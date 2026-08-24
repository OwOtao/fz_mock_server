--[[
    实际挂机收益计算
]]
local newClass = require("third.class.NewClass")

local TaskRewardFactory = require("app.models.Task2.TaskRewardFactory")

local TaskConst = require("app.models.Task2.TaskConst")

local CalHangUpTaskRewards = {
    __kongfu = 0,
    __luck = 0,
    __inheritValue = 0,
    __shiSiZhenValue = 0,
    __yaShiActiveTime = 0,
    __startTime = 0,
    __finsihTime = 0,
    __rewardInfo = {}
}

function CalHangUpTaskRewards:create()
    return CalHangUpTaskRewards.new()
end

function CalHangUpTaskRewards:setRewardClassId(classId)
    self.__classId = classId
end

function CalHangUpTaskRewards:setKongfu(value)
    self.__kongfu = value
end

function CalHangUpTaskRewards:setLuck(value)
    self.__luck = value
end

function CalHangUpTaskRewards:setInheritAdditionValue(value)
    self.__inheritValue = value
end

function CalHangUpTaskRewards:setShiSiZhenValue(value)
    self.__shiSiZhenValue = value
end

function CalHangUpTaskRewards:setYaShiActiveTime(time)
    self.__yaShiActiveTime = time
end

function CalHangUpTaskRewards:setStartTime(time)
    self.__startTime = time
end

function CalHangUpTaskRewards:setFinishTime(time)
    self.__finishTime = time
end

function CalHangUpTaskRewards:__getTaskRewards()
    return TaskRewardFactory:createPlayerHangUpRewards(self.__classId)
end

function CalHangUpTaskRewards:__calUseYaShiAddtionRewards()
    if self.__yaShiActiveTime <= 0 then
        error("雅士生效时间小于0，无法使用雅士计算挂机收益")
    end

    print("计算实际收益有雅士时间：")

    local rewards = self:__getTaskRewards()

    for i = 1, #rewards do
        --@RefType [src.app.models.Task2.PlayerHangUpTaskReward#PlayerHangUpTaskReward]
        local reward = rewards[i]

        reward:setKongfu(self.__kongfu)

        reward:setLuck(self.__luck)

        reward:setInheritAddition(self.__inheritValue)

        reward:setYaShiAdditionValue(TaskConst:getHangUpTaskConfigValue("yaShiAwardExpAdd"))

        reward:setShiZhenAddition(self.__shiSiZhenValue)

        self:__addRewardInfo(reward:getRewardAttrName(), reward:getValue() * self.__yaShiActiveTime)

        reward:printInfo()
    end
end

function CalHangUpTaskRewards:__calNoYaShiRewards(time)
    if time < 0 then
        error("雅士生效间隔时间小于0，无法使用该时间计算挂机收益")
    end

    if time == 0 then
        return
    end

    local rewards = self:__getTaskRewards()

    print("计算实际收益没有雅士时间：")

    for i = 1, #rewards do
        --@RefType [src.app.models.Task2.PlayerHangUpTaskReward#PlayerHangUpTaskReward]
        local reward = rewards[i]

        reward:setKongfu(self.__kongfu)

        reward:setLuck(self.__luck)

        reward:setInheritAddition(self.__inheritValue)

        reward:setYaShiAdditionValue(0)

        reward:setShiZhenAddition(self.__shiSiZhenValue)

        self:__addRewardInfo(reward:getRewardAttrName(), reward:getValue() * time)

        reward:printInfo()
    end
end

function CalHangUpTaskRewards:__addRewardInfo(attrName, value)
    if self.__rewardInfo == nil then
        self.__rewardInfo = {}
    end

    --@RefType [src.app.models.Task2.TaskAttrReward#TaskAttrReward]
    local rewardInfo = nil
    if #self.__rewardInfo > 0 then
        for i = 1, #self.__rewardInfo do
            --@RefType [src.app.models.Task2.TaskAttrReward#TaskAttrReward]
            local info = self.__rewardInfo[i]
            if info:getAttrName() == attrName then
                rewardInfo = info
                break
            end
        end
    end

    if rewardInfo == nil then
        local TaskAttrReward = require("app.models.Task2.TaskAttrReward")
        rewardInfo = TaskAttrReward:create(attrName, value)
        table.insert(self.__rewardInfo, rewardInfo)
    else
        local currValue = rewardInfo:getValue()
        rewardInfo:setValue(currValue + value)
    end
end

function CalHangUpTaskRewards:__calRewards()
    self.__rewardInfo = {}

    local elapsedTime = self.__finishTime - self.__startTime

    if self.__yaShiActiveTime > 0 then
        local noYaShiTime = elapsedTime - self.__yaShiActiveTime

        self:__calNoYaShiRewards(noYaShiTime)
        self:__calUseYaShiAddtionRewards()
    else
        self:__calNoYaShiRewards(elapsedTime)
    end


    print("CalHangUpTaskRewards:__calRewards kongfu :" .. self.__kongfu)
    print("CalHangUpTaskRewards:__calRewards luck :" .. self.__luck)
    print("CalHangUpTaskRewards:__calRewards shiSiZhenValue :" .. self.__shiSiZhenValue)
    print("CalHangUpTaskRewards:__calRewards inheritAddition :" .. self.__inheritValue)
    print("CalHangUpTaskRewards:__calRewards yaShiActiveTime :" .. self.__yaShiActiveTime)
end

function CalHangUpTaskRewards:getRewards()
    if self.__rewardInfo then
        self:__calRewards()
    end

    return self.__rewardInfo
end

return newClass("CalHangUpTaskRewards", {}, CalHangUpTaskRewards)
0000