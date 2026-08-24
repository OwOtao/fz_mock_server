local newClass = require("third.class.NewClass")

local AtkHitBuilder = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.AtkHitBuilder")

--@SuperType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.AtkHitBuilder#AtkHitBuilder]
local ActivateAtkHitBuilder = {}

function ActivateAtkHitBuilder:create(builderParams)
    local p = ActivateAtkHitBuilder.new()

    p:__init(builderParams)

    return p
end

function ActivateAtkHitBuilder:__buildAttackerZhaoEffectAttrs()
    local attacker = self.__builderParams:getAttacker()

    local buffSys = attacker:getBuffSystem()

    self.__zhao_atk:setZhaoEffectAttrsForAttacker(buffSys:roleGetUseActiveZhaoAttrsEffectMap(attacker:getId()))
end

function ActivateAtkHitBuilder:__buildTargetZhaoEffectAttrs()
    local target = self.__builderParams:getTarget()

    local buffSys = target:getBuffSystem()

    self.__zhao_atk:setZhaoEffectAttrsForTarget(buffSys:roleGetUnderActiveZhaoAttrsEffectMap(target:getId()))
end

return newClass("ActivateAtkHitBuilder", {AtkHitBuilder}, ActivateAtkHitBuilder)
00000000000