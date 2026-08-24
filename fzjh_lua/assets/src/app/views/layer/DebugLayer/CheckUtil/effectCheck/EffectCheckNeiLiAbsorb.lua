local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local NeiLiAbsorb = {}
--[[
    汲取
    参数1;arg1
        属性名，目前只有neili
    参数2;arg2
        值或公式
    参数3;arg3
        值或公式
]]

function NeiLiAbsorb:create(effect)
    local p = NeiLiAbsorb.new()
    p:init(effect)
    return p
end

function NeiLiAbsorb:checkArg1()
    local value = self.__effect:getArg1()

    if value == "neili" then
        return true
    end

    return false, "arg1值异常，非neili，arg1:"..tostring(value)
end

function NeiLiAbsorb:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

function NeiLiAbsorb:checkArg3()
    local value = self:getFinalArg3()

    if tonumber(value) then
        return true
    end

    return false, "arg3值异常，arg3:"..tostring(value)
end

return newClass("NeiLiAbsorb", {BaseCheck}, NeiLiAbsorb)
0000000000000000