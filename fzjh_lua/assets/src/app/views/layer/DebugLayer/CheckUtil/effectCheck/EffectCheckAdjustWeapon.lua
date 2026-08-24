local newClass = require("third.class.NewClass")
local BaseCheck = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckBaseCheck")
local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local AdjustWeapon = {}
--[[
    修武
    参数1;arg1
        武器属性ID
    参数2;arg2
        影响值或公式（小数），可以调用z1参数
    参数3;arg3
]]

function AdjustWeapon:create(effect)
    local p = AdjustWeapon.new()
    p:init(effect)
    return p
end

function AdjustWeapon:checkArg1()
    local value = self.__effect:getArg1()
    
    local attrList = {
        "weaponDamage", "weaponYindu", "weaponRendu", "weaponWeight", "breakWeapon", "flyWeapon","brokenWeapon", "beflyWeapon"
    }

    if table.keyof(attrList, value) then
        return true
    end

    return false, "arg1值异常，非武器属性，arg1:"..tostring(value)
end

function AdjustWeapon:checkArg2()
    local value = self:getFinalArg2()

    if tonumber(value) then
        return true
    end
    
    return false, "arg2值异常，arg2:"..tostring(value)
end

return newClass("AdjustWeapon", {BaseCheck}, AdjustWeapon)
0000