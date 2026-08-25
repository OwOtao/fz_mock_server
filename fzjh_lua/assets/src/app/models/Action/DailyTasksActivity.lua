local class = require("third.class.NewClass")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")
local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")
local DailyTaskConfig = require("script.activity.dailyTask")["Sheet1"]
local DailyTasksActivity = {}

-- 状态，0：不可领取，1：可领取，2：已领取
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

function DailyTasksActivity:create()
    return DailyTasksActivity:new()
end

function DailyTasksActivity:ctor()
    self.__name = "每日任务"
    self.__desc = "每日任务"
    self.__rewardList = {}
    self.__taskList = {}
    self.__score = 0
    self.__rewardState = false
end

function DailyTasksActivity:init(callback)
    HttpManagerEx:getDailyTaskList(function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self.__name = data.act_name

            self.__desc = data.detail_desc

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self.__desc = desc

            self.__score = data.daily_point

            self.__taskList = data.task_list

            self:__initRewardList(data.reward_list)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)

end

function DailyTasksActivity:setRole(role)
    self.__role = role
end

function DailyTasksActivity:getActionName()
    return self.__name
end

function DailyTasksActivity:getActionDesc()
    return self.__desc
end

function DailyTasksActivity:getScore()
    return self.__score
end

function DailyTasksActivity:getTaskInfo()
    return self.__taskList
end

function DailyTasksActivity:getRewardList()
    return self.__rewardList
end

function DailyTasksActivity:getRewardState()
    return self.__rewardState
end

function DailyTasksActivity:getTaskConfig(taskId)
    for k, task in pairs(DailyTaskConfig) do
        if task.id == taskId then
            return task
        end
    end
end

function DailyTasksActivity:__initRewardList(list)
    self.__rewardList = list
    self.__rewardState = false

    if MapIsEmpty(self.__rewardList) == false then
        for k,v in pairs(self.__rewardList) do
            if v.state == 1 then
                self.__rewardState = true
            end
        end

        table.sort(self.__rewardList,function(a,b)
            if RewardSort[a.state] < RewardSort[b.state] then
                return true
            elseif RewardSort[a.state] == RewardSort[b.state] then
                return a.rid < b.rid
            else
                return false
            end
        end)
    end
end

function DailyTasksActivity:getRewardText(rewardId)
    local reward = self:getReward(rewardId)

    return ActionRewardsHelper:getRewardText(reward)
end

function DailyTasksActivity:getReward(rewardId)
    for k, v in pairs(self.__rewardList) do
        if v.rid == rewardId then
            return v.reward
        end
    end
end

function DailyTasksActivity:checkBagCanGetReward(rewards)
    local isTrue, msg = ActionRewardsHelper:checkBagCanGetRewards(rewards, self.__role)
    return isTrue, msg
end

function DailyTasksActivity:doReward(rid, isEmail, callback)
    local dataVer = self.__role:getServerActionSystem():getDataVersion()
    local currencyVersion = self.__role:getCurrencyVersion()

    HttpManagerEx:getDailyTaskReward(rid, isEmail, dataVer, currencyVersion, function(status, errcode, errmsg, data)
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

--------------------------------
--每日任务修改
--------------------------------
function DailyTasksActivity:addDailyTaskPoint(taskType)
	HttpManagerEx:addDailyTaskPoint(taskType,function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				if data.addPoint > 0 then
					PopText("积分+"..tostring(data.addPoint))
				end
			else
				PopText(errmsg)
			end
		end
	end, IS_SHOW_WAITING)
end

return class("DailyTasksActivity", {}, DailyTasksActivity)
000000000000