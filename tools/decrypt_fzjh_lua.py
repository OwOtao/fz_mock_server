#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
放置江湖 (FangZhiJiangHu) APK Lua 脚本解密工具
================================================

破解对象: product_fangzhijianghu_guanfang_2.1.02.apk
加密方案: hex 文本编码 + JHHU02 魔数 + AES-256-CBC 自定义实现
参数来源: libcocos2dlua.so 中 JM::initLocalKey / JM::getKey 注册表

  算法 : AES-256-CBC
  Key  : cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF   (32 字节, .rodata 0x1183ac0)
  IV   : PcIQIZifRalhZ88n                   (16 字节, .rodata 0x1183b00)
  魔数 : JHHU02                             (6 字节, 密文前导)

解密流程: APK 内 .lua 原始字节(hex ASCII 文本)
          -> hex 解码
          -> 校验 JHHU02 魔数
          -> 跳过魔数, 对剩余密文按 16 字节块执行 AES-256-CBC 解密
          -> 得到 Lua 源码明文

特性:
  * 零第三方依赖: 内置纯 Python AES-256 实现, 任何 Python 3 环境可直接运行
  * 若系统装有 pycryptodome, 自动使用其 C 加速, 大幅提升批量速度
  * 批量模式: 从 APK 提取全部 .lua 并保留目录结构导出
  * 单文件模式: 解密任意 JHHU02 加密的 hex 文件

用法:
  # 批量解密 APK 内全部 Lua 脚本
  python decrypt_fzjh_lua.py <apk路径> [输出目录]

  # 解密单个 hex 加密文件到 stdout / 文件
  python decrypt_fzjh_lua.py --single <加密文件> [-o 输出文件]

示例:
  python decrypt_fzjh_lua.py product_fangzhijianghu_guanfang_2.1.02.apk
  python decrypt_fzjh_lua.py product_fangzhijianghu_guanfang_2.1.02.apk d:/out/lua
  python decrypt_fzjh_lua.py --single enc.lua -o dec.lua
