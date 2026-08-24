local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local TypeTransfer = {}
--[[
    类型转移
    参数1;arg1
        需要转移的效果类型，多个用#间隔
    参数2;arg2
        转移数量，可以调用z1参数
    参数3;arg3
        转移获取效果的角色类型（自己/目标）
]]

function TypeTransfer:create(effect)
    local p = TypeTransfer.new()
    p:init(effect)
    return p
end

function TypeTransfer:checkArg1()
    local value = self.__effect:getArg1() 

    local typeList = string.split(value, "#")

    local isTrue = true

    for i, v in ipairs(typeList) do
        if tonumber(v) == nil then
            isTrue = false
            break
        end
    end

    if isTrue then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end

function TypeTransfer:checkArg2()
    local value = self:getFinalArg2() 

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

function TypeTransfer:checkArg3()
    local value = self.__effect:getArg3()

    if value == EffectCheckConst.EffectTargetValue.Owner or value == EffectCheckConst.EffectTargetValue.Target then
        return true
    end

    return false, "arg3值异常，目标值填写错误，arg3:"..tostring(value)
end


return newClass("TypeTransfer", {BaseCheck}, TypeTransfer)
000