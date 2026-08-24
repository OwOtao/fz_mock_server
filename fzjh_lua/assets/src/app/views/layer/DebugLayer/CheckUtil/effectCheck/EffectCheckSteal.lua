local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local Steal = {}
--[[
    窃取
    参数1;arg1
        窃取增益效果的数量
    参数2;arg2
    参数3;arg3
]]

function Steal:create(effect)
    local p = Steal.new()
    p:init(effect)
    return p
end

function Steal:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end

return newClass("Steal", {BaseCheck}, Steal)
00000000