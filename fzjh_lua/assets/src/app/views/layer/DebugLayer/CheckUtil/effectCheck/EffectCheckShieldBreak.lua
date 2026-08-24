local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local ShieldBreak = {}
--[[
    主动碎盾
    参数1;arg1
        当“参数2;arg2"中的效果生效时，效果的目标对象
    参数2;arg2
        判定【碎盾】成功时生效的效果id
    参数3;arg3
]]

function ShieldBreak:create(effect)
    local p = ShieldBreak.new()
    p:init(effect)
    return p
end

function ShieldBreak:checkArg1()
    local value = self.__effect:getArg1()

    if value == EffectCheckConst.EffectTargetValue.Owner or value == EffectCheckConst.EffectTargetValue.Target then
        return true
    end

    return false, "arg1值异常，目标值填写错误，arg1:"..tostring(value)
end

function ShieldBreak:checkArg2()
    local value = self.__effect:getArg2()

    local effectList = EffectCheckConst.EffectList

    if effectList[value] then
        return true
    end
    
    return false, "arg2值异常，触发效果找不到，arg2:"..tostring(value)
end

return newClass("ShieldBreak", {BaseCheck}, ShieldBreak)
000000000000