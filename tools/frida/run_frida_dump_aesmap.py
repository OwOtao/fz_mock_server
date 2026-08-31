# -*- coding: utf-8 -*-
import argparse
import datetime
import os
import subprocess
import sys
import time

sys.path.insert(0, r"c:\Users\Admin\.trae-cn\work\6a704b483b2cb82d8f8bea98\frida17_lib")
import frida

PKG = "com.xhtt.app.fzjh"
ADB = r"E:\Program Files\LDPlayer14\adb.exe"
JS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "frida_dump_aesmap.js")


def get_pid():
    try:
        result = subprocess.run([ADB, "shell", "pidof", PKG], capture_output=True, text=True, timeout=15)
        value = result.stdout.strip()
        return int(value.split()[0]) if value else None
    except Exception:
        return None


def save_dump(payload):
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    path = os.path.join(os.path.dirname(JS), "aesmap_%s.json" % stamp)
    import json
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
    print("[+] dump 已保存: %s" % path, flush=True)


def on_message(message, data):
    if message["type"] == "error":
        print("[script-error]", message.get("description", message), flush=True)
        return
    if message["type"] != "send":
        return
    payload = message["payload"]
    kind = payload.get("type")
    if kind == "aesMap":
        save_dump(payload)
        print("[aesMap] count=%s reason=%s" % (payload.get("count"), payload.get("reason")), flush=True)
        for node in payload.get("nodes", []):
            aes = node.get("aes", {})
            print("  key=%r aes=%s" % (node.get("key"), aes.get("address")), flush=True)
            for item in aes.get("strings", []):
                print("    +0x%x %r" % (item["offset"], item["value"]), flush=True)
    elif kind == "createAes":
        print("[createAes] object=%s" % payload.get("object"), flush=True)
    elif kind == "module":
        print("[module] name=%s arch=%s base=%s aesMap=%s createAes=%s" % (
            payload.get("name"), payload.get("arch"), payload.get("base"),
            payload.get("aesMap"), payload.get("createAes")), flush=True)
    elif kind == "export":
        print("[export] %s -> %s" % (payload.get("symbol"), payload.get("address")), flush=True)
    elif kind == "missingExport":
        print("[!] 导出符号不存在: %s" % payload.get("symbol"), flush=True)
    else:
        print(payload, flush=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--pid", type=int)
    parser.add_argument("--follow", action="store_true")
    parser.add_argument("--retries", type=int, default=5)
    parser.add_argument("--retry-delay", type=float, default=3.0)
    args = parser.parse_args()
    device = frida.get_device_manager().get_usb_device(timeout=10)
    pid = args.pid
    session = None
    try:
        while True:
            if session is None:
                if pid is None:
                    pid = get_pid()
                if pid is None:
                    print("[+] 等待游戏进程...", flush=True)
                    time.sleep(2)
                    continue
                print("[+] 附加 PID %s" % pid, flush=True)
                attached = False
                for attempt in range(1, args.retries + 1):
                    try:
                        session = device.attach(pid)
                        with open(JS, "r", encoding="utf-8") as f:
                            script = session.create_script(f.read())
                        script.on("message", on_message)
                        script.load()
                        attached = True
                        print("[+] 已注入，等待 aesMap 输出", flush=True)
                        break
                    except frida.TimedOutError as e:
                        print("[!] attach 超时 (%d/%d): %s" % (attempt, args.retries, e), flush=True)
                    except Exception as e:
                        print("[!] attach/加载失败 (%d/%d): %s" % (attempt, args.retries, e), flush=True)
                    if session:
                        try:
                            session.detach()
                        except Exception:
                            pass
                        session = None
                    time.sleep(args.retry_delay)
                if not attached:
                    print("[!] 多次 attach 失败，放弃当前 PID", flush=True)
                    pid = None
                    if not args.follow:
                        break
                    time.sleep(args.retry_delay)
                    continue
            if not get_pid():
                session.detach()
                session = None
                if not args.follow:
                    break
                pid = None
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        if session:
            try:
                session.detach()
            except Exception:
                pass


if __name__ == "__main__":
    main()
