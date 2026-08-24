local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local Constants = require("app.FightSystem.FightBuff.Constants")

local ChangeWeaponEffect = {}

function ChangeWeaponEffect:create(effect, buffNeeded)
    local p = ChangeWeaponEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function ChangeWeaponEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function ChangeWeaponEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    self.__conditionType = self.__effect:getEffectTypeParam()[1]
    self.__conditionMethod = self.__effect:getEffectTypeParam()[2]
    self.__conditionValue = self.__effect:getEffectTypeParam()[3]
    self.__conditionFailedText = self.__effect:getEffectTypeParam()[4]
end

function ChangeWeaponEffect:tryTrigger(eventType, eventParam)
    if eventType == Constants.BuffTriggerType.Add then
        return true
    end
    return false
end

-- 条件类型=2、判断(武器切换目标的武器)是否符合(判断方式)对应的需求

-- 判断方式：等于/不等于
-- 判断值：填武器一级分类（对应 表[武器分类管理].firstType）
-- 条件不符提示文本ID：读取表[通用提示文本]的ID


-- 条件类型=3、判断(武器切换目标的武器战斗状态)是否符合(判断方式)对应的需求

-- 判断方式：等于/不等于
-- 判断值：填武器战斗状态【正常（normal）、击飞（fly）、损坏（destroy）、丢弃（giveUp）】
-- 条件不符提示文本ID：读取表[通用提示文本]的ID
function ChangeWeaponEffect:canChange(weaponFirstType, weaponFightState)
    if self.__conditionType == 2 then
        if self.__conditionMethod == "等于" then
            return self.__conditionValue == weaponFirstType
        else
            return self.__conditionValue ~= weaponFirstType
        end
    elseif self.__conditionType == 3 then
        if self.__conditionMethod == "等于" then
            return self.__conditionValue == weaponFightState
        else
            return self.__conditionValue ~= weaponFightState
        end
    else
        return true
    end
end

-- 获取条件类型
function ChangeWeaponEffect:getConditionType()
    return self.__conditionType
end

-- 条件方法
function ChangeWeaponEffect:getConditionMethod()
    return self.__conditionMethod
end

-- 条件值
function ChangeWeaponEffect:getConditionValue()
    return self.__conditionValue
end

-- 条件不符合提示文本
function ChangeWeaponEffect:getConditionFailedText()
    return self.__conditionFailedText
end 

return class("ChangeWeaponEffect", {ActiveEffect}, ChangeWeaponEffect)
00000