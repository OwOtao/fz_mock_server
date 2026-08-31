# -*- coding: utf-8 -*-
"""
放置江湖 Lua 批量解密器 (PC 端主控)
====================================
遍历 APK 中所有 JHHU02 加密的 Lua 文件, 通过 Frida RPC 调用
cpp::aes::getAesWithHead 解密并落盘到 decrypted_lua/ 目录。

支持游戏崩溃自动重启续传 (spawn-gating), 直到全部解密完成。

用法:
  使用 Python 3.14 执行 run_decrypt_lua.py
"""
import base64
import json
import os
import subprocess
import sys
import threading
import time
import zipfile

sys.path.insert(0, r"c:\Users\Admin\.trae-cn\work\6a704b483b2cb82d8f8bea98\frida17_lib")
import frida

APK = r"E:\Leidian14\Picutres\leidian9Picutres\product_fangzhijianghu_guanfang_2.1.02.apk"
OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "decrypted_lua")
PKG = "com.xhtt.app.fzjh"
ADB = r"E:\Program Files\LDPlayer14\adb.exe"
HOOK_JS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "frida_decrypt_lua.js")
MAGIC = b"JHHU02"

# 全局状态
state = {
    "ready": False,
    "key": None,
    "iv": None,
    "need_reinject": False,
}
lock = threading.Lock()
session = None
script = None


def adb(*args):
    return subprocess.run([ADB, *args], capture_output=True, text=True, timeout=30)


def collect_tasks():
    """遍历 APK, 找出所有 JHHU02 加密文件, 返回 [(relpath, enc_bytes)]"""
    tasks = []
    with zipfile.ZipFile(APK) as zf:
        for name in zf.namelist():
            if name.endswith(".lua") or name.endswith(".dat") or name.endswith(".czl"):
                data = zf.read(name)
                if data[:6] == MAGIC:
                    tasks.append((name, data))
    return tasks


def on_message(message, data):
    global state
    if message["type"] == "send":
        payload = message["payload"]
        if isinstance(payload, dict):
            t = payload.get("type")
            if t == "ready":
                with lock:
                    state["ready"] = True
                print(f"[ready] so 基址 {payload.get('base')} offset {payload.get('offset')}", flush=True)
            elif t == "key":
                with lock:
                    state["key"] = payload.get("key")
                print(f"[key] 已捕获 AES 密钥: {payload.get('key')[:24]}...", flush=True)
            elif t == "iv":
                with lock:
                    state["iv"] = payload.get("iv")
                print(f"[iv] 已捕获 IV: {payload.get('iv')[:24]}...", flush=True)
            elif t == "decrypted":
                pass  # 游戏运行时自动解密的文件, 由主循环去重处理
            elif t == "injected":
                print(f"[injected] pid={payload.get('pid')} arch={payload.get('arch')}", flush=True)
            elif t == "error":
                print(f"[script-error] {payload.get('msg')}", flush=True)
            elif t == "timeout":
                print(f"[script-timeout] {payload.get('msg')}", flush=True)
    elif message["type"] == "error":
        print(f"[js-error] {message.get('description', message)}", flush=True)


def inject(device, pid):
    """附加并注入 hook 脚本, 返回 (session, script)"""
    global session, script
    s = device.attach(pid)
    with open(HOOK_JS, "r", encoding="utf-8") as f:
        code = f.read()
    sc = s.create_script(code, runtime="v8")
    sc.on("message", on_message)
    sc.load()
    with lock:
        session = s
        script = sc
        state["ready"] = False
    return s, sc


def wait_ready(timeout=20):
    """等待 hook 就绪 (so 加载 + 捕获到有效 aes 对象)"""
    start = time.time()
    while time.time() - start < timeout:
        with lock:
            if state["ready"]:
                if script is not None:
                    try:
                        if script.exports_sync.ready():
                            return True
                    except Exception:
                        pass
                state["ready"] = False  # 重置, 等待下一次事件
        time.sleep(0.3)
    return False


def decrypt_file(relpath, enc_bytes, script):
    """通过 RPC 解密单个文件, 返回解密字节或 None"""
    try:
        enc_b64 = base64.b64encode(enc_bytes).decode()
        result = script.exports_sync.decrypt(enc_b64)
        if result and result.get("ok"):
            return base64.b64decode(result["out"])
        return None
    except Exception as e:
        print(f"  [rpc-error] {relpath}: {e}", flush=True)
        return None


