local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local TagTrigger = {}
--[[
    标记触发：
    参数1;arg1
        当满足条件时生效的效果ID
    参数2;arg2
        效果生效的次数，一般引用“z3”数值
    参数3;arg3
        无效果，默认不配置
]]

function TagTrigger:create(effect)
    local p = TagTrigger.new()
    p:init(effect)
    return p
end

function TagTrigger:checkArg1()
    local value = self.__effect:getArg1()

    local effectList = EffectCheckConst.EffectList

    if effectList[value] then
        return true
    end

    return false, "arg1值异常，触发效果找不到，arg1:"..tostring(value)
end

function TagTrigger:checkArg2()
    local value = self.__effect:getArg2()

    if tonumber(value) or value == "z3" then
        return true
    end

    return false, "arg2值异常，非数字或者z3，arg2:"..tostring(value)
end

return newClass("TagTrigger", {BaseCheck}, TagTrigger)
0