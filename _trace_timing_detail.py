# -*- coding: utf-8 -*-
"""用 monkey-patch 追踪 urllib 请求各阶段耗时, 定位 15s 延迟的来源"""
import http.client
import socket
import sys
import time
import urllib.request

sys.stdout.reconfigure(encoding="utf-8")

T0 = time.time()


def mark(label):
    print("  [%8.3fs] %s" % (time.time() - T0, label))


# patch http.client 关键方法
_orig_connect = http.client.HTTPConnection.connect
_orig_putheader = http.client.HTTPConnection.putheader
_orig_endheaders = http.client.HTTPConnection.endheaders
_orig_getresponse = http.client.HTTPConnection.getresponse
_orig_getaddrinfo = socket.getaddrinfo


def traced_connect(self):
    mark("connect() 开始 host=%s:%s" % (self.host, self.port))
    t = time.time()
    _orig_connect(self)
    mark("connect() 完成 %.3fs" % (time.time() - t))


def traced_putheader(self, header, *values):
    try:
        _orig_putheader(self, header, *values)
    except UnicodeEncodeError as e:
        mark("putheader(%s) 抛 UnicodeEncodeError: %s" % (header, e))
        raise


def traced_endheaders(self, *a, **kw):
    mark("endheaders() 开始(此时才真正联网发送)")
    t = time.time()
    _orig_endheaders(self, *a, **kw)
    mark("endheaders() 完成 %.3fs (请求已发出)" % (time.time() - t))


def traced_getresponse(self):
    mark("getresponse() 开始(等响应头)")
    t = time.time()
    r = _orig_getresponse(self)
    mark("getresponse() 完成 %.3fs status=%s" % (time.time() - t, r.status))
    return r


def traced_getaddrinfo(host, port, *a, **kw):
    t = time.time()
    r = _orig_getaddrinfo(host, port, *a, **kw)
    mark("getaddrinfo(%s) %.3fs -> %s" % (host, time.time() - t, r[0][4][0]))
    return r


http.client.HTTPConnection.connect = traced_connect
http.client.HTTPConnection.putheader = traced_putheader
http.client.HTTPConnection.endheaders = traced_endheaders
http.client.HTTPConnection.getresponse = traced_getresponse
socket.getaddrinfo = traced_getaddrinfo

DEVICE_CN = '{"dev_name":"ld_generic_x86_64","dev_model":"2512BPNDAC","dev_systemName":"android 34","dev_systemVersion":"14","dev_idfv":"guanfangd0b80cf7aa09ea3538329b0d","dev_net":"WWAN","app_name":"放置江湖","app_version":"2.1.02","app_build":"android-25","app_channel":"guanfang","imei":"","oaid":""}'

print("== CASE A: 带中文字符 device 头 (Unicode str) ==")
req = urllib.request.Request("http://update.xiaohoutiaotiao.com/v1/checkUpdate", method="GET")
req.add_header("device", DEVICE_CN)
req.add_header("channel", "guanfang")
req.add_header("ver", "2.1.02")
t0 = time.time()
try:
    with urllib.request.urlopen(req, timeout=10) as resp:
        resp.read()
        print("  结果: status=%s 总耗时=%.2fs" % (resp.status, time.time() - t0))
except Exception as e:
    print("  结果: %s: %s 总耗时=%.2fs" % (type(e).__name__, e, time.time() - t0))
