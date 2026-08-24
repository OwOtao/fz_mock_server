local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local HeavyParry = {}
--[[
    强招架
    参数1;arg1
        效果生效次数
    参数2;arg2
        效果添加概率
    参数3;arg3
]]

function HeavyParry:create(effect)
    local p = HeavyParry.new()
    p:init(effect)
    return p
end

function HeavyParry:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end

function HeavyParry:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end


return newClass("HeavyParry", {BaseCheck}, HeavyParry)
00000000