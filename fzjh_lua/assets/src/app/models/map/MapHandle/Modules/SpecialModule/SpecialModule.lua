--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local SpecialModule = class("SpecialModule", require("app.models.map.MapHandle.Modules.BaseModule"))

--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
SpecialModule.mapId = nil

--@desc 涉及房间 : 格式{["id"] = true} 默认为nil，无限制
SpecialModule.roomId = nil

--@desc 开启状态，默认开启
SpecialModule.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
SpecialModule.activityTime = 0

--@desc 子模块
SpecialModule.childModule = {
	["剑阵"] = "app.models.map.MapHandle.Modules.SpecialModule.ChildModule.JianZhen",
	["fb35End"] = "app.models.map.MapHandle.Modules.SpecialModule.ChildModule.fb35End",
	["佣兵"] = "app.models.map.MapHandle.Modules.SpecialModule.ChildModule.YongbingModule",
	["考试"] = "app.models.map.MapHandle.Modules.SpecialModule.ChildModule.ExamModule",
}

--@desc 条件结果的方法
SpecialModule.doResult = {
	["十六章答题"] = function(map, result, environment)
		-- arg1 十六章答题
		-- arg2 全错结果
		-- arg3 答对1题结果
		-- arg4 答对2题结果
		-- arg5 答对3题结果
		local resultsStrs1 = result.arg2
		local resultsStrs2 = result.arg3
		local resultsStrs3 = result.arg4
		local resultsStrs4 = result.arg5
		local QALayer = require("app.views.layer.QALayer.QALayer")
		QALayer:getInstance():showLayerByMap(
		function()
			if resultsStrs1 ~= nil then
				map:doNoRoleResults(resultsStrs1, environment)
			end
		end,
		function()
			if resultsStrs2 ~= nil then
				map:doNoRoleResults(resultsStrs2, environment)
			end
		end,
		function()
			if resultsStrs3 ~= nil then
				map:doNoRoleResults(resultsStrs3, environment)
			end
		end,
		function()
			if resultsStrs4 ~= nil then
				map:doNoRoleResults(resultsStrs4, environment)
			end
		end
		)
	end,
	
	["制作组副本奖励"] = function(map, result, environment)
		-- arg1 制作组副本奖励
		-- arg2 策略奖励
		-- arg3 不管有没有策略奖励都要调用的结果集
		local resultsStrs1 = result.arg2
		local resultsStrs2 = result.arg3
		
		HttpManagerEx:addZhiZuoZuNpcRecord(environment.currRole.baseId, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					print(environment.currRole.baseId .. " 今日完成次数 " .. data.npc_sum)
					if data.npc_sum == 1 then
						-- 每日第一次完成才可获得奖励
						if resultsStrs1 ~= nil then
							map:doNoRoleResults(resultsStrs1, environment)
						end
					end
					
					if data.add_points ~= nil and data.add_points > 0 then
						PopText("江湖美誉 + " .. data.add_points)
					end
					
					-- local ZhiZuoZu = require("app.models.ZhiZuoZu.ZhiZuoZu")
					-- ZhiZuoZu:getZhiZuoZuList( function()
					-- 	ZhiZuoZu:addTaskTotalCount(map)
					-- end)
				else
					--PopText(errmsg)
				end
			end
		end, IS_SHOW_WAITING)
		if resultsStrs2 ~= nil then
			map:doNoRoleResults(resultsStrs2, environment)
		end
	end,
	
	["赌场"] = function(map, result, environment)
		-- arg2 = 赌场每次赢调用的结果集
		local resultsStrs1 = result.arg2
		-- 文本描述
		local desc = result.arg3
		PopupLayerController:showLayer("GamblingHouseLayer", function(layer)
			layer:showLayer(function()
				if resultsStrs1 ~= nil then
					map:doNoRoleResults(resultsStrs1, environment)
					map:doRoomConditionAndResult(map.__MapLayer._currRoom.id)
				end
			end, desc)
		end)
	end,
	
	["奈何桥玩法"] = function(map, result, environment)
		local resultsStrs1 = result.arg2
		local resultsStrs2 = result.arg3
		local role = User:getRole()
		
		-- if role:getDayFlag("奈何桥玩法") >= 3 then   --	修改 每日三次改为每周三次
		-- 	-- 今日次数上限
		-- 	print("奈何桥玩法已达上限")
		-- 	if resultsStrs2 ~= nil then
		-- 		map:doNoRoleResults(resultsStrs2, environment)
		-- 	end
		-- 	return
		-- end
		

		local currtime  = GetTime()
		local startTime  =   role:getFlag("奈何桥结束时间") --  奈何桥任务结束时间，如果没有设置当前时间为奈何桥    策划沟通以奈何桥结束为准
		if startTime == 0 then
			startTime = GetTime() 
		end

		local  currWeekdy = tonumber(Helper:date("%w",currtime))
		local startWeekdy = tonumber(Helper:date("%w",startTime))
		--间隔大于7天
		if Helper:diffWithDate(currtime, startTime) >= 7 then
			role:setFlag("奈何桥奖励",0)
			role:setFlag("奈何桥玩法",0)
		--间隔小于7天，并且startWeekdy不为周末
		elseif currWeekdy ~= 0 and startWeekdy > currWeekdy then
			role:setFlag("奈何桥奖励",0) 
			role:setFlag("奈何桥玩法",0)
		elseif startWeekdy == 0 and currWeekdy > 0 then
			role:setFlag("奈何桥奖励",0)
			role:setFlag("奈何桥玩法",0)
		end


		if role:getFlag("奈何桥玩法") >= 3 then		-- 
			-- 本周次数上限
			print("奈何桥玩法已达上限")
			if resultsStrs2 ~= nil then
				map:doNoRoleResults(resultsStrs2, environment)
			end
			return
		end
		
		PopupLayerController:showLayer("HellBridgeLayer", function(layer)
			layer:showLayer(function()
				if resultsStrs1 ~= nil then
					map:doNoRoleResults(resultsStrs1, environment)
				end
			end, map)
		end)
	end,
	
	["守墓玩法"] = function(map, result, environment)
		local resultsStrs1 = result.arg2
		PopupLayerController:showLayer("CemeteryLayer", function(layer)
			layer:showLayer(function()
				if resultsStrs1 ~= nil then
					map:doNoRoleResults( resultsStrs1 , environment )
				end
			end)
		end)
	end,
	
	["生死簿玩法"] = function(map, result, environment) 
		local resultsStrs1 = result.arg2 	-- 全对
		local resultsStrs2 = result.arg3 	-- 错一题
		local resultsStrs3 = result.arg4 	-- 错两题
		local resultsStrs4 = result.arg5 	-- 错三题
		local resultsStrs5 = result.arg6 	-- 次数不足
		
		local role = User:getRole()
		-- if role:getDayFlag("生死簿玩法") >= 3 then   --	修改 每日三次改为每周三次
		-- 	-- 今日次数上限
		-- 	print("生死簿玩法已达上限")
		-- 	if resultsStrs5 ~= nil then
		-- 		map:doNoRoleResults(resultsStrs5, environment)
		-- 	end
		-- 	return
		-- end

		local currtime  = GetTime()
		local startTime  =   role:getFlag("生死簿结束时间") --  生死簿任务结束时间，如果没有设置当前时间为生死簿结束时间  策划沟通以生死簿结束为准
		if startTime == 0 then
			startTime = GetTime() 
		end

		local  currWeekdy = tonumber(Helper:date("%w",currtime))
		local startWeekdy = tonumber(Helper:date("%w",startTime))
		--间隔大于7天
		if Helper:diffWithDate(currtime, startTime) >= 7 then
			role:setFlag("生死簿奖励",0)
			role:setFlag("生死簿玩法",0)
		--间隔小于7天，并且startWeekdy不为周末
		elseif currWeekdy ~= 0 and startWeekdy > currWeekdy then
			role:setFlag("生死簿奖励",0) 
			role:setFlag("生死簿玩法",0)
		elseif startWeekdy == 0 and currWeekdy > 0 then
			role:setFlag("生死簿奖励",0)
			role:setFlag("生死簿玩法",0)
		end

		local role = User:getRole()
		if role:getFlag("生死簿玩法") >= 3 then   --	修改 每日三次改为每周三次
			-- 本周次数上限
			print("生死簿玩法已达上限")
			if resultsStrs5 ~= nil then
				map:doNoRoleResults(resultsStrs5, environment)
			end
			return
		end
		
		PopupLayerController:showLayer("LifeDeathBookLayer", function(layer)
			layer:showLayer(
			function()
				if resultsStrs1 ~= nil then
					map:doNoRoleResults(resultsStrs1, environment)
				end
			end,
			function()
				if resultsStrs2 ~= nil then
					map:doNoRoleResults(resultsStrs2, environment)
				end
			end,
			function()
				if resultsStrs3 ~= nil then
					map:doNoRoleResults(resultsStrs3, environment)
				end
			end,
			function()
				if resultsStrs4 ~= nil then
					map:doNoRoleResults(resultsStrs4, environment)
				end
			end
			)
		end)
	end,
	
	["捉鬼奖励"] = function(map, result, environment)
		local resultsStrs1 = result.arg2 	-- 成功
		local resultsStrs2 = result.arg3 	-- 次数上限
		local role = User:getRole()
		-- if role:getDayFlag("捉鬼奖励") >= 3 then    --	修改 每日三次改为每周三次
		-- 	if resultsStrs2 ~= nil then
		-- 		map:doNoRoleResults(resultsStrs2, environment)
		-- 	end
		-- 	return
		-- end

		local currtime  = GetTime()
		local startTime  =   role:getFlag("捉鬼结束时间") --  生死簿任务起始时间，如果没有设置当前时间为生死簿
		if startTime == 0 then
			startTime = GetTime() 
		end

		local  currWeekdy = tonumber(Helper:date("%w",currtime))
		local startWeekdy = tonumber(Helper:date("%w",startTime))
		--间隔大于7天
		if Helper:diffWithDate(currtime, startTime) >= 7 then
			role:setFlag("捉鬼奖励",0)
		--间隔小于7天，并且startWeekdy不为周末
		elseif currWeekdy ~= 0 and startWeekdy > currWeekdy then
			role:setFlag("捉鬼奖励",0) 
		elseif startWeekdy == 0 and currWeekdy > 0 then
			role:setFlag("捉鬼奖励",0)
		end

		local role = User:getRole()
		if role:getFlag("捉鬼奖励") >= 3 then   --	修改 每日三次改为每周三次
			-- 今日次数上限
			print("捉鬼奖励已达上限")
			if resultsStrs2 ~= nil then
				map:doNoRoleResults(resultsStrs2, environment)
			end
			return
		end
		--抓鬼的时候判断是否带面具
		local mianju = role:getPortraitId()
		local effectData = 1
		local need = 0 
		if mianju == "mianju1069" or mianju == "mianju1070" or mianju == "mianju1151" then
			effectData = 1.25
			need = 1
		end
		if  GetTime() > Helper:getTimeStampWithStringDate("20210820", 0)  and GetTime() < Helper:getTimeStampWithStringDate("20210903", 0) then 
			effectData=effectData+0.25
		end
		local points = 560 * effectData   -- 抓鬼奖励的冥币
		HttpManagerEx:addDeadCurrency(1, points,need, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if data.number > 0 then
						PopText("冥币 +" .. data.number .. "亿")
					end
					if resultsStrs1 ~= nil then
						map:doNoRoleResults(resultsStrs1, environment)
					end
					role:setFlag("捉鬼奖励", role:getFlag("捉鬼奖励") + 1)
					role:setFlag("捉鬼结束时间",GetTime())
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end,
	
	["赛龙舟"] = function(map, result, environment)
		local isPractice = result.arg2
		
		local function dragonBoat()
			if isPractice == 1 then
				PopupLayerController:showLayer("DragonBoatLayer", function(layer)
					layer:showLayer(map, true)
				end)
			elseif isPractice == 0 then
				HttpManagerEx:checkCanJoinDragonBoat(function(status, errcode, errmsg, data)
					if status == 200 then
						if errcode == 0 then
							
							local role = User:getRole()
							if PRINT_MODE == 1 then
								-- 奖励状态：0 没有或已领取，1 待领取
								print("赛龙舟奖励状态：",  role:getDayFlag("赛龙舟奖励状态"))
								print("赛龙舟次数：",  role:getDayFlag("赛龙舟次数"))
								print("赛龙舟积分：",  role:getDayFlag("赛龙舟积分"))
								print("赛龙舟付费后跨天",  role:getDayFlag("赛龙舟付费后跨天"))
							end

							-- 每天最多参加2次
							local maxTimes = 2
							
							-- 有奖励的时候，说不通的话，让玩家先去领奖励
							if role:getDayFlag("赛龙舟奖励状态") == 1 then 
								if role:getDayFlag("赛龙舟次数") >= maxTimes then
									RichPrint("main","YEL"..environment.currRole.name.."：少侠，你今天已经完成了两次，你最后一次奖励还没有领取过。")
								else
									RichPrint("main","YEL"..environment.currRole.name.."：少侠，需先领取奖励再进行龙舟大赛。")
								end
								return
							end

							if role:getDayFlag("赛龙舟次数") >= maxTimes then
								RichPrint("main","YEL"..environment.currRole.name.."：一日只能进行两次龙舟大赛，少侠可明日再来。")
								return
							end
							
							local startTime = GetTime()
							
							local function freeJoinGame()
								local text = "参与龙舟大赛，若榜上有名即可获得丰厚奖励，每日两次机会，本次免费，少侠是否参与龙舟比赛？"
								
								local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
								local dialog = DialogALayer:getInstance()
								dialog:hide()
								dialog:show(text)
								dialog:setButton1("确定", function()
									dialog:hide()
									local endTime=GetTime()
									if Helper:diffWithDate(endTime, startTime) > 0 then 
										RichPrint("main", environment.currRole.name.."：天色已黑，少侠想要参与龙舟大赛需重新报名参与。")
										return 
									end
									PopupLayerController:showLayer("DragonBoatLayer", function(layer)
										-- 非练习模式，免费
										layer:showLayer(map, false, true)
										end)
								end)
								dialog:setButton2("取消", function()
									RichPrint("main", "你决定暂时不参加龙舟大赛，" .. environment.currRole.name .. "没有多加勉强，只让你想清楚时再来找他。")
								end)
								dialog:setWeChatVisible(false)
							end

							local function notFreeJoinGame()
								-- 检测次数
								HttpManagerEx:getEquinoxTimes("sailongzhou", function(status,errcode,errmsg,data)
									if status == 200 then
										-- 获得次数成功，并且在活动时间
										if errcode == 0 and type(data)=="table" then
											if PRINT_MODE == 1 then
												Helper:print_lua_table(data)
												print("元宝：",data.remove)
												print("次数：",data.num)
											end

											local text = nil
											if data.remove > 0 then
												text = "参与龙舟大赛，若榜上有名即可获得丰厚奖励，每日两次机会，本次需花费"..tostring(data.remove).."元宝参与，少侠是否参与龙舟比赛？"
											else
												text = "参与龙舟大赛，若榜上有名即可获得丰厚奖励，每日两次机会，少侠是否参与龙舟比赛？"
											end
				
											local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
											local dialog = DialogALayer:getInstance()
											dialog:hide()
											dialog:show(text)
											dialog:setButton1("确定", function()
												dialog:hide()
												
												local dialog2 = DialogALayer:getInstance()
												dialog2:hide()
												dialog2:show("是否花费"..tostring(data.remove).."元宝，再次参与龙舟大赛？")
												dialog2:setButton1("确定", function()
													dialog2:hide()
													local endTime=GetTime()
													if Helper:diffWithDate(endTime, startTime) > 0 then 
														RichPrint("main", environment.currRole.name.."：天色已黑，少侠想要参与龙舟大赛需重新报名参与。")
														return 
													end
													HttpManagerEx:removeEquinoxPoint("sailongzhou", function(status,errcode,errmsg,data)
														if status == 200 and errcode == 0 then
															PopupLayerController:showLayer("DragonBoatLayer", function(layer)
																-- 非练习模式，不免费
																layer:showLayer(map, false, false)
																end)
														else
															PopText(errmsg)
														end
													end, IS_SHOW_WAITING) 
												end)
												dialog2:setButton2("取消", function()
													RichPrint("main", "你决定暂时不参加龙舟大赛，" .. environment.currRole.name .. "没有多加勉强，只让你想清楚时再来找他。")
												end)
												dialog2:setWeChatVisible(false)
											end)
											dialog:setButton2("取消", function()
												RichPrint("main", "你决定暂时不参加龙舟大赛，" .. environment.currRole.name .. "没有多加勉强，只让你想清楚时再来找他。")
											end)
											dialog:setWeChatVisible(false)
										elseif errcode == 1 then 
											PopText(errmsg)
										end
									else
										PopText(errmsg)
									end
								end, IS_SHOW_WAITING)
							end

							-- 没有跨天的情况下，第一次免费，付费跨天的情况下第二次免费
							if role:getDayFlag("赛龙舟次数") == 0 or (role:getDayFlag("赛龙舟付费后跨天") == 1 and role:getDayFlag("赛龙舟次数") == 1) then
								freeJoinGame()
							else
								notFreeJoinGame()
							end
						else
							PopText(errmsg)
						end
					else
						PopText(errmsg)
					end
				end, IS_SHOW_WAITING)
			end
		end

		-- 调试模式不从服务器更新时间
		if DEBUG_MODE == 1 then
			dragonBoat()
		else
			HttpManagerEx:getTime(function(status, errcode, errmsg, data)
				if status == 200 and errcode == 0 and data.time ~= nil then
					SetTime(tonumber(data.time))
					NETWORK_STATE = 1
					
					dragonBoat()
				end
			end)
		end
	end,

	["赛龙舟奖励"] = function(map, result, environment)
        local function getRewardListAndWords(score)
            if score >= 0 and score <= 159 then
                return "少侠划龙舟的技术有待加强，若能寻出窍门，想必会更好。",
				{
					{
						itemId = "money",
						number = 10000,
						name = "碎银",
						type = "属性"
					}
				}
            elseif score >= 160 and score <= 219 then
                return "少侠划龙舟的技术着实不错，之后若多加练习，定会更好，这是本次的奖励。",
				{
					{
						itemId = "gold",
						number = 200,
						name = "黄金",
						type = "属性"
					}
				}
            elseif score >= 220 and score <= 265 then
				return "少侠划龙舟的技术真让在下佩服，龙入江河而御水自如再寻常不过。迎风鼓舞、划若游龙，实在厉害，这是本次的奖励。",
				{
					{
						itemId = "gold",
						number = 200,
						name = "黄金",
						type = "属性"
					},
					{
						itemId = "xinggongsan",
						number = 1,
						type = "物品"
					}
				}
			end
        end
        local function getDayReward(rewardList)
			local role = User:getRole()
			
			-- 检查是否可以成功获得道具
			local pass = true
			for i, reward in ipairs(rewardList) do
				if reward.type == "物品" then
					local itemAttr = role:getOneItemByKey(reward.itemId)
					if itemAttr then
						if role:checkCanBuyThings(reward.itemId, reward.number) == false then
							pass = false
							break
						end
					else
						pass = false
						break
					end
				end
			end
			-- 不可以成功获得道具
			if pass == false then
				return false
			end
			
			for i, reward in ipairs(rewardList) do
				if reward.type == "物品" then
					local itemAttr = role:getOneItemByKey(reward.itemId)
					if itemAttr then
						if role:checkCanBuyThings(reward.itemId,reward.number) == true then
							role:addItemCount(reward.itemId,reward.number)
							PopText("获得物品"..itemAttr.name.."X"..tostring(reward.number))
						end
					end
				else
					role:addAttr(reward.itemId, reward.number)
					PopText(reward.name.."+"..tostring(reward.number))
				end
			end
			return true
		end
		
        local role = User:getRole()
		if PRINT_MODE == 1 then
			-- 奖励状态：0 没有或已领取，1 待领取
			print("赛龙舟奖励状态：",  role:getDayFlag("赛龙舟奖励状态"))
			print("赛龙舟次数：",  role:getDayFlag("赛龙舟次数"))
			print("赛龙舟积分：",  role:getDayFlag("赛龙舟积分"))
		end

		if role:getDayFlag("赛龙舟奖励状态") == 1 then
			local score = role:getDayFlag("赛龙舟积分") or 0
			local words, rewardList = getRewardListAndWords(math.floor(score)) 
            if MapIsEmpty(rewardList) == true then
				if DEBUG_MODE == 1 then
					print("没有赛龙舟奖励，分数：", score)
				end
				return
			end

			if getDayReward(rewardList) == true then
				role:setDayFlag("赛龙舟奖励状态", 0)
				role:setDayFlag("赛龙舟积分", 0)
				RichPrint("main", "YEL"..environment.currRole.name.."："..words)
			end
        else
            RichPrint("main","YEL"..environment.currRole.name.."：少侠需先进行龙舟大赛，才可领取奖励。")
        end
    end,
	
	["互搏神通"] = function(map, result, environment)
		local Meridian = require("app.models.Meridian.Meridian")
		local role = User:getRole()
		local inheritCount = role:getAttr("inheritCount")
		
		-- 老朽平生没什么爱好，唯饮酒尔。
		-- 若有周公酒，老夫倒可以指点指点你。
		-- 年轻人，习武切忌急躁，需循序渐进、缓缓图之。
		-- 年轻人，你这门武学已经练到家了，老朽也没什么可教给你的了。
		if role:isHaveImprintingId("zuoyouhuboyin") == true then
			if role:getAttr("leftRightFightExp") >= 900 then
				PopText("互搏神通已经满级！")
				RichPrint("main", "YEL无名老者：年轻人，你这门武学已经练到家了，老朽也没什么可教给你的了。")
				return
			end
			if role:getDayFlag("左右互搏游戏次数") >= 6 then
				PopText("今日次数已用完！")
				RichPrint("main", "YEL无名老者：年轻人，习武切忌急躁，需循序渐进、缓缓图之。")
				return
			end
			-- 升级  先判断福禄寿酒
			if role:getItemCount("zuoyouhubo1") <= 0 and role:getItemCount("zuoyouhubo2") <= 0 then
				RichPrint("main", "YEL无名老者：若有周公酒或福禄寿酒，老夫倒可以指点指点你。")
				return
			end
			
			if role:getItemCount("zuoyouhubo1") <= 0 then
				if role:getItemCount("zuoyouhubo2") <= 0 then
				else
					role:addItemCount("zuoyouhubo2", - 1)
				end
			else
				role:addItemCount("zuoyouhubo1", - 1)
			end
			
			role:setDayFlag("左右互搏游戏次数", role:getDayFlag("左右互搏游戏次数") + 1)
			User:getRole():setFlag("PVP活动状态", "忙碌")
			PopupLayerController:showLayer("LeftRightFightGameLayer", function(layer)
				layer:showLayer("promote")
			end)
		else
			if Meridian:checkCanOpenLeftRightFight() ~= true then
				PopText("未到达互搏神通学习要求")
				RichPrint("main", "YEL无名老者：老朽平生没什么爱好，唯饮酒尔。")
				return
			end
			
			-- 学习 传承三次以上无需道具
			if inheritCount < 3 then
				if role:getItemCount("zuoyouhubo1") <= 0 then
					PopText("福禄寿酒数量不足")
					RichPrint("main", "YEL无名老者：老朽平生没什么爱好，唯饮酒尔。")
					return
				else
					role:addItemCount("zuoyouhubo1", - 1)
				end
			end
			User:getRole():setFlag("PVP活动状态", "忙碌")
			PopupLayerController:showLayer("LeftRightFightGameLayer", function(layer)
				layer:showLayer("open")
			end)
		end
	end,
	
	["互搏神通练习"] = function(map, result, environment)
		local Meridian = require("app.models.Meridian.Meridian")
		if Meridian:checkCanOpenLeftRightFight() ~= true then
			PopText("未到达互搏神通学习要求")
			RichPrint("main", "YEL无名老者：老朽平生没什么爱好，唯饮酒尔。")
			return
		end
		
		User:getRole():setFlag("PVP活动状态", "忙碌")
		PopupLayerController:showLayer("LeftRightFightGameLayer", function(layer)
			layer:showLayer("Practice")
		end)
	end,
	
	["说书人"] = function(map, result, environment)
		local role = User:getRole()
		local resultsStrs1 = result.arg2 	-- 成功
		local resultsStrs2 = result.arg3 	-- 失败
		local resultsStrs3 = result.arg4 	-- 完成
		if role:getDayFlag("说书人次数") == 0 then
			if role:getFlag("说书人进度") >= 7 then
				-- 读完
				if resultsStrs3 ~= nil then
					map:doNoRoleResults(resultsStrs3, environment)
				end
			else
				local index = role:getFlag("说书人进度") + 1
				local Anniversary = require("app.models.Anniversary.Anniversary")
				Anniversary:storyteller(index, function()
					role:setDayFlag("说书人次数", 1)
					role:setFlag("说书人进度", index)
					if resultsStrs1 ~= nil then
						map:doNoRoleResults(resultsStrs1, environment)
					end
				end)
			end
		else
			-- 今日已读
			if resultsStrs2 ~= nil then
				map:doNoRoleResults(resultsStrs2, environment)
			end
		end
	end,
	
	["分组对抗"] = function(map, result, environment)
		local ControllLayer = require("app.views.layer.ControllLayer")
		local controllLayer = ControllLayer:getInstance()
		controllLayer:pushLayer("JiuChouGroupLayer")
		local JiuChouGroupLayer = controllLayer:getLayer("JiuChouGroupLayer")
		JiuChouGroupLayer:showLayer()
	end,
	
	["论剑送礼"] = function(map, result, environment)
		local BiWu = require("app.models.BiWu.BiWu")
		local currTime = GetTime()
		local fightAllData = BiWu:getfightAllData()
		if fightAllData and fightAllData.fightExpired_time and currTime < fightAllData.fightExpired_time and fightAllData.result == "lose" then
			BiWu:payYuanBao(function()
				----使用元宝后，挑战消失，上台
				local fightAllData = BiWu:getfightAllData()
				fightAllData.fightExpired_time = nil
				local str = "武馆管家跑了进去，跳上擂台，身子出奇的轻快。“待老夫来会会你”，话才说完，人已经跃到台上，一把拎起$b,往台下一扔。$b并没有反应过来，一脸懵然。"
				if fightAllData.user and fightAllData.user.name then
					str = string.gsub(str, "$b", tostring(fightAllData.user.name))
				end
				
				local startLayer = MainControllLayer:getInstance():getLayer("BiWuStartLayer")
				startLayer._UI:print(str)
				map.__MapLayer:delayFunc(2, function()
					startLayer._UI:print("下一位请入场！")
				end)
				----武馆管家赶走擂主的标识
				BiWu._guanJiaThrowOutBattle = true
				BiWu:savefightAllData(fightAllData)
			end)
		else
			PopText("老夫不接受你的礼物")
		end
	end,
	
	["论剑记录"] = function(map, result, environment)
		PopText("论剑记录")
		local BiWu = require("app.models.BiWu.BiWu")
		local BiWuRankingLayer = require("app.views.layer.BiWuLayer.BiWuRankingLayer")
		do
			local fightWeekAllData = BiWu:getfightWeekAllData()
			if fightWeekAllData.weekUserData and fightWeekAllData.weekUserData.list and #fightWeekAllData.weekUserData.list < 1 then
				PopText("你还没上台比武过！")
				return
			end
		end
		
		PopupLayerController:showLayer("BiWuRankingLayer", function(layer)
			local mark, list = {}
			-----从服务器获取list列表，数据
			BiWu:initRankings(3, function(mark, list)
				if mark == true then
					BiWu.list = "week"
					layer:show(BiWu.list)
					layer._UI:createListViews(3, list)
					layer:showWeekTop(
					function()
					end)
					
				else
					if PRINT_MODE == 1 then
						PopText("从服务器获取比武排行数据失败")
					end
					return
				end
			end, function()
				layer:hide()
			end)
		end)
	end,
	
	["论剑规则"] = function(map, result, environment)
		PopupLayerController:showLayer("BiWuGuanJiaLayer", function(layer)
			layer:show()
			layer:setRoleShow()
		end)
	end,
	
	["段位结算奖励"] = function(map, result, environment)
		print("-----------------------------------------")
		local function getDuanWeiName(sid)
			local GroupAgainst = require("script.others.Group")
			local name = ""
			if not sid then
				return name
			end
			local group = Helper:getDef(GroupAgainst["group"],{})
			if type(group["duanwei"..tostring(sid)]) == "table" then
				name = Helper:getDef(group["duanwei"..tostring(sid)]["rankname"],"无名小辈")
			end
			return name
		end
		HttpManagerEx:getGroupAgainstReward("group_fight","info",nil,function(status, errcode, errmsg, data, isEncrypted)
			if status == 200 and errcode == 0 then
				data = Helper:getDef(data,{})
				print("-----------getGroupAgainstReward------------info------------------")
				Helper:print_lua_table(data)
				local reward = {}
				for k,v in pairs(Helper:getDef(data.daoju,{})) do 
					if type(k) == "string" and tonumber(v) ~= nil then
						reward[k] = tonumber(v)
					end
				end
				if User:getRole():checkCanBuyTwoOrMoreThings(reward) == true then
					HttpManagerEx:getGroupAgainstReward("group_fight","receive",nil,function(status, errcode, errmsg, data, isEncrypted)
						if status == 200 and errcode == 0 then
							print("===============getGroupAgainstReward===============receive======================")
							-- Helper:print_lua_table(data)
							data = Helper:getDef(data,{})
							local rewardText = ""
							for k,v in pairs(Helper:getDef(data.daoju,{})) do 
								local item = Item:getOneItemByKey((k))
								if item ~= nil then
									PopText("获得物品"..item.name.."X"..tostring(v))
									User:getRole():addItemCount(k,v)
									rewardText = item.name.."X"..tostring(v).."\n"
								end
							end
							if data.isJinJi == "Y" then
								PopupLayerController:showLayer("PromotedSuccessLayer",function(layer)
									layer:showLayer()
									layer:setPromotedByNumber(data.groupName,data.groupRank)
									layer:setFinalPerformanceByNumber(data.jiuchou,data.point,data.home_win_times)
									layer:setGrading(getDuanWeiName(data.lastDW,data.nowDW))
									layer:setFinalReward(rewardText)
								end)
							end
						else
							PopText(errmsg)
						end
					end,IS_SHOW_WAITING)
				else
					PopText("背包空间不足")
				end
			else
				PopText(errmsg)
			end
		end,IS_SHOW_WAITING)
	end,
	
	["论剑入场"] = function(map, result, environment)
		local BiWu = require("app.models.BiWu.BiWu")
		Audio:playMusic("biwu_leitai",true)

		--从服务器获取次数并保存到一个文件里fidAndtimes
		BiWu:getBiWuFightTimes(function()

			----------入场前处理上次没有结束的战斗
			BiWu:resolveUnnormalFightResult()

				---从本地获取数据，
			local fightAllData = BiWu:getfightAllData()
			local currTime = GetTime()

			map.__MapLayer.ControllLayer:pushLayer("BiWuMainLayer")
			local biWuMainLayer = map.__MapLayer.ControllLayer:getLayer("BiWuMainLayer")
			if fightAllData and fightAllData.left_times then
				biWuMainLayer:setTimesNumber(fightAllData.left_times)
			end
			biWuMainLayer:show()
			local str = BiWu:getstartLayerTextToMainLayerText()
			biWuMainLayer._UI:print(str)
			if fightAllData and fightAllData.fightExpired_time and currTime < fightAllData.fightExpired_time and fightAllData.result == "lose" then
				biWuMainLayer:setButtonStage("挑战")
			end
		end)

	end,
	
	["论剑排行榜"] = function(map, result, environment)
		local BiWu = require("app.models.BiWu.BiWu")
		PopupLayerController:showLayer("BiWuRankingLayer", function(layer)
			local mark ,list = {}
			-----从服务器获取list列表，数据
			BiWu:initRankings(2,function(mark,list)
				if mark == true then
					BiWu.list = "people"
					layer:show(BiWu.list)
					layer._UI:createListViews(2,list)
					layer:showPeopleTop()
				else
					if PRINT_MODE ==1 then
						PopText("从服务器获取比武排行数据失败")
					end
					return
				end
			end,function ()
				layer:hide()
			end)
		end)
	end,
	
	["查看公告"] = function(map, result, environment)
		PopupLayerController:showLayer("BiWuNoticeLayer", function(layer)
			layer:show()
		end)
	end,

	["论剑入口"] = function(map, result, environment)
		if Map:getMapState("fb01") ~= MAP_STATE.COMPLETE then
			PopText("少侠踏入江湖尚浅，请积累经验后再尝试参与")
			return
		end

		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:show()
		dialog:setRichText( "进入参与论剑需要离开当前副本，是否离开？")
		dialog:setButton1("确定", function()
			local BiWu = require("app.models.BiWu.BiWu")
			Audio:playEffect("daAnNiu")
			----清除战斗类型
			BiWu:clearFightType()
			----一个礼拜删除一次本周对战数据
			BiWu:deleteWeekFightData()
			-- 校验所有凭证（轮将奖励的类型是 4 ）
			TransCheck:checkTransWithType(4)
			BiWu:getBiWuFighMessage(function ()
				map.__MapLayer:stopMusic()
				map.__MapLayer:quitData()
				PopText("你退出了副本")

				MainControllLayer:getLayer("MapRoleLayer"):onPause()
				MainControllLayer:getLayer("MapRoleLayer"):setVisible(false)

				local layer = MainControllLayer:getLayer("PrintLayer")
				layer:setLocalZOrder(0)
				layer:hide(true)

				local layer = MainControllLayer:getLayer("TitleLayer")
				layer:setLocalZOrder(10)
				layer:ButtonBack(function()
					MainControllLayer:pushLayer("MainLayer")
				end)
				layer:show(true)
				--转到比武
				MainControllLayer:pushLayer("BiWuStartLayer")
				local biWuStartLayer = MainControllLayer:getLayer("BiWuStartLayer")
				biWuStartLayer:show()
				local str = BiWu:getmainLayerToStartLayerText()
				biWuStartLayer._UI:print(str)

				---五分钟上传一次存档
				BiWu:uploadRecordFiveMinuteOnce()

			end,function()
				---如果是作弊用户，不然进入这个界面
				return
			end)
		end)
		dialog:setButton2("取消", function()
			dialog:hide()
		end)
		dialog:setWeChatVisible(false)
	end, 
	
	["唐门之乱播放动画"] = function(map, result, environment)
		local Anniversary = require("app.models.Anniversary.Anniversary")
			Anniversary:storyteller(8, function()
		end)
	end,

	["长生诀条件结果"] = function(map, result, environment)
		local TreasureHelper = require("app.models.treasure.TreasureHelper")
		TreasureHelper:getWaBaoReward(function()
			if type(result.arg2) ~= "string" then
				return
			end
			map:doNoRoleResults(result.arg2,environment)
		end)
	end,
	
	["锻造"] = function(map, result, environment)
		if User:getRole():getInheritFlag("可进入苏州水底") == 1 or DEBUG_MODE == 1  then
			MainControllLayer:pushLayer("FurnaceLayer")
			local FurnaceLayer = MainControllLayer:getLayer("FurnaceLayer")
			FurnaceLayer:entryLayer(result.arg3)
		else
			if result.arg2 then
				RichPrint("main",result.arg2)
			end
		end
	end,
	
	["熔炉"] = function(map, result, environment)
		if User:getRole():getInheritFlag("可进入苏州水底") == 1 or DEBUG_MODE == 1  then
			assert(tonumber(result.arg2) and tonumber(result.arg3)) --下限温度，上线温度
			PopupLayerController:showLayer("ShenBingRongLianLayer",function(layer)
				-- layer:setInitValue(tonumber(result.arg2),tonumber(result.arg3))
				layer:showLayer(tonumber(result.arg2),tonumber(result.arg3))
			end)
		else
			if result.arg4 then
				RichPrint("main",result.arg4)
			end
		end
	end,

	["神兵加工"] = function(map, result, environment)
		local player = User:getRole()
		if player:getInheritFlag("可进入苏州水底") == 0 and DEBUG_MODE ~= 1 then
			PopText("神兵系统未开启，无法使用该功能。")
			return
		end

		local items = player:getItems(function(item)
			if item.type == "神兵" then
				return true
			else
				return false
			end
		end)

		if MapIsEmpty(items) == true then
			PopText("背包中没有神兵，无法使用该功能！")
			return
		end

		local shenBing = player:getDefaultShenBing()
		if not shenBing then
			PopText("您还没有装上默认神兵，无法进行操作")
			return
		end

		PopupLayerController:showLayer("JiaGong", function(layer)
			layer:show()
		end)
	end,
	
	["修理兵器"] = function(map, result, environment)
		if User:getRole():getInheritFlag("可进入苏州水底") == 0 and DEBUG_MODE ~= 1  then
			PopText("神兵系统未开启，无法使用该功能。")
			return
		end

		--@desc result.arg2 人物标识，2为欧冶子、3为铁匠，可定制技能等级和名字
		local roleType = result.arg2
		--@desc result.arg3 锻造等级，默认300
		local skiLv = result.arg3
		--@desc result.arg4 人物角色名字，默认（铁匠）
		local name = result.arg4

		if roleType == 1 then
			--@RefType [src.app.models.role.Role#Role]
			local role = User:getRole()

			local skillLv = User:getRole():getSkillLv("duanzaozhishu")

			if skillLv == 0 then
				PopText("你未学习锻造之术，无法进行修理")
				return
			end
		end

		local ShenBingFixLayer = require("app.views.layer.ShenBingLayer.FixLayer.ShenBingFixLayer")
		ShenBingFixLayer:showLayer(roleType,skiLv,name)
	end,

	["熔兵"] = function(map, result, environment)
		if User:getRole():getInheritFlag("可进入苏州水底") == 0 and DEBUG_MODE ~= 1  then
			PopText("神兵系统未开启，无法使用该功能。")
			return
		end
		local rongBing = require("app.views.layer.ShenBingLayer.RongBingLayer.RongBingLayer")
		rongBing:setBackFunc(function()
		end)
		
		rongBing:showLayer()
	end,
	
	["神兵改名"] = function(map, result, environment)
		local player = User:getRole()
		if player:getInheritFlag("可进入苏州水底") == 0 and DEBUG_MODE ~= 1 then
			PopText("神兵系统未开启，无法使用该功能。")
			return
		end

		
		local items = player:getItems(function(item)
			if item.type == "神兵" then
				return true
			else
				return false
			end
		end)
		if MapIsEmpty(items) == true then
			PopText("背包中没有神兵")
		else
			local weapen = player:getDefaultShenBing() 

			if not weapen then
				PopText("您还没有装上默认神兵，无法进行操作")
				return
			end

			PopupLayerController:showLayer("ShenBingNameLayer",function(layer)
				layer:showLayer(2,weapen,function(rweapen)
					local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
					ShenBingDuanZao:updateShenBingInfo(rweapen)
				end)
			end)
		end
	end,
	
	["淬炼兵器"] = function(map, result, environment)
		--[[
			arg2 : 淬炼类型，1是自己淬炼，2是欧冶子淬炼，3是铁匠
			arg3 : 铁匠技能等级
		]]
		local player = User:getRole()

		if player:getInheritFlag("可进入苏州水底") == 0 and DEBUG_MODE ~= 1 then
			PopText("神兵系统未开启，无法使用该功能。")
			return
		end
		
		local weapons = player:getItems(function(item)
			return item.type == "神兵"
		end)

		if MapIsEmpty(weapons) == true then
			PopText("你身上没有神兵")
			return 
		end

		local weapon = player:getDefaultShenBing()
		if not weapon then
			PopText("您还没有装上默认神兵，无法进行操作")
			return
		end

		local roleType = result.arg2
		local skiLv = result.arg3
		local roleName = result.arg4
		local npc = environment.currRole
		local costFactor = npc:getBuffAttr("cuilianPriceReduce")

		if roleType == 1 then
			PopupLayerController:showLayer("ShenBingCuiLianLayer",function(layer)
				layer:showLayer(weapon,skiLv,roleName,costFactor)
			end)
		else
			PopupLayerController:showLayer("ShenBingNPCCuiLianLayer",function(layer)
				layer:showLayer(weapon,roleType,skiLv,roleName,costFactor)
			end)
		end
	end,

	["锻器"] = function(map, result, environment)
		if User:getRole():getInheritFlag("可进入苏州水底") == 0 and DEBUG_MODE ~= 1  then
			PopText("神兵系统未开启，无法使用该功能。")
			return
		end

		--@desc result.arg2 人物标识，1为欧冶子、2为家园铁匠
		local roleType = result.arg2
		--@desc result.arg3 人物角色名字
		local roleName = result.arg3
		
		local ShenBingDuanQiLayer = require("app.views.layer.ShenBingLayer.FixLayer.ShenBingDuanQiLayer")
		ShenBingDuanQiLayer:showLayer(roleType,roleName)
	end,
	
	["配制毒药"] = function(map, result, environment)
		local itemIdList = string.split(result.arg2, ";")

		--@RefType [src.app.models.Poison.PoisonUtil#PoisonUtil]
		local PoisonUtil = require("app.models.Poison.PoisonUtil")
		
		local list = {}
		
		local data = {}
		local item = {}
		for _, itemId in ipairs(itemIdList) do
			data = {}
			item = Item:getOneItemByKey(itemId)
			if not item then
				assert(false,"没有该毒药："..itemId)
			end
			data.name = item.name
			data.itemId = itemId
			table.insert(list, data)
		end
		
		PopupLayerController:showLayer(
			"ItemSelectLayer",
			function(layer)
				layer:setBtnClickFunc(
					function(itemId)
						local fun = PoisonUtil:makePoison(itemId,result.arg3)
		
						PopupLayerController:hideLayer("ItemSelectLayer",function (layer)
							layer:hideLayer()
						end)
		
						if type(fun) == "function" then
							local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
							local maplayer = MainControllLayer:getLayer("MapLayer")
							User:getRole():setFlag("PVP活动状态", "忙碌")
							MapRoleLayer:statusButtonFunc(
								false,
								function ()
									PopText("正在制作毒药，请稍等。")
								end
							)
							MapRoleLayer:exitButtonFunc(
								false,
								function()
									PopText("正在制作毒药，请稍等。")
								end
							)
							maplayer:setUnmoveRoom(
								true,
								function()
									PopText("正在制作毒药，请稍等。")
								end
							)
							maplayer._currMap:setCanLeave(false)
							maplayer:setNPCTouchEnabled(
								true,
								function()
									PopText("正在制作毒药，请稍等。")
								end
							)
							map:setSchedule(
								function(tag)
									local condition = fun()
									if condition then
										User:getRole():setFlag("PVP活动状态", "空闲中")									
										map:unSchedule(tag)
										MapRoleLayer:exitButtonFunc(true)
										MapRoleLayer:statusButtonFunc(true)
										maplayer:setUnmoveRoom(false)
										maplayer._currMap:setCanLeave(true)
										maplayer:setNPCTouchEnabled(false)
									end
								end,
								1
							)
						end
					end
				)
				layer:setList(list)
				layer:setTitle("你要制作何种毒药？")
				layer:showLayer()
            end
        )
	end,

	["冥商回收"] = function(map, result, environment)
		HttpManagerEx:viewCurrencyByType("mingbi", User:getRole():getCurrencyVersion(), function(status, errcode, errmsg, data)
			if status == 200 and errcode == 0 then
				if data.number >= 0 then
					if DEBUG_MODE == 1 then
						PopText("您所欠冥币已全部还清")
					end
					RichPrint("main", result.arg2)
				else
					local MingBiRecycleLayer = require("app.views.layer.SalesLayer.MingBiRecycleLayer")
					local layer = MingBiRecycleLayer:getInstance()
					layer:setRoles(User:getRole(), environment.currRole)
					layer:setTextMoney(data.number)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end,

	["长生诀补偿"] = function(map, result, environment)

		-- -- 判断时间是否在期限内
		-- local year = Helper:date("%Y",GetTime())
		-- local month = Helper:date("%m",GetTime())
		-- local day = Helper:date("%d",GetTime())
		-- if year ~= "2018" then
		-- 	return
		-- elseif month ~="03" and month ~= "04" then
		-- 	return
		-- elseif (month == "03" and day < "20") or (month == "04" and day > "31") then
		-- 	return
		-- end
		local role = User:getRole()

		local count = role:getBookCaseItemCount("shuye93")
		if count <= 0 then
			map:doNoRoleResults(result.arg4,environment)
			return
		end

		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		if count >= 2 then
		        local dialog = DialogALayer:getInstance()
		        dialog:hide()
		        dialog:show("是否愿意将长生诀金给予颓笔翁？")
		        dialog:setBack(false)
				dialog:setButton1("确定",function()
					if role:checkCanBuyTwoOrMoreThings({["changshengli"] = 1}) then
						role:addItemCount("shuye93", -1)
						PopText("你已把身上的长生诀（金）给予颓笔翁。")
						role:addItemCount("changshengli", 1)
						map:doNoRoleResults(result.arg2,environment)
						local name = Item:getOneItemByKey("changshengli").name
						PopText("你获得了"..name.." X 1")
					end
					
				end)
				dialog:setButton2("取消",function()
					
		        end)
			elseif count == 1 then
				local skillLv1 = role:getSkillLv("changshengjue")
				local skillLv2 = role:getSkillLv("changshengjueyin")
				local skillLv3 = role:getSkillLv("changshengjueyang")
				if skillLv1 >= 100 or skillLv2 >= 100 or skillLv3 >= 100 then
					local dialog = DialogALayer:getInstance()
					dialog:hide()
					dialog:show("是否愿意将长生诀金给予颓笔翁？")
					dialog:setBack(false)
					dialog:setButton1("确定",function()
						if role:checkCanBuyTwoOrMoreThings({["changshengli"] = 1}) then
							role:addItemCount("shuye93", -1)
							PopText("你已把身上的长生诀（金）给予颓笔翁。")
							role:addItemCount("changshengli", 1)
							map:doNoRoleResults(result.arg2,environment)
							local name = Item:getOneItemByKey("changshengli").name
							PopText("你获得了"..name.." X 1")
						end
					end)
					dialog:setButton2("取消",function()
			    	end)
				else
					map:doNoRoleResults(result.arg3,environment)
				end

			end
	end,
}



return SpecialModule00000000000000