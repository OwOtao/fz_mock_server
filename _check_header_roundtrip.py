# -*- coding: utf-8 -*-
"""验证 http.server 收到 UTF-8 头后的解析与再编码行为 (mock 代理链路的关键环节)"""
import http.client
import io
import sys

sys.stdout.reconfigure(encoding="utf-8")

print("Python 版本:", sys.version)

# 游戏发送的 device 头 (UTF-8 字节)
raw = b'device: {"dev_name":"ld","app_name":"\xe6\x94\xbe\xe7\xbd\xae\xe6\xb1\x9f\xe6\xb9\x96"}\r\n\r\n'
msg = http.client.parse_headers(io.BytesIO(raw))
value = msg.get("device")
print("\nparse_headers 解析后的值:")
print("  repr:", repr(value))
print("  codepoints:", [hex(ord(c)) for c in value[25:35]])

try:
    encoded = value.encode("latin-1")
    print("\nlatin-1 再编码: 成功, 还原出原始 UTF-8 字节?", encoded == raw.split(b": ", 1)[1].split(b"\r\n")[0])
except UnicodeEncodeError as e:
    print("\nlatin-1 再编码: 失败! %s" % e)
    print("  -> 这意味着 mock 的 urllib 转发会抛 UnicodeEncodeError (ValueError 子类) -> 502")
