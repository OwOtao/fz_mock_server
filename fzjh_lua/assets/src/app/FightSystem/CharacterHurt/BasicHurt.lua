--[[
    author:Seven
    time:2023-2-7 16:06:23
    desc: 基础伤害类
]]
local class = require("third.class.NewClass")

local ABasicHurt = require("app.FightSystem.CharacterHurt.ABasicHurt")

--@SuperType [src.app.FightSystem.CharacterHurt.ABasicHurt#ABasicHurt]
local BasicHurt = {}

function BasicHurt:create(attrName, value)
    return BasicHurt.new():__init(attrName, value)
end

function BasicHurt:__init(attrName, value)
    self:__setAttrName(attrName)
    self:__setHurtValue(value)
    return self
end

return class("BasicHurt", {ABasicHurt}, BasicHurt)
0