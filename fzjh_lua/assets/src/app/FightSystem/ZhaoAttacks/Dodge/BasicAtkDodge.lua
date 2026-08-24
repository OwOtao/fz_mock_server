--[[
    author:Seven
    time:2023-01-06 14:19:45
    desc:招式攻击招架结果处理基类
]]
local ABasicZhaoAttack = require("app.FightSystem.ZhaoAttacks.ABasicZhaoAttack")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local HIT_TYPE_HIT = FightCommons.ATTACK_HIT_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
local BasicAtkDodge = {
    __hitType = HIT_TYPE_HIT.DODGE
}

function BasicAtkDodge:__initDuration()
    self.__targetMoveBackDuration = 5 / 30

    self.__targetStartMoveTime = 7 / 30

    local returnDuration = 5 / 30

    self.__duration = self.__targetMoveBackDuration + self.__targetStartMoveTime + returnDuration
end

function BasicAtkDodge:__initAttackerAnim()
    local atk_weapon = self.__context:getAttacker():getWeapon()

    self.__attackerAnim = AnimResManager:getAttackAnimName(self.__zhao:getAnimResId(), atk_weapon:getWeaponModule())
end

function BasicAtkDodge:__initAttackerSoundId()
    self.__attackerSoundId = self.__zhao:getSoundId()
end

function BasicAtkDodge:getTargetStartMoveTime()
    return self.__targetStartMoveTime
end

function BasicAtkDodge:getTargetMoveBackDuration()
    return self.__targetMoveBackDuration
end

--@desc: 执行攻击
--@author:Seven
--@time:2023-02-09 11:08:00
function BasicAtkDodge:attack()
    --@desc闪避只打一下
    FightUtil:printLog("招式攻击 -- 闪避：")
    self.__currAtkIndex = 1
    FightUtil:printLog("- 招式攻击第【" .. tostring(self.__currAtkIndex) .. "】次攻击")
    self:__doOneAttack()
end

--@desc: 访问击中结果
--@author:Seven
--@time:2023-02-25 15:53:38
--@hitIndex: 第几次击中
--@visitor: [src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor#IAttackResultVisitor]
function BasicAtkDodge:runOneAttackVisitor(hitIndex, visitor)
    return
end

function BasicAtkDodge:runAttackResultVisitor(visitor)
end

return newClass("BasicAtkDodge", {ABasicZhaoAttack}, BasicAtkDodge)
0000000