"""

import os
import sys
import argparse
import zipfile

AES_KEY = b"cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF"  # 32 bytes => AES-256
AES_IV = b"PcIQIZifRalhZ88n"                    # 16 bytes => CBC IV
MAGIC = b"JHHU02"

# ---------------------------------------------------------------------------
# 纯 Python AES 实现 (FIPS-197, 支持 128/192/256 位密钥)
# 仅当 pycryptodome 不可用时才使用, 速度约慢 30-50 倍
# ---------------------------------------------------------------------------

_SBOX = [
    0x63,0x7c,0x77,0x7b,0xf2,0x6b,0x6f,0xc5,0x30,0x01,0x67,0x2b,0xfe,0xd7,0xab,0x76,
    0xca,0x82,0xc9,0x7d,0xfa,0x59,0x47,0xf0,0xad,0xd4,0xa2,0xaf,0x9c,0xa4,0x72,0xc0,
    0xb7,0xfd,0x93,0x26,0x36,0x3f,0xf7,0xcc,0x34,0xa5,0xe5,0xf1,0x71,0xd8,0x31,0x15,
    0x04,0xc7,0x23,0xc3,0x18,0x96,0x05,0x9a,0x07,0x12,0x80,0xe2,0xeb,0x27,0xb2,0x75,
    0x09,0x83,0x2c,0x1a,0x1b,0x6e,0x5a,0xa0,0x52,0x3b,0xd6,0xb3,0x29,0xe3,0x2f,0x84,
    0x53,0xd1,0x00,0xed,0x20,0xfc,0xb1,0x5b,0x6a,0xcb,0xbe,0x39,0x4a,0x4c,0x58,0xcf,
    0xd0,0xef,0xaa,0xfb,0x43,0x4d,0x33,0x85,0x45,0xf9,0x02,0x7f,0x50,0x3c,0x9f,0xa8,
    0x51,0xa3,0x40,0x8f,0x92,0x9d,0x38,0xf5,0xbc,0xb6,0xda,0x21,0x10,0xff,0xf3,0xd2,
    0xcd,0x0c,0x13,0xec,0x5f,0x97,0x44,0x17,0xc4,0xa7,0x7e,0x3d,0x64,0x5d,0x19,0x73,
    0x60,0x81,0x4f,0xdc,0x22,0x2a,0x90,0x88,0x46,0xee,0xb8,0x14,0xde,0x5e,0x0b,0xdb,
    0xe0,0x32,0x3a,0x0a,0x49,0x06,0x24,0x5c,0xc2,0xd3,0xac,0x62,0x91,0x95,0xe4,0x79,
    0xe7,0xc8,0x37,0x6d,0x8d,0xd5,0x4e,0xa9,0x6c,0x56,0xf4,0xea,0x65,0x7a,0xae,0x08,
    0xba,0x78,0x25,0x2e,0x1c,0xa6,0xb4,0xc6,0xe8,0xdd,0x74,0x1f,0x4b,0xbd,0x8b,0x8a,
    0x70,0x3e,0xb5,0x66,0x48,0x03,0xf6,0x0e,0x61,0x35,0x57,0xb9,0x86,0xc1,0x1d,0x9e,
    0xe1,0xf8,0x98,0x11,0x69,0xd9,0x8e,0x94,0x9b,0x1e,0x87,0xe9,0xce,0x55,0x28,0xdf,
    0x8c,0xa1,0x89,0x0d,0xbf,0xe6,0x42,0x68,0x41,0x99,0x2d,0x0f,0xb0,0x54,0xbb,0x16]

_INV_SBOX = [0] * 256
for _i, _v in enumerate(_SBOX):
    _INV_SBOX[_v] = _i


def _xtime(a):
    a <<= 1
    if a & 0x100:
        a ^= 0x11B
    return a & 0xFF


def _mul(a, b):
    r = 0
    while b:
        if b & 1:
            r ^= a
        a = _xtime(a)
        b >>= 1
    return r


def _key_expansion(key):
    """标准 AES 密钥扩展, 返回 (round_keys, num_rounds)"""
    nk = len(key) // 4          # 4 / 6 / 8
    nr = nk + 6                 # 10 / 12 / 14
    w = [list(key[i:i + 4]) for i in range(0, len(key), 4)]
    rcon = 1
    for i in range(nk, 4 * (nr + 1)):
        temp = w[i - 1][:]
        if i % nk == 0:
            temp = temp[1:] + temp[:1]          # RotWord
            temp = [_SBOX[b] for b in temp]     # SubWord
            temp[0] ^= rcon
            rcon = _xtime(rcon)
        elif nk > 6 and i % nk == 4:
            temp = [_SBOX[b] for b in temp]
        w.append([w[i - nk][j] ^ temp[j] for j in range(4)])
    rk = []
    for word in w:
        rk.extend(word)
    return rk, nr


def _add_round_key(state, rk, rnd):
    for c in range(4):
        for r in range(4):
            state[r][c] ^= rk[rnd * 16 + c * 4 + r]


def _inv_shift_rows(state):
    for r in range(1, 4):
        row = state[r][:]
        state[r] = row[-r:] + row[:-r]


def _inv_sub_bytes(state):
    for r in range(4):
        for c in range(4):
            state[r][c] = _INV_SBOX[state[r][c]]


def _inv_mix_columns(state):
    for c in range(4):
        a0, a1, a2, a3 = state[0][c], state[1][c], state[2][c], state[3][c]
        state[0][c] = _mul(a0, 14) ^ _mul(a1, 11) ^ _mul(a2, 13) ^ _mul(a3, 9)
        state[1][c] = _mul(a0, 9) ^ _mul(a1, 14) ^ _mul(a2, 11) ^ _mul(a3, 13)
        state[2][c] = _mul(a0, 13) ^ _mul(a1, 9) ^ _mul(a2, 14) ^ _mul(a3, 11)
        state[3][c] = _mul(a0, 11) ^ _mul(a1, 13) ^ _mul(a2, 9) ^ _mul(a3, 14)


def _aes_decrypt_block(block, rk, nr):
    state = [[block[c * 4 + r] for c in range(4)] for r in range(4)]
    _add_round_key(state, rk, nr)
    for rnd in range(nr - 1, 0, -1):
        _inv_shift_rows(state)
        _inv_sub_bytes(state)
        _add_round_key(state, rk, rnd)
        _inv_mix_columns(state)
    _inv_shift_rows(state)
    _inv_sub_bytes(state)
    _add_round_key(state, rk, 0)
    out = bytearray(16)
    for c in range(4):
        for r in range(4):
            out[c * 4 + r] = state[r][c]
    return bytes(out)


def _pure_aes_cbc_decrypt(data, key, iv):
    rk, nr = _key_expansion(key)
    out = b""
    prev = iv
    for i in range(0, len(data) - 15, 16):
        blk = data[i:i + 16]
        dec = _aes_decrypt_block(blk, rk, nr)
        out += bytes(a ^ b for a, b in zip(dec, prev))
        prev = blk
    return out


# ---------------------------------------------------------------------------
# 后端选择: 优先 pycryptodome, 否则使用内置纯 Python 实现
# ---------------------------------------------------------------------------

def _select_backend():
    try:
        from Crypto.Cipher import AES  # noqa
        return "pycryptodome"
    except ImportError:
        return "pure"

_BACKEND = _select_backend()


def _aes_cbc_decrypt(data, key, iv):
    if _BACKEND == "pycryptodome":
        from Crypto.Cipher import AES
        return AES.new(key, AES.MODE_CBC, iv).decrypt(data)
    return _pure_aes_cbc_decrypt(data, key, iv)


# ---------------------------------------------------------------------------
# 核心解密逻辑
# ---------------------------------------------------------------------------

def decrypt_lua_data(data):
    """解密一段 APK 内的 .lua 原始字节。

    data: 文件原始内容 (hex ASCII 文本)
    返回: Lua 明文 bytes; 非 JHHU02 加密文件返回 None
    """
    try:
        raw = bytes.fromhex(data.decode("ascii"))
    except (UnicodeDecodeError, ValueError):
        return None
    if not raw.startswith(MAGIC):
        return None
    enc = raw[len(MAGIC):]
    if len(enc) % 16 != 0:
        enc = enc[:len(enc) - (len(enc) % 16)]
    if not enc:
        return b""
    return _aes_cbc_decrypt(enc, AES_KEY, AES_IV)


def printable_score(data):
    """可读性评分, 用于解密结果自检 (0.0 ~ 1.0)"""
    if not data:
        return 0.0
    ok = sum(1 for b in data if 32 <= b < 127 or b in (9, 10, 13))
    return ok / len(data)


# ---------------------------------------------------------------------------
# 命令行入口
# ---------------------------------------------------------------------------

def cmd_batch(apk_path, out_dir, limit=None):
    if not os.path.isfile(apk_path):
        print(f"[错误] APK 文件不存在: {apk_path}")
        return 1
    os.makedirs(out_dir, exist_ok=True)

    with zipfile.ZipFile(apk_path) as zf:
        names = [n for n in zf.namelist() if n.lower().endswith(".lua")]
        if limit:
            names = names[:limit]
        print(f"[信息] 后端: {_BACKEND}")
        print(f"[信息] APK: {apk_path}")
        print(f"[信息] 输出: {out_dir}")
        print(f"[信息] Lua 文件总数: {len(names)}{' (limit=' + str(limit) + ')' if limit else ''}")
        print()

        ok = 0
        fail = 0
        score_sum = 0.0
        low_score = []
        for i, name in enumerate(names):
            data = zf.read(name)
            out = decrypt_lua_data(data)
            if out is None:
                fail += 1
                continue
            dst = os.path.join(out_dir, name.replace("/", os.sep))
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            with open(dst, "wb") as f:
                f.write(out)
            ok += 1
            sc = printable_score(out)
            score_sum += sc
            if sc < 0.7:
                low_score.append((name, round(sc, 3)))
            if (i + 1) % 500 == 0:
                print(f"[进度] {i + 1}/{len(names)}")

    print()
    print(f"[结果] 成功 {ok} / 失败 {fail}")
    if ok:
        print(f"[结果] 平均可读性: {score_sum / ok:.3f}")
    if low_score:
        print(f"[警告] 可读性低于 0.7 的文件 {len(low_score)} 个:")
        for n, s in low_score[:10]:
            print(f"         {s}  {n}")
    print(f"[结果] 输出目录: {os.path.abspath(out_dir)}")
    return 0 if fail == 0 else 2


def cmd_single(in_file, out_file):
    if not os.path.isfile(in_file):
        print(f"[错误] 文件不存在: {in_file}")
        return 1
    with open(in_file, "rb") as f:
        data = f.read()
    out = decrypt_lua_data(data)
    if out is None:
        print("[错误] 文件不是 JHHU02 加密格式 (hex + 魔数), 无法解密")
        return 2
    if out_file:
        with open(out_file, "wb") as f:
            f.write(out)
        print(f"[结果] 已解密 {len(out)} 字节 -> {out_file}")
        print(f"[结果] 可读性: {printable_score(out):.3f}")
    else:
        sys.stdout.buffer.write(out)
    return 0


def main():
    parser = argparse.ArgumentParser(
        description="放置江湖 APK Lua 脚本解密工具 (AES-256-CBC, 魔数 JHHU02)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__)
    parser.add_argument("apk", nargs="?", help="APK 文件路径 (批量模式)")
    parser.add_argument("outdir", nargs="?", default=None, help="输出目录 (批量模式, 默认同目录下 lua_out)")
    parser.add_argument("--single", metavar="FILE", help="解密单个 hex 加密文件")
    parser.add_argument("-o", "--output", metavar="FILE", help="单文件模式的输出文件 (缺省写 stdout)")
    parser.add_argument("--limit", type=int, default=None, metavar="N",
                        help="批量模式仅处理前 N 个文件 (调试用)")
    args = parser.parse_args()

    if args.single:
        return cmd_single(args.single, args.output)
    if not args.apk:
        parser.print_help()
        return 1

    out_dir = args.outdir or os.path.join(os.path.dirname(os.path.abspath(args.apk)) or ".", "lua_out")
    return cmd_batch(args.apk, out_dir, args.limit)


if __name__ == "__main__":
    sys.exit(main())
