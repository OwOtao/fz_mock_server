local class = require("third.class.NewClass")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local AttackHurtInfo = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AttackHurtInfo")

local ActiveZhaoCombAttack = {
    --@desc 存放组合攻击预计伤害
    __combProjectedDamages = {}
}

function ActiveZhaoCombAttack:create(activeZhaoComb)
    local p = self.new()
    p:init(activeZhaoComb)
    return p
end

function ActiveZhaoCombAttack:init(activeZhaoComb)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombination#ActiveZhaoCombination]
    self.__comb = activeZhaoComb
end

function ActiveZhaoCombAttack:getId()
    return self.__comb:getId()
end

function ActiveZhaoCombAttack:getActiveName()
    return self.__comb:getActiveName()
end

function ActiveZhaoCombAttack:getActiveId()
    return self.__comb:getActiveId()
end

function ActiveZhaoCombAttack:getActiveType()
    return self.__comb:getActiveType()
end

function ActiveZhaoCombAttack:isJumpAttack()
    return self.__comb:getIsJumpAttack()
end

function ActiveZhaoCombAttack:isSwitchTargets()
    return self.__comb:getSwitchTargets() == 1
end

function ActiveZhaoCombAttack:getCD()
    return self.__comb:getCD()
end

function ActiveZhaoCombAttack:getTiliCost()
    return self.__comb:getTiliCost()
end

function ActiveZhaoCombAttack:getNeiliCost()
    return self.__comb:getNeiliCost()
end

function ActiveZhaoCombAttack:getHurtTarget()
    return self.__comb:getHurtTarget()
end

function ActiveZhaoCombAttack:getHurtIDs()
    return self.__comb:getHurtIDs()
end

function ActiveZhaoCombAttack:getAddBuff()
    return self.__comb:getAddBuff()
end

function ActiveZhaoCombAttack:getBuffAdder()
    return self.__comb:getBuffAdder()
end

function ActiveZhaoCombAttack:getActionText()
    return self.__comb:getActionText()
end

function ActiveZhaoCombAttack:randomHurtPosName()
    local AttackHitPosManager = require("app.FightSystem.ResourceManager.AttackHitPosClassManager")

    local hurtPosClass = self.__comb:getHurtPosClass()

    local name = AttackHitPosManager:randomHitPosNameByPosClass(hurtPosClass)

    return name
end

--@desc: 判断是否攻击用技能，根据是否存在伤害组进行判断
--@author:Seven
--@time:2021-07-08 16:11:54
function ActiveZhaoCombAttack:isAttackSkill()
    return #self:getHurtIDs() > 0
end

--@desc: 准备招式
--@author:Seven
--@time:2021-07-07 20:08:38
--@return [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
function ActiveZhaoCombAttack:getReadyZhao()
    return self.__comb:getReadyZhao()
end

function ActiveZhaoCombAttack:setHurtInfos(hurtInfos)
    self.__combHurtInfos = hurtInfos
end

function ActiveZhaoCombAttack:getReadyAnimName()
    local readyZhaoInfo = self:getReadyZhao()

    if readyZhaoInfo == nil then
        return nil
    end

    local animResId = readyZhaoInfo:getAnimResId()

    if animResId == 0 then
        return nil
    end

    local animName = AnimResManager:getOtherAnimName(animResId)

    return animName
end

function ActiveZhaoCombAttack:getReadySound()
    local readyZhao = self:getReadyZhao()

    if readyZhao == nil then
        return nil
    end

    local soundId = readyZhao:getSoundId()

    local soundStart = readyZhao:getSoundStart()

    return soundId, soundStart
end

function ActiveZhaoCombAttack:getReadyDuration()
    local animName = self:getReadyAnimName()

    if animName == nil then
        return 0
    end

    local duration = 0

    duration = AnimResManager:getAnimTime(animName)

    return duration
end

--@desc: 该招式出招攻击次数
--@author:Seven
--@time:2021-05-15 11:10:55
function ActiveZhaoCombAttack:getAtkCount()
    return self.__comb:getAtkCount()
end

function ActiveZhaoCombAttack:getCombHurtTotalWeight()
    return self.__comb:getAttackHurtTotalWeight()
end

--@desc:根据索引获取招式信息
--@author:Seven
--@time:2021-07-07 16:32:42
--@index: 当前索引
--@return [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
function ActiveZhaoCombAttack:getZhaoInfo(index)
    return self.__comb:getAtkZhaoInfoByIndex(index)
end

function ActiveZhaoCombAttack:getHurtInfosByAttackZhaoIndex(index)
    local AllocHurt = require("app.FightSystem.AttackModel.AllocHurt")

    local zhaoInfo = self.__comb:getAtkZhaoInfoByIndex(index)

    local totalWeight = self:getCombHurtTotalWeight()

    local zhaoWeight = zhaoInfo:getHurtWeight()

    --@RefType [src.app.FightSystem.AttackModel.AllocHurt#AllocHurt]
    local allocHurt = AllocHurt:create(self.__combHurtInfos, totalWeight, zhaoWeight)

    local hurts = allocHurt:alloc()

    return hurts
end

function ActiveZhaoCombAttack:setQiDamageHurts(qiDamageHurts)
    self.__qiDamageHurts = qiDamageHurts
end

--@desc: 获取招式段分摊气血伤害对象
--@author:Seven
--@time:2021-07-17 16:48:20
--@return [src.app.FightSystem.AttackModel.QiDamageHurt#QiDamageHurt]
function ActiveZhaoCombAttack:getQiDamageHurtByIndex(index)
    local zhaoInfo = self.__comb:getAtkZhaoInfoByIndex(index)

    local totalWeight = self:getCombHurtTotalWeight()

    local zhaoWeight = zhaoInfo:getHurtWeight()

    local newQiDamageHurts = {}
    for _, qiDamageHurt in ipairs(self.__qiDamageHurts) do
        local newQiDamageHurt = qiDamageHurt:allocByWeight(zhaoWeight, totalWeight)
        table.insert(newQiDamageHurts, newQiDamageHurt)
    end

    return newQiDamageHurts
end

function ActiveZhaoCombAttack:getCompletionUseAuto()
    return self.__comb:getCompletionUseAuto()
end

function ActiveZhaoCombAttack:addCombProjectedDamages(damageInfos)
    table.insert(self.__combProjectedDamages, damageInfos)
end

function ActiveZhaoCombAttack:getCombProjectedDamages()
    return self.__combProjectedDamages
end

return class("ActiveZhaoCombAttack", {}, ActiveZhaoCombAttack)
0000