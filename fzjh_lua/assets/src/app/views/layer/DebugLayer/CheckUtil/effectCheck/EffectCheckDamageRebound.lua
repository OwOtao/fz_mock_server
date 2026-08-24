local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local DamageRebound = {}
--[[
    反弹
    参数1;arg1
        固定qi
    参数2;arg2
        影响值或公式（小数），可以调用z1参数
    参数3;arg3
        无效果，默认不配置
]]

function DamageRebound:create(effect)
    local p = DamageRebound.new()
    p:init(effect)
    return p
end

function DamageRebound:checkArg1()
    local value = self.__effect:getArg1()

    if value == "qi" then
        return true
    end

    return false, "arg1值异常，非qi，arg1:"..tostring(value)
end

function DamageRebound:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("DamageRebound", {BaseCheck}, DamageRebound)
0000000000000000