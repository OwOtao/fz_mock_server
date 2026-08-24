local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local AttrChange = {}
--[[
    属性变化
    参数1;arg1
        属性值
    参数2;arg2
        数值或者公式
    参数3;arg3
        伤害类型（可填）
]]

function AttrChange:create(effect)
    local p = AttrChange.new()
    p:init(effect)
    return p
end

function AttrChange:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("AttrChange", {BaseCheck}, AttrChange)
00000000