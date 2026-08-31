# -*- coding: utf-8 -*-
"""Analyze whether value.md can be decrypted with known keys."""
import binascii
import json
import os
import sys
import zlib

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)
import jm_crypto  # noqa: E402

VALUE = os.path.join(ROOT, "research", "samples", "value.md")
SO = os.path.join(ROOT, "research", "binaries", "libcocos2dlua_arm64_bootstrap.so")


def printable_ratio(buf):
    if not buf:
        return 0.0
    good = sum(1 for b in buf if 32 <= b < 127 or b in (9, 10, 13))
    return good / float(len(buf))


def try_unpad(dec):
    variants = {
        "rstrip0": dec.rstrip(b"0"),
        "raw": dec,
    }
    if dec:
        pad = dec[-1]
        if 1 <= pad <= 16 and all(x == pad for x in dec[-pad:]):
            variants["pkcs7"] = dec[:-pad]
    # also strip nulls
    variants["rstrip_null"] = dec.rstrip(b"\x00")
    return variants


def looks_json(p):
    s = p.lstrip()
    if not s or s[:1] not in (b"{", b"["):
        return False
    try:
        json.loads(p.decode("utf-8"))
        return True
    except Exception:
        return False


def try_decompress(p):
    out = []
    for name, fn in [
        ("zlib", lambda x: zlib.decompress(x)),
        ("zlib_raw", lambda x: zlib.decompress(x, -15)),
        ("gzip", lambda x: zlib.decompress(x, 16 + zlib.MAX_WBITS)),
    ]:
        try:
            d = fn(p)
            out.append((name, d))
        except Exception:
            pass
    return out


