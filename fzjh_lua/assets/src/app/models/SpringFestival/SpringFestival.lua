local User = require("app.models.user.User")
local Item = require("app.models.item.Item")
local Role = require("app.models.role.Role")

local SpringFestival = {}

local ChineseNewYear = assert(require("script.others.ChineseNewYear"))
local BaiNianActivity = ChineseNewYear["bainian"]
local BaiNianText = ChineseNewYear["text"]
local BaiNianNpc = ChineseNewYear["npc"]

-- 获取春节收益加成活动状态 每5分钟更新一次
function SpringFestival:getProfitActivityState()
	local startTime = os.time({year = 2018,month = 2, day = 7, hour = 0})	-- 起始时间 测试时间，正式提交需要改
	local overTime = os.time({year = 2018,month = 3, day = 3, hour = 0})	-- 结束时间
	local currTime = GetTime()
	
	local role = User:getRole()

	-- -- 未到时间不请求服务器获取状态
	-- if currTime < startTime then
	-- 	return 0
	-- end

	-- 超过时间关闭
	if currTime > overTime then
		role:getFlag("春节收益活动状态", 0)
		return 0
	end

	local lastTime = role:getFlag("春节收益活动检测时间")

	if currTime - lastTime > 300 then
		print("更新春节收益活动状态")
		-- 5分钟请求更新一次状态
		role:setFlag("春节收益活动检测时间", GetTime())
		HttpManagerEx:getNewYearFestivalState(4, function(status, errcode, errmsg, data)
		    if status == 200 then
		        if errcode == 0 then
		        	if data.is_open == 1 and data.status == 1 then
		        		role:setFlag("春节收益活动状态", 1)
		        	else
		        		role:setFlag("春节收益活动状态", 0)
		        	end
		        else
		        	role:setFlag("春节收益活动状态", 0)
		            --PopText(errmsg)
		        end
		    else
		    	role:setFlag("春节收益活动状态", 0)
			end
		end, IS_SHOW_WAITING)
	end

	return role:getFlag("春节收益活动状态")
end

-- 获取拜年活动状态
function SpringFestival:getBaiNianActivityState()
	local startTime = os.time({year = 2017,month = 1, day = 28, hour = 0})	-- 起始时间 测试时间，正式提交需要改
	local overTime = os.time({year = 2017,month = 2, day = 12, hour = 0})	-- 结束时间
	local currTime = GetTime()

	local role = User:getRole()

	-- -- 未到时间不请求服务器获取状态
	-- if currTime < startTime then
	-- 	return 0
	-- end

	-- 超过时间关闭
	if currTime > overTime then
		role:getFlag("春节拜年活动状态", 0)
		return 0
	end

	local lastTime = role:getFlag("春节拜年活动检测时间")

	if currTime - lastTime > 300 then
		print("更新春节拜年活动状态")
		-- 5分钟请求更新一次状态
		role:setFlag("春节拜年活动检测时间", GetTime())
		HttpManagerEx:getNewYearFestivalState(6, function(status, errcode, errmsg, data)
		    if status == 200 then
		        if errcode == 0 then
		        	if data.is_open == 1 and data.status == 1 then
		        		role:setFlag("春节拜年活动状态", 1)
		        	else
		        		role:setFlag("春节拜年活动状态", 0)
		        	end
		        else
		        	role:setFlag("春节拜年活动状态", 0)
		            --PopText(errmsg)
		        end
		    else
		    	role:setFlag("春节拜年活动状态", 0)
			end
		end, IS_SHOW_WAITING)
	end

	return role:getFlag("春节拜年活动状态")
end

-- 检测是否角色是否可拜年
function SpringFestival:checkCanBaiNian(npc)
	for k,v in pairs(BaiNianNpc) do
		if npc.baseId == v.id or npc.id == v.id then
			local role = User:getRole()
			if role:getDayFlag("自由拜年" .. v.id) == 0 then
				return true
			end
		end
	end
	return false
end

