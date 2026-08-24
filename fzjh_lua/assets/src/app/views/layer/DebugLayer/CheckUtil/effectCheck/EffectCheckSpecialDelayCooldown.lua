local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local SpecialDelayCooldown = {}
--[[
    指定延宕
    参数1;arg1
    参数2;arg2
        技能冷却时长增加或减少的时长
    参数3;arg3
        可影响的主动技能id
]]

function SpecialDelayCooldown:create(effect)
    local p = SpecialDelayCooldown.new()
    p:init(effect)
    return p
end

function SpecialDelayCooldown:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

function SpecialDelayCooldown:checkArg3()
    local value = self.__effect:getArg3()

    if Skill:getActiveZhao(value) then
        return true
    end

    return false, "arg3值异常，arg3:"..tostring(value)
end

return newClass("SpecialDelayCooldown", {BaseCheck}, SpecialDelayCooldown)
00