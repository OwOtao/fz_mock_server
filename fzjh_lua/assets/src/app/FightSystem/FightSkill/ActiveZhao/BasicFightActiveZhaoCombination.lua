--[[
    author:Seven
    time:2022-12-06 15:24:13
    desc: 战斗用主动技能招式组合基础类
]]
local newClass = require("third.class.NewClass")

local BasicActiveSkillManager = require("app.models.skill.BasicSkill.BasicActiveSkillManager")

local BasicFightActiveZhaoCombination = {}

function BasicFightActiveZhaoCombination:create(id, lv)
    return BasicFightActiveZhaoCombination.new():__init(id, lv)
end

function BasicFightActiveZhaoCombination:__init(id, lv)
    self.__comb = BasicActiveSkillManager:getBasicActiveZhaoCombination(id, lv)

    return self
end

function BasicFightActiveZhaoCombination:getActiveId()
    return self.__comb:getActiveId()
end

function BasicFightActiveZhaoCombination:getActiveLevel()
    return self.__comb:getActiveLevel()
end

function BasicFightActiveZhaoCombination:getCombName()
    return self.__comb:getCombName()
end

function BasicFightActiveZhaoCombination:getActiveType()
    return self.__comb:getActiveType()
end

-- 主动招式使用对应准备武学类型;
function BasicFightActiveZhaoCombination:getMethods()
    return self.__comb:getMethods()
end

function BasicFightActiveZhaoCombination:getTiliCost()
    return self.__comb:getTiliCost()
end

function BasicFightActiveZhaoCombination:getNeiliCost()
    return self.__comb:getNeiliCost()
end

function BasicFightActiveZhaoCombination:getCD()
    return self.__comb:getCd()
end

function BasicFightActiveZhaoCombination:getHurtPosClass()
    return self.__comb:getHurtPosClass()
end

function BasicFightActiveZhaoCombination:getHurtIDs()
    return self.__comb:getHurtIDs()
end

function BasicFightActiveZhaoCombination:getAttackCount()
    return self.__comb:getAtkCount()
end

function BasicFightActiveZhaoCombination:getAttackZhaoInfos()
    if self.__atkZhaoList == nil then
        self.__atkZhaoList = {}

        local ids = self.__comb:getAtkList()

        for _, zhaoId in ipairs(ids) do
            local autoZhao = BasicActiveSkillManager:getBasicSkillActiveZhaoInfo(zhaoId)

            table.insert(self.__atkZhaoList, autoZhao)
        end
    end

    return self.__atkZhaoList
end

function BasicFightActiveZhaoCombination:getActionText()
    return self.__comb:getActionText()
end

function BasicFightActiveZhaoCombination:getDesc()
    return self.__comb:getDesc()
end

--@desc: 获取准备招式
--@author:Seven
--@time:2023-02-18 17:44:24
--@return [src.app.models.skill.BasicSkill.ActiveZhao.BasicActiveZhaoInfo#BasicActiveZhaoInfo]
function BasicFightActiveZhaoCombination:getReadyZhaoInfo()
    local readyZhaoId = self.__comb:getReadyZhao()
    if readyZhaoId ~= nil then
        return BasicActiveSkillManager:getBasicSkillActiveZhaoInfo(readyZhaoId)
    end

    return nil
end

--@desc: 获取攻击招式
--@author:Seven
--@time:2023-02-19 19:35:18
--@index: 第几招
function BasicFightActiveZhaoCombination:getBasicZhaoInfo(index)
    if index <= 0 or index > self:getAttackCount() then
        error("BasicFightAutoZhaoCombination:getBasicZhaoInfo index 越界")
    end

    return self:getAttackZhaoInfos()[index]
end

--@desc: 判断是否攻击类型的攻击组合（有伤害组的就是伤害技能）
--@author:Seven
--@time:2023-02-19 17:05:27
--@return: true | false
function BasicFightActiveZhaoCombination:isAttackActiveComb()
    return table.getn(self:getHurtIDs()) > 0
end

--@desc: 是否需要前跳
--@author:Seven
--@time:2023-02-19 18:26:48
--@return: true | false
function BasicFightActiveZhaoCombination:isJumpAttack()
    return self.__comb:getIsJumpAttack() == 1
end

--@desc: 组合攻击结束后是否可以接被动技能
--@author:Seven
--@time:2023-02-27 21:19:26
--@return true|false
function BasicFightActiveZhaoCombination:isCompletionUseAuto()
    return self.__comb:getCompletionUseAuto() == 1
end

--@desc: 获取释放条件
--@author:Seven
--@time:2022-12-06 15:48:22
--@return: list
function BasicFightActiveZhaoCombination:getReleaseConditions()
    if self.__releaseConditions == nil then
        self.__releaseConditions = {}

        local releaseConditionsStr = self.__comb:getReleaseConditions()

        if not MapIsEmpty(releaseConditionsStr) then
            for i, v in ipairs(releaseConditionsStr) do
                local condArgs = string.split(v, "#")

                table.insert(self.__releaseConditions, BasicActiveSkillManager:createReleaseCondition(condArgs))
            end
        end
    end

    return self.__releaseConditions
end

--@desc: 获取使用条件
--@author:Seven
--@time:2022-12-06 15:47:46
--@return: list
function BasicFightActiveZhaoCombination:getUseConditions()
    if self.__useConditions == nil then
        self.__useConditions = {}
        local useConditionStrList = self.__comb:getUseConditions()
        if not MapIsEmpty(useConditionStrList) then
            for _, conditionStr in ipairs(useConditionStrList) do
                local condArgs = string.split(conditionStr, "#")

                table.insert(self.__useConditions, BasicActiveSkillManager:createUseCondition(condArgs))
            end
        end
    end

    return self.__useConditions
end

function BasicFightActiveZhaoCombination:getUseHideConditions()
    if self.__useHideConditions == nil then
        self.__useHideConditions = {}
        local useHideConditionStrList = self.__comb:getUseHideConditions()
        if not MapIsEmpty(useHideConditionStrList) then
            for _, conditionStr in ipairs(useHideConditionStrList) do
                local condArgs = string.split(conditionStr, "#")

                table.insert(self.__useHideConditions, BasicActiveSkillManager:createUseCondition(condArgs))
            end
        end
    end

    return self.__useHideConditions
end

function BasicFightActiveZhaoCombination:__walkAttackZhaoInfos(func)
    if self:getAttackCount() <= 0 then
        return
    end

    for i, v in ipairs(self:getAttackZhaoInfos()) do
        func(i, v)
    end
end

function BasicFightActiveZhaoCombination:getCombAttackTotalWeight()
    local value = 0

    self:__walkAttackZhaoInfos(
        function(index, zhao)
            value = value + zhao:getHurtWeight()
        end
    )

    return value
end

--@desc: 该buff添加器应用于主动技能释放过程中
--@author:Seven
--@time:2023-03-11 14:50:55
--@return 添加器id数组
function BasicFightActiveZhaoCombination:getBuffLauncherIdArray()
    return self.__comb:getBuffLauncherAdd()
end

--@desc: 该buff添加器组应用于入场时已准备好的主动技能
--@author:Seven
--@time:2023-03-11 14:52:27
--@return:添加器id数组
function BasicFightActiveZhaoCombination:getEnterBuffLauncherIdArray()
    return self.__comb:getEnteredLauncherAdd()
end

function BasicFightActiveZhaoCombination:getCarryBuffs()
    return self.__comb:getCarryBuffs()
end

return newClass("BasicFightActiveZhaoCombination", {}, BasicFightActiveZhaoCombination)
0000000000