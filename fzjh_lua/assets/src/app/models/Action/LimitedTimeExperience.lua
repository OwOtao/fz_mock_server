local TaskRes = require("script.others.limitedTimeExperience")["Sheet1"]
local class = require("third.class.NewClass")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")
local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")
local LimitedTimeExperience = {}

-- 状态，0：未解锁，1：可领取，2：已领取
local RewardState = {
    NotReward = 0,
    Reward = 1,
    AfterReward = 2,
}

local RewardSort = {
    [RewardState.Reward] = 1,
    [RewardState.NotReward] = 2,
    [RewardState.AfterReward] = 3,
}

function LimitedTimeExperience:create()
    return LimitedTimeExperience:new()
end

function LimitedTimeExperience:ctor()
    self.__name = "限时历练"
    self.__desc = "限时历练"
    self.__taskFinishCount = 0
    self.__totalTaskCount = 3
    self.__rewardList = {}
    self.__taskInfo = {}
    self.__refreshCost = 100
    self.__score = 0
    self.__rewardState = false
end

function LimitedTimeExperience:setRole(role)
    self.__role = role
end

function LimitedTimeExperience:setActionId(actionId)
    self.__actionId = actionId
end

function LimitedTimeExperience:getRole()
    return self.__role
end

function LimitedTimeExperience:getActionInfo(func)
    local pool = self:getTaskTypePool()

    HttpManagerEx:getTrainingTaskList(self.__actionId,pool,function(status, errcode, errmsg, data)
		if status ==200 and errcode == 0 then
            self.__name = data.act_name

            self.__desc = data.detail_desc

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self.__desc = desc

            self.__score = data.point

            self.__refreshCost = data.refresh_cost

            self.__taskFinishCount = data.completion_times

            self.__totalTaskCount = data.task_limit

            self:__initRewardInfo(data.reward_list)

            self.__rewardPool = data.reward_pool_list

            self:__initTaskInfo(data.task_list)

            if func then
                func()
            end
		else
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
end

function LimitedTimeExperience:getActionName()
    return self.__name
end

function LimitedTimeExperience:getActionDesc()
    return self.__desc
end

function LimitedTimeExperience:getFinishTaskCount()
    return self.__taskFinishCount
end

function LimitedTimeExperience:getTotalTaskCount()
    return self.__totalTaskCount
end

function LimitedTimeExperience:getScore()
    return self.__score
end

function LimitedTimeExperience:getRefreshCost()
    return self.__refreshCost
end

function LimitedTimeExperience:getTaskInfo()
    return self.__taskInfo
end

function LimitedTimeExperience:getRewardList()
    return self.__rewardList
end

function LimitedTimeExperience:getRewardState()
    return self.__rewardState
end

function LimitedTimeExperience:refresh(func)
    local pool = self:getTaskTypePool()
    
    HttpManagerEx:refreshTrainingTaskList(self.__actionId,pool,function(status, errcode, errmsg, data)
		if status ==200 and errcode == 0 then
            self:__initTaskInfo(data.task_list)

            self.__taskFinishCount = data.completion_times
            
            if func then
                func()
            end
		else
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
end

function LimitedTimeExperience:__initTaskInfo(list)
    self.__taskInfo = {}

    if MapIsEmpty(list) == false then
        for k,v in pairs(list) do
            local taskInfo = {}
            taskInfo.id = v.id
            taskInfo.state = v.state
            taskInfo.text1 = v.name
            taskInfo.text2 = v.desc
            taskInfo.text3 = "可获得历练分："..v.score.."分"

            if v.state == 1 then
                taskInfo.loadTexture = "Image/UI/ActionUI/complete.png"
            else
                taskInfo.loadTexture = "Image/UI/ActionUI/incomplete.png"
            end

            table.insert(self.__taskInfo,taskInfo)
        end

        table.sort(self.__taskInfo,function(a,b)
            if a.state > b.state then
                return false
            elseif a.state == b.state then
                if a.id > b.id then
                    return true
                else
                    return false
                end
            else
                return true
            end
        end)
    end
end

function LimitedTimeExperience:__initRewardInfo(list)
    self.__rewardList = {}
    self.__rewardState = false

    if MapIsEmpty(list) == false then
        for k,v in pairs(list) do
            local rewardInfo = {}
            rewardInfo.rid = v.rid
            rewardInfo.state = v.state
            rewardInfo.grade = v.grade
            rewardInfo.rewardIds = v.reward_ids
            rewardInfo.exchangeId = v.exchange_id

            if v.state == 1 then
                self.__rewardState = true
            end

            table.insert(self.__rewardList,rewardInfo)
        end

        table.sort(self.__rewardList,function(a,b)
            if RewardSort[a.state] < RewardSort[b.state] then
                return true
            elseif RewardSort[a.state] == RewardSort[b.state] then
                return a.grade < b.grade
            else
                return false
            end
        end)
    end
end

function LimitedTimeExperience:getRewardText(rewardId)
    local goodsList = self:getReward(rewardId)

    return ActionRewardsHelper:getRewardText(goodsList)
end

function LimitedTimeExperience:getReward(rewardId)
    return self.__rewardPool[tostring(rewardId)]
end

function LimitedTimeExperience:checkCanGetReward(rewards)
    local isDuplicate, searchInfo = GoodsHelper:checkDuplicatePurchaseList(self.__role, rewards)

    return not isDuplicate, searchInfo
end

function LimitedTimeExperience:checkBagCanGetReward(rewards)
    local isTrue, msg = ActionRewardsHelper:checkBagCanGetRewards(rewards, self.__role)
    return isTrue, msg
end

function LimitedTimeExperience:doReward(rid, giftId, isEmail, callback)
    local dataVer = self.__role:getServerActionSystem():getDataVersion()
    local currencyVersion = self.__role:getCurrencyVersion()

    HttpManagerEx:getTrainingTaskReward(self.__actionId, rid, giftId, isEmail, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then

            GoodsHelper:fromNetworkGrantGoods(self.__role,GrantGoodRequest:create({goodsList = data.reward, dataVersion = data.dataVer, currencyVersion = data.currencyVersion}))

            ActionRewardsHelper:printGetRewardsText(data.reward)

            if data.msg then
                PopText(data.msg)
            end

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

---------------------任务----------------------------------
function LimitedTimeExperience:getTaskTypePool()
    local pool = {}
    local taskState = {}
    for k,v in pairs(TaskRes) do
        local condition = v.scondition
        local values = v.openparam
        if not taskState[v.tasktype] and self:checkTaskIsOpen(v.tasktype) and self:__checkTaskIsOpenByCondition(condition,values) and not self:__checkTaskIsClosedByCondition(v.closecondition) then
            table.insert(pool,v.tasktype)
            taskState[v.tasktype] = true
        end
    end

    return pool
end



function LimitedTimeExperience:checkTaskIsOpen(taskType)
    do  --白名单
        if User:getRoleAttr("isWhiteList") == 1 then
            return true
        end
    end

    local currTime = GetTime()

    for k,v in pairs(TaskRes) do
        if taskType == v.tasktype then
            if currTime > Helper:getTimeStampWithStringDate(v.starttime, 0)  and currTime < Helper:getTimeStampWithStringDate(v.endtime, 0) then
                return true
            end
        end
    end

    return false
end

function LimitedTimeExperience:finishTaskByTaskType(taskType)
    local pool = self:getTaskTypePool()
    
    HttpManagerEx:addTrainingTaskPoint(taskType,pool,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                return true
            else
                PopText(errmsg)
                return true
            end
        else
            PopText(errmsg)
            return false
        end
    end, IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)
end

function LimitedTimeExperience:__checkTaskIsOpenByCondition(conditionType, value)
    local isTrue = switch(conditionType,{
        ["level"] = function()
            if self.__role:getLv() >= tonumber(value[1]) then
                return true
            else
                return false
            end
        end,

        ["exp"] = function()
            if self.__role:getExp() >= tonumber(value[1]) then
                return true
            else
                return false
            end
        end,

        ["map"] = function()
            if self.__role:isMapCompleted(value[1]) then
                return true
            else
                return false
            end
        end,

        ["inheritFlag"] = function()
            local flagValue = self.__role:getInheritFlag(value[1])
            if type(flagValue) == "number" then
                flagValue = tostring(flagValue)
            end
            
            if flagValue == value[2] then
                return true
            else
                return false
            end
        end,

        ["flag"] = function()
            local flagValue = self.__role:getFlag(value[1])
            if type(flagValue) == "number" then
                flagValue = tostring(flagValue)
            end

            if flagValue == value[2] then
                return true
            else
                return false
            end
        end,

        ["menpai"] = function()
            local familyId = value[1]

            return self.__role:getFamilyId() == familyId
        end,

        ["familytype"] = function()
            local familyType = tonumber(value[1])

            return self.__role:getFamilyType() == familyType
        end,

        ["hiddenMeridianSystemOpen"] = function()
            local isOpen = self.__role:getHiddenMeridianSystem():isUnlocked() == true and 1 or 0
            
            return isOpen == tonumber(value[1])
        end,
        

        ["default"] = false
    })

    return isTrue
end

--@desc: 判断限时历练任务是否关闭(配置了屏蔽条件而且已经达到屏蔽条件)
--@author:LvBin
--@time:2025-06-03 17:52:26
--@conditionType: 屏蔽条件类型
--@return true or false
function LimitedTimeExperience:__checkTaskIsClosedByCondition(conditionType)
    local isTrue = switch(conditionType,{
        --@desc 拳脚系统所有分支锻境等级是否都达到最高级
        ["duanjingid"] = function()
            local branchTypes = {"10010","10020","10030","10040","10050"}
            for _,branchType in ipairs(branchTypes) do
                if self.__role:getFistFootSystem():getBranchLv(branchType) < self.__role:getFistFootSystem():getBranchMaxLv(branchType) then
                    return false
                end
            end
            return true
        end,

        --@desc 拳脚系统潜思等级是否达到最高级
        ["basisid"] = function()
            return self.__role:getFistFootSystem():getReflectLv() >= self.__role:getFistFootSystem():getReflectMaxLv()
        end,

        --@desc 玄脉图是否达到最高等级而且所有窍关都激活
        ["minditemfull"] = function()
            return self.__role:getHiddenMeridianSystem():isHiddenMeridianChartMaxLv() and self.__role:getHiddenMeridianSystem():acupointAllActivate()
        end,

        ["default"] = false
    })

    return isTrue
end

return class("LimitedTimeExperience", {}, LimitedTimeExperience)
000