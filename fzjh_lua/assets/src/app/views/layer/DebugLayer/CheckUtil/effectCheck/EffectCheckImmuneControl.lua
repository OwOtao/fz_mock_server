local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local ImmuneControl = {}
--[[
    免疫控制
    参数1;arg1
        生效概率
    参数2;arg2
    参数3;arg3
]]

function ImmuneControl:create(effect)
    local p = ImmuneControl.new()
    p:init(effect)
    return p
end

function ImmuneControl:checkArg1()
    local value = self:getFinalArg1()

    if tonumber(value) then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end


return newClass("ImmuneControl", {BaseCheck}, ImmuneControl)
000000000000000