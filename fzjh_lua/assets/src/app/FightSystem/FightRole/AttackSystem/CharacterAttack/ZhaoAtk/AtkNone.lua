local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AttackHurtInfo = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AttackHurtInfo")

local FightCommons = require("app.FightSystem.FightCommons")

local IZhaoAttack = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack")

local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

--@SuperType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack#IZhaoAttack]
local AtkNone = {
    __hurtType = ATTACK_HIT_TYPE.NONE,
    __zhaoInfo = nil,
    __duration = 0,
    __animName = nil
}

function AtkNone:create()
    return self.new()
end

function AtkNone:ctor()
end

--@desc: 攻击者
--@author:Seven
--@time:2021-12-14 16:03:31
--@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AtkNone:setAttacker(attacker)
    self.__attacker = attacker
end

--@desc: 攻击目标
--@author:Seven
--@time:2021-12-14 16:03:03
--@target: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AtkNone:setTarget(target)
    self.__target = target
end

function AtkNone:setAttackAnims(attackAnims)
    --@RefType [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
    self.__attackAnims = attackAnims
end

--@return [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
function AtkNone:getAttackAnims()
    return self.__attackAnims
end

function AtkNone:getId()
    return self.__zhaoInfo:getId()
end

function AtkNone:getHurtType()
    return self.__hurtType
end

function AtkNone:setZhaoInfo(zhaoInfo)
    --@RefType [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
    self.__zhaoInfo = zhaoInfo
end

function AtkNone:setDuration(duration)
    self.__duration = duration
end

function AtkNone:getDuration()
    return self.__duration
end

function AtkNone:setAnimName(animName)
    self.__animName = animName
end

function AtkNone:getAnimName()
    return self.__animName
end

--@desc: 执行攻击
--@author:Seven
--@time:2021-07-06 16:41:34
--@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AtkNone:doAttack(attacker, target)
end

function AtkNone:getAllHurts()
    return {}
end

function AtkNone:getAllQiDamageHurts()
    return {}
end

function AtkNone:getAllOneAttackHit()
    return {}
end

function AtkNone:getAllTargetOneAttackHit()
    return {}
end

function AtkNone:getAllAttackerOneAttackHit()
    return {}
end

function AtkNone:runOutputDescVisitor(visitor)
end

function AtkNone:runHitFrameVisitor(index, visitor)
end

return class("AtkNone", {IZhaoAttack}, AtkNone)
00000