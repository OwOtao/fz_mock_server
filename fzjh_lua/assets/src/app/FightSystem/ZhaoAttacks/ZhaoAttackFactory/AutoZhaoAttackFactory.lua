--[[
    author:Seven
    time:2023-01-06 20:20:27
    desc: 被动招式结果生成工厂
]]
local newClass = require("third.class.NewClass")

local IZhaoAttackFactory = require("app.FightSystem.ZhaoAttacks.ZhaoAttackFactory.IZhaoAttackFactory")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightFormula = require("app.FightSystem.FightFormula")

local FightCommons = require("app.FightSystem.FightCommons")

local HIT_TYPE_HIT = FightCommons.ATTACK_HIT_TYPE

local AutoZhaoAttackFactory = {}

function AutoZhaoAttackFactory:create(context)
    return AutoZhaoAttackFactory.new():__init(context)
end

function AutoZhaoAttackFactory:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context
    return self
end

function AutoZhaoAttackFactory:__random(probability, min, max)
    if probability < min then
        return false
    end

    if probability >= max then
        return true
    end

    local rand = FightUtil:random(min, max)
    FightUtil:printLog("** AutoZhaoAttackFactory __random  ** 随机值：", rand, " , 范围值：[", min, " , ", probability, "]")
    if min <= rand and rand <= probability then
        return true
    end

    return false
end

--@desc: 随机类型
--@author:Seven
--@time:2023-01-07 17:36:51
function AutoZhaoAttackFactory:__randomHitType()
    FightUtil:printLog("AutoZhaoAttackFactory 招式攻击开始随机闪避 ：")
    local dodgeProbability = self:__calDodgeProbability()
    if self:__random(dodgeProbability, 1, 10000) then
        FightUtil:printLog("AutoZhaoAttackFactory 命中结果： ** 轻功闪避")
        return HIT_TYPE_HIT.DODGE
    end

    FightUtil:printLog("AutoZhaoAttackFactory 招式攻击开始随机格挡 ：")
    local parryProbability = self:__calParryProbability()
    if self:__random(parryProbability, 1, 10000) then
        FightUtil:printLog("AutoZhaoAttackFactory 命中结果： ** 普通招架")
        return HIT_TYPE_HIT.PARRY
    end

    FightUtil:printLog("AutoZhaoAttackFactory 命中结果： ** 击中")
    return HIT_TYPE_HIT.HIT
end

--@desc: 计算招式轻功闪躲的概率
--@author:Seven
--@time:2023-01-07 17:26:26
function AutoZhaoAttackFactory:__calDodgeProbability()
    local dodgeProbability = -1

    local target = self.__context:getTarget()
    local attacker = self.__context:getAttacker()
    if target:getBuffAddAttr("banAutoDodge") > 0 then
        dodgeProbability = 0
    elseif attacker:getBuffAddAttr("beAutoDodge") > 0 then
        dodgeProbability = 1 * 10000
    end

    if dodgeProbability < 0 then
        dodgeProbability = FightFormula:calAutoZhaoDodgeProbability(self.__context:getAttackComb(), self.__context:getAttacker(), self.__context:getTarget())
    end

    return dodgeProbability
end

--@desc: 计算招式格挡概率
--@author:Seven
--@time:2023-01-07 17:35:20
function AutoZhaoAttackFactory:__calParryProbability()
    local parryProbability = -1

    --@TODO 2023-01-07 18:07:11 需接入buff影响
    local target = self.__context:getTarget()
    local attacker = self.__context:getAttacker()

    if target:getBuffAddAttr("banAutoParry") > 0 then
        parryProbability = 0
    elseif attacker:getBuffAddAttr("beAutoParry") > 0 then
        parryProbability = 1 * 10000
    end

    if parryProbability < 0 then
        parryProbability = FightFormula:calAutoZhaoParryProbability(self.__context:getAttackComb(), self.__context:getAttacker(), self.__context:getTarget())
    end

    return parryProbability
end

function AutoZhaoAttackFactory:getZhaoAttack()
    local hitType = self:__randomHitType()

    local path
    if hitType == HIT_TYPE_HIT.PARRY then
        path = "app.FightSystem.ZhaoAttacks.Parry.AutoAtkParry"
    elseif hitType == HIT_TYPE_HIT.DODGE then
        path = "app.FightSystem.ZhaoAttacks.Dodge.AutoAtkDodge"
    elseif hitType == HIT_TYPE_HIT.HIT then
        path = "app.FightSystem.ZhaoAttacks.Hit.AutoAtkHit"
    end

    return require(path):create(self.__context, self.__context:getNextZhao())
end

return newClass("AutoZhaoAttackFactory", {IZhaoAttackFactory}, AutoZhaoAttackFactory)
00000