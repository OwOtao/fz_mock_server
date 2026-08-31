# -*- coding: utf-8 -*-
"""
放置江湖 Frida spawn-gating 启动器

每次 com.xhtt.app.fzjh 进程被创建时：
  1. Frida 先暂停该进程；
  2. 附加并注入 fzjh_jm_spawn_hook.js；
  3. 恢复进程；
  4. 若游戏崩溃或自行重启，spawn-added 事件会再次触发并重复上述流程。

使用前确认：
  - frida-server-17.16.4-android-x86_64 正在模拟器运行；
  - adb 已连接 emulator-5554；
  - 本机使用 Python 3.14 和 frida 17.16.4。

运行：
  使用 Python 3.14 执行 run_fzjh_spawn_gating.py

可选：
  --preview  仅用于已授权的测试账号；会显示最多 256 个字符，并自动屏蔽常见凭据字段。
"""
import argparse
import json
import os
import subprocess
import sys
import threading
import time

sys.path.insert(0, r"c:\Users\Admin\.trae-cn\work\6a704b483b2cb82d8f8bea98\frida17_lib")
import frida

PACKAGE = "com.xhtt.app.fzjh"
ADB = r"E:\Program Files\LDPlayer14\adb.exe"
HOOK_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fzjh_jm_spawn_hook.js")

sessions = {}
lock = threading.Lock()


def adb(*args):
    return subprocess.run([ADB, *args], capture_output=True, text=True, timeout=20)


def print_message(message, data):
    if message["type"] == "send":
        payload = message["payload"]
        kind = payload.get("kind", "message") if isinstance(payload, dict) else "message"
        details = payload.get("details", payload) if isinstance(payload, dict) else payload
        print(f"[{kind}] {json.dumps(details, ensure_ascii=False)}", flush=True)
    elif message["type"] == "error":
        print(f"[script-error] {message.get('description', message)}", flush=True)


def inject_and_resume(device, pid, preview):
    """在 spawn 暂停状态下附加、注入、恢复；无论成败均尝试恢复进程。"""
    session = None
    try:
        print(f"[spawn] 捕获目标进程 PID={pid}，注入 Hook…", flush=True)
        session = device.attach(pid)

        with open(HOOK_PATH, "r", encoding="utf-8") as hook_file:
            code = hook_file.read()
        code = "var options = { capturePreview: %s };\n" % ("true" if preview else "false") + code
        script = session.create_script(code, runtime="v8")
        script.on("message", print_message)
        script.load()

        with lock:
            sessions[pid] = (session, script)

        def on_detached(reason, crash):
            with lock:
                sessions.pop(pid, None)
            print(f"[detached] PID={pid} reason={reason} crash={crash}", flush=True)

        session.on("detached", on_detached)
        print(f"[spawn] PID={pid} Hook 已注入，恢复游戏进程。", flush=True)
    except Exception as exc:
        print(f"[error] PID={pid} 注入失败：{exc}", flush=True)
        if session is not None:
            try:
                session.detach()
            except Exception:
                pass
    finally:
        # 不恢复会导致游戏永久卡在 spawn 暂停状态。
        try:
            device.resume(pid)
        except Exception as exc:
            print(f"[warn] PID={pid} 恢复失败：{exc}", flush=True)


def main():
    parser = argparse.ArgumentParser(description="放置江湖 Frida spawn-gating + JM Hook")
    parser.add_argument("--preview", action="store_true", help="显示脱敏后的有限参数预览，仅用于已授权测试")
    parser.add_argument("--no-launch", action="store_true", help="只等待手动启动游戏，不自动拉起")
    args = parser.parse_args()

    if not os.path.isfile(HOOK_PATH):
        raise FileNotFoundError(f"找不到 Hook 脚本：{HOOK_PATH}")

    manager = frida.get_device_manager()
    device = manager.get_usb_device(timeout=10)
    print(f"[ready] 设备：{device.id} ({device.name})", flush=True)

    # enable_spawn_gating 必须先于启动目标应用执行。
    device.enable_spawn_gating()
    print("[ready] spawn-gating 已启用，游戏的每次重启都会自动被暂停并注入。", flush=True)

    def on_spawn_added(spawn):
        identifier = getattr(spawn, "identifier", "")
        if identifier == PACKAGE or identifier.startswith(PACKAGE + ":"):
            worker = threading.Thread(
                target=inject_and_resume,
                args=(device, spawn.pid, args.preview),
                daemon=True,
            )
            worker.start()
        else:
            # 不阻塞广告/WebView 等非目标子进程。
            try:
                device.resume(spawn.pid)
            except Exception:
                pass

    device.on("spawn-added", on_spawn_added)

    if not args.no_launch:
        # 先停止旧实例，确保下一次启动必然触发 spawn-added。
        adb("shell", "am", "force-stop", PACKAGE)
        time.sleep(1)
        result = adb("shell", "am", "start", "-n", PACKAGE + "/.activity.LauncherActivity")
        print(f"[launch] {result.stdout.strip() or result.stderr.strip()}", flush=True)
    else:
        print("[ready] 请现在手动启动游戏。", flush=True)

    print("[ready] 按 Ctrl+C 停止 spawn-gating 与所有 Hook 会话。", flush=True)
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n[stop] 正在清理…", flush=True)
    finally:
        with lock:
            active = list(sessions.values())
            sessions.clear()
        for session, _script in active:
            try:
                session.detach()
            except Exception:
                pass
        try:
            device.disable_spawn_gating()
        except Exception:
            pass
        print("[stop] 已停止。", flush=True)


if __name__ == "__main__":
    main()
