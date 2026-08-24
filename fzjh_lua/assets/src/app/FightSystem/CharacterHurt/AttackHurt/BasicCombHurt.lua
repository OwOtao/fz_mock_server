--[[
    author:Seven
    time:2023-03-24 19:32:02
    desc: 基础攻击招式组合伤害
]]
local newClass = require("third.class.NewClass")

local AAttackHurt = require("app.FightSystem.CharacterHurt.AttackHurt.AAttackHurt")

--@SuperType [src.app.FightSystem.CharacterHurt.AttackHurt.AAttackHurt#AAttackHurt]
local BasicCombHurt = {}

function BasicCombHurt:create(attrName, value, hurt, bypassShield)
    return BasicCombHurt.new():__init(attrName, value, hurt, bypassShield)
end

function BasicCombHurt:__init(attrName, value, hurtDesc, bypassShield)
    self:__setAttrName(attrName)
    self:__setHurtValue(value)
    if hurtDesc ~= nil then
        self:__setHurtDesc(hurtDesc)
    end

    if bypassShield == true then
        self:__setBypassShield(true)
    end

    return self
end

return newClass("BasicCombHurt", {AAttackHurt}, BasicCombHurt)
000000