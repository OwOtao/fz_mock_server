local hangUpTaskRewardConfig = requireWithEncrypt("res.script.HangUpTask.hangUpTaskRewardConfig")["挂机奖励"]

local TaskRewardFactory = {}

local hangUpTaskRewardClass = {}

local hangUpTaskRewardClassRes = {}

local function initHangUpRewardClassRes()
    for id, rewardInfo in pairs(hangUpTaskRewardConfig) do
        local awardClass = rewardInfo.awardClass
        if hangUpTaskRewardClassRes[tostring(awardClass)] == nil then
            hangUpTaskRewardClassRes[tostring(awardClass)] = {}
        end

        table.insert(hangUpTaskRewardClassRes[tostring(awardClass)], rewardInfo)
    end
end

initHangUpRewardClassRes()

function TaskRewardFactory:getHangUpRewards(taskClassId)
    local rewards = hangUpTaskRewardClass[tostring(taskClassId)]

    if rewards == nil then
        local HangUpTaskReward = require("app.models.Task2.HangUpTaskReward")
        local reses = hangUpTaskRewardClassRes[tostring(taskClassId)]

        if reses == nil then
            error("挂机奖励没有找到奖励系列：" .. taskClassId)
        end

        rewards = {}

        for k, v in pairs(reses) do
            local rewardClass = HangUpTaskReward:create(v)
            table.insert(rewards, rewardClass)
        end

        hangUpTaskRewardClass[tostring(taskClassId)] = rewards
    end

    return rewards
end

function TaskRewardFactory:createPlayerHangUpRewards( taskClassId)
    local rewards = self:getHangUpRewards(taskClassId)

    local PlayerHangUpTaskReward = require("app.models.Task2.PlayerHangUpTaskReward")
    local list = {}
    for _, v in ipairs(rewards) do
        --@RefType [src.app.models.Task2.PlayerHangUpTaskReward#PlayerHangUpTaskReward]
        local pHanguUpTaskReward = PlayerHangUpTaskReward:create()

        pHanguUpTaskReward:setTaskReward(v)

        table.insert(list, pHanguUpTaskReward)
    end

    return list
end

return TaskRewardFactory
0000000000000