# -*- coding: utf-8 -*-
"""FXXF01 深度爆破: 尝试二进制 key、XXTEA、以及更多组合."""
import sys, os, binascii, struct
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "mock_server"))
import jm_crypto

HERE = os.path.dirname(os.path.abspath(__file__))
MOCK_SERVER_ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
SO_PATH = os.path.join(
    MOCK_SERVER_ROOT, "research", "binaries", "libcocos2dlua_arm64_bootstrap.so"
)
raw = binascii.unhexlify(open(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                           "server_config_raw.bin"), "rb").read().strip())
magic, enc = raw[:6], raw[6:]
print(f"magic={magic} enc_len={len(enc)} blocks={len(enc)//16}")

# 从 SO 读取二进制 key 区域
with open(SO_PATH, "rb") as f:
    # 0x11839a0 = FZJH04 fallback (128B)
    f.seek(0x11839a0)
    fzjh04_key_128 = f.read(128)
    # 0x1183a20 = ABCTJM fallback (128B)
    f.seek(0x1183a20)
    abctjm_key_128 = f.read(128)

print(f"\nFZJH04 fallback key (0x11839a0, 128B): {fzjh04_key_128[:48].hex()}")
print(f"ABCTJM fallback key (0x1183a20, 128B): {abctjm_key_128[:48].hex()}")

IVS = {
    "defIV": b"34857d973953e44a",
    "PcIQ": b"PcIQIZifRalhZ88n",
    "zero": b"\x00" * 16,
}

def try_decrypt(key, iv, label):
    if len(key) not in (16, 24, 32):
        return False
    try:
        dec = jm_crypto._aes_cbc(enc, key, iv, "dec")
    except Exception:
        return False
    stripped = dec.rstrip(b"0")
    if not stripped:
        return False
    printable = sum(1 for b in stripped if 32 <= b < 127 or b in (9, 10, 13)) / len(stripped)
    starts_json = stripped[:1] in (b"{", b"[")
    if starts_json or printable > 0.85:
        print(f"\n*** HIT [{label}] printable={printable:.0%} ***")
        print(f"    key={key[:32]!r}...")
        print(f"    iv={iv!r}")
        try:
            print(f"    text={stripped[:500].decode('utf-8')}")
        except:
            print(f"    raw={stripped[:100]}")
        return True
    return False

# 1. 尝试二进制 key 的前 32/16 字节
print("\n=== 二进制 fallback key 尝试 ===")
found = False
for name, keydata in [("FZJH04_128", fzjh04_key_128), ("ABCTJM_128", abctjm_key_128)]:
    for klen in (32, 16):
        k = keydata[:klen]
        for iname, iv in IVS.items():
            if try_decrypt(k, iv, f"{name}[:{klen}]/{iname}"):
                found = True

# 2. XXTEA 尝试
print("\n=== XXTEA 尝试 ===")
def xxtea_decrypt(data, key):
    """简化 XXTEA 解密 (与 SO 中 xxtea_decrypt 对齐)."""
    DELTA = 0x9E3779B9
    n = len(data) // 4
    if n < 2:
        return None
    v = list(struct.unpack(f"<{n}I", data[:n*4]))
    # key 扩展为 4 个 uint32
    k = list(struct.unpack("<4I", key[:16].ljust(16, b"\x00")))
    q = 6 + 52 // n
    z = v[n - 1]
    s = (q * DELTA) & 0xFFFFFFFF
    while s != 0:
        e = (s >> 2) & 3
        for p in range(n - 1, 0, -1):
            z = v[p - 1]
            v[p] = (v[p] - (((z >> 5 ^ v[p] << 2) + (v[p] >> 3 ^ z << 4)) ^ ((s ^ v[p]) + (k[(p & 3) ^ e] ^ z)))) & 0xFFFFFFFF
        z = v[n - 1]
        v[0] = (v[0] - (((z >> 5 ^ v[0] << 2) + (v[0] >> 3 ^ z << 4)) ^ ((s ^ v[0]) + (k[0 ^ e] ^ z)))) & 0xFFFFFFFF
        s = (s - DELTA) & 0xFFFFFFFF
    result = struct.pack(f"<{n}I", *v)
    return result

XXTEA_KEYS = [
    ("FZJH01_ascii", b"ae9b363b80d5cc594973ecce1f4d546d"),
    ("FZJH01_hex", binascii.unhexlify("ae9b363b80d5cc594973ecce1f4d546d")),
    ("JHHU02", b"cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF"),
    ("FXXF03", b"07818f3a34e8165227b0dc6b7e69ea57"),
    ("FZJH03_prod", b"26549f871287ba9e838a057a7ffac1bc"),
    ("defIV_str", b"34857d973953e44a"),
    ("PcIQ", b"PcIQIZifRalhZ88n"),
]

for kname, key in XXTEA_KEYS:
    try:
        dec = xxtea_decrypt(enc, key)
        if dec:
            stripped = dec.rstrip(b"\x00")
            printable = sum(1 for b in stripped[:200] if 32 <= b < 127 or b in (9, 10, 13)) / max(len(stripped[:200]), 1)
            if printable > 0.8 or stripped[:1] in (b"{", b"["):
                print(f"\n*** XXTEA HIT [{kname}] printable={printable:.0%} ***")
                print(f"    text={stripped[:300]}")
                found = True
    except Exception:
        pass

# 3. 尝试 FZJH04/ABCTJM 的 ASCII 部分作为 key
print("\n=== 其他组合 ===")
other_keys = [
    ("FZJH04_str", fzjh04_key_128[:32]),
    ("ABCTJM_str", abctjm_key_128[:32]),
    ("rodata_3a40", None),  # 需要读取
]
# 读取更多 rodata
with open(SO_PATH, "rb") as f:
    f.seek(0x1183a40)
    extra1 = f.read(32)
    f.seek(0x1183a60)
    extra2 = f.read(32)

for name, key in [("rodata_3a40", extra1), ("rodata_3a60", extra2)]:
    for iname, iv in IVS.items():
        if try_decrypt(key, iv, f"{name}/{iname}"):
            found = True

if not found:
    print("\n[!] 所有静态候选均失败")
    print("    FXXF01 密钥确认为运行时动态下发 (bootstrap 阶段)")
    print("    需要 Frida hook createAes/addInfo 在游戏启动时捕获")