def main():
    raw_hex = open(VALUE, "rb").read().strip()
    text = "".join(raw_hex.decode("ascii", "ignore").split()).lower()
    raw = binascii.unhexlify(text)
    magic = raw[:6]
    enc = raw[6:]
    enc = enc[: len(enc) - (len(enc) % 16)]

    print("=== ciphertext meta ===")
    print("file:", VALUE)
    print("hex_len:", len(text))
    print("raw_len:", len(raw))
    print("magic_bytes:", magic, "ascii=", magic.decode("latin1", "replace"))
    print("magic_hex:", binascii.hexlify(magic).decode())
    print("enc_len:", len(enc), "blocks:", len(enc) // 16)
    print("enc_head16:", binascii.hexlify(enc[:16]).decode())

    # candidate keys
    ascii_keys = [
        ("default", b"cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF"),
        ("FZJH02/FXXF03", b"07818f3a34e8165227b0dc6b7e69ea57"),
        ("FZJH03_prod", b"26549f871287ba9e838a057a7ffac1bc"),
        ("test_key1", b"93a503f7cfaa11563a3ee36544f47430"),
        ("test_key2", b"a3374f473ed08213a285e7090196a93d"),
        ("FZJH01_ascii", b"ae9b363b80d5cc594973ecce1f4d546d"),
        ("JHHU01_ascii", b"9B5A96B0F4A1EC60DB88349E3B926765"),
        ("rodata_39a0", b"eirdOhIycKhV18r$3iqszOfgKTPUcEmj"),
        ("rodata_39c0", b"jX4SM#xx4cMBZR!txR0ghhI&cq*P36Ih"),
        ("rodata_3a00", b"SKMl^0SmirQ6Hcnh^1VwP1UBBzVz*M6Y"),
    ]

    # pull binary segments from SO around known key area
    so = open(SO, "rb").read()
    # file offset of rodata virtual 0x117aa10 is same on this ELF (offset == vaddr for ro)
    # Use previously known offsets from scripts (file offsets)
    bin_offsets = [
        0x1183980,
        0x11839A0,
        0x11839C0,
        0x11839E0,
        0x1183A00,
        0x1183A20,
        0x1183A40,
        0x1183A60,
        0x1183A80,
        0x1183AA0,
        0x1183AC0,
        0x1183AE0,
        0x1183B00,
        0x1183B18,
        0x1183B20,
        0x1183B40,
        0x1183B60,
        0x1183B80,
        0x1183BA0,
        0x1183BC0,
        0x1183BE0,
        0x1183BF0,
        0x1183BF8,
        0x1183C00,
        0x1183C20,
        0x1183C40,
        0x1185A48,
    ]
    for off in bin_offsets:
        seg = so[off : off + 64]
        # 16/24/32 raw bytes candidates
        for n in (16, 24, 32):
            k = seg[:n]
            if len(k) == n and any(b != 0 for b in k):
                ascii_keys.append(("so_%x_%d" % (off, n), k))
        # null-terminated ascii
        s = seg.split(b"\x00")[0]
        if 8 <= len(s) <= 64:
            ascii_keys.append(("so_cstr_%x" % off, s))

    # also search FXXF01 neighborhood
    p = so.find(b"FXXF01")
    print("FXXF01 in so:", hex(p) if p >= 0 else None)
    if p >= 0:
        neigh = so[p : p + 128]
        print("FXXF01 neigh:", bytes(b if 32 <= b < 127 else 46 for b in neigh).decode("latin1"))
        for n in (16, 24, 32):
            ascii_keys.append(("near_FXXF01_%d" % n, so[p + 6 : p + 6 + n]))
            ascii_keys.append(("near_FXXF01_off8_%d" % n, so[p + 8 : p + 8 + n]))

    # search magic FXXF01 string occurrences
    idx = 0
    occ = []
    while True:
        i = so.find(b"FXXF01", idx)
        if i < 0:
            break
        occ.append(i)
        idx = i + 1
    print("FXXF01 occurrences:", [hex(x) for x in occ])

    ivs = [
        ("PcIQ", b"PcIQIZifRalhZ88n"),
        ("def", b"34857d973953e44a"),
        ("zero", b"\x00" * 16),
        ("space", b" " * 16),
        ("magic_pad", b"FXXF01" + b"\x00" * 10),
        ("FXXF01xxxx", b"FXXF01FXXF01FXXF"),
    ]
    # also use 16B slices from so near FXXF
    if p >= 0:
        for off in range(0, 64, 8):
            ivs.append(("near_iv_%d" % off, so[p + off : p + off + 16]))

    # dedupe keys by content
    seen = set()
    keys = []
    for name, k in ascii_keys:
        if k in seen:
            continue
        # normalize only valid AES lengths later
        seen.add(k)
        keys.append((name, k))

    print("candidate keys:", len(keys), "ivs:", len(ivs))

    # auto jm_crypto
    print("\n=== jm_crypto.decrypt auto ===")
    try:
        plain = jm_crypto.decrypt(text)
        print("SUCCESS", plain[:200])
    except Exception as e:
        print("FAIL:", e)

    hits = []
    high = []
    for kname, key in keys:
        # variants of key interpretation
        key_vars = [(kname + "/raw", key)]
        # if looks like hex and length 32/48/64 chars
        try:
            if all(chr(c) in "0123456789abcdefABCDEF" for c in key) and len(key) in (32, 48, 64):
                key_vars.append((kname + "/hexdec", binascii.unhexlify(key)))
        except Exception:
            pass
        # pad/truncate to 16/24/32
        for label, kb in key_vars:
            for n in (16, 24, 32):
                if len(kb) >= n:
                    kk = kb[:n]
                    kl = "%s/k%d" % (label, n)
                elif len(kb) < n:
                    # skip pad unless exact
                    continue
                else:
                    continue
                for iname, iv in ivs:
                    if len(iv) != 16:
                        continue
                    try:
                        dec = jm_crypto._aes_cbc(enc, kk, iv, "dec")
                    except Exception:
                        continue
                    for utag, plain in try_unpad(dec).items():
                        pr = printable_ratio(plain)
                        if looks_json(plain):
                            hits.append((kl, iname, utag, pr, plain[:300]))
                            print("\n*** JSON HIT ***", kl, iname, utag)
                            print(plain[:500])
                        elif pr >= 0.70:
                            high.append((pr, kl, iname, utag, plain[:80]))
                        # try decompress on raw/unpadded
                        for dname, dplain in try_decompress(plain):
                            pr2 = printable_ratio(dplain)
                            if looks_json(dplain) or pr2 > 0.75:
                                hits.append((kl, iname, utag + "+" + dname, pr2, dplain[:300]))
                                print("\n*** DECOMP HIT ***", kl, iname, utag, dname, "pr=%.2f" % pr2)
                                print(dplain[:500])

    high.sort(reverse=True)
    print("\n=== top printable candidates (no json) ===")
    for item in high[:20]:
        pr, kl, iname, utag, head = item
        print("pr=%.3f %s %s %s head=%r" % (pr, kl, iname, utag, head))

    print("\n=== RESULT ===")
    print("json_or_decomp_hits:", len(hits))
    if hits:
        for h in hits:
            print(h[0], h[1], h[2], "pr=%.2f" % h[3])
    else:
        print("NO successful decrypt with known key candidates")
        print("Conclusion: ciphertext is valid JM-like (FXXF01), but key for FXXF01 is NOT in known static key set")


if __name__ == "__main__":
    main()
