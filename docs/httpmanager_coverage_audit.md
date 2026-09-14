# HttpManager 接口覆盖比对报告

- 审查对象：`fzjh_lua/assets/src/app/extends/Http/`（客户端 Http 层）
- 对照对象：mock 服务端路由表 `server.ROUTES`（`handlers/*.py` 的 `@route` 注册项）
- 基线：commit `787d5f2`（2026-09-14）、客户端版本 2.1.02
- 审查脚本：`_audit_httpmanager_coverage.py`（本报告与附录 A 的数据来源）
- 口径测试：`test_httpmanager_audit.py`（28 用例）
- **本报告只做比对，不新增/修改任何接口实现**；`handlers/`、`server.py` 均未改动。

## 1. 结论

客户端 Http 层共有 **664 个唯一接口**，mock 路由表注册 **283 条**，其中：

| 分类 | 数量 | 说明 |
| --- | --- | --- |
| 精确命中 | 268 | 客户端 URL 与注册路由完全一致 |
| 前缀命中 | 2 | `count_single_record/*` 这类带路径参数的调用 |
| **未实现** | **394** | 既无精确匹配也无最长前缀匹配，服务端返回 `errcode=404 no such api` |
| 合计分母 | 664 | = 268 + 2 + 394 |

也就是说 **约 59% 的客户端接口在 mock 服务端没有实现**（394/664）。这不是个别遗漏，而是覆盖了任务、比武、家园地皮、参悟、抽奖、节日活动等约 40 个功能族。

两条对后续工作直接有用的判断：

1. **未实现的 394 个接口，一个都没有出现在现有抓包里**（三份抓包合计 86 个唯一游戏接口，与缺失集合交集为 0）。因此这些接口无法用现有抓包验证，唯一可靠路径是重新抓包或按客户端 Lua 反推契约。
2. **它们几乎都被真实客户端代码调用**：394 个里有 352 个能在 Http 层之外的客户端 Lua 中找到调用点，只有 42 个没有任何调用点（多为一次性调试与废弃分支，清单见 A.8）。也就是说这些缺口不是死代码，而是会在游戏里被真实触发的。

## 2. 审查对象与基线

| 文件 | 角色 | 解析结果 |
| --- | --- | --- |
| `extends/Http/HttpManager.lua` | 接口清单唯一来源 | 686 个函数、680 个函数有请求、664 个唯一接口 |
| `extends/Http/BaseHttp.lua` | 请求基类 | 0 个接口（只拼 `Game:getDomain() .. "api/v5/"` 前缀） |
| `extends/Http/Http.lua` | 带重试的请求封装 | 0 个接口 |
| `extends/Http/HttpListManager.lua` | 请求队列 | 0 个接口 |

脚本会扫描全部 4 个文件：若未来热更把接口定义挪到其它文件，会解析出非 0 结果并提示（当前为 0）。

> 注意客户端另有一份旧版 `extends/HttpManager.lua`（252 KB，全局 `HttpManager`），与新版的
> `extends/Http/HttpManager.lua` 并存；`Loader.lua` 把后者导出为 `HttpManagerEx`。
> 本报告以 `extends/Http/` 内的新版为准，旧版文件只作为调用点统计的排除源（避免定义行被误算成调用）。

## 3. 方法与口径

1. **剥离 Lua 注释**：先去 `--[[ ... ]]` 块注释，再去 `--` 行注释尾巴，用引号感知扫描以免误伤字符串。这一步不是可选项——不去注释会多出 6 个只存在于注释里的旧接口（见 §9）。
2. **按函数切块**：`^function HttpManager:NAME(` 切块，同一函数内多分支请求全部收集（例如 `getMultiFestivalGift` 的两个分支）。
3. **表达式解析**：块内扫描任意参数位置、跨行的 `DOMAIN .. <expr>`：
   - 字面量直接取（`DOMAIN .. "get_time"`）；
   - 局部变量解析（`local url = "upload_user_file_3"` 后 `DOMAIN .. url`，注意该写法出现在第二个参数位，普通正则容易漏）；
   - 动态尾巴保留字面前缀（`DOMAIN .. "get_board/" .. tostring(ptype)` → `get_board/`，靠前缀匹配命中 `get_board`）。
4. **覆盖判定与服务端一致**：完全复刻 `server.match_route` 的「先精确、再最长前缀」语义，避免把 `get_board/1`、`upload_user_file_3/kaishi/3` 这类调用误报为未实现。
5. **HTTP 动词**取自调用点（`retryGetWithHeader*` → GET，`retryPostWithHeader*` → POST），不是按名字猜的。
6. **近名路由不折算为已实现**：`add_currency` 与 `add_currency_number`、`get_login_reward` 与 `get_login_reward_info` 这类只进「别名复核候选」清单（§9），计分时仍算缺失。
7. **无 URL 的方法**（`async`、`getCheatType`、`getAndroidUUID`、`updateOrderState`、`uploadUserDataWithoutSave`）不计入分母，单列在 §9。

复现方式：

```bash
cd mock_server
python scripts/audits/_audit_httpmanager_coverage.py                          # 全量结论 + 清单
python scripts/audits/_audit_httpmanager_coverage.py --json audit.json        # 机器可读结果
python scripts/audits/_audit_httpmanager_coverage.py --appendix-md appendix.md # 重生成附录 A
python -m unittest tests.test_httpmanager_audit -v                            # 口径回归测试
```

附录 A 由脚本生成、粘贴于本报告末尾；刷新方式为重新执行 `--appendix-md`，再用输出替换
`## 附录` 之后的内容（正文 §1–§11 为人工撰写，不要覆盖）。

## 4. 家族分布

按功能族聚合后的未实现数量（完整表见 A.2，逐条清单见 A.3）：

| 家族 | 未实现 | 代表接口 |
| --- | --- | --- |
| test/调试接口 | 33 | `test_wish`、`test_exchange_goods`、`test_reset_task` |
| book/书籍武学 | 23 | `learn_skill`、`learn_book`、`complete_book`、`upgrade_technique` |
| shop/商城道具 | 23 | `use_shop_goods`、`buy_storage_box`、`buy_merit_goods`、`special_item_exchange` |
| activity/活动玩法 | 20 | `get_newdaily_lists`、`get_first_festival_gift`、`get_equinox_times` |
| user/角色存档 | 19 | `save_user_info`、`restore_user_map`、`get_random_userdata`、`delete_all_data` |
| dream/梦想世界 | 18 | `get_dream_role`、`upload_dream_role`、`dream_floor_complete` |
| land/家园地皮 | 18 | `get_land_info`、`move_home_land`、`bidding_land`、`revamp_room_attr` |
| zhao/参悟 | 18 | `get_insight_data`、`start_insight`、`zhao_practice`、`get_zhaoColors` |
| fight/比武PVP副本 | 17 | `get_fight_msg2`、`can_watch_fight`、`join_fight`(已废弃注释)、`get_out_fight_stage` |
| lottery/抽奖 | 16 | `do_yuanbao_lottery`、`do_mingren_lottery`、`get_yuanbao_lottery_list` |
| record/记录上报 | 13 | `upload_wash_attribute_record`、`check_user_gain_log` |
| reward/奖励领取 | 13 | `get_expel_reward`、`get_shenshi_reward`、`roll_daily_reward` |
| currency/货币元宝 | 12 | `add_currency`、`exchange_yinpiao`、`get_martial_upgrade_currency` |
| merchant/商人交易 | 11 | `trader_store`、`buy_trader_goods`、`detection_goods` |
| meridian/经脉破境 | 10 | `get_hidden_meridian_info`、`start_thoroughfare_vessel`、`unlock_hidden_meridian_gems` |
| task/任务链 | 10 | `accept_task`、`get_task_info`、`finish_task`、`submit_task` |

