local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local NeiliSave = {}
--[[
    内省
    参数1;arg1
        内省
    参数2;arg2
        内力减少数值
    参数3;arg3
]]

function NeiliSave:create(effect)
    local p = NeiliSave.new()
    p:init(effect)
    return p
end

function NeiliSave:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end


return newClass("NeiliSave", {BaseCheck}, NeiliSave)
0000000