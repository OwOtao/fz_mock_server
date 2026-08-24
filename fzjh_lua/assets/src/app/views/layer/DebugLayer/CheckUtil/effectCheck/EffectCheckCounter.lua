local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local Counter = {}
--[[
    破招
    参数1;arg1
        属性值，目前是只支持tili
    参数2;arg2
        数值或者公式
    参数3;arg3
]]

function Counter:create(effect)
    local p = Counter.new()
    p:init(effect)
    return p
end

function Counter:checkArg1()
    local value = self.__effect:getArg1()

    if value == "tili" then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end

function Counter:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end


return newClass("Counter", {BaseCheck}, Counter)
000000000000