local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local FragileTag = {}
--[[
    易伤标记
    参数1;arg1
        填写易伤标记类型
    参数2;arg2
        效果生效时，目标身上对应的标记增加或减少的数量
    参数3;arg3
        易伤标记最大值，对应主动技能表配置格式中的z3
]]

function FragileTag:create(effect)
    local p = FragileTag.new()
    p:init(effect)
    return p
end

function FragileTag:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end
    
    return false, "arg2值异常，arg2:"..tostring(value)
end

function FragileTag:checkArg3()
    local value = self:getFinalArg3()

    if tonumber(value) then
        return true
    end
    
    return false, "arg3值异常，arg3:"..tostring(value)
end

return newClass("FragileTag", {BaseCheck}, FragileTag)
00000000000