#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""热更 Lua 推送工具(按客户端版本一键选加密组 + 目标目录)

背景
----
游戏的热更文件放在设备上:
    /data/user/0/com.xhtt.app.fzjh/files/updatePath_android_<版本>/<相对路径>
其中 .lua 是 JM 加密后的 hex 文本, 不同客户端版本用不同密钥组:
    2.1.01 -> 魔数 JHHU01, key 9B5A96B0F4A1EC60DB88349E3B926765, iv 34857d973953e44a
    2.1.02 -> 魔数 JHHU02, key cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF, iv PcIQIZifRalhZ88n
(见 config.UPDATE_CIPHER_GROUPS / config.UPDATE_VERSION_MAGIC)
明文用 ASCII '0' 补齐到 16 字节倍数; getMd5List 清单里的 md5 是"加密后 hex 文本"的 md5,
且随版本变化 —— 所以推哪一版就必须用哪一版的组加密。

用法
----
    python tools/push_hotupdate.py                 # 交互选择版本(默认)
    python tools/push_hotupdate.py 2.1.01          # 指定版本
    python tools/push_hotupdate.py 2.1.02 --only debug
    python tools/push_hotupdate.py 2.1.01 --dry-run
    python tools/push_hotupdate.py --list

推送内容(相对仓库根, 可用 --only 只推其中一项)
    debug      : debug/*.lua            -> src/app/views/layer/DebugLayer/
    mainlayer  : patched/MainLayer.<版本>.lua -> src/app/views/layer/MainLayer.lua

流程: 取 root -> 加密 -> adb push -> 继承目录属主 + chmod 600 -> 回读解密逐字节校验
      -> 与 mock 的 getMd5List 覆盖值(md5)对比。
"""

from __future__ import annotations

import argparse
import binascii
import hashlib
import os
import secrets
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

import config  # noqa: E402
import jm_crypto  # noqa: E402

ADB = os.getenv("ADB", r"D:\Program Files\platform-tools\adb.exe")
FILES_ROOT = "/data/user/0/com.xhtt.app.fzjh/files"
DEBUG_SUBDIR = "debug"
DEBUG_REMOTE = "src/app/views/layer/DebugLayer"
MAINLAYER_REMOTE = "src/app/views/layer/MainLayer.lua"


# ---------------------------------------------------------------------------
# 加密 / 解密
# ---------------------------------------------------------------------------

def group_for(version):
    magic = (getattr(config, "UPDATE_VERSION_MAGIC", None) or {}).get(str(version))
    if magic is None:
        raise SystemExit("未知版本 %s (config.UPDATE_VERSION_MAGIC 里没有)" % version)
    groups = getattr(config, "UPDATE_CIPHER_GROUPS", None) or {}
    if magic not in groups:
        raise SystemExit("config.UPDATE_CIPHER_GROUPS 里缺少 %r" % magic)
    return magic, groups[magic][0], groups[magic][1]


def encrypt_lua(plain: bytes, magic: bytes) -> bytes:
    """明文 -> hex 文本(magic + AES-256-CBC, '0' 填充到 16 字节倍数)。"""
    _m, key, iv = group_for(_version_of(magic))
    pad = (16 - len(plain) % 16) % 16
    return (magic + jm_crypto._aes_cbc(plain + b"0" * pad, key, iv, "enc")).hex().encode("ascii")


def decrypt_lua(text: str) -> bytes:
    raw = binascii.unhexlify(text.strip().lower())
    magic = raw[:6]
    _m, key, iv = group_for(_version_of(magic))
    return jm_crypto._aes_cbc(raw[6:], key, iv, "dec")


def _version_of(magic: bytes) -> str:
    for version, value in (getattr(config, "UPDATE_VERSION_MAGIC", None) or {}).items():
        if value == magic:
            return version
    raise SystemExit("魔数 %r 不在 config.UPDATE_VERSION_MAGIC 里" % magic)


def md5_of_file(path: Path, magic: bytes) -> str:
    """getMd5List 清单里的 md5 口径: 加密后 hex 文本的 md5。"""
    data = path.read_bytes()
    if data[:6] not in (getattr(config, "UPDATE_CIPHER_GROUPS", None) or {}):
        data = encrypt_lua(data, magic)
    return hashlib.md5(data).hexdigest()


# ---------------------------------------------------------------------------
# adb
# ---------------------------------------------------------------------------

def adb(*args, check=True, serial=None):
    cmd = [ADB]
    if serial:
        cmd += ["-s", serial]
    return subprocess.run(cmd + list(args), capture_output=True, check=check)


def ensure_root(serial=None):
    who = adb("shell", "id", serial=serial).stdout.decode(errors="replace")
    if who.startswith("uid=0"):
        return
    print("需要 root, 执行 adb root ...")
    adb("root", check=False, serial=serial)
    import time
    time.sleep(2)
    who = adb("shell", "id", serial=serial).stdout.decode(errors="replace")
    if not who.startswith("uid=0"):
        raise SystemExit("adb root 失败: %s" % who.strip())


def remote_dir(version, files_root=FILES_ROOT):
    return "%s/updatePath_android_%s" % (files_root.rstrip("/"), version)


# ---------------------------------------------------------------------------
# 待推送清单
# ---------------------------------------------------------------------------

def build_plan(version, only=None):
    plan = []
    if only in (None, "debug"):
        local_dir = ROOT / DEBUG_SUBDIR
        files = sorted(local_dir.rglob("*.lua")) if local_dir.is_dir() else []
        for path in files:
            rel = path.relative_to(local_dir).as_posix()
            plan.append(("debug", path, "%s/%s" % (DEBUG_REMOTE, rel)))
    if only in (None, "mainlayer"):
        for candidate in (ROOT / "patched" / ("MainLayer.%s.lua" % version),
                          ROOT / "patched" / "MainLayer.lua"):
            if candidate.is_file():
                plan.append(("mainlayer", candidate, MAINLAYER_REMOTE))
                break
        else:
            print("跳过 mainlayer: 找不到 patched/MainLayer.%s.lua 或 patched/MainLayer.lua" % version)
    return plan


def main(argv=None):
    parser = argparse.ArgumentParser(description="按客户端版本加密并推送热更 lua")
    parser.add_argument("version", nargs="?", help="客户端版本, 如 2.1.01 / 2.1.02")
    parser.add_argument("--list", action="store_true", help="只列出可用版本与待推送文件")
    parser.add_argument("--only", choices=("debug", "mainlayer"), help="只推其中一类")
    parser.add_argument("--dry-run", action="store_true", help="只打印计划, 不做任何写入")
    parser.add_argument("--serial", help="adb 设备序列号(多设备时用)")
    parser.add_argument("--files-root", default=FILES_ROOT, help="设备上 files 目录")
    parser.add_argument("--no-verify", action="store_true", help="跳过回读校验")
    args = parser.parse_args(argv)

    versions = list((getattr(config, "UPDATE_VERSION_MAGIC", None) or {}).keys())
    if not versions:
        raise SystemExit("config.UPDATE_VERSION_MAGIC 为空")
    if args.list:
        for version in versions:
            magic = config.UPDATE_VERSION_MAGIC[version]
            print("%s -> %s  目标 %s" % (version, magic.decode(), remote_dir(version, args.files_root)))
            for kind, local, remote in build_plan(version, args.only):
                print("    [%s] %s -> %s" % (kind, local.relative_to(ROOT), remote))
        return 0

    version = args.version
    if not version:
        print("可选版本: %s" % ", ".join(versions))
        version = input("选择版本: ").strip()
    if version not in versions:
        raise SystemExit("未知版本 %s, 可选: %s" % (version, ", ".join(versions)))

    magic, _key, _iv = group_for(version)
    target_root = remote_dir(version, args.files_root)
    plan = build_plan(version, args.only)
    print("版本 %s -> 魔数 %s, 目标 %s" % (version, magic.decode(), target_root))
    if not plan:
        raise SystemExit("没有要推送的文件")
    print("待推送 %d 个文件:" % len(plan))
    for kind, local, remote in plan:
        print("  [%-9s] %-40s -> %s" % (kind, local.relative_to(ROOT), remote))
    if args.dry_run:
        print("--dry-run: 结束(未写入设备)")
        return 0

    ensure_root(args.serial)
    if adb("shell", "test", "-d", target_root, check=False, serial=args.serial).returncode != 0:
        raise SystemExit("设备上没有目录 %s —— 该版本客户端至少启动过一次才会创建" % target_root)

    default_uid = adb("shell", "stat", "-c", "%u:%g", target_root,
                      serial=args.serial).stdout.decode().strip()
    staging = ROOT / (".push_hotupdate_staging_%s" % secrets.token_hex(4))
    staging.mkdir()  # 用默认权限, 不用 tempfile.mkdtemp(0700 在受限沙箱里不可写)
    ok = failed = 0
    md5_rows = []
    try:
        for kind, local, remote in plan:
            data = local.read_bytes()
            enc = encrypt_lua(data, magic)
            staged = staging / local.name
            staged.write_bytes(enc)
            target = "%s/%s" % (target_root, remote)
            adb("shell", "mkdir", "-p", os.path.dirname(target), serial=args.serial)
            pushed = adb("push", str(staged), target, check=False, serial=args.serial)
            if pushed.returncode != 0:
                print("  PUSH 失败 %-40s %s" % (remote, pushed.stderr.decode(errors="replace")[:100]))
                failed += 1
                continue
            uid = adb("shell", "stat", "-c", "%u:%g", os.path.dirname(target),
                      serial=args.serial).stdout.decode().strip() or default_uid
            adb("shell", "chown", uid, target, serial=args.serial)
            adb("shell", "chmod", "600", target, serial=args.serial)

            same = True
            if not args.no_verify:
                got = adb("shell", "cat", target, serial=args.serial).stdout.decode("ascii", "replace")
                expect = data + b"0" * ((16 - len(data) % 16) % 16)
                try:
                    same = decrypt_lua(got) == expect
                except Exception as error:  # noqa: BLE001
                    same = False
                    print("    校验异常: %s" % error)
            ok += 1 if same else 0
            failed += 0 if same else 1
            print("  %-40s 明文=%-7d 密文=%-8d 大小=%s 回读=%s"
                  % (remote, len(data), len(enc),
                     adb("shell", "stat", "-c", "%s", target,
                         serial=args.serial).stdout.decode().strip(),
                     "OK" if same else "不一致"))
            if kind == "mainlayer":
                md5_rows.append((remote, md5_of_file(local, magic)))
    finally:
        shutil.rmtree(staging, ignore_errors=True)

    print("\n推送成功 %d / 失败 %d" % (ok, failed))

    # 与 mock 的 getMd5List 覆盖值对齐检查(本地算, 不需要网络)
    try:
        sys.path.insert(0, str(ROOT))
        from handlers import service  # noqa: PLC0415
        overrides = service._md5_overrides(magic)
        print("mock md5 覆盖表(%s, %s): %d 项" % (version, magic.decode(), len(overrides)))
        for kind, local, remote in plan:
            key = remote
            if kind == "debug":
                key = remote
            want = overrides.get(key)
            got = md5_of_file(local, magic)
            print("  %-55s 清单覆盖=%s %s"
                  % (key, want or "(不在表里)", "OK" if want == got else "不一致"))
    except Exception as error:  # noqa: BLE001
        print("(跳过 md5 对照: %s)" % error)
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
