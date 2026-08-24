--[[
    author:Seven
    time:2024-01-13 17:43:21
    desc: 用于效果造成属性变化的统计
]]
local newClass = require("third.class.NewClass")

local EffectModifierResultCount = {}

function EffectModifierResultCount:create()
    return EffectModifierResultCount.new()
end

function EffectModifierResultCount:ctor()
    self.__changeMap = {}
end

--@effectModifierAttr: [src.app.FightSystem.CharacterHurt.BuffEffectHurt.ABuffEffectModifierAttr#ABuffEffectModifierAttr]
function EffectModifierResultCount:addModifierAttr(effectModifierAttr)
    --@desc 效果目标id
    local effectTargetId = effectModifierAttr:getCharacterId()

    local value = effectModifierAttr:getHurtValue()

    local attrName = effectModifierAttr:getAttrName()

    local effectId = effectModifierAttr:getEffectId()

    local ownerId = effectModifierAttr:getOwnerId()

    self:__recordAttrChange(effectTargetId, effectId, attrName, ownerId, value)
end

function EffectModifierResultCount:__recordAttrChange(effectTargetId, effectId, attrName, buffOwnerId, value)
    local keyStr = string.format("%s|%s|%s|%s", effectTargetId, effectId, buffOwnerId, attrName)

    if self.__changeMap[keyStr] ~= nil then
        value = value + self.__changeMap[keyStr]
    end

    self.__changeMap[keyStr] = value
end

function EffectModifierResultCount:walkModifierCount(func)
    if MapIsEmpty(self.__changeMap) then
        return {}
    end

    for keyStr, value in pairs(self.__changeMap) do
        local c_id, effectId, ownerId, attrName = unpack(string.split(keyStr, "|"))
        func(c_id, effectId, ownerId, attrName, value)
    end
end

return newClass("EffectModifierResultCount", {}, EffectModifierResultCount)
0000