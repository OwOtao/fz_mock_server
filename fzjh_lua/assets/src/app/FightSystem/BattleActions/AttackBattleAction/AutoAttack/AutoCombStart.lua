--[[
    author:Seven
    time:2022-11-17 17:12:47
    desc: 被动招式组合开始
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@RefType [Constants]
local BUFF_CONSTANT = require("app.FightSystem.FightBuff.Constants")
local BUFF_ADDER_TRIGGER_TYPE = BUFF_CONSTANT.ADDER_TRIGGER_TYPE
local ADD_BUFF_NODE_TYEP = BUFF_CONSTANT.ADD_BUFF_NODE_TYEP
local BUFF_EFFECT_ON_TYPE = BUFF_CONSTANT.BUFF_MAKE_EFFECT_ON_NODE_TYPE

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local AutoCombStart = {}

function AutoCombStart:create(context)
    return AutoCombStart.new():__init(context)
end

function AutoCombStart:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context
    return self
end

function AutoCombStart:onInit()
end

function AutoCombStart:onStart()
    FightUtil:printLog("组合攻击阶段：AutoCombStart start")

    FightUtil:printLog("AutoComb 角色被动招式组合攻击开始：", tostring(self.__context:getAttackSkill():getName()), tostring(self.__context:getAttackComb():getCombName()))

    self:__handleBuff()

    if self.__context:getAttacker():isDead() or self.__context:getTarget():isDead() then
        self:finish()
        return
    end

    --@region 体力消耗
    local costTili = self.__context:getAttackCostTili()

    self.__context:getAttacker():consumeTili(costTili)
    --@endregion

    --@region 内力消耗
    local costNeili = self.__context:getAttackCostNeili()

    self.__context:getAttacker():consumeNeili(costNeili)
    --@endregion

    --@region 组合攻击伤害
    local hurts = self.__context:getCombHurts()

    --@desc 组合攻击伤害计算
    for __, combHurt in ipairs(hurts) do
        --@RefType [src.app.FightSystem.CharacterHurt.BasicHurt#BasicHurt]
        local combHurt = combHurt
        FightUtil:printLog("组合伤害：", combHurt:getAttrName(), combHurt:getHurtValue())
    end
    --@endregion

    self.__context:setNextZhaoAttack(self.__context:getNextNewZhaoAttack())

    --@desc 如需跳跃
    if self.__context:combAttackIsNeedToJump() then
        --@RefType [src.app.FightSystem.BattleActions.BattleMoveActions.CharacterJumpForwardAction#CharacterJumpForwardAction]
        self.__jumpAction = require("app.FightSystem.BattleActions.BattleMoveActions.CharacterJumpForwardAction"):create(self.__fight, self.__context)
        self.__jumpAction:start()
    end

    self:__combStartTextOutput()
end

function AutoCombStart:onFinish()
    FightUtil:printLog("组合攻击阶段：AutoCombStart finish")
end

function AutoCombStart:onDestory()
end

function AutoCombStart:onUpdate(ft)
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

function AutoCombStart:__combStartTextOutput()
    local startCombText = self.__context:getAttackComb():getActionText()
    --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
    local desc = require("app.FightSystem.FightUtil.FightDesc"):create()

    desc:setText(startCombText)

    desc:setAttacker(self.__context:getAttacker())

    desc:setDefender(self.__context:getTarget())

    desc:setHitPosName(self.__context:getCombHitPosName())

    desc:setZhaoCombName(self.__context:getAttackComb():getCombName())

    self.__fight:showPrintText(desc:getString())
end

--@desc: 处理buff相关逻辑
--@author:Seven
--@time:2023-03-12 18:18:53
function AutoCombStart:__handleBuff()
    self:__makeBuffEffectOn()
    self:__execAddBuff()

    local characters = self.__fight:getCharacters()

    for _, character in ipairs(characters) do
        --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
        character = character
        if not character:isDead() then
            character:updateSelfAlive()
        end
        character:updateViews()
    end
end

--@desc: 执行buff添加器
--@author:Seven
--@time:2023-03-12 16:53:46
function AutoCombStart:__execAddBuff()
    local AddBuffUtil = require("app.FightSystem.FightRole.CharacterBuff.Utils.AddBuffUtil")

    AddBuffUtil:execAddBuff(self.__fight, self.__context:getAttacker(), ADD_BUFF_NODE_TYEP.AUTO_COMB_START)

    self.__fight:showAndClearAddBuffDesc()

    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterAddBuffsViewEvent":create(self.__fight, self.__fight))

    self.__fight:clearBuffEffectHurts()
end

function AutoCombStart:__makeBuffEffectOn()
    local attacker = self.__context:getAttacker()
    local target = self.__context:getTarget()
    if not attacker:isDead() then
        attacker:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoCombStart, self.__context)
        attacker:tryRemoveBuffs()
    end
    if not target:isDead() then
        target:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoCombStart, self.__context)
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

return newClass("AutoCombStart", {ABaseBattleAction}, AutoCombStart)
0000