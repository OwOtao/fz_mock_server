# -*- coding: utf-8 -*-
import json

d = json.load(open("data/har_analysis/0013_api_v5_get_rank_list_4.json", encoding="utf-8"))
for b in d["data"]:
    item = (b.get("body", {}).get("list") or [{}])[0]
    print("== %s (%s)" % (b.get("title"), b.get("type")))
    print("   keys:", sorted(item.keys()))
    print("   mine keys:", sorted((b.get("body", {}).get("mine") or {}).keys()))
