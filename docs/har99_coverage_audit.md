# ProxyPin9-9_09_12_12.har 接口实现审查

- 审查对象：`so/ProxyPin9-9_09_12_12.har`（234 条目，2.1.02 客户端）
- 解密产物：`so/har_decrypt_99/`（entries 134 个 + decrypted.har + summary.md）
- 审查范围：排除第三方 SDK
- 工具：`scripts/har/_har_tool.py`（decrypt / audit）、`scripts/audits/_audit_har_diff.py`（两次抓包对比）

## 结论

**抓包接口与商品数据已全部实现。** `add_currency_number` 与 `get_goods_2/cundangwei` 均已补齐。

| 分类 | 数量 |
| --- | --- |
| HAR 条目总数 | 234 |
| 游戏后端（`android.fzjh...`） | 130 |
| 更新服务器（`update.xiaohoutiaotiao.com`） | 4 |
| 第三方 SDK（穿山甲 / apmplus / douyin / umeng 等） | 100 |
| 去重后游戏接口路径 | 52 |
| 精确命中已注册路由 | 41 |
| 前缀命中（带路径参数） | 10 |
| **未实现路由** | **0** |
| 数据缺口 | **0**（`cundangwei` 已补） |

## 已实现接口

### `POST /api/v5/add_currency_number`

实现位置：`handlers/har_91.py`。抓包样本 `entries/090_add_currency_number.json`：

```json
// 请求
{"currency": {"prestige": 427}, "params": 1378999.9158137, "addType": "guajiTask"}
// 响应
{"errcode": 0, "data": {
  "currency": {"prestige": {"value": 427, "count": 427, "desc": ""}},
  "buff": {"shimenbuff1": 0}
}}
```

客户端调用点（`HttpManager:addCurrencyNumber`，`fzjh_lua/.../HttpManager.lua:3048`）：

| 调用点 | addType | 货币 |
| --- | --- | --- |
| `TeacherGuaJiTaskUtil.lua:1214` | `guajiTask` | prestige |
| `FestivalLanternRiddleRewardModel.lua:193` | `DailyTies_riddle` | jiaozi |
| `FestivalModule.lua:666 / 2415 / 2777 / 2864` | `DailyTies_*` | jiaozi |
| `ChongGuangDuiHuanLayer.lua:322` | `DailyTies_weekxzzy` | jiaozi |
| `JiangHuGuaiKeModel.lua:65` | `DailyTies_dmxb_<lv>` | jiaozi |
| `CommonResults.lua:3569 / 3612` | 墨璃珠奖励 / 手艺人补领 | molizhu |
| `TaskModule.lua:959` | 任务奖励 | — |

服务端行为：

- 逐项累加 `body.currency`，返回 `value`（本次增加量）、`count`（增加后总量）、`desc`；
- `prestige` 走 `basic._prestige_bucket`（与 `get_user_prestige` 同一份数据），其余货币走 `basic._set_currency_balance`（账号 `currencies` + 角色档镜像），随 `StateStore` 落盘；
- 负数/非数字按 0 处理，单次上限 1000000，空 `currency` 返回 `errcode 400`；
- `buff.shimenbuff1` 固定 0（掌门令加成暂无服务端来源，客户端 `> 0` 时不弹提示）。

配套修改：`basic._prestige_bucket` 初始化时改为取「账号 currencies 的 prestige」与「角色档 prestige/shengwang/familyPrestige」的较大值。原实现只看角色档，重启后客户端再上传一份不含 `prestige` 的 RoleData 会把服务端发放的声望清零；账号 `currencies` 不受客户端上传覆盖，因此用它兜底。

验证（`_verify_add_currency_number.py`，6 组用例全部通过）：

| 用例 | 结果 |
| --- | --- |
| 抓包样本重放（prestige 427 / guajiTask） | `value=427 count=427`，与抓包响应一致 |
| 连续发放累加 | 第二次 `value=100 count=527` |
| 回读 `get_user_prestige` | `total=527`（与发放值一致） |
| 回读 `view_currency_by_type` | `number=527` / jiaozi 50 / molizhu 20 |
| 落盘重启 + 角色档镜像 | 重启后三种货币余额不变，RoleData 内 `prestige/jiaozi` 同步 |
| 重启 + 客户端上传旧档 | 声望保持 888，不被清零 |
| 异常入参 | 空 body/空 currency → 400；负数不加；非数字按 0；超限截断；浮点取整 |

## 商品数据补齐：`get_goods_2/cundangwei`

抓包 `entries/076_cundangwei.json`、`077_cundangwei.json`：

```json
// 响应
{"errcode": 0, "data": {"id": 7, "itemId": "cundangwei", "itype": 1, "inde": 3,
  "name": "存档位", "price": 300, "number": 1, "dsc1": "", "dsc2": "",
  "share": "", "icon": "", "to": 0, "from": 0}}
```

