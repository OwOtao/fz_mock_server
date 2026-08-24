local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local WeightRandomTrigger = {}
--[[
    加权随机触发
    参数1;arg1 效果ID#权值|效果ID#权值；可配置多组
    参数2;arg2 配置整数，如果配置成小数则向下取整
    参数3;arg3
]]

function WeightRandomTrigger:create(effect)
    local p = WeightRandomTrigger.new()
    p:init(effect)
    return p
end

function WeightRandomTrigger:checkArg1()
    local value = self.__effect:getArg1()

    local groups = string.split(value, "|")

    local isTrue = true

    local effectList = EffectCheckConst.EffectList

    for i,v in ipairs(groups) do
        local groupData = string.split(v, "#") 
        if not effectList[groupData[1]] then
            isTrue = false
            break
        end

        if not tonumber(groupData[2]) then
            isTrue = false
            break
        end
    end

    if isTrue then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end

function WeightRandomTrigger:checkArg2()
    local value = self.__effect:getArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("WeightRandomTrigger", {BaseCheck}, WeightRandomTrigger)
000