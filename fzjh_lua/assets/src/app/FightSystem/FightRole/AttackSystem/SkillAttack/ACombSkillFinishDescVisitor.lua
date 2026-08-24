local abstract = require("third.class.abstract")

local ISkillAttackCombFinishDescVisitor = require("app.FightSystem.FightRole.AttackSystem.SkillAttack.ISkillAttackCombFinishDescVisitor")

local ACombSkillFinishDescVisitor = {
    __shiedAbsorbValue = 0
}

function ACombSkillFinishDescVisitor:__getCharacter(characterId)
    if characterId == self.__attacker:getId() then
        return self.__attacker
    end

    if characterId == self.__defender:getId() then
        return self.__defender
    end

    error("ACombSkillFinishDescVisitor:__getCharacter 获取id非攻击者也非受击者，检查代码")
end

function ACombSkillFinishDescVisitor:setAttacker(attacker)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__attacker = attacker
end

function ACombSkillFinishDescVisitor:setDefender(defender)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__defender = defender
end

function ACombSkillFinishDescVisitor:setCombHitPosName(hitPosName)
    self.__hitPosName = hitPosName
end

function ACombSkillFinishDescVisitor:setDefenderQiStage(stage)
    self.__defenderStartQiStage = stage
end

--@desc:
--@author:Seven
--@time:2022-01-07 18:08:19
--@qiDamageShield: [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiDamageShield#QiDamageShield]
function ACombSkillFinishDescVisitor:visitorQiShieldAbsorbedDamage(qiDamageShield)
    self.__shiedAbsorbValue = self.__shiedAbsorbValue + qiDamageShield:getHasAbsorbedDamage()
end

return abstract("ACombSkillFinishDescVisitor", {ISkillAttackCombFinishDescVisitor}, ACombSkillFinishDescVisitor)
0000