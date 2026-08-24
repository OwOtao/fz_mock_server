-- local newClass = require("third.class.NewClass")  

-- --@RefType [src.app.FightSystem.Fight.BattleGlobalData#BattleGlobalData]
-- local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

-- local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

-- local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

-- local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

-- local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

-- local FightFormula = require("app.FightSystem.FightFormula")

-- local FightCommons = require("app.FightSystem.FightCommons")

-- --@RefType[src.app.FightSystem.FightBuff.Constants#Constants]
-- local BuffSystemConstants = require("app.FightSystem.FightBuff.Constants")

-- local ActiveSkillCombFinishDescBuilder = require("app.FightSystem.FightRole.AttackSystem.SkillAttack.ActiveSkillCombFinishDescBuilder")

-- --@RefType[src.app.FightSystem.FightBuff.Desc#Desc]
-- local Desc = require("app.FightSystem.FightBuff.Desc")

-- local CHARACTER_STATE = FightCommons.CHARACTER_STATE

-- local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

-- local LOG_PREFIX = "# -> 主动技能 ActiveSkillAttack ："

-- local function ATTAK_LOG(str)
--     FightUtil:printLog(LOG_PREFIX, str)
-- end

-- local ISkillAttack = require("app.FightSystem.FightRole.AttackSystem.SkillAttack.ISkillAttack")

-- --@SuperType [src.app.FightSystem.FightRole.AttackSystem.SkillAttack.ISkillAttack#ISkillAttack]
-- local ActiveSkillAttack = {
--     __zhaoCombIsInterrupt = false,
--     __character = nil,
--     --@desc 一次出手总共使用的招式comb次数
--     __attackCount = 0,
--     __index = 1,
--     __zhaoComb = nil,
--     __zhaoAttacks = {},
--     __zhaoCombHitPosName = "",
--     __isRunning = false
-- }

-- function ActiveSkillAttack:create(character)
--     local p = self.new()
--     p:setCharacter(character)
--     return p
-- end

-- function ActiveSkillAttack:setCharacter(character)
--     --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--     self.__character = character
-- end

-- --@desc: 设置攻击使用的招式组合
-- --@author:Seven
-- --@time:2021-06-25 18:09:53
-- function ActiveSkillAttack:setZhaoComb(zhaoComb)
--     --@RefType [src.app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombAttack#ActiveZhaoCombAttack]
--     self.__zhaoComb = zhaoComb

--     if zhaoComb == nil then
--         self.__activeSkill = nil
--     else
--         self.__activeSkill = self.__character:getActiveSkill(self.__zhaoComb:getActiveId())
--     end
-- end

-- function ActiveSkillAttack:getZhaoComb()
--     return self.__zhaoComb
-- end

-- --@desc: 获取招式段攻击对象
-- --@author:Seven
-- --@time:2021-06-25 16:16:04
-- --@atkId: 攻击段id
-- --@return [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack#IZhaoAttack]
-- function ActiveSkillAttack:__getZhaoAttackById(atkId)
--     local zhaoAttack = self.__zhaoAttacks[atkId]

--     if zhaoAttack == nil then
--         error("ActiveSkillAttack:__getZhaoAttackById 没有找到对应攻击招式结果 ID:" .. tostring(atkId))
--     end

--     return zhaoAttack
-- end

-- --@desc: 获取当前被动招式信息
-- --@author:Seven
-- --@time:2021-06-25 21:00:20
-- --@return [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
-- function ActiveSkillAttack:__getCurrentZhaoInfo()
--     return self.__zhaoComb:getZhaoInfo(self.__index)
-- end

-- --@desc: 添加攻击结果
-- --@author:Seven
-- --@time:2021-06-25 20:39:34
-- --@zhaoAtk: [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack#IZhaoAttack]
-- function ActiveSkillAttack:__putZhaoAtk(zhaoAtk)
--     self.__zhaoAttacks[zhaoAtk:getId()] = zhaoAtk
-- end

-- function ActiveSkillAttack:__createCurrentZhaoAttack()
--     local AttackFactory = require("app.FightSystem.Factory.CharacterFactory.AttackFactory")
--     local hitType

--     local zhaoAtk

--     if self.__zhaoComb:isAttackSkill() then
--         hitType = ATTACK_HIT_TYPE.HIT

--         local builderParams =
--             require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.HitBuilderParams"):create(self.__zhaoComb, self.__index, self.__character, self.__character:getTarget())
--         --@RefType[src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.AtkHitBuilder#AtkHitBuilder]
--         local activateAtkHitBuilder = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.ActivateAtkHitBuilder"):create(builderParams)
--         zhaoAtk = activateAtkHitBuilder:build()
--     else
--         hitType = ATTACK_HIT_TYPE.NONE
--         zhaoAtk = AttackFactory:createZhaoAtk(self.__zhaoComb, self.__index, self.__character, self.__character:getTarget(), hitType)
--     end

--     return zhaoAtk
-- end

-- function ActiveSkillAttack:setZhaoCombCanRelease(bool)
--     if type(bool) ~= "boolean" then
--         assert(false, "ActiveSkillAttack setZhaoCombCanRelease 参数类型错误")
--     end

--     if self.__zhaoComb == nil then
--         assert(false, "ActiveSkillAttack:setZhaoCombCanRelease 主动技能未设置zhaoComb ，不可设置招式可出手，检查代码")
--     end

--     self.__canRelease = bool
-- end

-- function ActiveSkillAttack:underBan()
--     if self.__zhaoComb == nil then
--         assert(false, "ActiveSkillAttack:underBan 主动技能未设置zhaoComb ，无法检测是否被禁止，检查代码")
--     end

--     if self.__activeSkill == nil then
--         assert(false, "ActiveSkillAttack:underBan 主动技能未设置activeSkill ，无法检测是否被禁止，检查代码")
--     end

--     local underBan, popTips = self.__activeSkill:underBan()

--     return underBan, popTips
-- end

-- function ActiveSkillAttack:checkCanRelease()
--     if self.__zhaoComb == nil then
--         assert(false, "ActiveSkillAttack:checkCanRelease 主动技能未设置zhaoComb ，无法检测是否可以出手，检查代码")
--     end

--     local isbool, failureText = self.__activeSkill:isMeetTheCost()

--     return isbool, failureText
-- end

-- --@desc: 招式组合是否可以释放
-- --@author:Seven
-- --@time:2021-06-29 11:30:31
-- function ActiveSkillAttack:zhaoCombCanRelease()
--     if self:getZhaoComb() == nil then
--         assert(false, "当前攻击招式组为空，检查代码！")
--     end

--     return self.__canRelease
-- end

-- function ActiveSkillAttack:prepAttack()
--     -- self.__character:prepReleaseActiveSkill(self.__zhaoComb:getActiveId())
-- end

-- --@desc: 一次出手开始
-- --@author:Seven
-- --@time:2021-06-25 15:15:34
-- function ActiveSkillAttack:startAttack()
--     self.__zhaoCombIsInterrupt = false

--     ATTAK_LOG(self.__character:getAttr("name") .. "开始释放主动技能 id:" .. self.__zhaoComb:getActiveId() .. " name :" .. self.__zhaoComb:getActiveName())

--     if self:zhaoCombCanRelease() == false then
--         assert(false, "ActiveSkillAttack:startAttack 当前招式没有解锁出手，检查代码")
--         return
--     end

--     self:setZhaoCombCanRelease(false)

--     self.__attackCount = 0

--     self.__character:releaseActiveSkill(self.__zhaoComb:getActiveId())

--     self.__character:setCanRecover(false)

--     local costTili = self.__activeSkill:getTiliCost()

--     local costNeili = self.__activeSkill:getNeiliCost()

--     self.__character:consumeTili(costTili)

--     self.__character:consumeNeili(costNeili)

--     self.__activeSkill:setCD(self.__activeSkill:getCoolDownTime())

--     self.__zhaoCombHitPosName = self.__zhaoComb:randomHurtPosName()

--     local startText = self.__zhaoComb:getActionText()

--     local startDesc = self:__createActiveTextDesc(startText)

--     self.__character:outputDesces({startDesc})

--     self.__isRunning = true

--     ATTAK_LOG("startAttack 【体力消耗】：" .. costTili)
--     ATTAK_LOG("startAttack 【内力消耗】：" .. costNeili)
-- end

-- function ActiveSkillAttack:isNeedToJump()
--     return self.__zhaoComb:isJumpAttack()
-- end

-- function ActiveSkillAttack:isRunning()
--     return self.__isRunning
-- end

-- --@desc: 一次招式组合攻击开始
-- --@author:Seven
-- --@time:2021-06-25 15:16:13
-- function ActiveSkillAttack:startCombAttack()
--     self.__isContinueAutoZhao = self.__zhaoComb:getCompletionUseAuto() == 1

--     self:__addBuffOnCompoStart()

--     self.__character:startCombAttack()

--     local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")

--     --@region 计算当前招式组合总伤害
--     local target = self.__character:getTarget()
--     local hurtIDs = self.__zhaoComb:getHurtIDs()
--     local hurtArray = {}
--     local qiHurtArray = {}
--     if #hurtIDs > 0 then
--         for _, hurtID in ipairs(hurtIDs) do
--             local activeZhaoHurt = ZhaoHurtDegreeFactory:createActiveZhaoHurt(hurtID)

--             activeZhaoHurt:setCharacter(self.__character)

--             local activeZhaoHurtValue = activeZhaoHurt:getHurtValue()

--             if activeZhaoHurt:getChangeAttrName() == "qi" then
--                 local qiDamageHurt = require("app.FightSystem.AttackModel.QiDamageHurt"):create()
--                 qiDamageHurt:setProjectionValue(activeZhaoHurtValue)
--                 if activeZhaoHurt:getHurtDes() ~= nil then
--                     qiDamageHurt:setHurtDesc(activeZhaoHurt:getHurtDes())
--                 end

--                 local buffSys = self.__character:getBuffSystem()
--                 local redutionPercents = buffSys:roleGetActiveZhaoReductionOfInjuryRateArray(self.__character:getTarget():getId())
--                 if #redutionPercents > 0 then
--                     for _, v in ipairs(redutionPercents) do
--                         qiDamageHurt:addReductionOfInjuryPercent(v)
--                     end
--                 end

--                 local redutionConstValues = buffSys:roleGetActiveZhaoReductionOfInjuryValueArray(self.__character:getTarget():getId())
--                 if #redutionConstValues > 0 then
--                     for _, v in ipairs(redutionConstValues) do
--                         qiDamageHurt:addReductionOfInjuryConstValue(v)
--                     end
--                 end
--                 table.insert(qiHurtArray, qiDamageHurt)
--             else
--                 --@RefType[src.app.FightSystem.AttackModel.Hurt#Hurt]
--                 local hurt = require("app.FightSystem.AttackModel.Hurt"):create()
--                 hurt:setAttrName(activeZhaoHurt:getChangeAttrName())
--                 if activeZhaoHurt:getHurtDes() ~= nil then
--                     hurt:setHurtDesc(activeZhaoHurt:getHurtDes())
--                 end
--                 hurt:setHurtValue(activeZhaoHurtValue)
--                 table.insert(hurtArray, hurt)
--             end
--         end
--     end

--     self.__zhaoComb:setHurtInfos(hurtArray)

--     self.__zhaoComb:setQiDamageHurts(qiHurtArray)

--     self.__attackCount = self.__attackCount + 1

--     self.__index = 1

--     self.__startCombTargetQiStage = target:getQiStage()

--     ATTAK_LOG("startCombAttack 【" .. self.__character:getAttr("name") .. "】使用组合-" .. self.__zhaoComb:getId() .. "开始攻击 : ")
-- end

-- function ActiveSkillAttack:getReadyDuration()
--     return self.__zhaoComb:getReadyDuration()
-- end

-- --@desc: 攻击准备执行
-- --@author:Seven
-- --@time:2021-06-25 15:17:17
-- function ActiveSkillAttack:doReadyZhao()
--     local animName = self.__zhaoComb:getReadyAnimName()

--     local soundId, soundStart = self.__zhaoComb:getReadySound()

--     if animName ~= nil then
--         ATTAK_LOG("doReadyZhao " .. self.__character:getAttr("name") .. " 释放准备招式动画：" .. animName)
--         self.__character:activeReady(animName, soundId, soundStart)
--     end
-- end

-- --@desc: 一次招式攻击开始
-- --@author:Seven
-- --@time:2021-06-25 15:17:27
-- function ActiveSkillAttack:startZhaoAttack()
--     ATTAK_LOG("startZhaoAttack" .. self.__character:getAttr("name") .. " 开始【第" .. self.__index .. "段】攻击")
--     --@desc 每次使用时创建
--     local zhaoAtk = self:__createCurrentZhaoAttack()
--     self:__putZhaoAtk(zhaoAtk)
-- end

-- --@desc: 招式攻击
-- --@author:Seven
-- --@time:2021-06-25 15:17:38
-- function ActiveSkillAttack:doZhaoAttack()
--     local zhaoInfo = self:__getCurrentZhaoInfo()
--     local zhaoAttack = self:__getZhaoAttackById(zhaoInfo:getId())

--     ATTAK_LOG("doZhaoAttack【第" .. self.__index .. "/" .. self.__zhaoComb:getAtkCount() .. "段攻击")
--     -- ATTAK_LOG("doZhaoAttack  └【气血伤害】" .. zhaoAttack:getQiDamage())

--     self.__character:attack(zhaoAttack)
-- end

-- --@desc: 招式攻击完成
-- --@author:Seven
-- --@time:2021-06-25 15:17:46
-- function ActiveSkillAttack:finishZhaoAttack()
--     ATTAK_LOG("startZhaoAttack" .. self.__character:getAttr("name") .. " 完成【第" .. self.__index .. "段】攻击")
--     local target = self.__character:getTarget()
--     if target:getAttr("qi") <= 0 then
--         target:changeState(CHARACTER_STATE.DEAD)
--     end

--     if self.__character:getAttr("qi") <= 0 then
--         self.__character:changeState(CHARACTER_STATE.DEAD)
--     end

--     local zhaoInfo = self:__getCurrentZhaoInfo()
--     local currZhaoAttack = self:__getZhaoAttackById(zhaoInfo:getId())

--     local zhaoInfo = self:__getCurrentZhaoInfo()
--     local currZhaoAttack = self:__getZhaoAttackById(zhaoInfo:getId())
--     if (currZhaoAttack:getHurtType() == ATTACK_HIT_TYPE.DODGE_SPC or currZhaoAttack:getHurtType() == ATTACK_HIT_TYPE.PARRY_SPEC) then
--         self.__zhaoCombIsInterrupt = true
--     end
-- end

-- function ActiveSkillAttack:__createActiveTextDesc(text)
--     --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
--     local desc = require("app.FightSystem.FightUtil.FightDesc"):create()

--     desc:setText(text)

--     desc:setAttacker(self.__character)

--     desc:setDefender(self.__character:getTarget())

--     desc:setHitPosName(self.__zhaoCombHitPosName)

--     return desc
-- end

-- function ActiveSkillAttack:__outputTargetDesc()
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

--     --@RefType [src.app.FightSystem.FightRole.AttackSystem.SkillAttack.ActiveSkillCombFinishDescBuilder#ActiveSkillCombFinishDescBuilder]
--     local targetDescBuilder = ActiveSkillCombFinishDescBuilder:create()
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

--     self.__character:getTarget():outputDesces(targetDesc)
-- end

-- function ActiveSkillAttack:__outputAttackerDesc()
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

--     --@RefType [src.app.FightSystem.FightRole.AttackSystem.SkillAttack.ActiveSkillCombFinishDescBuilder#ActiveSkillCombFinishDescBuilder]
--     local attackerDescBuilder = ActiveSkillCombFinishDescBuilder:create()
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

--             if #oneHitAttack:getQiDamages() > 0 then
--                 table.insertArray(aQiDamageHurts, oneHitAttack:getQiDamages())
--             end

--             if #oneHitAttack:getOtherAttrDamageHurt() > 0 then
--                 table.insertArray(aOtherAttrHurts, oneHitAttack:getOtherAttrDamageHurt())
--             end

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

-- --@desc: 招式组合攻击完成
-- --@author:Seven
-- --@time:2021-06-25 15:17:59
-- function ActiveSkillAttack:finishCombAttack()
--     ATTAK_LOG("finishCombAttack 【" .. self.__character:getAttr("name") .. "】组合-" .. self.__zhaoComb:getId() .. "攻击结束")

--     self:__outputAttackerDesc()
--     self:__outputTargetDesc()

--     --@desc 当前招式结束，当前伤害相关属性清零
--     self.__startCombTargetQiStage = 0
--     local tempComb = self.__zhaoComb
--     self.__zhaoComb = nil
--     self.__zhaoAttacks = {}

--     self.__character:doWhenFinishCombAttack(self)

--     -- 结束后添加buff
--     -- self:__addBuffOnCompoFinish(tempComb:getAddBuff())
--     self:__addBuffOnCompoFinish(tempComb:getBuffAdders())

--     self.__character:finishCombAttack(self)
-- end

-- --@desc: 一次出手攻击的完成
-- --@author:Seven
-- --@time:2021-06-25 15:16:03
-- function ActiveSkillAttack:finishAttack()
--     self.__zhaoCombHitPosName = ""
--     self.__zhaoComb = nil
--     self.__zhaoAttacks = {}
--     self.__character:setCanRecover(true)
--     self.__isRunning = false
-- end

-- --@desc: 是否有一招攻击
-- --@author:Seven
-- --@time:2021-06-25 15:18:10
-- function ActiveSkillAttack:hasNextZhaoAttack()
--     local zhaoInfo = self:__getCurrentZhaoInfo()
--     local currZhaoAttack = self:__getZhaoAttackById(zhaoInfo:getId())
--     --@desc 被打断
--     if currZhaoAttack and self:zhaoCombIsBeInterrupt() then
--         return false
--     end

--     return self.__index < self.__zhaoComb:getAtkCount()
-- end

-- --@desc: 设置下一招攻击
-- --@author:Seven
-- --@time:2021-06-25 15:49:32
-- function ActiveSkillAttack:setNextZhaoAttack()
--     self.__index = self.__index + 1
--     ATTAK_LOG("setNextZhaoAttack " .. self.__character:getAttr("name") .. "设置下一段攻击：" .. self.__index)
-- end

-- --@desc: 获取攻击距离
-- --@author:Seven
-- --@time:2021-06-25 20:50:41
-- function ActiveSkillAttack:getAttackOffset()
--     local offset = BattleConstConf:get("activeZhaoJumpAttackDistance")

--     if self.__zhaoComb:isAttackSkill() then
--         local zhaoInfo = self:__getCurrentZhaoInfo()

--         local atkWeapon = self.__character:getWeapon()

--         local animName = AnimResManager:getAttackAnimName(zhaoInfo:getAnimResId(), atkWeapon:getWeaponModule())

--         offset = AnimResManager:getAttackAnimOffset(animName)
--     end

--     return offset
-- end

-- --@desc: 获取当前攻击的攻击时间
-- --@author:Seven
-- --@time:2021-06-26 16:14:38
-- --@return:
-- function ActiveSkillAttack:getAttackDuration()
--     local zhaoInfo = self:__getCurrentZhaoInfo()

--     local zhaoAttack = self:__getZhaoAttackById(zhaoInfo:getId())

--     local duration = zhaoAttack:getDuration()

--     return duration
-- end

-- function ActiveSkillAttack:zhaoCombIsBeInterrupt()
--     return self.__zhaoCombIsInterrupt
-- end

-- --[[
--     @desc:在连招前添加buff
--     author:唐健
--     time:2021-07-05 23:25:48
--     --@buffParamsArray: 
--     @return:
-- ]]
-- function ActiveSkillAttack:__addBuffOnCompoStart()
--     -- 先判断添buff添加条件
--     self.__buffAdders = clone(self.__zhaoComb:getBuffAdders())

--     -- 测试接口
--     if TestBuffAdders then
--         self.__buffAdders = clone(TestBuffAdders)
--     end

--     -- 添加buff条件判断
--     local preConditionMap = {}
--     for i, buffAdder in ipairs(self.__buffAdders) do
--         local preConditionIsTrue = preConditionMap[buffAdder:getPreConditionId()] == nil or preConditionMap[buffAdder:getPreConditionId()] == true

--         if not preConditionIsTrue then
--             print("添加器前置条件不成立", buffAdder:getId())
--         end

--         if preConditionIsTrue and buffAdder:canAdd(self.__character.__character_sys:getFight(), self.__character, self.__character:getTarget()) then
--             preConditionMap[buffAdder:getContidionId()] = true
--             buffAdder:setNeedAdd(true)
--         else
--             preConditionMap[buffAdder:getContidionId()] = false
--             buffAdder:setNeedAdd(false)
--         end
--     end

--     -- 添加buff
--     for _, buffAdder in ipairs(self.__buffAdders) do
--         if buffAdder:needAdd() then
--             buffAdder:addBuffWhen(self.__character.__character_sys:getFight(), self.__character, self.__character:getTarget(), 0)
--         end
--     end
-- end

-- --[[
--     @desc:在连招后添加buff
--     author:唐健
--     time:2021-07-05 23:26:09
--     --@buffParamsArray: 
--     @return:
-- ]]
-- function ActiveSkillAttack:__addBuffOnCompoFinish()
--     for _, buffAdder in ipairs(self.__buffAdders) do
--         if buffAdder:needAdd() then
--             buffAdder:addBuffWhen(self.__character.__character_sys:getFight(), self.__character, self.__character:getTarget(), 1)
--         end
--     end
-- end

-- function ActiveSkillAttack:canContinueUseAuto()
--     return self.__isContinueAutoZhao
-- end

-- return newClass("ActiveSkillAttack", {ISkillAttack}, ActiveSkillAttack)
000000000000000