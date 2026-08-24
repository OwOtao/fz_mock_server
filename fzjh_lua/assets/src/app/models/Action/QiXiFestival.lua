local QiXiFestival = {}
local monsterCreate =  require("script.others.monsterCreate").Sheet1

--生成七夕任务相关人物
function QiXiFestival:createQiXiRole(map)
    if map:getFlag("是否生成七夕npc") == 1 then
        print("已经生成七夕npc")
        return
    end
	local roleId = "zhangsheng"
    local npc = self:createNpc(roleId,map)
    local roomId
    --随机房间
	for k,v in pairs(monsterCreate) do
		if v.monster == roleId then
			local mapstr = v.map
			local mapAndRoom = string.split(mapstr,";")

			for i,v in ipairs(mapAndRoom) do
				local mapAndRoomStr = v
				local mapAndRoomList = string.split(mapAndRoomStr,"|")
				local mapid = mapAndRoomList[1]
				local roomStr = mapAndRoomList[2]
				
                if mapid == map.id then
                    if roomStr then
                        local roomList = string.split(roomStr,",")
                        roomId = roomList[math.random( 1,#roomList)]
                        print("随机房间 roomId = ",roomId)
                    else
                        assert(false,"QiXiFestival:createQiXiRole(map)  mapid = "..mapid)
                    end
                end
			end

		end
	end 

    map:createRole(npc)
    map:addRoomRole(roomId, npc.id)
    map:setFlag("是否生成七夕npc",1)
end

function QiXiFestival:createNpc(roleId,map)
	local role = Npc:createTaskNpc(roleId)

	if roleId == "zhangsheng" then
		role.canKill = false
		role.caozuo1 = true
		role.caozuoName1 = "交谈"
        role.caozuo2 = true
		role.caozuoName2 = "送礼"
		role.conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作1",
					}
				},
				results =
				{
					{
						type = "七夕交谈",
						arg1 = "七夕交谈",
					},
					{
						type = "生成七夕怪物",
						arg1 = "生成七夕怪物", --需要生成标记
                        arg2 = "jiading", --怪物id
					},
				},
			},
            {
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作2",
					}
				},
				results =
				{
					{
						type = "七夕送礼",
						arg1 = "七夕送礼",
						arg2 = "zhouhuodongbg"
					},
				},
			},
		}
    elseif roleId == "jiading" then
        role.canKill = false
		role.caozuo1 = true
		role.caozuoName1 = "交谈"
        role.caozuo2 = true
		role.caozuoName2 = "追击"
		role.conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作1",
					}
				},
				results =
				{
					{
						type = "七夕怪物交谈",
						arg1 = "七夕怪物交谈",
					},
				},
			},
            {
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作2",
					}
				},
				results =
				{
					{
						type = "七夕怪物追击",
						arg1 = "七夕怪物追击",
					},
				},
			},
		}
	end
	return role
end

