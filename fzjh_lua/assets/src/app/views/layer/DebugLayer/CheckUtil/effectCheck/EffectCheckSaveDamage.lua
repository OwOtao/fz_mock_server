local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local SaveDamage = {}
--[[
    储伤：
    参数1;arg1
        支持配置 参数z1 或者 小数
    参数2;arg2
        气血伤害来源#类型转化比例，可配置多组，用 | 间隔
        气血伤害来源配置：autoHurt、activeHurt
        类型转化比例，最多4位小数，支持配置参数z3
    参数3;arg3
        无效果，默认不配置
]]

function SaveDamage:create(effect)
    local p = SaveDamage.new()
    p:init(effect)
    return p
end

function SaveDamage:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) or value == "z1" then
        return true
    end

    return false, "arg1值异常，非数字或者z1，arg1:"..tostring(value)
end

function SaveDamage:checkArg2()
    local value = self.__effect:getArg2()

    local strList = string.split(value, "|")

    local isTrue = true

    for i,v in ipairs(strList) do

        local saveList = string.split(v, "#")

        if saveList[1] ~= "activeHurt" and saveList[1] ~= "autoHurt" then
            isTrue = false
            break
        end

        if tonumber(saveList[2]) == nil and saveList[2] ~= "z3" then
            isTrue = false
            break
        end
    end

    if isTrue then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("SaveDamage", {BaseCheck}, SaveDamage)
000000000