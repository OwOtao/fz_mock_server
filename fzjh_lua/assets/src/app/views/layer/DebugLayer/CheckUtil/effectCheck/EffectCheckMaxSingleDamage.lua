local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local MaxSingleDamage = {}
--[[
    单次伤害上限
    参数1;arg1
        qi
    参数2;arg2
        伤害上限参数公式或者值，可以调用z1参数
    参数3;arg3
        无效果，默认不配置
]]

function MaxSingleDamage:create(effect)
    local p = MaxSingleDamage.new()
    p:init(effect)
    return p
end

function MaxSingleDamage:checkArg1()
    local value = self.__effect:getArg1()

    if value == "qi" then
        return true
    end

    return false, "arg1值异常，非qi，arg1:"..tostring(value)
end

function MaxSingleDamage:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，公式异常，arg2:"..tostring(value)
end

return newClass("MaxSingleDamage", {BaseCheck}, MaxSingleDamage)
0000000000