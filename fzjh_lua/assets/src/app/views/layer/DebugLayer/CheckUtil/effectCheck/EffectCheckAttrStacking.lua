local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local AttrStacking = {}
--[[
    属性叠加
    参数1;arg1
        增减的标记类属性ID
    参数2;arg2
        属性增减值计算公式，可以调用z1~z3参数
    参数3;arg3
        属性叠加最大值，可以调用z1~z3参数
]]

function AttrStacking:create(effect)
    local p = AttrStacking.new()
    p:init(effect)
    return p
end

function AttrStacking:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

function AttrStacking:checkArg3()
    local value = self:getFinalArg3()

    if tonumber(value) then
        return true
    end

    return false, "arg3值异常，arg3:"..tostring(value)
end

return newClass("AttrStacking", {BaseCheck}, AttrStacking)
00000