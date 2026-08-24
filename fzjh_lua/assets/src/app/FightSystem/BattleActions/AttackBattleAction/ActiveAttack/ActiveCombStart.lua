--[[
    author:Seven
    time:2022-11-17 17:12:47
    desc: 被动招式组合开始
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local CharacterBuffAdderGroupFactory = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.CharacterBuffAdderGroupFactory")

--@RefType [Constants]
local BUFF_CONSTANT = require("app.FightSystem.FightBuff.Constants")
local BUFF_ADDER_TRIGGER_TYPE = BUFF_CONSTANT.ADDER_TRIGGER_TYPE
local ADD_BUFF_NODE_TYEP = BUFF_CONSTANT.ADD_BUFF_NODE_TYEP
local BUFF_EFFECT_ON_TYPE = BUFF_CONSTANT.BUFF_MAKE_EFFECT_ON_NODE_TYPE

--@RefType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ActiveCombStart = {}

function ActiveCombStart:create(context)
    return ActiveCombStart.new():__init(context)
end

function ActiveCombStart:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext#ActiveAttackContext]
    self.__context = context

    return self
end

function ActiveCombStart:onInit()
end

function ActiveCombStart:onStart()
    FightUtil:printFormatLog("组合攻击阶段：ActiveCombStart start : %s , 技能：【%s】", self.__context:getAttacker():getAttr("name"), self.__context:getAttackSkill():getName())

    self:__handleBuff()

    if self.__context:getAttacker():isDead() or self.__context:getTarget():isDead() then
        self:finish()
        return
    end

    --@region 生成组合攻击伤害
    if self.__context:getAttackComb():isAttackActiveComb() then
        --@desc 组合攻击伤害计算
        local hurts = self.__context:getCombHurts()

        for __, combHurt in ipairs(hurts) do
            --@RefType [src.app.FightSystem.CharacterHurt.BasicHurt#BasicHurt]
            local combHurt = combHurt
            FightUtil:printLog("组合伤害：", combHurt:getAttrName(), combHurt:getHurtValue())
        end
    end
    --@endregion

    --@desc 如需跳跃
    self.__context:setNextZhaoAttack(self.__context:getNextNewZhaoAttack())
    if self.__context:combAttackIsNeedToJump() then
        --@RefType [src.app.FightSystem.BattleActions.BattleMoveActions.CharacterJumpForwardAction#CharacterJumpForwardAction]
        self.__jumpAction = require("app.FightSystem.BattleActions.BattleMoveActions.CharacterJumpForwardAction"):create(self.__fight, self.__context)
    end
end

function ActiveCombStart:onFinish()
    FightUtil:printLog("组合攻击阶段：ActiveCombStart finish")
end

function ActiveCombStart:onDestory()
end

function ActiveCombStart:onUpdate(ft)
    if self.__jumpAction ~= nil then
        if self.__jumpAction:isFinish() then
            self:finish()
            return
        else
            if not self.__jumpAction:isStart() then
                self.__jumpAction:start()
            end
            self.__jumpAction:update(ft)
        end
    else
        self:finish()
    end
end

function ActiveCombStart:__handleBuff()
    self:__makeBuffEffectOn()
    self:__initBuffAdderInContext()
    self:__triggerBuffAdder()
    self:__execAddBuff()

    local characters = self.__fight:getCharacters()
    for _, character in ipairs(characters) do
        if not character:isDead() then
            character:updateSelfAlive()
        end

        character:updateViews()
    end
end

--@desc: 生成主动组合攻击过程中生效的buff添加器组
--@author:Seven
--@time:2023-03-12 16:51:43
function ActiveCombStart:__initBuffAdderInContext()
    local skill = self.__context:getAttackSkill()

    local adderIds = skill:getBuffLauncherIdArray()

    if table.getn(adderIds) <= 0 then
        return
    end

    local attacker = self.__context:getAttacker()

    for _, id in ipairs(adderIds) do
        local adderGroup = CharacterBuffAdderGroupFactory:getActiveBuffAdderGroup(id, attacker, self.__fight)
        local index = attacker:addBuffAdderGroup(adderGroup)
        self.__context:addBuffAdderGroupIndex(index)
    end
end

--@desc: 触发buff添加器
--@author:Seven
--@time:2023-03-12 16:53:34
function ActiveCombStart:__triggerBuffAdder()
    local list = self.__context:getAttacker():getAdderGroupByAdderTriggerType(BUFF_ADDER_TRIGGER_TYPE.ACTIVE_COMB_START)

    if table.getn(list) <= 0 then
        return
    end

    for _, adderGroup in ipairs(list) do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdderGroup#AFightCharacterBuffAdderGroup]
        adderGroup = adderGroup
        adderGroup:triggerBuffAdder(BUFF_ADDER_TRIGGER_TYPE.ACTIVE_COMB_START)
    end
end

--@desc: 执行buff添加器
--@author:Seven
--@time:2023-03-12 16:53:46
function ActiveCombStart:__execAddBuff()
    local AddBuffUtil = require("app.FightSystem.FightRole.CharacterBuff.Utils.AddBuffUtil")

    AddBuffUtil:execAddBuff(self.__fight, self.__context:getAttacker(), ADD_BUFF_NODE_TYEP.ACTIVE_COMB_START)

    self.__fight:showAndClearAddBuffDesc()

    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterAddBuffsViewEvent":create(self.__fight, self.__fight))

    self.__fight:clearBuffEffectHurts()
end

function ActiveCombStart:__makeBuffEffectOn()
    local attacker = self.__context:getAttacker()
    local target = self.__context:getTarget()
    if not attacker:isDead() then
        attacker:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnActiveCombStart, self.__context)
        attacker:tryRemoveBuffs()
    end
    if not target:isDead() then
        target:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnActiveCombStart, self.__context)
        target:tryRemoveBuffs()
    end
    local characters = self.__fight:getCharacters()
    for _, character in ipairs(characters) do
        if not character:isDead() then
            character:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAnyCombStart, self.__context)
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

return newClass("ActiveCombStart", {ABaseBattleAction}, ActiveCombStart)
000000