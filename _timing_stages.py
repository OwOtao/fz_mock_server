# -*- coding: utf-8 -*-
"""精确定位: DNS / TCP connect / 发送请求头 / 等响应 各阶段耗时"""
import socket
import sys
import time

sys.stdout.reconfigure(encoding="utf-8")

HOST = "update.xiaohoutiaotiao.com"
IP = "120.24.37.41"

DEVICE_CN = '{"dev_name":"ld_generic_x86_64","dev_model":"2512BPNDAC","dev_systemName":"android 34","dev_systemVersion":"14","dev_idfv":"guanfangd0b80cf7aa09ea3538329b0d","dev_net":"WWAN","app_name":"放置江湖","app_version":"2.1.02","app_build":"android-25","app_channel":"guanfang","imei":"","oaid":""}'

for round_no in (1, 2):
    print("=" * 80)
    print("ROUND %d" % round_no)

    t0 = time.time()
    socket.getaddrinfo(HOST, 80)
    print("  DNS:            %.3fs" % (time.time() - t0))

    s = socket.socket()
    s.settimeout(10)
    t0 = time.time()
    try:
        s.connect((IP, 80))
        print("  TCP connect:    %.3fs" % (time.time() - t0))
    except Exception as e:
        print("  TCP connect 失败: %r (%.3fs)" % (e, time.time() - t0))
        continue

    # 手工发请求: 先发不含中文的请求行+普通头, 单独测 device 中文头
    t0 = time.time()
    req_line = "GET /v1/checkUpdate HTTP/1.1\r\nHost: %s\r\n" % HOST
    req_line += "Connection: close\r\nUser-Agent: Dalvik/2.1.0\r\n"
    try:
        # device 头为 UTF-8 字节, 手工发送 (绕过 latin-1 编码限制)
        device_bytes = ("device: " + DEVICE_CN).encode("utf-8")
        full = req_line.encode("latin-1") + device_bytes + b"\r\n\r\n"
        s.sendall(full)
        print("  发送请求(UTF-8 device): %.3fs" % (time.time() - t0))
    except Exception as e:
        print("  发送失败: %r" % e)
        s.close()
        continue

    t0 = time.time()
    chunks = []
    try:
        while True:
            data = s.recv(65536)
            if not data:
                break
            chunks.append(data)
    except socket.timeout:
        print("  读响应: 超时 (>10s)")
    body = b"".join(chunks)
    head = body.split(b"\r\n\r\n", 1)[0]
    print("  读响应:        %.3fs, 共 %d 字节" % (time.time() - t0, len(body)))
    print("  响应行+头: %r" % head[:400])
    print("  响应体 head: %r" % body[len(head):len(head) + 120])
    s.close()