-- 获取师父拜年奖励
function SpringFestival:getBaiNianReward(npc)
	local role = User:getRole()

	local weight = role:getAttr("weight")
	local items = role:getAttr("items")

	if weight - #items < 11 then
		PopText("背包剩余空间不足")
		return
	end

	role:addItemCount("chunjiedahongbao1", 1)
	role:addItemCount("guoniansongli1", 1)
	role:addItemCount("guoniansongli2", 1)
	role:addItemCount("guoniansongli3", 1)
	role:addItemCount("guoniansongli4", 1)
	role:addItemCount("guoniansongli5", 1)
	role:addItemCount("guoniansongli6", 1)
	role:addItemCount("guoniansongli7", 1)
	role:addItemCount("guoniansongli8", 1)
	role:addItemCount("guoniansongli9", 1)
	role:addItemCount("guoniansongli10", 1)

	PopText("获得 大红包 X1")
	PopText("获得 字画 X1")
	PopText("获得 锦缎 X1")
	PopText("获得 龙井茶 X1")
	PopText("获得 宝剑 X1")
	PopText("获得 宝刀 X1")
	PopText("获得 画扇 X1")
	PopText("获得 夜明珠 X1")
	PopText("获得 盆景 X1")
	PopText("获得 女儿红 X1")
	PopText("获得 瓷器 X1")
	role:setFlag("春节师门拜年", 1)

	RichPrint("main", "你对" .. npc.name .. "拱手作揖道：师傅在上，徒儿给您拜年了！")
	RichPrint("main", "YEL" .. npc.name .. ":徒儿有这份孝心，为师甚是欣慰，来来来，拿上红包，讨个好彩头。这里还有一些礼品你且收好，为师还有些差事要交给你去办。")
end

-- 拜年委托任务
function  SpringFestival:getBaiNianTask(teacher)
	local role = User:getRole()
	local count = role:getDayFlag("今日师门委托拜年次数")

	print("今日师门委托拜年次数 = " .. count)
	if count >= 10 then
		PopText("今日拜年次数已达上限，还请明日再来吧。")
		return
	end

	-- 已经接受了委托，直接显示文本
	if role:getDayFlag("师门委托拜年") == 1 then
		local day = role:getDayFlag("师门委托拜年天数")
		if day > 15 or day < 1 then
			return
		end

		local baiNianTask = BaiNianActivity[tostring(day)]
		local task = baiNianTask["event" .. count + 1]
		if task ~= nil then
			print("接受师门委托拜年任务 " .. " 第 " .. day .. " 天")
			print(task)
			local strMap = string.split(task, ";")
			local map = role:getMapById(strMap[1])

			-- 输出文本
			local text = BaiNianText[strMap[4]].text
			local npc
			local item = Item:getOneItemByKey(strMap[3])
			local roleLis = map:getRoles()
			for k,v in pairs(roleLis) do
				if v.baseId == strMap[2] then
					npc = v
				end
			end

			text = string.gsub(text, "$M", "HIW" .. map.name .. "YEL")
			text = string.gsub(text, "$R", "GRN" .. map:getRoomMap()[strMap[5]].name .. "YEL")
			text = string.gsub(text, "$I", "HIR" .. item.name .. "YEL")
			text = string.gsub(text, "$N", "CYN" .. npc.name .. "YEL")

			RichPrint("main", "YEL" .. teacher.name .. ":" .. text)
		end
		return
	end

	HttpManagerEx:getNewYearFestivalState(6, function(status, errcode, errmsg, data)
		    if status == 200 then
		        if errcode == 0 then
		        	if data.is_open == 1 and data.status == 1 then
		        		local startTime = data.start
		        		local currTime = GetTime()

		        		print(" 拜年活动开启时间 " .. os.date("%x", startTime))
		        		print(" 当前时间 " .. os.date("%x", currTime))

		        		-- 活动第几天
		        		local day = math.abs(Helper:diffWithDate(currTime, startTime)) + 1
		        		print("接受师门委托拜年任务 " .. " 第 " .. day .. " 天")
		        		if day > 15 or day < 1 then
		        			return
		        		end

		        		local baiNianTask = BaiNianActivity[tostring(day)]
		        		local task = baiNianTask["event" .. count + 1]
		        		if task ~= nil then
		        			role:setDayFlag("师门委托拜年天数", day)
		        			role:setDayFlag("师门委托拜年", 1)
		        			print(task)

		        			local strMap = string.split(task, ";")
		        			local map = role:getMapById(strMap[1])

		        			-- 输出文本
		        			local text = BaiNianText[strMap[4]].text
							local npc
							local item = Item:getOneItemByKey(strMap[3])
							local roleLis = map:getRoles()
							for k,v in pairs(roleLis) do
								if v.baseId == strMap[2] then
									npc = v
								end
							end

							text = string.gsub(text, "$M", "HIW" .. map.name .. "YEL")
							text = string.gsub(text, "$R", "GRN" .. map:getRoomMap()[strMap[5]].name .. "YEL")
							text = string.gsub(text, "$I", "HIR" .. item.name .. "YEL")
							text = string.gsub(text, "$N", "CYN" .. npc.name .. "YEL")

							RichPrint("main", "YEL" .. teacher.name .. ":" .. text)
		        		end
		        	end
		        else
		            --PopText(errmsg)
		        end
			end
		end, IS_SHOW_WAITING)
