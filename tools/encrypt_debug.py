"""Encrypt DebugLayer files into debug, preserving relative paths.

Usage (from the workspace root):
    python mock_server/encrypt_debug.py
    python mock_server/encrypt_debug.py --format JHHU01

Existing output files are overwritten; unrelated output files are not deleted.
"""


# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__)))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import argparse
import binascii
from pathlib import Path

import config
import jm_crypto

ROOT = Path(__file__).resolve().parent.parent


def encrypt_content(data, format_name="JHHU02"):
    if format_name == "JHHU02":
        return jm_crypto.encrypt(data, "default").encode("ascii")
    if format_name == "JHHU01":
        encrypted = jm_crypto._aes_cbc(
            jm_crypto._pad(data),
            config.UPDATE_JHHU01_KEY,
            config.UPDATE_JHHU01_IV,
            "enc",
        )
        return binascii.hexlify(config.UPDATE_JHHU01_MAGIC + encrypted)
    raise ValueError("Unsupported format: %s" % format_name)


def encrypt_directory(source, output, format_name="JHHU02"):
    source = Path(source).resolve()
    output = Path(output).resolve()
    if not source.is_dir():
        raise ValueError("Source directory does not exist: %s" % source)
    if source == output or source in output.parents or output in source.parents:
        raise ValueError("Source and output must be separate, non-nested directories")
    if format_name not in ("JHHU02", "JHHU01"):
        raise ValueError("Unsupported format: %s" % format_name)

    # Snapshot paths before writing. Reject links to avoid leaving either tree.
    entries = sorted(source.rglob("*"))
    for entry in entries:
        if entry.is_symlink() or not entry.resolve().is_relative_to(source):
            raise ValueError("Source links are not supported: %s" % entry)
        target = output / entry.relative_to(source)
        if not target.resolve().is_relative_to(output):
            raise ValueError("Output path escapes output directory: %s" % target)

    output.mkdir(parents=True, exist_ok=True)
    count = 0
    for entry in entries:
        target = output / entry.relative_to(source)
        if entry.is_dir():
            target.mkdir(parents=True, exist_ok=True)
        elif entry.is_file():
            encrypted = encrypt_content(entry.read_bytes(), format_name)
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(encrypted)
            count += 1
    return count


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=ROOT / "DebugLayer")
    parser.add_argument("--output", type=Path, default=ROOT / "debug")
    parser.add_argument("--format", choices=("JHHU02", "JHHU01"), default="JHHU02")
    args = parser.parse_args()
    try:
        count = encrypt_directory(args.source, args.output, args.format)
    except (OSError, ValueError, RuntimeError) as exc:
        parser.exit(1, "Error: %s\n" % exc)
    print("Encrypted %d files [%s]" % (count, args.format))
    print("Source: %s" % args.source.resolve())
    print("Output: %s" % args.output.resolve())


if __name__ == "__main__":
    main()
