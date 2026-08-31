# -*- coding: utf-8 -*-
import json
import os
import re

from _paths import HERE

d = json.load(open(os.path.join(HERE, "so_exports_full.json"), encoding="utf-8"))
funcs = d["exported_functions"]


def show(title, pred):
    items = sorted([f for f in funcs if pred(f["name"])], key=lambda x: x["name"])
    print(f"\n=== {title} ({len(items)}) ===")
    for f in items:
        print(f"{f['addr']:>12} {f['size']:>6} {f['name']}")
    return items


show(
    "JM / AES / XXTEA / YXHelper / business HTTP",
    lambda n: (
        n.startswith("_ZN2JM")
        or "lua_myclass_encrypt_JM" in n
        or "lua_register_myclass_encrypt_JM" in n
        or n.startswith("_ZN3cpp3aes")
        or n.startswith("_Z13xxtea")
        or "YXHelper" in n
        or n.startswith("Java_com_xhtt")
        or n == "JNI_OnLoad"
        or "HttpManager" in n
        or n.startswith("_ZN8HttpTask")
        or n.startswith("_ZN11RequestTool")
        or "AppDelegate" in n
        or "cocos_android_app_init" in n
        or "setXXTEA" in n
        or "cleanupXXTEA" in n
        or "luaLoadBuffer" in n
        or "loadChunksFromZIP" in n
    ),
)

show("Java_* exports", lambda n: n.startswith("Java_"))
show(
    "register_all / register_*_module",
    lambda n: "register_all" in n or re.search(r"register_.*_module", n) is not None,
)

# cpp::aes all
show("cpp::aes all", lambda n: "cpp3aes" in n or "3cpp3aes" in n or "ZN3cpp3aes" in n)

# demangle-ish summary counts
print("\n=== summary counts ===")
print("total funcs", len(funcs))
print("Java_", sum(1 for f in funcs if f["name"].startswith("Java_")))
print("JNI_OnLoad", sum(1 for f in funcs if f["name"] == "JNI_OnLoad"))
print("JM class", sum(1 for f in funcs if f["name"].startswith("_ZN2JM")))
print("cpp::aes", sum(1 for f in funcs if "ZN3cpp3aes" in f["name"]))
print("lua_myclass", sum(1 for f in funcs if "lua_myclass" in f["name"]))
print("HttpManager", sum(1 for f in funcs if "HttpManager" in f["name"]))
print("OpenSSL AES_", sum(1 for f in funcs if f["name"].startswith("AES_")))
print("EVP_", sum(1 for f in funcs if f["name"].startswith("EVP_")))
