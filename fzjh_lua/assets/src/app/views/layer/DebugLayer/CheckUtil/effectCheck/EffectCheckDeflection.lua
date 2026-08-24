local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local Deflection = {}
--[[
    偏转
    参数1;arg1
        数值或者公式
    参数2;arg2
    参数3;arg3
]]

function Deflection:create(effect)
    local p = Deflection.new()
    p:init(effect)
    return p
end

function Deflection:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end


return newClass("Deflection", {BaseCheck}, Deflection)
0