end

-- 拜年委托副本NPC添加拜年按钮
function SpringFestival:setBaiNianNpc(map)
	local role = User:getRole()
	if self:getBaiNianActivityState() == 1 then

		-- 自由拜年
		local rolesList = map:getRoles()
		for k,v in pairs(rolesList) do
			if self:checkCanBaiNian(v) then
				print("NPC " .. v.name .. " 添加自由拜年操作")
				v.caozuo4 = true
				v.caozuoName4 = "拜年"
				table.insert(v.conditionAndResults,
				{
					conditionRelation = "and",
					conditions =
					{
						{
							type = "玩家操作",
							arg1 = "玩家操作",
							arg2 = "操作4",
						}
					},
					results =
					{
						{
							type = "拜年",
							arg1 = "拜年",
						},
					},
				})
			end
		end

		-- 委托拜年
		if role:getDayFlag("师门委托拜年") == 1 then
			local day = role:getDayFlag("师门委托拜年天数")
			if day > 15 or day < 1 then
				return
			end

			local count = role:getDayFlag("今日师门委托拜年次数")
			local baiNianTask = BaiNianActivity[tostring(day)]
			local task = baiNianTask["event" .. count + 1]
			if task ~= nil then
				local strMap = string.split(task, ";")
				if map.id ~= strMap[1] then
					return
				end

				for k,v in pairs(rolesList) do
					if v.baseId == strMap[2] then
						print("NPC " .. v.name .. " 添加拜年委托操作")
						v.caozuo4 = true
						v.caozuoName4 = "拜年"
						table.insert(v.conditionAndResults,
						{
							conditionRelation = "and",
							conditions =
							{
								{
									type = "玩家操作",
									arg1 = "玩家操作",
									arg2 = "操作4",
								}
							},
							results =
							{
								{
									type = "拜年委托",
									arg1 = "拜年委托",
								},
							},
						})
					end
				end
			end
		end
	end
end

-- 拜年委托
function SpringFestival:doBaiNian(npc, mapId, map)
	local role = User:getRole()

	local day = role:getDayFlag("师门委托拜年天数")
	if day > 15 or day < 1 then
		return
	end

	local weight = role:getAttr("weight")
	local items = role:getAttr("items")

	if weight - #items < 1 then
		PopText("背包剩余空间不足")
		return
	end

	local count = role:getDayFlag("今日师门委托拜年次数")
	local baiNianTask = BaiNianActivity[tostring(day)]
	local task = baiNianTask["event" .. count + 1]
	if task ~= nil then
		local strMap = string.split(task, ";")
		if mapId == strMap[1] and npc.baseId == strMap[2] and role:getDayFlag("师门委托拜年") == 1 then
			if role:getItemCount(strMap[3]) < 1 then
				PopText("如此恐有失礼数，还是先去准备好师傅交代的礼物吧")
			else
				role:addItemCount(strMap[3], -1)
				role:setDayFlag("今日师门委托拜年次数", role:getDayFlag("今日师门委托拜年次数") + 1)
				role:setDayFlag("师门委托拜年", 0)

				-- 给奖励
				role:addItemCount("chunjiexiaohongbao1", 1)
				local item = Item:getOneItemByKey("chunjiexiaohongbao1")
				PopText("获得 " .. item.name .. " X 1")

				-- 不显示拜年按钮 可能有多个角色
				local rolesList = map:getRoles()
				for k,v in pairs(rolesList) do
					if v.baseId == npc.baseId then
						v.caozuo4 = false
					end
				end

				-- 显示文本
				local teacherName = role:getAttr("teacherName")
				local num = math.random(1,3)
				if num == 1 then
					RichPrint("main", "你对" .. npc.name .. "拱手作揖道：奉家师" .. teacherName .. "之命特来给您拜年，祝您新春愉快合家欢！")
					RichPrint("main", "YEL" .. npc.name .. ":你师傅真是太客气了，我也没有别的好礼回赠，这个红包算是我的一点小小心意，还望你不要嫌弃啊!")
				elseif num == 2 then
					RichPrint("main", "你对" .. npc.name .. "拱手作揖道：奉家师" .. teacherName .. "之命特来给您拜年，这是贺礼，还请笑纳。")
					RichPrint("main", "YEL" .. npc.name .. ":您能来已经是我等的荣幸了，还带这么贵重的礼物，真是折煞我了。大过年的，这红包只能聊表寸心，还请少侠收下！")
				elseif num == 3 then
					RichPrint("main", "你对" .. npc.name .. "拱手作揖道：奉家师" .. teacherName .. "之命特来给您拜年，祝您家和万事兴！")
					RichPrint("main", "YEL" .. npc.name .. ":好好好！令师真是有心了！这红包是我的一点心意，请少侠回去后替我向你师傅问声好啊！")
				end

				print("完成拜访委托")
				print("今日师门委托拜年次数 = " .. role:getDayFlag("今日师门委托拜年次数"))
			end
		end
	end
