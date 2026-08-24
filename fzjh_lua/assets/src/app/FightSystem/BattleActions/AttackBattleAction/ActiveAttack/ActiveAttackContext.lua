--[[
    author:Seven
    time:2022-11-18 17:26:22
    desc: 武学被动攻击上下文，
     
    生命周期：一次被动攻击组合攻击


    -- 攻击者
    -- 攻击组合
]]
local newClass = require("third.class.NewClass")

local FightFormula = require("app.FightSystem.FightFormula")

local AttackHitPosManager = require("app.FightSystem.ResourceManager.AttackHitPosClassManager")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BasicCombHurt = require("app.FightSystem.CharacterHurt.AttackHurt.BasicCombHurt")

local isImpl = require("third.assertIsInstance.assertIsInstance")

local ActiveAttackContext = {}

function ActiveAttackContext:create(activeSkillId)
    return ActiveAttackContext.new():__init(activeSkillId)
end

function ActiveAttackContext:__init(activeSkillId)
    self.__combNeedJump = false

    self.__activeSkillId = activeSkillId

    self.__adderGroups = {}

    self.__effectModifierAttrList = {}

    self.__oneOffEffectList = {}

    return self
end

--@desc: 告知上下文攻击者id
--@author:Seven
--@time:2022-12-08 15:25:53
--@c_id: 攻击者id
function ActiveAttackContext:setAttackerId(c_id)
    self.__attackerId = c_id
end

--@desc: 告知上下文受击者id
--@author:Seven
--@time:2022-12-08 15:26:08
--@t_id: 受击者id
function ActiveAttackContext:setTargetId(t_id)
    self.__targetId = t_id
end

