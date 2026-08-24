local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local ZhenGang = {}
--[[
    真罡
    参数1;arg1
    参数2;arg2
        数值或者公式
    参数3;arg3
]]

function ZhenGang:create(effect)
    local p = ZhenGang.new()
    p:init(effect)
    return p
end

function ZhenGang:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("ZhenGang", {BaseCheck}, ZhenGang)
000000000000000