--[[
    普通闪避
]]
local class = require("third.class.NewClass")

local IZhaoAttack = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

--@SuperType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack#IZhaoAttack]
local AtkDodge = {
    __hurtType = ATTACK_HIT_TYPE.DODGE,
    __dodgeAnimName = nil,
    --@desc 攻击第一次击中的位置
    __hit_pos = nil,
    --@desc 受击者开始后退的时间
    __start_moveback_time = 0,
    --@desc 后退时长
    __moveback_duration = 0,
    --@desc 回位时长
    __return__duration = 0,
    --@desc 受击者后退距离
    __target_moveback_offset = 0,
    --@desc 受击者闪避动画
    __target_dodgeAnim = nil
}

function AtkDodge:create()
    return AtkDodge.new()
end

function AtkDodge:ctor()
end

function AtkDodge:init()
end

--@desc: 攻击者
--@author:Seven
--@time:2021-12-14 16:03:31
--@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AtkDodge:setAttacker(attacker)
    self.__attacker = attacker
end

--@desc: 攻击目标
--@author:Seven
--@time:2021-12-14 16:03:03
--@target: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AtkDodge:setTarget(target)
    self.__target = target
end

function AtkDodge:setAttackAnims(attackAnims)
    --@RefType [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
    self.__attackAnims = attackAnims
end

--@return [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
function AtkDodge:getAttackAnims()
    return self.__attackAnims
end

function AtkDodge:getId()
    return self.__zhaoInfo:getId()
end

function AtkDodge:getHurtType()
    return self.__hurtType
end

function AtkDodge:setZhaoInfo(zhaoInfo)
    --@RefType [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
    self.__zhaoInfo = zhaoInfo
end

function AtkDodge:getDuration()
    return self.__start_moveback_time + self.__moveback_duration + self.__return__duration
end

function AtkDodge:setAnimName(animName)
    self.__animName = animName
end

function AtkDodge:getAnimName()
    return self.__animName
end

function AtkDodge:setDodgeAnim(animName)
    self.__dodgeAnimName = animName
end

function AtkDodge:getDodgeAnimName()
    return self.__dodgeAnimName
end

function AtkDodge:setMoveBackOffset(offset)
    self.__target_moveback_offset = offset
end

function AtkDodge:getMoveBackOffset()
    return self.__target_moveback_offset
end

function AtkDodge:setStartMoveBackTime(time)
    self.__start_moveback_time = time
end

function AtkDodge:getStartMoveBackTime()
    return self.__start_moveback_time
end

function AtkDodge:setMoveBackDuration(dt)
    self.__moveback_duration = dt
end

function AtkDodge:getMoveBackDuration()
    return self.__moveback_duration
end

function AtkDodge:setReturnDuration(dt)
    self.__return__duration = dt
end

function AtkDodge:getRetrunDuration()
    return self.__return__duration
end

--@attacker:[src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AtkDodge:doAttack(attacker, target)
    FightUtil:printLog(" LOGIC UPDATE ATK AtkDodge 【", attacker:getAttr("name"), "】攻击被闪避了")
end

function AtkDodge:getAllHurts()
    return {}
end

function AtkDodge:getAllQiDamageHurts()
    return {}
end

function AtkDodge:getAllOneAttackHit()
    return {}
end

function AtkDodge:getAllTargetOneAttackHit()
    return {}
end

function AtkDodge:getAllAttackerOneAttackHit()
    return {}
end

function AtkDodge:runOutputDescVisitor(visitor)
end

function AtkDodge:runHitFrameVisitor(index, visitor)
end

return class("AtkDodge", {IZhaoAttack}, AtkDodge)
000000000000000