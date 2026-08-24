local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local DelayCooldown = {}
--[[
    延宕
    参数1;arg1
    参数2;arg2
        影响值或公式（小数），可以调用z1参数
    参数3;arg3
]]

function DelayCooldown:create(effect)
    local p = DelayCooldown.new()
    p:init(effect)
    return p
end

function DelayCooldown:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end
    
    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("DelayCooldown", {BaseCheck}, DelayCooldown)
0000000000