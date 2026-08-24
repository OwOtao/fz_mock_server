# 放置江湖 HTTP 协议字典

协议方法总数: **676** ｜ 提取自 `assets/src/app/extends/Http/HttpManager.lua`

## 统计
- POST: 463 ｜ GET: 210
- 含 URL: 649 ｜ 标准响应处理: 673

## 协议清单

### 1. `async` (unknown)
```
参数: funcName, ...
说明: 通用异步调用入口, 按 funcName 分派
```

### 2. `getTime` (get)
```
参数: func, isNeedWait, retryType, waitText
URL: get_time
```

### 3. `createRole` (post)
```
参数: func, isNeedWait, retryType
URL: create_role
请求体: ""
```

### 4. `getStoreData` (get)
```
参数: func, isNeedWait, retryType
URL: get_store_list_4
请求体: ""
```

### 5. `getAppStoreData` (get)
```
参数: func, isNeedWait, retryType
URL: get_applestore_list
请求体: ""
```

### 6. `getCheatType` (unknown)
```
参数: 
说明: 获取防作弊类型(本地)
```

### 7. `uploadUserData` (post)
```
参数: uType, func, isNeedWait, retryType, isNeedSave
URL: upload_user_file_3
```

### 8. `uploadUserDataWithoutSave` (unknown)
```
参数: uType, func, isNeedWait, retryType
```

### 9. `uploadLocalUserData` (post)
```
参数: uType, func, isNeedWait, retryType
URL: upload_user_file_5
```

### 10. `downloadUserData` (get)
```
参数: func, isNeedWait, retryType
URL: download_user_file_2
请求体: ""
```

### 11. `getReward` (get)
```
参数: type, func, isNeedWait, retryType
URL: get_reward/
```

### 12. `getReward2` (post)
```
参数: rType, trans_id, homeland_open, func, isNeedWait, retryType
URL: get_reward_2/
```

### 13. `updataUserName` (post)
```
参数: name, func, isNeedWait, retryType
URL: update_username
请求体: {name = name}
```

### 14. `buyGoods` (post)
```
参数: id, itemId, count, trans_id, others, discount, func, isNeedWait, retryType
URL: buy_goods_3/, buy_goods
```

### 15. `getGoodsInfo` (get)
```
参数: itemId, func, isNeedWait, retryType
URL: get_goods/
```

### 16. `getGoodsInfo_2` (post)
```
参数: itemId, others, func, isNeedWait, retryType
URL: get_goods_2/, check_fail_transaction/
```

### 17. `checkTrans` (post)
```
参数: transType, trans_id, func, isNeedWait, retryType
URL: check_fail_transaction_2/
```

### 18. `getYuanBao` (get)
```
参数: func, isNeedWait, retryType
URL: get_yuanbao
请求体: ""
```

### 19. `getRankingList` (post)
```
参数: page, func, isNeedWait, retryType
URL: get_rank_list_4
请求体: {page = page}
```

### 20. `getBoard` (post)
```
参数: ptype, page, func, isNeedWait, retryType
URL: get_board/
```

### 21. `getRemoveYuanBao` (get)
```
参数: num, trans_id, func, isNeedWait, retryType
URL: remove_yuanbao/
```

### 22. `checkLogin` (post)
```
参数: postData, func, isNeedWait, retryType
URL: login
请求体: postData
```

### 23. `getRandomWeaponDesc` (get)
```
参数: wType, func, isNeedWait, retryType
URL: get_random_weapon_desc/
```

### 24. `makeWeapon` (post)
```
参数: params, func, isNeedWait, retryType
URL: make_weapon
请求体: params
```

### 25. `upgradeWeapon` (post)
```
参数: params, func, isNeedWait, retryType
URL: upgrade_weapon
请求体: params
```

### 26. `getThrowWeaponData` (get)
```
参数: func, isNeedWait, retryType
URL: get_history_weapon
请求体: ""
```

### 27. `throwShenBingWeapon` (post)
```
参数: throwType, index, params, func, isNeedWait, retryType
URL: throw_weapon/
```

### 28. `getIsChangedName` (get)
```
参数: func, isNeedWait, retryType
URL: is_changed_name
请求体: ""
```

### 29. `getArchiveList` (get)
```
参数: func, isNeedWait, retryType
请求体: ""
```

### 30. `switchArchive` (get)
```
参数: switchTo, callback, isNeedWait, retryType
```

### 31. `useShopGoods` (get)
```
参数: itemId, func, isNeedWait, retryType
URL: use_shop_goods/
```

### 32. `testYueKa` (get)
```
参数: func, isNeedWait, retryType
URL: test_yueka
请求体: ""
```

### 33. `getJhmsDesc` (get)
```
参数: func, isNeedWait, retryType
URL: get_jhms_desc
请求体: ""
```

### 34. `getJhmsReward` (post)
```
参数: trans_id, homeland_open, days, func, isNeedWait, retryType
URL: get_jhms_reward
请求体: {trans_id = trans_id
```

### 35. `checkGoodsValid` (post)
```
参数: itemIds, func, isNeedWait, retryType
URL: check_goods_valid
请求体: {itemIds = itemIds}
```

### 36. `uploadCheat` (post)
```
参数: cheat, func, isNeedWait, retryType
URL: report_cheat
请求体: cheat
```

### 37. `getUserInfo` (post)
```
参数: userID, userType, func, isNeedWait, retryType
URL: get_user_info
请求体: {userid = userID
```

### 38. `getBiWuRankingList` (get)
```
参数: typeNUm, func, isNeedWait, retryType
URL: get_fight_board/
```

### 39. `sendBiWuWatch` (post)
```
参数: func, isNeedWait, retryType
URL: watch_fight
请求体: nil
```

### 40. `sendBiWuUnWatch` (post)
```
参数: params, func, isNeedWait, retryType
URL: unwatch_fight
请求体: params
```

### 41. `getBiWuFighMessage` (post)
```
参数: func, isNeedWait, retryType
URL: get_fight_msg2, join_fight
请求体: "", role_lv
```

### 42. `sendBiWuJoinFight` (post)
```
参数: func, isNeedWait, retryType
URL: join_fight2
请求体: ""
```

### 43. `sendBiWuFight` (post)
```
参数: fight_type, params, func, isNeedWait, retryType
URL: fight2/
```

### 44. `sendBiWuFightResult` (post)
```
参数: params, func, isNeedWait, retryType
URL: report_fight_result2
请求体: params
```

### 45. `sendBiWuFightCardId` (post)
```
参数: params, func, isNeedWait, retryType
URL: use_fight_card, get_fight_times
请求体: params, ""
```

### 46. `getBiWuFightTimes` (get)
```
参数: func, isNeedWait, retryType
URL: get_fight_times2
请求体: ""
```

### 47. `getBiWuFightYuanBao` (get)
```
参数: type, func, isNeedWait, retryType
URL: get_fight_yuanbao/
```

### 48. `getChanllengeMsg` (get)
```
参数: func, isNeedWait, retryType
URL: get_chanllenge_msg
请求体: ""
```

### 49. `getCanGuanZhan` (get)
```
参数: func, isNeedWait, retryType
URL: can_watch_fight
请求体: ""
```

### 50. `getFightRewardList` (get)
```
参数: func, isNeedWait, retryType
URL: get_fight_reward_list
请求体: ""
```

### 51. `getFightSelfReward` (post)
```
参数: params, func, isNeedWait, retryType
URL: get_fight_reward
请求体: params
```

### 52. `getFightWeekNotice` (get)
```
参数: func, isNeedWait, retryType
URL: get_fight_reward_notice
请求体: ""
```

### 53. `createAccount` (post)
```
参数: userid, func, isNeedWait, retryType
URL: create_account
请求体: ""
```

### 54. `uploadUselessUserData` (post)
```
参数: roleData, func, isNeedWait, retryType
URL: upload_user_file_4
请求体: {roleData
```

### 55. `downloadUserDataTang` (get)
```
参数: func, isNeedWait, retryType
URL: download_user_file_2
请求体: nil
```

### 56. `getEmailTang` (get)
```
参数: func, isNeedWait, retryType
URL: get_email
请求体: ""
```

### 57. `sendEmailTang` (post)
```
参数: email, event_type, func, isNeedWait, retryType
URL: send_email
请求体: {email = email
```

### 58. `loginDevice` (post)
```
参数: email, verify_code, func, isNeedWait, retryType
URL: login_device, verify_code, errcode
请求体: {verify_code = verify_code
```

### 59. `logoutDevice` (post)
```
参数: email, verify_code, callback, isNeedWait, retryType
URL: logout_device
请求体: {verify_code = verify_code
```

### 60. `logoutUnbindDevice` (post)
```
参数: callback, isNeedWait, retryType
URL: logout_device
请求体: nil
```

### 61. `bindDevice` (post)
```
参数: emailAddr, code, func, isNeedWait, retryType
URL: bind_device
请求体: {email = emailAddr
```

### 62. `getBindInfo` (get)
```
参数: callback, isNeedWait, retryType
URL: get_bind_info
请求体: ""
```

### 63. `sendVerifyCode` (post)
```
参数: sendType, sendKey, eventType, callback, isNeedWait, retryType
URL: send_verify_code
请求体: {send_type = sendType
```

### 64. `bindDevice2` (post)
```
参数: sendType, sendKey, verifyCode, callback, isNeedWait, retryType
URL: bind_device_2
请求体: {send_type = sendType
```

### 65. `sendPhoneVerifyCode` (post)
```
参数: phone, callback, isNeedWait, retryType
URL: realname_send
请求体: {phone = phone}
```

### 66. `bindShiMingInfo` (post)
```
参数: username, idcard, phone, code, callback, isNeedWait, retryType
URL: realname_auth
请求体: {username = username
```

### 67. `checkPaySign` (post)
```
参数: key, callback, isNeedWait, retryType
URL: check_pay_sign
请求体: {key = key}
```

### 68. `checkActionPaySign` (post)
```
参数: key, activityId, callback, isNeedWait, retryType
说明: 江湖秘宝活动充值
URL: check_pay_sign
请求体: {key = key
```

### 69. `checkJHMBActionPaySign` (post)
```
参数: key, activityId,dataVer, currencyVersion, callback, isNeedWait, retryType
URL: check_pay_sign
请求体: {key = key
```

### 70. `upDayGameTime` (post)
```
参数: time, callback, isNeedWait, retryType
URL: up_day_gametime
请求体: {time = time}
```

### 71. `loginDevice2` (post)
```
参数: sendType, sendKey, verifyCode, callback, isNeedWait, retryType
URL: login_device_2
请求体: {send_type = sendType
```

### 72. `logoutDevice2` (post)
```
参数: sendType, sendKey, verifyCode, callback, isNeedWait, retryType
URL: logout_device_2
请求体: {send_type = sendType
```

### 73. `logoutUnbindDevice2` (post)
```
参数: callback, isNeedWait, retryType
URL: logout_device_2
请求体: nil
```

### 74. `getGameUserInfo` (post)
```
参数: noticeId, currencyVersion,callback, isNeedWait, retryType
URL: get_game_user_info_2
请求体: {notice_version = noticeId
```

### 75. `getHistoryNotice` (get)
```
参数: callback, isNeedWait, retryType
URL: get_history_notice
请求体: nil
```

### 76. `CreateHeir` (post)
```
参数: heirName, callback, isNeedWait, retryType
说明: 传承
URL: createNextRoleTask
请求体: {name = heirName}
```

### 77. `inherit` (post)
```
参数: roleData, userId, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: finishNextRoleTask
请求体: {roleData = {roleData}
```

### 78. `getInheritHistoryRoleAttr` (post)
```
参数: data, callback, isNeedWait, retryType
URL: get_chuanchen_user_info
请求体: data
```

### 79. `isOpenVisitTask` (get)
```
参数: callback, isNeedWait, retryType
URL: is_visitor_shop_open
请求体: nil
```

### 80. `getMarketStoreList` (get)
```
参数: callback, isNeedWait, retryType
URL: black_market_store
请求体: nil
```