（其余族：menpai 9、qixi 9、spend 9、gift 8、other 8、boat 7、official 7、anniversary 6、intelligence 6、attribute 5、exam 4、order 4、teacher 4、trial 4、viewing 4、mask 3、sachet 3、sutra 3、talent 3、treasury 3、ui_theme 3、wish 3、ckitems 2、crontab 2、inheritance 1。）

## 5. 客户端可达性

用「Http 层之外的客户端 Lua 是否调用该 HttpManager 方法」衡量可达性（统计时排除 Lua 定义行，否则每个方法都会自带一次假调用）：

| 分类 | 数量 |
| --- | --- |
| 未实现且有客户端调用点 | 352 |
| 未实现且无任何调用点 | 42 |

调用点最密集的缺失接口（说明这些是真实会走到的链路，而非边角）：

| 接口 | 客户端方法 | 调用点 | 分散文件数 |
| --- | --- | --- | --- |
| `add_currency` | addActivityPoint / addCurrency | 12 | 11 |
| `detection_goods` | detectionGoods | 11 | 11 |
| `get_spend_plan_gift_list` | getSpendPlanGiftList | 9 | 3 |
| `push_affair` | pushAffair | 8 | 6 |
| `add_zhounian_jifen` | addZhounianJifen | 7 | 7 |
| `get_config_times` | getActionTimes | 7 | 6 |
| `remove_config_point` | submitAction | 7 | 6 |
| `test_exchange_goods` | testExchangeGoods | 6 | 3 |
| `receive_multi_festival_gift` | getMultiFestivalGift | 5 | 3 |
| `upload_zhengji` | uploadOfficialAchievement | 5 | 3 |

42 个无调用点的接口全部列在 A.8，多为 `test_*`、`clear_api_data`、`partition_clear`、`modify_qixi_ctime` 这类调试或已收敛的分支。

## 6. 抓包对照

现有三份已解密抓包（`so/har_decrypt_*/entries/`）：

| 来源 | 条目数 | 其中游戏后端接口（去重首段） |
| --- | --- | --- |
| har_decrypt_91 | 210 | — |
| har_decrypt_99 | 134 | — |
| har_decrypt_910_temp | 17 | — |
| 三份合计去重 | 361 | 86 |

结论：**394 个未实现接口与抓包集合的交集为 0**（报告中「未实现且在抓包中出现」恒为 0）。
这与既有审查结论一致——9-1 抓包覆盖到的接口早已全部实现，抓包能证明的只是「已实现的部分没问题」，无法为补齐提供契约样本。

因此后续要推进补齐，只有两条路：
1. **重新抓包**（覆盖任务、比武、家园地皮、参悟等目标玩法），按真实请求/响应落桩；
2. **按客户端 Lua 反推契约**（`HttpManager` 调用点 + 对应 model/UI 的字段消费方式），代价更高且需自行定义服务端结算规则。

## 7. 与既有文档的口径差异

`docs/har91_coverage_audit.md` 的「附带发现」一节记录：客户端接口 649 个、已注册路由 264 个、覆盖 241 个。
本报告为：接口 664、路由 283、覆盖 270。差异来自三处，均可解释：

1. **路由表增长**：264 → 283（该报告之后合入的拳脚、家园、挑战副本、师门等接口）。
2. **提取口径更严也更全**：
   - 去注释后剔除 6 个只存在于注释里的旧接口；
   - 解析局部变量后补回 `upload_user_file_3` / `upload_user_file_5`；
   - 扫描任意参数位置后补回 `get_time`、`uploadUserData` 这类 `DOMAIN` 不在首参的调用；
   - 动态尾巴按字面前缀参与前缀匹配（`get_board/`、`get_reward/`）。
3. **计数方式**：本报告把前缀命中单列（2 条），并把 `count_single_record/finish_ghost` 这类命中计入覆盖。

两处数字**不冲突**；以本报告为准（脚本可复现，且口径与 `server.match_route` 对齐）。

## 8. 反方向：路由表中没有客户端入口的接口

反向比对（已注册但没有任何客户端 URL 指向）共 15 条，全部列在 A.5：

- 协议前置/服务发现：`service/get_game_config`、`service/exchange_publickey`、`service_android/get_uuid`、`service_android/get_version_info`、`service_android/report_ads_info`、`service_android/update_uuid`
- 更新链路：`v1/checkUpdate`、`v1/getMd5List`、`v1/get_time`、`v1/get_game_version/MUD`
- 调试/运维：`hello`、`admin_send_email`、`update_order_state`、`vupgrade_user_bag`、`get_XinShenLevel`

这些不是「多余实现」：前两类由客户端更底层的 `GameChannelContext` / 更新流程调用，不在 `extends/Http/` 覆盖范围内；后一类是本地联调用的调试桩。它们的存在说明本报告的分子分母只覆盖 Http 业务层，不覆盖服务发现与热更链路。

## 9. 人工复核候选

**A.6 别名近似（11 组，均按「缺失」计分）**：`add_currency` ~ `add_currency_number`、`get_ckitems_list_by_uid` ~ `get_ckitems_list`、`get_devote_list_by_yuanbao` ~ `get_devote_list`、`get_fight_reward_notice` ~ `get_fight_reward`、`get_login_reward` ~ `get_login_reward_info`/`get_login_reward_list`、`get_spend_reward` ~ `get_spend_reward_list`、`get_yuanbao_consumption_info`/`get_yuanbao_consumption_reward`/`get_yuanbao_lottery_list`/`get_yuanbao_plan_gift_list` ~ `get_yuanbao`。
其中只有 `add_currency`（服务端已有 `add_currency_number`，语义相近但路径不同）值得优先确认；其余是「同族不同接口」，确认后仍应算缺失。

**A.7 仅存在于注释里的旧接口（6 个）**：`join_fight`、`get_fight_times`、`check_failed_history_sign`、`add_record/lunjian`、`get_dream_world`、`remove_room`。
它们已被 `join_fight2`、`get_fight_times2`、`check_failed_normal_sign` 等替代，不应实现。

**A.4 前缀命中（2 条）**：`count_single_record/finish_ghost`、`count_single_record/join_ghost` 都命中 `count_single_record`。
需人工确认服务端是否真的按路径尾部区分语义。

**A.8 无调用点的 42 个接口**：实现价值取决于是否要复现调试面板，而非玩法链路。

**无 URL 的本地方法（5 个）**：`async`、`getCheatType`、`getAndroidUUID`、`updateOrderState`、`uploadUserDataWithoutSave`——其中 `updateOrderState` 在路由表里存在同名实现，属于「客户端方法未直接发请求」的情况，不计入缺口。

## 10. 优先级建议（仅建议，不实施）

判断依据两条：**该族是否已有部分实现（缺一项则流程走不通）**，以及**调用点密度**。

