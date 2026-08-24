local class = require("third.class.NewClass")

local IZhaoAttack = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

--@SuperType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack#IZhaoAttack]
local AtkParrySpec = {
    __hurtType = ATTACK_HIT_TYPE.PARRY_SPEC,
    --@desc 攻击第一次击中的位置
    __hit_pos = nil,
    --@desc 后退时长
    __moveback_duration = 0,
    --@desc 回位时长
    __return__duration = 0,
    --@desc 受击者后退距离
    __target_moveback_offset = 0,
    --@desc 受击者闪避动画
    __target_parryAnim = nil
}

function AtkParrySpec:create()
    return self.new()
end

function AtkParrySpec:ctor()
end

function AtkParrySpec:onInit()
end

function AtkParrySpec:setAttackAnims(attackAnims)
    --@RefType [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
    self.__attackAnims = attackAnims
end

--@return [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
function AtkParrySpec:getAttackAnims()
    return self.__attackAnims
end

function AtkParrySpec:getId()
    return self.__zhaoInfo:getId()
end

function AtkParrySpec:getHurtType()
    return self.__hurtType
end

function AtkParrySpec:setZhaoInfo(zhaoInfo)
    --@RefType [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
    self.__zhaoInfo = zhaoInfo
end

function AtkParrySpec:getDuration()
    return self.__firstHitTime + self.__moveback_duration + self.__return__duration
end

function AtkParrySpec:setAnimName(animName)
    self.__animName = animName
end

function AtkParrySpec:getAnimName()
    return self.__animName
end

function AtkParrySpec:setParryAnim(animName)
    self.__parryAnimName = animName
end

function AtkParrySpec:getParryAnimName()
    return self.__parryAnimName
end

function AtkParrySpec:setMoveBackOffset(offset)
    self.__target_moveback_offset = offset
end

function AtkParrySpec:getMoveBackOffset()
    return self.__target_moveback_offset
end

function AtkParrySpec:setHitPos(pos)
    self.__hit_pos = pos
end

function AtkParrySpec:getHitPos()
    return self.__hit_pos
end

function AtkParrySpec:setFirstHitTime(time)
    self.__firstHitTime = time
end

function AtkParrySpec:setMoveBackDuration(dt)
    self.__moveback_duration = dt
end

function AtkParrySpec:getMoveBackDuration()
    return self.__moveback_duration
end

function AtkParrySpec:setReturnDuration(dt)
    self.__return__duration = dt
end

function AtkParrySpec:getRetrunDuration()
    return self.__return__duration
end

function AtkParrySpec:setParrySkill(parrySkill)
    self.__parrySkill = parrySkill
end

--@attacker:[src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AtkParrySpecSpec:doAttack(attacker, target)
    FightUtil:printLog(" LOGIC UPDATE ATK DOATTACK 【", attacker:getAttr("name") , "】攻击被招架格挡了")
end

function AtkParrySpec:getAllHurts()
    return {}
end

function AtkParrySpec:getAllQiDamageHurts()
    return {}
end

function AtkParrySpec:getAllOneAttackHit()
    return {}
end

function AtkParrySpec:getAllTargetOneAttackHit()
    return {}
end

function AtkParrySpec:getAllAttackerOneAttackHit()
    return {}
end

return class("AtkParrySpec", {IZhaoAttack}, AtkParrySpec)
00