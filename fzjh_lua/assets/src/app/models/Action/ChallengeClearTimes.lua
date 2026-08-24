local class = require("third.class.NewClass")

local challengeTaskInfoRes = require("script.activity.challengetaskPZ").Sheet1

local challengeTaskConditionRes = require("script.activity.challengetaskTJ").Sheet1

local GoodsHelper = require("app.models.Store.GoodsHelper")

local ChallengeClearTimes = {}

-- 状态，0：未完成，1：已完成，2：已领取
local RewardState = {
    UnFinish = 0,
    Finish = 1,
    AfterReward = 2,
}

function ChallengeClearTimes:create()
    return ChallengeClearTimes:new()
end

function ChallengeClearTimes:ctor()
    self._actionId = 0

    self._name = ""

    self._desc = ""

    self._taskList = {}

	self._mapClearTimes = {}
end

function ChallengeClearTimes:setRole(role)
    self._role = role
end

function ChallengeClearTimes:setActionId(actionId)
    self._actionId = actionId
end

function ChallengeClearTimes:init(callback)
    HttpManagerEx:getActivityChallengeMapClearTimeInfo(function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._name = data.act_name

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self._desc = desc

            self._taskList = data.task_list

			self._mapClearTimes = data.map_list

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function ChallengeClearTimes:getActionName()
    return self._name
end

function ChallengeClearTimes:getActionDesc()
    return self._desc
end

function ChallengeClearTimes:getTaskList()
    return self._taskList
end

function ChallengeClearTimes:checkStateIsUnFinish(state)
    return state == RewardState.UnFinish
end

function ChallengeClearTimes:checkStateIsFinish(state)
    return state == RewardState.Finish
end

function ChallengeClearTimes:checkStateIsAfterReward(state)
    return state == RewardState.AfterReward
end

function ChallengeClearTimes:doReward(callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()

    local currencyVersion = self._role:getCurrencyVersion()
    
	local isEmail = self:checkBagIsEnough() == true and 1 or 0

	HttpManagerEx:getActivityChallengeMapClearReward(isEmail, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

            GoodsHelper:fromNetworkGrantGoods(self._role,GrantGoodRequest:create({goodsList = data.reward,dataVersion = data.dataVer,currencyVersion = data.currencyVersion}))

            local rewardList = data.reward

            if MapIsEmpty(rewardList) == false then
                for i,v in ipairs(rewardList) do
                    local goods = GoodsHelper:getGoodsResClass(v.id)

                    PopText("获得"..goods:getName().."X"..tostring(v.num))
                end
            end

            if data.msg then
                PopText(data.msg)
            end

			self:init(callback)
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

-- true 代表背包满
function ChallengeClearTimes:checkBagIsEnough()
	local reward_summary = {}

	-- 遍历所有任务
	for _, task in ipairs(self._taskList) do
		if self:checkStateIsFinish(task.state) then
			for _, reward in ipairs(task.reward) do
				local reward_id = reward.id
				local reward_num = reward.num
				
				-- 如果该奖励ID已存在，累加数量；否则初始化
				if reward_summary[reward_id] then
					reward_summary[reward_id] = reward_summary[reward_id] + reward_num
				else
					reward_summary[reward_id] = reward_num
				end
			end
		end
	end

	-- 将汇总结果转换为和原始reward格式一致的列表（便于后续使用）
	local final_reward_list = {}
	for id, num in pairs(reward_summary) do
		table.insert(final_reward_list, {id = id, num = num})
	end

    return not GoodsHelper:checkRoleBagGoods(self._role, final_reward_list)
end

--@desc: 检查是否有已完成未领取的任务
--@author:LvBin
--@time:2026-03-18 18:06:36
--@return
function ChallengeClearTimes:checkTaskIsFinish()
	for _, task in ipairs(self._taskList) do
		if self:checkStateIsFinish(task.state) then
			return true
		end
	end

	return false
end

function ChallengeClearTimes:getTaskInfo(taskId)
	for i,taskInfo in ipairs(challengeTaskInfoRes) do
		if taskId == taskInfo.id then
			return taskInfo
		end
	end
	error(self._name.."任务资源找不到 taskId "..taskId)
end

function ChallengeClearTimes:getConditionInfo(conId)
	for i,condition in ipairs(challengeTaskConditionRes) do
		if conId == condition.id then
			return condition
		end
	end
	error(self._name.."条件资源找不到 conId "..conId)
end

--@desc: 获取副本通关次数
--@author:LvBin
--@time:2026-03-18 12:07:00
--@conId: 
--@return
function ChallengeClearTimes:getMapClearTimes(conId)
	local clearTimes = 0

	local conditionInfo = self:getConditionInfo(conId)

	local mapIds = conditionInfo.fbid

	for _,mapId in ipairs(mapIds) do
		for i,v in ipairs(self._mapClearTimes) do
			if v.map_id == mapId then
				clearTimes = clearTimes + v.times
			end
		end
	end
	
	return clearTimes
end

--@desc: 获取奖励商品列表
--@author:LvBin
--@time:2026-03-18 12:05:51
--@taskId: 
--@return
function ChallengeClearTimes:getTaskRewardGoodsList(taskId)
	local task = self:getTaskInfo(taskId)

	local rewards = task.rewards

	local goodsList = {}

	for i,v in ipairs(rewards) do
		table.insert(goodsList, {id = v[1],num = tonumber(v[2])})
	end

	return goodsList
end

return class("ChallengeClearTimes", {}, ChallengeClearTimes)
0000000000