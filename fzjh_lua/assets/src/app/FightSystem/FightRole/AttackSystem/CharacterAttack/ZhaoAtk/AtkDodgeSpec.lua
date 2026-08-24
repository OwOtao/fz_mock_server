--[[
    普通闪避
]]
local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

local AtkDodge = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkDodge")

--@SuperType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack#IZhaoAttack]
local AtkDodgeSpec = {
    __hurtType = ATTACK_HIT_TYPE.DODGE_SPC
    -- __dodgeAnimName = nil,
    -- --@desc 攻击第一次击中的位置
    -- __hit_pos = nil,
    -- --@desc 受击者开始后退的时间
    -- __start_moveback_time = 0,
    -- --@desc 后退时长
    -- __moveback_duration = 0,
    -- --@desc 回位时长
    -- __return__duration = 0,
    -- --@desc 受击者后退距离
    -- __target_moveback_offset = 0,
    -- --@desc 受击者闪避动画
    -- __target_dodgeAnim = nil
}

function AtkDodgeSpec:create()
    return self.new()
end

--@attacker:[src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AtkDodgeSpec:doAttack(attacker, target)
    FightUtil:printLog(" LOGIC UPDATE ATK AtkDodgeSpec 【", attacker:getAttr("name") , "】攻击被轻功跳离了")
end

return class("AtkDodgeSpec", {AtkDodge}, AtkDodgeSpec)
0