# -*- coding: utf-8 -*-
"""One-shot extractor: familytype.lua -> handlers/familytype_data.py"""

from __future__ import print_function

import json
import os
import pprint
import re
import sys


FAMILYTYPE = os.path.join(
    os.path.dirname(__file__),
    "..",
    "lua_out",
    "assets",
    "res",
    "script",
    "others",
    "familytype.lua",
)
FAMILYLIST = os.path.join(
    os.path.dirname(__file__),
    "..",
    "lua_out",
    "assets",
    "res",
    "script",
    "others",
    "familylist.lua",
)
OUT_PY = os.path.join(os.path.dirname(__file__), "handlers", "familytype_data.py")


class LuaParser(object):
    def __init__(self, text):
        self.s = text
        self.n = len(text)
        self.i = 0

    def peek(self):
        return self.s[self.i] if self.i < self.n else ""

    def skip_ws(self):
        while self.i < self.n and self.s[self.i] in " \t\r\n":
            self.i += 1

    def parse_value(self):
        self.skip_ws()
        c = self.peek()
        if c == "{":
            return self.parse_table()
        if c == "[":
            if self.s.startswith("[[", self.i):
                return self.parse_long_string()
            raise ValueError("unexpected [ at %d" % self.i)
        if c in "\"'":
            return self.parse_quoted()
        if c == "-" or c.isdigit():
            return self.parse_number()
        # identifier / keyword
        m = re.match(r"[A-Za-z_][A-Za-z0-9_]*", self.s[self.i:])
        if m:
            tok = m.group(0)
            self.i += len(tok)
            if tok == "true":
                return True
            if tok == "false":
                return False
            if tok == "nil":
                return None
            return tok
        raise ValueError("bad value at %d %r" % (self.i, self.s[self.i:self.i + 40]))

    def parse_long_string(self):
        assert self.s.startswith("[[", self.i)
        self.i += 2
        start = self.i
        end = self.s.find("]]", self.i)
        if end < 0:
            raise ValueError("unclosed long string at %d" % start)
        val = self.s[start:end]
        self.i = end + 2
        return val

    def parse_quoted(self):
        q = self.peek()
        self.i += 1
        out = []
        while self.i < self.n:
            c = self.s[self.i]
            if c == "\\":
                self.i += 1
                if self.i >= self.n:
                    break
                esc = self.s[self.i]
                mapping = {"n": "\n", "r": "\r", "t": "\t", "\\": "\\", '"': '"', "'": "'"}
                out.append(mapping.get(esc, esc))
                self.i += 1
                continue
            if c == q:
                self.i += 1
                return "".join(out)
            out.append(c)
            self.i += 1
        raise ValueError("unclosed quote")

    def parse_number(self):
        m = re.match(r"-?\d+(\.\d+)?", self.s[self.i:])
        if not m:
            raise ValueError("bad number at %d" % self.i)
        tok = m.group(0)
        self.i += len(tok)
        if "." in tok:
            return float(tok)
        return int(tok)

    def parse_key(self):
        self.skip_ws()
        if self.peek() == "[":
            self.i += 1
            self.skip_ws()
            if self.s.startswith("[[", self.i):
                key = self.parse_long_string()
            elif self.peek() in "\"'":
                key = self.parse_quoted()
            else:
                key = self.parse_number()
            self.skip_ws()
            if self.peek() != "]":
                raise ValueError("expected ] at %d" % self.i)
            self.i += 1
            return key
        m = re.match(r"[A-Za-z_][A-Za-z0-9_]*", self.s[self.i:])
        if m:
            key = m.group(0)
            self.i += len(key)
            return key
        raise ValueError("bad key at %d %r" % (self.i, self.s[self.i:self.i + 40]))

    def parse_table(self):
        assert self.peek() == "{"
        self.i += 1
        table = {}
        array_i = 1
        while True:
            self.skip_ws()
            if self.peek() == "}":
                self.i += 1
                return table
            if self.peek() == ",":
                self.i += 1
                continue
            # keyed or array
            save = self.i
            is_keyed = False
            if self.peek() == "[":
                is_keyed = True
            else:
                m = re.match(r"[A-Za-z_][A-Za-z0-9_]*\s*=", self.s[self.i:])
                if m:
                    is_keyed = True
            if is_keyed:
                key = self.parse_key()
                self.skip_ws()
                if self.peek() != "=":
                    raise ValueError("expected = at %d" % self.i)
                self.i += 1
                val = self.parse_value()
                table[key] = val
            else:
                val = self.parse_value()
                table[array_i] = val
                array_i += 1
            self.skip_ws()
            if self.peek() == ",":
                self.i += 1
            elif self.peek() == "}":
                self.i += 1
                return table
            else:
                raise ValueError("expected , or } at %d %r" % (self.i, self.s[self.i:self.i + 40]))


def parse_lua_return(path):
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    text = text.strip()
    if text.startswith("return"):
        text = text[len("return"):].lstrip()
    parser = LuaParser(text)
    return parser.parse_value()


LINK_KEYS = ("up", "down", "left", "right", "leftUp", "rightUp", "leftDown", "rightDown")

