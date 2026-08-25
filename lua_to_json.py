# -*- coding: utf-8 -*-
from __future__ import print_function

import argparse
import json
import os
import re
import sys


ROOT = os.path.dirname(os.path.abspath(__file__))
DEFAULT_OUT_DIR = os.path.join(ROOT, "item_json")
DEFAULT_SOURCES = [
    os.path.join(ROOT, "fzjh_lua", "assets", "res", "script", "store", "shoplist.lua"),
    os.path.join(ROOT, "fzjh_lua", "assets", "res", "script", "map", "mapItemAttr", "homeland.lua"),
    os.path.join(ROOT, "fzjh_lua", "assets", "res", "script", "map", "mapItemAttr", "Rewards.lua"),
]


class LuaParser(object):
    def __init__(self, text):
        self.s = text
        self.n = len(text)
        self.i = 0

    def peek(self):
        return self.s[self.i] if self.i < self.n else ""

    def skip(self):
        while self.i < self.n:
            c = self.s[self.i]
            if c.isspace():
                self.i += 1
                continue
            if self.s.startswith("--[[", self.i):
                end = self.s.find("]]", self.i + 4)
                self.i = self.n if end < 0 else end + 2
                continue
            if self.s.startswith("--", self.i):
                end = self.s.find("\n", self.i + 2)
                self.i = self.n if end < 0 else end + 1
                continue
            break

    def parse_identifier(self):
        m = re.match(r"[A-Za-z_][A-Za-z0-9_]*", self.s[self.i :])
        if not m:
            raise ValueError("invalid identifier at %d" % self.i)
        tok = m.group(0)
        self.i += len(tok)
        return tok

    def parse_quoted(self):
        quote = self.peek()
        self.i += 1
        out = []
        mapping = {
            "a": "\a",
            "b": "\b",
            "f": "\f",
            "n": "\n",
            "r": "\r",
            "t": "\t",
            "v": "\v",
            "\\": "\\",
            '"': '"',
            "'": "'",
        }
        while self.i < self.n:
            c = self.s[self.i]
            self.i += 1
            if c == quote:
                return "".join(out)
            if c != "\\":
                out.append(c)
                continue
            if self.i >= self.n:
                break
            esc = self.s[self.i]
            self.i += 1
            if esc == "z":
                while self.i < self.n and self.s[self.i].isspace():
                    self.i += 1
            elif esc == "x":
                out.append(chr(int(self.s[self.i : self.i + 2], 16)))
                self.i += 2
            elif esc.isdigit():
                digits = esc
                while self.i < self.n and len(digits) < 3 and self.s[self.i].isdigit():
                    digits += self.s[self.i]
                    self.i += 1
                out.append(chr(int(digits)))
            elif esc in "\r\n":
                if esc == "\r" and self.peek() == "\n":
                    self.i += 1
                out.append("\n")
            else:
                out.append(mapping.get(esc, esc))
        raise ValueError("unclosed string at %d" % self.i)

    def parse_long_string(self):
        m = re.match(r"\[(=*)\[", self.s[self.i :])
        if not m:
            raise ValueError("invalid long string at %d" % self.i)
        eq = m.group(1)
        self.i += len(m.group(0))
        end = "]" + eq + "]"
        pos = self.s.find(end, self.i)
        if pos < 0:
            raise ValueError("unclosed long string at %d" % self.i)
        value = self.s[self.i : pos]
        self.i = pos + len(end)
        if value.startswith("\r\n"):
            value = value[2:]
        elif value.startswith("\r") or value.startswith("\n"):
            value = value[1:]
        return value

    def parse_number(self):
        m = re.match(
            r"[+-]?(?:0[xX][0-9a-fA-F]+|(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)",
            self.s[self.i :],
        )
        if not m:
            raise ValueError("invalid number at %d" % self.i)
        raw = m.group(0)
        self.i += len(raw)
        if "x" in raw.lower():
            return int(raw, 16)
        value = float(raw)
        return int(value) if value.is_integer() else value

    def parse_table(self):
        assert self.peek() == "{"
        self.i += 1
        obj = {}
        arr = []
        while True:
            self.skip()
            if self.i >= self.n:
                raise ValueError("unclosed table")
            if self.peek() == "}":
                self.i += 1
                if obj and arr:
                    for index, value in enumerate(arr, 1):
                        obj[str(index)] = value
                    return obj
                return obj if obj else arr
            if self.peek() == "[" and not re.match(r"\[(=*)\[", self.s[self.i :]):
                self.i += 1
                key = self.parse_value()
                self.skip()
                if self.peek() != "]":
                    raise ValueError("expected ] at %d" % self.i)
                self.i += 1
                self.skip()
                if self.peek() != "=":
                    raise ValueError("expected = at %d" % self.i)
                self.i += 1
                obj[str(key)] = self.parse_value()
            else:
                save = self.i
                if self.peek().isalpha() or self.peek() == "_":
                    name = self.parse_identifier()
                    self.skip()
                    if self.peek() == "=":
                        self.i += 1
                        obj[name] = self.parse_value()
                    else:
                        self.i = save
                        arr.append(self.parse_value())
                else:
                    arr.append(self.parse_value())
            self.skip()
            if self.peek() in ",;":
                self.i += 1

    def parse_value(self):
        self.skip()
        c = self.peek()
        if not c:
            raise ValueError("unexpected end of file")
        if c in "\"'":
            return self.parse_quoted()
        if c == "[":
            return self.parse_long_string()
        if c == "{":
            return self.parse_table()
        if c.isdigit() or c in "+-.":
            return self.parse_number()
        if c.isalpha() or c == "_":
            name = self.parse_identifier()
            return {"true": True, "false": False, "nil": None}.get(name, name)
        raise ValueError("cannot parse at %d: %r" % (self.i, self.s[self.i : self.i + 40]))


