local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local AntiPoison = {}
--[[
    抗毒
    参数1;arg1
        生效概率
    参数2;arg2
    参数3;arg3
]]

function AntiPoison:create(effect)
    local p = AntiPoison.new()
    p:init(effect)
    return p
end

function AntiPoison:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end


return newClass("AntiPoison", {BaseCheck}, AntiPoison)
0000000