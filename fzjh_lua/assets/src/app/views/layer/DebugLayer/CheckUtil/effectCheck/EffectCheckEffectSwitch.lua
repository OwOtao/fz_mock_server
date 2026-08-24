local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local EffectSwitch = {}
--[[
    效果切换
    参数1;arg1
        效果id
    参数2;arg2
        数值或者公式
    参数3;arg3
        效果id
]]

function EffectSwitch:create(effect)
    local p = EffectSwitch.new()
    p:init(effect)
    return p
end

function EffectSwitch:checkArg1()
    local value = self.__effect:getArg1()

    local effectList = EffectCheckConst.EffectList

    if effectList[value] then
        return true
    end

    return false, "arg1值异常，效果找不到，arg1:"..tostring(value)
end

function EffectSwitch:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end
    
    return false, "arg2值异常，arg2:"..tostring(value)
end

function EffectSwitch:checkArg3()
    local value = self.__effect:getArg3()

    local effectList = EffectCheckConst.EffectList

    if effectList[value] then
        return true
    end
    
    return false, "arg3值异常，效果找不到，arg3:"..tostring(value)
end

return newClass("EffectSwitch", {BaseCheck}, EffectSwitch)
0