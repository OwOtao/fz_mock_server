# -*- coding: utf-8 -*-
"""
放置江湖 Frida 密钥/格式提取启动器 (attach 模式 + 进程跟随)
============================================================
用法:
  python run_frida_getkeys.py                # 自动定位并跟随游戏进程
  python run_frida_getkeys.py --pid 6551     # 指定 PID

运行后到游戏里触发一次 HTTP 请求(登录/进服/商店), 输出会打印:
  createAes.key / createAes.iv   -> FZJH03 分组密钥, 填入 mock_server/config.py
  eswh.in / eswh.out             -> 加密输入输出, 确认格式(hex 前缀/填充)
"""
import sys
import os
import time
import argparse
import subprocess

sys.path.insert(0, r"c:\Users\Admin\.trae-cn\work\6a704b483b2cb82d8f8bea98\frida17_lib")
import frida

PKG = "com.xhtt.app.fzjh"
HOOK_JS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "frida_getkeys.js")
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
        t = p.get("type", "?")
        if t == "dump":
            ts = p.get("ts", 0)
            import datetime
            tstr = datetime.datetime.fromtimestamp(ts / 1000).strftime("%H:%M:%S.%f")[:-3]
            print("\n  [%s] == %s len=%d ==" % (tstr, p["tag"], p["len"]))
            print("    hex_head :", p["hex_head"])
            print("    text_head:", p["text_head"])
            print("    b64      :", p["b64"][:120] + ("..." if len(p["b64"]) > 120 else ""))
        else:
            print(p.get("msg", str(p)), flush=True)
    elif message["type"] == "error":
        print("[script-error]", message.get("description", message), flush=True)


def main():
    parser = argparse.ArgumentParser(description="放置江湖 Frida 密钥提取")
    parser.add_argument("--pid", type=int, default=None)
    parser.add_argument("--follow", action="store_true", help="进程重启后自动重新附加")
    args = parser.parse_args()

    print("=" * 60)
    print("  放置江湖 Frida 密钥/格式提取 (attach + 跟随重启)")
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