`cundangwei`（存档位）不在 `_STORE_TEST_ITEMS / _STORE_LEVEL_ITEMS / _STORE_LIMITED_ITEMS`，也不在 `Items.json` 与客户端商店配置里，原先 `_find_store_item` 找不到 → 接口返回 `errcode=404 goods not found`，客户端 `ArchiveLayer:buyOneArchiveItem -> PopYuanBaoBuyItemLayer("cundangwei") -> YuanBaoPayLayer.buyStoreItem -> getGoodsInfo` 弹"获得商品数据出错.."，购买额外存档位不可用。

修复：

- 新增 `_VIRTUAL_STORE_ITEMS` 表（存放"不在任何商店列表、但客户端会单独查询"的商品），`cundangwei` 按抓包数据录入；
- `_find_store_item` 在原有三张商店表之后追加查这张表，因此 **`get_store_list_4` 的商城列表不受影响**；
- `_goods_detail` 补上抓包中存在的 `inde` / `to` / `from` 三个字段（`to`/`from` 与既有商品一致按字符串下发）。

验证（`_verify_cundangwei.py`，全部通过）：

| 用例 | 结果 |
| --- | --- |
| `get_goods_2/cundangwei` | `errcode=0`，name=存档位、price=300、itype=1、number=1、inde=3 |
| 抓包字段逐项比对 | 除 `id`/`to`/`from` 为字符串形式外全部一致 |
| `get_goods/cundangwei`（GET 变体） | `errcode=0`，price=300 |
| `buy_goods_3/cundangwei` | `remove_yuanbao=300`（不再走价格 1 的兜底），元宝余额同步减少 |
| 商城列表 | `cundangwei` 不出现在 `get_store_list_4` 中 |

## 9-9 相比 9-1 的新增接口

9-1 抓包唯一路径 104 个，9-9 为 52 个，两者交集 33 个。9-9 新出现 19 个接口，全部已实现：

| 接口 | 状态 |
| --- | --- |
| `add_currency_number` | 本次实现 |
| `check_goods_valid` / `create_role` / `download_user_file_2` | 已实现 |
| `get_all_intimacy` / `get_all_persons` / `get_archive_list` | 已实现 |
| `get_hangUp_yashi_time` / `get_user_group` / `get_user_shenbings` | 已实现 |
| `report_cheat` / `stop_hang_up_task` / `upload_weapon_repair_log` | 已实现 |
| `upload_user_file_4` | 已实现 |
| `buy_goods_3/{type}` / `get_goods_2/{type}` | 已实现（前缀匹配，`cundangwei` 数据缺口见上） |
| `switch_archive/{n}` / `upload_user_file_3/{uType}/{cheatType}` | 已实现（前缀匹配） |

## 解密过程中的格式变化（供后续抓包参考）

9-9 客户端版本为 2.1.02，与 9-1（2.1.01）有三处不同：

1. **密钥协商组改为 JHHU02**：`exchange_publickey` 响应魔数为 `JHHU02`，用 `config.KEY_GROUPS["default"]` 的 key + IV 解出会话密钥。
2. **FZJH03 组下发独立 IV**：本次会话 `{"k":"25c5ee1661224ddf1845ca1d8afc0aae","h":"FZJH03","i":"PcIQIZifRalhZ88n"}`，与 9-1 的默认 IV `34857d973953e44a` 不同；旧脚本硬编码默认 IV 会解出乱码。
3. **密文长度校验**：9-9 的 FZJH03 响应去掉 6 字节魔数后剩余长度不是 16 的倍数（相差 12 字节），按 `magic(6) + iv(12) + 密文` 才能对齐；`_har_tool.py` 已对两种布局都做尝试，以能解出 JSON 的为准。

统计：234 条响应中成功解密 132 条（FZJH03 126 + JHHU02 6），第三方 100 条，1 条 `get_token` 响应无法解密（无匹配 key/IV 组合，不影响接口清单，URL 来自请求侧）。请求体解密 75 条（FZJH03 74 + JHHU02 1）。

## 复核命令

```powershell
python scripts\har\_har_tool.py decrypt so\ProxyPin9-9_09_12_12.har so\har_decrypt_99
python scripts\har\_har_tool.py audit so\har_decrypt_99\entries
python scripts\audits\_audit_har_diff.py
python scripts\audits\_audit_har91_runtime.py so\har_decrypt_99\entries
python scripts\probes\_verify_add_currency_number.py
python scripts\probes\_verify_cundangwei.py
```

`_verify_add_currency_number.py` 覆盖 6 组用例：抓包样本重放、连续发放累加、回读（`get_user_prestige` / `view_currency_by_type`）、其他货币入库、落盘重启 + 角色档镜像、异常入参。
`_verify_cundangwei.py` 覆盖 5 组用例：`get_goods_2` 详情、抓包字段比对、GET 变体、`buy_goods_3` 计价、商城列表不受影响。
