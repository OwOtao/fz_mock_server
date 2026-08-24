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
local AutoZhaoStart = {}

function AutoZhaoStart:create(context)
    return AutoZhaoStart.new():__init(context)
end

function AutoZhaoStart:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context
    return self
end

function AutoZhaoStart:onInit()
end

function AutoZhaoStart:onStart()
    FightUtil:printLog("招式攻击开始阶段：AutoZhaoStart start")

    -- self:__triggerBuff()

    local currAttack = self.__context:getCurrZhaoAttack()

    currAttack:attack()

    self:finish()
end

-- function AutoZhaoStart:__triggerBuff()
--     local attacker = self.__context:getAttacker()

--     local target = self.__context:getTarget()

--     if not attacker:isDead() then
--         attacker:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoZhaoStart, self.__context)
--     end

--     if not target:isDead() then
--         target:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoZhaoStart, self.__context)
--     end
-- end

function AutoZhaoStart:onFinish()
    FightUtil:printLog("招式攻击开始阶段：AutoZhaoStart finish")
end

function AutoZhaoStart:onDestory()
end

function AutoZhaoStart:onUpdate(ft)
end

return newClass("AutoZhaoStart", {ABaseBattleAction}, AutoZhaoStart)
00000000000000