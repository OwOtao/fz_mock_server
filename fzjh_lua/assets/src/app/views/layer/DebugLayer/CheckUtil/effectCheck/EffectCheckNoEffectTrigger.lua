local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local NoEffectTrigger = {}
--[[
    无指定效果时触发
    参数1;arg1
        效果判断目标（自己/目标）
    参数2;arg2
        判定的指定效果id或指定效果类型（填写多个id时使用“ or ”进行间隔）
    参数3;arg3
        判定成功时生效的效果id
]]

function NoEffectTrigger:create(effect)
    local p = NoEffectTrigger.new()
    p:init(effect)
    return p
end

function NoEffectTrigger:checkArg1()
    local value = self.__effect:getArg1()

    if value == EffectCheckConst.EffectTargetValue.Owner or value == EffectCheckConst.EffectTargetValue.Target then
        return true
    end

    return false, "arg1值异常，目标值填写错误，arg1:"..tostring(value)
end

function NoEffectTrigger:checkArg2()
    local value = self.__effect:getArg2()

    local conditions = string.split(value, " or ")

    local effectList = EffectCheckConst.EffectList

    local isTrue = true

    for i, v in ipairs(conditions) do
        if tonumber(v) == nil then
            if not effectList[v] then
                isTrue = false
                break
            end
        end
    end

    if isTrue then
        return true
    end
    
    return false, "arg2值异常，判断效果找不到，arg2:"..tostring(value)
end

function NoEffectTrigger:checkArg3()
    local value = self.__effect:getArg3()

    local effectList = EffectCheckConst.EffectList

    if effectList[value] then
        return true
    end
    
    return false, "arg3值异常，触发效果找不到，arg3:"..tostring(value)
end

return newClass("NoEffectTrigger", {BaseCheck}, NoEffectTrigger)
000