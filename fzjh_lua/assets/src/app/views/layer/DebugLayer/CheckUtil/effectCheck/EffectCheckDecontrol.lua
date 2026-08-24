local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local Decontrol = {}
--[[
    解控
    参数1;arg1
        属性名 目前只有qi
    参数2;arg2
        值或公式
    参数3;arg3
]]

function Decontrol:create(effect)
    local p = Decontrol.new()
    p:init(effect)
    return p
end

function Decontrol:checkArg1()
    local value = self.__effect:getArg1()

    if value == "qi" then
        return true
    end

    return false, "arg1值异常，非qi，arg1:"..tostring(value)
end

function Decontrol:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("Decontrol", {BaseCheck}, Decontrol)
0000000000