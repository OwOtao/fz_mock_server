# -*- coding: utf-8 -*-
import json

d = json.load(open("data/har_analysis/0013_api_v5_get_rank_list_4.json", encoding="utf-8"))
for b in d["data"]:
    print("title=%s type=%s board_type=%s page=%s nums=%s total_nums=%s total_page=%s header=%s body_keys=%s" % (
        b.get("title"), b.get("type"), b.get("board_type"), b.get("page"),
        b.get("nums"), b.get("total_nums"), b.get("total_page"),
        b.get("header"), sorted((b.get("body") or {}).keys())))
