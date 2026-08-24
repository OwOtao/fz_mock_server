--[[
    获取玩家当前状态下可以获得的挂机奖励
]]
local newClass = require("third.class.NewClass")

local TaskRewardFactory = require("app.models.Task2.TaskRewardFactory")

local TaskConst = require("app.models.Task2.TaskConst")

local CalPlayerCurrExceptReward = {}

function CalPlayerCurrExceptReward:create()
    return CalPlayerCurrExceptReward.new()
end

function CalPlayerCurrExceptReward:setPlayer(player)
    self.__player = player
end

function CalPlayerCurrExceptReward:setPlayerHangUpTask(task)
    --@RefType [src.app.models.Task2.PlayerHangUpTask#PlayerHangUpTask]
    self.__task = task
end

function CalPlayerCurrExceptReward:__calRewards()
    local list = TaskRewardFactory:createPlayerHangUpRewards(self.__task:getHangUpRewardClassId())

    local playerInheritCount = self.__player:getAttr("inheritCount")

    local inheritAddition = TaskConst:getInheritAddition(playerInheritCount)

    for i = 1, #list do
        --@RefType [src.app.models.Task2.PlayerHangUpTaskReward#PlayerHangUpTaskReward]
        local reward = list[i]

        reward:setKongfu(self.__player:getKongfu())

        reward:setLuck(self.__player:getFinalAttr("luck"))

        reward:setInheritAddition(inheritAddition)

        reward:setShiZhenAddition(self.__player:getBuffAttr("xingzhenGuaJiSY"))

        if self.__player:isYaShi() then
            reward:setYaShiAdditionValue(TaskConst:getHangUpTaskConfigValue("yaShiAwardExpAdd"))
        end
    end

    table.sort(
        list,
        function(a, b)
            return tonumber(a:getId()) < tonumber(b:getId())
        end
    )

    self.__rewards = {}
    local TaskAttrReward = require("app.models.Task2.TaskAttrReward")
    for i = 1, #list do
        --@RefType [src.app.models.Task2.PlayerHangUpTaskReward#PlayerHangUpTaskReward]
        local hangUpReward = list[i]
        --@RefType [src.app.models.Task2.TaskAttrReward#TaskAttrReward]
        local attrReward = TaskAttrReward:create(hangUpReward:getRewardAttrName(), hangUpReward:getValue())
        table.insert(self.__rewards, attrReward)
    end
end

function CalPlayerCurrExceptReward:getRewards()
    if self.__rewards == nil then
        self:__calRewards()
    end

    return self.__rewards
end

return newClass("CalPlayerCurrExceptReward", {}, CalPlayerCurrExceptReward)
000000000000