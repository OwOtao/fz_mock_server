local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local DamageReflection = {}
--[[
    反伤
    参数1;arg1
        影响值或公式（小数），可以调用z1参数
    参数2;arg2
    参数3;arg3
]]

function DamageReflection:create(effect)
    local p = DamageReflection.new()
    p:init(effect)
    return p
end

function DamageReflection:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end

return newClass("DamageReflection", {BaseCheck}, DamageReflection)
000000000000