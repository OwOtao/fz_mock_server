local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local AntiEffect = {}
--[[
    指定抵抗
    参数1;arg1
        需要抵抗的效果ID，多个用#间隔
    参数2;arg2
    参数3;arg3
]]

function AntiEffect:create(effect)
    local p = AntiEffect.new()
    p:init(effect)
    return p
end

function AntiEffect:checkArg1()
    local value = self.__effect:getArg1()

    local conditionList = string.split(value, "#")

    local effectList = EffectCheckConst.EffectList

    local isTrue = true

    for i, v in ipairs(conditionList) do
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

    return false, "arg1值异常，效果id填写错误，arg1:"..tostring(value)
end

return newClass("AntiEffect", {BaseCheck}, AntiEffect)
0000000