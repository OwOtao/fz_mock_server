# -*- coding: utf-8 -*-
"""mock 服务端启动入口: python run.py

优雅关闭流程(收到 Ctrl+C / SIGINT、SIGTERM、SIGBREAK 时触发):
    1. 停止 accept 循环并关闭监听 socket(端口立刻可以重新绑定);
    2. 等待在途请求处理完(默认最多 MOCK_SHUTDOWN_TIMEOUT=5 秒), 超时则断开剩余连接;
    3. 落盘登录/存档状态(state.json + data/archives);
    4. flush 并关闭日志文件句柄(server.log)。
关闭过程中再按一次 Ctrl+C 会立即强制退出。
"""

import logging
import os
import signal
import sys
import threading
import time

_ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _ROOT)

_LOG_FMT = "%(asctime)s [%(levelname)s] %(message)s"
_LOG_FILE = os.path.join(_ROOT, "server.log")


def _env_timeout(name, default):
    try:
        value = float(os.getenv(name, default))
    except (TypeError, ValueError):
        return default
    return value if value >= 0 else default


# 优雅关闭时等待在途请求的最长秒数(可用环境变量覆盖)
_DRAIN_TIMEOUT = _env_timeout("MOCK_SHUTDOWN_TIMEOUT", 5.0)

_root = logging.getLogger()
_root.setLevel(logging.INFO)
_root.handlers.clear()

_formatter = logging.Formatter(_LOG_FMT)

# Windows 控制台默认 GBK: device 头里带有已是乱码的 UTF-8 字节时 StreamHandler
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
from server import create_server  # noqa: E402

log = logging.getLogger("mock_server")


def _shutdown_server(srv, timeout=_DRAIN_TIMEOUT):
    """优雅关闭: 先释放监听 socket, 再等在途请求, 最后落盘并关闭日志。"""
    started = time.monotonic()
    log.info("开始优雅关闭: listen=%s, 在途请求最长等待 %.1fs",
             getattr(srv, "server_address", None), timeout)

    # 1) 停止 accept 循环, 释放监听 socket(端口立即可复用)
    #    serve_forever 已退出时 shutdown() 会立即返回, 可安全重复调用。
    try:
        srv.shutdown()
    except Exception:
        log.exception("停止 accept 循环失败")
    try:
        srv.server_close()
        log.info("监听 socket 已释放")
    except Exception:
        log.exception("关闭监听 socket 失败")

    # 2) 等在途请求自然结束; 超时则断开剩余连接, 避免 socket 泄漏
    try:
        pending = srv.active_request_count()
        if pending:
            log.info("等待 %d 个在途请求结束 ...", pending)
        if srv.wait_for_requests(timeout):
            if pending:
                log.info("在途请求已全部结束")
        else:
            log.warning("等待超时, 强制断开剩余 %d 个连接", srv.active_request_count())
            srv.close_active_connections()
            srv.wait_for_requests(1.0)
    except Exception:
        log.exception("处理在途请求失败")

    # 3) 业务状态落盘(存档在写入时已逐个落盘, 这里保证最终一致)
    try:
        state = getattr(srv, "state", None)
        if state is None:
            pass
        elif getattr(state, "autosave", False):
            state.save()
            log.info("状态已落盘: %s", getattr(state, "json_path", None) or "(memory only)")
        else:
            log.info("STATE_AUTOSAVE 已关闭, 跳过最终落盘")
    except Exception:
        log.exception("状态落盘失败")

    # 4) flush 并关闭所有日志 handler(含 server.log)
    #    先摘掉 handler 再 shutdown, 避免被强制断开的线程之后写日志时报 I/O 错误
    log.info("mock server 已停止, 关闭耗时 %.3fs", time.monotonic() - started)
    for handler in list(_root.handlers):
        _root.removeHandler(handler)
    logging.shutdown()


def main():
    srv = None
    signals = {"count": 0}

    def _handle_signal(signum, _frame):
        try:
            name = signal.Signals(signum).name
        except (ValueError, AttributeError):
            name = str(signum)
        signals["count"] += 1
        if signals["count"] > 1 or srv is None:
            log.warning("收到 %s, 立即强制退出", name)
            logging.shutdown()
            os._exit(1)
        log.info("收到 %s, 准备优雅关闭 (再按一次强制退出)", name)
        # shutdown() 会等 serve_forever 循环退出, 不能在主线程(信号处理)里直接调用,
        # 否则 accept 循环与 shutdown 会互相等待造成死锁。
        threading.Thread(target=srv.shutdown, name="mock-shutdown", daemon=True).start()

    for name in ("SIGINT", "SIGTERM", "SIGBREAK"):
        signum = getattr(signal, name, None)
        if signum is None:
            continue
        try:
            signal.signal(signum, _handle_signal)
        except (ValueError, OSError):
            log.debug("无法注册 %s 信号处理", name)

    try:
        srv = create_server()
        srv.serve_forever(poll_interval=0.2)
    except KeyboardInterrupt:
        log.info("收到 KeyboardInterrupt, 准备优雅关闭")
    finally:
        if srv is not None:
            _shutdown_server(srv)


if __name__ == "__main__":
    logging.info("日志同时写入: %s", _LOG_FILE)
    main()
