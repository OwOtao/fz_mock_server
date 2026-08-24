-- local NewClass = require("third.class.NewClass")  

-- local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

-- --@RefType [src.app.FightSystem.Fight.BattleGlobalData#BattleGlobalData]
-- local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

-- local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

-- local AutoSkillCombFinishDescBuilder = require("app.FightSystem.FightRole.AttackSystem.SkillAttack.AutoSkillCombFinishDescBuilder")

-- local Desc = require("app.FightSystem.FightBuff.Desc")

-- --@RefType [FightFormula]
-- local FightFormula = require("app.FightSystem.FightFormula")

-- local FightCommons = require("app.FightSystem.FightCommons")

-- --@RefType[src.app.FightSystem.FightBuff.Constants#Constants]
-- local BuffSystemConstants = require("app.FightSystem.FightBuff.Constants")

-- local Desc = require("app.FightSystem.FightBuff.Desc")

-- local CHARACTER_STATE = FightCommons.CHARACTER_STATE

-- local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

-- local LOG_PREFIX = "# -> 被动技能 AutoSkillAttack ："

-- local function ATTAK_LOG(str)
--     FightUtil:printLog(LOG_PREFIX, str)
-- end

-- local ISkillAttack = require("app.FightSystem.FightRole.AttackSystem.SkillAttack.ISkillAttack")

-- --@SuperType [src.app.FightSystem.FightRole.AttackSystem.SkillAttack.ISkillAttack#ISkillAttack]
-- local AutoSkillAttack = {
--     __character = nil,
--     --@desc 一次出手总共使用的招式comb次数
--     __attackCount = 0,
--     __index = 1,
--     __zhaoComb = nil,
--     __zhaoAttacks = {},
--     --@desc 招式组合是否被打断
--     __zhaoCombIsInterrupt = false,
--     --@region 攻击伤害相关
--     __qiDamage = 0, --@desc 当前招式组合气血总伤害
--     --@desc 受击方气血阶段记录
--     __startCombTargetQiStage = 0,
--     --@endregion
--     __zhaoCombHitPosName = ""
-- }

-- function AutoSkillAttack:create(character)
--     local p = self.new()
--     p:setCharacter(character)
--     return p
-- end

-- function AutoSkillAttack:setCharacter(character)
--     --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--     self.__character = character
-- end

-- --@desc: 获取招式段攻击对象
-- --@author:Seven
-- --@time:2021-06-25 16:16:04
-- --@atkId: 攻击段id
-- --@return [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack#IZhaoAttack]
-- function AutoSkillAttack:__getZhaoAttackById(atkId)
--     local zhaoAttack = self.__zhaoAttacks[atkId]

--     if zhaoAttack == nil then
--         error("AutoSkillAttack:__getZhaoAttackById 没有找到对应攻击招式结果 ID:" .. tostring(atkId))
--     end
--     return zhaoAttack
-- end

-- --@desc: 获取当前被动招式信息
-- --@author:Seven
-- --@time:2021-06-25 21:00:20
-- --@return [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
-- function AutoSkillAttack:__getCurrentZhaoInfo()
--     return self.__zhaoComb:getZhaoInfo(self.__index)
-- end

-- --@desc: 添加攻击结果
-- --@author:Seven
-- --@time:2021-06-25 20:39:34
-- function AutoSkillAttack:__putZhaoAtk(zhaoAtk)
--     self.__zhaoAttacks[zhaoAtk:getId()] = zhaoAtk
-- end

-- function AutoSkillAttack:__createCurrentZhaoAttack()
--     local attacker = self.__character

--     local target = self.__character:getTarget()

--     local zhaoCombAttack = self.__zhaoComb

--     --@RefType [AttackFactory]
--     local AttackFactory = require("app.FightSystem.Factory.CharacterFactory.AttackFactory")

--     local attackHitType = AttackFactory:randomAutoZhaoAttackHitType(zhaoCombAttack, attacker, target)

--     local zhaoAtk
--     if attackHitType == ATTACK_HIT_TYPE.HIT then
--         local builderParams = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.HitBuilderParams"):create(zhaoCombAttack, self.__index, attacker, target)
--         --@RefType[src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.AtkHitBuilder#AtkHitBuilder]
--         local autoAtkHitBuilder = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.AutoAtkHitBuilder"):create(builderParams)
--         zhaoAtk = autoAtkHitBuilder:build()
--     else
--         zhaoAtk = AttackFactory:createZhaoAtk(zhaoCombAttack, self.__index, attacker, target, attackHitType)
--     end

--     return zhaoAtk
-- end

-- function AutoSkillAttack:prepAttack()
--     --@desc 被动技能无准备攻击阶段
-- end

-- function AutoSkillAttack:startAttack()
--     ATTAK_LOG(self.__character:getAttr("name") .. "开始出手被动技能 id：" .. self.__zhaoComb:getId() .. " name：" .. self.__zhaoComb:getZhaoName())
--     self.__character:setCanRecover(false)
--     self.__attackCount = 0
--     self.__zhaoCombIsInterrupt = false
-- end

-- function AutoSkillAttack:isNeedToJump()
--     --@desc 被动招式出手需跳跃
--     return true
-- end

-- --@desc: 设置攻击使用的招式组合
-- --@author:Seven
-- --@time:2021-06-25 18:09:53
-- function AutoSkillAttack:setZhaoComb(zhaoComb)
--     --@RefType [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombAttack#AutoZhaoCombAttack]
--     self.__zhaoComb = zhaoComb
-- end

-- --@desc: 获得被动攻击组合
-- --@author:Seven
-- --@time:2021-06-28 17:30:03
-- --@return [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombAttack#AutoZhaoCombAttack]
-- function AutoSkillAttack:getZhaoComb()
--     return self.__zhaoComb
-- end

-- function AutoSkillAttack:startCombAttack()
--     ATTAK_LOG("startCombAttack 【" .. self.__character:getAttr("name") .. "】 第" .. self.__index .. "段攻击开始")
--     self.__zhaoCombIsInterrupt = false

--     self.__character:startCombAttack()

--     local target = self.__character:getTarget()

--     --@region 计算当前招式组合总伤害
--     local totalQiDamage = FightFormula:calAutoZhaoQiDamageAttackValue(self.__zhaoComb, self.__character, target)
--     --@RefType [src.app.FightSystem.AttackModel.QiDamageHurt#QiDamageHurt]
--     local qiDamageHurt = require("app.FightSystem.AttackModel.QiDamageHurt"):create()
--     qiDamageHurt:setProjectionValue(totalQiDamage)
--     qiDamageHurt:setHurtDesc(self.__zhaoComb:getDamageType())
--     local buffSys = self.__character:getBuffSystem()
--     local redutionPercents = buffSys:roleGetAutoZhaoReductionOfInjuryRateArray(self.__character:getTarget():getId())
--     if #redutionPercents > 0 then
--         for _, v in ipairs(redutionPercents) do
--             qiDamageHurt:addReductionOfInjuryPercent(v)
--         end
--     end

--     local redutionConstValues = buffSys:roleGetAutoZhaoReductionOfInjuryValueArray(self.__character:getTarget():getId())
--     if #redutionConstValues > 0 then
--         for _, v in ipairs(redutionConstValues) do
--             qiDamageHurt:addReductionOfInjuryConstValue(v)
--         end
--     end

--     local disabilityProbability = FightFormula:calDisabilityProbability(self.__zhaoComb, self.__character, target)
--     local totalQiMaxDamage = FightFormula:calAutoZhaoQiMaxDamageAttackValue(totalQiDamage, disabilityProbability, self.__zhaoComb, self.__character, target)
--     --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.AttackHurtInfo#AttackHurtInfo]
--     local atkQiMaxHurtInfo = require("app.FightSystem.AttackModel.Hurt"):create()
--     atkQiMaxHurtInfo:setAttrName("qiMax")
--     atkQiMaxHurtInfo:setHurtValue(totalQiMaxDamage)
--     atkQiMaxHurtInfo:setHurtDesc(self.__zhaoComb:getDamageType())

--     self.__zhaoComb:setQiDamageHurts({qiDamageHurt})
--     self.__zhaoComb:setHurtInfos({atkQiMaxHurtInfo})
--     --@endregion

--     self.__zhaoCombHitPosName = self.__zhaoComb:randomHurtPosName()

--     self.__attackCount = self.__attackCount + 1

--     self.__index = 1

--     local costTili = FightFormula:calAutoAttackTiliCost(self.__zhaoComb:getTiliCost(), self.__character:getMulAutoZhaoTiliCost(), self.__character:getAddAutoZhaoTiliCost())

--     local costNeili = FightFormula:calAutoAttackNeiliCost(self.__character:getPlusPointBattle(), self.__character:getMulAutoZhaoNeiliCost(), self.__character:getAddAutoZhaoNeiliCost())
--     local currNeili = self.__character:getAttr("neili")
--     if costNeili > currNeili then
--         costNeili = math.ceil(currNeili)
--     end

--     self.__character:consumeTili(costTili)

--     self.__character:consumeNeili(costNeili)

--     local startCombText = self.__zhaoComb:getActionText()

--     local startCombDesc = self:__createAutoTextDesc(startCombText)

--     self.__character:outputDesces({startCombDesc})

--     self.__startCombTargetQiStage = target:getQiStage()

--     ATTAK_LOG("startCombAttack 【" .. self.__character:getAttr("name") .. "】使用组合-" .. self.__zhaoComb:getId() .. "开始攻击 : ")
--     ATTAK_LOG("startCombAttack 【体力消耗】：" .. costTili)
--     ATTAK_LOG("startCombAttack 【内力消耗】：" .. costNeili)
--     ATTAK_LOG("startCombAttack 【气血总伤害】：" .. totalQiDamage)
--     ATTAK_LOG("startCombAttack 【气血上限总伤害】：" .. totalQiMaxDamage)
-- end

-- function AutoSkillAttack:getReadyDuration()
--     return 0
-- end

-- function AutoSkillAttack:doReadyZhao()
--     --@desc 被动攻击无准备释放阶段
-- end

-- function AutoSkillAttack:startZhaoAttack()
--     ATTAK_LOG("startZhaoAttack 【" .. self.__character:getAttr("name") .. "】 第" .. self.__index .. "段攻击开始")
--     --@desc 每次使用时创建
--     local zhaoAtk = self:__createCurrentZhaoAttack()
--     self:__putZhaoAtk(zhaoAtk)
-- end

-- function AutoSkillAttack:doZhaoAttack()
--     ATTAK_LOG("doZhaoAttack【第" .. self.__index .. "/" .. self.__zhaoComb:getAtkCount() .. "段攻击")
--     local zhaoInfo = self:__getCurrentZhaoInfo()
--     local zhaoAttack = self:__getZhaoAttackById(zhaoInfo:getId())
--     self.__character:attack(zhaoAttack)
-- end

-- function AutoSkillAttack:finishZhaoAttack()
--     ATTAK_LOG("finishZhaoAttack 【" .. self.__character:getAttr("name") .. "】 第" .. self.__index .. "段攻击结束")
--     local target = self.__character:getTarget()
--     if target:getAttr("qi") <= 0 then
--         target:changeState(CHARACTER_STATE.DEAD)
--     end

--     if self.__character:getAttr("qi") <= 0 then
--         self.__character:changeState(CHARACTER_STATE.DEAD)
--     end

--     local zhaoInfo = self:__getCurrentZhaoInfo()
--     local currZhaoAttack = self:__getZhaoAttackById(zhaoInfo:getId())
--     if (currZhaoAttack:getHurtType() == ATTACK_HIT_TYPE.DODGE_SPC or currZhaoAttack:getHurtType() == ATTACK_HIT_TYPE.PARRY_SPEC) then
--         self.__zhaoCombIsInterrupt = true
--     end
-- end

-- function AutoSkillAttack:__createAutoTextDesc(text)
--     --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
--     local desc = require("app.FightSystem.FightUtil.FightDesc"):create()

--     desc:setText(text)

--     desc:setAttacker(self.__character)

--     desc:setDefender(self.__character:getTarget())

--     desc:setHitPosName(self.__zhaoCombHitPosName)

--     return desc
-- end

-- function AutoSkillAttack:__outputTargetDescs()
--     local allTargetOneHits = {}

--     for zhaoId, zhaoAttack in pairs(self.__zhaoAttacks) do
--         --@RefType[src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack#IZhaoAttack]
--         local zhaoAttack = zhaoAttack

--         local targetOneAttackHits = zhaoAttack:getAllTargetOneAttackHit()

--         if #targetOneAttackHits > 0 then
--             for i, v in ipairs(targetOneAttackHits) do
--                 table.insert(allTargetOneHits, v)
--             end
--         end
--     end

--     --@RefType [src.app.FightSystem.FightRole.AttackSystem.SkillAttack.AutoSkillCombFinishDescBuilder#AutoSkillCombFinishDescBuilder]
--     local targetDescBuilder = AutoSkillCombFinishDescBuilder:create()
--     targetDescBuilder:setAttacker(self.__character)
--     targetDescBuilder:setDefender(self.__character:getTarget())
--     targetDescBuilder:setHitPosName(self.__zhaoCombHitPosName)
--     targetDescBuilder:setTargetStartQiStage(self.__startCombTargetQiStage)
--     local tQiDamageHurts = {}
--     local tOtherAttrHurts = {}
--     local tEffectAttrsByQiDamages = {}
--     if #allTargetOneHits > 0 then
--         for i = 1, #allTargetOneHits do
--             --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.OneHitAttack#OneHitAttack]
--             local oneHitAttack = allTargetOneHits[i]

--             if #oneHitAttack:getQiDamages() > 0 then
--                 table.insertArray(tQiDamageHurts, oneHitAttack:getQiDamages())
--             end

--             if #oneHitAttack:getOtherAttrDamageHurt() > 0 then
--                 table.insertArray(tOtherAttrHurts, oneHitAttack:getOtherAttrDamageHurt())
--             end

--             if #oneHitAttack:getEffectAttrsByQidamage() > 0 then
--                 table.insertArray(tEffectAttrsByQiDamages, oneHitAttack:getEffectAttrsByQidamage())
--             end
--         end
--     end
--     targetDescBuilder:setQiDamageHurtCauseByZhaoHit(tQiDamageHurts)
--     targetDescBuilder:setOtherAttrHurtsCauseByZhaoHit(tOtherAttrHurts)
--     targetDescBuilder:setEffectAttrsByQiDamageArray(tEffectAttrsByQiDamages)

--     local targetDesc = targetDescBuilder:build()

--     self.__character:outputDesces(targetDesc)
-- end

-- function AutoSkillAttack:__outputAttackerDesc()
--     local allAttackerOneHits = {}

--     for zhaoId, zhaoAttack in pairs(self.__zhaoAttacks) do
--         --@RefType[src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack#IZhaoAttack]
--         local zhaoAttack = zhaoAttack

--         local targetOneAttackHits = zhaoAttack:getAllTargetOneAttackHit()

--         local attackerOneAttackHits = zhaoAttack:getAllAttackerOneAttackHit()
--         if #attackerOneAttackHits > 0 then
--             for i, v in ipairs(attackerOneAttackHits) do
--                 table.insert(allAttackerOneHits, v)
--             end
--         end
--     end

--     --@RefType [src.app.FightSystem.FightRole.AttackSystem.SkillAttack.AutoSkillCombFinishDescBuilder#AutoSkillCombFinishDescBuilder]
--     local attackerDescBuilder = AutoSkillCombFinishDescBuilder:create()
--     attackerDescBuilder:setAttacker(self.__character)
--     attackerDescBuilder:setDefender(self.__character:getTarget())
--     attackerDescBuilder:setHitPosName(self.__zhaoCombHitPosName)
--     local aQiDamageHurts = {}
--     local aOtherAttrHurts = {}
--     local aEffectAttrsByQiDamages = {}
--     if #allAttackerOneHits > 0 then
--         for i = 1, #allAttackerOneHits do
--             --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.OneHitAttack#OneHitAttack]
--             local oneHitAttack = allAttackerOneHits[i]

--             -- if #oneHitAttack:getQiDamages() > 0 then
--             --     table.insertArray(tQiDamageHurts, oneHitAttack:getQiDamages())
--             -- end

--             -- if #oneHitAttack:getOtherAttrDamageHurt() > 0 then
--             --     table.insertArray(tOtherAttrHurts, oneHitAttack:getOtherAttrDamageHurt())
--             -- end

--             if #oneHitAttack:getEffectAttrsByQidamage() > 0 then
--                 table.insertArray(aEffectAttrsByQiDamages, oneHitAttack:getEffectAttrsByQidamage())
--             end
--         end
--     end
--     attackerDescBuilder:setQiDamageHurtCauseByZhaoHit(aQiDamageHurts)
--     attackerDescBuilder:setOtherAttrHurtsCauseByZhaoHit(aOtherAttrHurts)
--     attackerDescBuilder:setEffectAttrsByQiDamageArray(aEffectAttrsByQiDamages)

--     local attackerDesc = attackerDescBuilder:build()

--     if #attackerDesc > 0 then
--         self.__character:outputDesces(attackerDesc)
--     end
-- end

-- function AutoSkillAttack:finishCombAttack()
--     ATTAK_LOG("finishCombAttack 【" .. self.__character:getAttr("name") .. "】组合-" .. self.__zhaoComb:getId() .. "攻击结束")

--     self:__outputAttackerDesc()
--     self:__outputTargetDescs()

--     -- 尝试移除buff
--     self:__tryRemoveBuff()

--     self.__startCombTargetQiStage = 0
--     self.__zhaoCombHitPosName = ""
--     self.__zhaoComb = nil
--     self.__zhaoAttacks = {}

--     self.__character:doWhenFinishCombAttack(self)

--     self.__character:finishCombAttack(self)
-- end

-- function AutoSkillAttack:__tryRemoveBuff()
--     local zhaoInfoCount = self.__index
--     if zhaoInfoCount > 0 then
--         local isAllHit = true
--         local hasDodge = false
--         local hasParry = false

--         local hasDodgeJump = false
--         local hasParryParry = false

--         for i = 1, zhaoInfoCount do
--             local zhaoInfo = self.__zhaoComb:getZhaoInfo(i)
--             local zhaoAttack = self:__getZhaoAttackById(zhaoInfo:getId())

--             local hurtType = zhaoAttack:getHurtType()

--             -- 是否命中
--             if hurtType == FightCommons.ATTACK_HIT_TYPE.HIT then
--             else
--                 isAllHit = false
--             end

--             -- 招架闪避
--             if hurtType == FightCommons.ATTACK_HIT_TYPE.DODGE then
--                 hasDodge = true
--             elseif hurtType == FightCommons.ATTACK_HIT_TYPE.PARRY then
--                 hasParry = true
--             elseif hurtType == FightCommons.ATTACK_HIT_TYPE.DODGE_SPC then
--                 hasDodgeJump = true
--             elseif hurtType == FightCommons.ATTACK_HIT_TYPE.PARRY_SPEC then
--                 hasParryParry = true
--             end
--         end

--         -- 触发所有命中移除
--         if isAllHit then
--             self.__character:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UseAutoZhao, FightCommons.ATTACK_HIT_TYPE.HIT)

--             self.__character:getTarget():tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UnderAutoZhao, FightCommons.ATTACK_HIT_TYPE.HIT)
--         end

--         -- 触发闪避移除
--         if hasDodge then
--             self.__character:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UseAutoZhao, FightCommons.ATTACK_HIT_TYPE.DODGE)

--             self.__character:getTarget():tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UnderAutoZhao, FightCommons.ATTACK_HIT_TYPE.DODGE)
--         end

--         -- 触发招架移除
--         if hasParry then
--             self.__character:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UseAutoZhao, FightCommons.ATTACK_HIT_TYPE.PARRY)

--             self.__character:getTarget():tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UnderAutoZhao, FightCommons.ATTACK_HIT_TYPE.PARRY)
--         end

--         -- 触发闪避移除
--         if hasDodgeJump then
--             self.__character:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UseAutoZhao, FightCommons.ATTACK_HIT_TYPE.DODGE_SPC)

--             self.__character:getTarget():getBuffSystem():roleTryRemoveBuff(
--                 self.__character:getTarget():getId(),
--                 BuffSystemConstants.BuffTriggerType.UnderAutoZhao,
--                 FightCommons.ATTACK_HIT_TYPE.DODGE_SPC
--             )
--         end

--         -- 触发招架移除
--         if hasParryParry then
--             self.__character:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UseAutoZhao, FightCommons.ATTACK_HIT_TYPE.PARRY_SPEC)
--             self.__character:getTarget():tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UseAutoZhao, FightCommons.ATTACK_HIT_TYPE.PARRY_SPEC)
--         end
--     end
-- end

-- function AutoSkillAttack:finishAttack()
--     ATTAK_LOG("finishAttack 【" .. self.__character:getAttr("name") .. "】本次出手结束")
--     self.__character:setCanRecover(true)
--     self.__zhaoComb = nil
--     self.__zhaoAttacks = {}
-- end

-- function AutoSkillAttack:hasNextZhaoAttack()
--     local zhaoInfo = self:__getCurrentZhaoInfo()
--     local currZhaoAttack = self:__getZhaoAttackById(zhaoInfo:getId())
--     --@desc 被打断
--     if currZhaoAttack and self:zhaoCombIsBeInterrupt() then
--         return false
--     end

--     return self.__index < self.__zhaoComb:getAtkCount()
-- end

-- function AutoSkillAttack:setNextZhaoAttack()
--     self.__index = self.__index + 1
--     ATTAK_LOG(self.__character:getAttr("name") .. "设置下一段攻击：" .. self.__index)
-- end

-- function AutoSkillAttack:getAttackOffset()
--     local offset = 0

--     local zhaoInfo = self:__getCurrentZhaoInfo()

--     local atkWeapon = self.__character:getWeapon()

--     local animName = AnimResManager:getAttackAnimName(zhaoInfo:getAnimResId(), atkWeapon:getWeaponModule())

--     offset = AnimResManager:getAttackAnimOffset(animName)

--     return offset
-- end

-- function AutoSkillAttack:getAttackDuration()
--     local zhaoInfo = self:__getCurrentZhaoInfo()

--     local zhaoAttack = self:__getZhaoAttackById(zhaoInfo:getId())

--     local duration = zhaoAttack:getDuration()

--     return duration
-- end

-- function AutoSkillAttack:zhaoCombIsBeInterrupt()
--     return self.__zhaoCombIsInterrupt
-- end

-- function AutoSkillAttack:canContinueUseAuto()
--     return true
-- end

-- return NewClass("AutoSkillAttack", {ISkillAttack}, AutoSkillAttack)
00000000000000