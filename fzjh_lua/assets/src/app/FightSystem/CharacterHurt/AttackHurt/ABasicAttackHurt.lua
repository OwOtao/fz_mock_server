--[[
    author:Seven
    time:2023-02-07 19:33:12
    desc: 一次攻击帧伤害基础攻击伤害抽象类
]]
local newClass = require("third.class.NewClass")

local AAttackHurt = require("app.FightSystem.CharacterHurt.AttackHurt.AAttackHurt")

--@SuperType [src.app.FightSystem.CharacterHurt.AttackHurt.AAttackHurt#AAttackHurt]
local ABasicAttackHurt = {}

--@desc: 击中时执行接口
--@author:Seven
--@time:2023-02-08 11:15:34
function ABasicAttackHurt:inAttack(attacker, target)
    error("ABasicAttackHurt:inAttack 请重写该方法")
end

function ABasicAttackHurt:initHurt()
    self.__attrName = self.__combHurt:getAttrName()
    if self.__combHurt:getHurtDesc() ~= nil then
        self:__setHurtDesc(self.__combHurt:getHurtDesc())
    end

    self:__setBypassShield(self.__combHurt:isBypassShield())

    self:__initAllocPercent()

    --@desc 初始化原始伤害
    self:__initOriginValue()

    self.__shieldCostValue = 0

    return self
end

--@desc: 计算权重占比
--@author:Seven
--@time:2023-02-07 21:10:12
function ABasicAttackHurt:__initAllocPercent()
    self.__allocPercent = (self.__zhaoWeight / self.__combWeight) * (self.__animWeight / self.__animTotalWeight)
end

function ABasicAttackHurt:getAllocPercent()
    if self.__allocPercent == nil then
        error("ABasicAttackHurt:getAllocPercent 权重占比未生成，检查流程")
    end

    return self.__allocPercent
end

--@desc: 计算初始预计伤害值
--@author:Seven
--@time:2023-02-07 21:10:40
function ABasicAttackHurt:__initOriginValue()
    self.__originValue = self.__combHurt:getHurtValue() * self.__allocPercent
end

function ABasicAttackHurt:setCombHurt(combHurt)
    --@RefType [src.app.FightSystem.CharacterHurt.AttackHurt.BasicCombHurt#BasicCombHurt]
    self.__combHurt = combHurt
end

--@desc: 设置组合总权重
--@author:Seven
--@time:2023-02-07 19:41:57
--@combWeight: 总权重
function ABasicAttackHurt:setCombTotalWeight(combWeight)
    self.__combWeight = combWeight
end

--@desc: 设置当前招式权重
--@author:Seven
--@time:2023-02-07 19:42:42
--@zhaoWeight: 当前招式权重
function ABasicAttackHurt:setZhaoWeight(zhaoWeight)
    self.__zhaoWeight = zhaoWeight
end

--@desc: 设置动画击中帧总权重
--@author:Seven
--@time:2023-02-07 19:50:19
--@animTotalWeight: 动画击中帧总权重
function ABasicAttackHurt:setAnimTotalWeight(animTotalWeight)
    self.__animTotalWeight = animTotalWeight
end

--@desc: 当前击中帧总权重
--@author:Seven
--@time:2023-02-07 19:50:53
--@animWeight: 击中帧占用权重
function ABasicAttackHurt:setAnimWeight(animWeight)
    self.__animWeight = animWeight
end

--@desc: 获取原始伤害
--@author:Seven
--@time:2023-02-07 20:00:17
function ABasicAttackHurt:getOriginHurtValue()
    if self.__originValue == nil then
        error("ABasicAttackHurt:getOriginHurtValue 未初始化原始值")
    end
    return self.__originValue
end

function ABasicAttackHurt:isBypassShield()
    return self.__combHurt:getByPassShield()
end

function ABasicAttackHurt:getShieldCostValue()
    return self.__shieldCostValue
end

return newClass("ABasicAttackHurt", {AAttackHurt}, ABasicAttackHurt)
000000