# -*- coding: utf-8 -*-
import struct
import re
import collections
import json
import os

from _paths import HERE, SO_PATH

SO = SO_PATH


def main():
    with open(SO, "rb") as f:
        data = f.read()

    e_shoff = struct.unpack_from("<Q", data, 0x28)[0]
    e_shentsize = struct.unpack_from("<H", data, 0x3A)[0]
    e_shnum = struct.unpack_from("<H", data, 0x3C)[0]
    e_shstrndx = struct.unpack_from("<H", data, 0x3E)[0]
    e_entry = struct.unpack_from("<Q", data, 0x18)[0]

    def get_sh(i):
        off = e_shoff + i * e_shentsize
        return data[off : off + e_shentsize]

    shstr_hdr = get_sh(e_shstrndx)
    shstr_off = struct.unpack_from("<Q", shstr_hdr, 0x18)[0]
    shstr_size = struct.unpack_from("<Q", shstr_hdr, 0x20)[0]
    shstr = data[shstr_off : shstr_off + shstr_size]

    def sh_name(name_off):
        end = shstr.find(b"\x00", name_off)
        return shstr[name_off:end].decode(errors="replace")

    sections = []
    dynsym = dynstr = None
    for i in range(e_shnum):
        h = get_sh(i)
        name_off = struct.unpack_from("<I", h, 0)[0]
        sh_type = struct.unpack_from("<I", h, 4)[0]
        flags = struct.unpack_from("<Q", h, 8)[0]
        addr = struct.unpack_from("<Q", h, 0x10)[0]
        offset = struct.unpack_from("<Q", h, 0x18)[0]
        size = struct.unpack_from("<Q", h, 0x20)[0]
        nm = sh_name(name_off)
        sections.append(
            {
                "name": nm,
                "type": sh_type,
                "addr": hex(addr),
                "offset": hex(offset),
                "size": size,
                "flags": flags,
            }
        )
        if sh_type == 11 and nm == ".dynsym":
            dynsym = h
        if sh_type == 3 and nm == ".dynstr":
            dynstr = h

    if dynsym is None or dynstr is None:
        raise SystemExit("missing .dynsym/.dynstr")

    sym_off = struct.unpack_from("<Q", dynsym, 0x18)[0]
    sym_size = struct.unpack_from("<Q", dynsym, 0x20)[0]
    entsize = struct.unpack_from("<Q", dynsym, 0x38)[0] or 24
    str_off = struct.unpack_from("<Q", dynstr, 0x18)[0]
    str_size = struct.unpack_from("<Q", dynstr, 0x20)[0]
    strtab = data[str_off : str_off + str_size]

    def cstr(o):
        e = strtab.find(b"\x00", o)
        return strtab[o:e].decode(errors="replace") if e != -1 else ""

    syms = []
    n = sym_size // entsize
    for i in range(n):
        off = sym_off + i * entsize
        st_name = struct.unpack_from("<I", data, off)[0]
        st_info = data[off + 4]
        st_other = data[off + 5]
        st_shndx = struct.unpack_from("<H", data, off + 6)[0]
        st_value = struct.unpack_from("<Q", data, off + 8)[0]
        st_size = struct.unpack_from("<Q", data, off + 16)[0]
        name = cstr(st_name)
        if not name:
            continue
        bind = st_info >> 4
        typ = st_info & 0xF
        syms.append(
            {
                "name": name,
                "bind": bind,
                "type": typ,
                "value": st_value,
                "size": st_size,
                "shndx": st_shndx,
                "vis": st_other & 0x3,
            }
        )

    exported = [s for s in syms if s["bind"] in (1, 2) and s["shndx"] != 0]
    imports = [s for s in syms if s["shndx"] == 0]
    exp_funcs = [s for s in exported if s["type"] == 2]
    exp_objs = [s for s in exported if s["type"] != 2]

    print("ELF entry", hex(e_entry), "sections", e_shnum, "dynsyms", len(syms))
    print(
        "exported total",
        len(exported),
        "funcs",
        len(exp_funcs),
        "objs",
        len(exp_objs),
        "imports",
        len(imports),
    )

    patterns = [
        ("JNI_OnLoad", re.compile(r"^JNI_OnLoad$")),
        ("JNI_OnUnload", re.compile(r"^JNI_OnUnload$")),
        ("Java_JNI", re.compile(r"^Java_")),
        ("lua_api", re.compile(r"^lua(L|open)?_")),
        (
            "lua_bindings",
            re.compile(r"lua_cocos2dx|register_.*module|tolua|luaval"),
        ),
        (
            "JM_crypto",
            re.compile(
                r"JM|stringEncrypt|stringDecrypt|createAes|getAes|initLocalKey|xxtea|XXTEA|eswh|dswh|AesMap|aes::",
                re.I,
            ),
        ),
        (
            "OpenSSL",
            re.compile(
                r"^(AES_|EVP_|RSA_|SHA|MD5|HMAC|DES_|BN_|EC_|CRYPTO_|OPENSSL|PKCS|SSL_|TLS|BIO_|X509|PEM_|RAND_|ERR_|OCSP_|ENGINE_|DH_|DSA_|CMS_|ASN1_|i2d_|d2i_)"
            ),
        ),
        ("cocos2d", re.compile(r"_ZN7cocos2d|_ZNK7cocos2d|^cocos2d")),
        ("cocostudio", re.compile(r"cocostudio")),
        ("spine", re.compile(r"spine")),
        ("bullet", re.compile(r"bt[A-Z]|_ZN2bt|_ZN10bt|Bullet")),
        ("chipmunk", re.compile(r"^cp[A-Z]")),
        ("freetype", re.compile(r"^FT_|^FTC_")),
        ("curl", re.compile(r"^curl_|^Curl")),
        (
            "zlib",
            re.compile(
                r"^(inflate|deflate|compress|uncompress|zlib|crc32|adler32|gz)"
            ),
        ),
        ("png_jpeg_tiff", re.compile(r"^(png_|jpeg_|jpeglib|TIFF|_TIFF)")),
        ("sqlite", re.compile(r"^sqlite3_")),
        ("flatbuffers", re.compile(r"flatbuffers")),
        ("rapidjson", re.compile(r"rapidjson")),
        (
            "android_ndk",
            re.compile(
                r"^A(Asset|Native|Configuration|Looper|Input|Sensor|Choreographer)|__android"
            ),
        ),
    ]

    cats = collections.Counter()
    interesting = []
    for s in exp_funcs:
        n = s["name"]
        hit = False
        for cat, pat in patterns:
            if pat.search(n):
                cats[cat] += 1
                hit = True
                if cat in (
                    "JNI_OnLoad",
                    "JNI_OnUnload",
                    "Java_JNI",
                    "JM_crypto",
                    "lua_api",
                ) or any(
                    k in n
                    for k in (
                        "Encrypt",
                        "Decrypt",
                        "Aes",
                        "AES",
                        "xxtea",
                        "XXTEA",
                        "Token",
                        "Md5",
                        "MD5",
                    )
                ):
                    interesting.append(s)
                break
        if not hit:
            cats["other_func"] += 1

    print("FUNC categories:")
    for k, v in cats.most_common():
        print(f"  {k}: {v}")

    keys = [
        "JNI_OnLoad",
        "JNI_OnUnload",
        "Java_",
        "stringEncrypt",
        "stringDecrypt",
        "createAes",
        "getAes",
        "initLocalKey",
        "XXTEA",
        "xxtea",
        "JM",
        "doMd5",
        "getToken",
        "Token",
        "encrypt",
        "decrypt",
        "Aes",
        "AES_",
        "luaL_loadbuffer",
        "lua_load",
        "luaopen_",
        "register_all",
        "register_cocos",
        "HttpClient",
        "Downloader",
        "LuaEngine",
        "LuaStack",
        "LuaBridge",
        "AppDelegate",
        "cocos_android_app_init",
        "android_app",
        "Java_org",
    ]
    print("\n=== keyword hits among exported ===")
    keyword_map = {}
    for k in keys:
        hits = [s for s in exported if k.lower() in s["name"].lower()]
        keyword_map[k] = [
            {
                "name": s["name"],
                "addr": hex(s["value"]),
                "size": s["size"],
                "type": s["type"],
            }
            for s in sorted(hits, key=lambda x: x["name"])
        ]
        print(f"{k}: {len(hits)}")
        for s in sorted(hits, key=lambda x: x["name"])[:20]:
            print(
                f"  0x{s['value']:08x} t={s['type']} sz={s['size']} {s['name']}"
            )
        if len(hits) > 20:
            print("  ...")

    # string scan for magic/keys
    printable = re.compile(rb"[\x20-\x7e]{4,}")
    found_strings = []
    targets = [
        b"FZJH",
        b"JHHU",
        b"XXTEA",
        b"xxtea",
        b"stringEncrypt",
        b"stringDecrypt",
        b"createAes",
        b"initLocalKey",
        b"AES",
        b"openssl",
        b"JNI_OnLoad",
        b"luaL_loadbuffer",
        b"PcIQ",
        b"cbIh",
        b"T_TOKEN",
        b"get_token",
        b"exchange_publickey",
        b"FZJH03",
        b"FZJH02",
        b"JM::",
        b"cpp::aes",
        b"aes::",
        b"doMd5",
        b"Http",
    ]
    for m in printable.finditer(data):
        s = m.group()
        if any(t in s for t in targets):
            found_strings.append(
                {"offset": hex(m.start()), "value": s.decode("latin1", errors="replace")}
            )
    # de-dup preserve order
    seen = set()
    uniq_strings = []
    for item in found_strings:
        key = item["value"]
        if key in seen:
            continue
        seen.add(key)
        uniq_strings.append(item)

    print("\ninteresting strings:", len(uniq_strings))
    for item in uniq_strings[:120]:
        print(item["offset"], item["value"][:180])

    # needed libs from DT_NEEDED via dynamic
    # parse program headers for PT_DYNAMIC
    e_phoff = struct.unpack_from("<Q", data, 0x20)[0]
    e_phentsize = struct.unpack_from("<H", data, 0x36)[0]
    e_phnum = struct.unpack_from("<H", data, 0x38)[0]
    needed = []
    soname = None
    dyn_off = dyn_vaddr = None
    for i in range(e_phnum):
        poff = e_phoff + i * e_phentsize
        p_type = struct.unpack_from("<I", data, poff)[0]
        if p_type == 2:  # PT_DYNAMIC
            dyn_off = struct.unpack_from("<Q", data, poff + 8)[0]
            dyn_vaddr = struct.unpack_from("<Q", data, poff + 16)[0]
            break
    if dyn_off is not None:
        # find load bias for vaddr->file
        # simple: use section .dynamic offset
        for sec in sections:
            if sec["name"] == ".dynamic":
                dyn_off = int(sec["offset"], 16)
                break
        pos = dyn_off
        while True:
            tag = struct.unpack_from("<Q", data, pos)[0]
            val = struct.unpack_from("<Q", data, pos + 8)[0]
            pos += 16
            if tag == 0:
                break
            if tag == 1:  # DT_NEEDED
                needed.append(cstr(val))
            if tag == 14:  # DT_SONAME
                soname = cstr(val)

    print("soname", soname)
    print("needed", needed)

    payload = {
        "file": "libcocos2dlua_arm64.so",
        "size": len(data),
        "entry": hex(e_entry),
        "soname": soname,
        "needed": needed,
        "dynsym_count": len(syms),
        "exported_count": len(exported),
        "exported_funcs": len(exp_funcs),
        "exported_objects": len(exp_objs),
        "import_count": len(imports),
        "func_categories": dict(cats),
        "sections": sections,
        "keyword_map": keyword_map,
        "interesting_strings": uniq_strings[:500],
        "exported_functions": [
            {
                "name": s["name"],
                "addr": hex(s["value"]),
                "size": s["size"],
                "bind": s["bind"],
            }
            for s in sorted(exp_funcs, key=lambda x: x["name"])
        ],
        "exported_objects": [
            {
                "name": s["name"],
                "addr": hex(s["value"]),
                "size": s["size"],
                "type": s["type"],
                "bind": s["bind"],
            }
            for s in sorted(exp_objs, key=lambda x: x["name"])
        ],
        "imports_sample": [
            {"name": s["name"], "type": s["type"]}
            for s in sorted(imports, key=lambda x: x["name"])[:300]
        ],
    }

    out_json = os.path.join(HERE, "so_exports_full.json")
    with open(out_json, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
    print("wrote", out_json)

    with open(os.path.join(HERE, "so_exports_funcs.txt"), "w", encoding="utf-8") as f:
        for s in sorted(exp_funcs, key=lambda x: x["name"]):
            f.write("0x%08x  %6d  %s\n" % (s["value"], s["size"], s["name"]))
    print("wrote so_exports_funcs.txt")

    # focused crypto/jni subset
    focus_re = re.compile(
        r"JNI_|Java_|luaL_|lua_load|luaopen_|stringEncrypt|stringDecrypt|createAes|getAes|initLocalKey|XXTEA|xxtea|Aes|AES_|MD5|Md5|HMAC|EVP_|RSA_|SHA|encrypt|decrypt|Token|HttpClient|LuaEngine|LuaStack|LuaBridge|AppDelegate|register_.*module|register_all|cocos_android",
        re.I,
    )
    with open(os.path.join(HERE, "so_exports_focus.txt"), "w", encoding="utf-8") as f:
        for s in sorted(exp_funcs, key=lambda x: x["name"]):
            if focus_re.search(s["name"]):
                f.write("0x%08x  %6d  %s\n" % (s["value"], s["size"], s["name"]))
    print("wrote so_exports_focus.txt")


if __name__ == "__main__":
    main()
