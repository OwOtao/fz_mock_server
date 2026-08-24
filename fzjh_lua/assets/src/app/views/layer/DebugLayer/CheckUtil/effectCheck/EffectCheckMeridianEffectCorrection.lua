local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local Meridian = require("app.models.Meridian.Meridian")
local MeridianEffectCorrection = {}
--[[
    经脉天赋修正
    参数1;arg1
        受影响的经脉印记ID，多个用#间隔
    参数2;arg2
        影响印记的修正系数公式或者值，可以调用z1参数
    参数3;arg3
]]

function MeridianEffectCorrection:create(effect)
    local p = MeridianEffectCorrection.new()
    p:init(effect)
    return p
end

function MeridianEffectCorrection:checkArg1()
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

function MeridianEffectCorrection:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("MeridianEffectCorrection", {BaseCheck}, MeridianEffectCorrection)
000000000000