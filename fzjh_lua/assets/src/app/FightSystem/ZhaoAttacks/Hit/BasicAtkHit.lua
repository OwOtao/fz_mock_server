--[[
    author:Seven
    time:2022-12-16 20:06:23
    desc: 招式攻击命中结果处理基类
    ]]
local ABasicZhaoAttack = require("app.FightSystem.ZhaoAttacks.ABasicZhaoAttack")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local AttackSound = require("app.FightSystem.AttackModel.AttackSound")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local HIT_TYPE_HIT = FightCommons.ATTACK_HIT_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
local BasicAtkHit = {
    __hitType = HIT_TYPE_HIT.HIT
}

function BasicAtkHit:__init()
    --@RefType [src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoInfo#BasicAutoZhaoInfo]
    self.__zhao = nil

    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = nil
end

function BasicAtkHit:__initHitAttack()
    --@desc 存放攻击结果
    self.__hitResults = {}

    --@desc 攻击动画初始化
    self:__initAttackerAnim()
    --@desc 初始化攻击音效
    self:__initAttackerSoundId()
    --@desc 攻击占用时长
    self:__initDuration()
end

function BasicAtkHit:__initDuration()
    self.__duration = AnimResManager:getAnimTime(self:getAttackerAnim())
end

function BasicAtkHit:__initAttackerAnim()
    local atk_weapon = self.__context:getAttacker():getWeapon()

    self.__attackerAnim = AnimResManager:getAttackAnimName(self.__zhao:getAnimResId(), atk_weapon:getWeaponModule())
end

function BasicAtkHit:__initAttackerSoundId()
    self.__attackerSoundId = AttackSound.getAttackSound(self.__zhao, self.__context:getAttacker())
end

--@desc: 攻击音效
--@author:Seven
--@time:2022-12-29 17:49:16
function BasicAtkHit:getAttackerSoundId()
    return self.__attackerSoundId
end

--@desc: 执行攻击
--@author:Seven
--@time:2023-02-09 11:08:00
function BasicAtkHit:attack()
    FightUtil:printLog("招式攻击 -- 命中：")
    for i = 1, self.__zhao:getAnimHurtTimes() do
        self.__currAtkIndex = i
        FightUtil:printLog("- 招式攻击第【" .. tostring(self.__currAtkIndex) .. "】次击中")
        self:__doOneAttack()
    end
end

function BasicAtkHit:__doOneAttack()
    error("BasicAtkHit:__doOneAttack 重写该方法")
end

--@desc: 获取一次击中的攻击结果
--@author:Seven
--@time:2023-02-17 15:42:10
--@index: 索引
--@return [src.app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult#OneAttackHitResult]
function BasicAtkHit:getOneHitResult(index)
    if type(index) ~= "number" then
        error("BasicAtkHit:getOneHitResult 参数类型错误 " .. tostring(index))
    end
    if index > self.__currAtkIndex or index <= 0 then
        error("BasicAtkHit:getOneHitResult 参数越界：index " .. tostring(index))
    end

    return self.__hitResults[index]
end

function BasicAtkHit:getHitCount()
    return table.getn(self.__hitResults)
end

--@desc: 访问击中结果
--@author:Seven
--@time:2023-02-25 15:53:38
--@hitIndex: 第几次击中
--@visitor: [src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.IAttackResultVisitor#IAttackResultVisitor]
function BasicAtkHit:runOneAttackVisitor(hitIndex, visitor)
    local result = self:getOneHitResult(hitIndex)
    visitor:visitOneAttackResult(result)
end

function BasicAtkHit:runAttackResultVisitor(visitor)
    for i = 1, self:getHitCount() do
        self:runOneAttackVisitor(i, visitor)
    end
end

return newClass("BasicAtkHit", {ABasicZhaoAttack}, BasicAtkHit)
00000000000