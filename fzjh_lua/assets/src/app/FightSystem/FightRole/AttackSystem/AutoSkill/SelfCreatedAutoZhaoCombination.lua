local SelfCreatedSkillManager = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillManager.SelfCreatedSkillManager")

local AutoZhaoCombination = require("app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombination")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local class = require("third.class.NewClass")

local SelfCreatedAutoZhaoCombination = {
    __id = "null", --@desc: 招式组合ID
    __skillId = "", --@desc: 对应武学ID
    __zhaoId = "", --@desc: 招式组id
    __zhaoIdText = "", --@desc: 第几招
    __zhaoName = "", --@desc: 招式名称
    __damageType = nil, --@desc 伤害描述文本
    __hurtPosClass = "default", --@desc:击中部位系列
    __actionText = "", --@desc: 出招文本
    __attack = 0, --@desc: 攻击性能
    __hit = 0, --@desc: 命中性能
    __topLimit = 0, --@desc: 伤害性能
    __tiliCost = 0, --@desc: 消耗体力
    __atkList = {}, --@desc: 招式攻击段（攻击段id组合）
    __lv = 0, ---@desc:需求武学等级
    __attackAverage = 0 --@desc 平均攻击性能
}

--@desc: 创建自创武学被动招式Comb
--@author:LvBin
--@time:2022-01-18 15:11:35
--@autoZhao: [src.app.models.SelfCreatedSkillSystem.SelfCreatedZhao.SelfCreatedZhao#SelfCreatedZhao]
	--@skill: [src.app.models.SelfCreatedSkillSystem.SelfCreatedSkill.SelfCreatedSkill#SelfCreatedSkill]
--@return
function SelfCreatedAutoZhaoCombination:create(autoZhao,skill)
    local p = SelfCreatedAutoZhaoCombination.new()
    p:init(autoZhao,skill)
    return p
end

--@desc: 
--@author:LvBin
--@time:2022-01-18 15:58:09
--@autoZhao: [src.app.models.SelfCreatedSkillSystem.SelfCreatedZhao.SelfCreatedZhao#SelfCreatedZhao]
	--@skill: [src.app.models.SelfCreatedSkillSystem.SelfCreatedSkill.SelfCreatedSkill#SelfCreatedSkill]
--@return
function SelfCreatedAutoZhaoCombination:init(autoZhao,skill)
    self.__id = skill:getId()..autoZhao:getId()

    self.__skillId = skill:getId()

    self.__zhaoId = autoZhao:getId()

    self.__zhaoIdText = "第"..Helper:numberCast(autoZhao:getIndex()).."招"
    
    self.__zhaoName = autoZhao:getName()

    self.__damageType = autoZhao:getDamageTypeLv()

    self.__hurtPosClass = autoZhao:getHurtPosClass()
    
    self.__actionText = string.gsub(autoZhao:getAction(), "$w", "$Nw")

    local zhaoAttackValue = autoZhao:getAttack()
    local transform_damRate = SelfCreatedSkillManager:getParamsById("transform_damRate")
    local transform_nAtk = SelfCreatedSkillManager:getParamsById("transform_nAtk")
    local transform_dam = SelfCreatedSkillManager:getParamsById("transform_dam")
    local transform_attackNewParam = SelfCreatedSkillManager:getParamsById("transform_attackNewParam")
    
    self.__attack = zhaoAttackValue * transform_damRate * transform_nAtk + autoZhao:getTopLimit() * transform_dam * zhaoAttackValue * transform_attackNewParam * transform_damRate * transform_nAtk
    
    FightUtil:printLog("SelfCreatedAutoZhaoCombination:initData 攻击性能计算: ",self.__id)
    FightUtil:printLog("自创.实际攻击性能:", zhaoAttackValue)
    FightUtil:printLog("武学招式伤害系数转换系数transform_damRate：", transform_damRate)
    FightUtil:printLog("攻击性能转换系数transform_nAtk：", transform_nAtk)
    FightUtil:printLog("伤害性能转换系数：", transform_dam)
    FightUtil:printLog("攻击性能新版修正系数：", transform_attackNewParam)
    FightUtil:printLog("self.__attack 计算结果 ：", self.__attack )

    local zhaoHitValue = autoZhao:getHit()
    local transform_hit = SelfCreatedSkillManager:getParamsById("transform_hit")
    
    self.__hit = zhaoHitValue * transform_hit

    FightUtil:printLog("SelfCreatedAutoZhaoCombination:initData 命中性能计算: ",self.__id)
    FightUtil:printLog("自创.实际命中性能:", zhaoHitValue)
    FightUtil:printLog("命中性能转换系数：", transform_hit)
    FightUtil:printLog("self.__hit 计算结果 ：", self.__hit)

    local topLimitValue = autoZhao:getTopLimit()

    self.__topLimit = topLimitValue * transform_dam

    FightUtil:printLog("SelfCreatedAutoZhaoCombination:initData 伤害性能计算: ",self.__id)
    FightUtil:printLog("自创.实际伤害性能:", topLimitValue)
    FightUtil:printLog("伤害性能转换系数：", transform_dam)
    FightUtil:printLog("self.__topLimit 计算结果 ：", self.__topLimit)

    local transform_preDuration = SelfCreatedSkillManager:getParamsById("transform_preDuration")
    local spiritValue = autoZhao:getSpirit()
    local transform_aftDuration = SelfCreatedSkillManager:getParamsById("transform_aftDuration")
    local transform_tiliCostNew = SelfCreatedSkillManager:getParamsById("transform_tiliCostNew")

    self.__tiliCost = (transform_preDuration + spiritValue * transform_aftDuration) * transform_tiliCostNew

    FightUtil:printLog("SelfCreatedAutoZhaoCombination:initData 使用被动消耗体力计算: ",self.__id)
    FightUtil:printLog("招式攻击前摇转换系数:", transform_preDuration)
    FightUtil:printLog("实际体力消耗：", spiritValue)
    FightUtil:printLog("体力消耗转换系数:", transform_aftDuration)
    FightUtil:printLog("体力消耗新版修正系数：", transform_tiliCostNew)
    FightUtil:printLog("self.__tiliCost 计算结果 ：", self.__tiliCost)

    self.__atkList = autoZhao:getAtkList()

    self.__lv = autoZhao:getGrade()

    local attackAverageValue = skill:getAttackAverage()

    FightUtil:printLog("平均攻击性能:", attackAverageValue)

    self.__attackAverage = attackAverageValue
end

return class("SelfCreatedAutoZhaoCombination", {AutoZhaoCombination}, SelfCreatedAutoZhaoCombination)0