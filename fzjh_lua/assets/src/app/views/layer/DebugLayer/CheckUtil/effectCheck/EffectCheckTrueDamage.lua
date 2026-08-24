local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local TrueDamage = {}
--[[
    指定抵抗
    参数1;arg1
        需要抵抗的效果ID，多个用#间隔
    参数2;arg2
        数值或者公式
    参数3;arg3
]]

function TrueDamage:create(effect)
    local p = TrueDamage.new()
    p:init(effect)
    return p
end

function TrueDamage:checkArg1()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("TrueDamage", {BaseCheck}, TrueDamage)
000000000