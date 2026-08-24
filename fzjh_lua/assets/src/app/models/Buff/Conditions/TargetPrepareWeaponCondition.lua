local BaseBuffCondition = require("app.models.Buff.Conditions.BaseBuffCondition")
--@SuperType [BaseBuffCondition]
local TargetPrepareWeaponCondition = class("TargetPrepareWeaponCondition", BaseBuffCondition)

function TargetPrepareWeaponCondition:create()
    local p = TargetPrepareWeaponCondition:new()
    p:init()
    return p
end

function TargetPrepareWeaponCondition:init()
    self.type = 4
end

function TargetPrepareWeaponCondition:check(context)
    local target = context.target

    local conType = self.arg1

    local currWeaponType

    if conType == 0 then
        currWeaponType = target:getCurrWeaponType()

        if currWeaponType == "拳脚" then
            return true
        end

        return false
    elseif conType == 1 then
        currWeaponType = target:getCurrWeaponType()

        if currWeaponType == self.arg2 then
            return true
        end

        return false
    elseif conType == 2 then
        currWeaponType = target:getCurrWeaponType2()

        if currWeaponType == self.arg2 then
            return true
        end

        return true
    end
end

return TargetPrepareWeaponCondition0000000