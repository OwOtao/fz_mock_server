# -*- coding: utf-8 -*-
"""
放置江湖 HTTP 密文抓取启动器 (libc hook, 兼容 x86_64 转译)
==========================================================
用法:
  python run_frida_httptext.py

运行后进游戏触发请求, 终端会打印 [BODY] 开头的 JM 密文(hex 文本)。
复制一条密文, 用 verify_key.py 验证密钥:
  python mock_server/verify_key.py <密文hex>   (或 --file 存到文件)
"""
import sys
import os
import time
import argparse
import subprocess

sys.path.insert(0, r"c:\Users\Admin\.trae-cn\work\6a704b483b2cb82d8f8bea98\frida17_lib")
import frida

PKG = "com.xhtt.app.fzjh"
HOOK_JS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "frida_httptext.js")
ADB = r"E:\Program Files\LDPlayer14\adb.exe"


def get_pid():
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
        p = message["payload"]
        if isinstance(p, str):
            print(p, flush=True)
        else:
            print(p.get("msg", str(p)), flush=True)
    elif message["type"] == "error":
        print("[script-error]", message.get("description", message), flush=True)


def main():
    parser = argparse.ArgumentParser(description="放置江湖 HTTP 密文抓取")
    parser.add_argument("--pid", type=int, default=None)
    parser.add_argument("--follow", action="store_true")
    args = parser.parse_args()

    print("=" * 60)
    print("  放置江湖 HTTP 密文抓取 (libc hook, 转译环境可用)")
    print("  Ctrl+C 停止")
    print("=" * 60)

    dev = frida.get_device_manager().get_usb_device(timeout=10)
    print(f"[+] 设备: {dev.id} ({dev.name})")

    current_pid = args.pid
    session = None
    script = None
    try:
        while True:
            if session is not None and session.is_detached:
                session = None
            if session is None:
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
                    print("[+] Hook 已注入, 请操作游戏触发 HTTP 请求\n")
                except Exception as e:
                    print(f"[!] 附加失败: {e}")
                    session = None
                    current_pid = None
                    time.sleep(3)
                    continue
            if not get_pid():
                print(f"\n[+] 游戏进程 {current_pid} 已退出")
                if args.follow:
                    session = None
                    current_pid = None
                    time.sleep(2)
                    continue
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
        print("[+] 已分离")


if __name__ == "__main__":
    main()