--完成七夕任务，在调用任务成功条件结果时调用
function QiXiFestival:finishQiXiTask(map,npc,roomId,itemId)
    if map == nil or npc == nil or roomId == nil or itemId == nil then
        return
	end
	local role = User:getRole()
	
	if role:getAttr("weight") - #role:getItems() < 1 then
		PopText("背包空间不足")
		return
	end

	local npcId = npc.id
	local isBuff = false
    HttpManagerEx:FinishQiXiTask("QiXiLoveLetter",function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0  then
			local duration = data.times --任务持续时间
			if MapIsEmpty(data.currency) == false then
                for currency,valueData in pairs(data.currency) do
                    if valueData.value > 0 then 
                         PopText("增加"..tostring(valueData.value)..role:getCHAttrName(currency).."，共拥有"..tostring(valueData.count)..role:getCHAttrName(currency))
                    end
                    if valueData.desc ~= nil and valueData.desc ~= ""  then
                        PopText(valueData.desc)
                    end
                end
            end
			HttpManagerEx:checkGoodsValid({"yuhuiling"}, function(status, errcode, errmsg, data)
				if 200 == status and 0 == errcode then
					for k,v in pairs(data) do 
						if "yuhuiling" == v.itemId and v.number > 0 then 
							isBuff = true
						end
					end
					
					--扣除提交任务道具
					role:addItemCount(itemId, -1)

					local pot,exp = 0,0
					if duration > 300 then
						pot = 4000
						exp = 6000
					elseif duration > 20 then
						pot = 7000
						exp = 9000
					else
						pot = 10000
						exp = 12000
					end
					local attrReward = {
						pot = pot,
						exp = exp
					}

					--属性奖励
					for k,v in pairs(attrReward) do
						local buffAddValue = role:getDayFlag("yuhuiling_"..k)
						local addValue = 0 
						if isBuff  then 
							addValue = YUHUILING_BUFF * v 

							addValue = math.min(addValue,YUHUILING_NUM_LIMIT - buffAddValue)
						end
						
						role:setDayFlag("yuhuiling_"..k,buffAddValue + addValue)

						local finalNum = v + addValue
						role:addAttr(k,finalNum)
						PopText("获得"..tostring(finalNum)..role:getCHAttrName(k))
					end
					
					--奖励策略id
					local extraAwardId = ""

					local taskTimes = role:getInheritFlag("weekbgsq_gameTimes")
					taskTimes = taskTimes + 1

					--保底机制
					if taskTimes >= 15 then
						extraAwardId = "2020sjjcelue2"
						taskTimes = 0
						local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")
                        ActivityCalendarUtils:getSpecialTitle("weekbgsq")
					else
						extraAwardId = "2020sjjcelue1"
					end

					role:setInheritFlag("weekbgsq_gameTimes",taskTimes)

					local rewardArray = RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(
							extraAwardId,
							role:getAttr("exp"),
							role:getFinalAttr("luck"),
							role:getKongfu()
						)
		
					local estRewardList = {
						["属性"] = {},
						["物品"] = {}
					}
	
					if not MapIsEmpty(rewardArray) then
						for i, reward in ipairs(rewardArray) do
							if reward.type == "物品" then
								estRewardList["物品"][reward.id] = tonumber(reward.value)
							elseif reward.type == "属性" then
								estRewardList["属性"][reward.id] = tonumber(reward.value)
							else
								if DEBUG_MODE == 1 then
									assert(false, "奖励策略奖励类型填写错误")
								end
							end
						end
					end
	
					local attrTab = estRewardList["属性"]
					local itemTab = estRewardList["物品"]
					if not MapIsEmpty(attrTab) then
						for attr,attrValue in pairs(attrTab) do
							role:addAttr(attr,attrValue)
							PopText("获得" .. role:getCHAttrName(attr) ..tostring(attrValue))
						end
					end
	
					if not MapIsEmpty(itemTab) then
						for itemId,itemValue in pairs(itemTab) do
							local item = Item:getOneItemByKey(itemId)
							if item then
								local name = item.name
								role:addItemCount(itemId, itemValue)
								PopText("获得".. name.." x " .. itemValue)
							else
								print(false,"物品不存在  itemId = "..itemId)
							end
						end
					end
		
					RichPrint("main","YEL" .. npc.name .. "：感谢少侠相助，区区薄礼，还请笑纳！")
		
					--完成任务，清除保存的副本id
					role:setInheritFlag("七夕情书随机副本id",nil)
		
					map:removeRoomRole(roomId,npcId)
					map.__MapLayer:delayRefreshMap()
				else
					PopText("网络请求出错,请换个网络环境再试!")
				end
			end, IS_SHOW_WAITING)
			
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

function QiXiFestival:createQiXiTaskGuaiWu(npcId,map)
    local roleId = npcId
    local npc = self:createNpc(roleId,map)
    local roomId
    --随机房间
    for k,v in pairs(monsterCreate) do
        if v.monster == roleId then
            local mapstr = v.map
            local mapAndRoom = string.split(mapstr,";")

            for i,v in ipairs(mapAndRoom) do
                local mapAndRoomStr = v
                local mapAndRoomList = string.split(mapAndRoomStr,"|")
                local mapid = mapAndRoomList[1]
                local roomStr = mapAndRoomList[2]
                
                if mapid == map.id then
                    if roomStr then
                        local roomList = string.split(roomStr,",")
                        roomId = roomList[math.random( 1,#roomList)]
                        print("七夕怪物随机房间 roomId = ",roomId)
                    else
                        assert(false," mapid = "..mapid)
                    end
                end
            end

        end
    end 

    map:createRole(npc)
    map:addRoomRole(roomId, npc.id)
end

return QiXiFestival00000