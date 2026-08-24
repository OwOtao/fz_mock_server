local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local Shield = {}
--[[
    护盾
    参数1;arg1
        值或公式
    参数2;arg2
        颜色
    参数3;arg3
        无效果，默认不配置
]]

function Shield:create(effect)
    local p = Shield.new()
    p:init(effect)
    return p
end

function Shield:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end

return newClass("Shield", {BaseCheck}, Shield)
000000000000