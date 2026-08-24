local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local DelayedEffect = {}
--[[
    延时生效
    参数1;arg1
        效果id
    参数2;arg2
    参数3;arg3
]]

function DelayedEffect:create(effect)
    local p = DelayedEffect.new()
    p:init(effect)
    return p
end

function DelayedEffect:checkArg1()
    local value = self.__effect:getArg1()

    local effectList = EffectCheckConst.EffectList

    if effectList[value] then
        return true
    end
    
    return false, "arg1值异常，触发效果找不到，arg1:"..tostring(value)
end

return newClass("DelayedEffect", {BaseCheck}, DelayedEffect)
0000000000000