# -*- coding: utf-8 -*-
"""Read full ciphertext string from rodata and verify."""
from elftools.elf.elffile import ELFFile

from _paths import SO_PATH

with open(SO_PATH, 'rb') as f:
    # Read 256 bytes at 0x1183b20 to get the full ciphertext string
    f.seek(0x1183b20)
    data = f.read(256)
    null_idx = data.find(b'\x00')
    if null_idx >= 0:
        s = data[:null_idx].decode('utf-8', errors='replace')
    else:
        s = data.decode('utf-8', errors='replace')
    print(f"Full ciphertext string at 0x1183b20:")
    print(f"  length: {len(s)} chars")
    print(f"  string: {s}")
    print(f"  hex decoded length: {len(s)//2} bytes")
    
    # Also check what's at 0x1183bf0 (group name)
    f.seek(0x1183bf0)
    data = f.read(64)
    null_idx = data.find(b'\x00')
    print(f"\nGroup name at 0x1183bf0: {data[:null_idx].decode()}")
    
    # Check for AES_set_decrypt_key and AES_cbc_encrypt in dynsym
    print("\n=== Searching for AES functions in dynsym ===")
    f.seek(0)
    elf = ELFFile(f)
    for section in elf.iter_sections():
        if not hasattr(section, 'iter_symbols'):
            continue
        for sym in section.iter_symbols():
            name = sym.name
            if 'AES' in name or 'aes' in name.lower():
                print(f"  {name}: addr=0x{sym['st_value']:x} size={sym['st_size']} type={sym['st_info']['type']}")
