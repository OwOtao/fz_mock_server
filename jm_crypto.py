# -*- coding: utf-8 -*-
"""
JM 加密组件: 与游戏 libcocos2dlua.so 中 JM::stringEncrypt/stringDecrypt 对齐
=============================================================================
格式约定(从 APK 内 lua 密文 + 源码实测得出):
    stringEncrypt(plain, version) -> hex文本( 魔数 + AES-256-CBC(plain) )
    - 魔数: JHHU02 (密钥组决定)
    - 明文用 ASCII '0' 补齐到 16 字节块(块满补整块)
    - 密文整体 hex 编码输出(小写)

零第三方依赖: 优先 pycryptodome, 否则使用内置纯 Python AES-256 实现。
密钥组定义见 config.KEY_GROUPS。
"""

import binascii
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# ---------------------------------------------------------------------------
# AES 表
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
    nk = len(key) // 4
    nr = nk + 6
    w = [list(key[i:i + 4]) for i in range(0, len(key), 4)]
    rcon = 1
    for i in range(nk, 4 * (nr + 1)):
        temp = w[i - 1][:]
        if i % nk == 0:
            temp = temp[1:] + temp[:1]
            temp = [_SBOX[b] for b in temp]
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


def _shift_rows(state):
    for r in range(1, 4):
        state[r] = state[r][r:] + state[r][:r]


def _inv_shift_rows(state):
    for r in range(1, 4):
        state[r] = state[r][-r:] + state[r][:-r]


def _sub_bytes(state):
    for r in range(4):
        for c in range(4):
            state[r][c] = _SBOX[state[r][c]]


def _inv_sub_bytes(state):
    for r in range(4):
        for c in range(4):
            state[r][c] = _INV_SBOX[state[r][c]]


def _mix_columns(state):
    for c in range(4):
        a0, a1, a2, a3 = state[0][c], state[1][c], state[2][c], state[3][c]
        state[0][c] = _mul(a0, 2) ^ _mul(a1, 3) ^ a2 ^ a3
        state[1][c] = a0 ^ _mul(a1, 2) ^ _mul(a2, 3) ^ a3
        state[2][c] = a0 ^ a1 ^ _mul(a2, 2) ^ _mul(a3, 3)
        state[3][c] = _mul(a0, 3) ^ a1 ^ a2 ^ _mul(a3, 2)


def _inv_mix_columns(state):
    for c in range(4):
        a0, a1, a2, a3 = state[0][c], state[1][c], state[2][c], state[3][c]
        state[0][c] = _mul(a0, 14) ^ _mul(a1, 11) ^ _mul(a2, 13) ^ _mul(a3, 9)
        state[1][c] = _mul(a0, 9) ^ _mul(a1, 14) ^ _mul(a2, 11) ^ _mul(a3, 13)
        state[2][c] = _mul(a0, 13) ^ _mul(a1, 9) ^ _mul(a2, 14) ^ _mul(a3, 11)
        state[3][c] = _mul(a0, 11) ^ _mul(a1, 13) ^ _mul(a2, 9) ^ _mul(a3, 14)


def _aes_encrypt_block(block, rk, nr):
    state = [[block[c * 4 + r] for c in range(4)] for r in range(4)]
    _add_round_key(state, rk, 0)
    for rnd in range(1, nr):
        _sub_bytes(state)
        _shift_rows(state)
        _mix_columns(state)
        _add_round_key(state, rk, rnd)
    _sub_bytes(state)
    _shift_rows(state)
    _add_round_key(state, rk, nr)
    out = bytearray(16)
    for c in range(4):
        for r in range(4):
            out[c * 4 + r] = state[r][c]
    return bytes(out)


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


def _pure_cbc(data, key, iv, op):
    rk, nr = _key_expansion(key)
    out = b""
    prev = iv
    for i in range(0, len(data) - 15, 16):
        blk = data[i:i + 16]
        if op == "enc":
            x = bytes(a ^ b for a, b in zip(blk, prev))
            cur = _aes_encrypt_block(x, rk, nr)
        else:
            dec = _aes_decrypt_block(blk, rk, nr)
            cur = bytes(a ^ b for a, b in zip(dec, prev))
        out += cur
        prev = blk if op == "dec" else cur
    return out


def _backend():
    try:
        from Crypto.Cipher import AES  # noqa
        return "pycryptodome"
    except ImportError:
        return "pure"


_BACKEND = _backend()


def _aes_cbc(data, key, iv, op):
    if _BACKEND == "pycryptodome":
        from Crypto.Cipher import AES
        if op == "enc":
            return AES.new(key, AES.MODE_CBC, iv).encrypt(data)
        return AES.new(key, AES.MODE_CBC, iv).decrypt(data)
    return _pure_cbc(data, key, iv, op)


# ---------------------------------------------------------------------------
# JM 格式层
# ---------------------------------------------------------------------------

def _pad(data):
    """明文用 ASCII '0' 补齐到 16 字节块, 块满补整块(与游戏一致)。"""
    pad = 16 - len(data) % 16
    if pad == 0:
        pad = 16
    return data + b"0" * pad


def _unpad(data):
    """去掉尾部 ASCII '0' 填充。"""
    return data.rstrip(b"0")


def is_encrypted(text):
    """判断文本是否为 JM 加密格式(hex 文本且以已知魔数 hex 开头)。"""
    if not isinstance(text, str):
        return False
    t = text.strip().lower()
    for group in _groups().values():
        magic = group["magic"]
        if t.startswith(binascii.hexlify(magic).decode()):
            return True
    return False


# 延迟引入 config 避免循环依赖(config 只存数据)
def _groups():
    from config import KEY_GROUPS
    return KEY_GROUPS


def encrypt(plain, group_name=None):
    """加密: 返回 hex 文本(小写)。group_name 默认取 config.RESPONSE_GROUP。"""
    if group_name is None:
        from config import RESPONSE_GROUP
        group_name = RESPONSE_GROUP
    g = _groups()[group_name]
    if g["key"] is None:
        raise RuntimeError("密钥组 %s 尚未配置 (运行 frida_getkeys.js 提取后填入 config.py)" % group_name)
    if isinstance(plain, str):
        plain = plain.encode("utf-8")
    data = _pad(plain)
    enc = _aes_cbc(data, g["key"], g["iv"], "enc")
    return binascii.hexlify(g["magic"] + enc).decode()


def decrypt(text, group_name=None):
    """解密: 输入 hex 文本, 返回明文 bytes。自动按魔数选择密钥组。"""
    if group_name is None:
        g = _detect_group(text)
    else:
        g = _groups()[group_name]
    if g is None or g["key"] is None:
        raise RuntimeError("无法解密: 密钥组缺失或未配置")
    raw = binascii.unhexlify(text.strip().lower())
    if not raw.startswith(g["magic"]):
        raise ValueError("密文魔数不匹配: 期望 %s" % g["magic"])
    enc = raw[len(g["magic"]):]
    enc = enc[:len(enc) - (len(enc) % 16)]
    plain = _aes_cbc(enc, g["key"], g["iv"], "dec")
    return _unpad(plain)


def _detect_group(text):
    """按密文开头的魔数识别密钥组。"""
    t = text.strip().lower()
    for name, g in _groups().items():
        if t.startswith(binascii.hexlify(g["magic"]).decode()):
            return g
    return None


def magic_hex(group_name=None):
    """返回密钥组魔数的 hex 前缀(用于识别加密文本)。"""
    if group_name is None:
        from config import RESPONSE_GROUP
        group_name = RESPONSE_GROUP
    return binascii.hexlify(_groups()[group_name]["magic"]).decode()
