# -*- coding: utf-8 -*-
"""Read global strings used by isUseXXTEA to check if FZJH03 uses XXTEA."""
from elftools.elf.elffile import ELFFile

from _paths import SO_PATH

# isUseXXTEA compares group name with strings at these global addresses
# The globals are at 0x15e62c8, 0x15e62d0, 0x15e62d8
# These are POINTERS to std::string objects, so we need to read the pointer first,
# then read the string data.

with open(SO_PATH, 'rb') as f:
    elf = ELFFile(f)

    # Find the section containing 0x15e62c8
    # These are in .data or .bss section
    for seg in elf.iter_segments():
        if seg['p_type'] == 'PT_LOAD':
            va_start = seg['p_vaddr']
            va_end = va_start + seg['p_filesz']
            if va_start <= 0x15e62c8 < va_end:
                offset = 0x15e62c8 - va_start + seg['p_offset']
                print(f"0x15e62c8 is in segment at va=0x{va_start:x}, file offset=0x{seg['p_offset']:x}")
                print(f"  Calculated file offset: 0x{offset:x}")
                print(f"  Segment flags: {seg['p_flags']}")

    # Read the pointers at 0x15e62c8, 0x15e62d0, 0x15e62d8
    # In the .data section, these contain pointers to std::string data
    # But since this is a loaded library, the addresses might be relocated

    # Let's try reading from the file at the calculated offset
    # First, let's find all PT_LOAD segments
    print("\n=== PT_LOAD segments ===")
    for seg in elf.iter_segments():
        if seg['p_type'] == 'PT_LOAD':
            print(f"  va=0x{seg['p_vaddr']:x} - 0x{seg['p_vaddr']+seg['p_memsz']:x} "
                  f"file_off=0x{seg['p_offset']:x} filesz=0x{seg['p_filesz']:x} "
                  f"flags={seg['p_flags']}")

    # Read pointers
    print("\n=== Reading global pointers ===")
    for addr in [0x15e62c8, 0x15e62d0, 0x15e62d8]:
        # Find the segment containing this address
        for seg in elf.iter_segments():
            if seg['p_type'] == 'PT_LOAD':
                va = seg['p_vaddr']
                if va <= addr < va + seg['p_filesz']:
                    file_offset = addr - va + seg['p_offset']
                    f.seek(file_offset)
                    ptr_bytes = f.read(8)
                    ptr = int.from_bytes(ptr_bytes, 'little')
                    print(f"\n  0x{addr:x} (file offset 0x{file_offset:x}):")
                    print(f"    pointer value: 0x{ptr:x}")

                    # The pointer points to std::string data
                    # In old std::string, the _Rep header is at data - 0x18
                    # and the actual chars start at data
                    if ptr != 0:
                        # Try to read the string data
                        # The pointer might be a virtual address that needs to be converted
                        for seg2 in elf.iter_segments():
                            if seg2['p_type'] == 'PT_LOAD':
                                va2 = seg2['p_vaddr']
                                if va2 <= ptr < va2 + seg2['p_filesz']:
                                    str_offset = ptr - va2 + seg2['p_offset']
                                    f.seek(str_offset)
                                    str_data = f.read(64)
                                    null_idx = str_data.find(b'\x00')
                                    if null_idx >= 0:
                                        s = str_data[:null_idx].decode('utf-8', errors='replace')
                                    else:
                                        s = str_data[:32].decode('utf-8', errors='replace')
                                    print(f"    string at 0x{ptr:x}: '{s}'")
                                    print(f"    raw: {str_data[:32].hex()}")
                                    break
                    break

    # Also read the structure at 0x15e62c8 more carefully
    # It might be an array of std::string objects (each 8 bytes = pointer)
    print("\n=== Reading 0x15e62c8 area (48 bytes) ===")
    for seg in elf.iter_segments():
        if seg['p_type'] == 'PT_LOAD':
            va = seg['p_vaddr']
            if va <= 0x15e62c8 < va + seg['p_filesz']:
                file_offset = 0x15e62c8 - va + seg['p_offset']
                f.seek(file_offset)
                data = f.read(48)
                print(f"  raw hex: {data.hex()}")
                for i in range(0, 48, 8):
                    ptr = int.from_bytes(data[i:i+8], 'little')
                    print(f"    +{i}: 0x{ptr:x}")
                break
