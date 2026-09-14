# har_decrypt_91 接口实现审查

- 审查对象：`so/har_decrypt_91/entries/`（210 个已解密条目，全部来自游戏后端）
- 审查范围：排除第三方 SDK（穿山甲 / 字节 apmplus / alog / toblog / webcast 等）
- 审查时间基线：commit `14daa45` 之后
- 审查脚本（位于 `scripts/audits/`）：
  - `_audit_har91_coverage.py`：URL → 路由覆盖率
  - `_audit_har91_runtime.py`：逐条调用 handler 冒烟
  - `_audit_inventory_coverage.py`：客户端全量接口清单对照

## 结论

**9-1 抓包覆盖的游戏接口全部已实现，未发现未实现接口。**

| 分类 | 数量 |
| --- | --- |
| 抓包条目（已解密） | 210 |
| 其中游戏后端 API（`android.fzjh...`） | 208 |
| 其中更新服务器（`update.xiaohoutiaotiao.com`） | 2 |
| 其中第三方 SDK（本次 entries 目录内无） | 0 |
| 去重后的接口路径 | 103 |
| 精确命中已注册路由 | 57 |
| 前缀命中（带路径参数） | 46（对应 28 个路由） |
| **未实现（404 / 无路由）** | **0** |

补充说明：

- `entries/` 目录只保存了游戏后端条目；全量 HAR 里的 52 条第三方 SDK 条目不在该目录内，因此第三方无需过滤也不会污染结果。
- `/v1/checkUpdate`、`/v1/getMd5List` 属更新服务器（`update.xiaohoutiaotiao.com`），由 `checkUpdate` 代理转发上游实现，不是未实现。

## 带路径参数的接口（前缀命中）核对

| 路径模式 | 抓包请求数 | 实现方式 | 参数是否被使用 |
| --- | --- | --- | --- |
| `get_limit_package/{libaoXXXX}` | 15 个礼包 | `_LIMITED_PACKAGE_DETAILS` 表 | 是，未命中返回 404 |
| `get_spring_festival_status/{id}` | 20 个 id | `_SPRING_STATUS_CAPTURE` 表 + 总表兜底 | 是 |
| `get_game_activity/dailypaynew` | 1 | 命中抓包基线，其余回退旧实现 | 是 |
| `get_login_reward_list/mingshidenglu1` | 1 | 命中抓包基线，其余回退 `service.py` | 是 |
| `get_sachet_attic_new_list/scachetAttic` | 1 | 固定抓包基线 | 是（仅一个样本） |
| `get_spend_reward_list/jianghumibao1` | 1 | 固定抓包基线 | 是（仅一个样本） |
| `get_zhenpinge_lottery_list/jianghuzhenpinge1` | 1 | 固定抓包基线 + 本地次数/货币 | 是（仅一个样本） |
| `upload_user_file_3/{uType}/{cheatType}` | 2（kaishi / paihang） | `_save_upload` 记录 uType/cheatType | 是，参数来自请求体 |

礼包明细覆盖 16 个：抓包请求的 15 个全部命中，另外 `libao1431` 为按同档礼包合成的兜底数据（抓包时因年龄限制未打开）。
春节活动状态覆盖 19 个独立抓包样本，`id=32` 走总表兜底。

## 冒烟测试中返回非 0 errcode 的 10 条（均非“未实现”）

| 接口 | errcode | 原因 |
| --- | --- | --- |
| `upload_user_file_3/kaishi/3`、`/paihang/3` | 400 | 审查脚本传的是抓包 `request_plain`，`_extract_archive` 无法解析；真实客户端上传的是 `[{userAttr},{recordInfo}]` 结构 |
| `outgoing_ckitems` | 2 | 请求带 `ver`，而审查用的空账号仓库版本不匹配 |
| `get_training_task_reward` | 1 | 空账号历练分不足 |
| `get_daily_task_reward` | 1 | 空账号任务未完成 |
| `add_devote_point` | 3 | 空账号缺少前置数据 |
| `getXiuLianData` / `getLianGongData` | 1 | 未开始修炼/练功，无会话 |
| `/v1/checkUpdate`、`/v1/getMd5List` | 无 errcode | 代理转发上游，沙箱内无外网导致失败 |

## 附带发现（超出 9-1 抓包范围）

用 `fzjh_lua/protocol_inventory.json`（客户端 HttpManager 全量接口）对照：

- 客户端接口 649 个（含多 URL 拆分），mock_server 已注册路由 264 个，覆盖 241 个；
- **9-1 抓包出现过的 63 个接口全部已实现**，408 个未实现接口在本次抓包中均未出现，无法据此验证；
- 结论：本次抓包不构成“未实现接口”的证据来源，若要继续补齐需新抓包。

> 本节数字已被 [httpmanager_coverage_audit.md](httpmanager_coverage_audit.md) 取代（口径更严：去注释、
> 解析局部变量、扫描任意参数位置、与 `server.match_route` 对齐）。最新口径为客户端接口 664 个、
> 路由 283 个、覆盖 270 个、未实现 394 个；差异原因见该报告 §7。
