local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local AttrBuff = {}
--[[
    属性增益
    参数1;arg1
        属性系数或者属性名
    参数2;arg2
        数值或者公式
    参数3;arg3
        伤害类型（可填）
]]

function AttrBuff:create(effect)
    local p = AttrBuff.new()
    p:init(effect)
    return p
end

function AttrBuff:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("AttrBuff", {BaseCheck}, AttrBuff)
00