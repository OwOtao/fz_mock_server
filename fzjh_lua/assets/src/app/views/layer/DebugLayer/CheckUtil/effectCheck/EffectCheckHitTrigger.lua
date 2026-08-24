local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local HitTrigger = {}
--[[
    受击触发
    参数1;arg1
        当“参数2;arg2”中的效果生效时，效果的目标对象,填“自己/目标”
    参数2;arg2
        当效果持有者受被动攻击命中时生效的效果ID
    参数3;arg3
]]

function HitTrigger:create(effect)
    local p = HitTrigger.new()
    p:init(effect)
    return p
end

function HitTrigger:checkArg1()
    local value = self.__effect:getArg1()

    if value == EffectCheckConst.EffectTargetValue.Owner or value == EffectCheckConst.EffectTargetValue.Target then
        return true
    end

    return false, "arg1值异常，目标值填写错误，arg1:"..tostring(value)
end

function HitTrigger:checkArg2()
    local value = self.__effect:getArg2()

    local effectList = EffectCheckConst.EffectList

    if effectList[value] then
        return true
    end

    return false, "arg2值异常，触发效果找不到，arg2:"..tostring(value)
end

return newClass("HitTrigger", {BaseCheck}, HitTrigger)
000000000000000