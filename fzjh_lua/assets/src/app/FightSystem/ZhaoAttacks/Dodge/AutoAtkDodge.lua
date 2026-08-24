--[[
    author:Seven
    time:2023-02-17 16:51:23
    desc: 被动招式躲避
]]
local newClass = require("third.class.NewClass")

local BasicAtkDodge = require("app.FightSystem.ZhaoAttacks.Dodge.BasicAtkDodge")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

--@RefType [Constants]
local BUFF_CONSTANTS = require("app.FightSystem.FightBuff.Constants")
local BUFF_EFFECT_ON_TYPE = BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE

--@SuperType [src.app.FightSystem.ZhaoAttacks.Dodge.BasicAtkDodge#BasicAtkDodge]
local AutoAtkDodge = {}

function AutoAtkDodge:create(context, zhao)
    return AutoAtkDodge.new():__init(context, zhao)
end

function AutoAtkDodge:__init(context, zhao)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context

    --@RefType [src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoInfo#BasicAutoZhaoInfo]
    self.__zhao = zhao

    self:__initHitAttack()

    return self
end

function AutoAtkDodge:__initHitAttack()
    --@desc 攻击动画初始化
    self:__initAttackerAnim()
    --@desc 初始化攻击音效
    self:__initAttackerSoundId()
    --@desc 攻击占用时长
    self:__initDuration()
end

function AutoAtkDodge:__doOneAttack()
    self.__context:getAttacker():makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoZhaoAttack, self.__context)

    self.__context:getTarget():makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoZhaoAttack, self.__context)
end

return newClass("AutoAtkDodge", {BasicAtkDodge}, AutoAtkDodge)
0000000