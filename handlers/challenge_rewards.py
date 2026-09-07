# -*- coding: utf-8 -*-
"""Server-owned challenge reward rolls from the bundled client tables."""
from functools import lru_cache
import json
from pathlib import Path
import random
import re

from lua_to_json import parse_lua_file


@lru_cache(maxsize=1)
def reward_configs():
    root = Path(__file__).resolve().parents[1] / "fzjh_lua/assets/res/script"
    return (parse_lua_file(root / "rewardScheme.lua")["rewardScheme"],
            parse_lua_file(root / "map/mapItemAttr/Rewards.lua"))


def rule_parts(rule):
    """Parse only nested identifier lists, never execute Lua or client code."""
    parts = str(rule).replace(" ", "").split(";")
    if len(parts) not in (1, 2):
        raise ValueError("invalid reward rule")

    def parse(value):
        if not re.fullmatch(r"[A-Za-z0-9_{},.-]+", value):
            raise ValueError("unsupported reward rule")
        encoded = re.sub(r"[^{} ,]+", lambda m: json.dumps(m[0]), value)
        result = json.loads(encoded.replace("{", "[").replace("}", "]"))
        return result if isinstance(result, list) else [result]

    choices = parse(parts[0])
    weights = [float(v) for v in parse(parts[1])] if len(parts) == 2 else [1] * len(choices)
    if not choices or len(weights) != len(choices) or any(w < 0 for w in weights) or sum(weights) <= 0:
        raise ValueError("invalid reward weights")
    return choices, weights


def roll_rewards(scheme_id, resources, rng=None):
    schemes, rewards = reward_configs()
    rng = rng or random.SystemRandom()
    output = []

    def reward(reward_id):
        if reward_id == "-1":
            return
        spec = rewards[reward_id]
        kind = {"物品": 1, "属性": 2, "称号": 4}[spec["rwType"]]
        # All 210 leaves reachable from current challenge configs are fixed.
        if spec.get("calcType") != "固定类" or type(spec["rwNumber"]) is not int or spec["rwNumber"] <= 0:
            raise ValueError("unsupported challenge reward calculation")
        output.append({"type": kind, "id": str(spec["rwName"]), "num": spec["rwNumber"]})

    def walk(scheme, parents=()):
        if scheme == "-1":
            return
        if scheme in parents or len(parents) >= 64:
            raise ValueError("cyclic reward scheme")
        spec = schemes[scheme]
        choices, weights = rule_parts(spec["rule"])
        selected = rng.choices(choices, weights=weights, k=1)[0]
        selected = selected if isinstance(selected, list) else [selected]
        for value in selected:
            if spec["type"] == "策略":
                walk(value, parents + (scheme,))
            elif spec["type"] == "奖励":
                reward(value)
            else:
                raise ValueError("unsupported reward scheme type")

    if scheme_id:
        walk(scheme_id)
    for item_id, amount in resources or []:
        if type(amount) is not int or amount <= 0:
            raise ValueError("invalid server resource reward")
        output.append({"type": 3, "id": str(item_id), "num": amount})
    return output


def grant_rewards(state, uid, account, archive, rewards, delivery):
    """Apply a pre-rolled settlement once; caller owns locking and receipt."""
    from handlers.basic import _CURRENCY_LIMITS

    items = archive.get("items") or []
    if not isinstance(items, list):
        raise ValueError("invalid role inventory")
    archive["items"] = items
    currencies = account.setdefault("currencies", {})
    mail_items, actual, messages = [], [], []
    for source in rewards:
        value = dict(source)
        kind, item_id, amount = value["type"], value["id"], value["num"]
        if kind == 1 and delivery == 2:
            mail_items.append({"id": item_id, "num": amount, "state": 0})
        elif kind == 1:
            found = next((i for i in items if isinstance(i, dict) and i.get("itemId") == item_id), None)
            if found is None:
                next_id = max([int(i.get("id") or 0) for i in items if isinstance(i, dict)] or [0]) + 1
                items.append({"id": next_id, "itemId": item_id, "count": amount})
            else:
                found["count"] = int(found.get("count") or 0) + amount
        elif kind == 2:
            archive[item_id] = (archive.get(item_id) or 0) + amount
        elif kind == 3:
            previous = max(int(currencies.get(item_id) or 0), int(archive.get(item_id) or 0), 0)
            limit = _CURRENCY_LIMITS.get(item_id)
            if limit is not None:
                amount = min(amount, max(0, limit - previous))
                if amount < value["num"]:
                    messages.append(item_id + "已达到上限")
            value["num"] = amount
            currencies[item_id] = archive[item_id] = previous + amount
        elif kind == 4:
            titles = archive.setdefault("basicTitleData", {}).setdefault("titleList", [])
            if item_id not in titles:
                titles.append(item_id)
        if value["num"] > 0:
            actual.append(value)
    version = max(int(account.get("currency_version") or 0), int(archive.get("currencyVersion") or 0)) + 1
    archive["currencyVersion"] = account["currency_version"] = version
    state.put_archive(uid, archive)
    mail_id = None
    if mail_items:
        mail_id = state.add_mail(uid, {"title": "挑战副本奖励", "content": "背包不足，副本物品奖励已通过邮驿发放。",
                                       "rewards": {"loc_items": mail_items}})["mail_id"]
        messages.append("物品奖励已发送至江湖邮驿")
    return {"award_list": actual, "currencyVersion": version, "msg": "；".join(messages), "mail_id": mail_id}
