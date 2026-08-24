--[[
    author:Seven
    time:2022-11-17 17:12:47
    desc: 被动招式组合完成
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@RefType [src.app.FightSystem.FightActions.FightActionQueuesSystem#FightActionQueuesSystem]
local FightActionQueuesSystem = require("app.FightSystem.FightActions.FightActionQueuesSystem")

--@RefType [Constants]
local BUFF_CONSTANT = require("app.FightSystem.FightBuff.Constants")
local BUFF_ADDER_TRIGGER_TYPE = BUFF_CONSTANT.ADDER_TRIGGER_TYPE
local ADD_BUFF_NODE_TYEP = BUFF_CONSTANT.ADD_BUFF_NODE_TYEP
local BUFF_EFFECT_TYPE = BUFF_CONSTANT.BUFF_MAKE_EFFECT_ON_NODE_TYPE

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ActiveCombFinish = {}

function ActiveCombFinish:create(context)
    return ActiveCombFinish.new():__init(context)
end

function ActiveCombFinish:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext#ActiveAttackContext]
    self.__context = context
    return self
end

function ActiveCombFinish:onInit()
end

function ActiveCombFinish:onStart()
    FightUtil:printFormatLog("组合攻击阶段：ActiveCombFinish start : %s , 技能：【%s】", self.__context:getAttacker():getAttr("name"), self.__context:getAttackSkill():getName())

    self:__correctAndDoCombCharacterDead()

    self:__makeBuffEffectOn()

    self:__showOutputDesc()

    --@desc 触发主动组合结束添加buff
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

    --@desc 主动技能接被动组合
    if self:__hasNextAutoCombAttack() then
        FightUtil:printLog("ActiveCombFinish:onStart 进入下一个被动组合攻击")
        return self:finish()
    end

    if not self.__context:getAttacker():isDead() and not self.__context:getAttacker():isInOrignPos() then
        --@RefType [src.app.FightSystem.BattleActions.BattleMoveActions.CharacterJumpBackAction#CharacterJumpBackAction]
        self.__jumpAction = require("app.FightSystem.BattleActions.BattleMoveActions.CharacterJumpBackAction"):create(self.__fight, self.__context)
        self.__jumpAction:start()
    else
        return self:finish()
    end
end

function ActiveCombFinish:__hasNextAutoCombAttack()
    if self.__context:getAttackComb():isCompletionUseAuto() ~= true then
        return false
    end

    if self.__context:getAttacker():isDead() then
        return false
    end

    if self.__context:getTarget():isDead() then
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

function ActiveCombFinish:onFinish()
    FightUtil:printLog("组合攻击阶段：ActiveCombFinish finish")
end

function ActiveCombFinish:onDestory()
end

function ActiveCombFinish:onUpdate(ft)
    if self.__jumpAction ~= nil then
        if self.__jumpAction:isFinish() then
            self:finish()
            return
        else
            if self.__jumpAction:isStart() then
                self.__jumpAction:update(ft)
            end
        end
    else
        self:finish()
    end
end

function ActiveCombFinish:__showOutputDesc()
    if not self.__context:isHasZhaoAttack() then
        FightUtil:printLog("没有招式攻击结果进行输出，可能攻击者或者受击者在组合开始阶段已死亡")
        return
    end

    local ActiveCombFinishVisitor = require("app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ZhaoAttackVisitor.ActiveCombFinishVisitor")

    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ZhaoAttackVisitor.ActiveCombFinishVisitor#ActiveCombFinishVisitor]
    local descVisitor = ActiveCombFinishVisitor:create(self.__context)

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

--@desc: 检查并执行组合攻击关联的攻守双方是否进入死亡状态
--@author:Seven
--@time:2023-03-02 20:51:16
function ActiveCombFinish:__correctAndDoCombCharacterDead()
    local attacker = self.__context:getAttacker()

    --@desc 修正属性
    if not attacker:isDead() then
        attacker:correctAttrLimit()
    end

    if attacker:canDead() then
        attacker:killCharacter()
    end

    local target = self.__context:getTarget()

    if not target:isDead() then
        target:getTarget():correctAttrLimit()
    end

    if target:canDead() then
        target:killCharacter()
    end
end

--@desc: 处理buff相关逻辑
--@author:Seven
--@time:2023-03-12 18:18:53
function ActiveCombFinish:__handleBuff()
    self:__execAddBuff()
    self:__removeBuffAdderGroup()

    local characters = self.__fight:getCharacters()
    for _, character in ipairs(characters) do
        if not character:isDead() then
            character:updateSelfAlive()
        end

        character:updateViews()
    end
end

--@desc: 执行添加buff
--@author:Seven
--@time:2023-03-11 18:05:18
function ActiveCombFinish:__execAddBuff()
    local AddBuffUtil = require("app.FightSystem.FightRole.CharacterBuff.Utils.AddBuffUtil")

    AddBuffUtil:execAddBuff(self.__fight, self.__context:getAttacker(), ADD_BUFF_NODE_TYEP.ACTIVE_COMB_FINISH)

    self.__fight:showAndClearAddBuffDesc()

    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterAddBuffsViewEvent":create(self.__fight, self.__fight))

    self.__fight:clearBuffEffectHurts()
end

--@desc: 生效buff
--@author:Seven
--@time:2023-10-17 16:22:03
function ActiveCombFinish:__makeBuffEffectOn()
    local attacker = self.__context:getAttacker()
    local target = self.__context:getTarget()
    if not attacker:isDead() then
        attacker:makeBuffEffectOn(BUFF_EFFECT_TYPE.OnActiveCombFinish, self.__context)
        attacker:tryRemoveBuffs()
    end

    if not target:isDead() then
        target:makeBuffEffectOn(BUFF_EFFECT_TYPE.OnActiveCombFinish, self.__context)
        target:tryRemoveBuffs()
    end

    local characters = self.__fight:getCharacters()
    for _, character in ipairs(characters) do
        if not character:isDead() then
            character:makeBuffEffectOn(BUFF_EFFECT_TYPE.OnAnyCombFinish, self.__context)
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

function ActiveCombFinish:__removeBuffAdderGroup()
    local adderGroupIndexs = self.__context:getBuffAdderGroupIndexs()
    if MapIsEmpty(adderGroupIndexs) then
        return
    end

    local attacker = self.__context:getAttacker()
    for i, v in ipairs(adderGroupIndexs) do
        attacker:removeBuffAdderGroup(v)
    end

    self.__context:clearBuffAdderGroupIndex()
end

return newClass("ActiveCombFinish", {ABaseBattleAction}, ActiveCombFinish)
000000000000