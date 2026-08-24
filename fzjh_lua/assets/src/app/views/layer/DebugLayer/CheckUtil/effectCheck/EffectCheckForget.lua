local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local Forget = {}
--[[
    遗忘
    参数1;arg1
        触发概率
    参数2;arg2
    参数3;arg3
]]

function Forget:create(effect)
    local p = Forget.new()
    p:init(effect)
    return p
end

function Forget:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end
    
    return false, "arg1值异常，arg1:"..tostring(value)
end

return newClass("Forget", {BaseCheck}, Forget)
0000000000000