### 81. `getSignList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_sign_list
请求体: nil
```

### 82. `getSignPrize` (post)
```
参数: trans_id, stringDate, itemId, homeland_open, callback, isNeedWait, retryType
URL: get_sign_prize
请求体: {trans_id = trans_id
```

### 83. `getSignHistoryPrize` (post)
```
参数: trans_id, prizeId, callback, isNeedWait, retryType
URL: get_sign_history_prize
请求体: {trans_id = trans_id
```

### 84. `checkFailedNormalSign` (post)
```
参数: trans_id, callback, isNeedWait, retryType
URL: check_failed_normal_sign
请求体: {trans_id = trans_id}
```

### 85. `getNewYearFestivalState` (get)
```
参数: id, callback, isNeedWait, retryType
```

### 86. `getXianShiPoint` (get)
```
参数: callback, isNeedWait, retryType
URL: get_xianshilibao_gift_list_2
请求体: nil
```

### 87. `resetXianShiPoint` (post)
```
参数: callback, isNeedWait, retryType
URL: reset_xianshilibao_points, check_failed_history_sign
请求体: nil, {trans_id = trans_id}
```

### 88. `testFastivalDate` (post)
```
参数: productId, callback, isNeedWait, retryType
请求体: {key = productId}
```

### 89. `clearTestFestivalData` (post)
```
参数: callback, isNeedWait, retryType
请求体: nil
```

### 90. `getFestivalOrderId` (post)
```
参数: orderType, orderInfo, callback, isNeedWait, retryType
URL: get_order_id/
```

### 91. `rollBackOrderStatus` (post)
```
参数: orderType, orderid, orderInfo, callback, isNeedWait, retryType
```

### 92. `getFirstFestivalGiftList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_first_festival_gift
请求体: nil
```

### 93. `getFirstFestivalGift` (post)
```
参数: orderid, callback, isNeedWait, retryType
URL: receive_first_festival_gift
请求体: {order_id = orderid
```

### 94. `getMultiFestivalGiftList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_multi_festival_gift_list
请求体: nil
```

### 95. `getMultiFestivalGift` (post)
```
参数: kry, orderid, itemId, callback, isNeedWait, retryType
URL: receive_multi_festival_gift
请求体: {key = kry
```

### 96. `getSpringFestivalList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_spring_festival_list
请求体: nil
```

### 97. `getZhiZuoZuRoleList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_npc_list
请求体: nil
```

### 98. `addZhiZuoZuNpcRecord` (get)
```
参数: npcId, callback, isNeedWait, retryType
URL: add_npc_record/
```

### 99. `getMaskList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_mask_list
请求体: nil
```

### 100. `refreshMaskList` (post)
```
参数: orderid, callback, isNeedWait, retryType
URL: refresh_mask_list
请求体: {order_id = orderid}
```

### 101. `buyMaskPiece` (post)
```
参数: orderid, id, callback, isNeedWait, retryType
URL: buy_mask_piece_2
请求体: {order_id = orderid
```

### 102. `getDailyPoint` (get)
```
参数: callback, isNeedWait, retryType
URL: get_daily_point
请求体: nil
```

### 103. `updateDailyPoint` (post)
```
参数: id, point, callback, isNeedWait, retryType
URL: update_daily_point/
```

### 104. `getDailyBoard` (get)
```
参数: callback, isNeedWait, retryType
URL: get_daily_board
请求体: nil
```

### 105. `getLongZhouDailyBoard` (get)
```
参数: type, callback, isNeedWait, retryType
URL: get_boat_board/
```

### 106. `getBuyOrderId` (get)
```
参数: callback, isNeedWait, retryType
URL: get_buy_order_id
请求体: nil
```

### 107. `getAllTypePoint` (get)
```
参数: callback, isNeedWait, retryType
URL: get_all_type_point, get_daily_board
请求体: nil
```

### 108. `getDailyNotice` (get)
```
参数: callback, isNeedWait, retryType
URL: get_daily_Notice
请求体: nil
```

### 109. `getDailyRewardList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_daily_reward_list
请求体: nil
```

### 110. `getDailyReward` (post)
```
参数: transid, callback, isNeedWait, retryType
URL: get_daily_reward
请求体: {trans_id = transid}
```

### 111. `rollDailyReward` (get)
```
参数: callback, isNeedWait, retryType
URL: roll_daily_reward
请求体: nil
```

### 112. `getEventList` (post)
```
参数: type, currencyVersion, callback, isNeedWait, retryType
URL: get_activity_list
请求体: {type = type
```

### 113. `delActivityCache` (get)
```
参数: callback, isNeedWait, retryType
URL: del_activity_cache, errcode, dev_point
请求体: nil
```

### 114. `getDevotePoint` (get)
```
参数: callback, isNeedWait, retryType
URL: get_devote_point, errcode, msg, errmsg
请求体: nil
```

### 115. `addDevotePoint` (post)
```
参数: ptype, point, callback, isNeedWait, retryType
URL: add_devote_point, errcode, id, itemId, leidongjiutian, itype
请求体: {type = ptype
```

### 116. `getDevoteList` (post)
```
参数: dtype, menpai, callback, isNeedWait, retryType
URL: get_devote_list, huakaibingdicanye, tiyunzongcanye, errcode, id, itemId
请求体: {type = dtype
```

### 117. `getDevoteListByYuanbao` (post)
```
参数: dtype, orderid, menpai, callback, isNeedWait, retryType
URL: get_devote_list_by_yuanbao, huakaibingdicanye, tiyunzongcanye, order_id, points, errcode
请求体: {order_id = orderid, nil
```

### 118. `updateMenpaiGongxiangdian` (post)
```
参数: orderid, itemId, points, info, callback, isNeedWait, retryType
URL: update_menpai_gongxiangdian
请求体: {order_id = orderid
```

### 119. `getChapmanItemList` (get)
```
参数: npcId, callback, isNeedWait, retryType
URL: trader_store/
```

### 120. `buyChapmanItem` (post)
```
参数: npcId, itemId, transid, voucherNum, callback, isNeedWait, retryType
URL: buy_trader_goods
请求体: {npc_id = npcId
```

### 121. `addChapmanItemCount` (post)
```
参数: npcId, itemId, callback, isNeedWait, retryType
URL: del_buy_npc_time
请求体: {npc_id = npcId
```

### 122. `addDeadCurrency` (post)
```
参数: id, number, isNeed, callback, isNeedWait, retryType
URL: add_user_mingbi
请求体: {type = id
```

### 123. `getDeadCurrencyGoodsList` (post)
```
参数: callback, isNeedWait, retryType
URL: get_mingbi_list
请求体: nil
```

### 124. `buyDeadCurrencyGoods` (post)
```
参数: orderid, id, callback, isNeedWait, retryType
URL: buy_mingbi_goods
请求体: {order_id = orderid
```

### 125. `getHelpDocument` (get)
```
参数: callback, isNeedWait, retryType
URL: get_help_document
请求体: nil
```

### 126. `getVoucherPrize` (post)
```
参数: voucherId, activityId, callback, isNeedWait, retryType
URL: get_voucher_prize_2
请求体: {voucher = voucherId
```

### 127. `cleanVoucherRecord` (get)
```
参数: callback, isNeedWait, retryType
URL: clean_voucher_record_2
请求体: nil
```

### 128. `checkCanExam` (get)
```
参数: id, callback, isNeedWait, retryType
URL: check_whether_exam/
```

### 129. `updateExamPoint` (post)
```
参数: id, rightCount, point, time, skillExp, cheat, callback, isNeedWait, retryType
URL: upload_exam_point
请求体: {type = id
```

### 130. `getExamPoint` (get)
```
参数: id, callback, isNeedWait, retryType
URL: get_exam_point/
```

### 131. `generateExamReward` (get)
```
参数: id, callback, isNeedWait, retryType
URL: crontab_gen_exam_reward/
```

### 132. `getExamReward` (post)
```
参数: id, orderid, callback, isNeedWait, retryType
URL: get_exam_reward
请求体: {trans_id = orderid
```

### 133. `delUserRankReward` (get)
```
参数: callback, isNeedWait, retryType
URL: delete_user_point_rank
请求体: nil
```

### 134. `delUserPoint` (get)
```
参数: callback, isNeedWait, retryType
URL: delete_user_point
请求体: nil
```

### 135. `getUserOfficial` (get)
```
参数: callback, isNeedWait, retryType
URL: get_user_guanzhi
请求体: nil
```

### 136. `getChenHao` (get)
```
参数: callback, isNeedWait, retryType
URL: get_user_designation
请求体: nil
```

### 137. `getFenLu` (get)
```
参数: callback, isNeedWait, retryType
URL: get_guanzhi_fenlu
请求体: nil
```

### 138. `uploadOfficialAchievement` (post)
```
参数: zhengji, guanzhi, callback, isNeedWait, retryType
URL: upload_zhengji
请求体: {zhengji = zhengji
```

### 139. `officialResignation` (get)
```
参数: callback, isNeedWait, retryType
URL: delete_my_guanzhi
请求体: nil
```

### 140. `delOfficialLimit` (get)
```
参数: callback, isNeedWait, retryType
URL: delete_ciguan_redis
请求体: nil
```

### 141. `delExamAllData` (get)
```
参数: callback, isNeedWait, retryType
请求体: nil
```

### 142. `calaOfficialAchievement` (get)
```
参数: callback, isNeedWait, retryType
URL: crontab_count_zhengji, get_daily_reward_list
请求体: nil
```

### 143. `getPersonalBoatScore` (post)
```
参数: familyId, callback, isNeedWait, retryType
URL: personal_boat_msg
请求体: {menpai = familyId}
```

### 144. `getAllFamilyScore` (get)
```
参数: callback, isNeedWait, retryType
URL: all_menpai_top
请求体: nil
```

### 145. `getBoatRewardList` (get)
```
参数: callback, isNeedWait, retryType
URL: can_get_duanwu_reward
请求体: nil
```

### 146. `getBoatReward` (post)
```
参数: transid, itype, callback, isNeedWait, retryType
URL: get_boat_reward
请求体: {trans_id = transid
```

### 147. `getDuanwuRewardNotice` (get)
```
参数: type, callback, isNeedWait, retryType
URL: get_duanwu_reward_notice/
```

### 148. `checkCanJoinDragonBoat` (get)
```
参数: callback, isNeedWait, retryType
URL: check_can_play_boat
请求体: nil
```

### 149. `updateDragonBoatPoint` (post)
```
参数: menpai, point, time, callback, isNeedWait, retryType
URL: update_boat_point
请求体: {menpai = menpai
```

### 150. `resetDuanWuReward` (get)
```
参数: callback, isNeedWait, retryType
URL: test_reset_my_reward
请求体: nil
```

### 151. `getRankingListByOne` (post)
```
参数: id, callback, isNeedWait, retryType
URL: get_board/
```

### 152. `getJhSanYouList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_jhsanyou_list
请求体: nil
```

### 153. `voteToJhsanyou` (post)
```
参数: type, id, callback, isNeedWait, retryType
URL: vote_to_jhsanyou
请求体: {itype = type
```

### 154. `clearApiData` (post)
```
参数: str, callback, isNeedWait, retryType
请求体: {act = str}
```

### 155. `getShopInfo` (post)
```
参数: shopId, callback, isNeedWait, retryType
URL: get_shop_info
请求体: {shop_id = shopId}
```

### 156. `shopExchangeGoods` (post)
```
参数: tab, callback, isNeedWait, retryType
URL: shop_exchange_goods
请求体: tab
```

### 157. `rollBackExchage` (post)
```
参数: transid, callback, isNeedWait, retryType
URL: roll_back_exchange, zhounianqin1
请求体: {client_trans_id = transid}
```

### 158. `addCurrency` (post)
```
参数: tab, callback, isNeedWait, retryType
URL: add_currency
请求体: tab
```

### 159. `clearShopRecord` (post)
```
参数: shopId, callback, isNeedWait, retryType
URL: clear_my_shop_record
请求体: {shop_id = shopId}
```

### 160. `addActivityPoint` (post)
```
参数: point, activityId, callback, isNeedWait, retryType
URL: add_currency
请求体: {number = point
```

### 161. `clearPointRecord` (post)
```
参数: activityId, callback, isNeedWait, retryType
URL: clear_my_shop_record, act, keyao, id, tiaoxi, game
请求体: {shop_id = activityId}
```

### 162. `addRecordCount` (post)
```
参数: stat_data, callback, isNeedWait, retryType
URL: upload_fzjh_stat
请求体: {stat_data = stat_data}
```

### 163. `getServerList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_partition_list
请求体: ""
```

### 164. `migrateToNewPackage` (post)
```
参数: email, code, callback, isNeedWait, retryType
URL: migrate_to_new_package
请求体: {email = email
```

### 165. `switchServer` (get)
```
参数: id, callback, isNeedWait, retryType
URL: switch_partition/
```

### 166. `getServerList2` (get)
```
参数: callback, isNeedWait, retryType
URL: get_partition_list2
请求体: ""
```

### 167. `switchServer2` (get)
```
参数: id, callback, isNeedWait, retryType
URL: switch_partition2/
```

### 168. `migrateToNewPackage2` (post)
```
参数: email, code, serverId, callback, isNeedWait, retryType
URL: migrate_to_new_package2
请求体: {email = email
```

### 169. `partitionClear` (get)
```
参数: callback, isNeedWait, retryType
URL: partition_clear
请求体: ""
```

### 170. `testReceiveAnniversaryReward` (get)
```
参数: date, callback, isNeedWait, retryType
URL: test_receive_anniversary_reward/
```

### 171. `resetAnniversaryRewardList` (get)
```
参数: callback, isNeedWait, retryType
URL: reset_anniversary_reward_list
请求体: nil
```

### 172. `getAnniversaryRewardList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_anniversary_reward_list
请求体: nil
```

### 173. `getAnniversaryReward` (post)
```
参数: rewardList, callback, isNeedWait, retryType
URL: get_anniversary_reward
请求体: {list = rewardList}
```

### 174. `getUserUploadInfo` (get)
```
参数: callback, isNeedWait, retryType
URL: get_user_upload_info
请求体: nil
```

### 175. `saveUserInfo` (post)
```
参数: phoneStr, addrStr, nameStr, qqStr, callback, isNeedWait, retryType
URL: save_user_info
请求体: {phone = phoneStr
```

### 176. `addMoneyCeiling` (post)
```
参数: money, callback, isNeedWait, retryType
URL: add_money_ceiling
请求体: {number = money}
```

### 177. `getTeacherTaskPointList` (post)
```
参数: posList, callback, isNeedWait, retryType
URL: get_same_menpai_user_list
请求体: posList
```

### 178. `addTeacherTaskRecord` (post)
```
参数: posList, callback, isNeedWait, retryType
URL: add_zhipai_task_record
请求体: posList
```

### 179. `getTeacherTaskRecord` (get)
```
参数: callback, isNeedWait, retryType
URL: get_zhipai_task_record
请求体: nil
```

### 180. `getTeacherTaskRewaard` (post)
```
参数: rewardId, callback, isNeedWait, retryType
URL: get_zhipai_task_reward
请求体: {reward_id = rewardId}
```

### 181. `refreshTeacherTaskList` (post)
```
参数: count, callback, isNeedWait, retryType
URL: fresh_task_by_yuanbao
请求体: {yuanbao = count}
```

### 182. `resetTeacherTask` (get)
```
参数: type, callback, isNeedWait, retryType
URL: test_reset_task/
```

### 183. `getWishList2` (get)
```
参数: callback, isNeedWait, retryType
URL: get_wish_list/2
请求体: nil
```

### 184. `getWishList1` (get)
```
参数: callback, isNeedWait, retryType
URL: get_wish_list/1
请求体: nil
```

### 185. `uploadWishData` (post)
```
参数: wishVal, wishType, wishId, callback, isNeedWait, retryType
请求体: {wish_val = wishVal
```

### 186. `recordWishedData` (post)
```
参数: recordId, wishUserId, callback, isNeedWait, retryType
请求体: {record_id = recordId
```

### 187. `getSeventhReward1` (get)
```
参数: callback, isNeedWait, retryType
URL: get_seventh_reward/1
请求体: nil
```

### 188. `getSeventhReward2` (get)
```
参数: callback, isNeedWait, retryType
URL: get_seventh_reward/2
请求体: nil
```

### 189. `findRoommate` (post)
```
参数: roommateId, roomId, callback, isNeedWait, retryType
URL: find_roommate
请求体: {roommate_id = roommateId
```

### 190. `TestWish1` (get)
```
参数: callback, isNeedWait, retryType
URL: test_wish/1
请求体: nil
```

### 191. `TestWish3` (get)
```
参数: callback, isNeedWait, retryType
URL: test_wish/3
请求体: nil
```

### 192. `TestWish4` (get)
```
参数: callback, isNeedWait, retryType
URL: test_wish/4
请求体: nil
```

### 193. `TestWish5` (get)
```
参数: callback, isNeedWait, retryType
URL: test_wish/5
请求体: nil
```

### 194. `resetActiveTask` (get)
```
参数: type, callback, isNeedWait, retryType
URL: add_record/
```

### 195. `getYuanBaoCostGiftList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_yuanbao_plan_gift_list
请求体: nil
```

### 196. `receiveYuanBaoPlanGift` (post)
```
参数: rid, isEmail, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: receive_yuanbao_plan_gift
请求体: {rid = rid
```

### 197. `testWish` (get)
```
参数: num, callback, isNeedWait, retryType
URL: test_wish/
```

### 198. `countSingleRecordWithType` (get)
```
参数: type, callback, isNeedWait, retryType
URL: count_single_record/
```

### 199. `getPlayGhost` (post)
```
参数: callback, isNeedWait, retryType
URL: update_currency_by_type, add
请求体: nil, {currency = list
```

### 200. `viewCurrencyByType` (post)
```
参数: currency_type, currencyVersion,callback, isNeedWait, retryType
URL: view_currency_by_type
请求体: {currency_type = currency_type
```

### 201. `addCurrencyByType` (post)
```
参数: num, callback, isNeedWait, retryType
URL: add_currency_by_type
请求体: {currency = {mingbi = num}}
```

### 202. `joinGhostTimes` (get)
```
参数: callback, isNeedWait, retryType
URL: count_single_record/join_ghost
请求体: nil
```

### 203. `finishGhostTimes` (get)
```
参数: callback, isNeedWait, retryType
URL: count_single_record/finish_ghost
请求体: nil
```

### 204. `updateCurrencyByType` (post)
```
参数: action, cType, count, addType, callback, isNeedWait, retryType
URL: update_currency_by_type
请求体: {action = action
```

### 205. `updateCurrencyByTable` (post)
```
参数: action, list, addType, callback, isNeedWait, retryType
URL: update_currency_by_type
请求体: {action = action
```

### 206. `getTeacherTaskShop` (post)
```
参数: getType, familyId, callback, isNeedWait, retryType
URL: get_teacher_shop
请求体: {type = getType
```

### 207. `buyTeacherTaskShopItem` (post)
```
参数: id, callback, isNeedWait, retryType
说明: 添加单条记录
URL: buy_teacher_good
请求体: {rid = id}
```

### 208. `addSingleRecord` (post)
```
参数: type, callback, isNeedWait, retryType
说明: 添加多条记录
URL: addSingleRecord
请求体: type
```

### 209. `countMultiRecord` (post)
```
参数: type, callback, isNeedWait, retryType
说明: 上传内挂数据
URL: count_multi_record
请求体: type
```

### 210. `uploadClientData` (post)
```
参数: type, data, callback, isNeedWait, retryType
说明: 查询数据
请求体: {type = type
```

### 211. `getClientData` (post)
```
参数: tb, callback, isNeedWait, retryType
说明: 删除数据库对应标识的数据
请求体: {type = tb.type
```

### 212. `delAllData` (post)
```
参数: type, callback, isNeedWait, retryType
请求体: {type = type}
```

### 213. `getBiWuFightEnd` (get)
```
参数: func, isNeedWait, retryType
URL: get_out_fight_stage, add_record/lunjian
请求体: ""
```

### 214. `getActionState` (post)
```
参数: id, postList, callback, isNeedWait, retryType
URL: get_game_activity/
```

### 215. `updateOrderState` (post)
```
参数: callback, isNeedWait, retryType
URL: api/v5/, api/service/, update_order_state
```

### 216. `getXianShiGiftBag` (get)
```
参数: itemId, callback, isNeedWait, retryType
URL: get_limit_package/
```

### 217. `getToken` (get)
```
参数: callback, isNeedWait, retryType
URL: get_token
请求体: nil
```

### 218. `resetDailyRecord` (get)
```
参数: callback, isNeedWait, retryType
说明: 神兵淬炼接口
URL: resetDailyRecord/1
请求体: nil
```

### 219. `incrWeaponCuilianNum` (post)
```
参数: wid, results, cuilianCount, callback, isNeedWait, retryType
说明: 筛除单条数据
URL: incr_weapon_cuilian_num
请求体: {wid = wid
```

### 220. `updateDataState` (post)
```
参数: tb, callback, isNeedWait, retryType
请求体: {id = tb.id
```

### 221. `getWeaponCuilianNum` (post)
```
参数: wid, itemId, callback, isNeedWait, retryType
URL: get_weapon_cuilian_num, errcode, add_point, total_count, errmsg
请求体: {wid = wid
```

### 222. `respectTeacher` (get)
```
参数: callback, isNeedWait, retryType
URL: respect_teacher
请求体: nil
```

### 223. `resetDailyRecord` (get)
```
参数: callback, isNeedWait, retryType
URL: resetDailyRecord/1
请求体: nil
```

### 224. `deleteClientData` (post)
```
参数: delType, callback, isNeedWait, retryType
请求体: {type = delType}
```

### 225. `getSpendPlanGiftList` (get)
```
参数: actionId, callback, isNeedWait, retryType
URL: get_spend_plan_gift_list/
```

### 226. `receiveSpendPlanGiftList` (post)
```
参数: actionId, num, callback, isNeedWait, retryType
URL: receive_spend_plan_gift_list/
```

### 227. `getActionSpendInfo` (get)
```
参数: actionId, callback, isNeedWait, retryType
URL: get_spend_info/
```

### 228. `resetSpendPlanGiftList` (get)
```
参数: flag, callback, isNeedWait, retryType
URL: test_spend_plan/
```

### 229. `getLoginRewardInfo` (get)
```
参数: callback, isNeedWait, retryType
URL: get_login_reward_info
请求体: nil
```

### 230. `getLoginYuanbao` (get)
```
参数: callback, isNeedWait, retryType
URL: get_login_yuanbao
请求体: nil
```

### 231. `deleteLoginYuanbaoCache` (get)
```
参数: callback, isNeedWait, retryType
URL: delete_login_yuanbao_cache
请求体: nil
```

### 232. `addSpendPlanGiftList` (get)
```
参数: flag, actionType, num, callback, isNeedWait, retryType
URL: test_spend_plan/
```

### 233. `getPayLotteryGiftList` (post)
```
参数: is_refresh, callback, isNeedWait, retryType
URL: get_lottery_list
请求体: {is_refresh = is_refresh}
```

### 234. `getPayLotteryGift` (post)
```
参数: order_id, callback, isNeedWait, retryType
URL: do_lottery
请求体: {order_id = order_id}
```

### 235. `getShareLink` (get)
```
参数: callback, isNeedWait, retryType
URL: get_share_link
请求体: nil
```

### 236. `doShare` (get)
```
参数: callback, isNeedWait, retryType
URL: do_share
请求体: nil
```

### 237. `bePutCkItems` (post)
```
参数: itemData, ckName, ver, callback, isNeedWait, retryType
URL: beput_ckitems
请求体: {itemId = itemId
```

### 238. `outGoingCkItems` (post)
```
参数: itemData, ckName, ver, callback, isNeedWait, retryType
URL: outgoing_ckitems
请求体: {itemId = itemId
```

### 239. `getCkItemsList` (post)
```
参数: ckName, localVer, callback, isNeedWait, retryType
说明: 获取对方仓储ID
-- function HttpManager:getCkitemsListByUid(ckName,uid,callback, isNeedWait, retryType)
--     callback = self:createGetResponseFunction(callback)
--  
URL: get_ckitems_list, get_ckitems_list_by_uid
请求体: {ckname = ckName
```

### 240. `delCkItems` (post)
```
参数: ckName, callback, isNeedWait, retryType
URL: del_ckitems
请求体: {ckname = ckName}
```

### 241. `getNewNpcChapmanItemList` (get)
```
参数: npcId, callback, isNeedWait, retryType
URL: get_npc_store_list/
```

### 242. `buyNewNpcChapmanItem` (post)
```
参数: npcId, itemId, transid, couponsId, callback, isNeedWait, retryType
URL: buy_npc_goods
请求体: {client_trans_id = transid
```

### 243. `exchangeYinPiao` (post)
```
参数: number, type, callback, isNeedWait, retryType
URL: exchange_yinpiao
请求体: {number = number
```

### 244. `renameHome` (post)
```
参数: mid, new_name, point, callback, isNeedWait, retryType
URL: rename_home
请求体: {mid = mid
```

### 245. `getLocationMap` (post)
```
参数: loc_mark, callback, isNeedWait, retryType
说明: 获取购房列表
URL: get_location_map
请求体: {loc_mark = loc_mark}
```

### 246. `getHouseStoreList` (post)
```
参数: npcId, is_refresh, callback, isNeedWait, retryType
URL: get_house_store_list
请求体: {npcId = npcId
```

### 247. `buyHomeland` (post)
```
参数: npcId, fqId, callback, isNeedWait, retryType
URL: buy_homeland
请求体: {npcId = npcId
```

### 248. `getLandStoreList` (post)
```
参数: fbId, npcId, callback, isNeedWait, retryType
URL: get_land_store_list
请求体: {fbId = fbId
```

### 249. `biddingLand` (post)
```
参数: dpId, npcId, price, callback, isNeedWait, retryType
URL: bidding_land
请求体: {dpId = dpId
```

### 250. `getbiddingLand` (post)
```
参数: dpId, callback, isNeedWait, retryType
URL: get_bidding_land
请求体: {dpId = dpId}
```

### 251. `querybiddingInfo` (get)
```
参数: callback, isNeedWait, retryType
URL: query_bidding_info
请求体: nil
```

### 252. `moveHomeland` (post)
```
参数: dpId, mid, callback, isNeedWait, retryType
URL: move_home_land
请求体: {dpId = dpId
```

### 253. `getBiddingReturnPoint` (post)
```
参数: dpId, callback, isNeedWait, retryType
说明: 放入家具
URL: get_bidding_return_point
请求体: {dpId = dpId}
```

### 254. `putinFurniture` (post)
```
参数: mid, roomId, furnitureId, extra, localVer, callback, isNeedWait, retryType
URL: putin_furniture
请求体: {mid = mid
```

### 255. `removeFurniture` (post)
```
参数: mid, fid, localVer, callback, isNeedWait, retryType
URL: remove_furniture
请求体: {mid = mid
```

### 256. `getUserMap` (post)
```
参数: mapId, userid, localVer, callback, isNeedWait, retryType
URL: get_user_map
请求体: {mid = mapId
```

### 257. `getCommonFuben` (post)
```
参数: mapId, callback, isNeedWait, retryType
URL: get_common_fuben
请求体: {fbId = mapId}
```

### 258. `saveEmployeeList` (post)
```
参数: type, npcId, list, callback, isNeedWait, retryType
URL: save_employee_list
请求体: {type = type
```

### 259. `getEmployList` (get)
```
参数: npcId, mid, callback, isNeedWait, retryType
URL: get_employee_list/
```

### 260. `addEmployee` (post)
```
参数: hid, objId, mid, npcId, push_data, callback, isNeedWait, retryType
URL: add_employee
请求体: {hid = hid
```

### 261. `getEmployRoleData` (post)
```
参数: objId, mid, callback, isNeedWait, retryType
请求体: {objId = objId
```

### 262. `updateEmployRoleData` (post)
```
参数: objId, mid, zc_type, zc_val, currency, callback, isNeedWait, retryType
请求体: {objId = objId
```

### 263. `deleteEmployee` (post)
```
参数: objId, mid, callback, isNeedWait, retryType
URL: delete_employee
请求体: {objId = objId
```

### 264. `transformRoom` (post)
```
参数: fjId, mid, attr, point, upload, callback, isNeedWait, retryType
URL: transform_room
请求体: {fjId = fjId
```

### 265. `roomExtension` (post)
```
参数: mid, attr, point, upload, callback, isNeedWait, retryType
URL: extension_room
请求体: {mid = mid
```

### 266. `restoreUserMap` (post)
```
参数: mid, callback, isNeedWait, retryType
说明: 更新家园相关数据
URL: restore_user_map, remove_room
请求体: {mid = mid}, {mid = mid
```

### 267. `updateHomeAttr` (post)
```
参数: mid, fj_update, pr_update, jj_update, cost, callback, isNeedWait, retryType
URL: update_home_attr, yinpiao
请求体: {mid = mid
```

### 268. `getAffairList` (post)
```
参数: bizType, mid, limit, callback, isNeedWait, retryType
URL: get_affair_list/
```

### 269. `pushAffair` (post)
```
参数: affairTb, callback, isNeedWait, retryType
URL: push_affair
请求体: affairTb
```

### 270. `processRoomAffair` (post)
```
参数: aid, deal_type, process_type, callback, isNeedWait, retryType
说明: 处理发薪事务
URL: process_affair
请求体: {aid = aid
```

### 271. `processPayAffairs` (post)
```
参数: aids, callback, isNeedWait, retryType
URL: process_pay_affairs
请求体: {aids = aids}
```

### 272. `upgrandeUserMap` (post)
```
参数: mid, new_fqId, yinpiao_num, callback, isNeedWait, retryType
说明: 获取指定UID的仓库信息
URL: upgrande_user_map
请求体: {mid = mid
```

### 273. `getCkItemsListByUid` (post)
```
参数: uid, ckname, callback, isNeedWait, retryType
说明: 修改房间的相关属性
URL: get_ckitems_list_by_uid
请求体: {uid = uid
```

### 274. `revampRoomAttr` (post)
```
参数: fjId, mid, attr, callback, isNeedWait, retryType
说明: 获取欠了多少管理费
URL: revamp_room_attr
请求体: {fjId = fjId
```

### 275. `getManagePayment` (get)
```
参数: dpId, callback, isNeedWait, retryType
说明: 上传特殊家具的一些属性（目前只有悬兵洞、藏衣阁使用）
URL: get_manage_payment/
```

### 276. `uploadFurnitureExtra` (post)
```
参数: mid, attr, callback, isNeedWait, retryType
URL: upload_furniture_extra
请求体: {mid = mid
```

### 277. `recycleLand` (post)
```
参数: dpId, callback, isNeedWait, retryType
URL: recycle_land
请求体: {dpId = dpId}
```

### 278. `updateEmployeeExtra` (post)
```
参数: mid, up_data, callback, isNeedWait, retryType
URL: update_employee_extra
请求体: {mid = mid
```

### 279. `testHomeland` (post)
```
参数: type, tb, callback, isNeedWait, retryType
说明: 测试接口，设置地皮过期时间
URL: test_homeland/
```

### 280. `setAuctionTime` (post)
```
参数: time, callback, isNeedWait, retryType
说明: 上传副本的额外属性。
URL: set_auction_time
请求体: {time = time}
```

### 281. `uploadMapExtra` (post)
```
参数: mid, attr, point, callback, isNeedWait, retryType
URL: upload_map_extra
请求体: {mid = mid
```

### 282. `getLocationMax` (get)
```
参数: mapIndex, callback, isNeedWait, retryType
URL: get_location_max/
```

### 283. `getShenShiReward` (post)
```
参数: type, objId, mid, up_data, callback, isNeedWait, retryType
URL: get_shenshi_reward
请求体: {type = type
```

### 284. `exchangeLuckyPoint` (post)
```
参数: itemId, callback, isNeedWait, retryType
说明: 获取自己的房间信息
URL: exchange_lucky_point
请求体: {itemId = itemId}
```

### 285. `getAllRooms` (post)
```
参数: mid, roomType, callback, isNeedWait, retryType
URL: get_all_rooms
请求体: {mid = mid
```

### 286. `getAllPersons` (post)
```
参数: mid, jobType, callback, isNeedWait, retryType
URL: get_all_persons
请求体: {mid = mid
```

### 287. `getLuckyGoods` (post)
```
参数: refresh, callback, isNeedWait, retryType
URL: get_lucky_goods
请求体: {is_refresh = refresh}
```

### 288. `buyLuckyGoods` (post)
```
参数: itemId, id, callback, isNeedWait, retryType
URL: buy_lucky_goods
请求体: {itemId = itemId
```

### 289. `getQiXiRecord` (get)
```
参数: callback, isNeedWait, retryType
说明: 上传七夕数据
URL: get_qixi_record
请求体: nil
```

### 290. `addQiXiRecord` (post)
```
参数: uploadStr, callback, isNeedWait, retryType
说明: 测试接口，删除所有数据
URL: add_qixi_record
请求体: {type = uploadStr}
```

### 291. `allQiXiDelete` (get)
```
参数: callback, isNeedWait, retryType
URL: all_qixi_delete
请求体: nil
```

### 292. `testModifyQiXiCtime` (get)
```
参数: daynum, callback, isNeedWait, retryType
URL: modify_qixi_ctime/
```

### 293. `getPuRenNumAndRoomNum` (post)
```
参数: mid, actionType, callback, isNeedWait, retryType
URL: get_all_numrsper
请求体: {mid = mid
```

### 294. `setPuRenStatus` (post)
```
参数: mid, rwId, type, time, callback, isNeedWait, retryType
说明: 储物箱售卖商人
URL: make_servant_change
请求体: {mid = mid
```

### 295. `getStorageBox` (get)
```
参数: baseId, callback, isNeedWait, retryType
说明: 购买储物箱
URL: get_storage_box/
```

### 296. `buyStorageBox` (post)
```
参数: npcId, itemId, transid, fid, callback, isNeedWait, retryType
说明: 家园开启
URL: buy_storage_box
请求体: {client_trans_id = transid
```

### 297. `getHomeSwitch` (post)
```
参数: callback, isNeedWait, retryType
说明: 获取房契信息
URL: get_home_switch
请求体: {}
```

### 298. `getHouseInfo` (post)
```
参数: callback, isNeedWait, retryType
说明: 补领地契
URL: get_house_info
请求体: nil
```

### 299. `getLandInfo` (post)
```
参数: callback, isNeedWait, retryType
URL: get_land_info
请求体: nil
```

### 300. `getDiscountCoupon` (post)
```
参数: awardList, callback, isNeedWait, retryType
URL: get_discount_coupon
请求体: awardList
```

### 301. `getActionTime` (post)
```
参数: callback, isNeedWait, retryType
URL: get_yueka_times
请求体: nil
```

### 302. `getActionAward` (post)
```
参数: callback, isNeedWait, retryType
URL: give_yueka_days
请求体: nil
```

### 303. `getNewDailyList` (post)
```
参数: activity_id, callback, isNeedWait, retryType
URL: get_newdaily_lists
请求体: {activity_id = activity_id}
```

### 304. `receiveNewDailyReward` (post)
```
参数: activity_id, type, callback, isNeedWait, retryType
URL: get_newdaily_award
请求体: {activity_id = activity_id
```

### 305. `checkItemIsCanUse` (post)
```
参数: itemId, number, callback, isNeedWait, retryType
URL: employ_materials
请求体: {itemId = itemId
```

### 306. `getActionTimes` (post)
```
参数: action, callback, isNeedWait, retryType
URL: get_config_times
请求体: {com_config = action}
```

### 307. `submitAction` (post)
```
参数: action, quantity, callback, isNeedWait, retryType
URL: remove_config_point
请求体: {com_config = action
```

### 308. `getGuaikeReward` (post)
```
参数: isMenKe, menKeId, mid, guaikeLv, callback, isNeedWait, retryType
URL: get_guaike_reward
请求体: {isMenKe = isMenKe
```

### 309. `addLandGift` (post)
```
参数: gift_type, objId, callback, isNeedWait, retryType
URL: add_land_gift
请求体: {gifTypt = gift_type
```

### 310. `getMenPaiHongBao` (post)
```
参数: type, callback, isNeedWait, retryType
URL: get_menpai_hongbao
请求体: {type = type}
```

### 311. `testExchangeGoods` (post)
```
参数: itemId, num, callback, isNeedWait, retryType
URL: test_exchange_goods
请求体: {itemId = itemId
```

### 312. `detectionGoods` (post)
```
参数: itemId, callback, isNeedWait, retryType
URL: detection_goods
请求体: {itemId = itemId}
```

### 313. `getWebConfig` (get)
```
参数: callback, isNeedWait, retryType
说明: 获取家园消耗
URL: getWebConfig
请求体: nil
```

### 314. `getHomelandCost` (get)
```
参数: mid, callback, isNeedWait, retryType
URL: get_homeland_cost/
```

### 315. `getEquinoxTimes` (post)
```
参数: type, callback, isNeedWait, retryType
URL: get_equinox_times
请求体: {type = type}
```

### 316. `removeEquinoxPoint` (post)
```
参数: type, callback, isNeedWait, retryType
URL: remove_equinox_point
请求体: {type = type}
```

### 317. `getAttributeTimes` (post)
```
参数: callback, isNeedWait, retryType
URL: get_attribute_times
请求体: nil
```

### 318. `removeAttributePoint` (post)
```
参数: callback, isNeedWait, retryType
说明: 获取师门团体信息
URL: remove_attribute_point
请求体: nil
```

### 319. `getUserGroup` (post)
```
参数: userId, teacherId, menpai, isCache, callback, isNeedWait, retryType
说明: 获取舍友亲密度
URL: get_user_group
请求体: {userid = userId
```

### 320. `getUserIntimacy` (post)
```
参数: userId, callback, isNeedWait, retryType
说明: 更新用户亲密度
URL: get_user_intimacy
请求体: {to_uid = userId}
```

### 321. `updateUserIntimacy` (post)
```
参数: userId, intimacy, event, callback, isNeedWait, retryType
说明: 获取所有舍友的亲密度
URL: update_user_intimacy
请求体: {to_uid = userId
```

### 322. `getAllIntimacy` (get)
```
参数: callback, isNeedWait, retryType
说明: 获取玩家进境排行
URL: get_all_intimacy
请求体: nil
```

### 323. `getGroupRank` (get)
```
参数: callback, isNeedWait, retryType
URL: get_group_rank
请求体: nil
```

### 324. `removeManpaiTeam` (get)
```
参数: callback, isNeedWait, retryType
说明: 送礼
URL: test_remove_menpai_team
请求体: nil
```

### 325. `sendGift` (post)
```
参数: userId, itemId, itemCount, addIntimacy, addPrestige, callback, isNeedWait, retryType
说明: 收礼
URL: send_gift
请求体: {to_uid = userId
```

### 326. `getGift` (post)
```
参数: userId, callback, isNeedWait, retryType
说明: 检查舍友是否有给你送礼
URL: get_gift
请求体: {from_uid = userId}
```

### 327. `checkHasGift` (post)
```
参数: userId, callback, isNeedWait, retryType
URL: check_has_gift
请求体: {from_uid = userId}
```

### 328. `addUserPrestige` (post)
```
参数: addPrestige, event, callback, isNeedWait, retryType
URL: add_user_prestige
请求体: {addPrestige = addPrestige
```

### 329. `getUserPrestige` (post)
```
参数: callback, isNeedWait, retryType
说明: 新副本重置
URL: get_user_prestige
请求体: nil
```

### 330. `refreshFubenByYuanBao` (post)
```
参数: mapList, callback, isNeedWait, retryType
URL: refresh_fuben_by_yuanbao
请求体: {map_list = mapList}
```

### 331. `getPrestigeGoods` (post)
```
参数: npcid, is_refresh, callback, isNeedWait, retryType
URL: get_prestige_goods
请求体: {npc_id = npcid
```

### 332. `buyPrestigeGoods` (post)
```
参数: itemId, trans_id, npc_id, callback, isNeedWait, retryType
URL: buy_prestige_goods
请求体: {itemId = itemId
```

### 333. `updateUserPrestige` (post)
```
参数: callback, isNeedWait, retryType
URL: update_user_prestige
请求体: nil
```

### 334. `setSoleTitle` (get)
```
参数: callback, isNeedWait, retryType
URL: set_sole_title
请求体: nil
```

### 335. `useHomeBw` (post)
```
参数: zc_val, prId, mid, bwid, callback, isNeedWait, retryType
说明: 网络属性变更接口（各种货币及服务器相关的属性）
URL: use_homebw
请求体: {zc_val = zc_val
```

### 336. `addCurrencyNumber` (post)
```
参数: currency_tb, eventType, params, callback, isNeedWait, retryType
请求体: {currency = currency_tb
```

### 337. `getQiXiRankBoard` (get)
```
参数: callback, isNeedWait, retryType
URL: get_qixi_board
请求体: nil
```

### 338. `getQiXiRankBoatReward` (post)
```
参数: transid, type, callback, isNeedWait, retryType
URL: get_qixi_reward
请求体: {trans_id = transid
```

### 339. `getQiXiTaskInFo` (post)
```
参数: actionId, callback, isNeedWait, retryType
URL: get_qixi_task_info
请求体: {actionId = actionId}
```

### 340. `TakeQiXiTask` (post)
```
参数: actionId, callback, isNeedWait, retryType
URL: take_qixi_task
请求体: {actionId = actionId}
```

### 341. `FinishQiXiTask` (post)
```
参数: actionId, callback, isNeedWait, retryType
说明: 充值测试接口
URL: finish_qixi_task
请求体: {actionId = actionId}
```

### 342. `testChongzhi` (get)
```
参数: rechargeType, callback, isNeedWait, retryType
说明: 获取副本开放状态
URL: test_chongzhi/
```

### 343. `getConfigFuben` (post)
```
参数: mapId, callback, isNeedWait, retryType
URL: get_config_fuben
请求体: {fbId = mapId}
```

### 344. `getDiyGoods` (post)
```
参数: isRefresh, callback, isNeedWait, retryType
URL: get_diy_goods
请求体: {is_refresh = isRefresh}
```

### 345. `getDiyInfos` (get)
```
参数: callback, isNeedWait, retryType
URL: get_diy_infos
请求体: nil
```

### 346. `buyDiyGoods` (post)
```
参数: callback, isNeedWait, retryType
URL: buy_diy_goods
请求体: nil
```

### 347. `addHomeBw` (post)
```
参数: bwId, number, callback, isNeedWait, retryType
URL: add_homebw
请求体: {bwid = bwId
```

### 348. `getActivityCalendar` (get)
```
参数: callback, isNeedWait, retryType
URL: get_activity_calendar, servant, lunjian
请求体: nil
```

### 349. `getGrowthInfo` (post)
```
参数: requirement, callback, isNeedWait, retryType
URL: get_growth_info
请求体: {requirement = requirement}
```

### 350. `addZhounianJifen` (post)
```
参数: addType, number, callback, isNeedWait, retryType
URL: add_zhounian_jifen, get_dream_world
请求体: {addType = addType, nil
```

### 351. `getDreamGoods` (get)
```
参数: callback, isNeedWait, retryType
说明: 购买梦呓商品
URL: get_dream_goods
请求体: nil
```

### 352. `buyDreamGood` (post)
```
参数: onlyId, period, callback, isNeedWait, retryType
说明: 获取传承前学习的其它门派技能
URL: buy_dream_goods
请求体: {onlyId = onlyId
```

### 353. `getOtherSkills` (post)
```
参数: inheritIndex, callback, isNeedWait, retryType
说明: 从前辈处学习技能
URL: get_other_skills
请求体: {inheritIndex = inheritIndex}
```

### 354. `studyOtherSkill` (post)
```
参数: userid, skillid, callback, isNeedWait, retryType
说明: 测试接口，添加技能
URL: study_other_skill
请求体: {userid = userid
```

### 355. `testOtherSkill` (post)
```
参数: userid, skillid, callback, isNeedWait, retryType
URL: test_other_skill
请求体: {userid = userid
```

### 356. `uploadDreamRoleData` (post)
```
参数: dreamRoleData, callback, isNeedWait, retryType
URL: upload_dream_role
请求体: {roleAttr = dreamRoleData}
```

### 357. `getDreamRoleData` (get)
```
参数: callback, isNeedWait, retryType
URL: get_dream_role
请求体: nil
```

### 358. `getWebReward` (post)
```
参数: params, callback, isNeedWait, retryType
URL: get_web_reward
请求体: params
```

### 359. `reportGainLog` (post)
```
参数: logData, callback, isNeedWait, retryType
说明: 日志上传
URL: report_gain_log
请求体: {log_data = logData}
```

### 360. `uploadAcquisitionLog` (post)
```
参数: _logs, callback, isNeedWait, retryType
URL: upload_acquisition_log, unlockTalent, dreamCoins
请求体: _logs
```

### 361. `uploadEventRecord` (post)
```
参数: params, callback, isNeedWait, retryType
URL: upload_event_record
请求体: {params = params}
```

### 362. `getEventRecord` (get)
```
参数: callback, isNeedWait, retryType
URL: get_event_record
请求体: nil
```

### 363. `submitEventRecord` (get)
```
参数: callback, isNeedWait, retryType
说明: 楼层结算
URL: submit_event_record
请求体: nil
```

### 364. `dreamFloorComplete` (post)
```
参数: roleAttr, callback, isNeedWait, retryType
说明: 梦境楼层结算
URL: dream_floor_complete
请求体: {roleAttr = roleAttr}
```

### 365. `dreamWorldComplete` (post)
```
参数: uploadParams, callback, isNeedWait, retryType
URL: dreamworld_complete
请求体: {roleAttr = uploadParams.roleAttr
```

### 366. `checkDreamRoleDataIsOverdue` (post)
```
参数: userData, callback, isNeedWait, retryType
URL: settle_overdue_dream
请求体: {userData}
```

### 367. `updateUnlockRecord` (post)
```
参数: events, callback, isNeedWait, retryType
URL: update_unlock_record
请求体: {events = events}
```

### 368. `getDreamRewardSkill` (get)
```
参数: callback, isNeedWait, retryType
URL: get_dream_reward_skill
请求体: nil
```

### 369. `getLoginYuandanInfo` (get)
```
参数: callback, isNeedWait, retryType
URL: get_login_yuandan_info
请求体: nil
```

### 370. `setLoginYuandanReward` (post)
```
参数: rewardId, callback, isNeedWait, retryType
URL: set_login_yuandan_reward
请求体: {rewardId = rewardId}
```

### 371. `getYuanbaoLotteryList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_yuanbao_lottery_list
请求体: nil
```

### 372. `doYuanbaoLottery` (get)
```
参数: callback, isNeedWait, retryType
说明: 异人录活动信息
URL: do_yuanbao_lottery
请求体: nil
```

### 373. `getMingRenLotteryList` (get)
```
参数: callback, isNeedWait, retryType
说明: 异人录活动抽奖
URL: get_mingren_lottery_list
请求体: nil
```

### 374. `doMingRenLottery` (get)
```
参数: times, callback, isNeedWait, retryType
说明: 江湖名武录活动信息
URL: do_mingren_lottery/
```

### 375. `getMingWuLotteryList` (get)
```
参数: callback, isNeedWait, retryType
说明: 江湖名武录抽奖
URL: get_mingwu_lottery_list
请求体: nil
```

### 376. `doMingWuLottery` (get)
```
参数: times, callback, isNeedWait, retryType
URL: do_mingwu_lottery/
```

### 377. `getZhenPinGeLotteryList` (get)
```
参数: activity_id, callback, isNeedWait, retryType
URL: get_zhenpinge_lottery_list/
```

### 378. `doZhenPinGeLottery` (post)
```
参数: activity_id, times, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: do_zhenpinge_lottery
请求体: {times = times
```

### 379. `exchangeZhenPinGeGoods` (post)
```
参数: activity_id, id, num, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: exchange_zhenpinge_goods
请求体: {id = id
```

### 380. `bfmingtieExchangeSpcl` (get)
```
参数: callback, isNeedWait, retryType
URL: bfmingtie_exchange_spcl
请求体: nil
```

### 381. `getCreateBooks` (get)
```
参数: callback, isNeedWait, retryType
URL: get_books
请求体: nil
```

### 382. `useCreateProp` (post)
```
参数: propId, userLv, skillDataId, callback, isNeedWait, retryType
URL: use_create_prop
请求体: {prop = propId
```

### 383. `useImproveProp` (post)
```
参数: propId, userLv, zhaoIndex, skillDataId, callback, isNeedWait, retryType
URL: use_improve_prop
请求体: {prop = propId
```

### 384. `addProp` (post)
```
参数: propId, count, callback, isNeedWait, retryType
URL: add_prop
请求体: {prop = propId
```

### 385. `getPropList` (get)
```
参数: propType, callback, isNeedWait, retryType
URL: get_propList/
```

### 386. `createZhao` (post)
```
参数: zhaoType, userLv, tujianLv, callback, isNeedWait, retryType
URL: create_zhao
请求体: {methods = zhaoType
```

### 387. `testDeleteBook` (post)
```
参数: action, callback, isNeedWait, retryType
URL: test_delete_book
请求体: {action = action}
```

### 388. `deleteCompletedBook` (post)
```
参数: skillId, callback, isNeedWait, retryType
URL: delete_book
请求体: {skillId = skillId}
```

### 389. `completeBook` (post)
```
参数: skillName, callback, isNeedWait, retryType
URL: complete_book
请求体: {skillName = skillName}
```

### 390. `getZhaoColors` (get)
```
参数: callback, isNeedWait, retryType
URL: get_zhaoColors
请求体: nil
```

### 391. `unlockZhaoColor` (post)
```
参数: colorId, callback, isNeedWait, retryType
URL: unlock_zhaoColor
请求体: {colorId = colorId}
```

### 392. `getZhaoDscs` (post)
```
参数: templateId, callback, isNeedWait, retryType
URL: get_zhaoDscs
请求体: {templateId = templateId}
```

### 393. `unlockZhaoDsc` (post)
```
参数: xiLieId, templateId, callback, isNeedWait, retryType
URL: unlock_zhaoDsc_xiLie
请求体: {xiLieId = xiLieId
```

### 394. `getSkillNameAffixs` (get)
```
参数: callback, isNeedWait, retryType
URL: get_skillName_affixs
请求体: nil
```

### 395. `unlockSkillNameAffixs` (post)
```
参数: nameAffixsId, callback, isNeedWait, retryType
URL: unlock_skillName_affixs
请求体: {affixsId = nameAffixsId}
```

### 396. `setZhaoAttr` (post)
```
参数: params, callback, isNeedWait, retryType
URL: set_zhao_attr
请求体: params
```

### 397. `getZhaoSuccessRate` (post)
```
参数: userLv, callback, isNeedWait, retryType
URL: get_successRate
请求体: {lv = userLv}
```

### 398. `learnSkillBook` (post)
```
参数: skillId, callback, isNeedWait, retryType
URL: learn_book
请求体: {skillId = skillId}
```

### 399. `acceptTask` (post)
```
参数: task_id, extra_data, callback, isNeedWait, retryType
URL: accept_task
请求体: {task_id = task_id
```

### 400. `finishTask` (post)
```
参数: task_id, extra_data, callback, isNeedWait, retryType
URL: finish_task
请求体: {task_id = task_id
```

### 401. `resetTask` (post)
```
参数: task_id, callback, isNeedWait, retryType
URL: reset_task
请求体: {task_id = task_id}
```

### 402. `submitTask` (post)
```
参数: task_id, callback, isNeedWait, retryType
URL: submit_task
请求体: {task_id = task_id}
```

### 403. `getTaskInfo` (post)
```
参数: task_id, callback, isNeedWait, retryType
URL: get_task_info
请求体: {task_id = task_id}
```

### 404. `testUpdateTask` (post)
```
参数: task_id, updateInfo, callback, isNeedWait, retryType
URL: test_update_task
请求体: {task_id = task_id
```

### 405. `testClearBook` (post)
```
参数: skill_id, callback, isNeedWait, retryType
URL: test_clear_book
请求体: {skill_id = skill_id}
```

### 406. `deleteCreateBookDayLimit` (get)
```
参数: callback, isNeedWait, retryType
URL: delete_book_dayLimit
请求体: nil
```

### 407. `testAddZhaoNum` (post)
```
参数: skill_id, num, callback, isNeedWait, retryType
URL: test_add_zhaoNum
请求体: {skillId = skill_id
```

### 408. `getDailyTaskList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_daily_task_list
请求体: nil
```

### 409. `getDailyTaskReward` (post)
```
参数: rid, isEmail, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: get_daily_task_reward
请求体: {rid = rid
```

### 410. `addDailyTaskPoint` (post)
```
参数: task_id, callback, isNeedWait, retryType
URL: add_daily_task_point
请求体: {task_id = task_id}
```

### 411. `getLoginRewardList` (get)
```
参数: activity_id, callback, isNeedWait, retryType
URL: get_login_reward_list/
```

### 412. `getLoginReward` (post)
```
参数: activityId, rid, isEmail, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: get_login_reward
请求体: {activityId = activityId
```

### 413. `getFundActivityInfo` (get)
```
参数: actionId, callback, isNeedWait, retryType
URL: get_login_reward_list/
```

### 414. `getFundReward` (post)
```
参数: actionId, rid, callback, isNeedWait, retryType
URL: get_login_reward
请求体: {activity_id = actionId
```

### 415. `setProductMark` (post)
```
参数: actionId, key, callback, isNeedWait, retryType
URL: set_product_mark
请求体: {activity_id = actionId
```

### 416. `getSpringNewReward` (get)
```
参数: callback, isNeedWait, retryType
URL: get_spring_new_reward
请求体: nil
```

### 417. `receiveSpringNewReward` (get)
```
参数: rid, callback, isNeedWait, retryType
URL: receive_spring_new_reward/
```

### 418. `getIntelligenceData` (get)
```
参数: callback, isNeedWait, retryType
请求体: nil
```

### 419. `uploadIntelligenceData` (post)
```
参数: params, callback, isNeedWait, retryType
请求体: params
```

### 420. `buyIntelligence` (get)
```
参数: callback, isNeedWait, retryType
URL: buy_day_intelligence
请求体: nil
```

### 421. `getTechniqueList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_technique_list
请求体: nil
```

### 422. `readIntelligence` (post)
```
参数: id, type, callback, isNeedWait, retryType
URL: read_intelligence
请求体: {intelligence_id = id
```

### 423. `deleteDayIntelligence` (get)
```
参数: callback, isNeedWait, retryType
URL: delete_day_intelligence
请求体: nil
```

### 424. `deleteIntelligence` (post)
```
参数: type, callback, isNeedWait, retryType
URL: delete_bought_intelligence
请求体: {type = type}
```

### 425. `getSpendRewardList` (get)
```
参数: actionId, callback, isNeedWait, retryType
URL: get_spend_reward_list/
```

### 426. `getSpendReward` (post)
```
参数: actionId, rid, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: get_spend_reward
请求体: {activity_id = actionId
```

### 427. `containsBlockedWord` (post)
```
参数: str, callback, isNeedWait, retryType
URL: contains_blocked_word
请求体: {s = str}
```

### 428. `getAnswerStatus` (post)
```
参数: activityId, callback, isNeedWait, retryType
请求体: {activity_id = activityId}
```

### 429. `setAnswerStatus` (post)
```
参数: activityId, type, passNum, callback, isNeedWait, retryType
请求体: {activity_id = activityId
```

### 430. `getEmails` (get)
```
参数: callback, isNeedWait, retryType
URL: get_email_info
请求体: nil
```

### 431. `readEmail` (post)
```
参数: id, callback, isNeedWait, retryType
URL: read_email
请求体: {id = id}
```

### 432. `deleteEmail` (get)
```
参数: id, callback, isNeedWait, retryType
URL: delete_email/
```

### 433. `getEmailReward` (post)
```
参数: id, familyId, retrievables, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: get_email_reward
请求体: {id = id
```

### 434. `getAllEmailRewardList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_email_rewards_list
请求体: nil
```

### 435. `getAllEmailReward` (post)
```
参数: familyId, retrievables, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: get_all_email_rewards
请求体: {familyId = familyId
```

### 436. `deleteIsFinishEmails` (get)
```
参数: callback, isNeedWait, retryType
URL: delete_processed_emails
请求体: nil
```

### 437. `maskUpgrade` (post)
```
参数: params, currencyVersion, callback, isNeedWait, retryType
URL: mask_upgrade
请求体: {params = params
```

### 438. `getLotteryTreasureList` (get)
```
参数: activity_id, callback, isNeedWait, retryType
URL: get_lottery_treasure_list/
```

### 439. `lotteryTreasureResult` (post)
```
参数: activity_id, callback, isNeedWait, retryType
URL: lottery_treasure_result
请求体: {activity_id = activity_id}
```

### 440. `lotteryTreasureReward` (post)
```
参数: activity_id, rid, is_email, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: lottery_treasure_reward
请求体: {activity_id = activity_id
```

### 441. `getLotteryTreasureExchangeShop` (post)
```
参数: activity_id, callback, isNeedWait, retryType
URL: get_lottery_treasure_exchange_shop
请求体: {activity_id = activity_id}
```

### 442. `lotteryTreasureExchangeGoods` (post)
```
参数: activity_id, goods_id, callback, isNeedWait, retryType
URL: lottery_treasure_exchange_goods
请求体: {activity_id = activity_id
```

### 443. `buyLotteryTreasureCurrency` (post)
```
参数: activity_id, number, callback, isNeedWait, retryType
URL: buy_lottery_treasure_currency
请求体: {activity_id = activity_id
```

### 444. `addGuideTaskPoint` (post)
```
参数: taskId, point, callback, isNeedWait, retryType
URL: add_guide_task_point
请求体: {task_id = taskId
```

### 445. `getGuideTaskPoint` (get)
```
参数: callback, isNeedWait, retryType
URL: get_guide_task_point
请求体: nil
```

### 446. `getRecordSkills` (get)
```
参数: callback, isNeedWait, retryType
URL: get_record_skills
请求体: nil
```

### 447. `recordSkill` (post)
```
参数: skill_id, skill_type, callback, isNeedWait, retryType
URL: record_skill
请求体: {skill_id = skill_id
```

### 448. `learnSkill` (post)
```
参数: skill_id, callback, isNeedWait, retryType
URL: learn_skill
请求体: {skill_id = skill_id}
```

### 449. `getAndroidUUID` (get)
```
参数: callback, isNeedWait, retryType
URL: api/v5/, api/service_android/, get_uuid
```

### 450. `checkFondDreamRoleDataIsOverdue` (post)
```
参数: userData, callback, isNeedWait, retryType
URL: settle_overdue_fond_dream
请求体: {userData}
```

### 451. `getFondDreamRoleData` (get)
```
参数: callback, isNeedWait, retryType
URL: get_fond_dream_role
请求体: nil
```

### 452. `uploadFondDreamRoleData` (post)
```
参数: dreamRoleData, callback, isNeedWait, retryType
URL: upload_fond_dream_role
请求体: {roleAttr = dreamRoleData}
```

### 453. `fondDreamFloorComplete` (post)
```
参数: roleAttr, callback, isNeedWait, retryType
URL: fond_dream_floor_complete
请求体: {roleAttr = roleAttr}
```

### 454. `fondDreamWorldComplete` (post)
```
参数: uploadParams, callback, isNeedWait, retryType
URL: fond_dreamworld_complete
请求体: {roleAttr = uploadParams.roleAttr
```

### 455. `getFondWebReward` (post)
```
参数: params, callback, isNeedWait, retryType
URL: get_fond_dream_reward
请求体: params
```

### 456. `deleteFondDreamRoleData` (get)
```
参数: callback, isNeedWait, retryType
URL: delete_fond_dream_role
请求体: nil
```

### 457. `getEggChallengeInfo` (get)
```
参数: callback, isNeedWait, retryType
URL: get_egg_challenge_info
请求体: nil
```

### 458. `addEggChallengeTimes` (post)
```
参数: npcId, callback, isNeedWait, retryType
URL: add_egg_challenge_times
请求体: {npc_id = npcId}
```

### 459. `getLuckBoxList` (post)
```
参数: activity_id, menpai, is_refresh, callback, isNeedWait, retryType
URL: get_luck_box_list
请求体: {activity_id = activity_id
```

### 460. `buyLuckBoxGood` (post)
```
参数: activity_id, rid, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: buy_luck_box_good
请求体: {activity_id = activity_id
```

### 461. `getLuckBoxGood` (post)
```
参数: activity_id, rid, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: get_luck_box_good
请求体: {activity_id = activity_id
```

### 462. `getSachetAtticList` (get)
```
参数: actionId, callback, isNeedWait, retryType
URL: get_sachet_attic_list/
```

### 463. `exchangeAwardToSachet` (post)
```
参数: activity_id, reward_id, callback, isNeedWait, retryType
URL: exchange_award_to_sachet
请求体: {activity_id = activity_id
```

### 464. `buySpendReward` (post)
```
参数: activity_id, rid, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: buy_spend_reward
请求体: {activity_id = activity_id
```

### 465. `startHangUpTask` (post)
```
参数: version, taskId, extraData, callback, isNeedWait, retryType
URL: start_hang_up_task
请求体: {version = version
```

### 466. `stopHangUpTask` (post)
```
参数: version, taskId, extraData, reward, callback, isNeedWait, retryType
URL: stop_hang_up_task
请求体: {version = version
```

### 467. `getHangUpYashiTime` (post)
```
参数: version, callback, isNeedWait, retryType
URL: get_hangUp_yashi_time
请求体: {version = version}
```

### 468. `getYaShiExpiredTime` (get)
```
参数: callback, isNeedWait, retryType
URL: check_has_yashi
请求体: nil
```

### 469. `recordClickTask` (post)
```
参数: taskId, reward, extra, callback, isNeedWait, retryType
URL: record_click_task
请求体: {task_id = taskId
```

### 470. `testSetUpdateYaShiTime` (post)
```
参数: create_time, expired_time, callback, isNeedWait, retryType
说明: 测试用:修改挂机数据
URL: test_update_yashi
请求体: {data = {create_time = create_time
```

### 471. `testSetUpdateHangTask` (post)
```
参数: version, data, callback, isNeedWait, retryType
说明: 查看挂机信息
URL: test_update_hang_task
请求体: {version = version
```

### 472. `testGetHangTask` (post)
```
参数: version, callback, isNeedWait, retryType
URL: test_get_hang_task
请求体: {version = version}
```

### 473. `getTotalSpendDetail` (get)
```
参数: activity_id, callback, isNeedWait, retryType
URL: get_total_spend_detail/
```

### 474. `getTotalSpendAward` (post)
```
参数: activity_id, award_id, callback, isNeedWait, retryType
URL: get_total_spend_award
请求体: {activity_id = activity_id
```

### 475. `upgradeUserBag` (post)
```
参数: type, level, callback, isNeedWait, retryType
URL: upgrade_user_bag
请求体: {type = type
```

### 476. `addIncidentLog` (post)
```
参数: event_type, envet_param, user_attr, callback, isNeedWait, retryType
URL: add_incident_log
请求体: {event_type = event_type
```

### 477. `martialUpgradeAddCurrency` (post)
```
参数: currencyVersion, type, callback, isNeedWait, retryType
URL: martial_upgrade_add_currency
请求体: {currencyVersion = currencyVersion
```

### 478. `getExpelRewardList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_expel_reward_list
请求体: nil
```

### 479. `expelNian` (post)
```
参数: times, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: expel_nian
请求体: {times = times
```

### 480. `getExpelReward` (post)
```
参数: rid, giftId, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: get_expel_reward
请求体: {rid = rid
```

### 481. `getAnecdote` (get)
```
参数: callback, isNeedWait, retryType
URL: get_user_anecdote
请求体: nil
```

### 482. `revertAnecdote` (get)
```
参数: callback, isNeedWait, retryType
说明: 获取节日副本详情
URL: test_revert_anecdote
请求体: nil
```

### 483. `getFestivalMapInfo` (post)
```
参数: groupId,callback, isNeedWait, retryType
说明: 判断是否有未完成的挑战副本进度
URL: get_festivalmap_info
请求体: {groupId = groupId}
```

### 484. `isChallengeMapReconnection` (get)
```
参数: callback, isNeedWait, retryType
说明: 进入未完成副本
URL: challengemap_unfinished
请求体: nil
```

### 485. `reEnterChallengemap` (get)
```
参数: callback, isNeedWait, retryType
URL: reenter_challengemap
请求体: nil
```

### 486. `enterChallengeMap` (post)
```
参数: mapId, callback, isNeedWait, retryType
说明: 挑战副本能否快速通关
URL: challengemap_enter
请求体: {map_id = mapId}
```

### 487. `challengeMapIsCustoms` (post)
```
参数: mapId, callback, isNeedWait, retryType
URL: challengemap_is_customs
请求体: {map_id = mapId}
```

### 488. `challengeMapConfirmConsume` (post)
```
参数: mapId, consume_map, callback, isNeedWait, retryType
URL: challengemap_confirm_consume
请求体: {map_id = mapId
```

### 489. `challengeMapFinish` (post)
```
参数: mapId, finishType, callback, isNeedWait, retryType
URL: challengemap_finish
请求体: {map_id = mapId
```

### 490. `challengeMapGetAward` (post)
```
参数: mapId, type, award_list, finishType, currencyVersion, callback, isNeedWait, retryType
说明: 挑战副本离开(用于未通关退出挑战副本，通知服务器结束这次挑战副本记录)
URL: challengemap_award
请求体: {currencyVersion = currencyVersion
```

### 491. `challengeMapLeave` (post)
```
参数: type, callback, isNeedWait, retryType
说明: 获取武学突破相关货币数量
URL: challengemap_leave
请求体: {type = type}
```

### 492. `getSkillBreakCurrency` (post)
```
参数: currencyVersion, callback, isNeedWait, retryType
说明: 武学突破
URL: get_martial_upgrade_currency
请求体: {currencyVersion = currencyVersion}
```

### 493. `skillBreakThrough` (post)
```
参数: id, skillId, currencyVersion, callback, isNeedWait, retryType
说明: 测试接口  增加武学突破相关货币各1000
URL: martial_upgrade
请求体: {id = id
```

### 494. `testAddMartialCurrency` (post)
```
参数: currencyVersion, callback, isNeedWait, retryType
说明: 招式突破
URL: test_add_martial_currency
请求体: {currencyVersion = currencyVersion}
```

### 495. `zhaoBreakThrough` (post)
```
参数: id, zhaoId, currencyVersion, callback, isNeedWait, retryType
说明: 获取招式突破相关道具数量列表
URL: zhao_upgrade
请求体: {id = id
```

### 496. `getZhaoBreakThroughItems` (post)
```
参数: currencyVersion, callback, isNeedWait, retryType
说明: 测试接口  增加招式突破相关道具各1000
URL: get_zhao_upgrade_matters
请求体: {currencyVersion = currencyVersion}
```

### 497. `testAddZhaoBreItems` (get)
```
参数: callback, isNeedWait, retryType
URL: test_add_zhao_currency
请求体: nil
```

### 498. `uploadWashAttributeRecord` (post)
```
参数: record, callback, isNeedWait, retryType
URL: upload_wash_attribute_record
请求体: {record = record}
```

### 499. `mattersShopInfo` (post)
```
参数: type, currencyVersion, callback, isNeedWait, retryType
URL: matters_shop_info
请求体: {type = type
```

### 500. `buyMatters` (post)
```
参数: goodsKey, currencyVersion, callback, isNeedWait, retryType
URL: buy_matters, xx
请求体: {goodsKey = goodsKey
```

### 501. `specialItemExchange` (post)
```
参数: exchangeItems, targetItems, callback, isNeedWait, retryType
说明: pvp战斗人物数据校验
URL: special_item_exchange
请求体: {exchangeItems = exchangeItems
```

### 502. `pvpRoleDataVerify` (post)
```
参数: roleDatas, callback, isNeedWait, retryType
URL: pvp_roleData_verify
请求体: {roleDatas = roleDatas}
```

### 503. `getTrainingTaskList` (post)
```
参数: actionId, taskList, callback, isNeedWait, retryType
URL: get_training_task_list
请求体: {activityId = actionId
```

### 504. `refreshTrainingTaskList` (post)
```
参数: actionId, taskList, callback, isNeedWait, retryType
URL: refresh_training_task_list
请求体: {activityId = actionId
```

### 505. `addTrainingTaskPoint` (post)
```
参数: taskId, taskList, callback, isNeedWait, retryType
URL: add_training_task_point
请求体: {tid = taskId
```

### 506. `getTrainingTaskReward` (post)
```
参数: activityId, rid, giftId, isEmail, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: get_training_task_reward
请求体: {activityId = activityId
```

### 507. `getUiThemeList` (get)
```
参数: callback,isNeedWait, retryType
URL: get_ui_theme_list
请求体: nil
```

### 508. `buyUiTheme` (get)
```
参数: uiId, callback,isNeedWait, retryType
URL: buy_ui_theme/
```

### 509. `useUiTheme` (get)
```
参数: uiId, callback,isNeedWait, retryType
说明: 删除已购买的所有皮肤（测试专用接口）
URL: use_ui_theme/
```

### 510. `testDeleteAllUiThemes` (get)
```
参数: callback,isNeedWait, retryType
说明: 获取练武场相关信息
URL: test_delete_all_ui_themes
请求体: nil
```

### 511. `getPracticeSkillRewardList` (post)
```
参数: activityId, skillData,zhaoData,callback,isNeedWait, retryType
URL: get_practice_skill_reward_list
请求体: {activityId = activityId
```

### 512. `getPracticeSkillReward` (post)
```
参数: activityId, rid,is_email,dataVer,callback,isNeedWait, retryType
URL: get_practice_skill_reward
请求体: {activityId = activityId
```

### 513. `unlockPracticeSkillPayReward` (post)
```
参数: activityId, jackpotId, callback, isNeedWait, retryType
URL: unlock_practice_skill_reward
请求体: {activityId = activityId
```

### 514. `getToastRewardList` (get)
```
参数: callback,isNeedWait, retryType
URL: get_toast_reward_list
请求体: nil
```

### 515. `toastQian` (post)
```
参数: times, dataVer, callback,isNeedWait, retryType
URL: toast_qian
请求体: {times = times
```

### 516. `getToastReward` (post)
```
参数: rid, giftId, dataVer, newDataVer, callback,isNeedWait, retryType
URL: get_toast_reward
请求体: {dataVer = dataVer
```

### 517. `getLianGongState` (post)
```
参数: dataVer, codeVer, callback
URL: getLianGongState
请求体: {dataVer = dataVer
```

### 518. `lianGongStart` (post)
```
参数: requestId, dataVer, codeVer, actionData, time, callback
URL: lianGongStart
请求体: {requestId = requestId
```

### 519. `lianGongFinish` (post)
```
参数: requestId, dataVer, codeVer, actionData, time, callback
URL: lianGongFinish
请求体: {requestId = requestId
```

### 520. `lianGongUseXingGongSan` (post)
```
参数: requestId, dataVer, codeVer, time, callback
URL: lianGongUseXingGongSan
请求体: {requestId = requestId
```

### 521. `getLianGongData` (post)
```
参数: dataVer, codeVer, callback
URL: getLianGongData
请求体: {dataVer = dataVer
```

### 522. `getXiuLianState` (post)
```
参数: dataVer, codeVer, callback
URL: getXiuLianState
请求体: {dataVer = dataVer
```

### 523. `xiuLianStart` (post)
```
参数: requestId, dataVer, codeVer, actionData, time, callback
URL: xiuLianStart
请求体: {requestId = requestId
```

### 524. `xiuLianFinish` (post)
```
参数: requestId, dataVer, codeVer, actionData, time, callback
URL: xiuLianFinish
请求体: {requestId = requestId
```

### 525. `xiuLianUseXingGongSan` (post)
```
参数: requestId, dataVer, codeVer, time, callback
URL: xiuLianUseXingGongSan
请求体: {requestId = requestId
```

### 526. `getXiuLianData` (post)
```
参数: dataVer, codeVer, callback
URL: getXiuLianData
请求体: {dataVer = dataVer
```

### 527. `getXinShenValue` (post)
```
参数: dataVer, codeVer, callback
URL: getXinShenValue
请求体: {dataVer = dataVer
```

### 528. `upgradeXinShenLevel` (post)
```
参数: requestId, dataVer, codeVer, time, callback
URL: upgradeXinShenLevel
请求体: {requestId = requestId
```

### 529. `getXinShenLevel` (post)
```
参数: dataVer, codeVer, callback
URL: getXinShenLevel
请求体: {dataVer = dataVer
```

### 530. `getXinShenRecoverStartTime` (post)
```
参数: dataVer, codeVer, callback
URL: getXinShenRecoverStartTime
请求体: {dataVer = dataVer
```

### 531. `recoverXinShenValue` (post)
```
参数: value, dataVer, codeVer, time, callback
URL: recoverXinShenValue
请求体: {dataVer = dataVer
```

### 532. `getLianGongTiLi` (post)
```
参数: dataVer, codeVer, callback
URL: get_liangong_tili
请求体: {dataVer = dataVer
```

### 533. `testAddLianGongTiLi` (post)
```
参数: count, dataVer, codeVer, callback
说明: 获取地仓府库活动详情
URL: test_add_liangong_tili
请求体: {count = count
```

### 534. `getWareHouseActivityInfo` (post)
```
参数: currencyVersion, callback,isNeedWait, retryType
说明: 地仓府库抽奖
URL: get_treasury_info
请求体: {currencyVersion = currencyVersion}
```

### 535. `WareHouseDrawLucky` (post)
```
参数: indexList, currencyVersion, callback,isNeedWait, retryType
说明: 领取地仓府库奖励
URL: treasury_lottery
请求体: {indexList = indexList
```

### 536. `getWareHouseAward` (post)
```
参数: rewardType,awardIds,isEmail,dataVer,currencyVersion,callback,isNeedWait, retryType
说明: 进入地仓府库下一层
URL: get_treasury_reward
请求体: {rewardType = rewardType
```

### 537. `enterWareHouseNextFloor` (get)
```
参数: callback,isNeedWait, retryType
URL: enter_next_treasury
请求体: nil
```

### 538. `getItemCount` (post)
```
参数: itemId, dataVer, codeVer, callback
URL: getItemCount
请求体: {dataVer = dataVer
```

### 539. `addItemCount` (post)
```
参数: itemId, count, dataVer, codeVer, callback
URL: addItemCount
请求体: {dataVer = dataVer
```

### 540. `useItem` (post)
```
参数: itemId, dataVer, codeVer, callback
URL: useItem
请求体: {dataVer = dataVer
```

### 541. `getItemMap` (post)
```
参数: callback
URL: getItemMap
请求体: {}
```

### 542. `refreshItemMapCache` (post)
```
参数: dataVer, codeVer, callback
URL: refreshItemMapCache
请求体: {dataVer = dataVer
```

### 543. `getAnniversaryLoginList` (get)
```
参数: callback, isNeedWait, retryType
URL: get_anniversary_login_list
请求体: nil
```

### 544. `getAnniversaryLoginReward` (post)
```
参数: rid, is_enough, dataVer, callback, isNeedWait, retryType
URL: get_anniversary_login_reward
请求体: {rid = rid
```

### 545. `getViewingHall` (get)
```
参数: callback,isNeedWait, retryType
URL: get_viewing_hall
请求体: nil
```

### 546. `getViewingReward` (post)
```
参数: id, is_free, is_email, callback, isNeedWait, retryType
说明: 获取观影堂特权加送活动数据
URL: get_viewing_reward
请求体: {id = id
```

### 547. `getViewingHallPrivilegeInfo` (get)
```
参数: callback,isNeedWait, retryType
说明: 获取观影堂特权加送活动奖励
URL: get_viewing_privilege_info
请求体: nil
```

### 548. `getViewingHallPrivilegeReward` (get)
```
参数: callback,isNeedWait, retryType
URL: get_viewing_privilege_reward
请求体: nil
```

### 549. `getSmithyInfo` (get)
```
参数: callback,isNeedWait, retryType
URL: get_smithy_info
请求体: nil
```

### 550. `getSmithyReward` (post)
```
参数: rid, is_email, callback, isNeedWait, retryType
URL: get_smithy_reward
请求体: {rid = rid
```

### 551. `uploadWeaponRepairLog` (post)
```
参数: logData, callback, isNeedWait, retryType
URL: upload_weapon_repair_log
请求体: logData
```

### 552. `getSachetAtticNewList` (get)
```
参数: activity_id, callback, isNeedWait, retryType
URL: get_sachet_attic_new_list/
```

### 553. `exchangeAwardToSachetNew` (post)
```
参数: activity_id, reward_id, is_email, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: exchange_award_to_sachet_new
请求体: {activity_id = activity_id
```

### 554. `getWakingDreamInfo` (get)
```
参数: callback,isNeedWait, retryType
URL: get_waking_dream_info
请求体: nil
```

### 555. `getWakingDreamReward` (post)
```
参数: rid, is_email, dataVer, callback, isNeedWait, retryType
URL: get_waking_dream_reward
请求体: {rid = rid
```

### 556. `unlockWakingDreamPayReward` (post)
```
参数: jackpotId, callback, isNeedWait, retryType
URL: unlock_waking_dream_pay_reward
请求体: {jackpotId = jackpotId}
```

### 557. `getYuanbaoConsumptionInfo` (get)
```
参数: callback,isNeedWait, retryType
URL: get_yuanbao_consumption_info
请求体: nil
```

### 558. `getYuanbaoConsumptionReward` (post)
```
参数: rid, is_email, callback, isNeedWait, retryType
URL: get_yuanbao_consumption_reward
请求体: {rid = rid
```

### 559. `getDanQingPavilionInfo` (get)
```
参数: activityId, callback,isNeedWait, retryType
URL: get_danqing_pavilion_info/
```

### 560. `exchangeDanQingPavilionItem` (post)
```
参数: activityId, id, rid, dataVer, callback, isNeedWait, retryType
URL: exchange_danqing_pavilion_item
请求体: {activityId = activityId
```

### 561. `getDanQingPavilionReward` (post)
```
参数: activityId, id, dataVer, callback, isNeedWait, retryType
URL: get_danqing_pavilion_reward
请求体: {activityId = activityId
```

### 562. `getUserShenBings` (get)
```
参数: callback,isNeedWait, retryType
说明: 完成拳脚系统前置任务,创建拳脚系统信息
URL: get_user_shenbings
请求体: nil
```

### 563. `createFistInfo` (post)
```
参数: dataVer,codeVer,callback,isNeedWait, retryType
说明: 获取拳脚系统数据
URL: create_fist_info
请求体: {dataVer = dataVer
```

### 564. `getFistFootInFo` (post)
```
参数: dataVer,codeVer,callback,isNeedWait, retryType
说明: 开始修行任务
URL: get_fist_info
请求体: {dataVer = dataVer
```

### 565. `startFistTask` (post)
```
参数: taskId,dataVer,codeVer,callback, isNeedWait, retryType
URL: start_fist_task
请求体: {taskId = taskId
```

### 566. `stopFistTask` (post)
```
参数: taskId, dataVer,codeVer,callback, isNeedWait, retryType
URL: stop_fist_task
请求体: {taskId = taskId
```

### 567. `finishFistTask` (post)
```
参数: taskId, bagEnough, dataVer,codeVer,callback, isNeedWait, retryType
URL: finish_fist_task
请求体: {taskId = taskId
```

### 568. `speedUpFistTask` (post)
```
参数: taskId,cost, dataVer,codeVer,callback, isNeedWait, retryType
URL: expedite_fist_task
请求体: {taskId = taskId
```

### 569. `upgradeTechnique` (post)
```
参数: techniqueId, dataVer,codeVer,callback, isNeedWait, retryType
URL: upgrade_technique
请求体: {techniqueId = techniqueId
```

### 570. `extractCharacter` (post)
```
参数: techniqueId, dataVer,codeVer,callback, isNeedWait, retryType
URL: grasp_technique_feature
请求体: {techniqueId = techniqueId
```

### 571. `replaceCharacter` (post)
```
参数: techniqueId, dataVer,codeVer,callback, isNeedWait, retryType
URL: replace_technique_feature
请求体: {techniqueId = techniqueId
```

### 572. `resetTalentPage` (post)
```
参数: talentPageId, dataVer,codeVer,callback, isNeedWait, retryType
URL: reset_fist_technique
请求体: {techniquePageId = talentPageId
```

### 573. `getTalentPageInfo` (post)
```
参数: dataVer, codeVer,callback, isNeedWait, retryType
URL: get_talent_info
请求体: {dataVer = dataVer
```

### 574. `getCharacterPoolInfo` (post)
```
参数: poolId, dataVer, codeVer,callback, isNeedWait, retryType
URL: get_characterPool_info
请求体: {papool = poolId
```

### 575. `updataFistFlag` (post)
```
参数: addFlags,deleteFlags, dataVer, codeVer,callback, isNeedWait, retryType
请求体: {addFlags = addFlags
```

### 576. `getFistTasks` (post)
```
参数: dataVer, codeVer,callback, isNeedWait, retryType
说明: 设置拳脚系统分支经验
URL: get_fist_tasks
请求体: {dataVer = dataVer
```

### 577. `testSetFistBranchExp` (post)
```
参数: branchId,branchExp, dataVer,codeVer,callback, isNeedWait, retryType
URL: test_set_fist_branch_level
请求体: {branchExp = branchExp
```

### 578. `testSetFistReflectExp` (post)
```
参数: exp,dataVer,codeVer,callback, isNeedWait, retryType
URL: test_set_fist_reflect_level
请求体: {exp = exp
```

### 579. `testSetFistTechniqueLevel` (post)
```
参数: techniqueId,level,dataVer,codeVer,callback, isNeedWait, retryType
URL: test_set_fist_technique_level
请求体: {techniqueId = techniqueId
```

### 580. `testAddFeelPoint` (post)
```
参数: number,dataVer,codeVer,callback, isNeedWait, retryType
说明: 添加技巧心得页
URL: test_add_fist_feel_point
请求体: {number = number
```

### 581. `testAddTalentPage` (post)
```
参数: dataVer,codeVer,callback, isNeedWait, retryType
说明: 切换技巧心得
URL: test_add_talent_page
请求体: {dataVer = dataVer
```

### 582. `switchTalentPage` (post)
```
参数: pageNum, codeVer, dataVer, callback, isNeedWait, retryType
URL: switch_talent_page
请求体: {pageIndex = pageNum
```

### 583. `getWuMenTrialInfo` (post)
```
参数: dataVer, callback,isNeedWait, retryType
URL: get_wumen_trial_info
请求体: {dataVer = dataVer}
```

### 584. `getWuMenTrialReward` (post)
```
参数: id, dataVer, callback, isNeedWait, retryType
URL: get_wumen_trial_reward
请求体: {id = id
```

### 585. `checkEmailWhite` (post)
```
参数: email, callback, isNeedWait, retryType
说明: 获取招式对练详情
URL: check_email_white
请求体: {email = email}
```

### 586. `getZhaoPracticeInfo` (post)
```
参数: npcId , mid, currencyVersion, callback, isNeedWait, retryType
说明: 对练
URL: get_zhao_practiceInfo
请求体: {npcId = npcId
```

### 587. `zhaoPractice` (post)
```
参数: npcId , mid, zhaoId, type, price, currencyVersion, callback, isNeedWait, retryType
说明: 赠与残页
URL: zhao_practice
请求体: {npcId = npcId
```

### 588. `giftZhaoPage` (post)
```
参数: npcId , mid, zhaoId, callback, isNeedWait, retryType
说明: 遗忘残页
URL: gift_zhao_page
请求体: {npcId = npcId
```

### 589. `forgetZhaoPage` (post)
```
参数: npcId , mid, zhaoId, callback, isNeedWait, retryType
URL: forget_zhao_page
请求体: {npcId = npcId
```

### 590. `getZhaoCaiJinBaoInfo` (get)
```
参数: activity_id, callback, isNeedWait, retryType
URL: get_zhaocaijinbao_info/
```

### 591. `getZhaoCaiJinBaoReward` (post)
```
参数: activity_id, id, reward_id, is_email, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: get_zhaocaijinbao_reward
请求体: {id = id
```

### 592. `buyBlackGoods` (post)
```
参数: goodsInfo , client_trans_id, mark, callback, isNeedWait, retryType
URL: buy_black_goods
请求体: {goodsInfo = goodsInfo
```

### 593. `getSutraPavilionList` (post)
```
参数: activity_id, is_refresh, levelType, callback, isNeedWait, retryType
URL: get_sutra_pavilion_list
请求体: {activity_id = activity_id
```

### 594. `buySutraPavilionGoods` (post)
```
参数: activity_id, id, callback, isNeedWait, retryType
URL: buy_sutra_pavilion_goods
请求体: {activity_id = activity_id
```

### 595. `getCuiLianCaiLiaoStoreList` (post)
```
参数: activity_id, currencyVersion, callback, isNeedWait, retryType
说明: 获取师门建设数据
URL: get_cuiLianCaiLiao_store_list
请求体: {activityId = activity_id
```

### 596. `getTeacherBuildInFo` (post)
```
参数: familyId,callback,isNeedWait, retryType
说明: 开始师门建设任务
URL: get_teacherBuild_info
请求体: {familyId = familyId}
```

### 597. `startTeacherBuildTask` (post)
```
参数: taskId,familyId,callback, isNeedWait, retryType
说明: 停止师门建设任务
URL: start_teacherBuild_task
请求体: {taskId = taskId
```

### 598. `stopTeacherBuildTask` (post)
```
参数: taskId,familyId,callback, isNeedWait, retryType
说明: 完成师门建设任务
URL: stop_teacherBuild_task
请求体: {taskId = taskId
```

### 599. `finishTeacherBuildTask` (post)
```
参数: taskId, familyId ,callback, isNeedWait, retryType
说明: 加速师门建设任务
URL: finish_teacherBuild_task
请求体: {taskId = taskId
```

### 600. `speedUpTeacherBuildTask` (post)
```
参数: taskId,cost,familyId,callback, isNeedWait, retryType
说明: 获取师门建设任务列表
URL: speedUp_teacherBuild_task
请求体: {taskId = taskId
```

### 601. `getTeacherBuildTasks` (post)
```
参数: familyId,callback, isNeedWait, retryType
说明: 更新师门建设日常任务标记
URL: get_teacherBuild_tasks
请求体: {familyId = familyId}
```

### 602. `updataTeacherBuildFlag` (post)
```
参数: addFlags,deleteFlags,familyId,callback, isNeedWait, retryType
说明: 获取师门建筑数据
请求体: {addFlags = addFlags
```

### 603. `getTeacherBuildData` (post)
```
参数: familyId,callback, isNeedWait, retryType
说明: 获取师门建筑材料信息
URL: get_teacherBuild_list
请求体: {familyId = familyId}
```

### 604. `getTeacherBuildItems` (post)
```
参数: familyId,callback, isNeedWait, retryType
说明: 兴建师门建筑
URL: get_teacherBuild_items
请求体: {familyId = familyId}
```

### 605. `buildTeacherBuild` (post)
```
参数: buildTypeId,familyId,callback, isNeedWait, retryType
说明: 获取建筑捐献信息
URL: build_teacherBuild
请求体: {buildTypeId = buildTypeId
```

### 606. `getTeacherBuildDonateInfo` (post)
```
参数: buildTypeId,familyId,callback, isNeedWait, retryType
说明: 捐献建筑材料
URL: get_teacherBuild_donateInfo
请求体: {buildTypeId = buildTypeId
```

### 607. `donateTeacherBuild` (post)
```
参数: buildTypeId,donateId,donateState,familyId, currencyVersion, callback, isNeedWait, retryType
说明: 师门建筑开放等级升级
URL: donate_teacherBuild
请求体: {currencyVersion = currencyVersion
```

### 608. `upgradeTeacherBuild` (post)
```
参数: buildTypeId,familyId,callback, isNeedWait, retryType
说明: 获取师门名绩数据
URL: upgrade_teacherBuild
请求体: {buildTypeId = buildTypeId
```

### 609. `getTeacherFeatData` (post)
```
参数: familyId,callback,isNeedWait, retryType
说明: 领取师门名绩奖励
URL: get_teacherFeat_info
请求体: {familyId = familyId}
```

### 610. `getTeacherFeatReward` (post)
```
参数: familyId,featId,dataVer,callback,isNeedWait, retryType
说明: 师门建设测试接口
URL: get_teacherFeat_reward
请求体: {familyId = familyId
```

### 611. `testTeacherBuildAction` (post)
```
参数: type,number,callback, isNeedWait, retryType
说明: 测试接口，修改建筑经验
URL: test_sect_build_action
请求体: {type = type
```

### 612. `testUpdateBuildingDegree` (post)
```
参数: familyId,buildTypeId,number,callback, isNeedWait, retryType
URL: test_update_building_degree
请求体: {familyId = familyId
```

### 613. `getSutraPavilionGoods` (post)
```
参数: activity_id, id, is_email, dataVer, callback, isNeedWait, retryType
URL: get_sutra_pavilion_goods
请求体: {activity_id = activity_id
```

### 614. `buyCuiLianCaiLiaoStoreGoods` (post)
```
参数: activity_id, id, currencyId, currencyVersion, callback, isNeedWait, retryType
URL: buy_cuiLianCaiLiao_store_goods
请求体: {activityId = activity_id
```

### 615. `getCuiLianCaiLiaoStoreReward` (post)
```
参数: activity_id, id, is_email, dataVer, callback, isNeedWait, retryType
URL: get_cuiLianCaiLiao_store_reward
请求体: {id = id
```

### 616. `exchangeCuiLianCaiLiaoStoreIntegral` (post)
```
参数: activity_id, id, number, currencyVersion, callback, isNeedWait, retryType
URL: exchange_cuiLianCaiLiao_store_integral
请求体: {id = id
```

### 617. `uploadClientEnvMessage` (post)
```
参数: env, callback, isNeedWait, retryType
URL: upload_client_error_message
请求体: env
```

### 618. `TransferHomegateGroup` (post)
```
参数: familyId, newFamilyId, callback, isNeedWait, retryType
URL: transfer_homegate_group
请求体: {familyId = familyId
```

### 619. `testUpdateTechniqueFeature` (post)
```
参数: techniqueId, characterId, dataVer,codeVer,callback, isNeedWait, retryType
URL: test_update_technique_feature
请求体: {techniqueId = techniqueId
```

### 620. `getSectMeritStore` (post)
```
参数: familyId, isRefresh, callback, isNeedWait, retryType
URL: get_sect_merit_store
请求体: {familyId = familyId
```

### 621. `buyMeritGoods` (post)
```
参数: familyId, id, callback, isNeedWait, retryType
URL: buy_merit_goods
请求体: {familyId = familyId
```

### 622. `getMeritGoods` (post)
```
参数: familyId, id, dataVer, isSent, callback, isNeedWait, retryType
说明: 获取散人装备武学心法限制条件数据
URL: get_merit_goods
请求体: {familyId = familyId
```

### 623. `getYouXiaMcmrestrictUpgradeCondition` (post)
```
参数: familyId, currencyVersion, callback, isNeedWait, retryType
说明: 散人升级装备武学心法限制
URL: get_youxia_upgradeCondition
请求体: {familyId = familyId
```

### 624. `youxiaUpgradeMcmrestrict` (post)
```
参数: familyId, currencyVersion, callback, isNeedWait, retryType
说明: 删除散人心法
URL: youxia_upgrade_condition
请求体: {familyId = familyId
```

### 625. `deleteYouXiaMcmrestrict` (get)
```
参数: callback, isNeedWait, retryType
URL: delete_youxia_upgradeCondition
请求体: nil
```

### 626. `testUpdateUserFamily` (post)
```
参数: familyId, callback, isNeedWait, retryType
说明: 获取账号注销网址
URL: test_update_user_family
请求体: {familyId = familyId}
```

### 627. `getLogoutAccountUrl` (get)
```
参数: callback, isNeedWait, retryType
URL: get_logoutAccount_url
请求体: nil
```

### 628. `getSectExchangeStore` (post)
```
参数: familyId, callback, isNeedWait, retryType
URL: get_sect_exchangeStore
请求体: {familyId = familyId}
```

### 629. `buySectExchangeGoods` (post)
```
参数: familyId, id, callback, isNeedWait, retryType
说明: 删除美容丸初始化测试接口
URL: buy_sect_exchangeGoods
请求体: {familyId = familyId
```

### 630. `testDeleteMeiRongWanInit` (get)
```
参数: callback, isNeedWait, retryType
说明: 获取制作面具信息
URL: test_delete_initial_meirongwan
请求体: nil
```

### 631. `getMakeMaskInfo` (get)
```
参数: callback, isNeedWait, retryType
URL: get_makeMask_info
请求体: nil
```

### 632. `makeRandomMask` (post)
```
参数: cost,grantType,callback, isNeedWait, retryType
URL: make_randomMask
请求体: {cost = cost
```

### 633. `makePayMask` (post)
```
参数: id,spCost,grantType,callback, isNeedWait, retryType
URL: make_payMask
请求体: {id = id
```

### 634. `getPayMakeMaskGiftInfo` (get)
```
参数: callback, isNeedWait, retryType
URL: get_payMask_gift_info
请求体: nil
```

### 635. `receivePayMaskGift` (post)
```
参数: id, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: receive_payMask_gift
请求体: {id = id
```

### 636. `testGetTime` (get)
```
参数: callback, isNeedWait, retryType
URL: get_time
请求体: nil
```

### 637. `testGetTimeAsync` (get)
```
参数: callback, isNeedWait, retryType
URL: get_time
请求体: nil
```

### 638. `testGetTimeWaitText` (get)
```
参数: waitText, callback, isNeedWait, retryType
URL: get_time
```

### 639. `testGetTimeWaitTextAsync` (get)
```
参数: waitText, callback, isNeedWait, retryType
URL: get_time
```

### 640. `getSectRevitalizationInfo` (post)
```
参数: familyId, callback, isNeedWait, retryType
URL: get_sectRevitalization_info
请求体: {familyId = familyId}
```

### 641. `getSectRevitalizationReward` (post)
```
参数: familyId, buildTypeId, callback, isNeedWait, retryType
URL: get_sectRevitalization_reward
请求体: {familyId = familyId
```

### 642. `getSectSupportShop` (post)
```
参数: familyId, callback, isNeedWait, retryType
URL: get_sect_supportShop
请求体: {familyId = familyId}
```

### 643. `BuySectSupportGoods` (post)
```
参数: familyId, id, callback, isNeedWait, retryType
URL: buy_sect_supportGoods
请求体: {familyId = familyId
```

### 644. `uploadAbnormalHangUpTask` (post)
```
参数: version, taskId, taskStartTime, extraData, callback, isNeedWait, retryType
说明: 获取拳脚商店信息
URL: upload_abnormal_hangUp_task
请求体: {version = version
```

### 645. `getFistFootShopInfo` (get)
```
参数: callback, isNeedWait, retryType
说明: 设置每日支付元宝数
URL: get_fistFootShop_info
请求体: nil
```

### 646. `setFistFootShopDailyCost` (post)
```
参数: dailySelectCost, callback, isNeedWait, retryType
URL: set_fistFootShop_dailyCost
请求体: {dailySelectCost = dailySelectCost}
```

### 647. `buyFistFootShopDailyGoods` (post)
```
参数: dayId,dataVer, callback, isNeedWait, retryType
URL: buy_fistFootShop_dailyGoods
请求体: {dayId = dayId
```

### 648. `buyFistFootShopSpecialOffer` (post)
```
参数: specialOfferCost,dataVer, callback, isNeedWait, retryType
URL: buy_fistFootShop_specialOffer
请求体: {specialOfferCost = specialOfferCost
```

### 649. `canInherit` (get)
```
参数: callback, isNeedWait, retryType
URL: canInherit
请求体: ""
```

### 650. `getwxtranstwxplushasGainAfter202509291500` (get)
```
参数: callback, isNeedWait, retryType
URL: check_user_gain_log
请求体: ""
```

### 651. `testSetMeridianPageNum` (post)
```
参数: num,callback, isNeedWait, retryType
说明: 获取隐脉相关资源
URL: test_set_meridian_talent_page
请求体: {num = num}
```

### 652. `getHiddenMeridianInfo` (get)
```
参数: callback, isNeedWait, retryType
说明: 开始破境
URL: get_hidden_meridian_info
请求体: nil
```

### 653. `startHiddenMeridianBreakThrough` (post)
```
参数: id,version,currencyVersion,callback, isNeedWait, retryType
说明: 加速破境
URL: start_break_through_realm
请求体: {id = id
```

### 654. `speedUpHiddenMeridianBreakThrough` (post)
```
参数: id,cost,version,callback, isNeedWait, retryType
说明: 完成破境
URL: accelerate_break_through_realm
请求体: {id = id
```

### 655. `finishHiddenMeridianBreakThrough` (post)
```
参数: id,boostingEffect,version,callback, isNeedWait, retryType
说明: 取消破境
URL: finish_break_through_realm
请求体: {id = id
```

### 656. `cancelHiddenMeridianBreakThrough` (post)
```
参数: id,version,callback, isNeedWait, retryType
说明: 开始冲脉
URL: cancel_break_through_realm
请求体: {id = id
```

### 657. `startAcupointActivate` (post)
```
参数: id,version,callback, isNeedWait, retryType
说明: 加速冲脉
URL: start_thoroughfare_vessel
请求体: {id = id
```

### 658. `speedUpAcupointActivate` (post)
```
参数: id,cost,version,callback, isNeedWait, retryType
说明: 完成冲脉
URL: accelerate_thoroughfare_vessel
请求体: {id = id
```

### 659. `finishAcupointActivate` (post)
```
参数: id,version,callback, isNeedWait, retryType
说明: 取消冲脉
URL: finish_thoroughfare_vessel
请求体: {id = id
```

### 660. `cancelAcupointActivate` (post)
```
参数: id,version,callback, isNeedWait, retryType
说明: 解锁玄络buff
URL: cancel_thoroughfare_vessel
请求体: {id = id
```

### 661. `unlockHiddenMeridianBuff` (post)
```
参数: id,version,currencyVersion,callback, isNeedWait, retryType
URL: unlock_hidden_meridian_gems
请求体: {id = id
```

### 662. `getSectGuidanceInfo` (post)
```
参数: familyId, callback, isNeedWait, retryType
URL: get_sectGuidance_info
请求体: {familyId = familyId}
```

### 663. `executeSectGuidance` (post)
```
参数: familyId, id, version, callback, isNeedWait, retryType
URL: execute_sectGuidance
请求体: {familyId = familyId
```

### 664. `joinFamily` (post)
```
参数: familyId, currencyVersion, callback, isNeedWait, retryType
URL: join_family
请求体: {familyId = familyId
```

### 665. `testResetSectGuidance` (get)
```
参数: callback, isNeedWait, retryType
URL: test_reset_sect_guidance
请求体: nil
```

### 666. `exchangeYashiWelfareReward` (post)
```
参数: id, number, type, currencyVersion, callback, isNeedWait, retryType
URL: exchange_yashi_welfare_reward
请求体: {id = id
```

### 667. `getMerchantStoreList` (post)
```
参数: merchantId, isRefresh, currencyVersion, dataVer, callback, isNeedWait, retryType
URL: get_merchant_store_list
请求体: {merchantId = merchantId
```

### 668. `buyMerchantGoods` (post)
```
参数: merchantId, goodsList, recordList, currencyVersion, dataVer, callback, isNeedWait, retryType
URL: buy_merchant_goods
请求体: {merchantId = merchantId
```

### 669. `testCurrency` (post)
```
参数: currencyId, num, action, currencyVersion, callback, isNeedWait, retryType
URL: test_currency
请求体: {currencyId = currencyId
```

### 670. `consumeSpecialProps` (post)
```
参数: itemId, number, currencyVersion, callback, isNeedWait, retryType
URL: consume_special_props
请求体: {itemId = itemId
```

### 671. `getRechargeBenefitsInfo` (get)
```
参数: callback, isNeedWait, retryType
URL: get_recharge_benefits_info
请求体: nil
```

### 672. `getRechargeBenefitsReward` (post)
```
参数: id, isEmail, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: get_recharge_benefits_reward
请求体: {id = id
```

### 673. `getMerchantEventInfo` (post)
```
参数: activityId, currencyVersion, callback, isNeedWait, retryType
URL: get_merchant_event_info
请求体: {activityId = activityId
```

### 674. `getActivityChallengeMapClearTimeInfo` (get)
```
参数: callback, isNeedWait, retryType
URL: get_challengemap_task_info
请求体: nil
```

### 675. `getActivityChallengeMapClearReward` (post)
```
参数: isEmail, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: get_challengemap_task_reward
请求体: {isEmail = isEmail
```

### 676. `getServerResourceCount` (post)
```
参数: itemList, dataVer, currencyVersion, callback, isNeedWait, retryType
URL: get_server_resource_count
请求体: {itemList = itemList
```
