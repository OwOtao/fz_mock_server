local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local AddDamage = {}
--[[
    追加伤害
    参数1;arg1
        造成伤害的气血百分比，可以调用z1参数
    参数2;arg2
        可记录的伤害上限，可以调用z3参数
    参数3;arg3
]]

function AddDamage:create(effect)
    local p = AddDamage.new()
    p:init(effect)
    return p
end

function AddDamage:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end
    
    return false, "arg1值异常，arg1:"..tostring(value)
end

function AddDamage:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end
    
    return false, "arg2值异常，arg2:"..tostring(value)
end


return newClass("AddDamage", {BaseCheck}, AddDamage)
0000