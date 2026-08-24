local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local Blinding = {}
--[[
    致盲
    参数1;arg1
        效果生效的次数，一般引用“z1”数值，也可以填包含z1的公式
    参数2;arg2
    参数3;arg3
]]

function Blinding:create(effect)
    local p = Blinding.new()
    p:init(effect)
    return p
end

function Blinding:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end


return newClass("Blinding", {BaseCheck}, Blinding)
0000000000000