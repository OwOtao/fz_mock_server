# -*- coding: utf-8 -*-
"""Read rodata strings at addresses referenced in JM::test()."""
from elftools.elf.elffile import ELFFile

from _paths import SO_PATH

# Addresses referenced in JM::test()
ADDRS = [
    (0x1183b20, "test ciphertext / first string"),
    (0x1183bf0, "group name (param1 to addInfo)"),
    (0x1183bf8, "key part 1 (param2 to addInfo #1)"),
    (0x1183c20, "key part 2 (param2 to addInfo #2)"),
    (0x120d3f0, "IV (param3 to addInfo)"),
]

with open(SO_PATH, 'rb') as f:
    for addr, desc in ADDRS:
        f.seek(addr)
        # Read up to 128 bytes
        data = f.read(128)
        # Find null terminator
        null_idx = data.find(b'\x00')
        if null_idx >= 0:
            s = data[:null_idx]
        else:
            s = data
        print(f"0x{addr:x} ({desc}):")
        print(f"  raw bytes: {data[:64].hex()}")
        print(f"  string:    {s.decode('utf-8', errors='replace')}")
        print(f"  len:       {len(s)}")
        # Also show what's after the null terminator
        if null_idx >= 0 and null_idx < 64:
            next_data = data[null_idx+1:null_idx+65]
            next_null = next_data.find(b'\x00')
            if next_null >= 0:
                next_s = next_data[:next_null]
                print(f"  next string at +{null_idx+1}: {next_s.decode('utf-8', errors='replace')}")
        print()
