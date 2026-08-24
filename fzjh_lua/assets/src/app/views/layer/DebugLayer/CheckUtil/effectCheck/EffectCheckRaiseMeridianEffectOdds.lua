local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local Meridian = require("app.models.Meridian.Meridian")
local RaiseMeridianEffectOdds = {}
--[[
    拳脚经脉增强
    参数1;arg1
        影响的经脉天赋ID，多个用#间隔
    参数2;arg2
        对应影响的经脉天赋概率，多个用#间隔，可以调用z3参数
    参数3;arg3
        效果持续次数，可以调用z1参数
]]

function RaiseMeridianEffectOdds:create(effect)
    local p = RaiseMeridianEffectOdds.new()
    p:init(effect)
    return p
end

function RaiseMeridianEffectOdds:checkArg1()
    local value = self.__effect:getArg1()

    local imprintingIds = string.split(value, "#")

    local isTrue = true

    for i, v in ipairs(imprintingIds) do
        local imprinting = Meridian:getImprintingId(v)

        if not imprinting then
            isTrue = false
            break
        end
    end

    if isTrue then
        return true
    end

    return false, "arg1值异常，非经脉天赋印记，arg1:"..tostring(value)
end

function RaiseMeridianEffectOdds:checkArg2()
    local value = self.__effect:getArg2()

    local oddsList = string.split(value, "#")

    local isTrue = true

    for i, v in ipairs(oddsList) do
        if tonumber(v) == nil then
            isTrue = false
            break
        end
    end

    if isTrue then
        return true
    end

    return false, "arg2值异常，非概率数值，arg2:"..tostring(value)
end

function RaiseMeridianEffectOdds:checkArg3()
    local value = self:getFinalArg3()

    if tonumber(value) then
        return true
    end

    return false, "arg3值异常，arg3:"..tostring(value)
end

return newClass("RaiseMeridianEffectOdds", {BaseCheck}, RaiseMeridianEffectOdds)
000000000