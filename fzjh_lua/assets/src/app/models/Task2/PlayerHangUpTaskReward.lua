local newClass = require("third.class.NewClass")

local PlayerHangUpTaskReward = {
    __luck = 0,
    __kongfu = 0,
    __yaShiAddition = 0,
    __shiSiZhenAddition = 0,
    __inheritAddition = 0
}

function PlayerHangUpTaskReward:create()
    return PlayerHangUpTaskReward.new()
end

function PlayerHangUpTaskReward:setTaskReward(taskReward)
    --@RefType [src.app.models.Task2.HangUpTaskReward#HangUpTaskReward]
    self.__taskReward = taskReward
end

function PlayerHangUpTaskReward:getId()
    return tostring(self.__taskReward:getId())
end

function PlayerHangUpTaskReward:setLuck(value)
    self.__luck = value
end

function PlayerHangUpTaskReward:setKongfu(value)
    self.__kongfu = value
end

function PlayerHangUpTaskReward:setYaShiAdditionValue(value)
    self.__yaShiAddition = value
end

function PlayerHangUpTaskReward:setShiZhenAddition(value)
    self.__shiSiZhenAddition = value
end

function PlayerHangUpTaskReward:setInheritAddition(value)
    self.__inheritAddition = value
end

function PlayerHangUpTaskReward:getRewardAttrName()
    local awardType = self.__taskReward:getAwardType()
    if awardType == 1 then
        return "exp"
    elseif awardType == 2 then
        return "pot"
    elseif awardType == 3 then
        return "money"
    else
        error("挂机任务奖励：" .. self.__taskReward:getId() .. "，奖励类型未知：" .. awardType)
    end
end

function PlayerHangUpTaskReward:__getHangUpTaskKongFuValue()
    --@desc 任务sklv下限
    local sklvLowLimit = self.__taskReward:getSklvLowLimit()

    --@desc 功夫值
    local kongfu = self.__kongfu

    --@desc 任务sklv上限
    local sklvUpperLimit = self.__taskReward:getSklvUpperLimit()

    --@desc 挂机功夫值 = math.min(max(任务sklv下限, 当前角色功夫值),任务sklv上限)
    local value = math.min(math.max(sklvLowLimit, kongfu), sklvUpperLimit)

    return value
end

function PlayerHangUpTaskReward:__getKongFuAdditionValue()
    local hangUpKongfuValue = self:__getHangUpTaskKongFuValue()

    --@desc sklv加成基准值
    local sklvAdd = self.__taskReward:getSklvAddBase()

    --@desc sklv基础修正系数
    local sklvBaseCorrection = self.__taskReward:getSklvBaseCorrection()

    local sklvAddCorrection = self.__taskReward:getSklvAddCorrection()

    --@desc 功夫值加成 = (挂机功夫值 - sklv加成基准值) * sklv基础修正系数 / sklv加成修正值
    local value = (hangUpKongfuValue - sklvAdd) * sklvBaseCorrection / sklvAddCorrection

    return value
end

--@desc 福缘加成收益
function PlayerHangUpTaskReward:__getLuckAdditionValue()
    --@desc 福缘加成收益 = (福缘系数A * min(当前角色福缘值,角色福缘限制) + 福缘参数A ) / (福缘系数B * min(当前角色福缘值,角色福缘限制) + 福缘参数B)

    local luckLimit = math.min(self.__luck, self.__taskReward:getLuckLimit())

    local value = (self.__taskReward:getFyFactorA() * luckLimit + self.__taskReward:getFyParamA()) / (self.__taskReward:getFyFactorB() * luckLimit + self.__taskReward:getFyParamB())

    return value
end

--@desc 每秒收益值
function PlayerHangUpTaskReward:getValue()
    if self.__taskReward:getAwardNumType() == 0 then
        return self.__taskReward:getBaseAward()
    end

    if self.__taskReward:getAwardNumType() == 1 then
        local bastAward = self.__taskReward:getBaseAward()

        --@desc 功夫值加成
        local kongFuAdditionValue = self:__getKongFuAdditionValue()

        --@desc 付费比例
        local payScale = self.__taskReward:getPayScale()

        --@desc 月卡加成
        local yaShiAddition = self.__yaShiAddition

        --@desc 预留付费加成
        local payAddtionValue = 0

        --@desc 福缘比例
        local fyScale = self.__taskReward:getFyScale()

        --@desc 福缘加成收益
        local luckAddtionValue = self:__getLuckAdditionValue()

        --@desc 走穴十四针加成值
        local shiSiZhenAddition = self.__shiSiZhenAddition

        --@desc 传承加成系数
        local inheritAddition = self.__inheritAddition

        --@desc 传承修正系数
        local inheritCorrectionFactor = self.__taskReward:getInheritCountAddCorrection()

        --@desc (任务基础收益 * (1 + 功夫值加成) * 付费比例 * (1 + 月卡加成 + 预留付费加成) + 任务基础收益 * (1 + 功夫值加成+走穴十四针加成值+传承加成系数*传承修正系数) * 福缘比例 * 福缘加成收益) / 3600

        local value =
            (bastAward * (1 + kongFuAdditionValue) * payScale * (1 + yaShiAddition + payAddtionValue) +
            bastAward * (1 + kongFuAdditionValue + shiSiZhenAddition + inheritAddition * inheritCorrectionFactor) * fyScale * luckAddtionValue) /
            3600

        return value
    end
end

function PlayerHangUpTaskReward:isHasLuckAddition()
    return not self.__taskReward:getAwardNumType() == 0
end

--@desc 每秒福缘加成收益
function PlayerHangUpTaskReward:getLuckAdditionValue()
    local bastAward = self.__taskReward:getBaseAward()

    --@desc 功夫值加成
    local kongFuAdditionValue = self:__getKongFuAdditionValue()

    --@desc 福缘比例
    local fyScale = self.__taskReward:getFyScale()

    --@desc 福缘加成收益
    local luckAddtionValue = self:__getLuckAdditionValue()

    --@desc 走穴十四针加成值
    local shiSiZhenAddition = self.__shiSiZhenAddition

    --@desc 传承加成系数
    local inheritAddition = self.__inheritAddition

    --@desc 传承修正系数
    local inheritCorrectionFactor = self.__taskReward:getInheritCountAddCorrection()

    -- int(任务基础收益*(1+功夫值加成+走穴十四针加成值+传承加成系数*传承修正系数)*福缘比例*福缘加成收益)
    local value = bastAward * (1 + kongFuAdditionValue + shiSiZhenAddition + inheritAddition * inheritCorrectionFactor) * fyScale * luckAddtionValue / 3600

    return value
end

function PlayerHangUpTaskReward:isHasYaShiAddition()
    return self.__yaShiAddition > 0
end

--@desc 月卡每秒加成收益
function PlayerHangUpTaskReward:getYaShiAdditionValue()
    -- 任务基础收益*(1+功夫值加成)*付费比例*月卡加成 * 3600
    local bastAward = self.__taskReward:getBaseAward()
    --@desc 功夫值加成
    local kongFuAdditionValue = self:__getKongFuAdditionValue()

    --@desc 付费比例
    local payScale = self.__taskReward:getPayScale()

    --@desc 月卡加成
    local yaShiAddition = self.__yaShiAddition

    local value = bastAward * (1 + kongFuAdditionValue) * payScale * yaShiAddition / 3600

    return value
end

function PlayerHangUpTaskReward:printInfo()
    print("attr name :" .. self:getRewardAttrName())
    print("luck：" .. self.__luck)
    print("kongfu：" .. self.__kongfu)
    print("yaShiAddition：" .. self.__yaShiAddition)
    print("shiSiZhenAddition：" .. self.__shiSiZhenAddition)
    print("inheritAddition：" .. self.__inheritAddition)
    print("\n")
end

return newClass("PlayerHangUpTaskReward", {}, PlayerHangUpTaskReward)
0000000000