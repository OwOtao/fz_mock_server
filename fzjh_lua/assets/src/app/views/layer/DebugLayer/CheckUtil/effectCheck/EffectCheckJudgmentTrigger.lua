local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local JudgmentTrigger = {}
--[[
    效果判断触发
    参数1;arg1 判断条件目标（自己/目标）
    参数2;arg2 判断条件参数（效果ID、效果类型、CHIXIE、KONGSHOU）
    参数3;arg3 添加的新效果ID
    参数4;arg4 判断方式（有/没有）
]]

function JudgmentTrigger:create(effect)
    local p = JudgmentTrigger.new()
    p:init(effect)
    return p
end

function JudgmentTrigger:checkArg1()
    local value = self.__effect:getArg1()

    if value == EffectCheckConst.EffectTargetValue.Owner or value == EffectCheckConst.EffectTargetValue.Target then
        return true
    end

    return false, "arg1值异常，目标值填写错误，arg1:"..tostring(value)
end

function JudgmentTrigger:checkArg2()
    local value = self.__effect:getArg2()

    if not value then
        return false, "arg2值不存在，arg2:"..tostring(value)
    end

    if string.find(value, " or ") and string.find(value, " and ") then
        return false, "arg2值异常，同时存在 or 与 and，arg2:"..tostring(value)
    end

    local valueMap = {}

    if string.find(value, " or ") then
        valueMap = string.split(value, " or ")
    elseif string.find(value, " and ") then
        valueMap = string.split(value, " and ")
    else
        table.insert(valueMap, value)
    end

    for i, v in ipairs(valueMap) do
        local _value = string.split(v, "#")

        if _value[1] == "id" then
            local effectList = EffectCheckConst.EffectList

            if not effectList[_value[2]] then
                return false, "arg2值异常，效果id异常，arg2:"..tostring(value)
            end
        end

        if _value[1] == "class" then
            if not tonumber[_value[2]] then
                return false, "arg2值异常，效果类型异常，arg2:"..tostring(value)
            end
        end

        if _value[1] == "wq" then
            if _value[2] ~= "CHIXIE" and _value[2] ~= "KONGSHOU" then
                return false, "arg2值异常，武器类型异常，arg2:"..tostring(value)
            end
        end
    end

    return true
end
function JudgmentTrigger:checkArg3()
    local value = self.__effect:getArg3()

    local effectList = EffectCheckConst.EffectList

    if effectList[value] then
        return true
    end

    return false, "arg3值异常，触发效果找不到，arg3:"..tostring(value)
end

function JudgmentTrigger:checkArg4()
    local value = self.__effect:getArg4()

    if value == "有" or value == "没有" then
        return true
    end

    return false, "arg4值异常，判断方式填写错误，arg4:"..tostring(value)
end

return newClass("JudgmentTrigger", {BaseCheck}, JudgmentTrigger)
000000000