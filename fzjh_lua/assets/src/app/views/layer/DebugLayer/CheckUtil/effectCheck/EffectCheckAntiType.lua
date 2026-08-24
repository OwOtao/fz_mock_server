local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local AntiType = {}
--[[
    类型抵抗
    参数1;arg1
        需要抵抗的效果类型，多个用#间隔
    参数2;arg2
    参数3;arg3
]]

function AntiType:create(effect)
    local p = AntiType.new()
    p:init(effect)
    return p
end

function AntiType:checkArg1()
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


return newClass("AntiType", {BaseCheck}, AntiType)
0000