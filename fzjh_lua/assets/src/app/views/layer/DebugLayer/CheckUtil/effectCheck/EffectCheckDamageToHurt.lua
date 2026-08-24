local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local DamageToHurt = {}
--[[
    伤害转持续自伤
    参数1;arg1
        自伤百分比，可以调用z1参数
    参数2;arg2
        伤害转化率，可以调用z3参数
    参数3;arg3
        伤害转化间隔时间调用z3参数(实际未配置，未实现)
]]

function DamageToHurt:create(effect)
    local p = DamageToHurt.new()
    p:init(effect)
    return p
end

function DamageToHurt:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end

function DamageToHurt:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("DamageToHurt", {BaseCheck}, DamageToHurt)
00000000000