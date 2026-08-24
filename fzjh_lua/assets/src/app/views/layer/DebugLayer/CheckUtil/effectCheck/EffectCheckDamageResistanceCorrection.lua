local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local DamageResistanceCorrection = {}
--[[
    伤害抗性修正
    参数1;arg1
        atkDamageClass=攻击属性、defDamageClass=防御属性
    参数2;arg2
        影响值或公式（小数），可以调用z1参数
    参数3;arg3
        伤害类型ID
]]

function DamageResistanceCorrection:create(effect)
    local p = DamageResistanceCorrection.new()
    p:init(effect)
    return p
end

function DamageResistanceCorrection:checkArg1()
    local value = self.__effect:getArg1()

    if value == "atkDamageClass" or value == "defDamageClass" then
        return true
    end

    return false, "arg1值异常，非atkDamageClass、defDamageClass，arg1:"..tostring(value)
end

function DamageResistanceCorrection:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

function DamageResistanceCorrection:checkArg3()
    local value = self.__effect:getArg3()

    if tonumber(value) then
        return true
    end

    return false, "arg3值异常，arg3:"..tostring(value)
end

return newClass("DamageResistanceCorrection", {BaseCheck}, DamageResistanceCorrection)
0