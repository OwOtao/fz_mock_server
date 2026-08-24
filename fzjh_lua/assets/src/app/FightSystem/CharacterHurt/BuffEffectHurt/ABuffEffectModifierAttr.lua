--[[
    author:Seven
    time:2023-03-19 17:12:42
    desc: 效果直接伤害基础类
]]
local newClass = require("third.class.NewClass")

local ABasicHurt = require("app.FightSystem.CharacterHurt.ABasicHurt")

--@SuperType [src.app.FightSystem.CharacterHurt.ABasicHurt#ABasicHurt]
local ABuffEffectModifierAttr = {}

function ABuffEffectModifierAttr:initEffectHurt(effectId, attrName, value, ownerId)
    self:__setEffectId(effectId)
    self:__setAttrName(attrName)
    self:__setHurtValue(value)
    self:__setOwnerId(ownerId)
    return self
end

function ABuffEffectModifierAttr:__setOwnerId(ownerId)
    self.__ownerId = ownerId
end

function ABuffEffectModifierAttr:getOwnerId()
    return self.__ownerId
end

--@desc: 添加效果id
--@author:Seven
--@time:2023-03-19 20:08:03
--@effectId: 效果id
function ABuffEffectModifierAttr:__setEffectId(effectId)
    self.__effectId = effectId
end

function ABuffEffectModifierAttr:getEffectId()
    if self.__effectId == nil then
        error("ABuffEffectModifierAttr:getEffectId 效果id为空，检查代码流程")
    end

    return self.__effectId
end

function ABuffEffectModifierAttr:getCharacterId()
    if self.__characterId == nil then
        error("ABuffEffectModifierAttr:getCharacterId : 作用角色id为空，检查该对象是否未执行doAttack方法")
    end

    return self.__characterId
end

--@desc: 执行属性变化
--@author:Seven
--@time:2023-03-22 15:25:24
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function ABuffEffectModifierAttr:doAttack(target)
    self.__characterId = target:getId()

    local value = self:getHurtValue()
    
    target:addAttr(self:getAttrName(), value)

    if self:getAttrName() == "qi" and value < 0 then
        if target:getBuffAddAttr("RecordDamageBuffNum") > 0 then
            target:addAttr("recordDamage", -value)
        end
    end
end

return newClass(ABuffEffectModifierAttr, {ABasicHurt}, ABuffEffectModifierAttr)
0