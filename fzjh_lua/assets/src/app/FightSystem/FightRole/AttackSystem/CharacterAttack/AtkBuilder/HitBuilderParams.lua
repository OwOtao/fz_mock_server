local newClass = require("third.class.NewClass")

local HitBuilderParams = {}

function HitBuilderParams:create(attackComb, zhaoAttackIndex, attacker, target, oneOffEffect)
    local p = HitBuilderParams.new()
    p:__init(attackComb, zhaoAttackIndex, attacker, target, oneOffEffect)

    return p
end

function HitBuilderParams:__init(attackComb, zhaoAttackIndex, attacker, target, oneOffEffect)
    self.__attackComb = attackComb
    self.__zhaoAttackIndex = zhaoAttackIndex
    self.__attacker = attacker
    self.__target = target
    self.__oneOneOffEffect = oneOffEffect
end

function HitBuilderParams:getAttackComb()
    return self.__attackComb
end

function HitBuilderParams:getZhaoAttackIndex()
    return self.__zhaoAttackIndex
end

--@return [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function HitBuilderParams:getAttacker()
    return self.__attacker
end

--@return [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function HitBuilderParams:getTarget()
    return self.__target
end

function HitBuilderParams:getOneOffEffect()
    return Helper:getDef(self.__oneOneOffEffect, {})
end

return newClass("HitBuilderParams", {}, HitBuilderParams)
00