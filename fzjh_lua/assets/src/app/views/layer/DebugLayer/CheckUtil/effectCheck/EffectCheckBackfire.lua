local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local Backfire = {}
--[[
    反噬
    参数1;arg1
        属性名，目前只有qi，效果生效未筛选，文档定义上应该只有伤害
    参数2;arg2
        值或公式
    参数3;arg3
]]

function Backfire:create(effect)
    local p = Backfire.new()
    p:init(effect)
    return p
end

function Backfire:checkArg1()
    local value = self.__effect:getArg1()

    if value == "qi" then
        return true
    end

    return false, "arg1值异常，非qi，arg1:"..tostring(value)
end

function Backfire:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end

    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("Backfire", {BaseCheck}, Backfire)
000