# Fallback roomType by special room name, matching existing huxing002 mapping
# and common tsfangjian ids used by the client.
NAME_ROOM_TYPE = {
    "屋外": "tsfangjian002",
    "门前": "tsfangjian003",
    "大门": "tsfangjian004",
    "仓库": "tsfangjian005",
    "下房": "tsfangjian006",
    "客房": "tsfangjian007",
    "厨房": "tsfangjian008",
    "练功房": "tsfangjian009",
    "书房": "tsfangjian010",
    "卧室": "tsfangjian011",
    "空房": "tsfangjian012",
    "藏剑室": "tsfangjian013",
    "藏衣室": "tsfangjian014",
    "饰品室": "tsfangjian015",
    "饰品房": "tsfangjian015",
    "闭关室": "tsfangjian016",
    "调息室": "tsfangjian017",
    "炼药房": "tsfangjian018",
    "炼器房": "tsfangjian019",
    "田圃": "tsfangjian020",
    "长廊": "ptfangjian001",
    "走廊": "ptfangjian002",
    "小路": "ptfangjian003",
    "小道": "ptfangjian004",
    "回廊": "ptfangjian005",
    "偏厅": "ptfangjian006",
    "庭院": "ptfangjian011",
    "小亭": "ptfangjian012",
}


def room_fjid(room):
    return str(room.get("roomId") or room.get("id") or "")


def convert_rooms(layout):
    rooms = []
    for key, room in layout.items():
        if not isinstance(room, dict):
            continue
        fjid = room_fjid(room)
        if not fjid:
            continue
        name = str(room.get("name") or "")
        room_type = str(room.get("roomType") or "").strip()
        if not room_type:
            special = str(room.get("specialset") or "").strip()
            room_type = NAME_ROOM_TYPE.get(name) or NAME_ROOM_TYPE.get(special) or ""
        item = {
            "fjId": fjid,
            "name": name,
            "desc": name,
            "roomType": room_type,
            "mapHide": 0,
        }
        for link in LINK_KEYS:
            if room.get(link):
                item[link] = str(room[link])
        rooms.append(item)
    rooms.sort(key=lambda r: r["fjId"])
    return rooms


def room_prefix(rooms, entry):
    if entry and "_" in entry:
        return entry.rsplit("_", 1)[0] + "_"
    if rooms:
        fjid = rooms[0]["fjId"]
        if "_" in fjid:
            return fjid.rsplit("_", 1)[0] + "_"
    return ""


def main():
    data = parse_lua_return(FAMILYTYPE)
    overview = data.get("户型总览") or {}
    hx_table = {}
    for slot, info in overview.items():
        if not isinstance(info, dict):
            continue
        hx_id = str(info.get("hxId") or "")
        if not hx_id:
            continue
        layout = data.get(hx_id) or {}
        rooms = convert_rooms(layout) if isinstance(layout, dict) else []
        entry = str(info.get("entryRoom1") or "")
        hx_table[hx_id] = {
            "hxId": hx_id,
            "name": str(info.get("name") or ""),
            "entryRoom": entry,
            "BGM": str(info.get("BGM") or "bgm001"),
            "mapAppearance": str(info.get("mapAppearance") or ""),
            "mapAppearanceIndex": str(info.get("mapAppearanceIndex") or ""),
            "overviewKey": str(slot),
            "roomPrefix": room_prefix(rooms, entry),
            "rooms": rooms,
        }

    # sanity
    missing = []
    for hx_id, rec in sorted(hx_table.items()):
        if not rec["mapAppearance"] or not rec["mapAppearanceIndex"]:
            missing.append(hx_id)
        ids_in_index = re.findall(r"fb\d+_\d+", rec["mapAppearanceIndex"])
        room_ids = {r["fjId"] for r in rec["rooms"]}
        extra_index = [i for i in ids_in_index if i not in room_ids]
        extra_rooms = [i for i in sorted(room_ids) if i not in set(ids_in_index)]
        print(
            "%s name=%s rooms=%d indexIds=%d extraIndex=%s extraRooms=%s prefix=%s entry=%s bgm=%s"
            % (
                hx_id,
                rec["name"],
                len(rec["rooms"]),
                len(ids_in_index),
                extra_index[:5],
                extra_rooms[:5],
                rec["roomPrefix"],
                rec["entryRoom"],
                rec["BGM"],
            )
        )
    if missing:
        print("MISSING appearance:", missing)
        sys.exit(1)

    # compare huxing002 appearance with current hardcoded join
    expected_app = "\n".join([
        "房间—长廊—房间",
        "　　　　▏",
        "　　　长廊",
        "　　　　▏",
        "房间—长廊",
        "　　　　▏",
        "　　　大门",
        "　　　　▏",
        "　　　门前",
        "　　　　▏",
        "　　　屋外",
    ])
    got = hx_table["huxing002"]["mapAppearance"]
    print("huxing002 appearance match:", got == expected_app)
    if got != expected_app:
        print("GOT repr:", repr(got))
        print("EXP repr:", repr(expected_app))

    header = (
        "# -*- coding: utf-8 -*-\n"
        "# Auto-generated from lua_out/assets/res/script/others/familytype.lua\n"
        "# Do not edit by hand. Re-run mock_server/_extract_familytype.py to refresh.\n"
        "# mapAppearance / mapAppearanceIndex are copied verbatim from [\"户型总览\"].\n\n"
    )
    body = "HX_TABLE = " + pprint.pformat(hx_table, width=100, compact=False)
    with open(OUT_PY, "w", encoding="utf-8", newline="\n") as f:
        f.write(header)
        f.write(body)
        f.write("\n")
    print("wrote", OUT_PY, "bytes", os.path.getsize(OUT_PY), "hx", len(hx_table))


if __name__ == "__main__":
    main()
