local _roleStatusTagCondition = function(player, funcName, symbol, tagId, tagValue)
    local func = player[funcName]
    local player_value = func(player, tagId)
    local ret =
        switch(
        symbol,
        {
            ["="] = function()
                if player_value == tonumber(tagValue) then
                    return true
                end
            end,
            [">"] = function()
                if player_value > tonumber(tagValue) then
                    return true
                end
            end,
            ["<="] = function()
                if player_value <= tonumber(tagValue) then
                    return true
                end
            end,
            ["<"] = function()
                if player_value < tonumber(tagValue) then
                    return true
                end
            end,
            [">="] = function()
                if player_value >= tonumber(tagValue) then
                    return true
                end
            end,
            ["!="] = function()
                if player_value ~= tonumber(tagValue) then
                    return true
                end
            end,
            default = function()
                error("玩家状态标识判断 参数错误 ， 不支持的符号 " .. tostring(symbol))
            end
        }
    )

    if ret == nil then
        ret = false
    end
    return ret
end

local conditionMap = {
	["玩家操作"] = function(map, condition, environment, player, currRole)
		-- print("environment.operation", environment.operation, "condition.arg2 = ", condition.arg2)
		if environment.operation == condition.arg2 then
			return true
		end
	end,
	["地图标记等于"] = function(map, condition, environment, player, currRole)
		local value = map:getFlag(condition.arg2)
		if value then

			local flagValue = condition.arg3

			if tonumber(flagValue) ~= nil then
				flagValue = tonumber(flagValue)
			end

			if value == flagValue then
				return true
			end
		end
	end,
	["地图标记大于"] = function(map, condition, environment, player, currRole)
		local value = map:getFlag(condition.arg2)
		if value then
			if value > tonumber(condition.arg3) then
				return true
			end
		end
	end,
	["地图标记小于"] = function(map, condition, environment, player, currRole)
		local value = map:getFlag(condition.arg2)
		if value then
			if value < tonumber(condition.arg3) then
				return true
			end
		end
	end,
	["人物标记等于"] = function(map, condition, environment, player, currRole)
		local value = currRole:getFlag(condition.arg2)
		if PRINT_MODE == 1 then
			print("人物标记 "..condition.arg2.." = "..value)
		end
		if value then
			local flagValue = condition.arg3

			if tonumber(flagValue) ~= nil then
				flagValue = tonumber(flagValue)
			end

			if value == flagValue then
				return true
			end
		end
	end,
	["人物标记大于"] = function(map, condition, environment, player, currRole)
		local value = currRole:getFlag(condition.arg2)
		if value then
			if value > tonumber(condition.arg3) then
				return true
			end
		end
	end,
	["人物标记小于"] = function(map, condition, environment, player, currRole)
		local value = currRole:getFlag(condition.arg2)
		if value then
			if value < tonumber(condition.arg3) then
				return true
			end
		end
	end,
	["玩家标记等于"] = function(map, condition, environment, player, currRole)
		local flagValue = condition.arg3

		if tonumber(flagValue) ~= nil then
			flagValue = tonumber(flagValue)
		end

		if player:getFlag(condition.arg2) == flagValue then
			return true
		end
	end,
	["玩家标记大于"] = function(map, condition, environment, player, currRole)
		if player:getFlag(condition.arg2) > tonumber(condition.arg3) then
			return true
		end
	end,
	["玩家标记小于"] = function(map, condition, environment, player, currRole)
		if player:getFlag(condition.arg2) < tonumber(condition.arg3) then
			return true
		end
	end,
	["可传承玩家标记等于"] = function(map, condition, environment, player, currRole)
		local flagValue = condition.arg3

		if tonumber(flagValue) ~= nil then
			flagValue = tonumber(flagValue)
		end

		if player:getInheritFlag(condition.arg2) == flagValue then
			return true
		end
	end,
	["可传承玩家标记大于"] = function(map, condition, environment, player, currRole)
		if player:getInheritFlag(condition.arg2) > tonumber(condition.arg3) then
			return true
		end
	end,
	["可传承玩家标记小于"] = function(map, condition, environment, player, currRole)
		if player:getInheritFlag(condition.arg2) < tonumber(condition.arg3) then
			return true
		end
	end,
	["玩家属性大于"] = function(map, condition, environment, player, currRole)
		if player:getFinalAttr(condition.arg2) > tonumber(condition.arg3) then
			return true
		end
	end,
	["玩家属性小于"] = function(map, condition, environment, player, currRole)
		if player:getFinalAttr(condition.arg2) < tonumber(condition.arg3) then
			return true
		end
	end,
	["玩家属性等于"] = function(map, condition, environment, player, currRole)
		local value = tonumber(condition.arg3)
		--@desc 编辑器导出有些值会变成字符串类型
		if value == nil then
			value = condition.arg3
		end

		if player:getFinalAttr(condition.arg2) == value then
			return true
		end
	end,
	["玩家时间标记等于"] = function(map, condition, environment, player, currRole)

		local flagValue = condition.arg3

		if tonumber(flagValue) ~= nil then
			flagValue = tonumber(flagValue)
		end

		if player:getDayFlag(condition.arg2) == flagValue then
			return true
		end
	end,
	["玩家时间标记大于"] = function(map, condition, environment, player, currRole)
		if player:getDayFlag(condition.arg2) > tonumber(condition.arg3) then
			return true
		end
	end,
	["玩家时间标记小于"] = function(map, condition, environment, player, currRole)
		if player:getDayFlag(condition.arg2) < tonumber(condition.arg3) then
			return true
		end
	end,
	["玩家定时标记等于"] = function(map, condition, environment, player, currRole)

		local flagValue = condition.arg3

		if tonumber(flagValue) ~= nil then
			flagValue = tonumber(flagValue)
		end

		if player:getTimeLimitFlag(condition.arg2) == flagValue then
			return true
		end
	end,
	["玩家定时标记大于"] = function(map, condition, environment, player, currRole)
		if player:getTimeLimitFlag(condition.arg2) > tonumber(condition.arg3) then
			return true
		end
	end,
	["玩家定时标记小于"] = function(map, condition, environment, player, currRole)
		if player:getTimeLimitFlag(condition.arg2) < tonumber(condition.arg3) then
			return true
		end
	end,
	["玩家物品数目大于"] = function(map, condition, environment, player, currRole)
		local itemCount = player:getItemCount(condition.arg2)
		if itemCount > tonumber(condition.arg3) then 
			return true
		end
	end,
	["玩家物品大于"] = function(map, condition, environment, player, currRole)
		local itemCount = player:getItemCount(condition.arg2)
		if itemCount > tonumber(condition.arg3) then 
			return true
		end
	end,
	["玩家物品数目小于"] = function(map, condition, environment, player, currRole)
		local itemCount = player:getItemCount(condition.arg2)
		if itemCount < tonumber(condition.arg3) then 
			return true
		end
	end,
	["玩家物品小于"] = function(map, condition, environment, player, currRole)
		local itemCount = player:getItemCount(condition.arg2)
		if itemCount < tonumber(condition.arg3) then 
			return true
		end
	end,
	["玩家物品数目等于"] = function(map, condition, environment, player, currRole)
		local itemCount = player:getItemCount(condition.arg2)
		if itemCount == tonumber(condition.arg3) then 
			return true
		end
	end,
	["玩家物品等于"] = function(map, condition, environment, player, currRole)
		local itemCount = player:getItemCount(condition.arg2)
		if itemCount == tonumber(condition.arg3) then 
			return true
		end
	end,
	["玩家武功等级大于"] = function(map, condition, environment, player, currRole)
		local skillLv = player:getSkillLv(condition.arg2);
		if not skillLv then
			skillLv = 0
		end
		if skillLv > tonumber(condition.arg3) then
			return true
		end
	end,
	["玩家武功等级小于"] = function(map, condition, environment, player, currRole)
		local skillLv = player:getSkillLv(condition.arg2);
		if not skillLv then
			skillLv = 0
		end
		if skillLv < tonumber(condition.arg3) then
			return true
		end
	end,
	["玩家武功等级等于"] = function(map, condition, environment, player, currRole)
		local skillLv = player:getSkillLv(condition.arg2);
		if not skillLv then
			skillLv = 0
		end
		if skillLv == tonumber(condition.arg3) then
			return true
		end
	end,
	["玩家武功等级小于玩家等级"] = function(map, condition, environment, player, currRole)
		local skillLv = player:getSkillLv(condition.arg2);
		if not skillLv then
			skillLv = 0
		end
		if skillLv < player:getLv() then
			return true
		end
	end,
	["玩家武功等级等于玩家等级"] = function(map, condition, environment, player, currRole)
		local skillLv = player:getSkillLv(condition.arg2);
		if not skillLv then
			skillLv = 0
		end
		if skillLv == player:getLv() then
			return true
		end
	end,
	["玩家武功等级大于玩家等级"] = function(map, condition, environment, player, currRole)
		local skillLv = player:getSkillLv(condition.arg2);
		if not skillLv then
			skillLv = 0
		end
		if skillLv > player:getLv() then
			return true
		end
	end,
	["玩家要进入房间"] = function(map, condition, environment, player, currRole)
		if environment.operation == "离开房间" then
			-- assert(environment.roomId)

			local roomName = condition.arg2
			if roomName == environment.roomId then
				if PRINT_MODE == 1 then
					print("environment.roomId = "..tostring(environment.roomId).." 离开房间 true")
				end
				-- error("玩家要进入房间")
				return true
			end
		else
			if PRINT_MODE == 1 then
				print("environment.roomId = "..tostring(environment.roomId).." 离开房间 false")
			end
		end
	end,
	["玩家离开房间"] = function(map, condition, environment, player, currRole)
		-- 玩家离开当前房间则触发触发 add by XiaoZhiWei 2016-12-21
		if environment.operation == "离开房间" then
			return true
		else
		end
	end,
	["玩家进入房间"] = function(map, condition, environment, player, currRole)
		if environment.operation == "进入房间" then
			local roomName = condition.arg2
			return true
		end
	end,
	["玩家武器类别"] = function(map, condition, environment, player, currRole)
		if player:getCurrWeaponType() == condition.arg2 then
			return true
		end
	end,
	["玩家武器名"] = function(map, condition, environment, player, currRole)
		if player:getCurrWeaponName() == condition.arg2 then
			return true
		end
	end,
	["特殊条件"] = function(map, condition, environment, player, currRole)
		if PRINT_MODE == 1 then
			print("environment.conditionType = "..tostring(environment.conditionType))
			print("environment.result = "..tostring(environment.result))
			print("condition.arg2 = "..tostring(condition.arg2))
			print("condition.arg3 = "..tostring(condition.arg3))
		end
		if environment.conditionType == condition.arg2 and environment.result == condition.arg3 then
			return true
		end
	end,
	["门派等于"] = function(map, condition, environment, player, currRole)
		if player:getFamilyId() == condition.arg2 then
			return true
		else
			return false
		end
	end,
	["门派不等于"] = function(map, condition, environment, player, currRole)
		if player:getFamilyId() ~= condition.arg2 then
			return true
		else
			return false
		end
	end,
	
	["门派类型等于"] = function(map, condition, environment, player, currRole)
		return player:getFamilyType() == condition.arg2
	end,

	["送信时间大于"] = function(map, condition, environment, player, currRole)
		if map.letterInterval ~= nil then
			local interval = map.letterInterval   --送信间隔判断  letterTime
			local letterTime = player:getAttr("letterTime")
			local currTime = GetTime()
			-- print("送信时间间隔: " .. map.letterInterval .. "差值" .. currTime - letterTime)
			if currTime - letterTime >= interval then
				player:setFlag("送信成功",1)
				return true
			end
		end
	end,
	["送信时间小于"] = function(map, condition, environment, player, currRole)
		if map.letterInterval ~= nil then
			local interval = map.letterInterval   --送信间隔判断  letterTime
			local letterTime = player:getAttr("letterTime")
			local currTime = GetTime()
			-- print("送信时间间隔: " .. map.letterInterval .. "差值" .. currTime - letterTime)
			if currTime - letterTime < interval then
				player:setFlag("送信成功",0)
				return true
			end
		end
	end,
	["缉拿时间大于"] = function(map, condition, environment, player, currRole)
		local wantedInterval = player:getAttr("wantedInterval")
		if wantedInterval ~= nil then
			--缉拿任务间隔判断
			local wantedTime = player:getAttr("wantedTime")
			local currTime = GetTime()
			-- print("缉拿任务时间间隔: " .. wantedInterval .. "差值" .. currTime - wantedTime)
			if currTime - wantedTime >= wantedInterval then
				player:setFlag("缉拿成功",1)
				return true
			end
		end
	end,
	["缉拿时间小于"] = function(map, condition, environment, player, currRole)
		local wantedInterval = player:getAttr("wantedInterval")
		if wantedInterval ~= nil then
			--缉拿任务间隔判断
			local wantedTime = player:getAttr("wantedTime")
			local currTime = GetTime()
			print("缉拿任务时间间隔: " .. wantedInterval .. "差值" .. currTime - wantedTime)
			if currTime - wantedTime < wantedInterval then
				player:setFlag("缉拿成功",0)
				return true
			end
		end
	end,
	["使用背包物品"] = function(map, condition, environment, player, currRole)
		if condition.arg1 ~= environment.operation then
			return false
		end
		local itemId = condition.arg2
		if environment.useItemId ~= nil then
			print(environment.useItemId)
			if environment.useItemId == itemId then
				if environment.func ~= nil then
					environment.func()
				end
				return true
			end
		end
	end,
	["使用普通物品"] = function(map, condition, environment, player, currRole)
		if condition.arg1 ~= environment.operation then
			return false
		end
		local itemId = condition.arg2
		if environment.useItemId ~= nil then
			if environment.useItemId == itemId then
				if environment.func ~= nil then
					environment.func()
				end
				return true
			end
		end
	end,
	["装备变更"] = function(map, condition, environment, player, currRole)
		return true
	end,
	["背包剩余空间大于等于"] = function(map, condition, environment, player, currRole)
		local count = condition.arg2
		if count == nil then
			count = 1
		end
		local items = player:getAttr("items")
		if player:getAttr("weight") - #items >= count then
			return true
		end
	end,
	["背包剩余空间小于"] = function(map, condition, environment, player, currRole)
		local count = condition.arg2
		if count == nil then
			count = 1
		end
		local items = player:getAttr("items")
		if player:getAttr("weight") - #items < count then
			return true
		end
	end,
	["是否身上装备道具"] = function(map, condition, environment, player, currRole)
		-- 道具ID
		local itemId = condition.arg2
		return player:checkItemIsEquipbyItemId(itemId)
	end,
	["是否在省试考试时间内"] = function(map, condition, environment, player, currRole)
		local Exam = require("app.models.Exam.Exam")
		return Exam:checkInProvinceExamTime()
	end,
	["有官职"] = function(map, condition, environment, player, currRole)
		if player:getAttr("officialType") ~= 0 and player:getAttr("officialType") ~= nil then
			return true
		end
	end,
	["无官职"] = function(map, condition, environment, player, currRole)
		if player:getAttr("officialType") == 0 or player:getAttr("officialType") == nil then
			return true
		end
	end,
	["物品收集程度大于"] = function(map, condition, environment, player, currRole)
		local item = player:getItem(condition.arg2)
		if item ~= nil and type(condition.arg3) == "number" and item.clCount > condition.arg3 then
			return true
		else
			return false
		end
	end,
	["物品收集程度等于"] = function(map, condition, environment, player, currRole)
		local item = player:getItem(condition.arg2)
		if item ~= nil and type(condition.arg3) == "number" and item.clCount == condition.arg3 then
			return true
		else
			return false
		end
	end,
	["物品收集程度小于"] = function(map, condition, environment, player, currRole)
		local item = player:getItem(condition.arg2)
		if item ~= nil and type(condition.arg3) == "number" and item.clCount < condition.arg3 then
			return true
		else
			return false
		end
	end,
	["装备武器所淬毒药"] = function(map, condition, environment, player, currRole)
		local equipWeapon = player:getEquipByName("weapon")

		--@desc 没有装备武器直接返回false
		if not equipWeapon then
			return false
		end
		
		local poisonWeaponList = player:getAttr("poison")

		local poisonWeapon = poisonWeaponList[tostring(equipWeapon.id)]
		if not poisonWeapon then
			return false
		end

		if condition.arg2 ~= nil and condition.arg2 ~= "" and poisonWeapon.poisonId == condition.arg2 then
			return true
		end

		return false
	end,
	["计时器不存在"] = function (map, condition, environment, player, currRole)
		local timerName = condition.arg2
		if map.timerMap == nil or map.timerMap[timerName] == nil then
			return true
		else
			return false
		end
	end,
	["玩家面具属于阵营"] = function (map, condition, environment, player, currRole)
		local PortraitZhenYing = require("app.models.Decorative.PortraitZhenYing")
		local portraitId = player:getPortraitId()
		local zhenying = condition.arg2  --0 其它 ,1 中原 ,2重光
		print("portraitId = ",portraitId,"zhenying = ",zhenying)
		if PortraitZhenYing:isAppointZY(portraitId,zhenying) then
			print("玩家面具属于阵营 "..zhenying)
			return true 
		else
			return false
		end
	end,
	["角色创建时间大于"] = function (map, condition, environment, player, currRole)
		local nowTime = GetTime()

		local crateTime = User:getRoleAttr("createTime")

		local hours = tonumber(condition.arg2)

		if hours == nil then
			print("角色创建时间大于 参数填写错误",condition.arg2)
			return true
		end

		if GetTime() - Helper:getDef(User:getRoleAttr("createTime"), GetTime()) >= 3600 * hours then
			return true
		end
		return false
	end,
	["角色创建时间小于"] = function (map, condition, environment, player, currRole)
		local nowTime = GetTime()

		local crateTime = User:getRoleAttr("createTime")

		local hours = tonumber(condition.arg2)

		if hours == nil then
			print("角色创建时间小于 参数填写错误",condition.arg2)
			return true
		end

		if GetTime() - Helper:getDef(User:getRoleAttr("createTime"), GetTime()) < 3600 * hours then
			return true
		end

		return false
	end,
	["副本节点标记等于"] = function (map, condition, environment, player, currRole)
		local flagName = condition.arg2
		local flagValue = tonumber(condition.arg3)
		
		local mapId 
		if condition.arg4 ~= "" and  condition.arg4 ~= nil then
			mapId = condition.arg4
		else
			mapId = map.id
		end

		local nodeFlagValue = player:getNodeFlag(mapId,flagName)
		if flagValue == nodeFlagValue then
			return true
		else
			return false
		end
	end,
	["副本节点标记大于"] = function (map, condition, environment, player, currRole)
		local flagName = condition.arg2
		local flagValue = tonumber(condition.arg3)
		local mapId 
		if condition.arg4 ~= "" and  condition.arg4 ~= nil then
			mapId = condition.arg4
		else
			mapId = map.id
		end

		local nodeFlagValue = player:getNodeFlag(mapId,flagName)
		if flagValue > nodeFlagValue then
			return true
		else
			return false
		end
	end,
	["副本节点标记小于"] = function (map, condition, environment, player, currRole)
		local flagName = condition.arg2
		local flagValue = tonumber(condition.arg3)
		local mapId 
		if condition.arg4 ~= "" and  condition.arg4 ~= nil then
			mapId = condition.arg4
		else
			mapId = map.id
		end

		local nodeFlagValue = player:getNodeFlag(mapId,flagName)
		if flagValue < nodeFlagValue then
			return true
		else
			return false
		end
	end,
	["副本是否通关"] = function (map, condition, environment, player, currRole)
		local mapId = condition.arg2 or map.id
		return player:isMapCompleted(mapId)
	end,
	["副本是否未通关"] = function (map, condition, environment, player, currRole)
		local mapId = condition.arg2 or map.id
		return not player:isMapCompleted(mapId)
	end,
	["佩戴指定面具"] = function (map, condition, environment, player, currRole)
		if not condition.arg2 or condition.arg2=="" then 
			print("佩戴面具判断 策划配置条件arg2 为空")
			return false
		end
		local itemList = string.split(condition.arg2,";") 
		if PRINT_MODE==1 then
			Helper:print_lua_table(itemList)
		end
		local ret = false
		local portrait = player:getPortraitId() --信物
		if portrait ~= nil and portrait ~= "" then
			for k,v in ipairs(itemList) do 
				if portrait == v then 
					ret = true
					break
				end
			end
		end
		return ret
	end,
	["未佩戴指定面具"] = function (map, condition, environment, player, currRole)
		if not condition.arg2 or condition.arg2=="" then 
			print("佩戴面具判断 策划配置条件arg2 为空")
			return false
		end
		local itemList = string.split(condition.arg2,";") 
		if PRINT_MODE==1 then
			Helper:print_lua_table(itemList)
		end
		local ret = true
		local portrait = player:getPortraitId() --信物
		if portrait ~= nil and portrait ~= "" then
			for k,v in ipairs(itemList) do 
				if portrait == v then 
					ret = false
					break
				end
			end
		end
		return ret
	end,

	["战斗切磋失败"] = function (map, condition, environment, player, currRole)
		if not condition.arg2 or condition.arg2=="" then 
			print("战斗切磋失败 策划配置条件arg2 为空")
			return false
		end
		if environment.conditionType == "切磋" then 
			if environment.result == "失败" or environment.result == "逃跑" then 
				if condition.arg2 == "失败" or condition.arg2 == "逃跑" then 
					return true
				end
			end
		end
		return false
	end,

	["假人耐久为零"] = function (map,condition,environment,player,currRole)
		if currRole.durable and currRole.durable <= 0 then 
			return true
		end
		return false
	end,
	["单位是否在房间中"] =function (map,condition,environment,player,currRole)
		--@desc 单位ID
		local unitId = condition.arg2
		--@desc 房间ID
		local roomId = condition.arg3

		local room = map:getRoomAttr(roomId)

		if MapIsEmpty(room) == false then
			local room_role_list = room.roleList

			for _, room_unit_id in pairs(room_role_list) do
				if unitId == room_unit_id and map:getRole(unitId) ~= nil then
					return true
				end
			end

			return false
		else
			return false
		end
	end,

	["周公之术阶段判断"] =function (map,condition,environment,player,currRole)
		local condLv = condition.arg2
		local currLv = player:getZhouGongZhiShuLvStatus()
		if tonumber(currLv) == tonumber(condLv) then
			return true
		end
		return false
	end,
	["判断是否有房契"] =function (map,condition,environment,player,currRole)
		local fq = player:getHomelandAttr("fq")

		if MapIsEmpty(fq) then
			return false
		end
		return true
	end,

	["记录点解锁判断"] =function (map,condition,environment,player,currRole)
		local records = condition.arg2

		if not records or records == "" then
			return false
		end

		records = tostring(records)

		records = string.split(records,";")

		local unlockRecords = AchievementSystem:getUnlockRecord()
		
		if MapIsEmpty(unlockRecords) == false then
			for __,_recordId in pairs(records) do
				if not unlockRecords[tonumber(_recordId)] then
					return false
				end
			end
		else
			return false
		end
		
		return true
	end,

	["拳脚锻境等级大于等于"] =function (map,condition,environment,player,currRole)
		local type = condition.arg2

		local needLv = condition.arg3

		if player:getFistFootSystem():getBranchLv(type) >= needLv then
			return true
		else
			return false
		end
	end,

	["拳脚锻境等级小于"] =function (map,condition,environment,player,currRole)
		local type = condition.arg2

		local needLv = condition.arg3

		if player:getFistFootSystem():getBranchLv(type) < needLv then
			return true
		else
			return false
		end
	end,

	["拳脚技巧等级大于等于"] =function (map,condition,environment,player,currRole)
		local techniqueId = condition.arg2

		local needLv = condition.arg3

		if player:getFistFootSystem():getTechniqueLv(techniqueId) >= needLv then
			return true
		else
			return false
		end
	end,

	["拳脚技巧等级小于"] =function (map,condition,environment,player,currRole)
		local techniqueId = condition.arg2

		local needLv = condition.arg3

		if player:getFistFootSystem():getTechniqueLv(techniqueId) < needLv then
			return true
		else
			return false
		end
	end,

	["拳脚潜思等级大于等于"]=function (map,condition,environment,player,currRole)
		local con_reflect_lv = tonumber(condition.arg2)

		if con_reflect_lv == nil then
			assert(false,"ConditionMap : 拳脚潜思等级大于等于 arg2填写错误：" .. tostring(condition.arg2) )
		end
		
		if player:getFistFootSystem():getReflectLv() >= con_reflect_lv then
			return true
		else
			return false
		end
	end,	
	
	["拳脚潜思等级小于"]=function (map,condition,environment,player,currRole)
		local con_reflect_lv = tonumber(condition.arg2)

		if con_reflect_lv == nil then
			assert(false,"ConditionMap : 拳脚潜思等级小于 arg2填写错误：" .. tostring(condition.arg2) )
		end

		if player:getFistFootSystem():getReflectLv() < con_reflect_lv then
			return true
		else
			return false
		end
	end,
	["NPC状态标识判断"] = function(map, condition, environment, player, currRole)
		local flagValue = condition.arg3
		local symbol = condition.arg4
		assert(tonumber(flagValue) ~= nil, "NPC状态标识判断 参数错误")
		return _roleStatusTagCondition(currRole,"getNpcStatusTags",symbol,condition.arg2,flagValue)
	end,
	["玩家状态标识判断"] = function(map, condition, environment, player, currRole)
		local flagValue = condition.arg3
		local symbol = condition.arg4
		assert(tonumber(flagValue) ~= nil, "玩家状态标识判断 参数错误")
		return _roleStatusTagCondition(player,"getRoleStatusTags",symbol,condition.arg2,flagValue)
	end,
	["玩家传承状态标识判断"] = function(map, condition, environment, player, currRole)
		local flagValue = condition.arg3
		local symbol = condition.arg4
		assert(tonumber(flagValue) ~= nil, "玩家传承状态标识判断 参数错误")
		return _roleStatusTagCondition(player,"getInheritRoleStatusTags",symbol,condition.arg2,flagValue)
	end,
	["玩家时间状态标识判断"] = function(map, condition, environment, player, currRole)
		local flagValue = condition.arg3
		local symbol = condition.arg4
		assert(tonumber(flagValue) ~= nil, "玩家时间状态标识判断 参数错误")
		return _roleStatusTagCondition(player,"getTimeStatusTags",symbol,condition.arg2,flagValue)
	end,
	["玩家传承时间标识判断"] = function(map, condition, environment, player, currRole)
		local flagValue = condition.arg3
		local symbol = condition.arg4
		assert(tonumber(flagValue) ~= nil, "玩家传承时间状态标识 参数错误")
		return _roleStatusTagCondition(player,"getInheritTimeStatusTags",symbol,condition.arg2,flagValue)
	end,
	["副本状态标识判断"] = function(map, condition, environment, player, currRole)
		local flagValue = condition.arg3
		local symbol = condition.arg4
		return _roleStatusTagCondition(map,"getMapStatusTags",symbol,condition.arg2,flagValue)
	end,
	default = function(map, condition, environment, player, currRole)
		assert(false, "未知条件, 报错!!!"..", type = "..tostring(condition.arg1)..", name = "..tostring(condition.arg2)..", value = "..tostring(condition.arg3))
		if PRINT_MODE == 1 then
			print("未知类型条件, 默认为true")
		end
		return true
	end,
}

return conditionMap0000000000000