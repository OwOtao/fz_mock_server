# 放置江湖 HTTP 协议字典 (v3)

协议方法总数: **676**

### 1. `async` (unknown)
参数: `funcName, ...`
URL: `third.async.AsyncFunction`

### 2. `getTime` (get)
参数: `func, isNeedWait, retryType, waitText`
URL: `get_time`
响应处理: createGetResponseFunction

### 3. `createRole` (post)
参数: `func, isNeedWait, retryType`
URL: `create_role`
请求体: `""`
响应处理: createGetResponseFunction

### 4. `getStoreData` (get)
参数: `func, isNeedWait, retryType`
URL: `get_store_list_4`
请求体: `""`
响应处理: createGetResponseFunction

### 5. `getAppStoreData` (get)
参数: `func, isNeedWait, retryType`
URL: `get_applestore_list`
请求体: `""`
响应处理: createGetResponseFunction

### 6. `getCheatType` (unknown)
参数: ``
URL: `app.views.layer.ControllLayer` `app.views.layer.TaskLayer.TaskLayer` `app.views.layer.StoreLayer.StoreLayer` `app.views.layer.SkillLayer.SkillInfoLayer` `app.views.layer.MapLayer.MapLayer`

### 7. `uploadUserData` (post)
参数: `uType, func, isNeedWait, retryType, isNeedSave`
URL: `upload_user_file_3`
响应处理: createGetResponseFunction

### 8. `uploadUserDataWithoutSave` (unknown)
参数: `uType, func, isNeedWait, retryType`

### 9. `uploadLocalUserData` (post)
参数: `uType, func, isNeedWait, retryType`
URL: `upload_user_file_5`
响应处理: createGetResponseFunction

### 10. `downloadUserData` (get)
参数: `func, isNeedWait, retryType`
URL: `download_user_file_2`
请求体: `""`
响应处理: createGetResponseFunction

### 11. `getReward` (get)
参数: `type, func, isNeedWait, retryType`
URL: `get_reward/`
响应处理: createGetResponseFunction

### 12. `getReward2` (post)
参数: `rType, trans_id, homeland_open, func, isNeedWait, retryType`
URL: `get_reward_2/`
响应处理: createGetResponseFunction

### 13. `updataUserName` (post)
参数: `name, func, isNeedWait, retryType`
URL: `update_username`
请求体: `{name = name}`
响应处理: createGetResponseFunction

### 14. `buyGoods` (post)
参数: `id, itemId, count, trans_id, others, discount, func, isNeedWait, retryType`
URL: `buy_goods_3/` `buy_goods`
响应处理: createGetResponseFunction

### 15. `getGoodsInfo` (get)
参数: `itemId, func, isNeedWait, retryType`
URL: `get_goods/`
响应处理: createGetResponseFunction

### 16. `getGoodsInfo_2` (post)
参数: `itemId, others, func, isNeedWait, retryType`
URL: `get_goods_2/` `check_fail_transaction/`
响应处理: createGetResponseFunction

### 17. `checkTrans` (post)
参数: `transType, trans_id, func, isNeedWait, retryType`
URL: `check_fail_transaction_2/`
响应处理: createGetResponseFunction

### 18. `getYuanBao` (get)
参数: `func, isNeedWait, retryType`
URL: `get_yuanbao`
请求体: `""`
响应处理: createGetResponseFunction

### 19. `getRankingList` (post)
参数: `page, func, isNeedWait, retryType`
URL: `get_rank_list_4`
请求体: `{page = page}`
响应处理: createGetResponseFunction

### 20. `getBoard` (post)
参数: `ptype, page, func, isNeedWait, retryType`
URL: `get_board/`
响应处理: createGetResponseFunction

### 21. `getRemoveYuanBao` (get)
参数: `num, trans_id, func, isNeedWait, retryType`
URL: `remove_yuanbao/`
响应处理: createGetResponseFunction

### 22. `checkLogin` (post)
参数: `postData, func, isNeedWait, retryType`
URL: `login`
请求体: `postData`
响应处理: createGetResponseFunction

### 23. `getRandomWeaponDesc` (get)
参数: `wType, func, isNeedWait, retryType`
URL: `get_random_weapon_desc/`
响应处理: createGetResponseFunction

### 24. `makeWeapon` (post)
参数: `params, func, isNeedWait, retryType`
URL: `make_weapon`
请求体: `params`
响应处理: createGetResponseFunction

### 25. `upgradeWeapon` (post)
参数: `params, func, isNeedWait, retryType`
URL: `upgrade_weapon`
请求体: `params`
响应处理: createGetResponseFunction

### 26. `getThrowWeaponData` (get)
参数: `func, isNeedWait, retryType`
URL: `get_history_weapon`
请求体: `""`
响应处理: createGetResponseFunction

### 27. `throwShenBingWeapon` (post)
参数: `throwType, index, params, func, isNeedWait, retryType`
URL: `throw_weapon/`
响应处理: createGetResponseFunction

### 28. `getIsChangedName` (get)
参数: `func, isNeedWait, retryType`
URL: `is_changed_name`
请求体: `""`
响应处理: createGetResponseFunction

### 29. `getArchiveList` (get)
参数: `func, isNeedWait, retryType`
URL: `get_archive_list`
请求体: `""`
响应处理: createGetResponseFunction

### 30. `switchArchive` (get)
参数: `switchTo, callback, isNeedWait, retryType`
URL: `switch_archive/`
响应处理: createGetResponseFunction

### 31. `useShopGoods` (get)
参数: `itemId, func, isNeedWait, retryType`
URL: `use_shop_goods/`
响应处理: createGetResponseFunction

### 32. `testYueKa` (get)
参数: `func, isNeedWait, retryType`
URL: `test_yueka`
请求体: `""`
响应处理: createGetResponseFunction

### 33. `getJhmsDesc` (get)
参数: `func, isNeedWait, retryType`
URL: `get_jhms_desc`
请求体: `""`
响应处理: createGetResponseFunction

### 34. `getJhmsReward` (post)
参数: `trans_id, homeland_open, days, func, isNeedWait, retryType`
URL: `get_jhms_reward`
请求体: `{trans_id = trans_id`
响应处理: createGetResponseFunction

### 35. `checkGoodsValid` (post)
参数: `itemIds, func, isNeedWait, retryType`
URL: `check_goods_valid`
请求体: `{itemIds = itemIds}`
响应处理: createGetResponseFunction

### 36. `uploadCheat` (post)
参数: `cheat, func, isNeedWait, retryType`
URL: `report_cheat`
请求体: `cheat`
响应处理: createGetResponseFunction

### 37. `getUserInfo` (post)
参数: `userID, userType, func, isNeedWait, retryType`
URL: `get_user_info`
请求体: `{userid = userID`
响应处理: createGetResponseFunction

### 38. `getBiWuRankingList` (get)
参数: `typeNUm, func, isNeedWait, retryType`
URL: `get_fight_board/`
响应处理: createGetResponseFunction

### 39. `sendBiWuWatch` (post)
参数: `func, isNeedWait, retryType`
URL: `watch_fight`
请求体: `nil`
响应处理: createGetResponseFunction

### 40. `sendBiWuUnWatch` (post)
参数: `params, func, isNeedWait, retryType`
URL: `unwatch_fight`
请求体: `params`
响应处理: createGetResponseFunction

### 41. `getBiWuFighMessage` (post)
参数: `func, isNeedWait, retryType`
URL: `get_fight_msg2` `join_fight`
请求体: `""` `role_lv`
响应处理: createGetResponseFunction

### 42. `sendBiWuJoinFight` (post)
参数: `func, isNeedWait, retryType`
URL: `join_fight2`
请求体: `""`
响应处理: createGetResponseFunction

### 43. `sendBiWuFight` (post)
参数: `fight_type, params, func, isNeedWait, retryType`
URL: `fight2/`
响应处理: createGetResponseFunction

### 44. `sendBiWuFightResult` (post)
参数: `params, func, isNeedWait, retryType`
URL: `report_fight_result2`
请求体: `params`
响应处理: createGetResponseFunction

### 45. `sendBiWuFightCardId` (post)
参数: `params, func, isNeedWait, retryType`
URL: `use_fight_card` `get_fight_times`
请求体: `params` `""`
响应处理: createGetResponseFunction

### 46. `getBiWuFightTimes` (get)
参数: `func, isNeedWait, retryType`
URL: `get_fight_times2`
请求体: `""`
响应处理: createGetResponseFunction

### 47. `getBiWuFightYuanBao` (get)
参数: `type, func, isNeedWait, retryType`
URL: `get_fight_yuanbao/`
响应处理: createGetResponseFunction

### 48. `getChanllengeMsg` (get)
参数: `func, isNeedWait, retryType`
URL: `get_chanllenge_msg`
请求体: `""`
响应处理: createGetResponseFunction

### 49. `getCanGuanZhan` (get)
参数: `func, isNeedWait, retryType`
URL: `can_watch_fight`
请求体: `""`
响应处理: createGetResponseFunction

### 50. `getFightRewardList` (get)
参数: `func, isNeedWait, retryType`
URL: `get_fight_reward_list`
请求体: `""`
响应处理: createGetResponseFunction

### 51. `getFightSelfReward` (post)
参数: `params, func, isNeedWait, retryType`
URL: `get_fight_reward`
请求体: `params`
响应处理: createGetResponseFunction

### 52. `getFightWeekNotice` (get)
参数: `func, isNeedWait, retryType`
URL: `get_fight_reward_notice`
请求体: `""`
响应处理: createGetResponseFunction

### 53. `createAccount` (post)
参数: `userid, func, isNeedWait, retryType`
URL: `create_account`
请求体: `""`
响应处理: createGetResponseFunction

### 54. `uploadUselessUserData` (post)
参数: `roleData, func, isNeedWait, retryType`
URL: `upload_user_file_4`
请求体: `{roleData`
响应处理: createGetResponseFunction

### 55. `downloadUserDataTang` (get)
参数: `func, isNeedWait, retryType`
URL: `download_user_file_2`
请求体: `nil`
响应处理: createGetResponseFunction

### 56. `getEmailTang` (get)
参数: `func, isNeedWait, retryType`
URL: `get_email`
请求体: `""`
响应处理: createGetResponseFunction

### 57. `sendEmailTang` (post)
参数: `email, event_type, func, isNeedWait, retryType`
URL: `send_email`
请求体: `{email = email`
响应处理: createGetResponseFunction

### 58. `loginDevice` (post)
参数: `email, verify_code, func, isNeedWait, retryType`
URL: `login_device` `verify_code` `errcode`
请求体: `{verify_code = verify_code`
响应处理: createGetResponseFunction

### 59. `logoutDevice` (post)
参数: `email, verify_code, callback, isNeedWait, retryType`
URL: `logout_device`
请求体: `{verify_code = verify_code`
响应处理: createGetResponseFunction

### 60. `logoutUnbindDevice` (post)
参数: `callback, isNeedWait, retryType`
URL: `logout_device`
请求体: `nil`
响应处理: createGetResponseFunction

### 61. `bindDevice` (post)
参数: `emailAddr, code, func, isNeedWait, retryType`
URL: `bind_device`
请求体: `{email = emailAddr`
响应处理: createGetResponseFunction

### 62. `getBindInfo` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_bind_info`
请求体: `""`
响应处理: createGetResponseFunction

### 63. `sendVerifyCode` (post)
参数: `sendType, sendKey, eventType, callback, isNeedWait, retryType`
URL: `send_verify_code`
请求体: `{send_type = sendType`
响应处理: createGetResponseFunction

### 64. `bindDevice2` (post)
参数: `sendType, sendKey, verifyCode, callback, isNeedWait, retryType`
URL: `bind_device_2`
请求体: `{send_type = sendType`
响应处理: createGetResponseFunction

### 65. `sendPhoneVerifyCode` (post)
参数: `phone, callback, isNeedWait, retryType`
URL: `realname_send`
请求体: `{phone = phone}`
响应处理: createGetResponseFunction

### 66. `bindShiMingInfo` (post)
参数: `username, idcard, phone, code, callback, isNeedWait, retryType`
URL: `realname_auth`
请求体: `{username = username`
响应处理: createGetResponseFunction

### 67. `checkPaySign` (post)
参数: `key, callback, isNeedWait, retryType`
URL: `check_pay_sign`
请求体: `{key = key}`
响应处理: createGetResponseFunction

### 68. `checkActionPaySign` (post)
参数: `key, activityId, callback, isNeedWait, retryType`
说明: 江湖秘宝活动充值
URL: `check_pay_sign`
请求体: `{key = key`
响应处理: createGetResponseFunction

