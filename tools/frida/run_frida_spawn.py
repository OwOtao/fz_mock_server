# -*- coding: utf-8 -*-
"""
放置江湖 Frida 抓包启动器 (spawn 模式)
======================================
在游戏进程启动前注入 hook, 从第一条协议流量开始捕获。

前置条件:
  1. 雷电14 模拟器已启动, 游戏已安装 (com.xhtt.app.fzjh)
  2. 模拟器内 frida-server-17.16.4-android-x86_64 已运行 (root)
  3. 本机 Python 3.14 + frida 17.16.4

用法:
  python run_frida_spawn.py            # 正常启动
  python run_frida_spawn.py --clean    # 先强制停止游戏再启动
  python run_frida_spawn.py --output capture.log   # 输出到文件
"""
import sys
import os
import time
import argparse
import subprocess

sys.path.insert(0, r"c:\Users\Admin\.trae-cn\work\6a704b483b2cb82d8f8bea98\frida17_lib")
import frida

PKG = "com.xhtt.app.fzjh"
HOOK_JS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "frida_hook_addinfo.js")
ADB = r"E:\Program Files\LDPlayer14\adb.exe"
# 多设备环境下明确指定模拟器, 避免 get_usb_device() 误选真机
DEVICE_ID = "emulator-5554"

STOP_BANNER = r"""
============================================================
  放置江湖 Frida 抓包 (spawn 模式)
  Ctrl+C 停止并保存日志
============================================================
"""


def adb(*args):
    """执行 adb 命令 (多设备环境必须带 -s 指定模拟器)"""
    try:
        r = subprocess.run([ADB, "-s", DEVICE_ID] + list(args), capture_output=True, text=True, timeout=30)
        return r.stdout.strip()
    except Exception as e:
        return f"adb err: {e}"


def stop_game():
    """强制停止游戏进程"""
    print("[+] 强制停止游戏 ...")
    print(adb("shell", "am", "force-stop", PKG))
    time.sleep(1)


def on_message(message, data):
    if message["type"] == "send":
        payload = message["payload"]
        if isinstance(payload, dict):
            kind = payload.get("kind")
            details = payload.get("details", {})
            if kind == "jm-addInfo":
                # FXXF 开头的密钥组高亮显示
                mark = " <<< FXXF" if details.get("magic", "").startswith("FXXF") else ""
                print("[addInfo] magic=%s key=%s(%sB) iv=%s(%sB) tag=%s%s" % (
                    details.get("magic"), details.get("key"), details.get("key_len"),
                    details.get("iv"), details.get("iv_len"), details.get("tag"), mark), flush=True)
            elif kind == "jm-getKey-FXXF":
                print("[getKey-FXXF] magic=%s key=%s iv=%s" % (
                    details.get("magic"), details.get("key"), details.get("iv")), flush=True)
            elif kind == "aes-createAes":
                print("[createAes] key=%s(%sB) iv=%s(%sB) tag=%s" % (
                    details.get("key"), details.get("key_len"),
                    details.get("iv"), details.get("iv_len"), details.get("tag")), flush=True)
            elif kind in ("hooked", "all-hooked", "so-found", "injected"):
                print("[%s] %s" % (kind, details), flush=True)
            elif kind == "error":
                print("[hook-error] %s" % details, flush=True)
            elif kind == "timeout":
                print("[timeout] %s" % details, flush=True)
            else:
                print(payload, flush=True)
        else:
            print(payload, flush=True)
    elif message["type"] == "error":
        print("[script-error]", message.get("description", message), flush=True)
    elif message["type"] == "log":
        print("[log]", message.get("payload", ""), flush=True)


def main():
    parser = argparse.ArgumentParser(description="放置江湖 Frida 抓包")
    parser.add_argument("--clean", action="store_true", help="先强制停止游戏再启动")
    parser.add_argument("--output", default=None, help="输出到文件 (默认 stdout)")
    parser.add_argument("--timeout", type=int, default=0, help="自动停止秒数 (0=无限)")
    args = parser.parse_args()

    if args.clean:
        stop_game()

    print(STOP_BANNER)

    # 输出重定向
    log_file = None
    if args.output:
        log_file = open(args.output, "w", encoding="utf-8")
        print(f"[+] 日志输出到: {args.output}")

    # 连接设备 (多设备环境必须明确指定模拟器, 避免误选真机)
    mgr = frida.get_device_manager()
    dev = mgr.get_device(DEVICE_ID, timeout=10)
    print(f"[+] 设备: {dev.id} ({dev.name})")

    # spawn 游戏 (启动前注入)
    print(f"[+] spawn 启动 {PKG} ...")
    pid = dev.spawn([PKG])
    print(f"[+] spawn PID: {pid}")

    session = None
    resumed = False
    try:
        session = dev.attach(pid)
        print("[+] 已 attach (spawn 阶段)")
        with open(HOOK_JS_PATH, "r", encoding="utf-8") as f:
            script_code = f.read()
        script = session.create_script(script_code)
        script.on("message", on_message)
        script.load()
        print("[+] aesMap hook 脚本已注入")
        dev.resume(pid)
        resumed = True
        print("[+] 游戏已启动, 请在模拟器中登录或进入服务器触发 createAes...\n")
        start = time.time()
        while True:
            time.sleep(1)
            if args.timeout and (time.time() - start) > args.timeout:
                print(f"\n[+] 超时 {args.timeout}s, 自动停止")
                break
    except KeyboardInterrupt:
        print("\n[+] 用户停止")
    finally:
        if not resumed:
            try:
                dev.resume(pid)
            except Exception:
                pass
        if session:
            try:
                session.detach()
            except Exception:
                pass
        if log_file:
            log_file.close()
        print("[+] 已分离, 抓包结束")


if __name__ == "__main__":
    main()
