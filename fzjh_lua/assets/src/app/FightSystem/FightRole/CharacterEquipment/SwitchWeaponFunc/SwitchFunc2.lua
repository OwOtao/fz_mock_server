--[[
    author:Seven
    time:2023-01-10 12:10:55
    desc: 判断(武器切换目标的武器)是否符合(判断方式)对应的需求
]]
local ASwitchFunc = require("app.FightSystem.FightRole.CharacterEquipment.SwitchWeaponFunc.ASwitchFunc")

local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [src.app.FightSystem.FightRole.CharacterEquipment.SwitchWeaponFunc.ASwitchFunc#ASwitchFunc]
local SwitchFunc2 = {}

function SwitchFunc2:create(logicalSymbol, conditionValue, failTextID)
    return SwitchFunc2.new():__init(logicalSymbol, conditionValue, failTextID)
end

function SwitchFunc2:__init(logicalSymbol, conditionValue, failTextID)
    self.__logicalSymbol = logicalSymbol

    self.__conditionValue = conditionValue

    self.__failTextId = failTextID

    return self
end

--@author:Seven
--@time:2023-01-10 14:27:10
--@sys: [src.app.FightSystem.FightRole.CharacterEquipment.SwitchWeaponFunc#SwitchWeaponFunc]
function SwitchFunc2:canSwitch(sys)
    local targetWeapon = sys:getSwitchTargetWeapon()

    local firstType = targetWeapon:getFirstType()

    local isMatch
    if self.__logicalSymbol == "等于" then
        if firstType == self.__conditionValue then
            isMatch = true
        else
            isMatch = false
        end
    elseif self.__logicalSymbol == "不等于" then
        if firstType ~= self.__conditionValue then
            isMatch = true
        else
            isMatch = false
        end
    elseif self.__logicalSymbol == "跳过" then
        isMatch = true
    else
        error("武器切换条件判断-类型2 ，判断方式未知：" .. self.__logicalSymbol)
    end

    if isMatch == false and self.__failTextId == nil then
        error("切换武器判断失败，但失败提示文本为空，检查配置！！")
    end

    FightUtil:printLog(string.format("武器切换条件判断-类型2：{判断方式：%s ，判断值：%s，目标武器一类型：%s，最终结果：%s}", self.__logicalSymbol, self.__conditionValue, firstType, tostring(isMatch)))

    return isMatch
end

return newClass("SwitchFunc2", {ASwitchFunc}, SwitchFunc2)
000000