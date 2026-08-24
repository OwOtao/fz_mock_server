local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local ActiveUseTrigger = {}
--[[
    使用主动技能
    参数1;arg1
        判定成功时生效的效果id
    参数2;arg2
        填“自己/目标”，为【参数1;arg1】字段效果的实际触发者（此处的自己/目标是以该效果的持有者为中心进行判断）
    参数3;arg3
        填“自己/目标”，为【参数1;arg1】字段效果的实际承受者（此处的自己/目标是以该效果的持有者为中心进行判断）
]]

function ActiveUseTrigger:create(effect)
    local p = ActiveUseTrigger.new()
    p:init(effect)
    return p
end

function ActiveUseTrigger:checkArg1()
    local value = self.__effect:getArg1()

    local effectList = EffectCheckConst.EffectList

    if effectList[value] then
        return true
    end

    return false, "arg1值异常，触发效果找不到，arg1:"..tostring(value)
end

function ActiveUseTrigger:checkArg2()
    local value = self.__effect:getArg2()

    if value == EffectCheckConst.EffectTargetValue.Owner or value == EffectCheckConst.EffectTargetValue.Target then
        return true
    end

    return false, "arg2值异常，目标值填写错误，arg2:"..tostring(value)
end

function ActiveUseTrigger:checkArg3()
    local value = self.__effect:getArg3()

    if value == EffectCheckConst.EffectTargetValue.Owner or value == EffectCheckConst.EffectTargetValue.Target then
        return true
    end

    return false, "arg3值异常，目标值填写错误，arg3:"..tostring(value)
end

return newClass("ActiveUseTrigger", {BaseCheck}, ActiveUseTrigger)
00000