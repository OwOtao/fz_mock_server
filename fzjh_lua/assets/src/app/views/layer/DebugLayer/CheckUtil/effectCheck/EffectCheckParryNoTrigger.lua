local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local ParryNoTrigger = {}
--[[
    招架触发
    参数1;arg1
        判断条件目标（自己/目标），不填代表无判断条件需求
    参数2;arg2
        添加额外效果ID
    参数3;arg3
        判断条件参数，不填代表无判断条件需求(多个用 or )
]]

function ParryNoTrigger:create(effect)
    local p = ParryNoTrigger.new()
    p:init(effect)
    return p
end

function ParryNoTrigger:checkArg1()
    local value = self.__effect:getArg1()

    if not value then
        return true
    end

    if value == EffectCheckConst.EffectTargetValue.Owner or value == EffectCheckConst.EffectTargetValue.Target then
        return true
    end

    return false, "arg1值异常，目标值填写错误，arg1:"..tostring(value)
end

function ParryNoTrigger:checkArg2()
    local value = self.__effect:getArg2()

    local effectList = EffectCheckConst.EffectList

    if effectList[value] then
        return true
    end

    return false, "arg2值异常，触发效果找不到，arg2:"..tostring(value)
end

function ParryNoTrigger:checkArg3()
    local value = self.__effect:getArg3()

    if not value then
        return true
    end

    local conditionList = string.split(value, " or ")

    local effectList = EffectCheckConst.EffectList

    local isTrue = true

    for i, v in ipairs(conditionList) do
        if tonumber(v) == nil then
            if not effectList[v] then
                isTrue = false
                break
            end
        end
    end

    if isTrue then
        return true
    end

    return false, "arg3值异常，触发效果找不到，arg3:"..tostring(value)
end

return newClass("ParryNoTrigger", {BaseCheck}, ParryNoTrigger)
0000000000000