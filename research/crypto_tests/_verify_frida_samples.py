# -*- coding: utf-8 -*-
import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")))
import jm_crypto

samples = {
    "update_apk": (
        "465a4a48303315ea8ac2b726ed0f81c130ba1a7673016a599402fa96799db09a"
        "eed2c862d7b673d19c73a8c9f925bfaaabd9ae70f78786c5b9719a80bf673720"
        "95a2a513bcc406368a4a1592d3d839ff2285b59c9cf318f160c05adb58b5d24a"
        "27831693bda794a5f4183320b8b1def4f371185131e17f0425be07398efda0dd"
        "377dca92f19cc3d0dcdbe5716b05edabac863cc115b0949440b76ab5f3360e22"
        "ba43691378cf6fdeb3c028585cee0a75b2b4a417f356553370d80de82ae54ce3"
        "295de2d0d181ba476755ed4d8ae6d4dedda869ab694137c55a87f4fbe5b57cff"
        "eb152ce872b38d100d18089fc3ea75259dacbc7ff632d09f2fe55705c6aff931"
        "94e124a3eee358e3678ab19450345ea209998efdb7351d97bb7e556263fc93dc"
        "9a937a1211298988885bdc1c97a13d1cd077d459c0e709328cbafb7844edd2eb"
        "84eea249700557898f752fe08fa5fea97047c0e3715b599920cad40db410f3df"
        "f2ed0e8153959a3392d383ede067070696ca8a716dc9a0af8feab9094a5ff2e5"
        "cd49833c458fb3fab63a2a74dfc5aa27f5c73417c4c51de4b79d89cc43f793ec"
        "278c26754177"
    ),
    "rand_t": (
        "465a4a4830339faf8e32c685902f189b920452daf89241411c358083aa4f59dc"
        "6f993ee0e8eb970a2beafb67d20b64c0dc6f103c116a1e829f3175c5596ee4fa"
        "04a745b620f3"
    ),
}

for name, hx in samples.items():
    try:
        plain = jm_crypto.decrypt(hx)
        print(name, "OK", plain[:220])
    except Exception as e:
        print(name, "FAIL", e)

# JHHU02 encrypt/decrypt roundtrip
plain = '{"adid":"197001010800000001","errcode":0}'
try:
    c = jm_crypto.encrypt(plain, group="JHHU02")
    back = jm_crypto.decrypt(c)
    print("JHHU02 roundtrip OK", c[:24], back)
except Exception as e:
    print("JHHU02 FAIL", e)
