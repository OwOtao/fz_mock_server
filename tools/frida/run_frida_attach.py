# -*- coding: utf-8 -*-
"""
放置江湖 Frida 抓包启动器 v3 (attach 模式 + 进程重启跟随)
============================================================
自动处理游戏进程重启: 检测到进程退出后自动重新附加。

用法:
  python run_frida_attach.py              # 自动定位并跟随游戏进程
  python run_frida_attach.py --pid 6551   # 指定 PID
"""
import sys
import os
import time
import argparse
import subprocess

sys.path.insert(0, r"c:\Users\Admin\.trae-cn\work\6a704b483b2cb82d8f8bea98\frida17_lib")
import frida

PKG = "com.xhtt.app.fzjh"
HOOK_JS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fzjh_network_hook.js")
ADB = r"E:\Program Files\LDPlayer14\adb.exe"


def get_pid():
    """获取游戏进程 PID (None 表示未运行)"""
    try:
        r = subprocess.run([ADB, "shell", "pidof", PKG], capture_output=True, text=True, timeout=15)
        out = r.stdout.strip()
        if out:
            return int(out.split()[0])
    except Exception:
        pass
    return None


def on_message(message, data):
    if message["type"] == "send":
        print(message["payload"], flush=True)
    elif message["type"] == "error":
        print("[script-error]", message.get("description", message), flush=True)


def main():
    parser = argparse.ArgumentParser(description="放置江湖 Frida 抓包 v3")
    parser.add_argument("--pid", type=int, default=None, help="游戏进程 PID (默认自动)")
    parser.add_argument("--follow", action="store_true", help="进程重启后自动重新附加")
    parser.add_argument("--timeout", type=int, default=0, help="自动停止秒数 (0=无限)")
    args = parser.parse_args()

    print("=" * 60)
    print("  放置江湖 Frida 网络抓包 (attach + 跟随重启)")
    print("  Ctrl+C 停止")
    print("=" * 60)

    dev = frida.get_device_manager().get_usb_device(timeout=10)
    print(f"[+] 设备: {dev.id} ({dev.name})")

    current_pid = args.pid
    session = None
    script = None

    try:
        while True:
            # 需要附加: 无 session 或已分离时
            if session is not None and session.is_detached:
                session = None
            if session is None:
                # 找进程
                if current_pid is None:
                    current_pid = get_pid()
                if current_pid is None:
                    print("[+] 未找到游戏进程, 等待启动...")
                    time.sleep(3)
                    continue

                print(f"[+] 附加游戏进程 PID {current_pid}")
                try:
                    session = dev.attach(current_pid)
                    with open(HOOK_JS_PATH, "r", encoding="utf-8") as f:
                        code = f.read()
                    script = session.create_script(code)
                    script.on("message", on_message)
                    script.load()
                    print("[+] 纯 Frida 网络 Hook 已注入")
                    print("[+] 请操作游戏触发网络请求 (登录/进服/商店)")
                    print("[+] Ctrl+C 停止\n")
                except Exception as e:
                    print(f"[!] 附加失败: {e}")
                    session = None
                    current_pid = None
                    time.sleep(3)
                    continue

            # 检查进程是否还活着
            if not get_pid():
                print(f"\n[+] 游戏进程 {current_pid} 已退出")
                if args.follow:
                    print("[+] 等待新进程并重新附加...")
                    session = None
                    current_pid = None
                    time.sleep(2)
                    continue
                else:
                    print("[!] 未启用 --follow, 停止")
                    break

            time.sleep(1)

    except KeyboardInterrupt:
        print("\n[+] 用户停止")
    finally:
        if session:
            try:
                session.detach()
            except Exception:
                pass
        print("[+] 已分离, 抓包结束")


if __name__ == "__main__":
    main()
