local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local DodgeAddQi = {}
--[[
    闪耀
    参数1;arg1
        属性值，当前只有qi
    参数2;arg2
        值或者公式
    参数3;arg3
]]

function DodgeAddQi:create(effect)
    local p = DodgeAddQi.new()
    p:init(effect)
    return p
end

function DodgeAddQi:checkArg1()
    local value = self.__effect:getArg1()

    if value == "qi" then
        return true
    end

    return false, "arg1值异常，非qi，arg1:"..tostring(value)
end

function DodgeAddQi:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("DodgeAddQi", {BaseCheck}, DodgeAddQi)
00000000000000