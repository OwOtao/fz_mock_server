# -*- coding: utf-8 -*-
"""只读: 把设备热更目录当前状态与"当前 getMd5List 覆盖会发出的 md5"逐条对照,
找出客户端校验必然报"文件损坏/被改动"的条目。
"""
import hashlib
import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)
sys.stdout.reconfigure(encoding="utf-8")
import config  # noqa: E402
from handlers import service  # noqa: E402

DEV = "/data/data/com.xhtt.app.fzjh/files/updatePath_android_2.1.02"
HAR = os.path.join(ROOT, "so", "ProxyPin9-10_18_00_08.har")


def sh(cmd, timeout=90):
    try:
        out = subprocess.run(["adb", "shell", "su -c '%s'" % cmd], capture_output=True, timeout=timeout)
        return out.stdout.decode("utf-8", "replace")
    except subprocess.TimeoutExpired:
        return ""


har = json.load(open(HAR, encoding="utf-8"))
for entry in har["log"]["entries"]:
    if "getMd5List" in entry["request"]["url"]:
        body = (entry["response"]["content"]["text"] or "").strip().encode()
        break
up = json.loads(service._update_cipher(body, "dec").decode())["data"]
ov = service._md5_overrides(service._update_magic_of(body))
result = service._apply_md5_override({"body": body, "status_code": 200,
                                      "headers": {"Content-Length": str(len(body))}})
sent = json.loads(service._update_cipher(result["body"], "dec").decode())["data"]

print("### 设备热更目录 vs 覆盖后服务端会下发的清单")
print("  覆盖项 %d 个; 服务端下发 original=%d deploy=%d"
      % (len(ov), len(sent["originalMd5List"]), len(sent["deployMd5List"])))
bad = []
for key in sorted(ov):
    dev_path = "%s/%s" % (DEV, key)
    out = sh("md5sum '%s' 2>/dev/null; wc -c < '%s' 2>/dev/null" % (dev_path, dev_path)).split()
    dev_md5 = out[0] if out else None
    size = out[1] if len(out) > 1 else "?"
    served = sent["originalMd5List"].get(key)
    ok = dev_md5 == served
    flag = "OK  " if ok else "不一致"
    if not ok:
        bad.append((key, dev_md5, served, size))
    print("  %s %-46s 设备=%-34s 下发=%-34s 字节=%s"
          % (flag, key.split("layer/")[-1], dev_md5 or "(不存在)", served, size))

print("\n### 结论: 客户端按这张清单校验时, 下列文件对不上 (就是'损坏/被改过'的对象)")
if bad:
    for key, dev, served, size in bad:
        print("  - %s  设备=%s(%s字节)  清单=%s" % (key, dev, size, served))
else:
    print("  无: 设备字节与下发 md5 完全一致")
