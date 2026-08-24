local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local UnloadForce = {}
--[[
    卸力
    参数1;arg1
    参数2;arg2
        数值或者公式
    参数3;arg3
]]

function UnloadForce:create(effect)
    local p = UnloadForce.new()
    p:init(effect)
    return p
end

function UnloadForce:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end
    
    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("UnloadForce", {BaseCheck}, UnloadForce)
000000000