### 69. `checkJHMBActionPaySign` (post)
参数: `key, activityId,dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `check_pay_sign`
请求体: `{key = key`
响应处理: createGetResponseFunction

### 70. `upDayGameTime` (post)
参数: `time, callback, isNeedWait, retryType`
URL: `up_day_gametime`
请求体: `{time = time}`
响应处理: createGetResponseFunction

### 71. `loginDevice2` (post)
参数: `sendType, sendKey, verifyCode, callback, isNeedWait, retryType`
URL: `login_device_2`
请求体: `{send_type = sendType`
响应处理: createGetResponseFunction

### 72. `logoutDevice2` (post)
参数: `sendType, sendKey, verifyCode, callback, isNeedWait, retryType`
URL: `logout_device_2`
请求体: `{send_type = sendType`
响应处理: createGetResponseFunction

### 73. `logoutUnbindDevice2` (post)
参数: `callback, isNeedWait, retryType`
URL: `logout_device_2`
请求体: `nil`
响应处理: createGetResponseFunction

### 74. `getGameUserInfo` (post)
参数: `noticeId, currencyVersion,callback, isNeedWait, retryType`
URL: `get_game_user_info_2`
请求体: `{notice_version = noticeId`
响应处理: createGetResponseFunction

### 75. `getHistoryNotice` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_history_notice`
请求体: `nil`
响应处理: createGetResponseFunction

### 76. `CreateHeir` (post)
参数: `heirName, callback, isNeedWait, retryType`
说明: 传承
URL: `createNextRoleTask`
请求体: `{name = heirName}`
响应处理: createGetResponseFunction

### 77. `inherit` (post)
参数: `roleData, userId, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `finishNextRoleTask`
请求体: `{roleData = {roleData}`
响应处理: createGetResponseFunction

### 78. `getInheritHistoryRoleAttr` (post)
参数: `data, callback, isNeedWait, retryType`
URL: `get_chuanchen_user_info`
请求体: `data`
响应处理: createGetResponseFunction

### 79. `isOpenVisitTask` (get)
参数: `callback, isNeedWait, retryType`
URL: `is_visitor_shop_open`
请求体: `nil`
响应处理: createGetResponseFunction

### 80. `getMarketStoreList` (get)
参数: `callback, isNeedWait, retryType`
URL: `black_market_store`
请求体: `nil`
响应处理: createGetResponseFunction

### 81. `getSignList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_sign_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 82. `getSignPrize` (post)
参数: `trans_id, stringDate, itemId, homeland_open, callback, isNeedWait, retryType`
URL: `get_sign_prize`
请求体: `{trans_id = trans_id`
响应处理: createGetResponseFunction

### 83. `getSignHistoryPrize` (post)
参数: `trans_id, prizeId, callback, isNeedWait, retryType`
URL: `get_sign_history_prize`
请求体: `{trans_id = trans_id`
响应处理: createGetResponseFunction

### 84. `checkFailedNormalSign` (post)
参数: `trans_id, callback, isNeedWait, retryType`
URL: `check_failed_normal_sign`
请求体: `{trans_id = trans_id}`
响应处理: createGetResponseFunction

### 85. `getNewYearFestivalState` (get)
参数: `id, callback, isNeedWait, retryType`
URL: `get_spring_festival_status/`
响应处理: createGetResponseFunction

### 86. `getXianShiPoint` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_xianshilibao_gift_list_2`
请求体: `nil`
响应处理: createGetResponseFunction

### 87. `resetXianShiPoint` (post)
参数: `callback, isNeedWait, retryType`
URL: `reset_xianshilibao_points` `check_failed_history_sign`
请求体: `nil` `{trans_id = trans_id}`
响应处理: createGetResponseFunction

### 88. `testFastivalDate` (post)
参数: `productId, callback, isNeedWait, retryType`
URL: `init_test_festival_data`
请求体: `{key = productId}`
响应处理: createGetResponseFunction

### 89. `clearTestFestivalData` (post)
参数: `callback, isNeedWait, retryType`
URL: `clean_test_festival_data`
请求体: `nil`
响应处理: createGetResponseFunction

### 90. `getFestivalOrderId` (post)
参数: `orderType, orderInfo, callback, isNeedWait, retryType`
URL: `get_order_id/`
响应处理: createGetResponseFunction

### 91. `rollBackOrderStatus` (post)
参数: `orderType, orderid, orderInfo, callback, isNeedWait, retryType`
URL: `rollback_order_status/`
响应处理: createGetResponseFunction

### 92. `getFirstFestivalGiftList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_first_festival_gift`
请求体: `nil`
响应处理: createGetResponseFunction

### 93. `getFirstFestivalGift` (post)
参数: `orderid, callback, isNeedWait, retryType`
URL: `receive_first_festival_gift`
请求体: `{order_id = orderid`
响应处理: createGetResponseFunction

### 94. `getMultiFestivalGiftList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_multi_festival_gift_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 95. `getMultiFestivalGift` (post)
参数: `kry, orderid, itemId, callback, isNeedWait, retryType`
URL: `receive_multi_festival_gift`
请求体: `{key = kry`
响应处理: createGetResponseFunction

### 96. `getSpringFestivalList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_spring_festival_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 97. `getZhiZuoZuRoleList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_npc_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 98. `addZhiZuoZuNpcRecord` (get)
参数: `npcId, callback, isNeedWait, retryType`
URL: `add_npc_record/`
响应处理: createGetResponseFunction

### 99. `getMaskList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_mask_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 100. `refreshMaskList` (post)
参数: `orderid, callback, isNeedWait, retryType`
URL: `refresh_mask_list`
请求体: `{order_id = orderid}`
响应处理: createGetResponseFunction

### 101. `buyMaskPiece` (post)
参数: `orderid, id, callback, isNeedWait, retryType`
URL: `buy_mask_piece_2`
请求体: `{order_id = orderid`
响应处理: createGetResponseFunction

### 102. `getDailyPoint` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_daily_point`
请求体: `nil`
响应处理: createGetResponseFunction

### 103. `updateDailyPoint` (post)
参数: `id, point, callback, isNeedWait, retryType`
URL: `update_daily_point/`
响应处理: createGetResponseFunction

### 104. `getDailyBoard` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_daily_board`
请求体: `nil`
响应处理: createGetResponseFunction

### 105. `getLongZhouDailyBoard` (get)
参数: `type, callback, isNeedWait, retryType`
URL: `get_boat_board/`
响应处理: createGetResponseFunction

### 106. `getBuyOrderId` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_buy_order_id`
请求体: `nil`
响应处理: createGetResponseFunction

### 107. `getAllTypePoint` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_all_type_point` `get_daily_board`
请求体: `nil`
响应处理: createGetResponseFunction

### 108. `getDailyNotice` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_daily_Notice`
请求体: `nil`
响应处理: createGetResponseFunction

### 109. `getDailyRewardList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_daily_reward_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 110. `getDailyReward` (post)
参数: `transid, callback, isNeedWait, retryType`
URL: `get_daily_reward`
请求体: `{trans_id = transid}`
响应处理: createGetResponseFunction

### 111. `rollDailyReward` (get)
参数: `callback, isNeedWait, retryType`
URL: `roll_daily_reward`
请求体: `nil`
响应处理: createGetResponseFunction

### 112. `getEventList` (post)
参数: `type, currencyVersion, callback, isNeedWait, retryType`
URL: `get_activity_list`
请求体: `{type = type`
响应处理: createGetResponseFunction

### 113. `delActivityCache` (get)
参数: `callback, isNeedWait, retryType`
URL: `del_activity_cache` `errcode` `dev_point`
请求体: `nil`
响应处理: createGetResponseFunction

### 114. `getDevotePoint` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_devote_point` `errcode` `msg` `errmsg`
请求体: `nil`
响应处理: createGetResponseFunction

### 115. `addDevotePoint` (post)
参数: `ptype, point, callback, isNeedWait, retryType`
URL: `add_devote_point` `errcode` `id` `itemId` `leidongjiutian`
请求体: `{type = ptype`
响应处理: createGetResponseFunction

### 116. `getDevoteList` (post)
参数: `dtype, menpai, callback, isNeedWait, retryType`
URL: `get_devote_list` `huakaibingdicanye` `tiyunzongcanye` `errcode` `id`
请求体: `{type = dtype`
响应处理: createGetResponseFunction

### 117. `getDevoteListByYuanbao` (post)
参数: `dtype, orderid, menpai, callback, isNeedWait, retryType`
URL: `get_devote_list_by_yuanbao` `huakaibingdicanye` `tiyunzongcanye` `order_id` `points`
请求体: `{order_id = orderid` `nil`
响应处理: createGetResponseFunction

### 118. `updateMenpaiGongxiangdian` (post)
参数: `orderid, itemId, points, info, callback, isNeedWait, retryType`
URL: `update_menpai_gongxiangdian`
请求体: `{order_id = orderid`
响应处理: createGetResponseFunction

### 119. `getChapmanItemList` (get)
参数: `npcId, callback, isNeedWait, retryType`
URL: `trader_store/`
响应处理: createGetResponseFunction

### 120. `buyChapmanItem` (post)
参数: `npcId, itemId, transid, voucherNum, callback, isNeedWait, retryType`
URL: `buy_trader_goods`
请求体: `{npc_id = npcId`
响应处理: createGetResponseFunction

### 121. `addChapmanItemCount` (post)
参数: `npcId, itemId, callback, isNeedWait, retryType`
URL: `del_buy_npc_time`
请求体: `{npc_id = npcId`
响应处理: createGetResponseFunction

### 122. `addDeadCurrency` (post)
参数: `id, number, isNeed, callback, isNeedWait, retryType`
URL: `add_user_mingbi`
请求体: `{type = id`
响应处理: createGetResponseFunction

### 123. `getDeadCurrencyGoodsList` (post)
参数: `callback, isNeedWait, retryType`
URL: `get_mingbi_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 124. `buyDeadCurrencyGoods` (post)
参数: `orderid, id, callback, isNeedWait, retryType`
URL: `buy_mingbi_goods`
请求体: `{order_id = orderid`
响应处理: createGetResponseFunction

### 125. `getHelpDocument` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_help_document`
请求体: `nil`
响应处理: createGetResponseFunction

### 126. `getVoucherPrize` (post)
参数: `voucherId, activityId, callback, isNeedWait, retryType`
URL: `get_voucher_prize_2`
请求体: `{voucher = voucherId`
响应处理: createGetResponseFunction

### 127. `cleanVoucherRecord` (get)
参数: `callback, isNeedWait, retryType`
URL: `clean_voucher_record_2`
请求体: `nil`
响应处理: createGetResponseFunction

### 128. `checkCanExam` (get)
参数: `id, callback, isNeedWait, retryType`
URL: `check_whether_exam/`
响应处理: createGetResponseFunction

### 129. `updateExamPoint` (post)
参数: `id, rightCount, point, time, skillExp, cheat, callback, isNeedWait, retryType`
URL: `upload_exam_point`
请求体: `{type = id`
响应处理: createGetResponseFunction

### 130. `getExamPoint` (get)
参数: `id, callback, isNeedWait, retryType`
URL: `get_exam_point/`
响应处理: createGetResponseFunction

### 131. `generateExamReward` (get)
参数: `id, callback, isNeedWait, retryType`
URL: `crontab_gen_exam_reward/`
响应处理: createGetResponseFunction

### 132. `getExamReward` (post)
参数: `id, orderid, callback, isNeedWait, retryType`
URL: `get_exam_reward`
请求体: `{trans_id = orderid`
响应处理: createGetResponseFunction

### 133. `delUserRankReward` (get)
参数: `callback, isNeedWait, retryType`
URL: `delete_user_point_rank`
请求体: `nil`
响应处理: createGetResponseFunction

### 134. `delUserPoint` (get)
参数: `callback, isNeedWait, retryType`
URL: `delete_user_point`
请求体: `nil`
响应处理: createGetResponseFunction

### 135. `getUserOfficial` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_user_guanzhi`
请求体: `nil`
响应处理: createGetResponseFunction

### 136. `getChenHao` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_user_designation`
请求体: `nil`
响应处理: createGetResponseFunction

### 137. `getFenLu` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_guanzhi_fenlu`
请求体: `nil`
响应处理: createGetResponseFunction

### 138. `uploadOfficialAchievement` (post)
参数: `zhengji, guanzhi, callback, isNeedWait, retryType`
URL: `upload_zhengji`
请求体: `{zhengji = zhengji`
响应处理: createGetResponseFunction

### 139. `officialResignation` (get)
参数: `callback, isNeedWait, retryType`
URL: `delete_my_guanzhi`
请求体: `nil`
响应处理: createGetResponseFunction

### 140. `delOfficialLimit` (get)
参数: `callback, isNeedWait, retryType`
URL: `delete_ciguan_redis`
请求体: `nil`
响应处理: createGetResponseFunction

### 141. `delExamAllData` (get)
参数: `callback, isNeedWait, retryType`
URL: `delete_all_data`
请求体: `nil`
响应处理: createGetResponseFunction

### 142. `calaOfficialAchievement` (get)
参数: `callback, isNeedWait, retryType`
URL: `crontab_count_zhengji` `get_daily_reward_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 143. `getPersonalBoatScore` (post)
参数: `familyId, callback, isNeedWait, retryType`
URL: `personal_boat_msg`
请求体: `{menpai = familyId}`
响应处理: createGetResponseFunction

### 144. `getAllFamilyScore` (get)
参数: `callback, isNeedWait, retryType`
URL: `all_menpai_top`
请求体: `nil`
响应处理: createGetResponseFunction

### 145. `getBoatRewardList` (get)
参数: `callback, isNeedWait, retryType`
URL: `can_get_duanwu_reward`
请求体: `nil`
响应处理: createGetResponseFunction

### 146. `getBoatReward` (post)
参数: `transid, itype, callback, isNeedWait, retryType`
URL: `get_boat_reward`
请求体: `{trans_id = transid`
响应处理: createGetResponseFunction

### 147. `getDuanwuRewardNotice` (get)
参数: `type, callback, isNeedWait, retryType`
URL: `get_duanwu_reward_notice/`
响应处理: createGetResponseFunction

### 148. `checkCanJoinDragonBoat` (get)
参数: `callback, isNeedWait, retryType`
URL: `check_can_play_boat`
请求体: `nil`
响应处理: createGetResponseFunction

### 149. `updateDragonBoatPoint` (post)
参数: `menpai, point, time, callback, isNeedWait, retryType`
URL: `update_boat_point`
请求体: `{menpai = menpai`
响应处理: createGetResponseFunction

### 150. `resetDuanWuReward` (get)
参数: `callback, isNeedWait, retryType`
URL: `test_reset_my_reward`
请求体: `nil`
响应处理: createGetResponseFunction

### 151. `getRankingListByOne` (post)
参数: `id, callback, isNeedWait, retryType`
URL: `get_board/`
响应处理: createGetResponseFunction

### 152. `getJhSanYouList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_jhsanyou_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 153. `voteToJhsanyou` (post)
参数: `type, id, callback, isNeedWait, retryType`
URL: `vote_to_jhsanyou`
请求体: `{itype = type`
响应处理: createGetResponseFunction

### 154. `clearApiData` (post)
参数: `str, callback, isNeedWait, retryType`
URL: `clear_api_data`
请求体: `{act = str}`
响应处理: createGetResponseFunction

### 155. `getShopInfo` (post)
参数: `shopId, callback, isNeedWait, retryType`
URL: `get_shop_info`
请求体: `{shop_id = shopId}`
响应处理: createGetResponseFunction

### 156. `shopExchangeGoods` (post)
参数: `tab, callback, isNeedWait, retryType`
URL: `shop_exchange_goods`
请求体: `tab`
响应处理: createGetResponseFunction

### 157. `rollBackExchage` (post)
参数: `transid, callback, isNeedWait, retryType`
URL: `roll_back_exchange` `zhounianqin1`
请求体: `{client_trans_id = transid}`
响应处理: createGetResponseFunction

### 158. `addCurrency` (post)
参数: `tab, callback, isNeedWait, retryType`
URL: `add_currency`
请求体: `tab`
响应处理: createGetResponseFunction

### 159. `clearShopRecord` (post)
参数: `shopId, callback, isNeedWait, retryType`
URL: `clear_my_shop_record`
请求体: `{shop_id = shopId}`
响应处理: createGetResponseFunction

### 160. `addActivityPoint` (post)
参数: `point, activityId, callback, isNeedWait, retryType`
URL: `add_currency`
请求体: `{number = point`
响应处理: createGetResponseFunction

### 161. `clearPointRecord` (post)
参数: `activityId, callback, isNeedWait, retryType`
URL: `clear_my_shop_record` `act` `keyao` `id` `tiaoxi`
请求体: `{shop_id = activityId}`
响应处理: createGetResponseFunction

### 162. `addRecordCount` (post)
参数: `stat_data, callback, isNeedWait, retryType`
URL: `upload_fzjh_stat`
请求体: `{stat_data = stat_data}`
响应处理: createGetResponseFunction

### 163. `getServerList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_partition_list`
请求体: `""`
响应处理: createGetResponseFunction

### 164. `migrateToNewPackage` (post)
参数: `email, code, callback, isNeedWait, retryType`
URL: `migrate_to_new_package`
请求体: `{email = email`
响应处理: createGetResponseFunction

### 165. `switchServer` (get)
参数: `id, callback, isNeedWait, retryType`
URL: `switch_partition/`
响应处理: createGetResponseFunction

### 166. `getServerList2` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_partition_list2`
请求体: `""`
响应处理: createGetResponseFunction

### 167. `switchServer2` (get)
参数: `id, callback, isNeedWait, retryType`
URL: `switch_partition2/`
响应处理: createGetResponseFunction

### 168. `migrateToNewPackage2` (post)
参数: `email, code, serverId, callback, isNeedWait, retryType`
URL: `migrate_to_new_package2`
请求体: `{email = email`
响应处理: createGetResponseFunction

### 169. `partitionClear` (get)
参数: `callback, isNeedWait, retryType`
URL: `partition_clear`
请求体: `""`
响应处理: createGetResponseFunction

### 170. `testReceiveAnniversaryReward` (get)
参数: `date, callback, isNeedWait, retryType`
URL: `test_receive_anniversary_reward/`
响应处理: createGetResponseFunction

### 171. `resetAnniversaryRewardList` (get)
参数: `callback, isNeedWait, retryType`
URL: `reset_anniversary_reward_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 172. `getAnniversaryRewardList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_anniversary_reward_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 173. `getAnniversaryReward` (post)
参数: `rewardList, callback, isNeedWait, retryType`
URL: `get_anniversary_reward`
请求体: `{list = rewardList}`
响应处理: createGetResponseFunction

### 174. `getUserUploadInfo` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_user_upload_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 175. `saveUserInfo` (post)
参数: `phoneStr, addrStr, nameStr, qqStr, callback, isNeedWait, retryType`
URL: `save_user_info`
请求体: `{phone = phoneStr`
响应处理: createGetResponseFunction

### 176. `addMoneyCeiling` (post)
参数: `money, callback, isNeedWait, retryType`
URL: `add_money_ceiling`
请求体: `{number = money}`
响应处理: createGetResponseFunction

### 177. `getTeacherTaskPointList` (post)
参数: `posList, callback, isNeedWait, retryType`
URL: `get_same_menpai_user_list`
请求体: `posList`
响应处理: createGetResponseFunction

### 178. `addTeacherTaskRecord` (post)
参数: `posList, callback, isNeedWait, retryType`
URL: `add_zhipai_task_record`
请求体: `posList`
响应处理: createGetResponseFunction

### 179. `getTeacherTaskRecord` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_zhipai_task_record`
请求体: `nil`
响应处理: createGetResponseFunction

### 180. `getTeacherTaskRewaard` (post)
参数: `rewardId, callback, isNeedWait, retryType`
URL: `get_zhipai_task_reward`
请求体: `{reward_id = rewardId}`
响应处理: createGetResponseFunction

### 181. `refreshTeacherTaskList` (post)
参数: `count, callback, isNeedWait, retryType`
URL: `fresh_task_by_yuanbao`
请求体: `{yuanbao = count}`
响应处理: createGetResponseFunction

### 182. `resetTeacherTask` (get)
参数: `type, callback, isNeedWait, retryType`
URL: `test_reset_task/`
响应处理: createGetResponseFunction

### 183. `getWishList2` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_wish_list/2`
请求体: `nil`
响应处理: createGetResponseFunction

### 184. `getWishList1` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_wish_list/1`
请求体: `nil`
响应处理: createGetResponseFunction

### 185. `uploadWishData` (post)
参数: `wishVal, wishType, wishId, callback, isNeedWait, retryType`
URL: `upload_wish_data`
请求体: `{wish_val = wishVal`
响应处理: createGetResponseFunction

### 186. `recordWishedData` (post)
参数: `recordId, wishUserId, callback, isNeedWait, retryType`
URL: `record_wished_data`
请求体: `{record_id = recordId`
响应处理: createGetResponseFunction

### 187. `getSeventhReward1` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_seventh_reward/1`
请求体: `nil`
响应处理: createGetResponseFunction

### 188. `getSeventhReward2` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_seventh_reward/2`
请求体: `nil`
响应处理: createGetResponseFunction

### 189. `findRoommate` (post)
参数: `roommateId, roomId, callback, isNeedWait, retryType`
URL: `find_roommate`
请求体: `{roommate_id = roommateId`
响应处理: createGetResponseFunction

### 190. `TestWish1` (get)
参数: `callback, isNeedWait, retryType`
URL: `test_wish/1`
请求体: `nil`
响应处理: createGetResponseFunction

### 191. `TestWish3` (get)
参数: `callback, isNeedWait, retryType`
URL: `test_wish/3`
请求体: `nil`
响应处理: createGetResponseFunction

### 192. `TestWish4` (get)
参数: `callback, isNeedWait, retryType`
URL: `test_wish/4`
请求体: `nil`
响应处理: createGetResponseFunction

### 193. `TestWish5` (get)
参数: `callback, isNeedWait, retryType`
URL: `test_wish/5`
请求体: `nil`
响应处理: createGetResponseFunction

### 194. `resetActiveTask` (get)
参数: `type, callback, isNeedWait, retryType`
URL: `add_record/`
响应处理: createGetResponseFunction

### 195. `getYuanBaoCostGiftList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_yuanbao_plan_gift_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 196. `receiveYuanBaoPlanGift` (post)
参数: `rid, isEmail, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `receive_yuanbao_plan_gift`
请求体: `{rid = rid`
响应处理: createGetResponseFunction

### 197. `testWish` (get)
参数: `num, callback, isNeedWait, retryType`
URL: `test_wish/`
响应处理: createGetResponseFunction

### 198. `countSingleRecordWithType` (get)
参数: `type, callback, isNeedWait, retryType`
URL: `count_single_record/`
响应处理: createGetResponseFunction

### 199. `getPlayGhost` (post)
参数: `callback, isNeedWait, retryType`
URL: `get_random_userdata` `update_currency_by_type` `add`
请求体: `nil` `{currency = list`
响应处理: createGetResponseFunction

### 200. `viewCurrencyByType` (post)
参数: `currency_type, currencyVersion,callback, isNeedWait, retryType`
URL: `view_currency_by_type`
请求体: `{currency_type = currency_type`
响应处理: createGetResponseFunction

### 201. `addCurrencyByType` (post)
参数: `num, callback, isNeedWait, retryType`
URL: `add_currency_by_type`
请求体: `{currency = {mingbi = num}}`
响应处理: createGetResponseFunction

### 202. `joinGhostTimes` (get)
参数: `callback, isNeedWait, retryType`
URL: `count_single_record/join_ghost`
请求体: `nil`
响应处理: createGetResponseFunction

### 203. `finishGhostTimes` (get)
参数: `callback, isNeedWait, retryType`
URL: `count_single_record/finish_ghost`
请求体: `nil`
响应处理: createGetResponseFunction

### 204. `updateCurrencyByType` (post)
参数: `action, cType, count, addType, callback, isNeedWait, retryType`
URL: `update_currency_by_type`
请求体: `{action = action`
响应处理: createGetResponseFunction

### 205. `updateCurrencyByTable` (post)
参数: `action, list, addType, callback, isNeedWait, retryType`
URL: `update_currency_by_type`
请求体: `{action = action`
响应处理: createGetResponseFunction

### 206. `getTeacherTaskShop` (post)
参数: `getType, familyId, callback, isNeedWait, retryType`
URL: `get_teacher_shop`
请求体: `{type = getType`
响应处理: createGetResponseFunction

### 207. `buyTeacherTaskShopItem` (post)
参数: `id, callback, isNeedWait, retryType`
说明: 添加单条记录
URL: `buy_teacher_good`
请求体: `{rid = id}`
响应处理: createGetResponseFunction

### 208. `addSingleRecord` (post)
参数: `type, callback, isNeedWait, retryType`
说明: 添加多条记录
URL: `addSingleRecord`
请求体: `type`
响应处理: createGetResponseFunction

### 209. `countMultiRecord` (post)
参数: `type, callback, isNeedWait, retryType`
说明: 上传内挂数据
URL: `count_multi_record`
请求体: `type`
响应处理: createGetResponseFunction

### 210. `uploadClientData` (post)
参数: `type, data, callback, isNeedWait, retryType`
说明: 查询数据
URL: `upload_client_data`
请求体: `{type = type`
响应处理: createGetResponseFunction

### 211. `getClientData` (post)
参数: `tb, callback, isNeedWait, retryType`
说明: 删除数据库对应标识的数据
URL: `get_client_data`
请求体: `{type = tb.type`
响应处理: createGetResponseFunction

### 212. `delAllData` (post)
参数: `type, callback, isNeedWait, retryType`
URL: `del_all_data`
请求体: `{type = type}`
响应处理: createGetResponseFunction

### 213. `getBiWuFightEnd` (get)
参数: `func, isNeedWait, retryType`
URL: `get_out_fight_stage` `add_record/lunjian`
请求体: `""`
响应处理: createGetResponseFunction

### 214. `getActionState` (post)
参数: `id, postList, callback, isNeedWait, retryType`
URL: `get_game_activity/`
响应处理: createGetResponseFunction

### 215. `updateOrderState` (post)
参数: `callback, isNeedWait, retryType`
URL: `api/v5/` `api/service/` `update_order_state`
响应处理: createGetResponseFunction

### 216. `getXianShiGiftBag` (get)
参数: `itemId, callback, isNeedWait, retryType`
URL: `get_limit_package/`
响应处理: createGetResponseFunction

### 217. `getToken` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_token`
请求体: `nil`
响应处理: createGetResponseFunction

### 218. `resetDailyRecord` (get)
参数: `callback, isNeedWait, retryType`
说明: 神兵淬炼接口
URL: `resetDailyRecord/1`
请求体: `nil`
响应处理: createGetResponseFunction

### 219. `incrWeaponCuilianNum` (post)
参数: `wid, results, cuilianCount, callback, isNeedWait, retryType`
说明: 筛除单条数据
URL: `incr_weapon_cuilian_num`
请求体: `{wid = wid`
响应处理: createGetResponseFunction

### 220. `updateDataState` (post)
参数: `tb, callback, isNeedWait, retryType`
URL: `update_data_state`
请求体: `{id = tb.id`
响应处理: createGetResponseFunction

### 221. `getWeaponCuilianNum` (post)
参数: `wid, itemId, callback, isNeedWait, retryType`
URL: `get_weapon_cuilian_num` `errcode` `add_point` `total_count` `errmsg`
请求体: `{wid = wid`
响应处理: createGetResponseFunction

### 222. `respectTeacher` (get)
参数: `callback, isNeedWait, retryType`
URL: `respect_teacher`
请求体: `nil`
响应处理: createGetResponseFunction

### 223. `resetDailyRecord` (get)
参数: `callback, isNeedWait, retryType`
URL: `resetDailyRecord/1`
请求体: `nil`
响应处理: createGetResponseFunction

### 224. `deleteClientData` (post)
参数: `delType, callback, isNeedWait, retryType`
URL: `del_data_by_type`
请求体: `{type = delType}`
响应处理: createGetResponseFunction

### 225. `getSpendPlanGiftList` (get)
参数: `actionId, callback, isNeedWait, retryType`
URL: `get_spend_plan_gift_list/`
响应处理: createGetResponseFunction

### 226. `receiveSpendPlanGiftList` (post)
参数: `actionId, num, callback, isNeedWait, retryType`
URL: `receive_spend_plan_gift_list/`
响应处理: createGetResponseFunction

### 227. `getActionSpendInfo` (get)
参数: `actionId, callback, isNeedWait, retryType`
URL: `get_spend_info/`
响应处理: createGetResponseFunction

### 228. `resetSpendPlanGiftList` (get)
参数: `flag, callback, isNeedWait, retryType`
URL: `test_spend_plan/`
响应处理: createGetResponseFunction

### 229. `getLoginRewardInfo` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_login_reward_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 230. `getLoginYuanbao` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_login_yuanbao`
请求体: `nil`
响应处理: createGetResponseFunction

### 231. `deleteLoginYuanbaoCache` (get)
参数: `callback, isNeedWait, retryType`
URL: `delete_login_yuanbao_cache`
请求体: `nil`
响应处理: createGetResponseFunction

### 232. `addSpendPlanGiftList` (get)
参数: `flag, actionType, num, callback, isNeedWait, retryType`
URL: `test_spend_plan/`
响应处理: createGetResponseFunction

### 233. `getPayLotteryGiftList` (post)
参数: `is_refresh, callback, isNeedWait, retryType`
URL: `get_lottery_list`
请求体: `{is_refresh = is_refresh}`
响应处理: createGetResponseFunction

### 234. `getPayLotteryGift` (post)
参数: `order_id, callback, isNeedWait, retryType`
URL: `do_lottery`
请求体: `{order_id = order_id}`
响应处理: createGetResponseFunction

### 235. `getShareLink` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_share_link`
请求体: `nil`
响应处理: createGetResponseFunction

### 236. `doShare` (get)
参数: `callback, isNeedWait, retryType`
URL: `do_share`
请求体: `nil`
响应处理: createGetResponseFunction

### 237. `bePutCkItems` (post)
参数: `itemData, ckName, ver, callback, isNeedWait, retryType`
URL: `beput_ckitems`
请求体: `{itemId = itemId`
响应处理: createGetResponseFunction

### 238. `outGoingCkItems` (post)
参数: `itemData, ckName, ver, callback, isNeedWait, retryType`
URL: `outgoing_ckitems`
请求体: `{itemId = itemId`
响应处理: createGetResponseFunction

### 239. `getCkItemsList` (post)
参数: `ckName, localVer, callback, isNeedWait, retryType`
说明: 获取对方仓储ID
-- function HttpManager:getCkitemsListByUid(ckName,uid,callback, isNeedWait, retryType)
--     callback = self:createGetResponseFunction(callback)
--     self:retryPostWithHeader(DOMAIN.."get
URL: `get_ckitems_list` `get_ckitems_list_by_uid`
请求体: `{ckname = ckName`
响应处理: createGetResponseFunction

### 240. `delCkItems` (post)
参数: `ckName, callback, isNeedWait, retryType`
URL: `del_ckitems`
请求体: `{ckname = ckName}`
响应处理: createGetResponseFunction

### 241. `getNewNpcChapmanItemList` (get)
参数: `npcId, callback, isNeedWait, retryType`
URL: `get_npc_store_list/`
响应处理: createGetResponseFunction

### 242. `buyNewNpcChapmanItem` (post)
参数: `npcId, itemId, transid, couponsId, callback, isNeedWait, retryType`
URL: `buy_npc_goods`
请求体: `{client_trans_id = transid`
响应处理: createGetResponseFunction

### 243. `exchangeYinPiao` (post)
参数: `number, type, callback, isNeedWait, retryType`
URL: `exchange_yinpiao`
请求体: `{number = number`
响应处理: createGetResponseFunction

### 244. `renameHome` (post)
参数: `mid, new_name, point, callback, isNeedWait, retryType`
URL: `rename_home`
请求体: `{mid = mid`
响应处理: createGetResponseFunction

### 245. `getLocationMap` (post)
参数: `loc_mark, callback, isNeedWait, retryType`
说明: 获取购房列表
URL: `get_location_map`
请求体: `{loc_mark = loc_mark}`
响应处理: createGetResponseFunction

### 246. `getHouseStoreList` (post)
参数: `npcId, is_refresh, callback, isNeedWait, retryType`
URL: `get_house_store_list`
请求体: `{npcId = npcId`
响应处理: createGetResponseFunction

### 247. `buyHomeland` (post)
参数: `npcId, fqId, callback, isNeedWait, retryType`
URL: `buy_homeland`
请求体: `{npcId = npcId`
响应处理: createGetResponseFunction

### 248. `getLandStoreList` (post)
参数: `fbId, npcId, callback, isNeedWait, retryType`
URL: `get_land_store_list`
请求体: `{fbId = fbId`
响应处理: createGetResponseFunction

### 249. `biddingLand` (post)
参数: `dpId, npcId, price, callback, isNeedWait, retryType`
URL: `bidding_land`
请求体: `{dpId = dpId`
响应处理: createGetResponseFunction

### 250. `getbiddingLand` (post)
参数: `dpId, callback, isNeedWait, retryType`
URL: `get_bidding_land`
请求体: `{dpId = dpId}`
响应处理: createGetResponseFunction

### 251. `querybiddingInfo` (get)
参数: `callback, isNeedWait, retryType`
URL: `query_bidding_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 252. `moveHomeland` (post)
参数: `dpId, mid, callback, isNeedWait, retryType`
URL: `move_home_land`
请求体: `{dpId = dpId`
响应处理: createGetResponseFunction

### 253. `getBiddingReturnPoint` (post)
参数: `dpId, callback, isNeedWait, retryType`
说明: 放入家具
URL: `get_bidding_return_point`
请求体: `{dpId = dpId}`
响应处理: createGetResponseFunction

### 254. `putinFurniture` (post)
参数: `mid, roomId, furnitureId, extra, localVer, callback, isNeedWait, retryType`
URL: `putin_furniture`
请求体: `{mid = mid`
响应处理: createGetResponseFunction

### 255. `removeFurniture` (post)
参数: `mid, fid, localVer, callback, isNeedWait, retryType`
URL: `remove_furniture`
请求体: `{mid = mid`
响应处理: createGetResponseFunction

### 256. `getUserMap` (post)
参数: `mapId, userid, localVer, callback, isNeedWait, retryType`
URL: `get_user_map`
请求体: `{mid = mapId`
响应处理: createGetResponseFunction

### 257. `getCommonFuben` (post)
参数: `mapId, callback, isNeedWait, retryType`
URL: `get_common_fuben`
请求体: `{fbId = mapId}`
响应处理: createGetResponseFunction

### 258. `saveEmployeeList` (post)
参数: `type, npcId, list, callback, isNeedWait, retryType`
URL: `save_employee_list`
请求体: `{type = type`
响应处理: createGetResponseFunction

### 259. `getEmployList` (get)
参数: `npcId, mid, callback, isNeedWait, retryType`
URL: `get_employee_list/`
响应处理: createGetResponseFunction

### 260. `addEmployee` (post)
参数: `hid, objId, mid, npcId, push_data, callback, isNeedWait, retryType`
URL: `add_employee`
请求体: `{hid = hid`
响应处理: createGetResponseFunction

### 261. `getEmployRoleData` (post)
参数: `objId, mid, callback, isNeedWait, retryType`
URL: `get_employee_data`
请求体: `{objId = objId`
响应处理: createGetResponseFunction

### 262. `updateEmployRoleData` (post)
参数: `objId, mid, zc_type, zc_val, currency, callback, isNeedWait, retryType`
URL: `update_employee_data`
请求体: `{objId = objId`
响应处理: createGetResponseFunction

### 263. `deleteEmployee` (post)
参数: `objId, mid, callback, isNeedWait, retryType`
URL: `delete_employee`
请求体: `{objId = objId`
响应处理: createGetResponseFunction

### 264. `transformRoom` (post)
参数: `fjId, mid, attr, point, upload, callback, isNeedWait, retryType`
URL: `transform_room`
请求体: `{fjId = fjId`
响应处理: createGetResponseFunction

### 265. `roomExtension` (post)
参数: `mid, attr, point, upload, callback, isNeedWait, retryType`
URL: `extension_room`
请求体: `{mid = mid`
响应处理: createGetResponseFunction

### 266. `restoreUserMap` (post)
参数: `mid, callback, isNeedWait, retryType`
说明: 更新家园相关数据
URL: `restore_user_map` `remove_room`
请求体: `{mid = mid}` `{mid = mid`
响应处理: createGetResponseFunction

### 267. `updateHomeAttr` (post)
参数: `mid, fj_update, pr_update, jj_update, cost, callback, isNeedWait, retryType`
URL: `update_home_attr` `yinpiao`
请求体: `{mid = mid`
响应处理: createGetResponseFunction

### 268. `getAffairList` (post)
参数: `bizType, mid, limit, callback, isNeedWait, retryType`
URL: `get_affair_list/`
响应处理: createGetResponseFunction

### 269. `pushAffair` (post)
参数: `affairTb, callback, isNeedWait, retryType`
URL: `push_affair`
请求体: `affairTb`
响应处理: createGetResponseFunction

### 270. `processRoomAffair` (post)
参数: `aid, deal_type, process_type, callback, isNeedWait, retryType`
说明: 处理发薪事务
URL: `process_affair`
请求体: `{aid = aid`
响应处理: createGetResponseFunction

### 271. `processPayAffairs` (post)
参数: `aids, callback, isNeedWait, retryType`
URL: `process_pay_affairs`
请求体: `{aids = aids}`
响应处理: createGetResponseFunction

### 272. `upgrandeUserMap` (post)
参数: `mid, new_fqId, yinpiao_num, callback, isNeedWait, retryType`
说明: 获取指定UID的仓库信息
URL: `upgrande_user_map`
请求体: `{mid = mid`
响应处理: createGetResponseFunction

### 273. `getCkItemsListByUid` (post)
参数: `uid, ckname, callback, isNeedWait, retryType`
说明: 修改房间的相关属性
URL: `get_ckitems_list_by_uid`
请求体: `{uid = uid`
响应处理: createGetResponseFunction

### 274. `revampRoomAttr` (post)
参数: `fjId, mid, attr, callback, isNeedWait, retryType`
说明: 获取欠了多少管理费
URL: `revamp_room_attr`
请求体: `{fjId = fjId`
响应处理: createGetResponseFunction

### 275. `getManagePayment` (get)
参数: `dpId, callback, isNeedWait, retryType`
说明: 上传特殊家具的一些属性（目前只有悬兵洞、藏衣阁使用）
URL: `get_manage_payment/`
响应处理: createGetResponseFunction

### 276. `uploadFurnitureExtra` (post)
参数: `mid, attr, callback, isNeedWait, retryType`
URL: `upload_furniture_extra`
请求体: `{mid = mid`
响应处理: createGetResponseFunction

### 277. `recycleLand` (post)
参数: `dpId, callback, isNeedWait, retryType`
URL: `recycle_land`
请求体: `{dpId = dpId}`
响应处理: createGetResponseFunction

### 278. `updateEmployeeExtra` (post)
参数: `mid, up_data, callback, isNeedWait, retryType`
URL: `update_employee_extra`
请求体: `{mid = mid`
响应处理: createGetResponseFunction

### 279. `testHomeland` (post)
参数: `type, tb, callback, isNeedWait, retryType`
说明: 测试接口，设置地皮过期时间
URL: `test_homeland/`
响应处理: createGetResponseFunction

### 280. `setAuctionTime` (post)
参数: `time, callback, isNeedWait, retryType`
说明: 上传副本的额外属性。
URL: `set_auction_time`
请求体: `{time = time}`
响应处理: createGetResponseFunction

### 281. `uploadMapExtra` (post)
参数: `mid, attr, point, callback, isNeedWait, retryType`
URL: `upload_map_extra`
请求体: `{mid = mid`
响应处理: createGetResponseFunction

### 282. `getLocationMax` (get)
参数: `mapIndex, callback, isNeedWait, retryType`
URL: `get_location_max/`
响应处理: createGetResponseFunction

### 283. `getShenShiReward` (post)
参数: `type, objId, mid, up_data, callback, isNeedWait, retryType`
URL: `get_shenshi_reward`
请求体: `{type = type`
响应处理: createGetResponseFunction

### 284. `exchangeLuckyPoint` (post)
参数: `itemId, callback, isNeedWait, retryType`
说明: 获取自己的房间信息
URL: `exchange_lucky_point`
请求体: `{itemId = itemId}`
响应处理: createGetResponseFunction

### 285. `getAllRooms` (post)
参数: `mid, roomType, callback, isNeedWait, retryType`
URL: `get_all_rooms`
请求体: `{mid = mid`
响应处理: createGetResponseFunction

### 286. `getAllPersons` (post)
参数: `mid, jobType, callback, isNeedWait, retryType`
URL: `get_all_persons`
请求体: `{mid = mid`
响应处理: createGetResponseFunction

### 287. `getLuckyGoods` (post)
参数: `refresh, callback, isNeedWait, retryType`
URL: `get_lucky_goods`
请求体: `{is_refresh = refresh}`
响应处理: createGetResponseFunction

### 288. `buyLuckyGoods` (post)
参数: `itemId, id, callback, isNeedWait, retryType`
URL: `buy_lucky_goods`
请求体: `{itemId = itemId`
响应处理: createGetResponseFunction

### 289. `getQiXiRecord` (get)
参数: `callback, isNeedWait, retryType`
说明: 上传七夕数据
URL: `get_qixi_record`
请求体: `nil`
响应处理: createGetResponseFunction

### 290. `addQiXiRecord` (post)
参数: `uploadStr, callback, isNeedWait, retryType`
说明: 测试接口，删除所有数据
URL: `add_qixi_record`
请求体: `{type = uploadStr}`
响应处理: createGetResponseFunction

### 291. `allQiXiDelete` (get)
参数: `callback, isNeedWait, retryType`
URL: `all_qixi_delete`
请求体: `nil`
响应处理: createGetResponseFunction

### 292. `testModifyQiXiCtime` (get)
参数: `daynum, callback, isNeedWait, retryType`
URL: `modify_qixi_ctime/`
响应处理: createGetResponseFunction

### 293. `getPuRenNumAndRoomNum` (post)
参数: `mid, actionType, callback, isNeedWait, retryType`
URL: `get_all_numrsper`
请求体: `{mid = mid`
响应处理: createGetResponseFunction

### 294. `setPuRenStatus` (post)
参数: `mid, rwId, type, time, callback, isNeedWait, retryType`
说明: 储物箱售卖商人
URL: `make_servant_change`
请求体: `{mid = mid`
响应处理: createGetResponseFunction

### 295. `getStorageBox` (get)
参数: `baseId, callback, isNeedWait, retryType`
说明: 购买储物箱
URL: `get_storage_box/`
响应处理: createGetResponseFunction

### 296. `buyStorageBox` (post)
参数: `npcId, itemId, transid, fid, callback, isNeedWait, retryType`
说明: 家园开启
URL: `buy_storage_box`
请求体: `{client_trans_id = transid`
响应处理: createGetResponseFunction

### 297. `getHomeSwitch` (post)
参数: `callback, isNeedWait, retryType`
说明: 获取房契信息
URL: `get_home_switch`
请求体: `{}`
响应处理: createGetResponseFunction

### 298. `getHouseInfo` (post)
参数: `callback, isNeedWait, retryType`
说明: 补领地契
URL: `get_house_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 299. `getLandInfo` (post)
参数: `callback, isNeedWait, retryType`
URL: `get_land_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 300. `getDiscountCoupon` (post)
参数: `awardList, callback, isNeedWait, retryType`
URL: `get_discount_coupon`
请求体: `awardList`
响应处理: createGetResponseFunction

### 301. `getActionTime` (post)
参数: `callback, isNeedWait, retryType`
URL: `get_yueka_times`
请求体: `nil`
响应处理: createGetResponseFunction

### 302. `getActionAward` (post)
参数: `callback, isNeedWait, retryType`
URL: `give_yueka_days`
请求体: `nil`
响应处理: createGetResponseFunction

### 303. `getNewDailyList` (post)
参数: `activity_id, callback, isNeedWait, retryType`
URL: `get_newdaily_lists`
请求体: `{activity_id = activity_id}`
响应处理: createGetResponseFunction

### 304. `receiveNewDailyReward` (post)
参数: `activity_id, type, callback, isNeedWait, retryType`
URL: `get_newdaily_award`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 305. `checkItemIsCanUse` (post)
参数: `itemId, number, callback, isNeedWait, retryType`
URL: `employ_materials`
请求体: `{itemId = itemId`
响应处理: createGetResponseFunction

### 306. `getActionTimes` (post)
参数: `action, callback, isNeedWait, retryType`
URL: `get_config_times`
请求体: `{com_config = action}`
响应处理: createGetResponseFunction

### 307. `submitAction` (post)
参数: `action, quantity, callback, isNeedWait, retryType`
URL: `remove_config_point`
请求体: `{com_config = action`
响应处理: createGetResponseFunction

### 308. `getGuaikeReward` (post)
参数: `isMenKe, menKeId, mid, guaikeLv, callback, isNeedWait, retryType`
URL: `get_guaike_reward`
请求体: `{isMenKe = isMenKe`
响应处理: createGetResponseFunction

### 309. `addLandGift` (post)
参数: `gift_type, objId, callback, isNeedWait, retryType`
URL: `add_land_gift`
请求体: `{gifTypt = gift_type`
响应处理: createGetResponseFunction

### 310. `getMenPaiHongBao` (post)
参数: `type, callback, isNeedWait, retryType`
URL: `get_menpai_hongbao`
请求体: `{type = type}`
响应处理: createGetResponseFunction

### 311. `testExchangeGoods` (post)
参数: `itemId, num, callback, isNeedWait, retryType`
URL: `test_exchange_goods`
请求体: `{itemId = itemId`
响应处理: createGetResponseFunction

### 312. `detectionGoods` (post)
参数: `itemId, callback, isNeedWait, retryType`
URL: `detection_goods`
请求体: `{itemId = itemId}`
响应处理: createGetResponseFunction

### 313. `getWebConfig` (get)
参数: `callback, isNeedWait, retryType`
说明: 获取家园消耗
URL: `getWebConfig`
请求体: `nil`
响应处理: createGetResponseFunction

### 314. `getHomelandCost` (get)
参数: `mid, callback, isNeedWait, retryType`
URL: `get_homeland_cost/`
响应处理: createGetResponseFunction

### 315. `getEquinoxTimes` (post)
参数: `type, callback, isNeedWait, retryType`
URL: `get_equinox_times`
请求体: `{type = type}`
响应处理: createGetResponseFunction

### 316. `removeEquinoxPoint` (post)
参数: `type, callback, isNeedWait, retryType`
URL: `remove_equinox_point`
请求体: `{type = type}`
响应处理: createGetResponseFunction

### 317. `getAttributeTimes` (post)
参数: `callback, isNeedWait, retryType`
URL: `get_attribute_times`
请求体: `nil`
响应处理: createGetResponseFunction

### 318. `removeAttributePoint` (post)
参数: `callback, isNeedWait, retryType`
说明: 获取师门团体信息
URL: `remove_attribute_point`
请求体: `nil`
响应处理: createGetResponseFunction

### 319. `getUserGroup` (post)
参数: `userId, teacherId, menpai, isCache, callback, isNeedWait, retryType`
说明: 获取舍友亲密度
URL: `get_user_group`
请求体: `{userid = userId`
响应处理: createGetResponseFunction

### 320. `getUserIntimacy` (post)
参数: `userId, callback, isNeedWait, retryType`
说明: 更新用户亲密度
URL: `get_user_intimacy`
请求体: `{to_uid = userId}`
响应处理: createGetResponseFunction

### 321. `updateUserIntimacy` (post)
参数: `userId, intimacy, event, callback, isNeedWait, retryType`
说明: 获取所有舍友的亲密度
URL: `update_user_intimacy`
请求体: `{to_uid = userId`
响应处理: createGetResponseFunction

### 322. `getAllIntimacy` (get)
参数: `callback, isNeedWait, retryType`
说明: 获取玩家进境排行
URL: `get_all_intimacy`
请求体: `nil`
响应处理: createGetResponseFunction

### 323. `getGroupRank` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_group_rank`
请求体: `nil`
响应处理: createGetResponseFunction

### 324. `removeManpaiTeam` (get)
参数: `callback, isNeedWait, retryType`
说明: 送礼
URL: `test_remove_menpai_team`
请求体: `nil`
响应处理: createGetResponseFunction

### 325. `sendGift` (post)
参数: `userId, itemId, itemCount, addIntimacy, addPrestige, callback, isNeedWait, retryType`
说明: 收礼
URL: `send_gift`
请求体: `{to_uid = userId`
响应处理: createGetResponseFunction

### 326. `getGift` (post)
参数: `userId, callback, isNeedWait, retryType`
说明: 检查舍友是否有给你送礼
URL: `get_gift`
请求体: `{from_uid = userId}`
响应处理: createGetResponseFunction

### 327. `checkHasGift` (post)
参数: `userId, callback, isNeedWait, retryType`
URL: `check_has_gift`
请求体: `{from_uid = userId}`
响应处理: createGetResponseFunction

### 328. `addUserPrestige` (post)
参数: `addPrestige, event, callback, isNeedWait, retryType`
URL: `add_user_prestige`
请求体: `{addPrestige = addPrestige`
响应处理: createGetResponseFunction

### 329. `getUserPrestige` (post)
参数: `callback, isNeedWait, retryType`
说明: 新副本重置
URL: `get_user_prestige`
请求体: `nil`
响应处理: createGetResponseFunction

### 330. `refreshFubenByYuanBao` (post)
参数: `mapList, callback, isNeedWait, retryType`
URL: `refresh_fuben_by_yuanbao`
请求体: `{map_list = mapList}`
响应处理: createGetResponseFunction

### 331. `getPrestigeGoods` (post)
参数: `npcid, is_refresh, callback, isNeedWait, retryType`
URL: `get_prestige_goods`
请求体: `{npc_id = npcid`
响应处理: createGetResponseFunction

### 332. `buyPrestigeGoods` (post)
参数: `itemId, trans_id, npc_id, callback, isNeedWait, retryType`
URL: `buy_prestige_goods`
请求体: `{itemId = itemId`
响应处理: createGetResponseFunction

### 333. `updateUserPrestige` (post)
参数: `callback, isNeedWait, retryType`
URL: `update_user_prestige`
请求体: `nil`
响应处理: createGetResponseFunction

### 334. `setSoleTitle` (get)
参数: `callback, isNeedWait, retryType`
URL: `set_sole_title`
请求体: `nil`
响应处理: createGetResponseFunction

### 335. `useHomeBw` (post)
参数: `zc_val, prId, mid, bwid, callback, isNeedWait, retryType`
说明: 网络属性变更接口（各种货币及服务器相关的属性）
URL: `use_homebw`
请求体: `{zc_val = zc_val`
响应处理: createGetResponseFunction

### 336. `addCurrencyNumber` (post)
参数: `currency_tb, eventType, params, callback, isNeedWait, retryType`
URL: `add_currency_number`
请求体: `{currency = currency_tb`
响应处理: createGetResponseFunction

### 337. `getQiXiRankBoard` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_qixi_board`
请求体: `nil`
响应处理: createGetResponseFunction

### 338. `getQiXiRankBoatReward` (post)
参数: `transid, type, callback, isNeedWait, retryType`
URL: `get_qixi_reward`
请求体: `{trans_id = transid`
响应处理: createGetResponseFunction

### 339. `getQiXiTaskInFo` (post)
参数: `actionId, callback, isNeedWait, retryType`
URL: `get_qixi_task_info`
请求体: `{actionId = actionId}`
响应处理: createGetResponseFunction

### 340. `TakeQiXiTask` (post)
参数: `actionId, callback, isNeedWait, retryType`
URL: `take_qixi_task`
请求体: `{actionId = actionId}`
响应处理: createGetResponseFunction

### 341. `FinishQiXiTask` (post)
参数: `actionId, callback, isNeedWait, retryType`
说明: 充值测试接口
URL: `finish_qixi_task`
请求体: `{actionId = actionId}`
响应处理: createGetResponseFunction

### 342. `testChongzhi` (get)
参数: `rechargeType, callback, isNeedWait, retryType`
说明: 获取副本开放状态
URL: `test_chongzhi/`
响应处理: createGetResponseFunction

### 343. `getConfigFuben` (post)
参数: `mapId, callback, isNeedWait, retryType`
URL: `get_config_fuben`
请求体: `{fbId = mapId}`
响应处理: createGetResponseFunction

### 344. `getDiyGoods` (post)
参数: `isRefresh, callback, isNeedWait, retryType`
URL: `get_diy_goods`
请求体: `{is_refresh = isRefresh}`
响应处理: createGetResponseFunction

### 345. `getDiyInfos` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_diy_infos`
请求体: `nil`
响应处理: createGetResponseFunction

### 346. `buyDiyGoods` (post)
参数: `callback, isNeedWait, retryType`
URL: `buy_diy_goods`
请求体: `nil`
响应处理: createGetResponseFunction

### 347. `addHomeBw` (post)
参数: `bwId, number, callback, isNeedWait, retryType`
URL: `add_homebw`
请求体: `{bwid = bwId`
响应处理: createGetResponseFunction

### 348. `getActivityCalendar` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_activity_calendar` `servant` `lunjian`
请求体: `nil`
响应处理: createGetResponseFunction

### 349. `getGrowthInfo` (post)
参数: `requirement, callback, isNeedWait, retryType`
URL: `get_growth_info`
请求体: `{requirement = requirement}`
响应处理: createGetResponseFunction

### 350. `addZhounianJifen` (post)
参数: `addType, number, callback, isNeedWait, retryType`
URL: `add_zhounian_jifen` `get_dream_world`
请求体: `{addType = addType` `nil`
响应处理: createGetResponseFunction

### 351. `getDreamGoods` (get)
参数: `callback, isNeedWait, retryType`
说明: 购买梦呓商品
URL: `get_dream_goods`
请求体: `nil`
响应处理: createGetResponseFunction

### 352. `buyDreamGood` (post)
参数: `onlyId, period, callback, isNeedWait, retryType`
说明: 获取传承前学习的其它门派技能
URL: `buy_dream_goods`
请求体: `{onlyId = onlyId`
响应处理: createGetResponseFunction

### 353. `getOtherSkills` (post)
参数: `inheritIndex, callback, isNeedWait, retryType`
说明: 从前辈处学习技能
URL: `get_other_skills`
请求体: `{inheritIndex = inheritIndex}`
响应处理: createGetResponseFunction

### 354. `studyOtherSkill` (post)
参数: `userid, skillid, callback, isNeedWait, retryType`
说明: 测试接口，添加技能
URL: `study_other_skill`
请求体: `{userid = userid`
响应处理: createGetResponseFunction

### 355. `testOtherSkill` (post)
参数: `userid, skillid, callback, isNeedWait, retryType`
URL: `test_other_skill`
请求体: `{userid = userid`
响应处理: createGetResponseFunction

### 356. `uploadDreamRoleData` (post)
参数: `dreamRoleData, callback, isNeedWait, retryType`
URL: `upload_dream_role`
请求体: `{roleAttr = dreamRoleData}`
响应处理: createGetResponseFunction

### 357. `getDreamRoleData` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_dream_role`
请求体: `nil`
响应处理: createGetResponseFunction

### 358. `getWebReward` (post)
参数: `params, callback, isNeedWait, retryType`
URL: `get_web_reward`
请求体: `params`
响应处理: createGetResponseFunction

### 359. `reportGainLog` (post)
参数: `logData, callback, isNeedWait, retryType`
说明: 日志上传
URL: `report_gain_log`
请求体: `{log_data = logData}`
响应处理: createGetResponseFunction

### 360. `uploadAcquisitionLog` (post)
参数: `_logs, callback, isNeedWait, retryType`
URL: `upload_acquisition_log` `unlockTalent` `dreamCoins`
请求体: `_logs`
响应处理: createGetResponseFunction

### 361. `uploadEventRecord` (post)
参数: `params, callback, isNeedWait, retryType`
URL: `upload_event_record`
请求体: `{params = params}`
响应处理: createGetResponseFunction

### 362. `getEventRecord` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_event_record`
请求体: `nil`
响应处理: createGetResponseFunction

### 363. `submitEventRecord` (get)
参数: `callback, isNeedWait, retryType`
说明: 楼层结算
URL: `submit_event_record`
请求体: `nil`
响应处理: createGetResponseFunction

### 364. `dreamFloorComplete` (post)
参数: `roleAttr, callback, isNeedWait, retryType`
说明: 梦境楼层结算
URL: `dream_floor_complete`
请求体: `{roleAttr = roleAttr}`
响应处理: createGetResponseFunction

### 365. `dreamWorldComplete` (post)
参数: `uploadParams, callback, isNeedWait, retryType`
URL: `dreamworld_complete`
请求体: `{roleAttr = uploadParams.roleAttr`
响应处理: createGetResponseFunction

### 366. `checkDreamRoleDataIsOverdue` (post)
参数: `userData, callback, isNeedWait, retryType`
URL: `settle_overdue_dream`
请求体: `{userData}`
响应处理: createGetResponseFunction

### 367. `updateUnlockRecord` (post)
参数: `events, callback, isNeedWait, retryType`
URL: `update_unlock_record`
请求体: `{events = events}`
响应处理: createGetResponseFunction

### 368. `getDreamRewardSkill` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_dream_reward_skill`
请求体: `nil`
响应处理: createGetResponseFunction

### 369. `getLoginYuandanInfo` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_login_yuandan_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 370. `setLoginYuandanReward` (post)
参数: `rewardId, callback, isNeedWait, retryType`
URL: `set_login_yuandan_reward`
请求体: `{rewardId = rewardId}`
响应处理: createGetResponseFunction

### 371. `getYuanbaoLotteryList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_yuanbao_lottery_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 372. `doYuanbaoLottery` (get)
参数: `callback, isNeedWait, retryType`
说明: 异人录活动信息
URL: `do_yuanbao_lottery`
请求体: `nil`
响应处理: createGetResponseFunction

### 373. `getMingRenLotteryList` (get)
参数: `callback, isNeedWait, retryType`
说明: 异人录活动抽奖
URL: `get_mingren_lottery_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 374. `doMingRenLottery` (get)
参数: `times, callback, isNeedWait, retryType`
说明: 江湖名武录活动信息
URL: `do_mingren_lottery/`
响应处理: createGetResponseFunction

### 375. `getMingWuLotteryList` (get)
参数: `callback, isNeedWait, retryType`
说明: 江湖名武录抽奖
URL: `get_mingwu_lottery_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 376. `doMingWuLottery` (get)
参数: `times, callback, isNeedWait, retryType`
URL: `do_mingwu_lottery/`
响应处理: createGetResponseFunction

### 377. `getZhenPinGeLotteryList` (get)
参数: `activity_id, callback, isNeedWait, retryType`
URL: `get_zhenpinge_lottery_list/`
响应处理: createGetResponseFunction

### 378. `doZhenPinGeLottery` (post)
参数: `activity_id, times, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `do_zhenpinge_lottery`
请求体: `{times = times`
响应处理: createGetResponseFunction

### 379. `exchangeZhenPinGeGoods` (post)
参数: `activity_id, id, num, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `exchange_zhenpinge_goods`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 380. `bfmingtieExchangeSpcl` (get)
参数: `callback, isNeedWait, retryType`
URL: `bfmingtie_exchange_spcl`
请求体: `nil`
响应处理: createGetResponseFunction

### 381. `getCreateBooks` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_books`
请求体: `nil`
响应处理: createGetResponseFunction

### 382. `useCreateProp` (post)
参数: `propId, userLv, skillDataId, callback, isNeedWait, retryType`
URL: `use_create_prop`
请求体: `{prop = propId`
响应处理: createGetResponseFunction

### 383. `useImproveProp` (post)
参数: `propId, userLv, zhaoIndex, skillDataId, callback, isNeedWait, retryType`
URL: `use_improve_prop`
请求体: `{prop = propId`
响应处理: createGetResponseFunction

### 384. `addProp` (post)
参数: `propId, count, callback, isNeedWait, retryType`
URL: `add_prop`
请求体: `{prop = propId`
响应处理: createGetResponseFunction

### 385. `getPropList` (get)
参数: `propType, callback, isNeedWait, retryType`
URL: `get_propList/`
响应处理: createGetResponseFunction

### 386. `createZhao` (post)
参数: `zhaoType, userLv, tujianLv, callback, isNeedWait, retryType`
URL: `create_zhao`
请求体: `{methods = zhaoType`
响应处理: createGetResponseFunction

### 387. `testDeleteBook` (post)
参数: `action, callback, isNeedWait, retryType`
URL: `test_delete_book`
请求体: `{action = action}`
响应处理: createGetResponseFunction

### 388. `deleteCompletedBook` (post)
参数: `skillId, callback, isNeedWait, retryType`
URL: `delete_book`
请求体: `{skillId = skillId}`
响应处理: createGetResponseFunction

### 389. `completeBook` (post)
参数: `skillName, callback, isNeedWait, retryType`
URL: `complete_book`
请求体: `{skillName = skillName}`
响应处理: createGetResponseFunction

### 390. `getZhaoColors` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_zhaoColors`
请求体: `nil`
响应处理: createGetResponseFunction

### 391. `unlockZhaoColor` (post)
参数: `colorId, callback, isNeedWait, retryType`
URL: `unlock_zhaoColor`
请求体: `{colorId = colorId}`
响应处理: createGetResponseFunction

### 392. `getZhaoDscs` (post)
参数: `templateId, callback, isNeedWait, retryType`
URL: `get_zhaoDscs`
请求体: `{templateId = templateId}`
响应处理: createGetResponseFunction

### 393. `unlockZhaoDsc` (post)
参数: `xiLieId, templateId, callback, isNeedWait, retryType`
URL: `unlock_zhaoDsc_xiLie`
请求体: `{xiLieId = xiLieId`
响应处理: createGetResponseFunction

### 394. `getSkillNameAffixs` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_skillName_affixs`
请求体: `nil`
响应处理: createGetResponseFunction

### 395. `unlockSkillNameAffixs` (post)
参数: `nameAffixsId, callback, isNeedWait, retryType`
URL: `unlock_skillName_affixs`
请求体: `{affixsId = nameAffixsId}`
响应处理: createGetResponseFunction

### 396. `setZhaoAttr` (post)
参数: `params, callback, isNeedWait, retryType`
URL: `set_zhao_attr`
请求体: `params`
响应处理: createGetResponseFunction

### 397. `getZhaoSuccessRate` (post)
参数: `userLv, callback, isNeedWait, retryType`
URL: `get_successRate`
请求体: `{lv = userLv}`
响应处理: createGetResponseFunction

### 398. `learnSkillBook` (post)
参数: `skillId, callback, isNeedWait, retryType`
URL: `learn_book`
请求体: `{skillId = skillId}`
响应处理: createGetResponseFunction

### 399. `acceptTask` (post)
参数: `task_id, extra_data, callback, isNeedWait, retryType`
URL: `accept_task`
请求体: `{task_id = task_id`
响应处理: createGetResponseFunction

### 400. `finishTask` (post)
参数: `task_id, extra_data, callback, isNeedWait, retryType`
URL: `finish_task`
请求体: `{task_id = task_id`
响应处理: createGetResponseFunction

### 401. `resetTask` (post)
参数: `task_id, callback, isNeedWait, retryType`
URL: `reset_task`
请求体: `{task_id = task_id}`
响应处理: createGetResponseFunction

### 402. `submitTask` (post)
参数: `task_id, callback, isNeedWait, retryType`
URL: `submit_task`
请求体: `{task_id = task_id}`
响应处理: createGetResponseFunction

### 403. `getTaskInfo` (post)
参数: `task_id, callback, isNeedWait, retryType`
URL: `get_task_info`
请求体: `{task_id = task_id}`
响应处理: createGetResponseFunction

### 404. `testUpdateTask` (post)
参数: `task_id, updateInfo, callback, isNeedWait, retryType`
URL: `test_update_task`
请求体: `{task_id = task_id`
响应处理: createGetResponseFunction

### 405. `testClearBook` (post)
参数: `skill_id, callback, isNeedWait, retryType`
URL: `test_clear_book`
请求体: `{skill_id = skill_id}`
响应处理: createGetResponseFunction

### 406. `deleteCreateBookDayLimit` (get)
参数: `callback, isNeedWait, retryType`
URL: `delete_book_dayLimit`
请求体: `nil`
响应处理: createGetResponseFunction

### 407. `testAddZhaoNum` (post)
参数: `skill_id, num, callback, isNeedWait, retryType`
URL: `test_add_zhaoNum`
请求体: `{skillId = skill_id`
响应处理: createGetResponseFunction

### 408. `getDailyTaskList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_daily_task_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 409. `getDailyTaskReward` (post)
参数: `rid, isEmail, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `get_daily_task_reward`
请求体: `{rid = rid`
响应处理: createGetResponseFunction

### 410. `addDailyTaskPoint` (post)
参数: `task_id, callback, isNeedWait, retryType`
URL: `add_daily_task_point`
请求体: `{task_id = task_id}`
响应处理: createGetResponseFunction

### 411. `getLoginRewardList` (get)
参数: `activity_id, callback, isNeedWait, retryType`
URL: `get_login_reward_list/`
响应处理: createGetResponseFunction

### 412. `getLoginReward` (post)
参数: `activityId, rid, isEmail, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `get_login_reward`
请求体: `{activityId = activityId`
响应处理: createGetResponseFunction

### 413. `getFundActivityInfo` (get)
参数: `actionId, callback, isNeedWait, retryType`
URL: `get_login_reward_list/`
响应处理: createGetResponseFunction

### 414. `getFundReward` (post)
参数: `actionId, rid, callback, isNeedWait, retryType`
URL: `get_login_reward`
请求体: `{activity_id = actionId`
响应处理: createGetResponseFunction

### 415. `setProductMark` (post)
参数: `actionId, key, callback, isNeedWait, retryType`
URL: `set_product_mark`
请求体: `{activity_id = actionId`
响应处理: createGetResponseFunction

### 416. `getSpringNewReward` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_spring_new_reward`
请求体: `nil`
响应处理: createGetResponseFunction

### 417. `receiveSpringNewReward` (get)
参数: `rid, callback, isNeedWait, retryType`
URL: `receive_spring_new_reward/`
响应处理: createGetResponseFunction

### 418. `getIntelligenceData` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_intelligence_data`
请求体: `nil`
响应处理: createGetResponseFunction

### 419. `uploadIntelligenceData` (post)
参数: `params, callback, isNeedWait, retryType`
URL: `upload_intelligence_data`
请求体: `params`
响应处理: createGetResponseFunction

### 420. `buyIntelligence` (get)
参数: `callback, isNeedWait, retryType`
URL: `buy_day_intelligence`
请求体: `nil`
响应处理: createGetResponseFunction

### 421. `getTechniqueList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_technique_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 422. `readIntelligence` (post)
参数: `id, type, callback, isNeedWait, retryType`
URL: `read_intelligence`
请求体: `{intelligence_id = id`
响应处理: createGetResponseFunction

### 423. `deleteDayIntelligence` (get)
参数: `callback, isNeedWait, retryType`
URL: `delete_day_intelligence`
请求体: `nil`
响应处理: createGetResponseFunction

### 424. `deleteIntelligence` (post)
参数: `type, callback, isNeedWait, retryType`
URL: `delete_bought_intelligence`
请求体: `{type = type}`
响应处理: createGetResponseFunction

### 425. `getSpendRewardList` (get)
参数: `actionId, callback, isNeedWait, retryType`
URL: `get_spend_reward_list/`
响应处理: createGetResponseFunction

### 426. `getSpendReward` (post)
参数: `actionId, rid, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `get_spend_reward`
请求体: `{activity_id = actionId`
响应处理: createGetResponseFunction

### 427. `containsBlockedWord` (post)
参数: `str, callback, isNeedWait, retryType`
URL: `contains_blocked_word`
请求体: `{s = str}`
响应处理: createGetResponseFunction

### 428. `getAnswerStatus` (post)
参数: `activityId, callback, isNeedWait, retryType`
URL: `get_answer_status`
请求体: `{activity_id = activityId}`
响应处理: createGetResponseFunction

### 429. `setAnswerStatus` (post)
参数: `activityId, type, passNum, callback, isNeedWait, retryType`
URL: `set_answer_status`
请求体: `{activity_id = activityId`
响应处理: createGetResponseFunction

### 430. `getEmails` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_email_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 431. `readEmail` (post)
参数: `id, callback, isNeedWait, retryType`
URL: `read_email`
请求体: `{id = id}`
响应处理: createGetResponseFunction

### 432. `deleteEmail` (get)
参数: `id, callback, isNeedWait, retryType`
URL: `delete_email/`
响应处理: createGetResponseFunction

### 433. `getEmailReward` (post)
参数: `id, familyId, retrievables, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `get_email_reward`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 434. `getAllEmailRewardList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_email_rewards_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 435. `getAllEmailReward` (post)
参数: `familyId, retrievables, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `get_all_email_rewards`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 436. `deleteIsFinishEmails` (get)
参数: `callback, isNeedWait, retryType`
URL: `delete_processed_emails`
请求体: `nil`
响应处理: createGetResponseFunction

### 437. `maskUpgrade` (post)
参数: `params, currencyVersion, callback, isNeedWait, retryType`
URL: `mask_upgrade`
请求体: `{params = params`
响应处理: createGetResponseFunction

### 438. `getLotteryTreasureList` (get)
参数: `activity_id, callback, isNeedWait, retryType`
URL: `get_lottery_treasure_list/`
响应处理: createGetResponseFunction

### 439. `lotteryTreasureResult` (post)
参数: `activity_id, callback, isNeedWait, retryType`
URL: `lottery_treasure_result`
请求体: `{activity_id = activity_id}`
响应处理: createGetResponseFunction

### 440. `lotteryTreasureReward` (post)
参数: `activity_id, rid, is_email, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `lottery_treasure_reward`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 441. `getLotteryTreasureExchangeShop` (post)
参数: `activity_id, callback, isNeedWait, retryType`
URL: `get_lottery_treasure_exchange_shop`
请求体: `{activity_id = activity_id}`
响应处理: createGetResponseFunction

### 442. `lotteryTreasureExchangeGoods` (post)
参数: `activity_id, goods_id, callback, isNeedWait, retryType`
URL: `lottery_treasure_exchange_goods`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 443. `buyLotteryTreasureCurrency` (post)
参数: `activity_id, number, callback, isNeedWait, retryType`
URL: `buy_lottery_treasure_currency`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 444. `addGuideTaskPoint` (post)
参数: `taskId, point, callback, isNeedWait, retryType`
URL: `add_guide_task_point`
请求体: `{task_id = taskId`
响应处理: createGetResponseFunction

### 445. `getGuideTaskPoint` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_guide_task_point`
请求体: `nil`
响应处理: createGetResponseFunction

### 446. `getRecordSkills` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_record_skills`
请求体: `nil`
响应处理: createGetResponseFunction

### 447. `recordSkill` (post)
参数: `skill_id, skill_type, callback, isNeedWait, retryType`
URL: `record_skill`
请求体: `{skill_id = skill_id`
响应处理: createGetResponseFunction

### 448. `learnSkill` (post)
参数: `skill_id, callback, isNeedWait, retryType`
URL: `learn_skill`
请求体: `{skill_id = skill_id}`
响应处理: createGetResponseFunction

### 449. `getAndroidUUID` (get)
参数: `callback, isNeedWait, retryType`
URL: `api/v5/` `api/service_android/` `get_uuid`
响应处理: createGetResponseFunction

### 450. `checkFondDreamRoleDataIsOverdue` (post)
参数: `userData, callback, isNeedWait, retryType`
URL: `settle_overdue_fond_dream`
请求体: `{userData}`
响应处理: createGetResponseFunction

### 451. `getFondDreamRoleData` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_fond_dream_role`
请求体: `nil`
响应处理: createGetResponseFunction

### 452. `uploadFondDreamRoleData` (post)
参数: `dreamRoleData, callback, isNeedWait, retryType`
URL: `upload_fond_dream_role`
请求体: `{roleAttr = dreamRoleData}`
响应处理: createGetResponseFunction

### 453. `fondDreamFloorComplete` (post)
参数: `roleAttr, callback, isNeedWait, retryType`
URL: `fond_dream_floor_complete`
请求体: `{roleAttr = roleAttr}`
响应处理: createGetResponseFunction

### 454. `fondDreamWorldComplete` (post)
参数: `uploadParams, callback, isNeedWait, retryType`
URL: `fond_dreamworld_complete`
请求体: `{roleAttr = uploadParams.roleAttr`
响应处理: createGetResponseFunction

### 455. `getFondWebReward` (post)
参数: `params, callback, isNeedWait, retryType`
URL: `get_fond_dream_reward`
请求体: `params`
响应处理: createGetResponseFunction

### 456. `deleteFondDreamRoleData` (get)
参数: `callback, isNeedWait, retryType`
URL: `delete_fond_dream_role`
请求体: `nil`
响应处理: createGetResponseFunction

### 457. `getEggChallengeInfo` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_egg_challenge_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 458. `addEggChallengeTimes` (post)
参数: `npcId, callback, isNeedWait, retryType`
URL: `add_egg_challenge_times`
请求体: `{npc_id = npcId}`
响应处理: createGetResponseFunction

### 459. `getLuckBoxList` (post)
参数: `activity_id, menpai, is_refresh, callback, isNeedWait, retryType`
URL: `get_luck_box_list`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 460. `buyLuckBoxGood` (post)
参数: `activity_id, rid, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `buy_luck_box_good`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 461. `getLuckBoxGood` (post)
参数: `activity_id, rid, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `get_luck_box_good`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 462. `getSachetAtticList` (get)
参数: `actionId, callback, isNeedWait, retryType`
URL: `get_sachet_attic_list/`
响应处理: createGetResponseFunction

### 463. `exchangeAwardToSachet` (post)
参数: `activity_id, reward_id, callback, isNeedWait, retryType`
URL: `exchange_award_to_sachet`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 464. `buySpendReward` (post)
参数: `activity_id, rid, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `buy_spend_reward`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 465. `startHangUpTask` (post)
参数: `version, taskId, extraData, callback, isNeedWait, retryType`
URL: `start_hang_up_task`
请求体: `{version = version`
响应处理: createGetResponseFunction

### 466. `stopHangUpTask` (post)
参数: `version, taskId, extraData, reward, callback, isNeedWait, retryType`
URL: `stop_hang_up_task`
请求体: `{version = version`
响应处理: createGetResponseFunction

### 467. `getHangUpYashiTime` (post)
参数: `version, callback, isNeedWait, retryType`
URL: `get_hangUp_yashi_time`
请求体: `{version = version}`
响应处理: createGetResponseFunction

### 468. `getYaShiExpiredTime` (get)
参数: `callback, isNeedWait, retryType`
URL: `check_has_yashi`
请求体: `nil`
响应处理: createGetResponseFunction

### 469. `recordClickTask` (post)
参数: `taskId, reward, extra, callback, isNeedWait, retryType`
URL: `record_click_task`
请求体: `{task_id = taskId`
响应处理: createGetResponseFunction

### 470. `testSetUpdateYaShiTime` (post)
参数: `create_time, expired_time, callback, isNeedWait, retryType`
说明: 测试用:修改挂机数据
URL: `test_update_yashi`
请求体: `{data = {create_time = create_time`
响应处理: createGetResponseFunction

### 471. `testSetUpdateHangTask` (post)
参数: `version, data, callback, isNeedWait, retryType`
说明: 查看挂机信息
URL: `test_update_hang_task`
请求体: `{version = version`
响应处理: createGetResponseFunction

### 472. `testGetHangTask` (post)
参数: `version, callback, isNeedWait, retryType`
URL: `test_get_hang_task`
请求体: `{version = version}`
响应处理: createGetResponseFunction

### 473. `getTotalSpendDetail` (get)
参数: `activity_id, callback, isNeedWait, retryType`
URL: `get_total_spend_detail/`
响应处理: createGetResponseFunction

### 474. `getTotalSpendAward` (post)
参数: `activity_id, award_id, callback, isNeedWait, retryType`
URL: `get_total_spend_award`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 475. `upgradeUserBag` (post)
参数: `type, level, callback, isNeedWait, retryType`
URL: `upgrade_user_bag`
请求体: `{type = type`
响应处理: createGetResponseFunction

### 476. `addIncidentLog` (post)
参数: `event_type, envet_param, user_attr, callback, isNeedWait, retryType`
URL: `add_incident_log`
请求体: `{event_type = event_type`
响应处理: createGetResponseFunction

### 477. `martialUpgradeAddCurrency` (post)
参数: `currencyVersion, type, callback, isNeedWait, retryType`
URL: `martial_upgrade_add_currency`
请求体: `{currencyVersion = currencyVersion`
响应处理: createGetResponseFunction

### 478. `getExpelRewardList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_expel_reward_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 479. `expelNian` (post)
参数: `times, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `expel_nian`
请求体: `{times = times`
响应处理: createGetResponseFunction

### 480. `getExpelReward` (post)
参数: `rid, giftId, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `get_expel_reward`
请求体: `{rid = rid`
响应处理: createGetResponseFunction

### 481. `getAnecdote` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_user_anecdote`
请求体: `nil`
响应处理: createGetResponseFunction

### 482. `revertAnecdote` (get)
参数: `callback, isNeedWait, retryType`
说明: 获取节日副本详情
URL: `test_revert_anecdote`
请求体: `nil`
响应处理: createGetResponseFunction

### 483. `getFestivalMapInfo` (post)
参数: `groupId,callback, isNeedWait, retryType`
说明: 判断是否有未完成的挑战副本进度
URL: `get_festivalmap_info`
请求体: `{groupId = groupId}`
响应处理: createGetResponseFunction

### 484. `isChallengeMapReconnection` (get)
参数: `callback, isNeedWait, retryType`
说明: 进入未完成副本
URL: `challengemap_unfinished`
请求体: `nil`
响应处理: createGetResponseFunction

### 485. `reEnterChallengemap` (get)
参数: `callback, isNeedWait, retryType`
URL: `reenter_challengemap`
请求体: `nil`
响应处理: createGetResponseFunction

### 486. `enterChallengeMap` (post)
参数: `mapId, callback, isNeedWait, retryType`
说明: 挑战副本能否快速通关
URL: `challengemap_enter`
请求体: `{map_id = mapId}`
响应处理: createGetResponseFunction

### 487. `challengeMapIsCustoms` (post)
参数: `mapId, callback, isNeedWait, retryType`
URL: `challengemap_is_customs`
请求体: `{map_id = mapId}`
响应处理: createGetResponseFunction

### 488. `challengeMapConfirmConsume` (post)
参数: `mapId, consume_map, callback, isNeedWait, retryType`
URL: `challengemap_confirm_consume`
请求体: `{map_id = mapId`
响应处理: createGetResponseFunction

### 489. `challengeMapFinish` (post)
参数: `mapId, finishType, callback, isNeedWait, retryType`
URL: `challengemap_finish`
请求体: `{map_id = mapId`
响应处理: createGetResponseFunction

### 490. `challengeMapGetAward` (post)
参数: `mapId, type, award_list, finishType, currencyVersion, callback, isNeedWait, retryType`
说明: 挑战副本离开(用于未通关退出挑战副本，通知服务器结束这次挑战副本记录)
URL: `challengemap_award`
请求体: `{currencyVersion = currencyVersion`
响应处理: createGetResponseFunction

### 491. `challengeMapLeave` (post)
参数: `type, callback, isNeedWait, retryType`
说明: 获取武学突破相关货币数量
URL: `challengemap_leave`
请求体: `{type = type}`
响应处理: createGetResponseFunction

### 492. `getSkillBreakCurrency` (post)
参数: `currencyVersion, callback, isNeedWait, retryType`
说明: 武学突破
URL: `get_martial_upgrade_currency`
请求体: `{currencyVersion = currencyVersion}`
响应处理: createGetResponseFunction

### 493. `skillBreakThrough` (post)
参数: `id, skillId, currencyVersion, callback, isNeedWait, retryType`
说明: 测试接口  增加武学突破相关货币各1000
URL: `martial_upgrade`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 494. `testAddMartialCurrency` (post)
参数: `currencyVersion, callback, isNeedWait, retryType`
说明: 招式突破
URL: `test_add_martial_currency`
请求体: `{currencyVersion = currencyVersion}`
响应处理: createGetResponseFunction

### 495. `zhaoBreakThrough` (post)
参数: `id, zhaoId, currencyVersion, callback, isNeedWait, retryType`
说明: 获取招式突破相关道具数量列表
URL: `zhao_upgrade`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 496. `getZhaoBreakThroughItems` (post)
参数: `currencyVersion, callback, isNeedWait, retryType`
说明: 测试接口  增加招式突破相关道具各1000
URL: `get_zhao_upgrade_matters`
请求体: `{currencyVersion = currencyVersion}`
响应处理: createGetResponseFunction

### 497. `testAddZhaoBreItems` (get)
参数: `callback, isNeedWait, retryType`
URL: `test_add_zhao_currency`
请求体: `nil`
响应处理: createGetResponseFunction

### 498. `uploadWashAttributeRecord` (post)
参数: `record, callback, isNeedWait, retryType`
URL: `upload_wash_attribute_record`
请求体: `{record = record}`
响应处理: createGetResponseFunction

### 499. `mattersShopInfo` (post)
参数: `type, currencyVersion, callback, isNeedWait, retryType`
URL: `matters_shop_info`
请求体: `{type = type`
响应处理: createGetResponseFunction

### 500. `buyMatters` (post)
参数: `goodsKey, currencyVersion, callback, isNeedWait, retryType`
URL: `buy_matters` `xx`
请求体: `{goodsKey = goodsKey`
响应处理: createGetResponseFunction

### 501. `specialItemExchange` (post)
参数: `exchangeItems, targetItems, callback, isNeedWait, retryType`
说明: pvp战斗人物数据校验
URL: `special_item_exchange`
请求体: `{exchangeItems = exchangeItems`
响应处理: createGetResponseFunction

### 502. `pvpRoleDataVerify` (post)
参数: `roleDatas, callback, isNeedWait, retryType`
URL: `pvp_roleData_verify`
请求体: `{roleDatas = roleDatas}`
响应处理: createGetResponseFunction

### 503. `getTrainingTaskList` (post)
参数: `actionId, taskList, callback, isNeedWait, retryType`
URL: `get_training_task_list`
请求体: `{activityId = actionId`
响应处理: createGetResponseFunction

### 504. `refreshTrainingTaskList` (post)
参数: `actionId, taskList, callback, isNeedWait, retryType`
URL: `refresh_training_task_list`
请求体: `{activityId = actionId`
响应处理: createGetResponseFunction

### 505. `addTrainingTaskPoint` (post)
参数: `taskId, taskList, callback, isNeedWait, retryType`
URL: `add_training_task_point`
请求体: `{tid = taskId`
响应处理: createGetResponseFunction

### 506. `getTrainingTaskReward` (post)
参数: `activityId, rid, giftId, isEmail, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `get_training_task_reward`
请求体: `{activityId = activityId`
响应处理: createGetResponseFunction

### 507. `getUiThemeList` (get)
参数: `callback,isNeedWait, retryType`
URL: `get_ui_theme_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 508. `buyUiTheme` (get)
参数: `uiId, callback,isNeedWait, retryType`
URL: `buy_ui_theme/`
响应处理: createGetResponseFunction

### 509. `useUiTheme` (get)
参数: `uiId, callback,isNeedWait, retryType`
说明: 删除已购买的所有皮肤（测试专用接口）
URL: `use_ui_theme/`
响应处理: createGetResponseFunction

### 510. `testDeleteAllUiThemes` (get)
参数: `callback,isNeedWait, retryType`
说明: 获取练武场相关信息
URL: `test_delete_all_ui_themes`
请求体: `nil`
响应处理: createGetResponseFunction

### 511. `getPracticeSkillRewardList` (post)
参数: `activityId, skillData,zhaoData,callback,isNeedWait, retryType`
URL: `get_practice_skill_reward_list`
请求体: `{activityId = activityId`
响应处理: createGetResponseFunction

### 512. `getPracticeSkillReward` (post)
参数: `activityId, rid,is_email,dataVer,callback,isNeedWait, retryType`
URL: `get_practice_skill_reward`
请求体: `{activityId = activityId`
响应处理: createGetResponseFunction

### 513. `unlockPracticeSkillPayReward` (post)
参数: `activityId, jackpotId, callback, isNeedWait, retryType`
URL: `unlock_practice_skill_reward`
请求体: `{activityId = activityId`
响应处理: createGetResponseFunction

### 514. `getToastRewardList` (get)
参数: `callback,isNeedWait, retryType`
URL: `get_toast_reward_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 515. `toastQian` (post)
参数: `times, dataVer, callback,isNeedWait, retryType`
URL: `toast_qian`
请求体: `{times = times`
响应处理: createGetResponseFunction

### 516. `getToastReward` (post)
参数: `rid, giftId, dataVer, newDataVer, callback,isNeedWait, retryType`
URL: `get_toast_reward`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 517. `getLianGongState` (post)
参数: `dataVer, codeVer, callback`
URL: `getLianGongState`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 518. `lianGongStart` (post)
参数: `requestId, dataVer, codeVer, actionData, time, callback`
URL: `lianGongStart`
请求体: `{requestId = requestId`
响应处理: createGetResponseFunction

### 519. `lianGongFinish` (post)
参数: `requestId, dataVer, codeVer, actionData, time, callback`
URL: `lianGongFinish`
请求体: `{requestId = requestId`
响应处理: createGetResponseFunction

### 520. `lianGongUseXingGongSan` (post)
参数: `requestId, dataVer, codeVer, time, callback`
URL: `lianGongUseXingGongSan`
请求体: `{requestId = requestId`
响应处理: createGetResponseFunction

### 521. `getLianGongData` (post)
参数: `dataVer, codeVer, callback`
URL: `getLianGongData`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 522. `getXiuLianState` (post)
参数: `dataVer, codeVer, callback`
URL: `getXiuLianState`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 523. `xiuLianStart` (post)
参数: `requestId, dataVer, codeVer, actionData, time, callback`
URL: `xiuLianStart`
请求体: `{requestId = requestId`
响应处理: createGetResponseFunction

### 524. `xiuLianFinish` (post)
参数: `requestId, dataVer, codeVer, actionData, time, callback`
URL: `xiuLianFinish`
请求体: `{requestId = requestId`
响应处理: createGetResponseFunction

### 525. `xiuLianUseXingGongSan` (post)
参数: `requestId, dataVer, codeVer, time, callback`
URL: `xiuLianUseXingGongSan`
请求体: `{requestId = requestId`
响应处理: createGetResponseFunction

### 526. `getXiuLianData` (post)
参数: `dataVer, codeVer, callback`
URL: `getXiuLianData`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 527. `getXinShenValue` (post)
参数: `dataVer, codeVer, callback`
URL: `getXinShenValue`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 528. `upgradeXinShenLevel` (post)
参数: `requestId, dataVer, codeVer, time, callback`
URL: `upgradeXinShenLevel`
请求体: `{requestId = requestId`
响应处理: createGetResponseFunction

### 529. `getXinShenLevel` (post)
参数: `dataVer, codeVer, callback`
URL: `getXinShenLevel`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 530. `getXinShenRecoverStartTime` (post)
参数: `dataVer, codeVer, callback`
URL: `getXinShenRecoverStartTime`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 531. `recoverXinShenValue` (post)
参数: `value, dataVer, codeVer, time, callback`
URL: `recoverXinShenValue`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 532. `getLianGongTiLi` (post)
参数: `dataVer, codeVer, callback`
URL: `get_liangong_tili`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 533. `testAddLianGongTiLi` (post)
参数: `count, dataVer, codeVer, callback`
说明: 获取地仓府库活动详情
URL: `test_add_liangong_tili`
请求体: `{count = count`
响应处理: createGetResponseFunction

### 534. `getWareHouseActivityInfo` (post)
参数: `currencyVersion, callback,isNeedWait, retryType`
说明: 地仓府库抽奖
URL: `get_treasury_info`
请求体: `{currencyVersion = currencyVersion}`
响应处理: createGetResponseFunction

### 535. `WareHouseDrawLucky` (post)
参数: `indexList, currencyVersion, callback,isNeedWait, retryType`
说明: 领取地仓府库奖励
URL: `treasury_lottery`
请求体: `{indexList = indexList`
响应处理: createGetResponseFunction

### 536. `getWareHouseAward` (post)
参数: `rewardType,awardIds,isEmail,dataVer,currencyVersion,callback,isNeedWait, retryType`
说明: 进入地仓府库下一层
URL: `get_treasury_reward`
请求体: `{rewardType = rewardType`
响应处理: createGetResponseFunction

### 537. `enterWareHouseNextFloor` (get)
参数: `callback,isNeedWait, retryType`
URL: `enter_next_treasury`
请求体: `nil`
响应处理: createGetResponseFunction

### 538. `getItemCount` (post)
参数: `itemId, dataVer, codeVer, callback`
URL: `getItemCount`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 539. `addItemCount` (post)
参数: `itemId, count, dataVer, codeVer, callback`
URL: `addItemCount`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 540. `useItem` (post)
参数: `itemId, dataVer, codeVer, callback`
URL: `useItem`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 541. `getItemMap` (post)
参数: `callback`
URL: `getItemMap`
请求体: `{}`
响应处理: createGetResponseFunction

### 542. `refreshItemMapCache` (post)
参数: `dataVer, codeVer, callback`
URL: `refreshItemMapCache`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 543. `getAnniversaryLoginList` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_anniversary_login_list`
请求体: `nil`
响应处理: createGetResponseFunction

### 544. `getAnniversaryLoginReward` (post)
参数: `rid, is_enough, dataVer, callback, isNeedWait, retryType`
URL: `get_anniversary_login_reward`
请求体: `{rid = rid`
响应处理: createGetResponseFunction

### 545. `getViewingHall` (get)
参数: `callback,isNeedWait, retryType`
URL: `get_viewing_hall`
请求体: `nil`
响应处理: createGetResponseFunction

### 546. `getViewingReward` (post)
参数: `id, is_free, is_email, callback, isNeedWait, retryType`
说明: 获取观影堂特权加送活动数据
URL: `get_viewing_reward`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 547. `getViewingHallPrivilegeInfo` (get)
参数: `callback,isNeedWait, retryType`
说明: 获取观影堂特权加送活动奖励
URL: `get_viewing_privilege_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 548. `getViewingHallPrivilegeReward` (get)
参数: `callback,isNeedWait, retryType`
URL: `get_viewing_privilege_reward`
请求体: `nil`
响应处理: createGetResponseFunction

### 549. `getSmithyInfo` (get)
参数: `callback,isNeedWait, retryType`
URL: `get_smithy_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 550. `getSmithyReward` (post)
参数: `rid, is_email, callback, isNeedWait, retryType`
URL: `get_smithy_reward`
请求体: `{rid = rid`
响应处理: createGetResponseFunction

### 551. `uploadWeaponRepairLog` (post)
参数: `logData, callback, isNeedWait, retryType`
URL: `upload_weapon_repair_log`
请求体: `logData`
响应处理: createGetResponseFunction

### 552. `getSachetAtticNewList` (get)
参数: `activity_id, callback, isNeedWait, retryType`
URL: `get_sachet_attic_new_list/`
响应处理: createGetResponseFunction

### 553. `exchangeAwardToSachetNew` (post)
参数: `activity_id, reward_id, is_email, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `exchange_award_to_sachet_new`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 554. `getWakingDreamInfo` (get)
参数: `callback,isNeedWait, retryType`
URL: `get_waking_dream_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 555. `getWakingDreamReward` (post)
参数: `rid, is_email, dataVer, callback, isNeedWait, retryType`
URL: `get_waking_dream_reward`
请求体: `{rid = rid`
响应处理: createGetResponseFunction

### 556. `unlockWakingDreamPayReward` (post)
参数: `jackpotId, callback, isNeedWait, retryType`
URL: `unlock_waking_dream_pay_reward`
请求体: `{jackpotId = jackpotId}`
响应处理: createGetResponseFunction

### 557. `getYuanbaoConsumptionInfo` (get)
参数: `callback,isNeedWait, retryType`
URL: `get_yuanbao_consumption_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 558. `getYuanbaoConsumptionReward` (post)
参数: `rid, is_email, callback, isNeedWait, retryType`
URL: `get_yuanbao_consumption_reward`
请求体: `{rid = rid`
响应处理: createGetResponseFunction

### 559. `getDanQingPavilionInfo` (get)
参数: `activityId, callback,isNeedWait, retryType`
URL: `get_danqing_pavilion_info/`
响应处理: createGetResponseFunction

### 560. `exchangeDanQingPavilionItem` (post)
参数: `activityId, id, rid, dataVer, callback, isNeedWait, retryType`
URL: `exchange_danqing_pavilion_item`
请求体: `{activityId = activityId`
响应处理: createGetResponseFunction

### 561. `getDanQingPavilionReward` (post)
参数: `activityId, id, dataVer, callback, isNeedWait, retryType`
URL: `get_danqing_pavilion_reward`
请求体: `{activityId = activityId`
响应处理: createGetResponseFunction

### 562. `getUserShenBings` (get)
参数: `callback,isNeedWait, retryType`
说明: 完成拳脚系统前置任务,创建拳脚系统信息
URL: `get_user_shenbings`
请求体: `nil`
响应处理: createGetResponseFunction

### 563. `createFistInfo` (post)
参数: `dataVer,codeVer,callback,isNeedWait, retryType`
说明: 获取拳脚系统数据
URL: `create_fist_info`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 564. `getFistFootInFo` (post)
参数: `dataVer,codeVer,callback,isNeedWait, retryType`
说明: 开始修行任务
URL: `get_fist_info`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 565. `startFistTask` (post)
参数: `taskId,dataVer,codeVer,callback, isNeedWait, retryType`
URL: `start_fist_task`
请求体: `{taskId = taskId`
响应处理: createGetResponseFunction

### 566. `stopFistTask` (post)
参数: `taskId, dataVer,codeVer,callback, isNeedWait, retryType`
URL: `stop_fist_task`
请求体: `{taskId = taskId`
响应处理: createGetResponseFunction

### 567. `finishFistTask` (post)
参数: `taskId, bagEnough, dataVer,codeVer,callback, isNeedWait, retryType`
URL: `finish_fist_task`
请求体: `{taskId = taskId`
响应处理: createGetResponseFunction

### 568. `speedUpFistTask` (post)
参数: `taskId,cost, dataVer,codeVer,callback, isNeedWait, retryType`
URL: `expedite_fist_task`
请求体: `{taskId = taskId`
响应处理: createGetResponseFunction

### 569. `upgradeTechnique` (post)
参数: `techniqueId, dataVer,codeVer,callback, isNeedWait, retryType`
URL: `upgrade_technique`
请求体: `{techniqueId = techniqueId`
响应处理: createGetResponseFunction

### 570. `extractCharacter` (post)
参数: `techniqueId, dataVer,codeVer,callback, isNeedWait, retryType`
URL: `grasp_technique_feature`
请求体: `{techniqueId = techniqueId`
响应处理: createGetResponseFunction

### 571. `replaceCharacter` (post)
参数: `techniqueId, dataVer,codeVer,callback, isNeedWait, retryType`
URL: `replace_technique_feature`
请求体: `{techniqueId = techniqueId`
响应处理: createGetResponseFunction

### 572. `resetTalentPage` (post)
参数: `talentPageId, dataVer,codeVer,callback, isNeedWait, retryType`
URL: `reset_fist_technique`
请求体: `{techniquePageId = talentPageId`
响应处理: createGetResponseFunction

### 573. `getTalentPageInfo` (post)
参数: `dataVer, codeVer,callback, isNeedWait, retryType`
URL: `get_talent_info`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 574. `getCharacterPoolInfo` (post)
参数: `poolId, dataVer, codeVer,callback, isNeedWait, retryType`
URL: `get_characterPool_info`
请求体: `{papool = poolId`
响应处理: createGetResponseFunction

### 575. `updataFistFlag` (post)
参数: `addFlags,deleteFlags, dataVer, codeVer,callback, isNeedWait, retryType`
URL: `updata_fist_flag`
请求体: `{addFlags = addFlags`
响应处理: createGetResponseFunction

### 576. `getFistTasks` (post)
参数: `dataVer, codeVer,callback, isNeedWait, retryType`
说明: 设置拳脚系统分支经验
URL: `get_fist_tasks`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 577. `testSetFistBranchExp` (post)
参数: `branchId,branchExp, dataVer,codeVer,callback, isNeedWait, retryType`
URL: `test_set_fist_branch_level`
请求体: `{branchExp = branchExp`
响应处理: createGetResponseFunction

### 578. `testSetFistReflectExp` (post)
参数: `exp,dataVer,codeVer,callback, isNeedWait, retryType`
URL: `test_set_fist_reflect_level`
请求体: `{exp = exp`
响应处理: createGetResponseFunction

### 579. `testSetFistTechniqueLevel` (post)
参数: `techniqueId,level,dataVer,codeVer,callback, isNeedWait, retryType`
URL: `test_set_fist_technique_level`
请求体: `{techniqueId = techniqueId`
响应处理: createGetResponseFunction

### 580. `testAddFeelPoint` (post)
参数: `number,dataVer,codeVer,callback, isNeedWait, retryType`
说明: 添加技巧心得页
URL: `test_add_fist_feel_point`
请求体: `{number = number`
响应处理: createGetResponseFunction

### 581. `testAddTalentPage` (post)
参数: `dataVer,codeVer,callback, isNeedWait, retryType`
说明: 切换技巧心得
URL: `test_add_talent_page`
请求体: `{dataVer = dataVer`
响应处理: createGetResponseFunction

### 582. `switchTalentPage` (post)
参数: `pageNum, codeVer, dataVer, callback, isNeedWait, retryType`
URL: `switch_talent_page`
请求体: `{pageIndex = pageNum`
响应处理: createGetResponseFunction

### 583. `getWuMenTrialInfo` (post)
参数: `dataVer, callback,isNeedWait, retryType`
URL: `get_wumen_trial_info`
请求体: `{dataVer = dataVer}`
响应处理: createGetResponseFunction

### 584. `getWuMenTrialReward` (post)
参数: `id, dataVer, callback, isNeedWait, retryType`
URL: `get_wumen_trial_reward`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 585. `checkEmailWhite` (post)
参数: `email, callback, isNeedWait, retryType`
说明: 获取招式对练详情
URL: `check_email_white`
请求体: `{email = email}`
响应处理: createGetResponseFunction

### 586. `getZhaoPracticeInfo` (post)
参数: `npcId , mid, currencyVersion, callback, isNeedWait, retryType`
说明: 对练
URL: `get_zhao_practiceInfo`
请求体: `{npcId = npcId`
响应处理: createGetResponseFunction

### 587. `zhaoPractice` (post)
参数: `npcId , mid, zhaoId, type, price, currencyVersion, callback, isNeedWait, retryType`
说明: 赠与残页
URL: `zhao_practice`
请求体: `{npcId = npcId`
响应处理: createGetResponseFunction

### 588. `giftZhaoPage` (post)
参数: `npcId , mid, zhaoId, callback, isNeedWait, retryType`
说明: 遗忘残页
URL: `gift_zhao_page`
请求体: `{npcId = npcId`
响应处理: createGetResponseFunction

### 589. `forgetZhaoPage` (post)
参数: `npcId , mid, zhaoId, callback, isNeedWait, retryType`
URL: `forget_zhao_page`
请求体: `{npcId = npcId`
响应处理: createGetResponseFunction

### 590. `getZhaoCaiJinBaoInfo` (get)
参数: `activity_id, callback, isNeedWait, retryType`
URL: `get_zhaocaijinbao_info/`
响应处理: createGetResponseFunction

### 591. `getZhaoCaiJinBaoReward` (post)
参数: `activity_id, id, reward_id, is_email, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `get_zhaocaijinbao_reward`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 592. `buyBlackGoods` (post)
参数: `goodsInfo , client_trans_id, mark, callback, isNeedWait, retryType`
URL: `buy_black_goods`
请求体: `{goodsInfo = goodsInfo`
响应处理: createGetResponseFunction

### 593. `getSutraPavilionList` (post)
参数: `activity_id, is_refresh, levelType, callback, isNeedWait, retryType`
URL: `get_sutra_pavilion_list`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 594. `buySutraPavilionGoods` (post)
参数: `activity_id, id, callback, isNeedWait, retryType`
URL: `buy_sutra_pavilion_goods`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 595. `getCuiLianCaiLiaoStoreList` (post)
参数: `activity_id, currencyVersion, callback, isNeedWait, retryType`
说明: 获取师门建设数据
URL: `get_cuiLianCaiLiao_store_list`
请求体: `{activityId = activity_id`
响应处理: createGetResponseFunction

### 596. `getTeacherBuildInFo` (post)
参数: `familyId,callback,isNeedWait, retryType`
说明: 开始师门建设任务
URL: `get_teacherBuild_info`
请求体: `{familyId = familyId}`
响应处理: createGetResponseFunction

### 597. `startTeacherBuildTask` (post)
参数: `taskId,familyId,callback, isNeedWait, retryType`
说明: 停止师门建设任务
URL: `start_teacherBuild_task`
请求体: `{taskId = taskId`
响应处理: createGetResponseFunction

### 598. `stopTeacherBuildTask` (post)
参数: `taskId,familyId,callback, isNeedWait, retryType`
说明: 完成师门建设任务
URL: `stop_teacherBuild_task`
请求体: `{taskId = taskId`
响应处理: createGetResponseFunction

### 599. `finishTeacherBuildTask` (post)
参数: `taskId, familyId ,callback, isNeedWait, retryType`
说明: 加速师门建设任务
URL: `finish_teacherBuild_task`
请求体: `{taskId = taskId`
响应处理: createGetResponseFunction

### 600. `speedUpTeacherBuildTask` (post)
参数: `taskId,cost,familyId,callback, isNeedWait, retryType`
说明: 获取师门建设任务列表
URL: `speedUp_teacherBuild_task`
请求体: `{taskId = taskId`
响应处理: createGetResponseFunction

### 601. `getTeacherBuildTasks` (post)
参数: `familyId,callback, isNeedWait, retryType`
说明: 更新师门建设日常任务标记
URL: `get_teacherBuild_tasks`
请求体: `{familyId = familyId}`
响应处理: createGetResponseFunction

### 602. `updataTeacherBuildFlag` (post)
参数: `addFlags,deleteFlags,familyId,callback, isNeedWait, retryType`
说明: 获取师门建筑数据
URL: `updata_teacherBuild_flag`
请求体: `{addFlags = addFlags`
响应处理: createGetResponseFunction

### 603. `getTeacherBuildData` (post)
参数: `familyId,callback, isNeedWait, retryType`
说明: 获取师门建筑材料信息
URL: `get_teacherBuild_list`
请求体: `{familyId = familyId}`
响应处理: createGetResponseFunction

### 604. `getTeacherBuildItems` (post)
参数: `familyId,callback, isNeedWait, retryType`
说明: 兴建师门建筑
URL: `get_teacherBuild_items`
请求体: `{familyId = familyId}`
响应处理: createGetResponseFunction

### 605. `buildTeacherBuild` (post)
参数: `buildTypeId,familyId,callback, isNeedWait, retryType`
说明: 获取建筑捐献信息
URL: `build_teacherBuild`
请求体: `{buildTypeId = buildTypeId`
响应处理: createGetResponseFunction

### 606. `getTeacherBuildDonateInfo` (post)
参数: `buildTypeId,familyId,callback, isNeedWait, retryType`
说明: 捐献建筑材料
URL: `get_teacherBuild_donateInfo`
请求体: `{buildTypeId = buildTypeId`
响应处理: createGetResponseFunction

### 607. `donateTeacherBuild` (post)
参数: `buildTypeId,donateId,donateState,familyId, currencyVersion, callback, isNeedWait, retryType`
说明: 师门建筑开放等级升级
URL: `donate_teacherBuild`
请求体: `{currencyVersion = currencyVersion`
响应处理: createGetResponseFunction

### 608. `upgradeTeacherBuild` (post)
参数: `buildTypeId,familyId,callback, isNeedWait, retryType`
说明: 获取师门名绩数据
URL: `upgrade_teacherBuild`
请求体: `{buildTypeId = buildTypeId`
响应处理: createGetResponseFunction

### 609. `getTeacherFeatData` (post)
参数: `familyId,callback,isNeedWait, retryType`
说明: 领取师门名绩奖励
URL: `get_teacherFeat_info`
请求体: `{familyId = familyId}`
响应处理: createGetResponseFunction

### 610. `getTeacherFeatReward` (post)
参数: `familyId,featId,dataVer,callback,isNeedWait, retryType`
说明: 师门建设测试接口
URL: `get_teacherFeat_reward`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 611. `testTeacherBuildAction` (post)
参数: `type,number,callback, isNeedWait, retryType`
说明: 测试接口，修改建筑经验
URL: `test_sect_build_action`
请求体: `{type = type`
响应处理: createGetResponseFunction

### 612. `testUpdateBuildingDegree` (post)
参数: `familyId,buildTypeId,number,callback, isNeedWait, retryType`
URL: `test_update_building_degree`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 613. `getSutraPavilionGoods` (post)
参数: `activity_id, id, is_email, dataVer, callback, isNeedWait, retryType`
URL: `get_sutra_pavilion_goods`
请求体: `{activity_id = activity_id`
响应处理: createGetResponseFunction

### 614. `buyCuiLianCaiLiaoStoreGoods` (post)
参数: `activity_id, id, currencyId, currencyVersion, callback, isNeedWait, retryType`
URL: `buy_cuiLianCaiLiao_store_goods`
请求体: `{activityId = activity_id`
响应处理: createGetResponseFunction

### 615. `getCuiLianCaiLiaoStoreReward` (post)
参数: `activity_id, id, is_email, dataVer, callback, isNeedWait, retryType`
URL: `get_cuiLianCaiLiao_store_reward`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 616. `exchangeCuiLianCaiLiaoStoreIntegral` (post)
参数: `activity_id, id, number, currencyVersion, callback, isNeedWait, retryType`
URL: `exchange_cuiLianCaiLiao_store_integral`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 617. `uploadClientEnvMessage` (post)
参数: `env, callback, isNeedWait, retryType`
URL: `upload_client_error_message`
请求体: `env`
响应处理: createGetResponseFunction

### 618. `TransferHomegateGroup` (post)
参数: `familyId, newFamilyId, callback, isNeedWait, retryType`
URL: `transfer_homegate_group`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 619. `testUpdateTechniqueFeature` (post)
参数: `techniqueId, characterId, dataVer,codeVer,callback, isNeedWait, retryType`
URL: `test_update_technique_feature`
请求体: `{techniqueId = techniqueId`
响应处理: createGetResponseFunction

### 620. `getSectMeritStore` (post)
参数: `familyId, isRefresh, callback, isNeedWait, retryType`
URL: `get_sect_merit_store`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 621. `buyMeritGoods` (post)
参数: `familyId, id, callback, isNeedWait, retryType`
URL: `buy_merit_goods`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 622. `getMeritGoods` (post)
参数: `familyId, id, dataVer, isSent, callback, isNeedWait, retryType`
说明: 获取散人装备武学心法限制条件数据
URL: `get_merit_goods`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 623. `getYouXiaMcmrestrictUpgradeCondition` (post)
参数: `familyId, currencyVersion, callback, isNeedWait, retryType`
说明: 散人升级装备武学心法限制
URL: `get_youxia_upgradeCondition`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 624. `youxiaUpgradeMcmrestrict` (post)
参数: `familyId, currencyVersion, callback, isNeedWait, retryType`
说明: 删除散人心法
URL: `youxia_upgrade_condition`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 625. `deleteYouXiaMcmrestrict` (get)
参数: `callback, isNeedWait, retryType`
URL: `delete_youxia_upgradeCondition`
请求体: `nil`
响应处理: createGetResponseFunction

### 626. `testUpdateUserFamily` (post)
参数: `familyId, callback, isNeedWait, retryType`
说明: 获取账号注销网址
URL: `test_update_user_family`
请求体: `{familyId = familyId}`
响应处理: createGetResponseFunction

### 627. `getLogoutAccountUrl` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_logoutAccount_url`
请求体: `nil`
响应处理: createGetResponseFunction

### 628. `getSectExchangeStore` (post)
参数: `familyId, callback, isNeedWait, retryType`
URL: `get_sect_exchangeStore`
请求体: `{familyId = familyId}`
响应处理: createGetResponseFunction

### 629. `buySectExchangeGoods` (post)
参数: `familyId, id, callback, isNeedWait, retryType`
说明: 删除美容丸初始化测试接口
URL: `buy_sect_exchangeGoods`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 630. `testDeleteMeiRongWanInit` (get)
参数: `callback, isNeedWait, retryType`
说明: 获取制作面具信息
URL: `test_delete_initial_meirongwan`
请求体: `nil`
响应处理: createGetResponseFunction

### 631. `getMakeMaskInfo` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_makeMask_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 632. `makeRandomMask` (post)
参数: `cost,grantType,callback, isNeedWait, retryType`
URL: `make_randomMask`
请求体: `{cost = cost`
响应处理: createGetResponseFunction

### 633. `makePayMask` (post)
参数: `id,spCost,grantType,callback, isNeedWait, retryType`
URL: `make_payMask`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 634. `getPayMakeMaskGiftInfo` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_payMask_gift_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 635. `receivePayMaskGift` (post)
参数: `id, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `receive_payMask_gift`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 636. `testGetTime` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_time`
请求体: `nil`
响应处理: createGetResponseFunction

### 637. `testGetTimeAsync` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_time`
请求体: `nil`
响应处理: createGetResponseFunction

### 638. `testGetTimeWaitText` (get)
参数: `waitText, callback, isNeedWait, retryType`
URL: `get_time`
响应处理: createGetResponseFunction

### 639. `testGetTimeWaitTextAsync` (get)
参数: `waitText, callback, isNeedWait, retryType`
URL: `get_time`
响应处理: createGetResponseFunction

### 640. `getSectRevitalizationInfo` (post)
参数: `familyId, callback, isNeedWait, retryType`
URL: `get_sectRevitalization_info`
请求体: `{familyId = familyId}`
响应处理: createGetResponseFunction

### 641. `getSectRevitalizationReward` (post)
参数: `familyId, buildTypeId, callback, isNeedWait, retryType`
URL: `get_sectRevitalization_reward`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 642. `getSectSupportShop` (post)
参数: `familyId, callback, isNeedWait, retryType`
URL: `get_sect_supportShop`
请求体: `{familyId = familyId}`
响应处理: createGetResponseFunction

### 643. `BuySectSupportGoods` (post)
参数: `familyId, id, callback, isNeedWait, retryType`
URL: `buy_sect_supportGoods`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 644. `uploadAbnormalHangUpTask` (post)
参数: `version, taskId, taskStartTime, extraData, callback, isNeedWait, retryType`
说明: 获取拳脚商店信息
URL: `upload_abnormal_hangUp_task`
请求体: `{version = version`
响应处理: createGetResponseFunction

### 645. `getFistFootShopInfo` (get)
参数: `callback, isNeedWait, retryType`
说明: 设置每日支付元宝数
URL: `get_fistFootShop_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 646. `setFistFootShopDailyCost` (post)
参数: `dailySelectCost, callback, isNeedWait, retryType`
URL: `set_fistFootShop_dailyCost`
请求体: `{dailySelectCost = dailySelectCost}`
响应处理: createGetResponseFunction

### 647. `buyFistFootShopDailyGoods` (post)
参数: `dayId,dataVer, callback, isNeedWait, retryType`
URL: `buy_fistFootShop_dailyGoods`
请求体: `{dayId = dayId`
响应处理: createGetResponseFunction

### 648. `buyFistFootShopSpecialOffer` (post)
参数: `specialOfferCost,dataVer, callback, isNeedWait, retryType`
URL: `buy_fistFootShop_specialOffer`
请求体: `{specialOfferCost = specialOfferCost`
响应处理: createGetResponseFunction

### 649. `canInherit` (get)
参数: `callback, isNeedWait, retryType`
URL: `canInherit`
请求体: `""`
响应处理: createGetResponseFunction

### 650. `getwxtranstwxplushasGainAfter202509291500` (get)
参数: `callback, isNeedWait, retryType`
URL: `check_user_gain_log`
请求体: `""`
响应处理: createGetResponseFunction

### 651. `testSetMeridianPageNum` (post)
参数: `num,callback, isNeedWait, retryType`
说明: 获取隐脉相关资源
URL: `test_set_meridian_talent_page`
请求体: `{num = num}`
响应处理: createGetResponseFunction

### 652. `getHiddenMeridianInfo` (get)
参数: `callback, isNeedWait, retryType`
说明: 开始破境
URL: `get_hidden_meridian_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 653. `startHiddenMeridianBreakThrough` (post)
参数: `id,version,currencyVersion,callback, isNeedWait, retryType`
说明: 加速破境
URL: `start_break_through_realm`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 654. `speedUpHiddenMeridianBreakThrough` (post)
参数: `id,cost,version,callback, isNeedWait, retryType`
说明: 完成破境
URL: `accelerate_break_through_realm`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 655. `finishHiddenMeridianBreakThrough` (post)
参数: `id,boostingEffect,version,callback, isNeedWait, retryType`
说明: 取消破境
URL: `finish_break_through_realm`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 656. `cancelHiddenMeridianBreakThrough` (post)
参数: `id,version,callback, isNeedWait, retryType`
说明: 开始冲脉
URL: `cancel_break_through_realm`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 657. `startAcupointActivate` (post)
参数: `id,version,callback, isNeedWait, retryType`
说明: 加速冲脉
URL: `start_thoroughfare_vessel`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 658. `speedUpAcupointActivate` (post)
参数: `id,cost,version,callback, isNeedWait, retryType`
说明: 完成冲脉
URL: `accelerate_thoroughfare_vessel`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 659. `finishAcupointActivate` (post)
参数: `id,version,callback, isNeedWait, retryType`
说明: 取消冲脉
URL: `finish_thoroughfare_vessel`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 660. `cancelAcupointActivate` (post)
参数: `id,version,callback, isNeedWait, retryType`
说明: 解锁玄络buff
URL: `cancel_thoroughfare_vessel`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 661. `unlockHiddenMeridianBuff` (post)
参数: `id,version,currencyVersion,callback, isNeedWait, retryType`
URL: `unlock_hidden_meridian_gems`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 662. `getSectGuidanceInfo` (post)
参数: `familyId, callback, isNeedWait, retryType`
URL: `get_sectGuidance_info`
请求体: `{familyId = familyId}`
响应处理: createGetResponseFunction

### 663. `executeSectGuidance` (post)
参数: `familyId, id, version, callback, isNeedWait, retryType`
URL: `execute_sectGuidance`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 664. `joinFamily` (post)
参数: `familyId, currencyVersion, callback, isNeedWait, retryType`
URL: `join_family`
请求体: `{familyId = familyId`
响应处理: createGetResponseFunction

### 665. `testResetSectGuidance` (get)
参数: `callback, isNeedWait, retryType`
URL: `test_reset_sect_guidance`
请求体: `nil`
响应处理: createGetResponseFunction

### 666. `exchangeYashiWelfareReward` (post)
参数: `id, number, type, currencyVersion, callback, isNeedWait, retryType`
URL: `exchange_yashi_welfare_reward`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 667. `getMerchantStoreList` (post)
参数: `merchantId, isRefresh, currencyVersion, dataVer, callback, isNeedWait, retryType`
URL: `get_merchant_store_list`
请求体: `{merchantId = merchantId`
响应处理: createGetResponseFunction

### 668. `buyMerchantGoods` (post)
参数: `merchantId, goodsList, recordList, currencyVersion, dataVer, callback, isNeedWait, retryType`
URL: `buy_merchant_goods`
请求体: `{merchantId = merchantId`
响应处理: createGetResponseFunction

### 669. `testCurrency` (post)
参数: `currencyId, num, action, currencyVersion, callback, isNeedWait, retryType`
URL: `test_currency`
请求体: `{currencyId = currencyId`
响应处理: createGetResponseFunction

### 670. `consumeSpecialProps` (post)
参数: `itemId, number, currencyVersion, callback, isNeedWait, retryType`
URL: `consume_special_props`
请求体: `{itemId = itemId`
响应处理: createGetResponseFunction

### 671. `getRechargeBenefitsInfo` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_recharge_benefits_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 672. `getRechargeBenefitsReward` (post)
参数: `id, isEmail, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `get_recharge_benefits_reward`
请求体: `{id = id`
响应处理: createGetResponseFunction

### 673. `getMerchantEventInfo` (post)
参数: `activityId, currencyVersion, callback, isNeedWait, retryType`
URL: `get_merchant_event_info`
请求体: `{activityId = activityId`
响应处理: createGetResponseFunction

### 674. `getActivityChallengeMapClearTimeInfo` (get)
参数: `callback, isNeedWait, retryType`
URL: `get_challengemap_task_info`
请求体: `nil`
响应处理: createGetResponseFunction

### 675. `getActivityChallengeMapClearReward` (post)
参数: `isEmail, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `get_challengemap_task_reward`
请求体: `{isEmail = isEmail`
响应处理: createGetResponseFunction

### 676. `getServerResourceCount` (post)
参数: `itemList, dataVer, currencyVersion, callback, isNeedWait, retryType`
URL: `get_server_resource_count`
请求体: `{itemList = itemList`
响应处理: createGetResponseFunction
