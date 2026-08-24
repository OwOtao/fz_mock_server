local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local RecoveryCorrection = {}
--[[
    恢复修正
    参数1;arg1
        属性名;属性名 目前只有qi，neili
    参数2;arg2
        值或公式
    参数3;arg3
]]

function RecoveryCorrection:create(effect)
    local p = RecoveryCorrection.new()
    p:init(effect)
    return p
end

function RecoveryCorrection:checkArg1()
    local value = self.__effect:getArg1()

    local valueMap = string.split(value, ";")

    local isTrue = true

    for i, v in ipairs(valueMap) do
        if v ~= "qi" and v ~= "neili" then
            isTrue = false
            break
        end
    end

    if isTrue then
        return true
    end

    return false, "arg1值异常，非qi和neili其他属性，arg1:"..tostring(value)
end

function RecoveryCorrection:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("RecoveryCorrection", {BaseCheck}, RecoveryCorrection)
00