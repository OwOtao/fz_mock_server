local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local AttrMonitor = {}
--[[
    监控角色属性
    参数1;arg1
        值或公式
    参数2;arg2
        效果id#效果id
    参数3;arg3
]]

function AttrMonitor:create(effect)
    local p = AttrMonitor.new()
    p:init(effect)
    return p
end

function AttrMonitor:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end

function AttrMonitor:checkArg2()
    local value = self.__effect:getArg2()

    local effectIds = string.split(value, "#")

    local effectList = EffectCheckConst.EffectList

    local isTrue = true

    for i, effectId in ipairs(effectIds) do
        if effectList[effectId] ~= true then
            isTrue = false
            break
        end
    end

    if isTrue then
        return true
    end

    return false, "arg2值异常，参数中含有不存在的效果id，arg2:"..tostring(value)
end

return newClass("AttrMonitor", {BaseCheck}, AttrMonitor)
00000000000