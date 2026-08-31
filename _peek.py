# -*- coding: utf-8 -*-
import json
import sys

for path in sys.argv[1:]:
    d = json.load(open(path, encoding="utf-8"))
    data = d.get("data")
    print("=" * 10, path.split("\\")[-1] if "\\" in path else path.split("/")[-1])
    if isinstance(data, dict):
        print("dict keys:", sorted(data.keys()))
    elif isinstance(data, list):
        print("list len:", len(data))
        if data and isinstance(data[0], dict):
            print("item0 keys:", sorted(data[0].keys()))
            print("item0 sample:", {k: data[0].get(k) for k in list(data[0].keys())[:6]})
    else:
        print(type(data), str(data)[:100])
