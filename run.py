# -*- coding: utf-8 -*-
"""mock 服务端启动入口: python run.py"""

import logging
import os
import sys

_ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _ROOT)

_LOG_FMT = "%(asctime)s [%(levelname)s] %(message)s"
_LOG_FILE = os.path.join(_ROOT, "server.log")

_root = logging.getLogger()
_root.setLevel(logging.INFO)
_root.handlers.clear()

_formatter = logging.Formatter(_LOG_FMT)

# Windows 控制台默认 GBK: device 头里带有已是乱码的 UTF-8 字节时, StreamHandler
# 会抛 UnicodeEncodeError(日志丢失 + stderr 刷栈)。改成遇错替换字符即可。
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(errors="replace")
    except (AttributeError, ValueError):
        pass

_console = logging.StreamHandler(sys.stdout)
_console.setFormatter(_formatter)
_root.addHandler(_console)

_file = logging.FileHandler(_LOG_FILE, encoding="utf-8")
_file.setFormatter(_formatter)
_root.addHandler(_file)

import handlers  # noqa: F401  (触发路由注册)
from server import serve_forever  # noqa: E402

if __name__ == "__main__":
    logging.info("日志同时写入: %s", _LOG_FILE)
    serve_forever()
