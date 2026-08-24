local class = require("third.class.NewClass")
local tasksList = require("script.fenjiyindao.fenjiyindaozu")["Sheet1"]

-- tasksList = {
--     {
--         id = "group1",
--         name = "成长经验",
--         taskId = "task1",
--         desc = "挂机等级达到20级",
--         startCondition = 0,
--         startRecordId = "",
--         finishCondition = "",
--         finishRecordId = "",
--         rewardId = "",
--     }
-- }

local GuideSystem = {}

function GuideSystem:create()
    return GuideSystem:new()
end

function GuideSystem:ctor()
    self._name = "江湖笔录"

    self._point = 0

    self._allList = {}

    self._finishList = {}

    self._currList = {}
end

function GuideSystem:setRole(role)
    self._role = role
end

function GuideSystem:init(callback)
    self:__unlockSpecailRecords()

    AchievementSystem:updateRecord(function()
        self._unlockPoints = AchievementSystem:getUnlockPoints()
        self._unlockRecords = AchievementSystem:getUnlockRecord()
        -- print("-----------_unlockPoints----------------")
        -- Helper:print_lua_table(self._unlockPoints)
        -- print("-----------_unlockRecords----------------")
        -- Helper:print_lua_table(self._unlockRecords)
        self:__initAllList()
        self:__initFinishList()
        self:__initCurrList()
        
        -- HttpManagerEx:getGuideTaskPoint(function(status, errcode, errmsg, data)
        --     if status == 200 and errcode == 0 then
        --         self._point = data.number
                if callback then
                    callback()
                end
        --     else
        --         PopText(errmsg)
        --     end
        -- end, IS_SHOW_WAITING)
    end)
end

function GuideSystem:getName()
    return self._name
end

function GuideSystem:getFinishList()
    local list = {}
    if MapIsEmpty(self._finishList) == false then
        for __,task in pairs(self._finishList) do
            local itemInfo = {}
            itemInfo.id = task.id
            itemInfo.taskId = task.taskId
            itemInfo.title = task.name
            itemInfo.desc = task.desc
            itemInfo.point = task.point
            itemInfo.state = 3 --0 待接取  1 进行中  2 完成待领取奖励  3奖励领取

            table.insert(list,itemInfo)
        end
    end
    return list
end

function GuideSystem:getCurrList()
    local list = {}
    if MapIsEmpty(self._currList) == false then
        for __,task in pairs(self._currList) do
            local itemInfo = {}
            itemInfo.id = task.id
            itemInfo.taskId = task.taskId
            itemInfo.title = task.name
            itemInfo.desc = task.desc
            itemInfo.state = 1 --0 待接取  1 进行中  2 完成待领取奖励  3奖励领取

            for index,unlockId in ipairs(self._unlockPoints) do
                if task.finishCondition == unlockId then
                    itemInfo.state = 2
                end
            end

            table.insert(list,itemInfo)
        end
    end
    return list
end

function GuideSystem:getAllList()
    local list = {}
    if MapIsEmpty(self._allList) == false then
        for __,task in pairs(self._allList) do
            local itemInfo = {}
            itemInfo.id = task.id
            itemInfo.taskId = task.taskId
            itemInfo.title = task.name
            itemInfo.desc = task.desc
            itemInfo.point = task.point
            itemInfo.state = 0 --0 待接取  1 进行中  2 完成待领取奖励  3奖励已领取

            if self._unlockRecords[task.startRecordId] then
                itemInfo.state = 1

                for index,unlockId in ipairs(self._unlockPoints) do
                    if task.finishCondition == unlockId then
                        itemInfo.state = 2
                    end
                end
            end

            if self._unlockRecords[task.finishRecordId] then
                itemInfo.state = 3
            end

            table.insert(list,itemInfo)
        end
    end
    return list
end

function GuideSystem:getPoint()
    return self._point
end

function GuideSystem:acceptTask(taskId,func)
    local task = self:getTaskById(taskId)
    local record = AchievementSystem:getRecordById(task.startRecordId)
    AchievementSystem:add(record)
    if func then
        func()
    end
end

function GuideSystem:finishTask(taskId,func)
    local task = self:getTaskById(taskId)
    local rewards = RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(task.rewardId, self._role:getAttr("exp"), self._role:getFinalAttr("luck"), self._role:getKongfu())

    if self:__checkCanGetReward(rewards) then
        for i, reward in ipairs(rewards) do
            if reward.type == "物品" then
                PopText("获得了 " .. self._role:getOneItemByKey(reward.id).name)
                self._role:addItemCount(reward.id, reward.value)
            elseif reward.type == "属性" then
                if type(self._role:getCHAttrName(reward.id)) == "string" then
                    PopText("获得" .. self._role:getCHAttrName(reward.id) .. tostring(reward.value))
                end
                self._role:addAttr(reward.id, reward.value)
            else
                error()
            end
        end

        local record = AchievementSystem:getRecordById(task.finishRecordId)
        AchievementSystem:add(record)
        if func then
            func()
        end
    end
end

function GuideSystem:getTaskById(taskId)
    if MapIsEmpty(tasksList) == false then
        for __,task in pairs(tasksList) do
            if task.id == taskId then
                return task
            end
        end
    end
    assert(false,taskId.." is not found")