def parse_lua_file(path):
    with open(path, "r", encoding="utf-8-sig") as f:
        text = f.read()
    parser = LuaParser(text)
    parser.skip()
    if parser.s.startswith("return", parser.i):
        parser.i += 6
    data = parser.parse_value()
    parser.skip()
    leftover = parser.s[parser.i :].strip("0\ufeff \t\r\n")
    if leftover:
        raise ValueError("unparsed content in %s at %d: %r" % (path, parser.i, leftover[:50]))
    return data


def count_entries(data):
    if isinstance(data, dict) and isinstance(data.get("Sheet1"), dict):
        return len(data["Sheet1"])
    if isinstance(data, dict):
        return len(data)
    if isinstance(data, list):
        return len(data)
    return 1


def convert_file(src, out_dir):
    data = parse_lua_file(src)
    os.makedirs(out_dir, exist_ok=True)
    dst = os.path.join(out_dir, os.path.splitext(os.path.basename(src))[0] + ".json")
    with open(dst, "w", encoding="utf-8", newline="\n") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")
    return dst, count_entries(data), os.path.getsize(dst)


def main(argv=None):
    parser = argparse.ArgumentParser(description="Convert Lua tables to readable JSON.")
    parser.add_argument("files", nargs="*", help="Lua files to convert. Defaults to shoplist/homeland/Rewards.")
    parser.add_argument(
        "-o",
        "--out",
        default=DEFAULT_OUT_DIR,
        help="Output directory (default: mock_server/item_json)",
    )
    args = parser.parse_args(argv)
    sources = args.files or DEFAULT_SOURCES
    out_dir = os.path.abspath(args.out)
    failed = 0
    for src in sources:
        src_path = os.path.abspath(src)
        try:
            dst, count, size = convert_file(src_path, out_dir)
        except Exception as exc:
            failed += 1
            print("FAIL %s: %s" % (src_path, exc), file=sys.stderr)
            continue
        print("OK %s -> %s (%s entries, %s bytes)" % (src_path, dst, count, size))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
