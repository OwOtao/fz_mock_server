# -*- coding: utf-8 -*-
"""验证: urllib 是否走了系统代理, 以及代理对耗时的影响"""
import sys
import time
import urllib.request

sys.stdout.reconfigure(encoding="utf-8")

print("== urllib.request.getproxies() ==")
proxies = urllib.request.getproxies()
print(proxies)

print("\n== getproxies_environment ==")
print(urllib.request.getproxies_environment())

print("\n== 原始套接字直连 vs urllib 默认(带系统代理) vs urllib 禁用代理 ==")
URL = "http://update.xiaohoutiaotiao.com/v1/checkUpdate"

# 1. urllib 默认 opener (走系统代理)
t0 = time.time()
try:
    with urllib.request.urlopen(URL, timeout=30) as r:
        r.read()
        print("默认opener: status=%s 耗时=%.2fs" % (r.status, time.time() - t0))
except urllib.error.HTTPError as e:
    e.read()
    print("默认opener: HTTP %s 耗时=%.2fs" % (e.code, time.time() - t0))
except Exception as e:
    print("默认opener: %s: %s 耗时=%.2fs" % (type(e).__name__, e, time.time() - t0))

# 2. 显式禁用代理
opener_noproxy = urllib.request.build_opener(urllib.request.ProxyHandler({}))
t0 = time.time()
try:
    with opener_noproxy.open(URL, timeout=30) as r:
        r.read()
        print("禁用代理: status=%s 耗时=%.2fs" % (r.status, time.time() - t0))
except urllib.error.HTTPError as e:
    e.read()
    print("禁用代理: HTTP %s 耗时=%.2fs" % (e.code, time.time() - t0))
except Exception as e:
    print("禁用代理: %s: %s 耗时=%.2fs" % (type(e).__name__, e, time.time() - t0))
