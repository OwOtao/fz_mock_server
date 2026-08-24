--[[
    author:Seven
    time:2022-11-17 17:12:47
    desc: 被动招式组合完成
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
local AutoAttackContext = require("app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext")

local FightActionQueuesSystem = require("app.FightSystem.FightActions.FightActionQueuesSystem")

--@RefType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@RefType [Constants]
local BUFF_CONSTANT = require("app.FightSystem.FightBuff.Constants")
local BUFF_ADDER_TRIGGER_TYPE = BUFF_CONSTANT.ADDER_TRIGGER_TYPE
local ADD_BUFF_NODE_TYEP = BUFF_CONSTANT.ADD_BUFF_NODE_TYEP
local BUFF_EFFECT_ON_TYPE = BUFF_CONSTANT.BUFF_MAKE_EFFECT_ON_NODE_TYPE

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local AutoCombFinish = {}

function AutoCombFinish:create(context)
    return AutoCombFinish.new():__init(context)
end

function AutoCombFinish:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context
    return self
end

function AutoCombFinish:onInit()
end

function AutoCombFinish:__handleTheLastAttack()
    -- 暂时无需处理的东西
end

function AutoCombFinish:onStart()
    FightUtil:printLog("组合攻击阶段：AutoCombFinish start")

    self:__handleTheLastAttack()

    self:__correctAndDoCombCharacterDead()

    self:__makeBuffEffectOn()

    self:__showOutputDesc()

    self:__handleBuff()

    --@desc 如果存在主动技能释放类型
    local operationCommand = self.__fight:getFirstOperationCommand()
    if operationCommand ~= nil and operationCommand:getCommandTypeId() == FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_ACTIVE_SKILL and not self.__context:getTarget():isDead() then
        if operationCommand:getCommanderId() == self.__context:getAttacker():getId() then
            --@desc 设置下一个主动技能释放
            local activeOperationCommand = self.__fight:popFirstOperationCommand()

            local canDo, failMsg = activeOperationCommand:canDoOperationCommand(self.__fight)

            if canDo == true then
                local AttackBattleActionUtil = require("app.FightSystem.BattleActions.AttackBattleAction.AttackBattleActionUtil")
                local battleAction = AttackBattleActionUtil:createAttackBattleActionFromOperationCommand(activeOperationCommand, self.__fight)
                self.__context:setNextAttackBattleAction(battleAction)
                self.__fight:notifyVeiwEvent(
                    require("app.FightSystem.Veiws.ViewEvents.Events.CharacterOperationRemoveViewEvent"):create(
                        activeOperationCommand:getCommanderId(),
                        activeOperationCommand:getOperationCommandId(),
                        true
                    )
                )
            else
                if activeOperationCommand:getCommanderId() == self.__fight:getPlayerId() and #failMsg > 0 then
                    self.__fight:popText(failMsg)
                end
                self.__fight:notifyVeiwEvent(
                    require("app.FightSystem.Veiws.ViewEvents.Events.CharacterOperationRemoveViewEvent"):create(
                        activeOperationCommand:getCommanderId(),
                        activeOperationCommand:getOperationCommandId(),
                        false
                    )
                )
            end

            self:finish()
            return
        end

        local canDo, failMsg = operationCommand:canDoOperationCommand(self.__fight)
        if canDo == true then
            --@desc 释放者非当前攻击者，打断当前攻击者继续释放组合攻击
            FightUtil:printLog("AutoCombFinish:onStart 主动技能非当前攻击者，执行跳回")
            --@RefType [src.app.FightSystem.BattleActions.BattleMoveActions.CharacterJumpBackAction#CharacterJumpBackAction]
            self.__jumpBackAction = require("app.FightSystem.BattleActions.BattleMoveActions.CharacterJumpBackAction"):create(self.__fight, self.__context)
            self.__jumpBackAction:start()
            return
        end
    end

    if self:__hasNextAutoCombAttack() then
        FightUtil:printLog("AutoCombFinish:onStart 进入下一个被动组合攻击")
        return self:finish()
    end

    if not self.__context:getAttacker():isDead() then
        FightUtil:printLog("AutoCombFinish:onStart 无下一个攻击组合，执行跳回")
        --@RefType [src.app.FightSystem.BattleActions.BattleMoveActions.CharacterJumpBackAction#CharacterJumpBackAction]
        self.__jumpBackAction = require("app.FightSystem.BattleActions.BattleMoveActions.CharacterJumpBackAction"):create(self.__fight, self.__context)
        self.__jumpBackAction:start()
    else
        FightUtil:printLog("AutoCombFinish:onStart 攻击者死亡，无需跳回，结束被动攻击阶段")
        return self:finish()
    end
end

function AutoCombFinish:onFinish()
    FightUtil:printLog("组合攻击阶段：AutoCombFinish finish")
end

function AutoCombFinish:onDestory()
end

function AutoCombFinish:onUpdate(ft)
    if self.__jumpBackAction ~= nil then
        if self.__jumpBackAction:isFinish() then
            self:finish()
            return
        else
            if self.__jumpBackAction:isStart() then
                self.__jumpBackAction:update(ft)
            end
        end
    else
        self:finish()
    end
end

--@desc: 判断是否能继续组合攻击，如果能将生成下一次组合攻击
--@author:Seven
--@time:2023-02-03 15:25:40
function AutoCombFinish:__hasNextAutoCombAttack()
    local attackerIsDead = self.__context:getAttacker():isDead()
    if attackerIsDead then
        return false
    end

    local targetIsDead = self.__context:getTarget():isDead()
    if targetIsDead then
        return false
    end

    local AutoAttackAction = require("app.FightSystem.FightActions.AutoAttackAction")

    --@RefType [src.app.FightSystem.FightActions.AutoAttackAction#AutoAttackAction]
    local autoAction = AutoAttackAction:create()

    autoAction:init(self.__context:getAttacker():getId(), self.__fight:getCurrentFrameIndex(), self.__fight)

    local canRelease = autoAction:checkPreRelease()

    if canRelease == true then
        self.__context:setNextAttackBattleAction(autoAction:getAndDoAttackAction())
        return true
    end

    return false
end

--@desc: 招式组合结束文本输出
--@author:Seven
--@time:2023-02-27 14:29:12
function AutoCombFinish:__showOutputDesc()
    if not self.__context:isHasZhaoAttack() then
        FightUtil:printLog("没有招式攻击结果进行输出，可能攻击者或者受击者在组合开始阶段已死亡")
        return
    end

    local AutoCombFinishVisitor = require("app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.ZhaoAttackVisitor.AutoCombFinishVisitor")

    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.ZhaoAttackVisitor.AutoCombFinishVisitor#AutoCombFinishVisitor]
    local descVisitor = AutoCombFinishVisitor:create(self.__context)

    self.__context:walkAllZhaoAttackInTheCombAttack(
        function(index, zhaoAttack)
            -- --@RefType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
            -- zhaoAttack = zhaoAttack
            zhaoAttack:runAttackResultVisitor(descVisitor)
        end
    )

    self.__context:walkAllCharacterEffectModifierAttrs(
        function(index, modifierAttr)
            descVisitor:visitorEffectModifierAttr(modifierAttr)
        end
    )

    local texts = descVisitor:getZhaoOutputTexts()
    for _, text in ipairs(texts) do
        self.__fight:showPrintText(text)
    end

    local effectPrintText, effectPopText = descVisitor:getEffectPrintAndPopTexts()
    for _, text in ipairs(effectPrintText) do
        self.__fight:showPrintText(text)
    end

    for _, pop in ipairs(effectPopText) do
        self.__fight:notifyVeiwEvent(require("app.FightSystem.Veiws.ViewEvents.Events.CharacterPopHeadTextViewEvent"):create(pop.id, pop.text))
    end
end

--@desc: 检查修正并执行组合攻击关联的攻守双方是否进入死亡状态
--@author:Seven
--@time:2023-03-02 20:51:16
function AutoCombFinish:__correctAndDoCombCharacterDead()
    local attacker = self.__context:getAttacker()

    if not attacker:isDead() then
        attacker:updateSelfAlive()
    end

    local target = self.__context:getTarget()

    if not target:isDead() then
        target:updateSelfAlive()
    end
end

--@desc: 处理buff相关逻辑
--@author:Seven
--@time:2023-03-12 18:18:53
function AutoCombFinish:__handleBuff()
    self:__triggerBuffAdder()
    self:__execAddBuff()

    for _, character in ipairs(self.__fight:getCharacters()) do
        --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
        character = character
        if not character:isDead() then
            character:updateSelfAlive()
        end
        character:updateViews()
    end
end

function AutoCombFinish:__makeBuffEffectOn()
    local attacker = self.__context:getAttacker()
    local target = self.__context:getTarget()
    if not attacker:isDead() then
        attacker:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoCombFinish, self.__context)
        attacker:tryRemoveBuffs()
    end

    if not target:isDead() then
        target:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoCombFinish, self.__context)
        target:tryRemoveBuffs()
    end

    local characters = self.__fight:getCharacters()

    for _, character in ipairs(characters) do
        if not character:isDead() then
            character:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAnyCombFinish, self.__context)
        end
    end

    for _, character in ipairs(characters) do
        character:tryRemoveBuffs()
        if not character:isDead() then
            character:updateSelfAlive()
        end
    end

    self.__fight:showAndClearDeleteBuffDesc()
end

local triggerBuffAdder = function(t_type, context, fightCharacter)
    local list = fightCharacter:getAdderGroupByAdderTriggerType(t_type)

    if table.getn(list) <= 0 then
        return
    end

    for _, adderGroup in ipairs(list) do
        -- --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdderGroup#AFightCharacterBuffAdderGroup]
        -- adderGroup = adderGroup
        adderGroup:triggerBuffAdder(t_type, context)
    end
end

local triggerAttackerBuffAdder = function(t_type, context)
    return triggerBuffAdder(t_type, context, context:getAttacker())
end

local triggerTargetBuffAdder = function(t_type, context)
    return triggerBuffAdder(t_type, context, context:getTarget())
end

--@desc: 触发buff添加器
--@author:Seven
--@time:2023-03-12 16:53:34
function AutoCombFinish:__triggerBuffAdder()
    local isAllHit = true
    local hasDodge = false
    local hasParry = false

    local HIT_TYPE_HIT = FightCommons.ATTACK_HIT_TYPE

    for _, zhaoAttack in ipairs(self.__context:getAllZhaoAttackInTheCombAttack()) do
        --@RefType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
        zhaoAttack = zhaoAttack

        local hitType = zhaoAttack:getHitType()

        -- 是否命中
        if hitType == HIT_TYPE_HIT.HIT then
        else
            isAllHit = false
        end

        if hitType == HIT_TYPE_HIT.DODGE then
            -- 闪避
            hasDodge = true
        elseif hitType == HIT_TYPE_HIT.PARRY then
            -- 招架
            hasParry = true
        end
    end

    if isAllHit then
        triggerAttackerBuffAdder(BUFF_ADDER_TRIGGER_TYPE.AUTO_ATTACK_ALL_HIT, self.__context)
        triggerTargetBuffAdder(BUFF_ADDER_TRIGGER_TYPE.AUTO_TARGET_BE_ATTACK_ALL_HIT, self.__context)
    end

    if hasParry then
        triggerAttackerBuffAdder(BUFF_ADDER_TRIGGER_TYPE.AUTO_ATTACK_HAS_PARRY, self.__context)
        triggerTargetBuffAdder(BUFF_ADDER_TRIGGER_TYPE.AUTO_TARGET_BE_ATTACK_HAS_PARRY, self.__context)
    end

    if hasDodge then
        triggerAttackerBuffAdder(BUFF_ADDER_TRIGGER_TYPE.AUTO_ATTACK_HAS_DODGE, self.__context)
        triggerTargetBuffAdder(BUFF_ADDER_TRIGGER_TYPE.AUTO_TARGET_BE_ATTACK_HAS_DODGE, self.__context)
    end
end

--@desc: 执行添加buff
--@author:Seven
--@time:2023-03-11 18:05:18
function AutoCombFinish:__execAddBuff()
    local AddBuffUtil = require("app.FightSystem.FightRole.CharacterBuff.Utils.AddBuffUtil")

    AddBuffUtil:execAddBuff(self.__fight, self.__context:getAttacker(), ADD_BUFF_NODE_TYEP.AUTO_COMB_FINISH)

    self.__fight:showAndClearAddBuffDesc()

    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterAddBuffsViewEvent":create(self.__fight, self.__fight))

    self.__fight:clearBuffEffectHurts()
end

return newClass("AutoCombFinish", {ABaseBattleAction}, AutoCombFinish)
00000