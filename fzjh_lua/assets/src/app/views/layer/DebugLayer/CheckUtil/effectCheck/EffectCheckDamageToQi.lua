local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local DamageToQi = {}
--[[
    伤害转气血
    参数1;arg1
        恢复的气血百分比，可以调用z1参数
    参数2;arg2
        可记录的伤害上限，可以调用z3参数
    参数3;arg3
        记录的伤害类型（判断多个类型时用【#】进行链接）
]]

function DamageToQi:create(effect)
    local p = DamageToQi.new()
    p:init(effect)
    return p
end

function DamageToQi:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end

function DamageToQi:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

function DamageToQi:checkArg3()
    local value = self.__effect:getArg3()

    local typeList = string.split(value, "#")

    local isTrue = true

    for i, v in ipairs(typeList) do
        if tonumber(v) == nil then
            isTrue = false
            break
        end
    end

    if isTrue then
        return true
    end

    return false, "arg3值异常，arg3:"..tostring(value)
end

return newClass("DamageToQi", {BaseCheck}, DamageToQi)
000000000