local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local Disarm = {}
--[[
    打掉兵器
    参数1;arg1
        概率
    参数2;arg2
    参数3;arg3
]]

function Disarm:create(effect)
    local p = Disarm.new()
    p:init(effect)
    return p
end

function Disarm:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end

return newClass("Disarm", {BaseCheck}, Disarm)
0