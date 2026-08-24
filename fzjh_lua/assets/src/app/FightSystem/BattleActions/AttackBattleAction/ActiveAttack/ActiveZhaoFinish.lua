--[[
    author:Seven
    time:2022-11-17 17:13:43
    desc: 被动招式完成阶段
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [Constants]
local BUFF_CONSTANTS = require("app.FightSystem.FightBuff.Constants")
local BUFF_EFFECT_ON_TYPE = BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE

--@RefType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ActiveZhaoFinish = {}

function ActiveZhaoFinish:create(context)
    return ActiveZhaoFinish.new():__init(context)
end

function ActiveZhaoFinish:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context
    return self
end

function ActiveZhaoFinish:onInit()
end

function ActiveZhaoFinish:onStart()
    FightUtil:printLog("招式攻击阶段 ActiveZhaoFinish start")
    local attacker = self.__context:getAttacker()
    attacker:correctAttrLimit()

    local target = self.__context:getTarget()
    target:correctAttrLimit()

    if attacker:canDead() then
        attacker:killCharacter()
    end

    if target:canDead() then
        target:killCharacter()
    end

    -- self:__makeBuffEffectOn()

    self:finish()
end

function ActiveZhaoFinish:onFinish()
    FightUtil:printLog("招式攻击阶段 ActiveZhaoFinish finish")
end

function ActiveZhaoFinish:onDestory()
end

function ActiveZhaoFinish:onUpdate(ft)
end

function ActiveZhaoFinish:__makeBuffEffectOn()
    local attacker = self.__context:getAttacker()

    local target = self.__context:getTarget()

    -- if not attacker:isDead() then
    --     attacker:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnActiveZhaoFinish, self.__context)
    -- end

    -- if not target:isDead() then
    --     target:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnActiveZhaoFinish, self.__context)
    -- end

    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterUpdateShieldViewEvent":create(attacker:getId(), attacker:getQiShieldAnimId()))
    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterUpdateShieldViewEvent":create(target:getId(), target:getQiShieldAnimId()))

    self.__fight:showAndClearDeleteBuffDesc()
end

return newClass("ActiveZhaoFinish", {ABaseBattleAction}, ActiveZhaoFinish)
0000000