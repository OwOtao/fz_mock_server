--[[
    author:Seven
    time:2022-11-18 17:26:22
    desc: 武学被动攻击上下文，
     
    生命周期：一次被动攻击组合攻击


    -- 攻击者
    -- 攻击组合
]]
local newClass = require("third.class.NewClass")

local isImpl = require("third.assertIsInstance.assertIsInstance")

local FightFormula = require("app.FightSystem.FightFormula")

local AttackHitPosManager = require("app.FightSystem.ResourceManager.AttackHitPosClassManager")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BasicCombHurt = require("app.FightSystem.CharacterHurt.AttackHurt.BasicCombHurt")

local AutoAttackContext = {}

function AutoAttackContext:create()
    return AutoAttackContext.new():__init()
end

function AutoAttackContext:__init()
    self.__combNeedJump = false

    self.__adderGroups = {}

    self.__effectModifierAttrList = {}
    return self
end

--@desc: 告知上下文攻击者id
--@author:Seven
--@time:2022-12-08 15:25:53
--@c_id: 攻击者id
function AutoAttackContext:setAttackerId(c_id)
    self.__attackerId = c_id
end

--@desc: 告知上下文受击者id
--@author:Seven
--@time:2022-12-08 15:26:08
--@t_id: 受击者id
function AutoAttackContext:setTargetId(t_id)
    self.__targetId = t_id
end

