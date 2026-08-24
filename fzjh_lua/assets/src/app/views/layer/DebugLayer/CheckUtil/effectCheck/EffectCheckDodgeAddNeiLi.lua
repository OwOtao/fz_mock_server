local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local DodgeAddNeiLi = {}
--[[
    闪烁
    参数1;arg1
        属性值，当前只有neili
    参数2;arg2
        值或者公式
    参数3;arg3
]]

function DodgeAddNeiLi:create(effect)
    local p = DodgeAddNeiLi.new()
    p:init(effect)
    return p
end

function DodgeAddNeiLi:checkArg1()
    local value = self.__effect:getArg1()

    if value == "neili" then
        return true
    end

    return false, "arg1值异常，非neili，arg1:"..tostring(value)
end

function DodgeAddNeiLi:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("DodgeAddNeiLi", {BaseCheck}, DodgeAddNeiLi)
0000000000000000