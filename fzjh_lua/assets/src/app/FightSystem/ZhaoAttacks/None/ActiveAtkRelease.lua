--[[
    释放类主动技能
]]
local ABasicZhaoAttack = require("app.FightSystem.ZhaoAttacks.ABasicZhaoAttack")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local AttackSound = require("app.FightSystem.AttackModel.AttackSound")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local HIT_TYPE_HIT = FightCommons.ATTACK_HIT_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
local AcitveAtkRelease = {
    __hitType = HIT_TYPE_HIT.ACTIVE_RELEASE
}

function AcitveAtkRelease:create(context, zhao)
    return AcitveAtkRelease.new():__init(context, zhao)
end

function AcitveAtkRelease:__init(context, zhao)
    self.__context = context

    --@RefType [src.app.models.skill.BasicSkill.ActiveZhao.BasicActiveZhaoInfo#BasicActiveZhaoInfo]
    self.__zhao = zhao

    self:__initAttack()

    return self
end

function AcitveAtkRelease:__initAttack()
    --@desc 攻击动画初始化
    self:__initAttackerAnim()
    --@desc 初始化攻击音效
    self:__initAttackerSoundId()
    --@desc 攻击占用时长
    self:__initDuration()
end

function AcitveAtkRelease:__initDuration()
    local attackerAnim = self:getAttackerAnim()
    if attackerAnim ~= nil then
        self.__duration = AnimResManager:getAnimTime(attackerAnim)
    else
        self.__duration = 0
    end
end

function AcitveAtkRelease:__initAttackerAnim()
    local animResId = self.__zhao:getAnimResId()
    if animResId ~= 0 then
        self.__attackerAnim = AnimResManager:getOtherAnimName(animResId)
    end
end

function AcitveAtkRelease:__initAttackerSoundId()
    self.__attackerSoundId = self.__zhao:getSoundId()
end

--@desc: 攻击音效
--@author:Seven
--@time:2022-12-29 17:49:16
function AcitveAtkRelease:getAttackerSoundId()
    return self.__attackerSoundId
end

--@desc: 执行攻击
--@author:Seven
--@time:2023-02-09 11:08:00
function AcitveAtkRelease:attack()
end

--@desc: 访问击中结果
--@author:Seven
--@time:2023-02-25 15:53:38
--@hitIndex: 第几次击中
--@visitor: [src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor#IAttackResultVisitor]
function AcitveAtkRelease:runOneAttackVisitor(hitIndex, visitor)
end

function AcitveAtkRelease:runAttackResultVisitor(visitor)
end

return newClass("AcitveAtkRelease", {ABasicZhaoAttack}, AcitveAtkRelease)
00000000