function AutoAttackContext:setFight(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight
end

--@desc: 获取战场
--@author:Seven
--@time:2023-03-31 21:15:58
--@return [src.app.FightSystem.Fight.BattleSystem#Fight]
function AutoAttackContext:getFight()
    return self.__fight
end

--@desc: 组合攻击开始是否需要跳跃
--@author:Seven
--@time:2022-12-15 14:51:04
--@return: true | false
function AutoAttackContext:combAttackIsNeedToJump()
    return self.__attacker:isInOrignPos()
end

function AutoAttackContext:getJumpForwardOffset()
    local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")
    local currentAttack = self:getCurrZhaoAttack()
    return AnimResManager:getAttackAnimOffset(currentAttack:getAttackerAnim())
end

--@desc: 初始化攻击上下文
--@author:Seven
--@time:2022-12-08 15:35:41
function AutoAttackContext:initAttackConext()
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__attacker = self.__fight:getCharacter(self.__attackerId)

    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__target = self.__fight:getCharacter(self.__targetId)

    --@desc 攻击用武学
    --@RefType [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
    self.__attackerSkill = self.__attacker:getAttackSkill()

    --@desc 使用的攻击招式组合
    --@RefType [src.app.FightSystem.FightSkill.AutoZhao.BasicFightAutoZhaoCombination#BasicFightAutoZhaoCombination]
    self.__attackComb = self.__attackerSkill:getAttackZhaoComb()

    --@desc 当前攻击进行到第几招
    self.__currZhaoAttackIndex = 0

    --@desc 初始化目标气血阶段
    self.__targetCombStartQiStage = self.__target:getQiStage()

    --@desc 存放招式攻击结果
    self.__zhaoAttackList = {}

    self.__oneOffEffectList = {}
end

--@desc:攻击者
--@author:Seven
--@time:2022-12-29 16:27:23
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function AutoAttackContext:getAttacker()
    return self.__attacker
end

--@desc: 受击者
--@author:Seven
--@time:2022-12-29 16:27:13
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function AutoAttackContext:getTarget()
    return self.__target
end

--@desc: 获取受击目标开始时气血阶段
--@author:Seven
--@time:2023-02-27 14:51:14
function AutoAttackContext:getTargetCombStartQiStage()
    return self.__targetCombStartQiStage
end

--@desc: 当前攻击用得武学技能
--@author:Seven
--@time:2022-12-14 17:47:50
--@return: [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function AutoAttackContext:getAttackSkill()
    return self.__attackerSkill
end

--@desc: 获取当前攻击使用的攻击组合
--@author:Seven
--@time:2022-12-08 16:26:27
--@return: [src.app.FightSystem.FightSkill.AutoZhao.BasicFightAutoZhaoCombination#BasicFightAutoZhaoCombination]
function AutoAttackContext:getAttackComb()
    return self.__attackComb
end

--@desc: 招式组合攻击消耗的体力
--@author:Seven
--@time:2022-12-08 15:58:56
function AutoAttackContext:getAttackCostTili()
    if self.__attackCostTili == nil then
        self.__attackCostTili = self.__attackComb:getCostTili()
    end

    return self.__attackCostTili
end

--@desc: 招式组合攻击消耗的内力
--@author:Seven
--@time:2022-12-08 15:59:15
function AutoAttackContext:getAttackCostNeili()
    if self.__attackCostNeili == nil then
        self.__attackCostNeili = self.__attackComb:getCostNeili()
    end
    return self.__attackCostNeili
end

--@desc: 招式组合攻击随机攻击位置，文本展示需求
--@author:Seven
--@time:2022-12-09 21:24:06
function AutoAttackContext:getCombHitPosName()
    if self.__combHitPosName == nil then
        local hurtPosClass = self.__attackComb:getHurtPosClass()

        self.__combHitPosName = AttackHitPosManager:randomHitPosNameByPosClass(hurtPosClass)
    end

    return self.__combHitPosName
end

--@desc: 获取招式攻击结果
--@author:Seven
--@time:2023-02-08 17:15:17
function AutoAttackContext:getCombHurts()
    if self.__combHurts == nil then
        self.__combHurts = {}
        local qiValue = FightFormula:calAutoZhaoQiDamageAttackValue(self.__attackComb, self.__attacker, self.__target)
        local qiHurt = BasicCombHurt:create("qi", qiValue, self.__attackComb:getDamageType(), self.__attacker:getBuffAddAttr("autoPassQiShiled") > 0)
        table.insert(self.__combHurts, qiHurt)

        local disabilityProbability = FightFormula:calDisabilityProbability(self.__attackComb, self.__attacker, self.__target)
        local qiMaxValue = FightFormula:calAutoZhaoQiMaxDamageAttackValue(qiValue, disabilityProbability, self.__attackComb, self.__attacker, self.__target)
        local qiMaxHurt = BasicCombHurt:create("qiMax", qiMaxValue, self.__attackComb:getDamageType(), false)
        table.insert(self.__combHurts, qiMaxHurt)
    end

    return self.__combHurts
end

--@desc: 判断是否有招式攻击结果
--@author:Seven
--@time:2023-03-24 20:21:29
function AutoAttackContext:isHasZhaoAttack()
    return table.getn(self.__zhaoAttackList) > 0
end

--@desc: 获取当前组合攻击所有攻击结果
--@author:Seven
--@time:2023-01-06 17:31:41
function AutoAttackContext:getAllZhaoAttackInTheCombAttack()
    if table.getn(self.__zhaoAttackList) == 0 then
        error("当前组合攻击并未生成攻击结果，不可获取，请查看调用流程")
    end

    return self.__zhaoAttackList
end

--@desc: 遍历招式攻击所有结果
--@author:Seven
--@time:2023-02-02 21:27:34
--@func: 遍历执行方法
function AutoAttackContext:walkAllZhaoAttackInTheCombAttack(func)
    for i, v in ipairs(self:getAllZhaoAttackInTheCombAttack()) do
        if func(i, v) == true then
            break
        end
    end
end

--@desc: 获取是否还有能进行下一次招式攻击
--@author:Seven
--@time:2023-02-02 21:26:13
--@return: true | false
function AutoAttackContext:hasNextZhaoAttack()
    if self.__attacker:isDead() or self.__target:isDead() then
        return false
    end

    local nextIndex = self.__currZhaoAttackIndex + 1
    if nextIndex > self.__attackComb:getAttackCount() then
        return false
    end

    return true
end

--@desc: 获取下一个招式攻击结果
--@author:Seven
--@time:2023-01-06 17:20:20
--@return  [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
function AutoAttackContext:getNextZhaoAttack()
    if self.__currZhaoAttackIndex + 1 > self.__attackComb:getAttackCount() then
        error("当前招式攻击结果数量已超出招式组合拥有的攻击招式数量，检查代码")
    end

    local zhaoAttack = self.__zhaoAttackList[self.__currZhaoAttackIndex + 1]

    if zhaoAttack == nil then
        error("AutoAttackContext:getNextZhaoAttack() 没有下一招")
    end

    return zhaoAttack
end

--@desc: 获取下一个攻击招式
--@author:Seven
--@time:2023-02-06 14:43:29
--@return: [src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoInfo#BasicAutoZhaoInfo]
function AutoAttackContext:getNextZhao()
    if self.__currZhaoAttackIndex + 1 > self.__attackComb:getAttackCount() then
        error("AutoAttackContext:getNextZhao 超出组合最大攻击招式数，无法获取")
    end
    return self.__attackComb:getBasicZhaoInfo(self.__currZhaoAttackIndex + 1)
end

--@desc: 获取新的招式攻击
--@author:Seven
--@time:2023-02-01 17:20:20
--@return: [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
function AutoAttackContext:getNextNewZhaoAttack()
    --@RefType [src.app.FightSystem.ZhaoAttacks.ZhaoAttackFactory.AutoZhaoAttackFactory#AutoZhaoAttackFactory]
    local AutoZhaoAttackFactory = require("app.FightSystem.ZhaoAttacks.ZhaoAttackFactory.AutoZhaoAttackFactory")

    local zhaoAttack = AutoZhaoAttackFactory:create(self):getZhaoAttack()

    return zhaoAttack
end

--@desc: 设置下一招攻击
--@author:Seven
--@time:2023-02-01 17:00:37
--@zhaoAttack: [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
function AutoAttackContext:setNextZhaoAttack(zhaoAttack)
    if zhaoAttack == nil then
        error("AutoAttackContext:setNextZhaoAttack 参数不可为空")
    end

    if self.__currZhaoAttackIndex + 1 > self.__attackComb:getAttackCount() then
        error("AutoAttackContext:setNextZhaoAttack 当前招式攻击结果数量已超出招式组合拥有的攻击招式数量，不可再次添加")
    end

    self.__currZhaoAttackIndex = self.__currZhaoAttackIndex + 1

    table.insert(self.__zhaoAttackList, zhaoAttack)
end

--@desc: 获取当前正在执行的攻击(可能为空)
--@author:Seven
--@time:2023-01-06 17:28:26
--@return  [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
function AutoAttackContext:getCurrZhaoAttack()
    return self.__zhaoAttackList[self.__currZhaoAttackIndex]
end

function AutoAttackContext:setNextAttackBattleAction(battleAction)
    self.__nextAttackBattleAction = battleAction
end

function AutoAttackContext:getNextAttackBattleAction()
    return self.__nextAttackBattleAction
end

--@desc: 添加当前上下文中生效的buff添加器
--@author:Seven
--@time:2023-03-11 14:59:42
function AutoAttackContext:addBuffAdderGroupIndex(addGroupIndex)
    table.insert(self.__adderGroups, addGroupIndex)
end

--@desc: 获取当前上下文中存在的buff添加器
--@author:Seven
--@time:2023-03-11 15:04:15
function AutoAttackContext:getBuffAdderGroupIndexs()
    return self.__adderGroups
end

function AutoAttackContext:clearBuffAdderGroupIndex()
    self.__adderGroups = {}
end

function AutoAttackContext:addCharacterEffectModifierAttr(hurt)
    table.insert(self.__effectModifierAttrList, isImpl(hurt, require("app.FightSystem.CharacterHurt.BuffEffectHurt.ABuffEffectModifierAttr")))
end

function AutoAttackContext:walkAllCharacterEffectModifierAttrs(func)
    if table.getn(self.__effectModifierAttrList) <= 0 then
        return
    end

    for i, hurt in ipairs(self.__effectModifierAttrList) do
        if func(i, hurt) == true then
            break
        end
    end
end

--@desc: 添加一个一次性的特效，这个特效只会在当前攻击中生效，不会被保存到战斗中，只会在当前攻击组合的招式攻击中生效，用于一些特殊攻击时的特效
--@author:Seven
--@time:2023-03-29 16:07:19
--@animTriggerEventName: 特效触发事件名（动画内配置）
--@animId: 特效id
--@buffOwnerId: 特效拥有者id
function AutoAttackContext:addOneOffEffect(animTriggerEventName, animId, buffOwnerId)
    table.insert(self.__oneOffEffectList, {animTriggerEventName = animTriggerEventName, animId = animId, buffOwnerId = buffOwnerId})
end

function AutoAttackContext:getOneOffEffectsByTriggerEventName(eventName)
    local list = {}
    for i, v in ipairs(self.__oneOffEffectList) do
        if v.animTriggerEventName == eventName then
            table.insert(list, v)
        end
    end
    return list
end

--@desc: 创建一个新的上下文
--@author:Seven
--@time:2023-02-03 14:38:04
--@fight: [src.app.FightSystem.Fight.BattleSystem#Fight]
--@attacekrId: 攻击者id
--@targetId: 目标id
--@return: src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext
function AutoAttackContext.createContext(fight, attackerId, targetId)
    local context = AutoAttackContext:create()

    context:setAttackerId(attackerId)

    context:setTargetId(targetId)

    context:setFight(fight)

    context:initAttackConext()

    return context
end

return newClass("AutoAttackContext", {}, AutoAttackContext)
00