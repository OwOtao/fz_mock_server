--[[
    author:Seven
    time:2022-11-17 17:13:43
    desc: 被动招式攻击中
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [Constants]
local BUFF_CONSTANTS = require("app.FightSystem.FightBuff.Constants")
local BUFF_EFFECT_ON_TYPE = BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE

--@RefType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local AutoZhaoAttacking = {}

function AutoZhaoAttacking:create(context)
    return AutoZhaoAttacking.new():__init(context)
end

function AutoZhaoAttacking:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context
    return self
end

function AutoZhaoAttacking:onInit()
end

function AutoZhaoAttacking:onStart()
    FightUtil:printLog("招式攻击阶段 ：AutoZhaoAttacking start")

    self:__zhaoAttackStart()

    self.__duration = 0

    self.__currAttack = self.__context:getCurrZhaoAttack()

    self.__fight:notifyVeiwEvent(require("app.FightSystem.Veiws.ViewEvents.Events.AutoZhaoAttackViewEvent"):create(self.__context, self.__currAttack))
end

function AutoZhaoAttacking:onFinish()
    FightUtil:printLog("招式攻击阶段 ：AutoZhaoAttacking finish")
    self:__zhaoAttackFinish()
end

function AutoZhaoAttacking:onDestory()
end

function AutoZhaoAttacking:onUpdate(ft)
    if self.__duration >= self.__currAttack:getDuration() then
        self:finish()
        return
    end

    self.__duration = self.__duration + ft
end

function AutoZhaoAttacking:__zhaoAttackStart()
    -- local attacker = self.__context:getAttacker()

    -- local target = self.__context:getTarget()

    -- if not attacker:isDead() then
    --     attacker:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoZhaoStart, self.__context)
    -- end

    -- if not target:isDead() then
    --     target:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoZhaoStart, self.__context)
    -- end

    self.__context:getCurrZhaoAttack():attack()
end

function AutoZhaoAttacking:__zhaoAttackFinish()
    FightUtil:printLog("招式攻击阶段 AutoZhaoAttacking start")

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

    -- local attacker = self.__context:getAttacker()
    -- local target = self.__context:getTarget()

    -- if not attacker:isDead() then
    --     attacker:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoZhaoFinish, self.__context)
    -- end

    -- if not target:isDead() then
    --     target:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoZhaoFinish, self.__context)
    -- end
end

return newClass("AutoZhaoAttacking", {ABaseBattleAction}, AutoZhaoAttacking)
000000000000