| 优先级 | 目标族 | 未实现 | 理由 |
| --- | --- | --- | --- |
| P0 | task/任务链 | 10 | 主线任务整体缺失（`accept_task`/`get_task_info`/`finish_task`/`submit_task`），阻塞面最大 |
| P0 | fight/比武PVP副本 | 17 | 上游已有 `fight2`/`report_fight_result2`/`get_fight_board`/`get_fight_reward`，补齐 `get_fight_msg2`/`can_watch_fight`/`get_fight_yuanbao`/`get_out_fight_stage` 即可闭环 |
| P1 | land/家园地皮 | 18 | 家园模块已有实现，地皮/房间/事务链路缺失导致既有流程走不通 |
| P1 | zhao/参悟 | 18 | 调用点密集（`zhao_practice`、`get_insight_data` 等），且与已实现的 `zhao_upgrade`/`get_zhao_upgrade_matters` 同族 |
| P1 | currency+official+reward | 32 | `add_currency`（12 个调用点）是全客户端最热的缺失接口，牵动货币/功勋/奖励三类结算 |
| P2 | shop/商城道具、book/书籍武学 | 46 | 数量大但多为独立结算接口，可批量落桩 |
| P2 | 节日活动族（anniversary/qixi/boat/activity） | 42 | 接口彼此独立、数据可自造，适合整块实现 |
| P3 | test/调试接口 | 33 | 仅调试面板使用，可最后处理 |
| P3 | 42 个无调用点接口 | 42 | 无真实调用链路，按需实现 |

## 11. 已知限制

- 计数会随客户端 Lua 热更漂移；测试只断言不变量与固定锚点（`login`/`get_time`/`upload_user_file_3` 必须已覆盖，`accept_task`/`send_gift`/`can_watch_fight` 必须缺失），总数由脚本输出为准。
- 家族归类是关键字启发式，用于分批规划而非精确分类。
- 前缀匹配可能掩盖「路径参数未被真正处理」的问题（例如服务端注册了 `get_board` 却忽略 `/{ptype}`），需按 A.4 人工确认。
- 本报告只覆盖 `extends/Http/` 这一层；服务发现（`api/service*`）、更新链路（`v1/*`）、实时战斗网关（WebSocket）不在口径内。
- 路由表已知有 9 条重复注册（后加载覆盖前者），本报告按注册表命中判定覆盖，不评价实现是否被覆盖为死代码。

## 附录

> 本附录由 `_audit_httpmanager_coverage.py --appendix-md` 于 2026-09-14 15:16:15 生成, 请勿手改。

### A.1 总量

| 项 | 值 |
| --- | --- |
| HttpManager 函数总数 | 686 |
| 含接口的函数数 | 680 |
| 客户端唯一接口 | 664 |
| mock 路由表 | 283 |
| 精确命中 | 268 |
| 前缀命中 | 2 |
| **未实现** | **394** |
| 未实现且在抓包中出现 | 0 |

### A.2 家族分布

| 家族 | 未实现 | 代表接口 |
| --- | --- | --- |
| test/调试接口 | 33 | `clean_test_festival_data`, `init_test_festival_data`, `test_add_martial_currency`, `test_add_talent_page` |
| book/书籍武学 | 23 | `complete_book`, `delete_book`, `delete_book_dayLimit`, `get_books` |
| shop/商城道具 | 23 | `add_prop`, `buy_cuiLianCaiLiao_store_goods`, `buy_fistFootShop_specialOffer`, `buy_lucky_goods` |
| activity/活动玩法 | 20 | `buy_fistFootShop_dailyGoods`, `get_daily_Notice`, `get_equinox_times`, `get_first_festival_gift` |
| user/角色存档 | 19 | `clear_api_data`, `del_data_by_type`, `delete_all_data`, `delete_ciguan_redis` |
| dream/梦想世界 | 18 | `buy_dream_goods`, `delete_fond_dream_role`, `dream_floor_complete`, `dreamworld_complete` |
| land/家园地皮 | 18 | `add_homebw`, `add_land_gift`, `extension_room`, `find_roommate` |
| zhao/参悟 | 18 | `advance_insight_realm`, `cancel_insight`, `complete_insight`, `create_zhao` |
| fight/比武PVP副本 | 17 | `add_egg_challenge_times`, `bidding_land`, `can_watch_fight`, `get_bidding_land` |
| lottery/抽奖 | 16 | `buy_lottery_treasure_currency`, `do_lottery`, `do_mingren_lottery`, `do_mingwu_lottery` |
| record/记录上报 | 13 | `add_npc_record`, `add_zhipai_task_record`, `check_user_gain_log`, `claim_single_new_login_reward` |
| reward/奖励领取 | 13 | `exchange_yashi_welfare_reward`, `get_cuiLianCaiLiao_store_reward`, `get_danqing_pavilion_reward`, `get_expel_reward` |
| currency/货币元宝 | 12 | `add_currency`, `add_currency_by_type`, `add_money_ceiling`, `add_user_mingbi` |
| merchant/商人交易 | 11 | `buy_diy_goods`, `buy_merchant_goods`, `buy_trader_goods`, `del_buy_npc_time` |
| meridian/经脉破境 | 10 | `accelerate_break_through_realm`, `accelerate_thoroughfare_vessel`, `cancel_break_through_realm`, `cancel_thoroughfare_vessel` |
| task/任务链 | 10 | `accept_task`, `add_guide_task_point`, `finish_task`, `get_all_numrsper` |
| menpai/门派帮派 | 9 | `all_menpai_top`, `buy_sect_exchangeGoods`, `buy_sect_supportGoods`, `get_menpai_hongbao` |
| qixi/七夕 | 9 | `add_qixi_record`, `all_qixi_delete`, `finish_qixi_task`, `get_qixi_board` |
| spend/消费回馈 | 9 | `buy_spend_reward`, `clean_voucher_record_2`, `get_spend_info`, `get_spend_plan_gift_list` |
| gift/社交赠礼 | 8 | `check_has_gift`, `get_answer_status`, `get_jhsanyou_list`, `get_user_intimacy` |
| other/其它 | 8 | `addSingleRecord`, `canInherit`, `createNextRoleTask`, `finishNextRoleTask` |
| boat/龙舟端午 | 7 | `can_get_duanwu_reward`, `check_can_play_boat`, `get_boat_board`, `get_boat_reward` |
| official/官职功勋 | 7 | `buy_prestige_goods`, `delete_my_guanzhi`, `get_devote_list_by_yuanbao`, `get_guanzhi_fenlu` |
| anniversary/周年庆 | 6 | `add_zhounian_jifen`, `get_anniversary_login_list`, `get_anniversary_login_reward`, `get_anniversary_reward` |
| intelligence/情报 | 6 | `buy_day_intelligence`, `delete_bought_intelligence`, `delete_day_intelligence`, `get_intelligence_data` |
| attribute/属性加点 | 5 | `get_attribute_times`, `get_config_times`, `get_successRate`, `remove_attribute_point` |
| exam/科举考试 | 4 | `check_whether_exam`, `get_exam_point`, `get_exam_reward`, `upload_exam_point` |
| order/订单交易 | 4 | `get_order_id`, `roll_back_exchange`, `rollback_order_status`, `set_product_mark` |
| teacher/师门任务 | 4 | `buy_teacher_good`, `get_teacher_shop`, `get_zhipai_task_reward`, `respect_teacher` |
| trial/历练奇遇 | 4 | `add_incident_log`, `expel_nian`, `get_wumen_trial_info`, `get_wumen_trial_reward` |
| viewing/观战大厅 | 4 | `get_viewing_hall`, `get_viewing_privilege_info`, `get_viewing_privilege_reward`, `get_viewing_reward` |
| mask/面谱 | 3 | `buy_mask_piece_2`, `get_mask_list`, `refresh_mask_list` |
| sachet/香囊 | 3 | `exchange_award_to_sachet`, `exchange_award_to_sachet_new`, `get_sachet_attic_list` |
| sutra/藏经阁 | 3 | `buy_sutra_pavilion_goods`, `get_sutra_pavilion_goods`, `get_sutra_pavilion_list` |
| talent/天赋 | 3 | `get_talent_info`, `get_talent_page_count`, `switch_talent_page` |
| treasury/宝库 | 3 | `enter_next_treasury`, `get_treasury_info`, `get_treasury_reward` |
| ui_theme/主题皮肤 | 3 | `buy_ui_theme`, `get_ui_theme_list`, `use_ui_theme` |
| wish/心愿 | 3 | `get_wish_list/1`, `get_wish_list/2`, `upload_wish_data` |
| ckitems/仓库 | 2 | `del_ckitems`, `get_ckitems_list_by_uid` |
| crontab/后台任务 | 2 | `crontab_count_zhengji`, `crontab_gen_exam_reward` |
| inheritance/传承转世 | 1 | `get_chuanchen_user_info` |

