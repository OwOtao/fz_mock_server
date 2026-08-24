--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local TaskModule = class("TaskModule", require("app.models.map.MapHandle.Modules.BaseModule"))

--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
TaskModule.mapId = nil

--@desc 涉及房间 : 格式{["id"] = true} 默认为nil，无限制
TaskModule.roomId = nil

--@desc 开启状态，默认开启
TaskModule.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
TaskModule.activityTime = 0

--@desc 子模块
TaskModule.childModule = {
	["神书任务"] = "app.models.map.MapHandle.Modules.TaskModule.ShenShuTask",
	["师门任务"] = "app.models.map.MapHandle.Modules.TaskModule.TeacherTask",
	["拜访任务"] = "app.models.map.MapHandle.Modules.TaskModule.VisitTask",
}

--@desc 条件结果的方法
TaskModule.doResult = {
	["送信时间随机"] = function(map, result, environment)
		local interval = result.arg2
		interval = math.random(200, interval)  --获取随机值
		print("送信时间随机最大值:" .. result.arg2 .. "随机值" .. interval)
		
		map.letterInterval = interval
	end,
	
	["送信奖励"] = function(map, result, environment)
		--@RefType [src.app.models.role.Role#Role]
		local role = User:getRole()
		
		role:setDayFlag("送信奖励", role:getDayFlag("送信奖励") + 1)
		role:setTaskTimes("songxin", role:getTaskTimes("songxin") + 1)
		local count = role:getDayFlag("送信奖励")
		local round = math.ceil(count / 10)
		PopText("完成送信任务 今日完成次数 " .. count)
		
		-- 获取奖励
		local ratio = 1
		local pot = 0
		local money = 0
		ratio =(1 -((round - 1) * 0.2))
		-- 超过50次没有潜能碎银奖励
		if ratio > 0 then
			local exp = role:getAttr("exp")
			local fy = role:getFinalAttr("luck")
			local sklv = role:getKongfu()
			
			pot = math.floor(Formula:getFormula("qianneng1")(exp, fy, sklv, 144) * ratio)
			money = math.floor(Formula:getFormula("suiyin1")(exp, fy, sklv, 720) * ratio)
			
			-- 春节活动收益加成
			local buff = 1
			local SpringFestival = require("app.models.SpringFestival.SpringFestival")
			if SpringFestival:getProfitActivityState() == 1 then
				buff = buff + 1
			end
			pot = pot * buff
			money = money * buff
			
			role:addAttr("pot", pot)
			role:addAttr("money", money)
			PopText("碎银 + " .. tostring(money))
			PopText("潜能 + " .. tostring(pot))
			map:richPrintText(role, "money", money)
			map:richPrintText(role, "pot", pot)
		else
			PopText("今天完成次数已超过50次 无法得到奖励")
		end
		
		if count % 10 == 0 then
			PopText("你已完成10次送信任务 得到银宝箱")
			if not map:addItemCount("tie110", 1) then
				map:dropItem(environment.currRoomId, "tie110")
				return
			end
			role:addItemCount("tie110", 1)
			Statistics:recordItemCount("tie110", 1) -- 用于统计
		end
	end,
	
	["悬赏奖励"] = function(map, result, environment)
		local role = User:getRole()

		role:setDayFlag("悬赏奖励", role:getDayFlag("悬赏奖励") + 1)
		local count = role:getDayFlag("悬赏奖励")
		local round = math.ceil(count / 10)
		PopText("完成悬赏任务 今日完成次数 " .. count)
		
		-- 获取奖励
		local ratio = 1
		local pot = 0
		local money = 0
		ratio =(1 -((round - 1) * 0.2))
		-- 超过50次没有潜能碎银奖励
		if ratio > 0 then
			local exp = role:getAttr("exp")
			local fy = role:getFinalAttr("luck")
			local sklv = role:getKongfu()
			
			pot = math.floor(Formula:getFormula("qianneng1")(exp, fy, sklv, 720) * ratio)
			money = math.floor(Formula:getFormula("suiyin1")(exp, fy, sklv, 144) * ratio)
			
			-- 春节活动收益加成
			local buff = 1
			local SpringFestival = require("app.models.SpringFestival.SpringFestival")
			if SpringFestival:getProfitActivityState() == 1 then
				buff = buff + 1
			end
			pot = pot * buff
			money = money * buff
			
			role:addAttr("pot", pot)
			role:addAttr("money", money)
			
			PopText("碎银 + " .. tostring(money))
			PopText("潜能 + " .. tostring(pot))
			map:richPrintText(role, "money", money)
			map:richPrintText(role, "pot", pot)
		else
			PopText("今天完成次数已超过50次 无法得到奖励")
		end
		
		if count % 10 == 0 then
			PopText("你已完成10次悬赏任务 得到银宝箱")
			if not map:addItemCount("tie110", 1) then
				map:dropItem(environment.currRoomId, "tie110")
				return
			end
			role:addItemCount("tie110", 1)
			Statistics:recordItemCount("tie110", 1) -- 用于统计
		end
	end,
	
	["完成追击任务"] = function(map, result, environment)
		local role = User:getRole()
		local Task = require("app.models.task.Task")
		local roleTsak = Task:getRoleTask("task17")
		
		--task17 为追击任务 当前状态为主动任务且为task17时 任务完成
		if role:isInCurrState(ROLE_CURR_STATE_ZHUDONG) and Task:getRoleCurrTaskId() == "task17" then
			print("完成追击任务 roleTsak.state = TASK_STATE_TO_SUBMIT")
			roleTsak.state = TASK_STATE_TO_SUBMIT
		end
	end,
	
	["缉拿任务时间随机"] = function(map, result, environment)
		local role = User:getRole()

		local interval = result.arg2
		interval = math.random(200, interval)
		print("缉拿任务时间随机最大值:" .. result.arg2 .. "随机值" .. interval)
		User:setRoleAttr("wantedInterval", interval)
		User:setRoleAttr("wantedTime", GetTime())
	end,
	
	["随机缉拿任务"] = function(map, result, environment)
		local progress = User:getRoleAttr("jindu")
		local player = User:getRole()
		if progress == 0 then
			progress = 1
		end
		
		--缉拿任务 根据江湖进度 从xuan1 ~ xuanXXX 中获取物品
		local wantedItemId =
		{
			[1] = 1,
			[2] = 2,
			[3] = 4,
			[4] = 6,
			[5] = 8,
			[6] = 9,
			[7] = 11,
			[8] = 12,
			[9] = 14,
			[10] = 16,
			[11] = 17,
			[12] = 18,
			[13] = 19,
			[14] = 20,
			[15] = 21,
			[16] = 23,
			[17] = 24,
			[18] = 26,
			[19] = 27,
			[20] = 29,
			[21] = 30,
			[22] = 31,
			[23] = 32,
			[24] = 33,
			[25] = 35,
			[26] = 37,
			[27] = 39,
			[28] = 40,
			[29] = 41,
			[30] = 42,
			[31] = 43,
			[32] = 45,
			[33] = 46,
			[34] = 47,
			[35] = 48,
			[36] = 48,
			[37] = 48,
		}
		
		--根据江湖进度获物品
		local function getWantedItemId(progress)
			local p = 0
			local id
			for k, v in pairs(wantedItemId) do
				if k <= progress then
					p = k
				end
			end
			print("获得悬赏公告范围1~" .. wantedItemId[p])
			id = math.random(1, wantedItemId[p])
			local str = "xuan" .. tostring(id)
			
			return str, id
		end
		
		local itemId, id = getWantedItemId(progress - 1)
		local itemCount = 1
		
		--User:setRoleAttr("wantedTime", GetTime())
		print("当前通关进度: " .. progress - 1 .. " 获取悬赏公告" .. id)
		
		--增加能否获取物品的判断 7/22
		if not map:addItemCount(itemId, itemCount) then
			map:dropItem(environment.currRoomId, itemId)
			return
		end
		
		player:addItemCount(itemId, itemCount)
		Statistics:recordItemCount(itemId, itemCount) -- 用于统计
		
		PopText("你获得了 " .. Item:getOneItemByKey(itemId).name)
	end,
	
	["萧子远任务"] = function(map, result, environment)
		local Anniversary = require("app.models.Anniversary.Anniversary")
		Anniversary:acceptXiaoZhiYuan()
		-- Anniversary:createRoleToMap(map)
	end,
	
	["箫子远送礼"] = function(map, result, environment)
		local Anniversary = require("app.models.Anniversary.Anniversary")
		local role = User:getRole()
		
		if role:getFlag("萧子远任务") ~= 0 then
			local str = role:getFlag("萧子远任务")
			local strList = string.split(str, ";")
			if strList[2] == "1" then
				-- 已完成不处理
				RichPrint("main", "CYN我不接受你的物品")
			else
				if strList[1] == "2" then
					if role:getItemCount(strList[3]) > 0 then
						-- 送礼任务 扣除道具
						role:addItemCount(strList[3], - 1)
						Anniversary:finishTask("萧子远任务")
						Anniversary:acceptXiaoZhiYuan()
						return
					end
				end
			end
		else
			RichPrint("main", "CYN我不接受你的物品")
		end
	end,
	
	["箫子远拜访"] = function(map, result, environment)
		local Anniversary = require("app.models.Anniversary.Anniversary")
		Anniversary:finishTask("萧子远任务")
		RichPrint("main", "CYN你替萧子远拜访了" .. environment.currRole.name .. "，快回去复命吧。 ")
	end,
	
	["惊鸿燕任务"] = function(map, result, environment)
		local Anniversary = require("app.models.Anniversary.Anniversary")
		Anniversary:acceptJingHongYan()
		-- Anniversary:createRoleToMap(map)
	end,
	
	["劫富济贫"] = function(map, result, environment)
		-- 怀里成功文本
		local huailiSuccessDesc =
		{
			"CYN你看好$N前进的方向，提前到他前方去埋伏着。",
			"HIY只见$N缓缓向你走来，你赶紧冲着他快步走去。",
			"HIG恰在他与你相遇时，身体撞向他怀中！",
			"HIC你伸手顺势向他怀里一捞，一个沉甸甸的物事落入你手中！",
			"HIW你连忙道了一声歉，头也不回地飞快走了。",
			"HIW东西已经到手，快回去复命吧。",
		}
		
		-- 怀里失败文本
		local huanliFailDesc =
		{
			"CYN你看好$N前进的方向，提前到他前方去埋伏着。",
			"HIY只见$N缓缓向你走来，你赶紧冲着他快步走去。",
			"HIG恰在他与你相遇时，身体撞向他怀中！",
			"HIC你伸手顺势向他怀里一捞，但却什么也没捞到！",
			"HIW你连忙道了一声歉，头也不回地飞快走了。",
			"HIW你一无所获，他也已经有了警惕，看来这次是失败了。",
		}
		
		-- 袖囊成功文本：
		local xiunangSuccessDesc =
		{
			"CYN你心生一计，在路边捡了一个石子。",
			"HIY你看准$N前进的方向，不动声色地从后方靠了过去。",
			"HIG你慢慢加快步伐，从其右侧经过，将手中石子向左打去。",
			"HIC却见$N向左转身看去，你趁机往其双袖一摸！",
			"HIW一个沉甸甸的物事落入你的手，你赶忙向一旁一走开。",
			"HIW东西已经到手，快回去复命吧。",
		}
		
		-- 袖囊失败文本：
		local xiunangFailDesc =
		{
			"CYN你心生一计，在路边捡了一个石子。",
			"HIY你看准$N前进的方向，不动声色地从后方靠了过去。",
			"HIG你慢慢加快步伐，从其右侧经过，将手中石子向左打去。",
			"HIC却见$N向左转身看去，你趁机往其双袖一摸！",
			"HIW但却一无所获！你为免被发现，赶忙走开。",
			"HIW你一无所获，他也已经有了警惕，看来这次是失败了。",
		}
		
		-- 腰间成功文本
		local yaojianSuccessDesc =
		{
			"CYN你悄悄地跟上$N，在他身后不远处尾随着。",
			"HIY你脑子慢慢思索该如何得手，恰在这时，前方的$N似乎要在下一个路口转弯。",
			"HIG你当即意识到这时一个好机会，快步跟了上去。",
			"HIC恰到转角处时，你悄一伸手向$N腰间探去！",
			"HIW一个沉甸甸的物事入手，你立刻转身走开。",
			"HIW东西已经到手，快回去复命吧。",
		}
		
		-- 腰间失败文本
		local yaojianFailDesc =
		{
			"CYN你悄悄地跟上$N，在他身后不远处尾随着。",
			"HIY你脑子慢慢思索该如何得手，恰在这时，前方的$N似乎要在下一个路口转弯。",
			"HIG你当即意识到这时一个好机会，快步跟了上去。",
			"HIC恰到转角处时，你悄一伸手向$N腰间探去！",
			"HIW但却一无所获！你为免被发现，赶忙走开。",
			"HIW你一无所获，他也已经有了警惕，看来这次是失败了。",
		}
		
		
		local Anniversary = require("app.models.Anniversary.Anniversary")
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		dialog:show("你要偷他哪个位置?")
		dialog:setButton1("怀里", function()
			environment.currRole.caozuo1 = false
			if Anniversary:theft(1) == true then
				for i, v in ipairs(huailiSuccessDesc) do
					environment.mapLayer:delayFunc((i - 1) * 0.5, function()
						local str = string.gsub(v, "$N", environment.currRole.name)
						RichPrint("main", str)
					end)
				end
				Anniversary:finishTask("惊鸿燕任务")
			else
				for i, v in ipairs(huanliFailDesc) do
					environment.mapLayer:delayFunc((i - 1) * 0.5, function()
						local str = string.gsub(v, "$N", environment.currRole.name)
						RichPrint("main", str)
					end)
				end
				Anniversary:failTask("惊鸿燕任务")
			end
			dialog:hide()
		end)
		
		dialog:setButton2("袖囊", function()
			environment.currRole.caozuo1 = false
			if Anniversary:theft(2) == true then
				for i, v in ipairs(xiunangSuccessDesc) do
					environment.mapLayer:delayFunc((i - 1) * 0.5, function()
						local str = string.gsub(v, "$N", environment.currRole.name)
						RichPrint("main", str)
					end)
				end
				Anniversary:finishTask("惊鸿燕任务")
			else
				for i, v in ipairs(xiunangFailDesc) do
					environment.mapLayer:delayFunc((i - 1) * 0.5, function()
						local str = string.gsub(v, "$N", environment.currRole.name)
						RichPrint("main", str)
					end)
				end
				Anniversary:failTask("惊鸿燕任务")
			end
			dialog:hide()
		end)
		
		dialog:setButton3("腰间", function()
			environment.currRole.caozuo1 = false
			if Anniversary:theft(3) == true then
				for i, v in ipairs(yaojianSuccessDesc) do
					environment.mapLayer:delayFunc((i - 1) * 0.5, function()
						local str = string.gsub(v, "$N", environment.currRole.name)
						RichPrint("main", str)
					end)
				end
				Anniversary:finishTask("惊鸿燕任务")
			else
				for i, v in ipairs(yaojianFailDesc) do
					environment.mapLayer:delayFunc((i - 1) * 0.5, function()
						local str = string.gsub(v, "$N", environment.currRole.name)
						RichPrint("main", str)
					end)
				end
				Anniversary:failTask("惊鸿燕任务")
			end
			dialog:hide()
		end)
	end,
	
	["押鬼奖励"] = function(map, result, environment)
		local npcList = Helper:getDef(map:getFollowInfoByKey("npcList"), {})
		--[[			1个正常鬼20冥币,5个正常鬼100冥币,并额外奖励20冥币,最对120冥币
			混入一个恶鬼,扣10冥币,最多混入3个恶鬼,获得70冥币
			每日最多360冥币

			yasongrenwu1   普通鬼魂
			yasongrenwu2   被附体的鬼魂
		]]
		local puTong, eGui = 0, 0
		for i, v in ipairs(npcList) do
			if v == "yasongrenwu1" then
				puTong = puTong + 1
			elseif v == "yasongrenwu2" then
				eGui = eGui + 1
			else
				error("这里出错了,居然出现了不知道是什么鬼的鬼" .. tostring(v))
			end
		end
		local reward = 0
		if puTong == 5 then
			reward = 500
		else
			reward = puTong * 80 - eGui * 50
		end
		reward = math.min(reward, 500)
		reward = math.max(reward, 0)
		print("押鬼奖励：普通鬼：", puTong, "恶鬼:", eGui)
		--玩法数据统计
		HttpManagerEx:countSingleRecordWithType("YeGuiRenWu", function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					HttpManagerEx:updateCurrencyByType("add", "mingbi", reward,nil, function(status, errcode, errmsg, data)
						if status == 200 then
							if errcode == 0 then
								PopText("冥币 + " .. tostring(reward) .. "亿")
								map:doNoRoleResults(result.arg2, environment)
							else
								PopText(errmsg)
							end
						else
							PopText(errmsg)
						end
					end)
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end)
	end,
	
	["蒿里行奖励发放"] = function(map, result, environment)
		local player = User:getRole()
		local item = Helper:getDef(player:getItem("item201_20"), {})
		local clCount = Helper:getDef(item.clCount, 0)
		local mbCount = 50
		local reward = {}
		if clCount == 0 then
			mbCount = 50
		elseif clCount >= 1 and clCount <= 30 then
			mbCount = 100
		elseif clCount >= 31 and clCount <= 50 then
			mbCount = 125
		elseif clCount >= 51 and clCount <= 60 then
			mbCount = 150
		elseif clCount >= 61 and clCount <= 70 then
			mbCount = 200
		elseif clCount >= 71 and clCount <= 80 then
			mbCount = 240
		elseif clCount >= 81 and clCount <= 90 then
			mbCount = 300
		elseif clCount >= 91 and clCount <= 98 then
			mbCount = 330
			reward = {
				[1] = {
					id = "pot",
					count = 500,
					type = "attr"
				}
			}
		elseif clCount == 99 then
			mbCount = 390
			reward = {
				[1] = {
					id = "pot",
					count = 1000,
					type = "attr"
				},
				[2] = {
					id = "yueli",
					count = 10,
					type = "attr"
				},
			}
			local weight = {[1] = 55, [2] = 15, [3] = 15, [4] = 15}
			local random = Helper:RandomByWeight(weight)
			local tab
			if random == 1 then
				local list = {
					[1] = "lingxiaoxinfa2",
					[2] = "lingxiaoxinfa3",
					[3] = "lingxiaoxinfa4",
					[4] = "lingxiaoxinfa5",
				}
				tab = {
					id = list[math.random(1, #list)],
					count = 1,
					type = "item"
				}
			elseif random == 2 then
				tab = {
					id = "qingmingzhuangbei17",
					count = 1,
					type = "item"
				}
			elseif random == 3 then
				tab = {
					id = "qingmingzhuangbei18",
					count = 1,
					type = "item"
				}
			elseif random == 4 then
				tab = {
					id = "qingmingzhuangbei19",
					count = 1,
					type = "item"
				}
			else
				assert("蒿里行奖励阴气为99时获取随机奖励出错")
			end
			table.insert(reward, tab)
		else
			assert("蒿里行奖励出错")
		end
		local ckReward = {}
		for k, v in pairs(reward) do
			if v.type == "item" then
				ckReward[v.id] = v.count
			end
		end
		HttpManagerEx:countSingleRecordWithType("HaoLiXing", function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if player:checkCanBuyTwoOrMoreThings(ckReward) == true then
						HttpManagerEx:updateCurrencyByType("add", "mingbi", mbCount,nil, function(status, errcode, errmsg, data)
							if status == 200 then
								if errcode == 0 then
									PopText("冥币 + " .. tostring(mbCount) .. "亿")
									for k, v in pairs(reward) do
										if v.type == "item" then
											local reward_item = Item:getOneItemByKey(v.id)
											if reward_item then
												PopText("获得物品" .. reward_item.name .. "X" .. tostring(Helper:getDef(v.count, 1)))
												player:addItemCount(v.id, v.count)
											end
										elseif v.type == "attr" then
											local attr_name = player:getCHAttrName(v.id)
											if attr_name ~= "" then
												player:addAttr(v.id, v.count)
												PopText(attr_name .. "+" .. tostring(v.count))
											else
												if DEBUG_MODE == 1 then
													assert("测试才能看见，奖励的属性名称在getCHAttrName方法中没有设置")
												end
											end
										else
											
										end
									end
									player:addItemCount("item201_20", - 1)
									player:addItemCount("item201_21", - 1)
									player:addItemCount("item201_19", - 1)
									map:doNoRoleResults(result.arg2, environment)
								else
									PopText(errmsg)
								end
							else
								PopText(errmsg)
							end
						end)
					else
						PopText("背包空间不足")
					end
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end)
	end,
	
	["押鬼文本输出"] = function(map, result, environment)
		local npcList = map:getFollowInfoByKey("npcList")
		local str = result.arg2
		if MapIsEmpty(npcList) == true then
			str = string.gsub(str, "#YGZS#", "零")
			str = string.gsub(str, "#YGSL#", "零")
		else
			str = string.gsub(str, "#YGZS#", Helper:numberCast(#npcList))
			local text = ""
			for i, v in ipairs(npcList) do
				if i == #npcList then
					text = text .. Helper:numberCast(i)
				else
					text = text .. Helper:numberCast(i) .. "、"	
				end
			end
			str = string.gsub(str, "#YGSL#", text)
		end
		RichPrint("main", str)
	end,
	
	["冥币扣除"] = function(map, result, environment)
		local count = Helper:getDef(result.arg2, 0)
		if count <= 0 then
		else
			HttpManagerEx:updateCurrencyByType("remove", "mingbi", count,nil, function(status, errcode, errmsg, data)
				if status == 200 then
					if errcode == 0 then
						PopText("冥币 - " .. tostring(count) .. "亿")
						map:doNoRoleResults(result.arg3, environment)
					elseif errcode == - 1 then
						PopText("冥币数量不足")
					else
						PopText(errmsg)
					end
				else
					PopText(errmsg)
				end
			end)
		end
	end,
	
	["阴气变化"] = function(map, result, environment)
		local player = User:getRole()
		player:addCollectItemCount("item201_20", Helper:getDef(result.arg2, 0))
		local random = Helper:getDef(result.arg2, 0)
		local item = player:getItem("item201_20")
		-- add by XiaoZhiWei 2017/08/31 20:33:22 如果物品不存在或者收集数量小于0 则直接退出副本
		if item == nil or(item ~= nil and item.clCount <= 0) then
			player:addItemCount("item201_21", 1)
			player:addItemCount("item201_20", - 1)
			PopText("阴气" .. tostring(random))
			RichPrint("main", "一股股阴气不断从双鱼玉佩中渗出，只听得一声轻响，玉佩竟碎裂开来。")
			map:doNoRoleResults(result.arg3, environment)
			map.__MapLayer.TotalMapBtn_IsInit = false
			map.__MapLayer:quit()
		else
			if random >= 0 then
				PopText("阴气+" .. tostring(random))
				RichPrint("main", "一团白雾慢慢渗入双鱼玉佩中，玉佩由清转白，又由白转清。")
				map:doNoRoleResults(result.arg3, environment)
			else
				PopText("阴气" .. tostring(random))
				RichPrint("main", "一股股阴气不断从双鱼玉佩中渗出。")
				map:doNoRoleResults(result.arg3, environment)
			end
		end
	end,
	
	["阴气随机变化"] = function(map, result, environment)
		local player = User:getRole()
		local min, max = Helper:getDef(tonumber(result.arg2), 0), Helper:getDef(tonumber(result.arg3), 0)
		print("****************************", min, result.arg2, type(result.arg2), "**************************", max, result.arg3, type(result.arg3))
		local random = math.random(min, max)
		player:addCollectItemCount("item201_20", random)
		local item = player:getItem("item201_20")
		-- add by XiaoZhiWei 2017/08/31 20:33:22 如果物品不存在或者收集数量小于0 则直接退出副本
		local popText = ""
		if item == nil or(item ~= nil and item.clCount <= 0) then
			player:addItemCount("item201_21", 1)
			player:addItemCount("item201_20", - 1)
			PopText("阴气" .. tostring(random))
			RichPrint("main", "一股股阴气不断从双鱼玉佩中渗出，只听得一声轻响，玉佩竟碎裂开来。")
			map.__MapLayer.TotalMapBtn_IsInit = false
			map.__MapLayer:quit()
		else
			if random >= 0 then
				PopText("阴气+" .. tostring(random))
				RichPrint("main", "一团白雾慢慢渗入双鱼玉佩中，玉佩由清转白，又由白转清。")
			else
				PopText("阴气" .. tostring(random))
				RichPrint("main", "一股股阴气不断从双鱼玉佩中渗出。")
			end
		end
	end,
	
	["鬼差任务"] = function(map, result, environment)
		local function getBaZiTime()
			local tiangan_tb = {"甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"}
			local dizhi_tb = {"子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"}
			
			local des_time = {
				t_year = tiangan_tb[math.random(1, 10)],
				d_year = dizhi_tb[math.random(1, 12)],
				t_month = tiangan_tb[math.random(1, 10)],
				d_month = dizhi_tb[math.random(1, 12)],
				t_day = tiangan_tb[math.random(1, 10)],
				d_day = dizhi_tb[math.random(1, 12)],
				d_time = dizhi_tb[math.random(1, 12)],
			}
			return des_time
		end
		
		local function setGhostDsc(npcRole, time)
			local str = "$N的衣服背面写着一样小字：“"
			.. time.t_year .. time.d_year .. "年"
			.. time.t_month .. time.d_month .. "月"
			.. time.t_day .. time.d_day .. "日"
			.. time.d_time .. "时”，这似乎是$N的生辰八字。"
			
			local npc_sex = npcRole:getAttr("sex")
			if npc_sex == "男" then
				npcRole:setAttr("name", "男鬼")
				str = string.gsub(str, "$N", "他")
			elseif npc_sex == "女" then
				npcRole:setAttr("name", "女鬼")
				str = string.gsub(str, "$N", "她")
			end
			return str
		end
		
		local function initGhostNpcAttr(map, npcRoleId, time, name, sex)
			local npcRole = map:getRole(npcRoleId)
			--随机生成性别
			local sex_index = math.random(1, 2)
			local npc_sex
			if sex == nil then
				npc_sex = "男"
				if sex_index == 1 then
					npc_sex = "男"
				elseif sex_index == 2 then
					npc_sex = "女"
				end
			else
				npc_sex = sex
			end
			npcRole:setAttr("sex", npc_sex)
			
			local des_name
			if name == nil then
				des_name = Helper:getRandomName(npcRole:getAttr("sex"))
			else
				des_name = name
			end
			npcRole:setAttr("des_name", des_name)
			local str = setGhostDsc(npcRole, time)
			npcRole:setAttr("dsc", str)
			return npcRole
		end
		
		
		local function setGuiChaiTask(map)
			local role = User:getRole()
			local ghostInfo = {}
			
			--检查背包是否可以领取
			local bagIsMax = role:checkCanBuyTwoOrMoreThings({item201_17new21 = 1})
			
			if not bagIsMax then
				return false
			end

			local timeFlag = role:getTimeLimitFlag("酆都每日鬼差次数")
			if timeFlag == 0 and role._timeLimitFlags["酆都每日鬼差次数"].startTime == 0 then
				local timelimit
				local Hour = os.date("%H",GetTime())
				local Minute = os.date("%M",GetTime())
				local Second = os.date("%S",GetTime())
				if os.date("%w",GetTime()) == "0" then			
					timelimit=(23-Hour)*3600+(59-Minute)*60+(60-Second)
				else
					timelimit=(7-os.date("%w",GetTime()))*86400+(23-Hour)*3600+(59-Minute)*60+(60-Second)
				end
				role:setTimeLimitFlag("酆都每日鬼差次数",0,timelimit)
			end

			
			local mapList = {"fb201_70", "fb201_71", "fb201_73", "fb201_74", "fb201_75", "fb201_76", "fb201_77", "fb201_78", "fb201_79", "fb201_81", "fb201_82", "fb201_83", "fb201_84", "fb201_85", "fb201_87", "fb201_88", "fb201_89", "fb201_90", "fb201_91", "fb201_92", "fb201_93", "fb201_94", "fb201_95", "fb201_96", "fb201_97", "fb201_98", "fb201_99", "fb201_100", "fb201_101", "fb201_102"}
			
			local mark = role:getFlag("酆都任务进度")
			
			--已接取任务，任务正在进行中
			if tonumber(mark) == 1 then
				local info = Helper:getDef(role:getAttr("ghostInfo"), {})
				if not MapIsEmpty(info) then
					local str = info.str
					local str1 = string.gsub(str, "#@n#", "\n")
					RichPrint("main", str1)
				end
				return true
			end
			
			--接取任务
			if tonumber(mark) == 0 and tonumber(role:getDayFlag("酆都每日鬼差次数")) == 0 then
				--服务器发送活动参与次数
				HttpManagerEx:joinGhostTimes(function(status, errcode, errmsg, data)
					if status == 200 and errcode == 0 then
						if DEBUG_MODE == 1 then
							print("参与次数加 1")
						end
					end
				end)
			end
			
			local des_time = getBaZiTime()
			
			--随机生成房间，根据baseRoomId获取周边房间列表，在周边房间生成NPC
			local roomBaseId = mapList[math.random(1, #mapList)]
			local roomList = map:getNearRoomsExceptSelf(roomBaseId, 1)
			local roomId = roomList[math.random(1, #roomList)]
			print("Room ID :" .. roomId)
			
			
			--随机生成类型
			local odds = math.random(1, 100)
			-- local odds = 31
			local npcRole
			local npcId
			if odds <= 50 then
				print("普通型")
				local npcList = {"zyputong1", "zyputong2", "zyputong3", "zyputong4", "zyputong5", "zyputong6", "zyputong7", "zyputong8", "zyputong9", "zyputong10", "zyputong11", "zyputong12", "zyputong13", "zyputong14", "zyputong15", "zyputong16", "zyputong17", "zyputong18", "zyputong19", "zyputong20"}
				npcId = npcList[math.random(1, #npcList)]
				npcRole = initGhostNpcAttr(map, npcId, des_time)
				map:addRoomRole(roomId, npcRole.id)
			elseif odds > 50 and odds <= 60 then
				print("受虐型")
				npcId = "zyshounue1"
				npcRole = initGhostNpcAttr(map, npcId, des_time)
				local npcRole_a = initGhostNpcAttr(map, "zyshounue1a", des_time, npcRole:getAttr("des_name"), npcRole:getAttr("sex"))
				map:addRoomRole(roomId, npcRole.id)
				
				--伴生型
				local npcRole_1 = map:getRole("zybansheng1")
				local b_Time1 = getBaZiTime()
				local str1 = setGhostDsc(npcRole_1, b_Time1)
				npcRole_1:setAttr("dsc", str1)
				npcRole_1:setAttr("name", "男鬼")
				map:addRoomRole(roomId, npcRole_1.id)
				ghostInfo.bStr1 = str1
				
				local npcRole_2 = map:getRole("zybansheng2")
				npcRole_2:setAttr("sex", "女")
				local b_Time2 = getBaZiTime()
				local str2 = setGhostDsc(npcRole_2, b_Time2)
				npcRole_2:setAttr("dsc", str2)
				npcRole_2:setAttr("name", "女鬼")
				map:addRoomRole(roomId, npcRole_2.id)
				ghostInfo.bStr2 = str2
				
			elseif odds > 60 and odds <= 90 then
				print("切磋型")
				npcId = "zyqiecuo1"
				npcRole = initGhostNpcAttr(map, npcId, des_time)
				local npcRole_a = initGhostNpcAttr(map, "zyqiecuo1a", des_time, npcRole:getAttr("des_name"), npcRole:getAttr("sex"))
				map:addRoomRole(roomId, npcRole.id)
			elseif odds > 90 then
				print("赌博型")
				npcId = "zydubo1"
				npcRole = initGhostNpcAttr(map, npcId, des_time)
				local npcRole_a = initGhostNpcAttr(map, "zydubo1a", des_time, npcRole:getAttr("des_name"), npcRole:getAttr("sex"))
				map:addRoomRole(roomId, npcRole.id)
			end
			
			if DEBUG_MODE == 1 then
				print("NPC 生成的房间是 ：" .. roomId)
				print("NPC 的名字是 ：" .. npcRole.des_name)
			end
			
			local room = map:getRoomById(roomBaseId)
			local item = Item:getOneItemByKey("item201_17new21")
			local item_des = "这是一份祭品，里面是一些阴间所用之物，收件人名为：" .. npcRole:getAttr("des_name") .. ",上面还写着$N的生辰八字："
			.. des_time.t_year .. des_time.d_year .. "年"
			.. des_time.t_month .. des_time.d_month .. "月"
			.. des_time.t_day .. des_time.d_day .. "日"
			.. des_time.d_time .. "时。"
			if npcRole:getAttr("sex") == "男" then
				item_des = string.gsub(item_des, "$N", "他")
			elseif npcRole:getAttr("sex") == "女" then
				item_des = string.gsub(item_des, "$N", "她")
			end
			
			local str = "YEL阎历行：初秋夜露香篆冷，月上黄昏。#@n#鸣钟三更，未闻哭啼两三声。#@n#" .. room.name .. "附近有阴魂，祭物当心恶鬼掠。#@n#阴魂名为" .. npcRole:getAttr("des_name") .. "，生辰八字物上寻。"
			local str1 = string.gsub(str, "#@n#", "\n")
			RichPrint("main", str1)
			role:addItemCount("item201_17new21", 1)
			PopText("你获得了 " .. item.name)
			
			ghostInfo.npcId = npcId								--随机的类型
			ghostInfo.npcName = npcRole:getAttr("name")			--副本上显示的名字：男鬼 | 女鬼
			ghostInfo.npcDesName = npcRole:getAttr("des_name")	--npc名字
			ghostInfo.npcSex = npcRole:getAttr("sex")			--npc性别
			ghostInfo.npcDsc = npcRole:getAttr("dsc")			--npc描述
			ghostInfo.itemDes = item_des						--祭品的描述
			ghostInfo.roomId = roomId							--生成的房间
			ghostInfo.str = str
			
			role:setAttr("ghostInfo", ghostInfo)
			return true
		end
		local canGet = setGuiChaiTask(map)
		if canGet then
			local list = result.arg2
			map:doNoRoleResults(list, environment)
		end
	end,
	
	["鬼差任务奖励"] = function(map, result, environment)
		-- role:setFlag("幽冥鬼差",0)
		local role = User:getRole()
		local dayFlag = role:getDayFlag("酆都每日鬼差次数")
		if dayFlag < 3 then
			--抓鬼的时候判断是否带面具
			local mianju = role:getPortraitId()
			local effectData = 1
			if mianju == "mianju1069" or mianju == "mianju1070" or mianju == "mianju1151" then
				effectData = 1.25
			end
			if  GetTime() > Helper:getTimeStampWithStringDate("20210820", 0)  and GetTime() < Helper:getTimeStampWithStringDate("20210903", 0) then 
				effectData=effectData+0.25
			end
			local point = 600 *effectData
			local net_rewards = {}
	        net_rewards["mingbi"] = point
	        local CN = {
	        	["mingbi"] = "亿冥币"
	   		 }
			HttpManagerEx:addCurrencyNumber(
	            net_rewards,
	            "DailyTies",
	            "guijiebao",
	            function(status, errcode, errmsg, data)
	                if status == 200 and errcode == 0 then
	                    if MapIsEmpty(data.currency) == false then
	                        role:setAttr("ghostInfo", {})
	                        for currency,valueData in pairs(data.currency) do
	                            if valueData.value > 0 then 
                                    PopText("获得"..tostring(valueData.value)..CN[currency])
                                end
	                        end
							map:doNoRoleResults(result.arg2, environment)						
							--奖励领取完成后通知服务器
							HttpManagerEx:finishGhostTimes(function(status, errcode, errmsg, data)
								if status == 200 and errcode == 0 then
									if DEBUG_MODE == 1 then
										PopText("任务完成上传")
									end
								else
									if DEBUG_MODE == 1 then
										PopText(errmsg)
									end
								end
							end)	 
						else
							PopText("领取失败，请重新领取。")                     	                      
	                    end
	                else
	                    PopText("领取失败，请重新领取。")
	                end
	            end,
	            IS_SHOW_WAITING
	        )
		else
			PopText("今日任务已完成，请明日再来")
		end
	end,
	

}





return TaskModule000000