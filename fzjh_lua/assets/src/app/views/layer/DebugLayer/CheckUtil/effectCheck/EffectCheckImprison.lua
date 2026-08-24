local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local Imprison = {}
--[[
    禁锢
    参数1;arg1
        禁锢/限攻
    参数2;arg2
    参数3;arg3
]]

function Imprison:create(effect)
    local p = Imprison.new()
    p:init(effect)
    return p
end

function Imprison:checkArg1()
    local value = self.__effect:getArg1()

    if value == "禁锢" or value == "限攻" then
        return true
    end

    return false, "arg1值异常，非禁锢/限攻，arg1:"..tostring(value)
end

return newClass("Imprison", {BaseCheck}, Imprison)
000000