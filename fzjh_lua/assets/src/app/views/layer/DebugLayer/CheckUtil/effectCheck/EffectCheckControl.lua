local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local Control = {}
--[[
    控制
    参数1;arg1
        控制类型 定身、迷惑、瘫痪、晕迷
    参数2;arg2
        值或公式（定身、迷惑受到一定攻击后会解控）
    参数3;arg3
]]

function Control:create(effect)
    local p = Control.new()
    p:init(effect)
    return p
end

function Control:checkArg1()
    local value = self.__effect:getArg1()

    if value == "晕迷" or value == "瘫痪" or value == "迷惑" or value == "定身" then
        return true
    end

    return false, "arg1值异常，非定身、迷惑、瘫痪、晕迷，arg1:"..tostring(value)
end

function Control:checkArg2()
    local controlType = self.__effect:getArg1()

    if controlType == "晕迷" or controlType == "瘫痪" then
        return true
    end

    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("Control", {BaseCheck}, Control)
0000000000