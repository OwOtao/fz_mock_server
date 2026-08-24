local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local CooldownChange = {}
--[[
    冷却变化
    参数1;arg1
        冷却变化的主动类型，对应主动技能类别;type，多个用#间隔
    参数2;arg2
        冷却变化参数公式或者值，可以调用z1参数
    参数3;arg3
        主动剩余冷却时间上限（单位秒）。填cd代表主动默认冷却时间。填数值和公式代表具体值。公式可以调用z1~z3参数
]]

function CooldownChange:create(effect)
    local p = CooldownChange.new()
    p:init(effect)
    return p
end

function CooldownChange:checkArg1()
    local value = self.__effect:getArg1() 

    local typeList = string.split(value, "#")

    local isTrue = true

    for i, v in ipairs(typeList) do
        if v ~= "攻击" and v ~= "释放" then
            isTrue = false
            break
        end
    end

    if isTrue then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end

function CooldownChange:checkArg2()
    local value = self:getFinalArg2() 

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

function CooldownChange:checkArg3()
    local value = self.__effect:getArg3()

    if value == "cd" then
        return true
    end

    local value = self:getFinalArg3() 

    if tonumber(value) then
        return true
    end

    return false, "arg3值异常，arg3:"..tostring(value)
end


return newClass("CooldownChange", {BaseCheck}, CooldownChange)
000000000