end

-- 自由拜年
function SpringFestival:doFreeBaiNian(itemId, npc, map)
	local role = User:getRole()

	-- 每日上限10次
	local count = role:getDayFlag("每天自由拜年次数")

	if count >= 10 then
		PopText("今天已经获得了10份奖励，明天再来吧。")
		return
	end

	-- 检测是否拥有道具
	if role:getItem(itemId) == nil then
		PopText("没有该物品")
		return
	end

	role:addItemCount(itemId, -1)

	--	根据道具获得奖励
	for k,v in pairs(BaiNianNpc) do
		if v.id == npc.id or v.id == npc.baseId then

			-- 同一个NPC一天只能拜年一次
			role:setDayFlag("自由拜年" .. v.id, 1)

			-- 不显示拜年按钮 可能有多个角色
			if map ~= nil then
				local rolesList = map:getRoles()
				for k,v in pairs(rolesList) do
					if v.baseId == npc.baseId then
						v.caozuo4 = false
					end
				end
			end

			-- 大红包奖励
			local strMap = string.split(v.reward1, ";")
			for i,str in ipairs(strMap) do
				if str == itemId and role:getDayFlag("每天自由拜年次数") < 10 then
					role:addItemCount("chunjiedahongbao1", 1)
					local item = Item:getOneItemByKey("chunjiedahongbao1")
					PopText("获得 " .. item.name .. " X 1")
					RichPrint("main", "你给" .. npc.name .. "拜年，并送上新年贺礼一份。")
					RichPrint("main", "YEL" .. npc.name .. ":少侠所赠深得我心，我这里也有份薄礼，请少侠务必收下。")
					role:setDayFlag("每天自由拜年次数", count + 1)
					return
				end
			end

			-- 小红包奖励
			strMap = string.split(v.reward2, ";")
			for i,str in ipairs(strMap) do
				if str == itemId and role:getDayFlag("每天自由拜年次数") < 10 then
					role:addItemCount("chunjiexiaohongbao1", 1)
					local item = Item:getOneItemByKey("chunjiexiaohongbao1")
					PopText("获得 " .. item.name .. " X 1")
					RichPrint("main", "你给" .. npc.name .. "拜年，并送上新年贺礼一份。")
					RichPrint("main", "YEL" .. npc.name .. ":多谢少侠赠礼，我也有一份小小心意，请少侠收下。")
					role:setDayFlag("每天自由拜年次数", count + 1)
					return
				end
			end

			-- 显示无奖励文本
			local num = math.random(1,3)
			if num == 1 then
				RichPrint("main", "你给" .. npc.name .. "拜年，并送上新年贺礼一份。")
				RichPrint("main", "YEL" .. npc.name .. ":既然少侠有这份心，那我便恭谨不如从命了。")
			elseif num == 2 then
				RichPrint("main", "你给" .. npc.name .. "拜年，并送上新年贺礼一份。")
				RichPrint("main", "YEL" .. npc.name .. ":同喜同喜。")
			elseif num == 3 then
				RichPrint("main", "你给" .. npc.name .. "拜年，并送上新年贺礼一份。")
				RichPrint("main", "YEL" .. npc.name .. ":如此便多谢少侠了。")
			end


			print("没有获得红包")
		end
	end
