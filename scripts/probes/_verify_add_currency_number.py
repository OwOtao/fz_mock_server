# -*- coding: utf-8 -*-
"""add_currency_number 验证：发放、回读、持久化、异常入参。

覆盖：
1. 抓包样本原样重放（prestige 427 / guajiTask）
2. 连续发放累加
3. 回读：get_user_prestige、view_currency_by_type
4. 其他货币（jiaozi / molizhu）入库 + 回读
5. StateStore 落盘后重启，余额仍在
6. 异常入参：空 currency、负数、非数字、超上限
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)
import handlers  # noqa: F401,E402
from handlers.basic import _currency_balance, get_user_prestige, view_currency_by_type  # noqa: E402
from handlers.har_91 import add_currency_number  # noqa: E402
from state import StateStore  # noqa: E402

sys.stdout.reconfigure(encoding="utf-8")
FAILED = []


def check(label, condition, detail=""):
    print("  [%s] %s %s" % ("OK " if condition else "FAIL", label, detail))
    if not condition:
        FAILED.append(label)


def call(ctx, body):
    return add_currency_number(dict(ctx, body=body))


print("=== 1. 抓包样本重放 (prestige 427, addType=guajiTask) ===")
store = StateStore(autosave=False)
userid = store.ensure_account()["userid"]
ctx = {"state": store, "headers": {"userid": str(userid)}}
capture = json.load(open(os.path.join(
    ROOT, "so", "har_decrypt_99", "entries", "090_add_currency_number.json"), encoding="utf-8"))
body = json.loads(capture["request_plain"])
print("  请求体:", json.dumps(body, ensure_ascii=False))
res = call(ctx, body)
print("  响应:", json.dumps(res, ensure_ascii=False))
check("errcode=0", res["errcode"] == 0)
check("prestige.value=427", res["data"]["currency"]["prestige"]["value"] == 427)
check("prestige.count=427", res["data"]["currency"]["prestige"]["count"] == 427)
check("buff.shimenbuff1=0", res["data"]["buff"]["shimenbuff1"] == 0)

print("\n=== 2. 连续发放累加 ===")
res2 = call(ctx, {"currency": {"prestige": 100}, "addType": "guajiTask"})
check("第二次 value=100", res2["data"]["currency"]["prestige"]["value"] == 100)
check("第二次 count=527", res2["data"]["currency"]["prestige"]["count"] == 527)
check("_currency_balance=527", _currency_balance(ctx, userid, "prestige") == 527)

print("\n=== 3. 回读接口 ===")
prestige = get_user_prestige(ctx)
print("  get_user_prestige:", json.dumps(prestige["data"], ensure_ascii=False))
check("get_user_prestige.total=527", prestige["data"]["total"] == 527)
check("get_user_prestige.prestige=527", prestige["data"]["prestige"] == 527)
view = view_currency_by_type(dict(ctx, body={"currency_type": "prestige"}))
print("  view_currency_by_type(prestige):", json.dumps(view["data"], ensure_ascii=False))
check("view_currency_by_type.number=527", view["data"]["number"] == 527)

print("\n=== 4. 其他货币 jiaozi / molizhu ===")
res3 = call(ctx, {"currency": {"jiaozi": 50}, "addType": "DailyTies_riddle", "params": "weekact"})
check("jiaozi value=50", res3["data"]["currency"]["jiaozi"]["value"] == 50)
check("jiaozi count=50", res3["data"]["currency"]["jiaozi"]["count"] == 50)
res4 = call(ctx, {"currency": {"molizhu": 20}, "addType": "workmanship_replace"})
check("molizhu value=20", res4["data"]["currency"]["molizhu"]["value"] == 20)
check("jiaozi 回读=50", view_currency_by_type(dict(ctx, body={"currency_type": "jiaozi"}))["data"]["number"] == 50)
check("molizhu 回读=20", view_currency_by_type(dict(ctx, body={"currency_type": "molizhu"}))["data"]["number"] == 20)

print("\n=== 5. 落盘 + 重启 ===")
tmp = os.path.join(ROOT, ".diagnostics", "add_currency_number_state.json")
if os.path.exists(tmp):
    os.unlink(tmp)
disk_store = StateStore(tmp, autosave=True)
uid2 = disk_store.ensure_account()["userid"]
# 先放一份角色档，验证货币会同时镜像进 RoleData（客户端 getAttr 读的就是这里）
disk_store.put_archive(uid2, {"userid": uid2, "name": "测试角色", "dataVer": 1})
ctx2 = {"state": disk_store, "headers": {"userid": str(uid2)}}
call(ctx2, {"currency": {"prestige": 300, "jiaozi": 70, "molizhu": 15}, "addType": "guajiTask"})
reloaded = StateStore(tmp, autosave=False)
ctx3 = {"state": reloaded, "headers": {"userid": str(uid2)}}
check("重启后 prestige=300", _currency_balance(ctx3, uid2, "prestige") == 300)
check("重启后 jiaozi=70", _currency_balance(ctx3, uid2, "jiaozi") == 70)
check("重启后 molizhu=15", _currency_balance(ctx3, uid2, "molizhu") == 15)
check("重启后 get_user_prestige=300", get_user_prestige(ctx3)["data"]["total"] == 300)
archive = reloaded.get_archive(uid2) or {}
check("角色档镜像 prestige=300", archive.get("prestige") == 300, "archive.prestige=%s" % archive.get("prestige"))
check("角色档镜像 jiaozi=70", archive.get("jiaozi") == 70, "archive.jiaozi=%s" % archive.get("jiaozi"))
account = reloaded.get_account(uid2) or {}
check("账号 currencies 持久化", (account.get("currencies") or {}).get("prestige") == 300,
      "currencies=%s" % account.get("currencies"))
os.unlink(tmp)

print("\n=== 6. 异常入参 ===")
empty = call(ctx, {})
check("空 body -> errcode=400", empty["errcode"] == 400, empty["errmsg"])
empty2 = call(ctx, {"currency": {}})
check("空 currency -> errcode=400", empty2["errcode"] == 400)
before = _currency_balance(ctx, userid, "prestige")
neg = call(ctx, {"currency": {"prestige": -500}})
check("负数不加", _currency_balance(ctx, userid, "prestige") == before, "value=%s" % neg["data"]["currency"]["prestige"]["value"])
bad = call(ctx, {"currency": {"jiaozi": "abc"}})
check("非数字按 0 处理", bad["errcode"] == 0 and bad["data"]["currency"]["jiaozi"]["value"] == 0)
big = call(ctx, {"currency": {"molizhu": 10 ** 12}})
check("超上限被截断到 1000000", big["data"]["currency"]["molizhu"]["value"] == 1000000,
      "value=%s" % big["data"]["currency"]["molizhu"]["value"])
float_amt = call(ctx, {"currency": {"jiaozi": 50.7}})
check("浮点被取整", float_amt["data"]["currency"]["jiaozi"]["value"] == 50)

print("\n=== 结果: %s ===" % ("全部通过" if not FAILED else "失败 %d 项: %s" % (len(FAILED), FAILED)))
sys.exit(1 if FAILED else 0)