function ActiveAttackContext:setFight(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight
end

function ActiveAttackContext:getFight()
    return self.__fight
end

--@desc: 组合攻击开始是否需要跳跃
--@author:Seven
--@time:2022-12-15 14:51:04
--@return: true | false
function ActiveAttackContext:combAttackIsNeedToJump()
    if self.__attackComb:isJumpAttack() and self.__attacker:isInOrignPos() then
        return true
    end

    return false
end

--@desc: 跳跃落地跟目标的偏移距离
--@author:Seven
--@time:2023-02-19 20:53:58
function ActiveAttackContext:getJumpForwardOffset()
    local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

    local offset = BattleConstConf:get("activeZhaoJumpAttackDistance")

    if self.__attackComb:isAttackActiveComb() then
        local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")
        local currentAttack = self:getCurrZhaoAttack()
        offset = AnimResManager:getAttackAnimOffset(currentAttack:getAttackerAnim())
    end

    return offset
end

--@desc: 初始化攻击上下文
--@author:Seven
--@time:2022-12-08 15:35:41
function ActiveAttackContext:initAttackConext()
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__attacker = self.__fight:getCharacter(self.__attackerId)

    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__target = self.__fight:getCharacter(self.__targetId)

    --@desc 主动技能
    --@RefType [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
    self.__attackerSkill = self.__attacker:getActiveSkill(self.__activeSkillId)

    --@desc 使用的攻击招式组合
    --@RefType [src.app.FightSystem.FightSkill.ActiveZhao.BasicFightActiveZhaoCombination#BasicFightActiveZhaoCombination]
    self.__attackComb = self.__attackerSkill:getAttackZhaoComb()

    --@desc 当前攻击进行到第几招
    self.__currZhaoAttackIndex = 0

    --@desc 存放招式攻击结果
    self.__zhaoAttackList = {}
end

--@desc:攻击者
--@author:Seven
--@time:2022-12-29 16:27:23
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function ActiveAttackContext:getAttacker()
    return self.__attacker
end

--@desc: 受击者
--@author:Seven
--@time:2022-12-29 16:27:13
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function ActiveAttackContext:getTarget()
    return self.__target
end

--@desc: 当前攻击用得武学技能
--@author:Seven
--@time:2022-12-14 17:47:50
--@return [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
function ActiveAttackContext:getAttackSkill()
    return self.__attackerSkill
end

--@desc: 获取当前攻击使用的攻击组合
--@author:Seven
--@time:2022-12-08 16:26:27
--@return [src.app.FightSystem.FightSkill.ActiveZhao.BasicFightActiveZhaoCombination#BasicFightActiveZhaoCombination]
function ActiveAttackContext:getAttackComb()
    return self.__attackComb
end

--@desc: 招式组合攻击消耗的体力
--@author:Seven
--@time:2022-12-08 15:58:56
function ActiveAttackContext:getAttackCostTili()
    if self.__attackCostTili == nil then
        self.__attackCostTili = self.__attackerSkill:getTiliCost()
    end

    return self.__attackCostTili
end

--@desc: 招式组合攻击消耗的内力
--@author:Seven
--@time:2022-12-08 15:59:15
function ActiveAttackContext:getAttackCostNeili()
    if self.__attackCostNeili == nil then
        self.__attackCostNeili = self.__attackerSkill:getNeiliCost()
    end
    return self.__attackCostNeili
end

--@desc: 招式组合攻击随机攻击位置，文本展示需求
--@author:Seven
--@time:2022-12-09 21:24:06
function ActiveAttackContext:getCombHitPosName()
    if self.__combHitPosName == nil then
        local hurtPosClass = self.__attackComb:getHurtPosClass()

        self.__combHitPosName = AttackHitPosManager:randomHitPosNameByPosClass(hurtPosClass)
    end

    return self.__combHitPosName
end

--@desc: 获取招式攻击结果
--@author:Seven
--@time:2023-02-08 17:15:17
function ActiveAttackContext:getCombHurts()
    if self.__combHurts == nil then
        self.__combHurts = {}
        local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")
        local hurtIds = self.__attackComb:getHurtIDs()

        for _, hurtID in ipairs(hurtIds) do
            local activeZhaoHurt = ZhaoHurtDegreeFactory:createActiveZhaoHurt(hurtID)

            activeZhaoHurt:setCharacter(self.__attacker)

            local activeZhaoHurtValue = activeZhaoHurt:getHurtValue()

            local attrName = activeZhaoHurt:getChangeAttrName()

            if attrName == "qi" then
                --@desc 是否能穿透护盾
                local isBypassShield = false
                if activeZhaoHurt:getBreakShield() then
                    isBypassShield = true
                end
                local hurt = BasicCombHurt:create(attrName, activeZhaoHurtValue, activeZhaoHurt:getHurtDes(), isBypassShield)
                table.insert(self.__combHurts, hurt)
            else
                local hurt = BasicCombHurt:create(attrName, activeZhaoHurtValue, activeZhaoHurt:getHurtDes(), false)
                table.insert(self.__combHurts, hurt)
            end
        end
    end

    return self.__combHurts
end

--@desc: 判断是否有招式攻击结果
--@author:Seven
--@time:2023-03-24 20:21:29
function ActiveAttackContext:isHasZhaoAttack()
    return table.getn(self.__zhaoAttackList) > 0
end

--@desc: 获取当前组合攻击所有攻击结果
--@author:Seven
--@time:2023-01-06 17:31:41
function ActiveAttackContext:getAllZhaoAttackInTheCombAttack()
    if table.getn(self.__zhaoAttackList) == 0 then
        error("当前组合攻击并未生成攻击结果，不可获取，请查看调用流程")
    end

    return self.__zhaoAttackList
end

--@desc: 遍历招式攻击所有结果
--@author:Seven
--@time:2023-02-02 21:27:34
--@func: 遍历执行方法
function ActiveAttackContext:walkAllZhaoAttackInTheCombAttack(func)
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
function ActiveAttackContext:hasNextZhaoAttack()
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
function ActiveAttackContext:getNextZhaoAttack()
    if self.__currZhaoAttackIndex + 1 > self.__attackComb:getAttackCount() then
        error("当前招式攻击结果数量已超出招式组合拥有的攻击招式数量，检查代码")
    end

    local zhaoAttack = self.__zhaoAttackList[self.__currZhaoAttackIndex + 1]

    if zhaoAttack == nil then
        error("ActiveAttackContext:getNextZhaoAttack() 没有下一招")
    end

    return zhaoAttack
end

--@desc: 获取下一个攻击招式
--@author:Seven
--@time:2023-02-06 14:43:29
--@return: [src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoInfo#BasicAutoZhaoInfo]
function ActiveAttackContext:getNextZhao()
    if self.__currZhaoAttackIndex + 1 > self.__attackComb:getAttackCount() then
        error("ActiveAttackContext:getNextZhao 超出组合最大攻击招式数，无法获取")
    end
    return self.__attackComb:getBasicZhaoInfo(self.__currZhaoAttackIndex + 1)
end

--@desc: 获取新的招式攻击
--@author:Seven
--@time:2023-02-01 17:20:20
--@return: [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
function ActiveAttackContext:getNextNewZhaoAttack()
    local ActiveZhaoAttackFactory = require("app.FightSystem.ZhaoAttacks.ZhaoAttackFactory.ActiveZhaoAttackFactory")

    local zhaoAttack = ActiveZhaoAttackFactory:create(self):getZhaoAttack()

    return zhaoAttack
end

--@desc: 获取前置招式
--@author:Seven
--@time:2023-02-19 16:29:08
--@return [src.app.FightSystem.ZhaoAttacks.None.BasicAtkNone#BasicAtkNone]
function ActiveAttackContext:getReadyZhaoAttack()
    if self.__readyZhaoAttack == nil then
        local readyZhao = self.__attackComb:getReadyZhaoInfo()
        if readyZhao ~= nil then
            self.__readyZhaoAttack = require("app.FightSystem.ZhaoAttacks.None.BasicAtkNone"):create(self, readyZhao)
        else
            return nil
        end
    end

    return self.__readyZhaoAttack
end

--@desc: 设置下一招攻击
--@author:Seven
--@time:2023-02-01 17:00:37
--@zhaoAttack: [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
function ActiveAttackContext:setNextZhaoAttack(zhaoAttack)
    if zhaoAttack == nil then
        error("ActiveAttackContext:setNextZhaoAttack 参数不可为空")
    end

    if self.__currZhaoAttackIndex + 1 > self.__attackComb:getAttackCount() then
        error("ActiveAttackContext:setNextZhaoAttack 当前招式攻击结果数量已超出招式组合拥有的攻击招式数量，不可再次添加")
    end

    self.__currZhaoAttackIndex = self.__currZhaoAttackIndex + 1

    table.insert(self.__zhaoAttackList, zhaoAttack)
end

--@desc: 获取当前正在执行的攻击(可能为空)
--@author:Seven
--@time:2023-01-06 17:28:26
--@return  [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
function ActiveAttackContext:getCurrZhaoAttack()
    return self.__zhaoAttackList[self.__currZhaoAttackIndex]
end

function ActiveAttackContext:setNextAttackBattleAction(battleAction)
    self.__nextAttackBattleAction = battleAction
end

function ActiveAttackContext:getNextAttackBattleAction()
    return self.__nextAttackBattleAction
end

--@desc: 添加当前上下文中生效的buff添加器
--@author:Seven
--@time:2023-03-11 14:59:42
function ActiveAttackContext:addBuffAdderGroupIndex(addGroupIndex)
    table.insert(self.__adderGroups, addGroupIndex)
end

--@desc: 获取当前上下文中存在的buff添加器
--@author:Seven
--@time:2023-03-11 15:04:15
function ActiveAttackContext:getBuffAdderGroupIndexs()
    return self.__adderGroups
end

function ActiveAttackContext:clearBuffAdderGroupIndex()
    self.__adderGroups = {}
end

function ActiveAttackContext:addCharacterEffectModifierAttr(hurt)
    table.insert(self.__effectModifierAttrList, isImpl(hurt, require("app.FightSystem.CharacterHurt.BuffEffectHurt.ABuffEffectModifierAttr")))
end

function ActiveAttackContext:walkAllCharacterEffectModifierAttrs(func)
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
function ActiveAttackContext:addOneOffEffect(animTriggerEventName, animId, buffOwnerId)
    table.insert(self.__oneOffEffectList, {animTriggerEventName = animTriggerEventName, animId = animId, buffOwnerId = buffOwnerId})
end

function ActiveAttackContext:getOneOffEffectsByTriggerEventName(eventName)
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
--@activeSkillId: 主动技能id
--@return [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext#ActiveAttackContext]
function ActiveAttackContext.createContext(fight, attackerId, targetId, activeSkillId)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext#ActiveAttackContext]
    local context = ActiveAttackContext:create(activeSkillId)

    context:setAttackerId(attackerId)

    context:setTargetId(targetId)

    context:setFight(fight)

    context:initAttackConext()

    return context
end

return newClass("ActiveAttackContext", {}, ActiveAttackContext)
000