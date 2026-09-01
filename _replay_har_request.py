# -*- coding: utf-8 -*-
"""从 HAR 提取 checkUpdate 原始请求头, 逐字节精确重放, 验证上游 500 是否服务器自身故障"""
import json
import socket
import sys
import time

sys.stdout.reconfigure(encoding="utf-8")

HAR = r"F:\AI\fzjh\fz_mock_server\so\ProxyPin8-24_14_40_30.har"
HOST = "update.xiaohoutiaotiao.com"
IP = "120.24.37.41"

with open(HAR, "r", encoding="utf-8") as f:
    har = json.load(f)

entry = None
for e in har["log"]["entries"]:
    url = e["request"]["url"]
    if url.rstrip("/").endswith("/checkUpdate"):
        entry = e
        break

req = entry["request"]
print("HAR 原始请求: %s %s" % (req["method"], req["url"]))
print("HAR 响应: status=%s contentLength=%s bodyHead=%r" % (
    entry["response"]["status"],
    entry["response"]["headers"],
    (entry["response"]["content"].get("text") or "")[:60]))

# 用原始头逐字节重放 (device 头按 UTF-8 原样发送)
lines = ["%s %s HTTP/1.1" % (req["method"], "/v1/checkUpdate")]
for h in req["headers"]:
    name = h["name"]
    if name.lower() in ("host", "connection", "content-length"):
        continue
    lines.append("%s: %s" % (name, h["value"]))
lines.append("Host: %s" % HOST)
lines.append("Connection: close")
raw = ("\r\n".join(lines) + "\r\n\r\n").encode("utf-8")
print("\n重放请求 (%d 字节):" % len(raw))
print(raw.decode("utf-8", "replace"))

s = socket.socket()
s.settimeout(20)
s.connect((IP, 80))
s.sendall(raw)
t0 = time.time()
chunks = []
while True:
    try:
        data = s.recv(65536)
    except socket.timeout:
        print("!! 读响应超时")
        break
    if not data:
        break
    chunks.append(data)
    if b"</html>" in b"".join(chunks):
        break
body = b"".join(chunks)
print("\n重放结果: %.3fs, %d 字节" % (time.time() - t0, len(body)))
head, _, rest = body.partition(b"\r\n\r\n")
print("状态行: %r" % head.split(b"\r\n")[0])
print("响应头: %r" % head)
print("响应体: %r" % rest[:200])