end

function GuideSystem:__checkCanGetReward(rewards)
    if MapIsEmpty(rewards) == false then
        local items = {}
        for i, reward in ipairs(rewards) do
            if reward.type == "物品" then
                if items[reward.id] then
                    items[reward.id] = items[reward.id] + reward.value
                else
                    items[reward.id] = reward.value
                end
            end
        end

        if self._role:checkCanBuyTwoOrMoreThings(items,true) == false then
            return false
        else
            return true
        end
    end 

    return true
end

function GuideSystem:__initAllList()
    self._allList = {}

    local isUnlock = MapIsEmpty(self._unlockPoints) == false
    local isRecord = MapIsEmpty(self._unlockRecords) == false
   
    for __,task in pairs(tasksList) do
        if task.startCondition == 0 then  --0表示无条件
            self._allList[task.id] = task
        else
            if isUnlock then
                for index,unlockId in ipairs(self._unlockPoints) do
                    if task.startCondition == unlockId then
                        self._allList[task.id] = task
                    end
                end
            end

            if isRecord and self._unlockRecords[task.finishRecordId] then
                self._allList[task.id] = task
            end
        end
    end
end

function GuideSystem:__initFinishList()
    self._finishList = {}
    if MapIsEmpty(self._allList) == false then
        for __,task in pairs(self._allList) do
            if task.finishCondition == 0 then  --0表示无条件
                self._finishList[task.id] = task
            elseif self._unlockRecords[task.finishRecordId] then
                self._finishList[task.id] = task
            end
        end
    end
end

function GuideSystem:__initCurrList()
    self._currList = {}
    if MapIsEmpty(self._allList) == false then
        for __,task in pairs(self._allList) do
            if not self._finishList[task.id] and self._unlockRecords[task.startRecordId] then
                self._currList[task.id] = task
            end 
        end
    end
end

function GuideSystem:__unlockSpecailRecords()
    local map_recordIds = {
		["fb01"] = 5001,
		["fb05"] = 5002,
		["fb10"] = 5003,
        ["fb16"] = 5500,
	}

    for fbId,recordId in pairs(map_recordIds) do
        if self._role:isMapCompleted(fbId) then
            local record = AchievementSystem:getRecordById(recordId)
		    AchievementSystem:add(record)
        end
    end

    if self._role:getAttr("wUpCount") >= 1 then
        local record = AchievementSystem:getRecordById(5004)
        AchievementSystem:add(record)
    end

    if self._role:getAttr("ckUpCount") >= 1 then
        local record = AchievementSystem:getRecordById(5005)
        AchievementSystem:add(record)
    end

    if self._role:getInheritFlag("家园引导") >= 2 then
        local record = AchievementSystem:getRecordById(5502)
        AchievementSystem:add(record)
    end

    if self._role:getInheritFlag("江湖情报开启") then
        local record = AchievementSystem:getRecordById(5503)
        AchievementSystem:add(record)
    end

    if self._role:getFlag("drqianzhi") == 1 then
        local record = AchievementSystem:getRecordById(5504)
        AchievementSystem:add(record)
    end

    if self._role:getLv() >= 350 or self._role:getFlag("开启经脉系统") ~= 0 then
        local record = AchievementSystem:getRecordById(5505)
        AchievementSystem:add(record)
    end

    if self._role:getFlag("神兵") == "Y" then
        local record = AchievementSystem:getRecordById(5506)
        AchievementSystem:add(record)
    end

    local shenBingItems = self._role:getAttr("shenBingItems")

    if MapIsEmpty(shenBingItems) == false then
        if #shenBingItems >= 1 then
            local record = AchievementSystem:getRecordById(5013)
            AchievementSystem:add(record)
        end

        for __,shenbing in pairs(shenBingItems) do
            if shenbing.cuilianCount > 0 then
                local record = AchievementSystem:getRecordById(5014)
            	AchievementSystem:add(record)
                break
            end
        end
    end

    local fq = self._role:getHomelandAttr("fq")

    if MapIsEmpty(fq) == false then
        local record = AchievementSystem:getRecordById(5007)
        AchievementSystem:add(record)
    end

    local meridian = self._role:getAttr("meridian")

    local count = meridian.meridianCount

    if count >= 1 then
        local record = AchievementSystem:getRecordById(5012)
        AchievementSystem:add(record)
    end

    HttpManagerEx:getGrowthInfo({"homeland"},
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local servants = {}
                if MapIsEmpty(data.homeland) == false then 
                    servants = data.homeland.servants
                end

                local isPuren,isGuanJia = false,false

                if MapIsEmpty(servants) == false then 
                    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
                    for k,v in pairs(servants) do 
                        if v and v.num > 0 then 
                            local puRenJob = HomelandRoleUtil:getCHAJobTypeName(v.job)
                            if puRenJob == "管家" then
                                isGuanJia = true
                            else
                                isPuren = true
                            end
                        end
                    end

                    if isGuanJia then
                        local record = AchievementSystem:getRecordById(5008)
                        AchievementSystem:add(record)
                    end

                    if isPuren then
                        local record = AchievementSystem:getRecordById(5009)
                        AchievementSystem:add(record)
                    end
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING)
end


return class("GuideSystem", {}, GuideSystem)
00000000