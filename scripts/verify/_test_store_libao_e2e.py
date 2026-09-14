# -*- coding: utf-8 -*-
"""端到端验证: 商城页签礼包内容与 so/entries 抓包数据一致。

1. get_store_list_4 的 xianshi_goods(限时)页签与抓包 104_get_store_list_4.json 一致。
2. 每个抓包到的礼包 get_limit_package/libaoXXXX 响应与抓包一致(end_time 顺延除外)。
"""


# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import glob
import json
import sys
import time

import config
config.HOST = "127.0.0.1"  # 0.0.0.0 在 Windows 上不能作为连接目标

from test_client import req  # noqa: E402


def _load_capture(index_name):
    path = r"so\entries\%s.json" % index_name
    with open(path, encoding="utf-8") as f:
        return json.loads(json.load(f)["response_plain"])["data"]


def main():
    now = int(time.time())

    print("== 1. get_store_list_4 限时页签 vs 抓包 ==")
    captured_list = _load_capture("104_get_store_list_4")["list"]
    captured_xianshi = next(c for c in captured_list if c["classId"] == "xianshi_goods")
    payload = req("get_store_list_4", None, force_method="GET",
                  headers={"userid": "1000000002"})
    live_xianshi = next(c for c in payload["data"]["list"] if c["classId"] == "xianshi_goods")
    # mock 在抓包的 16 个礼包后额外附加新手礼包(xinshoulibao1)
    live_items = live_xianshi["items"]
    assert len(live_items) == len(captured_xianshi["items"]) + 1, \
        (len(live_items), len(captured_xianshi["items"]))
    assert live_items[-1]["itemId"] == "xinshoulibao1"
    for live, captured in zip(live_items, captured_xianshi["items"]):
        assert live["itemId"] == captured["itemId"], (live, captured)
        assert live["id"] == captured["id"], (live, captured)
        assert live["name"] == captured["name"], (live, captured)
        assert live["price"] == captured["price"], (live, captured)
    print("  限时页签 %d 个礼包(含新手礼包), id/itemId/name/price 与抓包一致"
          % len(live_items))

    print("== 2. get_limit_package 明细 vs 抓包 ==")
    checked = 0
    for path in sorted(glob.glob(r"so\entries\*_libao*.json")):
        with open(path, encoding="utf-8") as f:
            entry = json.load(f)
        key = entry["url"].split("/api/v5/get_limit_package/")[1]
        captured = json.loads(entry["response_plain"])["data"]
        payload = req("get_limit_package/" + key, None, force_method="GET",
                      headers={"userid": "1000000002"})
        live = payload["data"]
        for field in ("id", "total_price", "price", "limit_num", "beyond",
                      "begin_time", "list", "special_reward_itemId", "buy_times"):
            if field == "buy_times":
                continue  # mock 不跟踪购买次数
            assert live.get(field) == captured.get(field), (key, field, live.get(field), captured.get(field))
        assert live["end_time"] > now, (key, live["end_time"])
        checked += 1
        print("  %s ok: price=%s items=%s" %
              (key, live["price"], [(i["itemId"], i["number"]) for i in live["list"]]))

    # 未收录礼包 -> 404
    missing = req("get_limit_package/libao9999", None, force_method="GET",
                  headers={"userid": "1000000002"}, expect_errcode=404)
    print("  unknown package rejected:", missing["errmsg"])

    print("ALL OK (%d packages verified)" % checked)


if __name__ == "__main__":
    sys.exit(main())