### A.3 全量未实现清单(按家族)

| 接口 | HTTP | 客户端方法 | 调用点 | 抓包 |
| --- | --- | --- | --- | --- |
| `clean_test_festival_data` | POST | clearTestFestivalData | 0 | - |
| `init_test_festival_data` | POST | testFastivalDate | 0 | - |
| `test_add_martial_currency` | POST | testAddMartialCurrency | 1 | - |
| `test_add_talent_page` | POST | testAddTalentPage | 1 | - |
| `test_add_zhaoNum` | POST | testAddZhaoNum | 1 | - |
| `test_add_zhao_currency` | GET | testAddZhaoBreItems | 1 | - |
| `test_chongzhi` | GET | testChongzhi | 1 | - |
| `test_clear_book` | POST | testClearBook | 1 | - |
| `test_currency` | POST | testCurrency | 1 | - |
| `test_delete_all_ui_themes` | GET | testDeleteAllUiThemes | 1 | - |
| `test_delete_book` | POST | testDeleteBook | 1 | - |
| `test_delete_initial_meirongwan` | GET | testDeleteMeiRongWanInit | 1 | - |
| `test_exchange_goods` | POST | testExchangeGoods | 6 | - |
| `test_get_hang_task` | POST | testGetHangTask | 1 | - |
| `test_other_skill` | POST | testOtherSkill | 0 | - |
| `test_receive_anniversary_reward` | GET | testReceiveAnniversaryReward | 0 | - |
| `test_remove_menpai_team` | GET | removeManpaiTeam | 1 | - |
| `test_reset_my_reward` | GET | resetDuanWuReward | 0 | - |
| `test_reset_task` | GET | resetTeacherTask | 6 | - |
| `test_set_meridian_talent_page` | POST | testSetMeridianPageNum | 2 | - |
| `test_spend_plan` | GET | addSpendPlanGiftList, resetSpendPlanGiftList | 0 | - |
| `test_update_building_degree` | POST | testUpdateBuildingDegree | 1 | - |
| `test_update_hang_task` | POST | testSetUpdateHangTask | 2 | - |
| `test_update_task` | POST | testUpdateTask | 1 | - |
| `test_update_technique_feature` | POST | testUpdateTechniqueFeature | 1 | - |
| `test_update_user_family` | POST | testUpdateUserFamily | 1 | - |
| `test_update_yashi` | POST | testSetUpdateYaShiTime | 2 | - |
| `test_wish` | GET | testWish | 0 | - |
| `test_wish/1` | GET | TestWish1 | 0 | - |
| `test_wish/3` | GET | TestWish3 | 0 | - |
| `test_wish/4` | GET | TestWish4 | 0 | - |
| `test_wish/5` | GET | TestWish5 | 0 | - |
| `test_yueka` | GET | testYueKa | 0 | - |
| `complete_book` | POST | completeBook | 1 | - |
| `delete_book` | POST | deleteCompletedBook | 1 | - |
| `delete_book_dayLimit` | GET | deleteCreateBookDayLimit | 1 | - |
| `get_books` | GET | getCreateBooks | 1 | - |
| `get_martial_upgrade_currency` | POST | getSkillBreakCurrency | 1 | - |
| `get_other_skills` | POST | getOtherSkills | 1 | - |
| `get_practice_skill_reward` | POST | getPracticeSkillReward | 1 | - |
| `get_practice_skill_reward_list` | POST | getPracticeSkillRewardList | 1 | - |
| `get_record_skills` | GET | getRecordSkills | 2 | - |
| `get_skillName_affixs` | GET | getSkillNameAffixs | 1 | - |
| `get_technique_list` | GET | getTechniqueList | 1 | - |
| `grasp_technique_feature` | POST | extractCharacter | 1 | - |
| `learn_book` | POST | learnSkillBook | 1 | - |
| `learn_skill` | POST | learnSkill | 1 | - |
| `martial_upgrade` | POST | skillBreakThrough | 1 | - |
| `martial_upgrade_add_currency` | POST | martialUpgradeAddCurrency | 1 | - |
| `record_skill` | POST | recordSkill | 1 | - |
| `replace_technique_feature` | POST | replaceCharacter | 1 | - |
| `reset_fist_technique` | POST | resetTalentPage | 1 | - |
| `study_other_skill` | POST | studyOtherSkill | 1 | - |
| `unlock_practice_skill_reward` | POST | unlockPracticeSkillPayReward | 1 | - |
| `unlock_skillName_affixs` | POST | unlockSkillNameAffixs | 1 | - |
| `upgrade_technique` | POST | upgradeTechnique | 1 | - |
| `add_prop` | POST | addProp | 1 | - |
| `buy_cuiLianCaiLiao_store_goods` | POST | buyCuiLianCaiLiaoStoreGoods | 1 | - |
| `buy_fistFootShop_specialOffer` | POST | buyFistFootShopSpecialOffer | 1 | - |
| `buy_lucky_goods` | POST | buyLuckyGoods | 1 | - |
| `buy_merit_goods` | POST | buyMeritGoods | 1 | - |
| `buy_storage_box` | POST | buyStorageBox | 1 | - |
| `consume_special_props` | POST | consumeSpecialProps | 1 | - |
| `exchange_cuiLianCaiLiao_store_integral` | POST | exchangeCuiLianCaiLiaoStoreIntegral | 1 | - |
| `exchange_danqing_pavilion_item` | POST | exchangeDanQingPavilionItem | 1 | - |
| `exchange_lucky_point` | POST | exchangeLuckyPoint | 1 | - |
| `exchange_zhenpinge_goods` | POST | exchangeZhenPinGeGoods | 1 | - |
| `get_danqing_pavilion_info` | POST | getDanQingPavilionInfo | 1 | - |
| `get_lucky_goods` | POST | getLuckyGoods | 2 | - |
| `get_merit_goods` | POST | getMeritGoods | 1 | - |
| `get_propList` | GET | getPropList | 1 | - |
| `get_smithy_info` | GET | getSmithyInfo | 1 | - |
| `get_storage_box` | GET | getStorageBox | 1 | - |
| `is_visitor_shop_open` | GET | isOpenVisitTask | 1 | - |
| `restore_user_map` | POST | restoreUserMap | 1 | - |
| `special_item_exchange` | POST | specialItemExchange | 1 | - |
| `use_create_prop` | POST | useCreateProp | 1 | - |
| `use_improve_prop` | POST | useImproveProp | 1 | - |
| `use_shop_goods` | GET | useShopGoods | 1 | - |
| `buy_fistFootShop_dailyGoods` | POST | buyFistFootShopDailyGoods | 1 | - |
| `get_daily_Notice` | GET | getDailyNotice | 0 | - |
| `get_equinox_times` | POST | getEquinoxTimes | 1 | - |
| `get_first_festival_gift` | GET | getFirstFestivalGiftList | 3 | - |
| `get_login_yuandan_info` | GET | getLoginYuandanInfo | 1 | - |
| `get_multi_festival_gift_list` | GET | getMultiFestivalGiftList | 3 | - |
| `get_newdaily_award` | POST | receiveNewDailyReward | 1 | - |
| `get_newdaily_lists` | POST | getNewDailyList | 1 | - |
| `get_seventh_reward/1` | GET | getSeventhReward1 | 1 | - |
| `get_seventh_reward/2` | GET | getSeventhReward2 | 1 | - |
| `get_toast_reward` | POST | getToastReward | 1 | - |
| `get_toast_reward_list` | GET | getToastRewardList | 1 | - |
| `receive_first_festival_gift` | POST | getFirstFestivalGift | 3 | - |
| `receive_multi_festival_gift` | POST | getMultiFestivalGift | 5 | - |
| `receive_spring_new_reward` | GET | receiveSpringNewReward | 1 | - |
| `remove_equinox_point` | POST | removeEquinoxPoint | 1 | - |
| `reset_xianshilibao_points` | POST | resetXianShiPoint | 0 | - |
| `roll_daily_reward` | GET | rollDailyReward | 0 | - |
| `set_login_yuandan_reward` | POST | setLoginYuandanReward | 1 | - |
| `toast_qian` | POST | toastQian | 1 | - |
| `clear_api_data` | POST | clearApiData | 0 | - |
| `del_data_by_type` | POST | deleteClientData | 0 | - |
| `delete_all_data` | GET | delExamAllData | 1 | - |
| `delete_ciguan_redis` | GET | delOfficialLimit | 1 | - |
| `delete_user_point` | GET | delUserPoint | 1 | - |
| `delete_user_point_rank` | GET | delUserRankReward | 1 | - |
| `delete_youxia_upgradeCondition` | GET | deleteYouXiaMcmrestrict | 0 | - |
| `get_makeMask_info` | GET | getMakeMaskInfo | 1 | - |
| `get_random_userdata` | GET | getPlayGhost | 1 | - |
| `get_user_upload_info` | GET | getUserUploadInfo | 1 | - |
| `get_youxia_upgradeCondition` | POST | getYouXiaMcmrestrictUpgradeCondition | 1 | - |
| `partition_clear` | GET | partitionClear | 0 | - |
| `save_user_info` | POST | saveUserInfo | 3 | - |
| `set_sole_title` | GET | setSoleTitle | 1 | - |
| `switch_partition` | GET | switchServer | 0 | - |
| `switch_partition2` | GET | switchServer2 | 2 | - |
| `up_day_gametime` | POST | upDayGameTime | 0 | - |
| `update_data_state` | POST | updateDataState | 2 | - |
| `upgrande_user_map` | POST | upgrandeUserMap | 1 | - |
| `buy_dream_goods` | POST | buyDreamGood | 2 | - |
| `delete_fond_dream_role` | GET | deleteFondDreamRoleData | 1 | - |
| `dream_floor_complete` | POST | dreamFloorComplete | 1 | - |
| `dreamworld_complete` | POST | dreamWorldComplete | 1 | - |
| `fond_dream_floor_complete` | POST | fondDreamFloorComplete | 1 | - |
| `fond_dreamworld_complete` | POST | fondDreamWorldComplete | 1 | - |
| `get_dream_goods` | GET | getDreamGoods | 2 | - |
| `get_dream_reward_skill` | GET | getDreamRewardSkill | 1 | - |
| `get_dream_role` | GET | getDreamRoleData | 1 | - |
| `get_fond_dream_reward` | POST | getFondWebReward | 1 | - |
| `get_fond_dream_role` | GET | getFondDreamRoleData | 1 | - |
| `get_waking_dream_info` | GET | getWakingDreamInfo | 1 | - |
| `get_waking_dream_reward` | POST | getWakingDreamReward | 1 | - |
| `settle_overdue_dream` | POST | checkDreamRoleDataIsOverdue | 1 | - |
| `settle_overdue_fond_dream` | POST | checkFondDreamRoleDataIsOverdue | 1 | - |
| `unlock_waking_dream_pay_reward` | POST | unlockWakingDreamPayReward | 1 | - |
| `upload_dream_role` | POST | uploadDreamRoleData | 1 | - |
| `upload_fond_dream_role` | POST | uploadFondDreamRoleData | 1 | - |
| `add_homebw` | POST | addHomeBw | 0 | - |
| `add_land_gift` | POST | addLandGift | 1 | - |
| `extension_room` | POST | roomExtension | 1 | - |
| `find_roommate` | POST | findRoommate | 0 | - |
| `get_homeland_cost` | GET | getHomelandCost | 1 | - |
| `get_land_info` | POST | getLandInfo | 1 | - |
| `get_land_store_list` | POST | getLandStoreList | 1 | - |
| `move_home_land` | POST | moveHomeland | 1 | - |
| `process_affair` | POST | processRoomAffair | 1 | - |
| `process_pay_affairs` | POST | processPayAffairs | 1 | - |
| `push_affair` | POST | pushAffair | 8 | - |
| `recycle_land` | POST | recycleLand | 1 | - |
| `remove_furniture` | POST | removeFurniture | 2 | - |
| `revamp_room_attr` | POST | revampRoomAttr | 2 | - |
| `transfer_homegate_group` | POST | TransferHomegateGroup | 1 | - |
| `transform_room` | POST | transformRoom | 1 | - |
| `update_home_attr` | POST | updateHomeAttr | 2 | - |
| `use_homebw` | POST | useHomeBw | 1 | - |
| `advance_insight_realm` | POST | advanceActiveZhaoMeditateLevel | 1 | - |
| `cancel_insight` | POST | cancelActiveZhaoMeditate | 1 | - |
| `complete_insight` | POST | completeActiveZhaoMeditate | 1 | - |
| `create_zhao` | POST | createZhao | 1 | - |
| `execute_fuse` | POST | executeFuseActiveZhaoCanYe | 1 | - |
| `forget_zhao_page` | POST | forgetZhaoPage | 1 | - |
| `get_insight_data` | POST | getActiveZhaoMeditateInfo | 1 | - |
| `get_zhaoColors` | GET | getZhaoColors | 1 | - |
| `get_zhaoDscs` | POST | getZhaoDscs | 1 | - |
| `get_zhao_practiceInfo` | POST | getZhaoPracticeInfo | 1 | - |
| `get_zhaocaijinbao_info` | GET | getZhaoCaiJinBaoInfo | 1 | - |
| `get_zhaocaijinbao_reward` | POST | getZhaoCaiJinBaoReward | 1 | - |
| `gift_zhao_page` | POST | giftZhaoPage | 1 | - |
| `set_zhao_attr` | POST | setZhaoAttr | 1 | - |
| `start_insight` | POST | startActiveZhaoMeditate | 1 | - |
| `unlock_zhaoColor` | POST | unlockZhaoColor | 1 | - |
| `unlock_zhaoDsc_xiLie` | POST | unlockZhaoDsc | 1 | - |
| `zhao_practice` | POST | zhaoPractice | 1 | - |
| `add_egg_challenge_times` | POST | addEggChallengeTimes | 1 | - |
| `bidding_land` | POST | biddingLand | 1 | - |
| `can_watch_fight` | GET | getCanGuanZhan | 1 | - |
| `get_bidding_land` | POST | getbiddingLand | 1 | - |
| `get_bidding_return_point` | POST | getBiddingReturnPoint | 1 | - |
| `get_challengemap_task_info` | GET | getActivityChallengeMapClearTimeInfo | 1 | - |
| `get_challengemap_task_reward` | POST | getActivityChallengeMapClearReward | 1 | - |
| `get_chanllenge_msg` | GET | getChanllengeMsg | 1 | - |
| `get_characterPool_info` | POST | getCharacterPoolInfo | 1 | - |
| `get_egg_challenge_info` | GET | getEggChallengeInfo | 1 | - |
| `get_fight_msg2` | GET | getBiWuFighMessage | 1 | - |
| `get_fight_reward_notice` | GET | getFightWeekNotice | 1 | - |
| `get_fight_yuanbao` | GET | getBiWuFightYuanBao | 1 | - |
| `get_out_fight_stage` | GET | getBiWuFightEnd | 2 | - |
| `pvp_roleData_verify` | POST | pvpRoleDataVerify | 2 | - |
| `query_bidding_info` | GET | querybiddingInfo | 1 | - |
| `refresh_fuben_by_yuanbao` | POST | refreshFubenByYuanBao | 1 | - |
| `buy_lottery_treasure_currency` | POST | buyLotteryTreasureCurrency | 1 | - |
| `do_lottery` | POST | getPayLotteryGift | 2 | - |
| `do_mingren_lottery` | GET | doMingRenLottery | 1 | - |
| `do_mingwu_lottery` | GET | doMingWuLottery | 1 | - |
| `do_yuanbao_lottery` | GET | doYuanbaoLottery | 1 | - |
| `do_zhenpinge_lottery` | POST | doZhenPinGeLottery | 1 | - |
| `get_lottery_list` | POST | getPayLotteryGiftList | 2 | - |
| `get_lottery_treasure_exchange_shop` | POST | getLotteryTreasureExchangeShop | 0 | - |
| `get_lottery_treasure_list` | GET | getLotteryTreasureList | 1 | - |
| `get_mingren_lottery_list` | GET | getMingRenLotteryList | 1 | - |
| `get_mingwu_lottery_list` | GET | getMingWuLotteryList | 1 | - |
| `get_yuanbao_lottery_list` | GET | getYuanbaoLotteryList | 1 | - |
| `lottery_treasure_exchange_goods` | POST | lotteryTreasureExchangeGoods | 0 | - |
| `lottery_treasure_result` | POST | lotteryTreasureResult | 1 | - |
| `lottery_treasure_reward` | POST | lotteryTreasureReward | 1 | - |
| `treasury_lottery` | POST | WareHouseDrawLucky | 1 | - |
| `add_npc_record` | GET | addZhiZuoZuNpcRecord | 2 | - |
| `add_zhipai_task_record` | POST | addTeacherTaskRecord | 1 | - |
| `check_user_gain_log` | GET | getwxtranstwxplushasGainAfter202509291500 | 1 | - |
| `claim_single_new_login_reward` | POST | claimSingleNewLoginReward | 1 | - |
| `clear_my_shop_record` | POST | clearPointRecord, clearShopRecord | 0 | - |
| `delete_login_yuanbao_cache` | GET | deleteLoginYuanbaoCache | 0 | - |
| `get_event_record` | GET | getEventRecord | 1 | - |
| `get_login_reward` | POST | getFundReward, getLoginReward | 3 | - |
| `get_login_yuanbao` | GET | getLoginYuanbao | 1 | - |
| `get_logoutAccount_url` | GET | getLogoutAccountUrl | 1 | - |
| `get_zhipai_task_record` | GET | getTeacherTaskRecord | 1 | - |
| `record_wished_data` | POST | recordWishedData | 1 | - |
| `upload_wash_attribute_record` | POST | uploadWashAttributeRecord | 2 | - |
| `exchange_yashi_welfare_reward` | POST | exchangeYashiWelfareReward | 1 | - |
| `get_cuiLianCaiLiao_store_reward` | POST | getCuiLianCaiLiaoStoreReward | 1 | - |
| `get_danqing_pavilion_reward` | POST | getDanQingPavilionReward | 1 | - |
| `get_expel_reward` | POST | getExpelReward | 1 | - |
| `get_expel_reward_list` | GET | getExpelRewardList | 1 | - |
| `get_gift` | POST | getGift | 1 | - |
| `get_shenshi_reward` | POST | getShenShiReward | 3 | - |
| `get_smithy_reward` | POST | getSmithyReward | 1 | - |
| `get_web_reward` | POST | getWebReward | 1 | - |
| `get_yuanbao_consumption_reward` | POST | getYuanbaoConsumptionReward | 1 | - |
| `give_yueka_days` | POST | getActionAward | 1 | - |
| `receive_payMask_gift` | POST | receivePayMaskGift | 1 | - |
| `receive_yuanbao_plan_gift` | POST | receiveYuanBaoPlanGift | 2 | - |
| `add_currency` | POST | addActivityPoint, addCurrency | 12 | - |
| `add_currency_by_type` | POST | addCurrencyByType | 1 | - |
| `add_money_ceiling` | POST | addMoneyCeiling | 0 | - |
| `add_user_mingbi` | POST | addDeadCurrency | 4 | - |
| `bfmingtie_exchange_spcl` | GET | bfmingtieExchangeSpcl | 1 | - |
| `buy_mingbi_goods` | POST | buyDeadCurrencyGoods | 1 | - |
| `exchange_yinpiao` | POST | exchangeYinPiao | 2 | - |
| `fresh_task_by_yuanbao` | POST | refreshTeacherTaskList | 1 | - |
| `get_mingbi_list` | POST | getDeadCurrencyGoodsList | 2 | - |
| `get_yuanbao_consumption_info` | GET | getYuanbaoConsumptionInfo | 1 | - |
| `get_yuanbao_plan_gift_list` | GET | getYuanBaoCostGiftList | 3 | - |
| `get_yueka_times` | POST | getActionTime | 1 | - |
| `buy_diy_goods` | POST | buyDiyGoods | 1 | - |
| `buy_merchant_goods` | POST | buyMerchantGoods | 1 | - |
| `buy_trader_goods` | POST | buyChapmanItem | 1 | - |
| `del_buy_npc_time` | POST | addChapmanItemCount | 1 | - |
| `detection_goods` | POST | detectionGoods | 11 | - |
| `get_diy_goods` | POST | getDiyGoods | 2 | - |
| `get_diy_infos` | GET | getDiyInfos | 1 | - |
| `get_merchant_event_info` | POST | getMerchantEventInfo | 1 | - |
| `get_merchant_store_list` | POST | getMerchantStoreList | 1 | - |
| `get_npc_list` | GET | getZhiZuoZuRoleList | 1 | - |
| `trader_store` | GET | getChapmanItemList | 2 | - |
| `accelerate_break_through_realm` | POST | speedUpHiddenMeridianBreakThrough | 1 | - |
| `accelerate_thoroughfare_vessel` | POST | speedUpAcupointActivate | 1 | - |
| `cancel_break_through_realm` | POST | cancelHiddenMeridianBreakThrough | 1 | - |
| `cancel_thoroughfare_vessel` | POST | cancelAcupointActivate | 1 | - |
| `finish_break_through_realm` | POST | finishHiddenMeridianBreakThrough | 1 | - |
| `finish_thoroughfare_vessel` | POST | finishAcupointActivate | 1 | - |
| `get_hidden_meridian_info` | GET | getHiddenMeridianInfo | 1 | - |
| `start_break_through_realm` | POST | startHiddenMeridianBreakThrough | 1 | - |
| `start_thoroughfare_vessel` | POST | startAcupointActivate | 1 | - |
| `unlock_hidden_meridian_gems` | POST | unlockHiddenMeridianBuff | 1 | - |
| `accept_task` | POST | acceptTask | 1 | - |
| `add_guide_task_point` | POST | addGuideTaskPoint | 0 | - |
| `finish_task` | POST | finishTask | 1 | - |
| `get_all_numrsper` | POST | getPuRenNumAndRoomNum | 1 | - |
| `get_all_type_point` | GET | getAllTypePoint | 2 | - |
| `get_guide_task_point` | GET | getGuideTaskPoint | 1 | - |
| `get_task_info` | POST | getTaskInfo | 1 | - |
| `reset_task` | POST | resetTask | 1 | - |
| `submit_task` | POST | submitTask | 1 | - |
| `upload_abnormal_hangUp_task` | POST | uploadAbnormalHangUpTask | 1 | - |
| `all_menpai_top` | GET | getAllFamilyScore | 0 | - |
| `buy_sect_exchangeGoods` | POST | buySectExchangeGoods | 1 | - |
| `buy_sect_supportGoods` | POST | BuySectSupportGoods | 1 | - |
| `get_menpai_hongbao` | POST | getMenPaiHongBao | 1 | - |
| `get_same_menpai_user_list` | POST | getTeacherTaskPointList | 3 | - |
| `get_sect_exchangeStore` | POST | getSectExchangeStore | 1 | - |
| `get_sect_merit_store` | POST | getSectMeritStore | 1 | - |
| `get_sect_supportShop` | POST | getSectSupportShop | 1 | - |
| `update_menpai_gongxiangdian` | POST | updateMenpaiGongxiangdian | 2 | - |
| `add_qixi_record` | POST | addQiXiRecord | 1 | - |
| `all_qixi_delete` | GET | allQiXiDelete | 1 | - |
| `finish_qixi_task` | POST | FinishQiXiTask | 1 | - |
| `get_qixi_board` | GET | getQiXiRankBoard | 1 | - |
| `get_qixi_record` | GET | getQiXiRecord | 1 | - |
| `get_qixi_reward` | POST | getQiXiRankBoatReward | 1 | - |
| `get_qixi_task_info` | POST | getQiXiTaskInFo | 1 | - |
| `modify_qixi_ctime` | GET | testModifyQiXiCtime | 0 | - |
| `take_qixi_task` | POST | TakeQiXiTask | 1 | - |
| `buy_spend_reward` | POST | buySpendReward | 1 | - |
| `clean_voucher_record_2` | GET | cleanVoucherRecord | 0 | - |
| `get_spend_info` | GET | getActionSpendInfo | 1 | - |
| `get_spend_plan_gift_list` | GET | getSpendPlanGiftList | 9 | - |
| `get_spend_reward` | POST | getSpendReward | 1 | - |
| `get_total_spend_award` | POST | getTotalSpendAward | 1 | - |
| `get_total_spend_detail` | GET | getTotalSpendDetail | 1 | - |
| `get_voucher_prize_2` | POST | getVoucherPrize | 4 | - |
| `receive_spend_plan_gift_list` | POST | receiveSpendPlanGiftList | 5 | - |
| `check_has_gift` | POST | checkHasGift | 1 | - |
| `get_answer_status` | POST | getAnswerStatus | 1 | - |
| `get_jhsanyou_list` | GET | getJhSanYouList | 2 | - |
| `get_user_intimacy` | POST | getUserIntimacy | 1 | - |
| `send_gift` | POST | sendGift | 1 | - |
| `set_answer_status` | POST | setAnswerStatus | 2 | - |
| `update_user_intimacy` | POST | updateUserIntimacy | 1 | - |
| `vote_to_jhsanyou` | POST | voteToJhsanyou | 2 | - |
| `addSingleRecord` | POST | addSingleRecord | 0 | - |
| `canInherit` | POST | canInherit | 1 | - |
| `createNextRoleTask` | POST | CreateHeir | 1 | - |
| `finishNextRoleTask` | POST | inherit | 2 | - |
| `make_payMask` | POST | makePayMask | 1 | - |
| `make_randomMask` | POST | makeRandomMask | 1 | - |
| `resetDailyRecord/1` | GET | resetDailyRecord | 1 | - |
| `youxia_upgrade_condition` | POST | youxiaUpgradeMcmrestrict | 1 | - |
| `can_get_duanwu_reward` | GET | getBoatRewardList | 0 | - |
| `check_can_play_boat` | GET | checkCanJoinDragonBoat | 1 | - |
| `get_boat_board` | GET | getLongZhouDailyBoard | 3 | - |
| `get_boat_reward` | POST | getBoatReward | 2 | - |
| `get_duanwu_reward_notice` | GET | getDuanwuRewardNotice | 2 | - |
| `personal_boat_msg` | POST | getPersonalBoatScore | 4 | - |
| `update_boat_point` | POST | updateDragonBoatPoint | 1 | - |
| `buy_prestige_goods` | POST | buyPrestigeGoods | 1 | - |
| `delete_my_guanzhi` | GET | officialResignation | 2 | - |
| `get_devote_list_by_yuanbao` | POST | getDevoteListByYuanbao | 1 | - |
| `get_guanzhi_fenlu` | GET | getFenLu | 1 | - |
| `get_prestige_goods` | POST | getPrestigeGoods | 2 | - |
| `update_user_prestige` | POST | updateUserPrestige | 1 | - |
| `upload_zhengji` | POST | uploadOfficialAchievement | 5 | - |
| `add_zhounian_jifen` | POST | addZhounianJifen | 7 | - |
| `get_anniversary_login_list` | GET | getAnniversaryLoginList | 1 | - |
| `get_anniversary_login_reward` | POST | getAnniversaryLoginReward | 2 | - |
| `get_anniversary_reward` | POST | getAnniversaryReward | 1 | - |
| `get_anniversary_reward_list` | GET | getAnniversaryRewardList | 1 | - |
| `reset_anniversary_reward_list` | GET | resetAnniversaryRewardList | 0 | - |
| `buy_day_intelligence` | GET | buyIntelligence | 1 | - |
| `delete_bought_intelligence` | POST | deleteIntelligence | 0 | - |
| `delete_day_intelligence` | GET | deleteDayIntelligence | 0 | - |
| `get_intelligence_data` | GET | getIntelligenceData | 1 | - |
| `read_intelligence` | POST | readIntelligence | 1 | - |
| `upload_intelligence_data` | POST | uploadIntelligenceData | 1 | - |
| `get_attribute_times` | POST | getAttributeTimes | 1 | - |
| `get_config_times` | POST | getActionTimes | 7 | - |
| `get_successRate` | POST | getZhaoSuccessRate | 1 | - |
| `remove_attribute_point` | POST | removeAttributePoint | 1 | - |
| `remove_config_point` | POST | submitAction | 7 | - |
| `check_whether_exam` | GET | checkCanExam | 4 | - |
| `get_exam_point` | GET | getExamPoint | 4 | - |
| `get_exam_reward` | POST | getExamReward | 2 | - |
| `upload_exam_point` | POST | updateExamPoint | 2 | - |
| `get_order_id` | POST | getFestivalOrderId | 1 | - |
| `roll_back_exchange` | POST | rollBackExchage | 0 | - |
| `rollback_order_status` | POST | rollBackOrderStatus | 1 | - |
| `set_product_mark` | POST | setProductMark | 0 | - |
| `buy_teacher_good` | POST | buyTeacherTaskShopItem | 1 | - |
| `get_teacher_shop` | POST | getTeacherTaskShop | 3 | - |
| `get_zhipai_task_reward` | POST | getTeacherTaskRewaard | 1 | - |
| `respect_teacher` | GET | respectTeacher | 0 | - |
| `add_incident_log` | POST | addIncidentLog | 1 | - |
| `expel_nian` | POST | expelNian | 1 | - |
| `get_wumen_trial_info` | POST | getWuMenTrialInfo | 1 | - |
| `get_wumen_trial_reward` | POST | getWuMenTrialReward | 1 | - |
| `get_viewing_hall` | GET | getViewingHall | 1 | - |
| `get_viewing_privilege_info` | GET | getViewingHallPrivilegeInfo | 1 | - |
| `get_viewing_privilege_reward` | GET | getViewingHallPrivilegeReward | 1 | - |
| `get_viewing_reward` | POST | getViewingReward | 1 | - |
| `buy_mask_piece_2` | POST | buyMaskPiece | 1 | - |
| `get_mask_list` | GET | getMaskList | 1 | - |
| `refresh_mask_list` | POST | refreshMaskList | 1 | - |
| `exchange_award_to_sachet` | POST | exchangeAwardToSachet | 0 | - |
| `exchange_award_to_sachet_new` | POST | exchangeAwardToSachetNew | 1 | - |
| `get_sachet_attic_list` | GET | getSachetAtticList | 0 | - |
| `buy_sutra_pavilion_goods` | POST | buySutraPavilionGoods | 1 | - |
| `get_sutra_pavilion_goods` | POST | getSutraPavilionGoods | 1 | - |
| `get_sutra_pavilion_list` | POST | getSutraPavilionList | 1 | - |
| `get_talent_info` | POST | getTalentPageInfo | 1 | - |
| `get_talent_page_count` | POST | getTalentPageCount | 1 | - |
| `switch_talent_page` | POST | switchTalentPage | 1 | - |
| `enter_next_treasury` | GET | enterWareHouseNextFloor | 1 | - |
| `get_treasury_info` | POST | getWareHouseActivityInfo | 1 | - |
| `get_treasury_reward` | POST | getWareHouseAward | 1 | - |
| `buy_ui_theme` | GET | buyUiTheme | 1 | - |
| `get_ui_theme_list` | GET | getUiThemeList | 1 | - |
| `use_ui_theme` | GET | useUiTheme | 1 | - |
| `get_wish_list/1` | GET | getWishList1 | 1 | - |
| `get_wish_list/2` | GET | getWishList2 | 1 | - |
| `upload_wish_data` | POST | uploadWishData | 1 | - |
| `del_ckitems` | POST | delCkItems | 2 | - |
| `get_ckitems_list_by_uid` | POST | getCkItemsListByUid | 2 | - |
| `crontab_count_zhengji` | GET | calaOfficialAchievement | 1 | - |
| `crontab_gen_exam_reward` | GET | generateExamReward | 2 | - |
| `get_chuanchen_user_info` | POST | getInheritHistoryRoleAttr | 1 | - |

