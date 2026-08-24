--[[
    author:Seven
    time:2023-02-19 17:14:25
    desc:空类型-用于动画播放占位
]]
local ABasicZhaoAttack = require("app.FightSystem.ZhaoAttacks.ABasicZhaoAttack")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local AttackSound = require("app.FightSystem.AttackModel.AttackSound")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local HIT_TYPE_HIT = FightCommons.ATTACK_HIT_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
local BasicAtkNone = {
    __hitType = HIT_TYPE_HIT.NONE
}

function BasicAtkNone:create(context, zhao)
    return BasicAtkNone.new():__init(context, zhao)
end

function BasicAtkNone:__init(context, zhao)
    self.__context = context

    --@RefType [src.app.models.skill.BasicSkill.ActiveZhao.BasicActiveZhaoInfo#BasicActiveZhaoInfo]
    self.__zhao = zhao

    self:__initAttack()

    return self
end

function BasicAtkNone:__initAttack()
    --@desc 攻击动画初始化
    self:__initAttackerAnim()
    --@desc 初始化攻击音效
    self:__initAttackerSoundId()
    --@desc 攻击占用时长
    self:__initDuration()
end

function BasicAtkNone:__initDuration()
    local attackerAnim = self:getAttackerAnim()
    if attackerAnim ~= nil then
        self.__duration = AnimResManager:getAnimTime(attackerAnim)
    else
        self.__duration = 0
    end
end

function BasicAtkNone:__initAttackerAnim()
    local animResId = self.__zhao:getAnimResId()
    if animResId ~= 0 then
        self.__attackerAnim = AnimResManager:getOtherAnimName(animResId)
    end
end

function BasicAtkNone:__initAttackerSoundId()
    self.__attackerSoundId = self.__zhao:getSoundId()
end

--@desc: 攻击音效
--@author:Seven
--@time:2022-12-29 17:49:16
function BasicAtkNone:getAttackerSoundId()
    return self.__attackerSoundId
end

--@desc: 执行攻击
--@author:Seven
--@time:2023-02-09 11:08:00
function BasicAtkNone:attack()
end

--@desc: 访问击中结果
--@author:Seven
--@time:2023-02-25 15:53:38
--@hitIndex: 第几次击中
--@visitor: [src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor#IAttackResultVisitor]
function BasicAtkNone:runOneAttackVisitor(hitIndex, visitor)
end

function BasicAtkNone:runAttackResultVisitor(visitor)
end

return newClass("BasicAtkNone", {ABasicZhaoAttack}, BasicAtkNone)
00000000