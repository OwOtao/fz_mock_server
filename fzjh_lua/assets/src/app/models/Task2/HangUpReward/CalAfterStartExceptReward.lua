--[[
    获取玩家当前状态下可以获得的挂机奖励
]]
local newClass = require("third.class.NewClass")

local TaskRewardFactory = require("app.models.Task2.TaskRewardFactory")

local TaskConst = require("app.models.Task2.TaskConst")

local CalAfterStartExceptReward = {}

function CalAfterStartExceptReward:create()
    return CalAfterStartExceptReward.new()
end


function CalAfterStartExceptReward:setPlayerHangUpTask(task)
    --@RefType [src.app.models.Task2.PlayerHangUpTask#PlayerHangUpTask]
    self.__task = task
end

function CalAfterStartExceptReward:setPlayer(player)
    self.__player = player
end

function CalAfterStartExceptReward:__calRewards()
    local inheritAddition = self.__task:getInheritAddition()

    local list = TaskRewardFactory:createPlayerHangUpRewards(self.__task:getHangUpRewardClassId())

    for i = 1, #list do
        --@RefType [src.app.models.Task2.PlayerHangUpTaskReward#PlayerHangUpTaskReward]
        local reward = list[i]

        reward:setKongfu(self.__task:getKongfu())

        reward:setLuck(self.__task:getLuck())

        reward:setInheritAddition(inheritAddition)

        reward:setShiZhenAddition(self.__task:getShiSiZhenValue())

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
    self.__luckRewards = {}
    self.__yaShiRewards = {}
    local TaskAttrReward = require("app.models.Task2.TaskAttrReward")

    print("CalAfterStartExceptReward 开始挂机后预算值计算 :" )

    for i = 1, #list do
        --@RefType [src.app.models.Task2.PlayerHangUpTaskReward#PlayerHangUpTaskReward]
        local hangUpReward = list[i]

        --@RefType [src.app.models.Task2.TaskAttrReward#TaskAttrReward]
        local attrReward = TaskAttrReward:create(hangUpReward:getRewardAttrName(), hangUpReward:getValue())
        table.insert(self.__rewards, attrReward)

        --@RefType [src.app.models.Task2.TaskAttrReward#TaskAttrReward]
        local luckReward = TaskAttrReward:create(hangUpReward:getRewardAttrName(), hangUpReward:getLuckAdditionValue())
        table.insert(self.__luckRewards, luckReward)

        if self.__player:isYaShi() then
            --@RefType [src.app.models.Task2.TaskAttrReward#TaskAttrReward]
            local yaShiAdditionReward = TaskAttrReward:create(hangUpReward:getRewardAttrName(), hangUpReward:getYaShiAdditionValue())
            table.insert(self.__yaShiRewards, yaShiAdditionReward)
        end

        hangUpReward:printInfo()
    end


    print("CalAfterStartExceptReward:__calRewards kongfu :" .. self.__task:getKongfu())
    print("CalAfterStartExceptReward:__calRewards luck :" .. self.__task:getLuck())
    print("CalAfterStartExceptReward:__calRewards shiSiZhenValue :" .. self.__task:getShiSiZhenValue())
    print("CalAfterStartExceptReward:__calRewards inheritAddition :" .. self.__task:getInheritAddition())
    print("CalAfterStartExceptReward:__calRewards yashi :" ..  tostring(self.__player:isYaShi()))
end

function CalAfterStartExceptReward:getRewards()
    if self.__rewards == nil then
        self:__calRewards()
    end

    return self.__rewards
end

function CalAfterStartExceptReward:getLuckAddRewards()
    if self.__luckRewards == nil then
        self:__calRewards()
    end

    return self.__luckRewards
end

function CalAfterStartExceptReward:getYaShiAddRewards()
    if self.__yaShiRewards == nil then
        self:__calRewards()
    end

    return self.__yaShiRewards
end


return newClass("CalAfterStartExceptReward", {}, CalAfterStartExceptReward)
0000000000000