def save_output(relpath, plain_bytes):
    """落盘解密结果, 保留 APK 内相对路径"""
    out_path = os.path.join(OUT_DIR, relpath)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "wb") as f:
        f.write(plain_bytes)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    print("=" * 60)
    print("  放置江湖 Lua 批量解密器")
    print(f"  输出目录: {OUT_DIR}")
    print("=" * 60)

    # 收集任务
    print("[+] 扫描 APK 中的 JHHU02 加密文件...")
    tasks = collect_tasks()
    print(f"[+] 找到 {len(tasks)} 个加密文件")

    todo = {relpath: enc for relpath, enc in tasks}
    done = 0
    failed = []

    manager = frida.get_device_manager()
    device = manager.get_usb_device(timeout=10)
    print(f"[+] 设备: {device.id} ({device.name})")

    # 启用 spawn-gating, 游戏每次启动都会先暂停
    device.enable_spawn_gating()

    def on_spawn_added(spawn):
        if getattr(spawn, "identifier", "") == PKG:
            def worker():
                global session, script
                try:
                    s, sc = inject(device, spawn.pid)
                    device.resume(spawn.pid)
                    print(f"[+] 已注入 PID={spawn.pid} 并恢复", flush=True)
                    s.on("detached", lambda reason, crash: on_detached(spawn.pid, reason, crash))
                except Exception as e:
                    print(f"[!] 注入失败: {e}", flush=True)
                    try:
                        device.resume(spawn.pid)
                    except Exception:
                        pass
            threading.Thread(target=worker, daemon=True).start()
        else:
            try:
                device.resume(spawn.pid)
            except Exception:
                pass

    def on_detached(pid, reason, crash):
        global session, script
        with lock:
            session = None
            script = None
            state["ready"] = False
        print(f"[detached] pid={pid} reason={reason}", flush=True)

    device.on("spawn-added", on_spawn_added)

    # 启动游戏
    adb("shell", "am", "force-stop", PKG)
    time.sleep(1)
    adb("shell", "am", "start", "-n", PKG + "/.activity.LauncherActivity")
    print("[+] 游戏已启动, 等待 hook 就绪...")

    # 主循环: 等待就绪 -> 批量解密 -> 崩溃后重试
    start_time = time.time()
    overall_timeout = 300  # 5 分钟上限

    while todo and time.time() - start_time < overall_timeout:
        if not wait_ready(30):
            print("[!] hook 未就绪 (游戏可能已崩溃), 等待重启...", flush=True)
            time.sleep(3)
            continue

        sc = script
        if sc is None:
            time.sleep(1)
            continue

        # 批量解密当前 todo 中尚未完成的任务
        batch = list(todo.items())
        print(f"[+] 开始解密本批 {len(batch)} 个文件...", flush=True)
        for relpath, enc_bytes in batch:
            if relpath not in todo:
                continue
            plain = decrypt_file(relpath, enc_bytes, sc)
            if plain is not None and len(plain) > 0:
                save_output(relpath, plain)
                todo.pop(relpath, None)
                done += 1
                if done % 100 == 0:
                    print(f"    进度: {done}/{len(tasks)}", flush=True)
            else:
                failed.append(relpath)

        if todo:
            print(f"[+] 剩余 {len(todo)} 个文件待解密 (可能因进程崩溃中断, 自动续传)...", flush=True)
            # 触发重启: 进程已死则等 spawn-gating 自动拉起
            time.sleep(2)

    # 清理
    try:
        device.disable_spawn_gating()
    except Exception:
        pass
    if session:
        try:
            session.detach()
        except Exception:
            pass

    print("\n" + "=" * 60)
    print(f"完成! 解密成功 {done}/{len(tasks)} 个文件")
    if failed:
        print(f"失败 {len(failed)} 个 (将被跳过):")
        for f in failed[:20]:
            print(f"  - {f}")
    print(f"输出目录: {OUT_DIR}")
    print("=" * 60)


if __name__ == "__main__":
    main()
