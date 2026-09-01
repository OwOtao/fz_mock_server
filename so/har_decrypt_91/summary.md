# ProxyPin9-1_22_57_26.har 解密汇总

- 条目总数: 262
- 输出目录: `F:\AI\fzjh\har_decrypt_91`

## 本次会话密钥 (来自 har 内 exchange_publickey, JHHU01 静态密钥解出)

```json
[
  {
    "k": "3541a91c710ecd1e70fdff9a60c909c6",
    "h": "FZJH02"
  },
  {
    "k": "56611ad7cd284ae04c1432748fa5c761",
    "h": "FZJH03"
  },
  {
    "k": "3541a91c710ecd1e70fdff9a60c909c6",
    "h": "FXXF03"
  }
]
```

- IV: `34857d973953e44a` (默认 IV, 本 HAR 的 FZJH03 组未下发 `i` 字段, 实测默认 IV 正确)
- exchange_publickey / get_game_config / update 服务器响应使用 `JHHU01` 静态组 (2.1.01 客户端)

## 解密统计

```
req:3rd_party                            39
req:FZJH03                               82
req:JHHU01                               1
resp:3rd_party                           52
resp:FZJH03                              203
resp:JHHU01                              4
```

## 条目明细

| # | 时间 | 方法 | 状态 | 路径 | 请求体 | 响应体 | 备注 |
|---|------|------|------|------|--------|--------|------|
| 0 | 14:56:44 | POST | 200 | `log-api/service/2/app_log/` | 第三方 | 第三方 | 第三方SDK |
| 1 | 14:56:20 | GET | 200 | `android/api/v5/get_time` | - | 已解(FZJH03) |  |
| 2 | 14:56:17 | POST | 200 | `android/api/v5/get_teacherBuild_info` | 已解(FZJH03) | 已解(FZJH03) |  |
| 3 | 14:56:16 | POST | 200 | `android/api/v5/get_user_prestige` | 已解(FZJH03) | 已解(FZJH03) |  |
| 4 | 14:56:16 | GET | 200 | `android/api/v5/get_devote_point` | - | 已解(FZJH03) |  |
| 5 | 14:56:15 | GET | 200 | `android/api/v5/get_devote_point` | - | 已解(FZJH03) |  |
| 6 | 14:56:15 | POST | 200 | `alog/app_logs` | 第三方 | 第三方 | 第三方SDK |
| 7 | 14:56:15 | POST | 200 | `alog/app_logs` | 第三方 | 第三方 | 第三方SDK |
| 8 | 14:56:15 | GET | 200 | `android/api/v5/get_time` | - | 已解(FZJH03) |  |
| 9 | 14:56:12 | POST | 200 | `log-api/service/2/app_log/` | 第三方 | 第三方 | 第三方SDK |
| 10 | 14:56:08 | POST | 200 | `android/api/v5/get_user_prestige` | 已解(FZJH03) | 已解(FZJH03) |  |
| 11 | 14:56:08 | GET | 200 | `android/api/v5/get_devote_point` | - | 已解(FZJH03) |  |
| 12 | 14:56:08 | GET | 200 | `android/api/v5/get_devote_point` | - | 已解(FZJH03) |  |
| 13 | 14:56:06 | GET | 200 | `android/api/v5/get_time` | - | 已解(FZJH03) |  |
| 14 | 14:56:05 | GET | 0 | `android/api/v5/get_time` | - | - |  |
| 15 | 14:56:05 | POST | 200 | `toblog/service/2/app_log/` | 第三方 | 第三方 | 第三方SDK |
| 16 | 14:56:05 | GET | -4 | `uop/` | - | 第三方 | 第三方SDK |
| 17 | 14:56:05 | POST | 200 | `alog/app_logs` | 第三方 | 第三方 | 第三方SDK |
| 18 | 14:56:05 | GET | 200 | `log/service/2/app_alert_check/` | - | 第三方 | 第三方SDK |
| 19 | 14:56:05 | POST | 200 | `apmplus/monitor/collect/c/session` | 第三方 | 第三方 | 第三方SDK |
| 20 | 14:56:05 | POST | 200 | `alog/app_logs` | 第三方 | 第三方 | 第三方SDK |
| 21 | 14:54:04 | GET | 200 | `android/api/v5/get_time` | - | 已解(FZJH03) |  |
| 22 | 14:53:58 | POST | 200 | `android/api/v5/get_zhao_upgrade_matters` | 已解(FZJH03) | 已解(FZJH03) |  |
| 23 | 14:53:50 | POST | 200 | `android/api/v5/view_currency_by_type` | 已解(FZJH03) | 已解(FZJH03) |  |
| 24 | 14:53:49 | POST | 200 | `android/api/v5/view_currency_by_type` | 已解(FZJH03) | 已解(FZJH03) |  |
| 25 | 14:53:45 | POST | 200 | `android/api/v5/report_gain_log` | 已解(FZJH03) | 已解(FZJH03) |  |
| 26 | 14:53:39 | POST | 200 | `android/api/v5/update_unlock_record` | 已解(FZJH03) | 已解(FZJH03) |  |
| 27 | 14:53:38 | POST | 200 | `android/api/v5/get_growth_info` | 已解(FZJH03) | 已解(FZJH03) |  |
| 28 | 14:53:37 | POST | 200 | `android/api/v5/update_unlock_record` | 已解(FZJH03) | 已解(FZJH03) |  |
| 29 | 14:53:37 | POST | 200 | `android/api/v5/get_growth_info` | 已解(FZJH03) | 已解(FZJH03) |  |
| 30 | 14:53:35 | POST | 200 | `android/api/v5/update_unlock_record` | 已解(FZJH03) | 已解(FZJH03) |  |
| 31 | 14:53:35 | POST | 200 | `android/api/v5/get_growth_info` | 已解(FZJH03) | 已解(FZJH03) |  |
| 32 | 14:53:20 | POST | 200 | `android/api/v5/get_user_map` | 已解(FZJH03) | 已解(FZJH03) |  |
| 33 | 14:53:12 | POST | 200 | `android/api/v5/get_rank_list_4` | 已解(FZJH03) | 已解(FZJH03) |  |
| 34 | 14:53:11 | POST | 200 | `android/api/v5/upload_user_file_3/paihang/3` | 已解(FZJH03) | 已解(FZJH03) |  |
| 35 | 14:53:11 | GET | 200 | `android/api/v5/is_changed_name` | - | 已解(FZJH03) |  |
| 36 | 14:53:11 | GET | 200 | `android/api/v5/get_email` | - | 已解(FZJH03) |  |
| 37 | 14:53:03 | POST | 200 | `android/api/v5/upload_map_extra` | 已解(FZJH03) | 已解(FZJH03) |  |
| 38 | 14:53:03 | POST | 200 | `android/api/v5/outgoing_ckitems` | 已解(FZJH03) | 已解(FZJH03) |  |
| 39 | 14:52:48 | POST | 200 | `android/api/v5/get_client_data` | 已解(FZJH03) | 已解(FZJH03) |  |
| 40 | 14:52:45 | POST | 200 | `android/api/v5/report_gain_log` | 已解(FZJH03) | 已解(FZJH03) |  |
| 41 | 14:52:31 | POST | 200 | `android/api/v5/get_ckitems_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 42 | 14:52:31 | POST | 200 | `android/api/v5/get_client_data` | 已解(FZJH03) | 已解(FZJH03) |  |
| 43 | 14:52:21 | POST | 200 | `android/api/v5/incr_weapon_cuilian_num` | 已解(FZJH03) | 已解(FZJH03) |  |
| 44 | 14:52:12 | POST | 200 | `android/api/v5/incr_weapon_cuilian_num` | 已解(FZJH03) | 已解(FZJH03) |  |
| 45 | 14:52:05 | POST | 200 | `android/api/v5/incr_weapon_cuilian_num` | 已解(FZJH03) | 已解(FZJH03) |  |
| 46 | 14:52:00 | POST | 200 | `android/api/v5/incr_weapon_cuilian_num` | 已解(FZJH03) | 已解(FZJH03) |  |
| 47 | 14:51:44 | POST | 200 | `android/api/v5/report_gain_log` | 已解(FZJH03) | 已解(FZJH03) |  |
| 48 | 14:51:41 | POST | 200 | `android/api/v5/get_ckitems_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 49 | 14:51:41 | POST | 200 | `android/api/v5/get_client_data` | 已解(FZJH03) | 已解(FZJH03) |  |
| 50 | 14:51:35 | POST | 200 | `android/api/v5/get_config_fuben` | 已解(FZJH03) | 已解(FZJH03) |  |
| 51 | 14:51:31 | POST | 200 | `android/api/v5/get_config_fuben` | 已解(FZJH03) | 已解(FZJH03) |  |
| 52 | 14:51:20 | POST | 200 | `android/api/v5/get_activity_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 53 | 14:51:18 | GET | 200 | `android/api/v5/get_spring_festival_list` | - | 已解(FZJH03) |  |
| 54 | 14:51:17 | POST | 200 | `android/api/v5/get_activity_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 55 | 14:51:15 | POST | 200 | `android/api/v5/get_activity_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 56 | 14:51:15 | GET | 200 | `android/api/v5/get_time` | - | 已解(FZJH03) |  |
| 57 | 14:51:12 | POST | 200 | `android/api/v5/claim_all_new_login_reward` | 已解(FZJH03) | 已解(FZJH03) |  |
| 58 | 14:51:11 | POST | 200 | `android/api/v5/claim_all_new_login_reward` | 已解(FZJH03) | 已解(FZJH03) |  |
| 59 | 14:51:09 | POST | 200 | `android/api/v5/get_new_login_reward_Info` | 已解(FZJH03) | 已解(FZJH03) |  |
| 60 | 14:51:09 | GET | 200 | `android/api/v5/get_spring_festival_status/157` | - | 已解(FZJH03) |  |
| 61 | 14:51:01 | GET | 200 | `android/api/v5/get_login_reward_list/mingshidenglu1` | - | 已解(FZJH03) |  |
| 62 | 14:51:01 | GET | 200 | `android/api/v5/get_spring_festival_status/90` | - | 已解(FZJH03) |  |
| 63 | 14:50:57 | GET | 200 | `android/api/v5/get_payMask_gift_info` | - | 已解(FZJH03) |  |
| 64 | 14:50:56 | GET | 200 | `android/api/v5/get_spring_festival_status/141` | - | 已解(FZJH03) |  |
| 65 | 14:50:54 | GET | 200 | `android/api/v5/get_daily_task_list` | - | 已解(FZJH03) |  |
| 66 | 14:50:54 | GET | 200 | `android/api/v5/get_spring_festival_status/86` | - | 已解(FZJH03) |  |
| 67 | 14:50:52 | GET | 200 | `android/api/v5/get_spring_festival_status/84` | - | 已解(FZJH03) |  |
| 68 | 14:50:49 | GET | 200 | `android/api/v5/get_xianshilibao_gift_list_2` | - | 已解(FZJH03) |  |
| 69 | 14:50:49 | GET | 200 | `android/api/v5/get_spring_festival_status/8` | - | 已解(FZJH03) |  |
| 70 | 14:50:48 | GET | 200 | `android/api/v5/get_spring_festival_status/8` | - | 已解(FZJH03) |  |
| 71 | 14:50:45 | GET | 200 | `android/api/v5/get_spring_new_reward` | - | 已解(FZJH03) |  |
| 72 | 14:50:44 | GET | 200 | `android/api/v5/get_spring_festival_status/1` | - | 已解(FZJH03) |  |
| 73 | 14:50:42 | GET | 200 | `android/api/v5/get_spring_festival_status/70` | - | 已解(FZJH03) |  |
| 74 | 14:50:40 | GET | 200 | `android/api/v5/get_spring_festival_status/58` | - | 已解(FZJH03) |  |
| 75 | 14:50:37 | POST | 200 | `android/api/v5/get_training_task_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 76 | 14:50:36 | GET | 200 | `android/api/v5/get_spring_festival_status/103` | - | 已解(FZJH03) |  |
| 77 | 14:50:33 | POST | 200 | `android/api/v5/set_fistFootShop_dailyCost` | 已解(FZJH03) | 已解(FZJH03) |  |
| 78 | 14:50:27 | POST | 200 | `android/api/v5/set_fistFootShop_dailyCost` | 已解(FZJH03) | 已解(FZJH03) |  |
| 79 | 14:50:18 | GET | 200 | `android/api/v5/get_fistFootShop_info` | - | 已解(FZJH03) |  |
| 80 | 14:50:18 | GET | 200 | `android/api/v5/get_spring_festival_status/140` | - | 已解(FZJH03) |  |
| 81 | 14:50:16 | POST | 200 | `android/api/v5/get_cuiLianCaiLiao_store_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 82 | 14:50:15 | GET | 200 | `android/api/v5/get_spring_festival_status/128` | - | 已解(FZJH03) |  |
| 83 | 14:50:12 | GET | 200 | `android/api/v5/get_sachet_attic_new_list/scachetAttic` | - | 已解(FZJH03) |  |
| 84 | 14:50:12 | GET | 200 | `android/api/v5/get_spring_festival_status/112` | - | 已解(FZJH03) |  |
| 85 | 14:50:09 | GET | 200 | `android/api/v5/get_spend_reward_list/jianghumibao1` | - | 已解(FZJH03) |  |
| 86 | 14:50:09 | GET | 200 | `android/api/v5/get_spring_festival_status/94` | - | 已解(FZJH03) |  |
| 87 | 14:50:06 | GET | 200 | `android/api/v5/get_recharge_benefits_info` | - | 已解(FZJH03) |  |
| 88 | 14:50:06 | POST | 200 | `android/api/v5/get_game_activity/dailypaynew` | 已解(FZJH03) | 已解(FZJH03) |  |
| 89 | 14:50:06 | GET | 200 | `android/api/v5/get_spring_festival_status/149` | - | 已解(FZJH03) |  |
| 90 | 14:50:03 | GET | 200 | `android/api/v5/get_sign_list` | - | 已解(FZJH03) |  |
| 91 | 14:50:03 | GET | 200 | `android/api/v5/get_spring_festival_status/14` | - | 已解(FZJH03) |  |
| 92 | 14:50:02 | GET | 200 | `android/api/v5/get_sign_list` | - | 已解(FZJH03) |  |
| 93 | 14:50:02 | GET | 200 | `android/api/v5/get_spring_festival_status/14` | - | 已解(FZJH03) |  |
| 94 | 14:50:02 | GET | 200 | `android/api/v5/get_sign_list` | - | 已解(FZJH03) |  |
| 95 | 14:50:01 | GET | 200 | `android/api/v5/get_spring_festival_status/14` | - | 已解(FZJH03) |  |
| 96 | 14:50:01 | GET | 200 | `android/api/v5/get_sign_list` | - | 已解(FZJH03) |  |
| 97 | 14:50:00 | GET | 200 | `android/api/v5/get_spring_festival_status/14` | - | 已解(FZJH03) |  |
| 98 | 14:49:52 | POST | 200 | `android/api/v5/get_shop_info` | 已解(FZJH03) | 已解(FZJH03) |  |
| 99 | 14:49:52 | GET | 200 | `android/api/v5/get_spring_festival_status/19` | - | 已解(FZJH03) |  |
| 100 | 14:49:52 | GET | 200 | `android/api/v5/get_spring_festival_status/19` | - | 已解(FZJH03) |  |
| 101 | 14:49:44 | GET | 200 | `android/api/v5/get_spring_festival_list` | - | 已解(FZJH03) |  |
| 102 | 14:49:44 | POST | 200 | `android/api/v5/get_activity_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 103 | 14:49:42 | POST | 200 | `android/api/v5/get_activity_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 104 | 14:49:40 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 105 | 14:49:39 | GET | 200 | `android/api/v5/get_limit_package/libao1440` | - | 已解(FZJH03) |  |
| 106 | 14:49:37 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 107 | 14:49:36 | GET | 200 | `android/api/v5/get_limit_package/libao1434` | - | 已解(FZJH03) |  |
| 108 | 14:49:35 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 109 | 14:49:34 | GET | 200 | `android/api/v5/get_limit_package/libao1439` | - | 已解(FZJH03) |  |
| 110 | 14:49:32 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 111 | 14:49:31 | GET | 200 | `android/api/v5/get_limit_package/libao1438` | - | 已解(FZJH03) |  |
| 112 | 14:49:29 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 113 | 14:49:28 | GET | 200 | `android/api/v5/get_limit_package/libao1437` | - | 已解(FZJH03) |  |
| 114 | 14:49:25 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 115 | 14:49:24 | GET | 200 | `android/api/v5/get_limit_package/libao1435` | - | 已解(FZJH03) |  |
| 116 | 14:49:21 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 117 | 14:49:20 | GET | 200 | `android/api/v5/get_limit_package/libao1436` | - | 已解(FZJH03) |  |
| 118 | 14:49:17 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 119 | 14:49:16 | GET | 200 | `android/api/v5/get_limit_package/libao1435` | - | 已解(FZJH03) |  |
| 120 | 14:49:14 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 121 | 14:49:13 | GET | 200 | `android/api/v5/get_limit_package/libao1434` | - | 已解(FZJH03) |  |
| 122 | 14:49:11 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 123 | 14:49:10 | GET | 200 | `android/api/v5/get_limit_package/libao1433` | - | 已解(FZJH03) |  |
| 124 | 14:49:07 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 125 | 14:49:06 | GET | 200 | `android/api/v5/get_limit_package/libao1432` | - | 已解(FZJH03) |  |
| 126 | 14:49:02 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 127 | 14:49:01 | GET | 200 | `android/api/v5/get_limit_package/libao1430` | - | 已解(FZJH03) |  |
| 128 | 14:49:00 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 129 | 14:48:59 | GET | 200 | `android/api/v5/get_limit_package/libao1429` | - | 已解(FZJH03) |  |
| 130 | 14:48:57 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 131 | 14:48:56 | GET | 200 | `android/api/v5/get_limit_package/libao1428` | - | 已解(FZJH03) |  |
| 132 | 14:48:55 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 133 | 14:48:54 | GET | 200 | `android/api/v5/get_limit_package/libao1427` | - | 已解(FZJH03) |  |
| 134 | 14:48:53 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 135 | 14:48:51 | GET | 200 | `android/api/v5/get_limit_package/libao1426` | - | 已解(FZJH03) |  |
| 136 | 14:48:50 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 137 | 14:48:48 | GET | 200 | `android/api/v5/get_limit_package/libao1425` | - | 已解(FZJH03) |  |
| 138 | 14:48:46 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 139 | 14:48:46 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 140 | 14:48:45 | GET | 200 | `android/api/v5/get_store_list_4` | - | 已解(FZJH03) |  |
| 141 | 14:48:45 | GET | 200 | `android/api/v5/get_bind_info` | - | 已解(FZJH03) |  |
| 142 | 14:48:43 | POST | 200 | `android/api/v5/report_gain_log` | 已解(FZJH03) | 已解(FZJH03) |  |
| 143 | 14:48:42 | POST | 200 | `android/api/v5/get_activity_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 144 | 14:48:39 | GET | 200 | `android/api/v5/get_zhenpinge_lottery_list/jianghuzhenpinge1` | - | 已解(FZJH03) |  |
| 145 | 14:48:39 | GET | 200 | `android/api/v5/get_spring_festival_status/121` | - | 已解(FZJH03) |  |
| 146 | 14:48:35 | POST | 200 | `android/api/v5/get_luck_box_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 147 | 14:48:33 | POST | 200 | `android/api/v5/get_luck_box_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 148 | 14:48:32 | POST | 200 | `android/api/v5/get_luck_box_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 149 | 14:48:30 | POST | 200 | `android/api/v5/get_luck_box_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 150 | 14:48:27 | POST | 200 | `android/api/v5/get_luck_box_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 151 | 14:48:24 | POST | 200 | `android/api/v5/get_luck_box_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 152 | 14:48:23 | GET | 200 | `android/api/v5/get_spring_festival_status/100` | - | 已解(FZJH03) |  |
| 153 | 14:48:18 | POST | 200 | `android/api/v5/get_cuiLianCaiLiao_store_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 154 | 14:48:18 | GET | 200 | `android/api/v5/get_spring_festival_status/128` | - | 已解(FZJH03) |  |
| 155 | 14:48:08 | POST | 200 | `android/api/v5/refresh_training_task_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 156 | 14:48:00 | POST | 200 | `android/api/v5/get_training_task_reward` | 已解(FZJH03) | 已解(FZJH03) |  |
| 157 | 14:47:57 | POST | 200 | `android/api/v5/get_training_task_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 158 | 14:47:57 | GET | 200 | `android/api/v5/get_spring_festival_status/103` | - | 已解(FZJH03) |  |
| 159 | 14:47:49 | GET | 200 | `android/api/v5/get_daily_task_list` | - | 已解(FZJH03) |  |
| 160 | 14:47:48 | POST | 200 | `android/api/v5/get_daily_task_reward` | 已解(FZJH03) | 已解(FZJH03) |  |
| 161 | 14:47:46 | GET | 200 | `android/api/v5/get_daily_task_list` | - | 已解(FZJH03) |  |
| 162 | 14:47:46 | GET | 200 | `android/api/v5/get_spring_festival_status/86` | - | 已解(FZJH03) |  |
| 163 | 14:47:43 | POST | 200 | `android/api/v5/report_gain_log` | 已解(FZJH03) | 已解(FZJH03) |  |
| 164 | 14:47:42 | GET | 200 | `android/api/v5/get_spring_festival_list` | - | 已解(FZJH03) |  |
| 165 | 14:47:41 | POST | 200 | `android/api/v5/get_activity_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 166 | 14:47:38 | POST | 200 | `android/api/v5/add_daily_task_point` | 已解(FZJH03) | 已解(FZJH03) |  |
| 167 | 14:47:38 | POST | 200 | `android/api/v5/add_training_task_point` | 已解(FZJH03) | 已解(FZJH03) |  |
| 168 | 14:47:33 | POST | 200 | `android/api/v5/get_activity_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 169 | 14:47:26 | POST | 200 | `log/service/2/app_log/` | 第三方 | 第三方 | 第三方SDK |
| 170 | 14:47:22 | POST | 200 | `api-access/api/ad/union/sdk/upload/app_info/` | 第三方 | 第三方 | 第三方SDK |
| 171 | 14:47:20 | GET | 200 | `android/api/v5/get_daily_task_list` | - | 已解(FZJH03) |  |
| 172 | 14:47:20 | GET | 200 | `android/api/v5/get_time` | - | 已解(FZJH03) |  |
| 173 | 14:47:20 | GET | 200 | `android/api/v5/get_spring_festival_status/86` | - | 已解(FZJH03) |  |
| 174 | 14:47:20 | GET | 0 | `android/api/v5/get_spring_festival_status/86` | - | - |  |
| 175 | 14:47:04 | GET | 200 | `android/api/v5/get_daily_task_list` | - | 已解(FZJH03) |  |
| 176 | 14:47:03 | GET | 200 | `android/api/v5/get_spring_festival_status/86` | - | 已解(FZJH03) |  |
| 177 | 14:46:56 | GET | 200 | `android/api/v5/get_daily_task_list` | - | 已解(FZJH03) |  |
| 178 | 14:46:56 | GET | 200 | `android/api/v5/get_spring_festival_status/86` | - | 已解(FZJH03) |  |
| 179 | 14:46:48 | GET | 200 | `android/api/v5/get_sign_list` | - | 已解(FZJH03) |  |
| 180 | 14:46:48 | GET | 200 | `android/api/v5/get_spring_festival_status/14` | - | 已解(FZJH03) |  |
| 181 | 14:46:47 | GET | 200 | `android/api/v5/get_sign_list` | - | 已解(FZJH03) |  |
| 182 | 14:46:46 | GET | 200 | `android/api/v5/get_spring_festival_status/14` | - | 已解(FZJH03) |  |
| 183 | 14:46:42 | GET | 200 | `android/api/v5/get_sign_list` | - | 已解(FZJH03) |  |
| 184 | 14:46:41 | GET | 200 | `android/api/v5/get_spring_festival_status/14` | - | 已解(FZJH03) |  |
| 185 | 14:46:39 | GET | 200 | `android/api/v5/get_spring_festival_list` | - | 已解(FZJH03) |  |
| 186 | 14:46:38 | POST | 200 | `android/api/v5/get_activity_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 187 | 14:46:33 | POST | 200 | `android/api/v5/start_hang_up_task` | 已解(FZJH03) | 已解(FZJH03) |  |
| 188 | 14:46:26 | POST | 200 | `log/service/2/app_log/` | 第三方 | 第三方 | 第三方SDK |
| 189 | 14:46:24 | POST | 200 | `android/api/v5/add_training_task_point` | 已解(FZJH03) | 已解(FZJH03) |  |
| 190 | 14:46:20 | GET | 200 | `android/api/v5/get_devote_point` | - | 已解(FZJH03) |  |
| 191 | 14:46:19 | POST | 200 | `android/api/v5/add_daily_task_point` | 已解(FZJH03) | 已解(FZJH03) |  |
| 192 | 14:46:19 | POST | 200 | `android/api/v5/add_devote_point` | 已解(FZJH03) | 已解(FZJH03) |  |
| 193 | 14:46:17 | POST | 200 | `android/api/v5/get_user_prestige` | 已解(FZJH03) | 已解(FZJH03) |  |
| 194 | 14:46:17 | GET | 200 | `android/api/v5/get_devote_point` | - | 已解(FZJH03) |  |
| 195 | 14:46:17 | GET | 200 | `android/api/v5/get_devote_point` | - | 已解(FZJH03) |  |
| 196 | 14:46:06 | POST | 200 | `android/api/v5/get_user_prestige` | 已解(FZJH03) | 已解(FZJH03) |  |
| 197 | 14:46:06 | GET | 200 | `android/api/v5/get_user_designation` | - | 已解(FZJH03) |  |
| 198 | 14:46:05 | POST | 200 | `android/api/v5/get_activity_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 199 | 14:46:05 | GET | 200 | `android/api/v5/get_time` | - | 已解(FZJH03) |  |
| 200 | 14:46:04 | POST | 200 | `android/api/v5/get_teacherBuild_info` | 已解(FZJH03) | 已解(FZJH03) |  |
| 201 | 14:46:04 | POST | 200 | `android/api/v5/get_teacherBuild_list` | 已解(FZJH03) | 已解(FZJH03) |  |
| 202 | 14:46:04 | POST | 200 | `android/api/v5/refreshItemMapCache` | 已解(FZJH03) | 已解(FZJH03) |  |
| 203 | 14:46:04 | POST | 200 | `android/api/v5/get_fist_info` | 已解(FZJH03) | 已解(FZJH03) |  |
| 204 | 14:46:03 | POST | 200 | `android/api/v5/getXiuLianData` | 已解(FZJH03) | 已解(FZJH03) |  |
| 205 | 14:46:03 | POST | 200 | `android/api/v5/getXiuLianState` | 已解(FZJH03) | 已解(FZJH03) |  |
| 206 | 14:46:03 | POST | 200 | `android/api/v5/getLianGongData` | 已解(FZJH03) | 已解(FZJH03) |  |
| 207 | 14:46:02 | POST | 200 | `android/api/v5/getLianGongState` | 已解(FZJH03) | 已解(FZJH03) |  |
| 208 | 14:46:02 | POST | 200 | `android/api/v5/update_unlock_record` | 已解(FZJH03) | 已解(FZJH03) |  |
| 209 | 14:46:01 | POST | 200 | `android/api/v5/get_game_user_info_2` | 已解(FZJH03) | 已解(FZJH03) |  |
| 210 | 14:46:01 | POST | 200 | `android/api/v5/upload_user_file_3/kaishi/3` | 已解(FZJH03) | 已解(FZJH03) |  |
| 211 | 14:46:00 | POST | 200 | `android/api/v5/create_account` | - | 已解(FZJH03) |  |
| 212 | 14:45:56 | GET | 200 | `android/api/v5/get_partition_list2` | - | 已解(FZJH03) |  |
| 213 | 14:45:54 | GET | 200 | `android/api/v5/get_token` | - | 已解(FZJH03) |  |
| 214 | 14:45:54 | GET | 0 | `android/api/v5/get_token` | - | - |  |
| 215 | 14:45:51 | POST | 200 | `api-access/api/ad/union/sdk/stats/batch/` | 第三方 | 第三方 | 第三方SDK |
| 216 | 14:45:42 | POST | 200 | `api-access/api/ad/union/sdk/stats/batch/` | 第三方 | 第三方 | 第三方SDK |
| 217 | 14:45:38 | GET | 200 | `android/api/v5/getWebConfig` | - | 已解(FZJH03) |  |
| 218 | 14:45:38 | GET | 200 | `android/api/v5/get_time` | - | 已解(FZJH03) |  |
| 219 | 14:45:32 | GET | 404 | `abtest-ch/` | - | 第三方 | 第三方SDK |
| 220 | 14:45:32 | POST | 200 | `api-access/api/ad/union/sdk/stats/batch/` | 第三方 | 第三方 | 第三方SDK |
| 221 | 14:45:32 | POST | 200 | `api-access/api/ad/union/sdk/stats/batch/` | 第三方 | 第三方 | 第三方SDK |
| 222 | 14:45:32 | POST | 200 | `api-access/api/ad/union/sdk/stats/batch/` | 第三方 | 第三方 | 第三方SDK |
| 223 | 14:45:31 | POST | 200 | `api-access/api/ad/union/sdk/settings/` | 第三方 | 第三方 | 第三方SDK |
| 224 | 14:45:31 | POST | 200 | `mssdk/ri/report_otob` | 第三方 | 第三方 | 第三方SDK |
| 225 | 14:45:30 | POST | 200 | `apmplus/settings/get` | 第三方 | 第三方 | 第三方SDK |
| 226 | 14:45:30 | POST | 200 | `vcs/vc/setting` | 第三方 | 第三方 | 第三方SDK |
| 227 | 14:45:30 | POST | 200 | `apmplus/monitor/collect/c/cloudcontrol/get` | 第三方 | 第三方 | 第三方SDK |
| 228 | 14:45:30 | GET | 200 | `webcast-open/webcast/openapi/setting/i18n/package/` | - | 第三方 | 第三方SDK |
| 229 | 14:45:30 | GET | 200 | `webcast-open/webcast/openapi/pangle/id_sign/` | - | 第三方 | 第三方SDK |
| 230 | 14:45:30 | GET | 200 | `webcast-open/webcast/openapi/setting/tab/` | - | 第三方 | 第三方SDK |
| 231 | 14:45:30 | GET | 200 | `webcast-open/webcast/openapi/setting/` | - | 第三方 | 第三方SDK |
| 232 | 14:45:29 | GET | 200 | `tnc0-alisc1/get_domains/v5/` | - | 第三方 | 第三方SDK |
| 233 | 14:45:29 | POST | 200 | `webcast-open/webcast/openapi/pangle/common_params/` | 第三方 | 第三方 | 第三方SDK |
| 234 | 14:45:27 | POST | 200 | `toblog/service/2/device_sdk/kite/` | 第三方 | 第三方 | 第三方SDK |
| 235 | 14:45:27 | POST | 200 | `toblog/service/2/device_sdk/kite/` | 第三方 | 第三方 | 第三方SDK |
| 236 | 14:45:26 | POST | 200 | `apmplus/monitor/collect/c/session` | 第三方 | 第三方 | 第三方SDK |
| 237 | 14:45:25 | POST | 200 | `log/service/2/app_log/` | 第三方 | 第三方 | 第三方SDK |
| 238 | 14:45:25 | POST | 200 | `apmplus/settings/get` | 第三方 | 第三方 | 第三方SDK |
| 239 | 14:45:25 | POST | 200 | `log/service/2/log_settings/` | 第三方 | 第三方 | 第三方SDK |
| 240 | 14:45:25 | POST | 200 | `log/service/2/device_register/` | 第三方 | 第三方 | 第三方SDK |
| 241 | 14:45:23 | GET | 200 | `webcast-open/webcast/openapi/pangle/setting/` | - | 第三方 | 第三方SDK |
| 242 | 14:45:22 | GET | 200 | `update/v1/getMd5List` | - | 已解(JHHU01) |  |
| 243 | 14:45:22 | GET | 200 | `update/v1/checkUpdate` | - | 已解(JHHU01) |  |
| 244 | 14:45:22 | GET | -4 | `uop/` | - | 第三方 | 第三方SDK |
| 245 | 14:45:22 | POST | 200 | `toblog/service/2/app_log/` | 第三方 | 第三方 | 第三方SDK |
| 246 | 14:45:22 | POST | 200 | `api-access/api/ad/union/mediation/config/` | 第三方 | 第三方 | 第三方SDK |
| 247 | 14:45:22 | GET | 200 | `sf6-fe-tos/obj/ad-pattern/renderer/package.json` | - | 第三方 | 第三方SDK |
| 248 | 14:45:22 | GET | 200 | `lf-cdn-tos/obj/static/ad/play-comp/playable-component-sdk/package.ugen.json` | - | 第三方 | 第三方SDK |
| 249 | 14:45:22 | POST | 200 | `toblog/service/2/log_settings/` | 第三方 | 第三方 | 第三方SDK |
| 250 | 14:45:21 | POST | 200 | `android/api/service_android/report_ads_info` | 已解(JHHU01) | 已解(FZJH03) |  |
| 251 | 14:45:21 | POST | 200 | `toblog/service/2/device_register_only/` | 第三方 | 第三方 | 第三方SDK |
| 252 | 14:45:21 | POST | 200 | `api-access/api/ad/union/mediation/config/` | 第三方 | 第三方 | 第三方SDK |
| 253 | 14:45:21 | GET | 200 | `api-access/api/ad/union/ping` | - | 第三方 | 第三方SDK |
| 254 | 14:45:21 | POST | 200 | `alog/app_logs` | 第三方 | 第三方 | 第三方SDK |
| 255 | 14:45:21 | POST | 200 | `alog/app_logs` | 第三方 | 第三方 | 第三方SDK |
| 256 | 14:45:21 | POST | 200 | `android/api/service_android/get_version_info` | - | 已解(FZJH03) |  |
| 257 | 14:45:21 | POST | 200 | `android/api/service/exchange_publickey` | - | 已解(JHHU01) |  |
| 258 | 14:45:20 | GET | 200 | `android/api/service/get_game_config` | - | 已解(JHHU01) |  |
| 259 | 14:45:16 | CONNECT | -1 | `10` | 第三方 | 第三方 | 第三方SDK |
| 260 | 14:45:16 | CONNECT | -1 | `10` | 第三方 | 第三方 | 第三方SDK |
| 261 | 14:45:16 | CONNECT | -1 | `10` | 第三方 | 第三方 | 第三方SDK |