### A.4 前缀命中清单(参数级实现需人工确认)

| 客户端接口 | 命中路由 |
| --- | --- |
| `count_single_record/finish_ghost` | `count_single_record` |
| `count_single_record/join_ghost` | `count_single_record` |

### A.5 反方向: 路由表中无客户端入口

- `admin_send_email`
- `get_XinShenLevel`
- `hello`
- `service/exchange_publickey`
- `service/get_game_config`
- `service_android/get_uuid`
- `service_android/get_version_info`
- `service_android/report_ads_info`
- `service_android/update_uuid`
- `update_order_state`
- `v1/checkUpdate`
- `v1/getMd5List`
- `v1/get_game_version/MUD`
- `v1/get_time`
- `vupgrade_user_bag`

### A.6 别名复核候选

| 客户端缺失接口 | 近名已注册路由 |
| --- | --- |
| `add_currency` | `add_currency_number` |
| `get_ckitems_list_by_uid` | `get_ckitems_list` |
| `get_devote_list_by_yuanbao` | `get_devote_list` |
| `get_fight_reward_notice` | `get_fight_reward` |
| `get_login_reward` | `get_login_reward_info` |
| `get_login_reward` | `get_login_reward_list` |
| `get_spend_reward` | `get_spend_reward_list` |
| `get_yuanbao_consumption_info` | `get_yuanbao` |
| `get_yuanbao_consumption_reward` | `get_yuanbao` |
| `get_yuanbao_lottery_list` | `get_yuanbao` |
| `get_yuanbao_plan_gift_list` | `get_yuanbao` |

