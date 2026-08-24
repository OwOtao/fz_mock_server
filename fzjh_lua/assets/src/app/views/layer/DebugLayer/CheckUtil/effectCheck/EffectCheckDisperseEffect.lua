local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local DisperseEffect = {}
--[[
    指定驱散
    参数1;arg1
    参数2;arg2
        需要驱散的效果ID，多个用" or "间隔
    参数3;arg3
]]

function DisperseEffect:create(effect)
    local p = DisperseEffect.new()
    p:init(effect)
    return p
end

function DisperseEffect:checkArg2()
    local value = self.__effect:getArg2()

    local conditionList = string.split(value, " or ")

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

    return false, "arg2值异常，效果id填写错误，arg2:"..tostring(value)
end

return newClass("DisperseEffect", {BaseCheck}, DisperseEffect)
0000000