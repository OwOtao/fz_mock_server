local interface = require("third.class.interface")

local ISkillAttackCombFinishDescVisitor = {}

--@desc:招式直接伤害的统计访问者
--@author:Seven
--@time:2022-01-06 12:15:18
--@damageProperty: [src.app.FightSystem.FightRole.AttackSystem.DamageModel.ADamageProperty#ADamageProperty]
function ISkillAttackCombFinishDescVisitor:visitDamageActualValue(damageProperty)
end

--@desc: 访问攻击过程中的实际伤害值（按照击中帧处理的相关效果）
--@author:Seven
--@time:2022-01-06 12:18:26
--@effectDamageProperty: [src.app.FightSystem.FightRole.AttackSystem.DamageModel.EffectChangeAttrByQiHitDamage#EffectChangeAttrByQiHitDamage]
function ISkillAttackCombFinishDescVisitor:visitEffectChangeAttrActualValue(effectDamageProperty)
end

--@desc:
--@author:Seven
--@time:2022-01-07 18:06:21
--@qiDamageShield: [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiDamageShield#QiDamageShield]
function ISkillAttackCombFinishDescVisitor:visitorQiShieldAbsorbedDamage(qiDamageShield)
end

return interface("ISkillAttackCombFinishDescVisitor", ISkillAttackCombFinishDescVisitor)
000000