### A.7 仅存在于注释中的旧接口

- `add_record/lunjian`
- `check_failed_history_sign`
- `get_dream_world`
- `get_fight_times`
- `join_fight`
- `remove_room`

### A.8 未被任何其它客户端 Lua 调用的缺失接口

| 接口 | 客户端方法 |
| --- | --- |
| `addSingleRecord` | addSingleRecord |
| `add_guide_task_point` | addGuideTaskPoint |
| `add_homebw` | addHomeBw |
| `add_money_ceiling` | addMoneyCeiling |
| `all_menpai_top` | getAllFamilyScore |
| `can_get_duanwu_reward` | getBoatRewardList |
| `clean_test_festival_data` | clearTestFestivalData |
| `clean_voucher_record_2` | cleanVoucherRecord |
| `clear_api_data` | clearApiData |
| `clear_my_shop_record` | clearPointRecord, clearShopRecord |
| `del_data_by_type` | deleteClientData |
| `delete_bought_intelligence` | deleteIntelligence |
| `delete_day_intelligence` | deleteDayIntelligence |
| `delete_login_yuanbao_cache` | deleteLoginYuanbaoCache |
| `delete_youxia_upgradeCondition` | deleteYouXiaMcmrestrict |
| `exchange_award_to_sachet` | exchangeAwardToSachet |
| `find_roommate` | findRoommate |
| `get_daily_Notice` | getDailyNotice |
| `get_lottery_treasure_exchange_shop` | getLotteryTreasureExchangeShop |
| `get_sachet_attic_list` | getSachetAtticList |
| `init_test_festival_data` | testFastivalDate |
| `lottery_treasure_exchange_goods` | lotteryTreasureExchangeGoods |
| `modify_qixi_ctime` | testModifyQiXiCtime |
| `partition_clear` | partitionClear |
| `reset_anniversary_reward_list` | resetAnniversaryRewardList |
| `reset_xianshilibao_points` | resetXianShiPoint |
| `respect_teacher` | respectTeacher |
| `roll_back_exchange` | rollBackExchage |
| `roll_daily_reward` | rollDailyReward |
| `set_product_mark` | setProductMark |
| `switch_partition` | switchServer |
| `test_other_skill` | testOtherSkill |
| `test_receive_anniversary_reward` | testReceiveAnniversaryReward |
| `test_reset_my_reward` | resetDuanWuReward |
| `test_spend_plan` | addSpendPlanGiftList, resetSpendPlanGiftList |
| `test_wish` | testWish |
| `test_wish/1` | TestWish1 |
| `test_wish/3` | TestWish3 |
| `test_wish/4` | TestWish4 |
| `test_wish/5` | TestWish5 |
| `test_yueka` | testYueKa |
| `up_day_gametime` | upDayGameTime |