end

-- 检测是否有加成的策略
function SpringFestival:checkIsAdditionSchemeId(schemeId)
	-- 只有以下策略才有加成
	local additionSchemeIdArray =
	{
		"tiaozhancelue200",
		"tiaozhancelue250",
		"tiaozhancelue300",
		"tiaozhancelue350",
		"tiaozhancelue400",
		"tiaozhancelue450",
		"tiaozhancelue500",
		"tiaozhancelue550",
		"tiaozhancelue600",
		"tiaozhancelue650",
		"tiaozhancelue700",
		"tiaozhancelue750",
		"tiaozhancelue800",
		"tiaozhancelue850",
		"tiaozhancelue900",
		"tiaozhancelue950",
		"tiaozhancelue1000",
		"newfubenxiangzi",
	}

	for k,v in pairs(additionSchemeIdArray) do
		if schemeId == v then
			return true
		end
	end

	return false
end

local getRedPacketText={
	[1]="满脸笑意的将已经备好的新年红包交到你手中，祝愿你岁祥安乐，万事如意。",

}
local afterGetRedPacketText={
	[1]="年初一至初七每日可于我这里领取一份红包，既可沾沾一年的新喜气，亦祝你今年万事如意。",
}

-- 讨红包  roleType 2 平安小镇  1 门派  
function SpringFestival:getRedPacket(roleType,roleName,func)
	if not roleType then 
		print("SpringFestival:getRedPacket roleType：参数有误")
		return 
	end

	local callBack = func
	if not callBack then
		callBack=function ()
		end
	end
	local packetReward={
		[1] = {
			localAttrs = {},
			netAttrType = nil, --0 元宝 1 贡献点 2 师门声望
			items = {["2021xchongbao1"] =1}
		},
		[2] = {
			localAttrs = {},
			netAttrType =nil,
			items = {["2021xchongbao2"] =1}
		}
	}
	
	local role = User:getRole()
    local count = role:getDayFlag("讨红包次数")
    if count >= 1 then
        RichPrint("main","YEL"..roleName.."："..afterGetRedPacketText[math.random(1,#afterGetRedPacketText)])
        return
    end

    local isEnoughSpace = true
    if MapIsEmpty(packetReward[roleType]) == false and MapIsEmpty(packetReward[roleType].items) == false then
		isEnoughSpace = role:checkCanBuyTwoOrMoreThings(packetReward[roleType].items,false)
    end 
    if isEnoughSpace == false then 
    	PopText("背包已满，无法领取奖励")
		return
    end

	local function getLocalReward(rewardInfo)
		if MapIsEmpty(rewardInfo) == false and  MapIsEmpty(rewardInfo.localAttrs) == false then 
			for k,v in pairs(rewardInfo.localAttrs) do 
				role:addAttr(k,v)
				PopText("获得"..tostring(v)..role:getCHAttrName(k))
			end
		end

		if MapIsEmpty(rewardInfo) == false and  MapIsEmpty(rewardInfo.items) == false then 
			for k,v in pairs(rewardInfo.items) do 
				role:addItemCount(k,v)
				local itemInfo = Item:getOneItemByKey(k)
			    PopText("获得"..itemInfo.name.." X "..tostring(v))
			end
		end
	end

	local function getNetReward(rewardInfo,callfunc)
		if MapIsEmpty(rewardInfo) == false and  rewardInfo.netAttrType then 
			HttpManagerEx:getMenPaiHongBao(rewardInfo.netAttrType,function(status, errcode, errmsg, data)
			    if status == 200 and errcode == 0 then
					if MapIsEmpty(data) ==false then 
						for i,v in pairs(data) do
							PopText("获得"..v..role:getCHAttrName(i))
						end
						
						RichPrint("main","YEL"..roleName..getRedPacketText[math.random(1,#getRedPacketText)])
						callfunc()
					end
			    else
			    	print("status:",status)
			    	PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end
	end

	if MapIsEmpty(packetReward[roleType]) == false and  packetReward[roleType].netAttrType then 
		getNetReward(packetReward[roleType],function()
			getLocalReward(packetReward[roleType])
			callBack()
			role:setDayFlag("讨红包次数", count+1)
		end)
	else
		getLocalReward(packetReward[roleType])
		callBack()
		RichPrint("main","YEL"..roleName..getRedPacketText[math.random(1,#getRedPacketText)])
		role:setDayFlag("讨红包次数", count+1)
	end
    
end

--串门摆放策略奖励
function SpringFestival:getNewYearRewardByRsid(rsid)
	
	if not rsid then 
		print("检查策略id")
		return 
	end
	local player=User:getRole()
	local map=player:getCurrMap()
    local rewardArray=RewardManager:getRewardArrayWithRewardScheme(rsid,  player:getAttr("exp"), player:getFinalAttr("luck"), player:getKongfu())
    for i, reward in ipairs(rewardArray) do
        if reward.type == "物品" then
        	local itemAttr = Item:getOneItemByKey(reward.id)
        	if itemAttr.type == "秘籍残页" or itemAttr.type == "书页" then
                User:getRole():addItemCount(reward.id, reward.value)
                PopText("获得 " .. itemAttr.name .. " x " .. reward.value)
            else
            	if map:addItemCount(reward.id, reward.value) == false then
                	map:dropItem(map:getCurrRoomId(), reward.id, reward.value)
                else
                	User:getRole():addItemCount(reward.id, reward.value)
                	PopText("获得 " .. itemAttr.name .. " x " .. reward.value)
                end
            end
        elseif reward.type == "属性" then
            if type(User:getRole():getCHAttrName(reward.id)) == "string" then
                PopText("获得" .. player:getCHAttrName(reward.id) .. tostring(reward.value))
            end
            User:getRole():addAttr(reward.id, reward.value) 
            map:richPrintText(User:getRole(), reward.id, reward.value) -- 角色属性变化文本显示
        end
    end
end

--串门摆放额外奖励
--( 1 碎银红包 2 新春福袋 3普通奖励奖励 5奖励次数已满 无奖励)
function SpringFestival:getHouserNewYearExtraReward(rewardType)
	local attrRewards = {
		["weiwang"]={[1] = 1,[2] = 2} --k 对应奖励类型 v 对应奖励数值
	}
	for k,v in pairs(attrRewards) do 
		if v and v[rewardType] then 
			User:getRole():addAttr(k, v[rewardType])
		    PopText("获得"..User:getRole():getCHAttrName(k)..tostring(v[rewardType]))
		end
	end
end

function SpringFestival:getVisitorNewYearExtraReward(rewardType)
	local itemRewards = {
		["newfudai17"]={[2] = 1} --k 对应奖励类型 v 对应奖励数值
	}

	local role=User:getRole()
	local map=role:getCurrMap()

	for k,v in pairs(itemRewards) do 
		if v and v[rewardType] then 
			if map:addItemCount(k, v[rewardType]) == false then
            	map:dropItem(map:getCurrRoomId(), k, v[rewardType])
            else
            	local currItem = Item:getOneItemByKey(k)
				role:addItemCount(k, v[rewardType])
			    PopText("获得"..currItem.name.." X "..tostring(v[rewardType]))
            end
		end
	end
end

function SpringFestival:getHouserGiveGiftExtraReward(rewardType)
	local itemRewards = {
		["newfudai17"]={[2] = 1}, --k 对应奖励类型 v 对应奖励数值
		["homebw2"] = {[1] = 1}
	}

	local role=User:getRole()
	local map=role:getCurrMap()
	
	for k,v in pairs(itemRewards) do 
		if v and v[rewardType] then 
			if map:addItemCount(k, v[rewardType]) == false then
            	map:dropItem(map:getCurrRoomId(), k, v[rewardType])
            else
            	local currItem = Item:getOneItemByKey(k)
				role:addItemCount(k, v[rewardType])
			    PopText("获得"..currItem.name.." X "..tostring(v[rewardType]))
            end
		end
	end
end

return SpringFestival0