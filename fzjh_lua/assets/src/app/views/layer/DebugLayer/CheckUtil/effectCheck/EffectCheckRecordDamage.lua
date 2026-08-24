local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local RecordDamage = {}
--[[
    记录承受伤害
    参数1;arg1
        记录伤害的 属性参数id recordDamage
    参数2;arg2
    参数3;arg3
]]

function RecordDamage:create(effect)
    local p = RecordDamage.new()
    p:init(effect)
    return p
end

function RecordDamage:checkArg1()
    local value = self.__effect:getArg1()

    if value == "recordDamage" then
        return true
    end

    return false, "arg1值异常，非recordDamage，arg1:"..tostring(value)
end

return newClass("RecordDamage", {BaseCheck}, RecordDamage)
0000