local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local AugmentTag = {}
--[[
    增伤标记
    参数1;arg1
        填写增伤标记类型
    参数2;arg2
        效果生效时，目标身上对应的标记增加或减少的数量
    参数3;arg3
        增伤标记最大值，对应主动技能表配置格式中的z3
]]

function AugmentTag:create(effect)
    local p = AugmentTag.new()
    p:init(effect)
    return p
end

function AugmentTag:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end
    
    return false, "arg2值异常，arg2:"..tostring(value)
end

function AugmentTag:checkArg3()
    local value = self:getFinalArg3()

    if tonumber(value) then
        return true
    end
    
    return false, "arg3值异常，arg3:"..tostring(value)
end

return newClass("AugmentTag", {BaseCheck}, AugmentTag)
00000000000