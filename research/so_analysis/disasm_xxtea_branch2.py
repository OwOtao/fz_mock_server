# -*- coding: utf-8 -*-
"""反汇编 stringDecrypt(Data) 的 XXTEA 分支 (0x654744) 和 getKey 的运行时 map 查找."""
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH

with open(SO_PATH, "rb") as f:
    elf = ELFFile(f)

    def va_to_off(va):
        for seg in elf.iter_segments():
            if seg["p_type"] == "PT_LOAD" and seg["p_vaddr"] <= va < seg["p_vaddr"] + seg["p_filesz"]:
                return va - seg["p_vaddr"] + seg["p_offset"]
        return None

    def read_cstr(va, maxlen=120):
        off = va_to_off(va)
        if off is None:
            return None
        f.seek(off)
        raw = f.read(maxlen)
        e = raw.find(b"\x00")
        return raw[:e] if e >= 0 else raw

    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)

    # 1. XXTEA 分支: 从 0x654744 开始 (isUseXXTEA=true 时跳转目标)
    # stringDecrypt(Data) 函数范围: 0x654464 .. 0x654464+1460
    func_va = 0x654464
    func_sz = 1460
    off = va_to_off(func_va)
    f.seek(off)
    code = f.read(func_sz)

    print("=== stringDecrypt(Data) XXTEA 分支 (0x654744 起) ===")
    started = False
    for insn in md.disasm(code, func_va):
        if insn.address >= 0x654744:
            started = True
        if started:
            print(f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}")

    # 2. 读取 isUseXXTEA 比较的 3 个 magic 字符串
    # isUseXXTEA 从全局 0x15e62c8 加载 3 个 std::string
    # 这些是运行时初始化的, 但让我看看 initLocalKey 是否写入了它们
    # 实际上让我看看 0x6526e4 中比较的字符串内容
    # 从反汇编看, 它比较的是 [x19], [x19+8], [x19+0x10] 其中 x19=0x15e62c8
    # 这些是 std::string 对象, 内容在运行时确定

    # 3. 看看 getHttpHeaders 中 addInfo 的参数
    print("\n\n=== cpp::Game::getHttpHeaders 中 addInfo 调用上下文 ===")
    # getHttpHeaders @0x6868a0, size=10620
    gh_va = 0x6868a0
    gh_sz = 10620
    off = va_to_off(gh_va)
    f.seek(off)
    code = f.read(gh_sz)

    # 只看 addInfo 调用点附近 (0x689a60 和 0x689c88)
    for target in [0x689a60, 0x689c88]:
        print(f"\n--- addInfo call @0x{target:x} 上下文 ---")
        start = target - 0x80
        for insn in md.disasm(code, gh_va):
            if start <= insn.address <= target + 0x10:
                mark = " <== BL addInfo" if insn.address == target else ""
                print(f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}{mark}")
