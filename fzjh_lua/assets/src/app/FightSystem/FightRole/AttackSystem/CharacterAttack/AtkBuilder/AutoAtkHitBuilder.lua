local newClass = require("third.class.NewClass")

local AtkHitBuilder = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.AtkHitBuilder")

--@SuperType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.AtkHitBuilder#AtkHitBuilder]
local AutoAtkHitBuilder = {}

function AutoAtkHitBuilder:create(builderParams)
    local p = AutoAtkHitBuilder.new()

    p:__init(builderParams)

    return p
end

function AutoAtkHitBuilder:__buildAttackerZhaoEffectAttrs()
    local attacker = self.__builderParams:getAttacker()

    local buffSys = attacker:getBuffSystem()

    self.__zhao_atk:setZhaoEffectAttrsForAttacker(buffSys:roleGetUseAutoZhaoAttrsEffectMap(attacker:getId()))
end

function AutoAtkHitBuilder:__buildTargetZhaoEffectAttrs()
    local target = self.__builderParams:getTarget()

    local buffSys = target:getBuffSystem()

    self.__zhao_atk:setZhaoEffectAttrsForTarget(buffSys:roleGetUnderAutoZhaoAttrsEffectMap(target:getId()))
end

return newClass("AutoAtkHitBuilder", {AtkHitBuilder}, AutoAtkHitBuilder)
00000000000