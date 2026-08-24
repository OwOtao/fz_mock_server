local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local NeiliDamage = {}
--[[
    内伤
    参数1;arg1
        内伤
    参数2;arg2
        加力值额外数值
    参数3;arg3
]]

function NeiliDamage:create(effect)
    local p = NeiliDamage.new()
    p:init(effect)
    return p
end

function NeiliDamage:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end


return newClass("NeiliDamage", {BaseCheck}, NeiliDamage)
00000000