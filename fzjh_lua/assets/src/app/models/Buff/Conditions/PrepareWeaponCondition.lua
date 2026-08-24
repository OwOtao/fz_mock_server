--[[
    3 - 自身准备的兵器
        arg1 : 0 表示空手，1 表示一级武器类型，， 2 表示二级武器类型 
        arg2 : 根据arg1 类型填写  如：arg1:1,此处填“刀剑棍...”，arg1:2 此处填“剑;1(代表X剑)”
]]
local BaseBuffCondition = require("app.models.Buff.Conditions.BaseBuffCondition")
--@SuperType [BaseBuffCondition]
local PrepareWeaponCondition = class("PrepareWeaponCondition", BaseBuffCondition)

function PrepareWeaponCondition:create()
    local p = PrepareWeaponCondition:new()
    p:init()
    return p
end

function PrepareWeaponCondition:init()
    self.type = 3
end

function PrepareWeaponCondition:onCheck()
    local role = self.context.role

    local conType = self.arg1

    local currWeaponType

    if conType == 0 then
        currWeaponType = role:getCurrWeaponType()

        if currWeaponType == "拳脚" then
            return true
        end

        return false
    elseif conType == 1 then
        currWeaponType = role:getCurrWeaponType()

        if currWeaponType == self.arg2 then
            return true
        end

        return false

    elseif conType == 2 then
        currWeaponType = role:getCurrWeaponType2()

        if currWeaponType == self.arg2 then
            return true
        end

        return true
    end
end

return PrepareWeaponCondition000000