# -*- coding: utf-8 -*-
"""cundangwei(存档位) 商品缺口验证。

覆盖：
1. get_goods_2/cundangwei 返回抓包同款字段
2. get_goods/cundangwei（客户端 getGoodsInfo 走 GET）同样可用
3. buy_goods_3/cundangwei 按 300 元宝计价（不再走价格 1 的兜底）
4. 商城列表 get_store_list_4 不受影响（cundangwei 不应出现在列表里）
5. 抓包响应字段逐项比对
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, ROOT)
import handlers  # noqa: F401,E402
from handlers.basic import (  # noqa: E402
    _currency_balance,
    buy_goods,
    get_goods,
    get_goods_2,
    get_store_list,
    _find_store_item,
)
from state import StateStore  # noqa: E402

sys.stdout.reconfigure(encoding="utf-8")
FAILED = []


def check(label, condition, detail=""):
    print("  [%s] %s %s" % ("OK " if condition else "FAIL", label, detail))
    if not condition:
        FAILED.append(label)


store = StateStore(autosave=False)
userid = store.ensure_account()["userid"]
ctx = {"state": store, "headers": {"userid": str(userid)}}

print("=== 1. get_goods_2/cundangwei ===")
res = get_goods_2(dict(ctx, route_tail=["cundangwei"], body={}))
print("  ", json.dumps(res, ensure_ascii=False))
check("errcode=0", res["errcode"] == 0)
data = res["data"]
check("name=存档位", data["name"] == "存档位")
check("price=300", data["price"] == 300)
check("itemId=cundangwei", data["itemId"] == "cundangwei")
check("itype=1", data["itype"] == 1)
check("number=1", data["number"] == 1)

print("\n=== 2. 抓包字段比对 ===")
capture = json.load(open(os.path.join(
    ROOT, "so", "har_decrypt_99", "entries", "076_cundangwei.json"), encoding="utf-8"))
captured = json.loads(capture["response_plain"])["data"]
for key, want in captured.items():
    got = data.get(key)
    if key in ("id", "to", "from"):
        # mock 统一把 id/to/from 序列化成字符串（与既有 _STORE_TEST_ITEMS 一致）
        check("字段 %s=%r(字符串形式)" % (key, want), str(got) == str(want), "got=%r" % got)
    else:
        check("字段 %s=%r" % (key, want), got == want, "got=%r" % got)

print("\n=== 3. get_goods/cundangwei（GET 变体）===")
res_get = get_goods(dict(ctx, route_tail=["cundangwei"]))
check("errcode=0", res_get["errcode"] == 0, json.dumps(res_get, ensure_ascii=False))
check("price=300", res_get["data"]["price"] == 300)

print("\n=== 4. buy_goods_3/cundangwei 按 300 计价 ===")
before = _currency_balance(ctx, userid, "yuanbao")
buy = buy_goods(dict(ctx, route_tail=["cundangwei"], body={
    "client_trans_id": "cundang-test-1",
    "id": data["id"],
    "itemId": "cundangwei",
    "quantity": 1,
}))
print("  ", json.dumps(buy, ensure_ascii=False))
check("errcode=0", buy["errcode"] == 0)
check("remove_yuanbao=300", buy["data"]["remove_yuanbao"] == 300,
      "remove=%s" % buy["data"]["remove_yuanbao"])
check("元宝余额减少 300", _currency_balance(ctx, userid, "yuanbao") == before - 300)

print("\n=== 5. 商城列表不受影响 ===")
listed = get_store_list(ctx)
items = listed["data"]["list"][1]["items"]
check("cundangwei 不在商城列表", all(i.get("itemId") != "cundangwei" for i in items),
      "商城商品数=%d" % len(items))
check("_find_store_item 命中", _find_store_item("cundangwei") is not None)

print("\n=== 结果: %s ===" % ("全部通过" if not FAILED else "失败 %d 项: %s" % (len(FAILED), FAILED)))
sys.exit(1 if FAILED else 0)
