--[[
    author:Seven
    time:2022-11-17 17:13:43
    desc: 被动招式攻击开始
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [Constants]
local BUFF_CONSTANTS = require("app.FightSystem.FightBuff.Constants")
local BUFF_EFFECT_ON_TYPE = BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE

--@RefType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ActiveZhaoStart = {}

function ActiveZhaoStart:create(context)
    return ActiveZhaoStart.new():__init(context)
end

function ActiveZhaoStart:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext#ActiveAttackContext]
    self.__context = context
    return self
end

function ActiveZhaoStart:onInit()
end

function ActiveZhaoStart:onStart()
    FightUtil:printLog("招式攻击开始阶段：ActiveZhaoStart start")

    -- self:__makeBuffEffectOn()

    local currAttack = self.__context:getCurrZhaoAttack()

    currAttack:attack()

    self:finish()
end

function ActiveZhaoStart:onFinish()
    FightUtil:printLog("招式攻击开始阶段：ActiveZhaoStart finish")
end

function ActiveZhaoStart:onDestory()
end

function ActiveZhaoStart:onUpdate(ft)
end

-- function ActiveZhaoStart:__makeBuffEffectOn()
--     local attacker = self.__context:getAttacker()

--     local target = self.__context:getTarget()

--     if not attacker:isDead() then
--         attacker:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnActiveZhaoStart, self.__context)
--     end

--     if not target:isDead() then
--         target:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnActiveZhaoStart, self.__context)
--     end
-- end

return newClass("ActiveZhaoStart", {ABaseBattleAction}, ActiveZhaoStart)
000000000000