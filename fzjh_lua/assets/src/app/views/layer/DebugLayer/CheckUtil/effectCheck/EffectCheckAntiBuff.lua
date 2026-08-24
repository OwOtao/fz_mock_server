local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local AntiBuff = {}
--[[
    抗增益
    参数1;arg1
        生效概率
    参数2;arg2
    参数3;arg3
]]

function AntiBuff:create(effect)
    local p = AntiBuff.new()
    p:init(effect)
    return p
end

function AntiBuff:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end


return newClass("AntiBuff", {BaseCheck}, AntiBuff)
0000000000000000