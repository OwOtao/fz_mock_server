--[[
    攻击用招式组合
]]
local newClass = require("third.class.NewClass")

local AttackHurtInfo = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AttackHurtInfo")

local AutoZhaoCombAttack = {
    __combProjectedDamages = {}
}

function AutoZhaoCombAttack:create(autoZhaoComb)
    local p = AutoZhaoCombAttack.new()
    p:init(autoZhaoComb)
    return p
end

function AutoZhaoCombAttack:init(autoZhaoComb)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombination#AutoZhaoCombination]
    self.__autoZhaoComb = autoZhaoComb
end

function AutoZhaoCombAttack:getId()
    return self.__autoZhaoComb:getId()
end

function AutoZhaoCombAttack:getZhaoName()
    return self.__autoZhaoComb:getZhaoName()
end

--@desc: 消耗体力
--@author:Seven
--@time:2021-05-15 11:47:37
function AutoZhaoCombAttack:getTiliCost()
    return self.__autoZhaoComb:getTiliCost()
end

--@desc: 命中性能
--@author:Seven
--@time:2021-07-12 19:16:16
function AutoZhaoCombAttack:getHit()
    return self.__autoZhaoComb:getHit()
end

function AutoZhaoCombAttack:getActionText()
    return self.__autoZhaoComb:getActionText()
end

--@desc: 伤害性能
--@author:Seven
--@time:2021-07-12 19:16:09
function AutoZhaoCombAttack:getTopLimit()
    return self.__autoZhaoComb:getTopLimit()
end

function AutoZhaoCombAttack:getDamageType()
    return self.__autoZhaoComb:getDamageType()
end

function AutoZhaoCombAttack:randomHurtPosName()
    local AttackHitPosManager = require("app.FightSystem.ResourceManager.AttackHitPosClassManager")

    local hurtPosClass = self.__autoZhaoComb:getHurtPosClass()

    local name = AttackHitPosManager:randomHitPosNameByPosClass(hurtPosClass)

    return name
end

--@desc: 该招式出招攻击次数
--@author:Seven
--@time:2021-05-15 11:10:55
function AutoZhaoCombAttack:getAtkCount()
    return self.__autoZhaoComb:getAtkCount()
end

function AutoZhaoCombAttack:getCombHurtTotalWeight()
    return self.__autoZhaoComb:getAttackHurtTotalWeight()
end

--@desc: 设置招式组合计算总伤害
--@author:Seven
--@time:2021-07-05 22:27:49
--@hurtInfos: [AttackHurtInfo,AttackHurtInfo]
function AutoZhaoCombAttack:setHurtInfos(hurtInfos)
    self.__combHurtInfos = hurtInfos
end

function AutoZhaoCombAttack:getZhaoInfo(index)
    return self.__autoZhaoComb:getAtkZhaoInfoByIndex(index)
end

function AutoZhaoCombAttack:getHurtInfosByAttackZhaoIndex(index)
    local AllocHurt = require("app.FightSystem.AttackModel.AllocHurt")

    local zhaoInfo = self.__autoZhaoComb:getAtkZhaoInfoByIndex(index)

    local totalWeight = self:getCombHurtTotalWeight()

    local zhaoWeight = zhaoInfo:getHurtWeight()

    --@RefType [src.app.FightSystem.AttackModel.AllocHurt#AllocHurt]
    local allocHurt = AllocHurt:create(self.__combHurtInfos, totalWeight, zhaoWeight)

    local hurts = allocHurt:alloc()

    return hurts
end

function AutoZhaoCombAttack:setQiDamageHurts(qiDamageHurts)
    self.__qiDamageHurts = qiDamageHurts
end

--@desc: 获取招式段分摊气血伤害对象
--@author:Seven
--@time:2021-07-17 16:48:20
--@return [src.app.FightSystem.AttackModel.QiDamageHurt#QiDamageHurt]
function AutoZhaoCombAttack:getQiDamageHurtByIndex(index)
    local zhaoInfo = self.__autoZhaoComb:getAtkZhaoInfoByIndex(index)

    local totalWeight = self:getCombHurtTotalWeight()

    local zhaoWeight = zhaoInfo:getHurtWeight()

    local newQiDamageHurts = {}
    for _, qiDamageHurt in ipairs(self.__qiDamageHurts) do
        local newQiDamageHurt = qiDamageHurt:allocByWeight(zhaoWeight, totalWeight)
        table.insert(newQiDamageHurts, newQiDamageHurt)
    end

    return newQiDamageHurts
end

--@desc 攻击性能
function AutoZhaoCombAttack:getAttack()
    return self.__autoZhaoComb:getAttack()
end

function AutoZhaoCombAttack:addCombProjectedDamages(damageInfos)
    table.insert(self.__combProjectedDamages, damageInfos)
end

function AutoZhaoCombAttack:getCombProjectedDamages()
    return self.__combProjectedDamages
end

return newClass("AutoZhaoCombAttack", {}, AutoZhaoCombAttack)
0000000