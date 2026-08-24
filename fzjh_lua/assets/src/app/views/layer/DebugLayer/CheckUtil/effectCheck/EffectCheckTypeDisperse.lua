local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local TypeDisperse = {}
--[[
    类型驱散
    参数1;arg1
        需要驱散的效果类型，多个用#间隔
    参数2;arg2
    参数3;arg3
]]

function TypeDisperse:create(effect)
    local p = TypeDisperse.new()
    p:init(effect)
    return p
end

function TypeDisperse:checkArg1()
    local value = self.__effect:getArg1() 

    local typeList = string.split(value, "#")

    local isTrue = true

    for i, v in ipairs(typeList) do
        if tonumber(v) == nil then
            isTrue = false
            break
        end
    end

    if isTrue then
        return true
    end

    return false, "arg1值异常，arg1:"..tostring(value)
end


return newClass("TypeDisperse", {BaseCheck}, TypeDisperse)
00000000000