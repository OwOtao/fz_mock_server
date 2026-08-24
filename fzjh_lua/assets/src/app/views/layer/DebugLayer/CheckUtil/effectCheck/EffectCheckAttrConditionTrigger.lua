local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local AttrConditionTrigger = {}
--[[
    属性条件触发
    参数1;arg1
        触发结果 1 成功 0 失败
    参数2;arg2
        若“arg1”中输出的结果为1时生效该字段对应的效果id
    参数3;arg3
]]

function AttrConditionTrigger:create(effect)
    local p = AttrConditionTrigger.new()
    p:init(effect)
    return p
end

function AttrConditionTrigger:checkArg1()
    local value = self:getFinalArg1()

    if value == 1 or value == 0 then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end

function AttrConditionTrigger:checkArg2()
    local value = self.__effect:getArg2()

    local effectList = EffectCheckConst.EffectList

    if effectList[value] then
        return true
    end

    return false, "arg2值异常，触发效果找不到，arg2:"..tostring(value)
end

return newClass("AttrConditionTrigger", {BaseCheck}, AttrConditionTrigger)
00000000000000