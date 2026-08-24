--[[
    战斗中使用的主动技能
]]
local class = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightFormula = require("app.FightSystem.FightFormula")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local NormalFightActiveSkill = {
    __character = nil,
    __cd = 0,
    __zhaoComb = nil,
    __releaseConditonsCache = nil
}

function NormalFightActiveSkill:create()
    return self.new()
end

function NormalFightActiveSkill:setCharacter(f_character)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__character = f_character
end

function NormalFightActiveSkill:getCharacter()
    return self.__character
end

function NormalFightActiveSkill:setZhaoComb(zhao_comb)
    --@RefType[src.app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombination#ActiveZhaoCombination]
    self.__zhaoComb = zhao_comb
end

function NormalFightActiveSkill:getType()
    return self.__zhaoComb:getActiveType()
end

function NormalFightActiveSkill:getCD()
    return self.__cd
end

function NormalFightActiveSkill:getCoolDownTime()
    return self.__zhaoComb:getCD()
end

function NormalFightActiveSkill:setCD(cd)
    if cd == nil then
        assert(false, self:getName() .. " 设置技能CD参数错误" .. cd)
    end

    if cd < 0 then
        assert(false, self:getName() .. "设置技能CD不可为负数")
    end

    self.__cd = cd
end

function NormalFightActiveSkill:getDesc()
    return self.__zhaoComb:getDesc()
end

--@desc: 返回招式组合
--@author:Seven
--@time:2021-06-17 15:15:56
--@return [src.app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombination#ActiveZhaoCombination]
function NormalFightActiveSkill:getZhaoComb()
    return self.__zhaoComb
end

-- 获得入场buff添加器
function NormalFightActiveSkill:getEnterFightBuffAdder()
    return self.__zhaoComb:getEnterFightBuffAdder()
end

function NormalFightActiveSkill:getId()
    return self.__zhaoComb:getActiveId()
end

function NormalFightActiveSkill:getName()
    return self.__zhaoComb:getActiveName()
end

function NormalFightActiveSkill:getLevel()
    return self.__zhaoComb:getActiveLevel()
end

function NormalFightActiveSkill:getNeiliCost()
    local zhaoCost = self.__zhaoComb:getNeiliCost()
    -- FightUtil:printLog(string.format("主动技能%s内力消耗：", self:getName()))
    local value = FightFormula:calActiveActtackNeiliCost(zhaoCost, self.__character:getMulActiveZhaoNeiliCost(), self.__character:getAddActiveZhaoNeiliCost())
    return value
end

function NormalFightActiveSkill:getTiliCost()
    local zhaoCost = self.__zhaoComb:getTiliCost()
    -- FightUtil:printLog(string.format("主动技能%s体力消耗：", self:getName()))
    local value = FightFormula:calActiveAttackTiliCost(zhaoCost, self.__character:getMulActiveZhaoTiliCost(), self.__character:getAddAutoZhaoTiliCost())
    return value
end

function NormalFightActiveSkill:isAttackTypeSkill()
    return self.__zhaoComb:getActiveType() == FightCommons.ACTIVE_TYPE.ATTACK
end

function NormalFightActiveSkill:isReleaseTypeSkill()
    return self.__zhaoComb:getActiveType() == FightCommons.ACTIVE_TYPE.RELEASE
end

function NormalFightActiveSkill:releaseAreMet()
    local releaseCondiMeet, failureText = self:__isReleaseCondiAreMet()
    if not releaseCondiMeet then
        return releaseCondiMeet, failureText
    end

    local costMeet, failureText = self:__isMeetTheCost()
    if not costMeet then
        return costMeet, failureText
    end

    return true
end

function NormalFightActiveSkill:__isReleaseCondiAreMet()
    local releaseConditionsStr = self.__zhaoComb:getReleaseConditions()

    if MapIsEmpty(releaseConditionsStr) then
        return true
    end

    if self.__releaseConditonsCache == nil then
        self.__releaseConditonsCache = {}
        for i, v in ipairs(releaseConditionsStr) do
            local conditionArgs = string.split(v, "#")
            local releaseType = conditionArgs[1]
            local conditionClass =
                switch(
                releaseType,
                {
                    ["1"] = function()
                        return require("app.FightSystem.FightSkill.ActiveSkillRelaseCondition.AttrPercentCondition")
                    end,
                    ["2"] = function()
                        return require("app.FightSystem.FightSkill.ActiveSkillRelaseCondition.SwitchWeaponTypeCondition")
                    end,
                    ["3"] = function()
                        return require("app.FightSystem.FightSkill.ActiveSkillRelaseCondition.SwitchWeaponFightStateCondition")
                    end
                }
            )

            table.insert(self.__releaseConditonsCache, conditionClass:create(conditionArgs[2], conditionArgs[3], conditionArgs[4], conditionArgs[5], conditionArgs[6]))
        end
    end

    for i, v in ipairs(self.__releaseConditonsCache) do
        --@RefType [src.app.FightSystem.FightSkill.ActiveSkillRelaseCondition.IActiveSkillReleaseCondition#IActiveSkillReleaseCondition]
        local condClass = v

        local isMet, failureText = condClass:canRelease(self.__character)

        if not isMet then
            return isMet, failureText
        end
    end

    return true
end

--@desc: 是否满足消耗
--@author:Seven
--@time:2021-07-15 14:15:33
function NormalFightActiveSkill:__isMeetTheCost()
    --@desc 体力消耗（功能需求，需实时计算）
    local costTili = self:getTiliCost()
    if costTili > self.__character:getAttr("tili") then
        return false, TextResManager:getText("1002")
    end

    local costNeili = self:getNeiliCost()
    if costNeili > self.__character:getAttr("neili") then
        return false, TextResManager:getText("1001")
    end

    return true
end

function NormalFightActiveSkill:underBan()
    local buffSys = self.__character:getBuffSystem()

    local isBan, popTips = buffSys:roleIsBanActiveZhao(self.__character:getId(), self.__zhaoComb:getActiveType())

    return isBan, popTips
end

--@desc: 条件类创建
--@author:Seven
--@time:2021-08-31 11:18:26
--@conditionStr: 配置字符
--@return src.app.FightSystem.FightSkill.ActiveSkillUseCondition.IActiveUseCondition#IActiveUseCondition
function NormalFightActiveSkill:__createUseCondition(condArgs)
    local useCondType = condArgs[1]

    local condClass =
        switch(
        useCondType,
        {
            ["1"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.AttrUseCondition")
            end,
            ["2"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.SkillLevelConditon")
            end,
            ["3"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.PrepSkillCondition")
            end,
            ["4"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.UseWeaponCondition")
            end,
            ["5"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.CharacterFamilyMatchCondition")
            end,
            ["6"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.PrepAndUseSkillCondition")
            end,
            ["7"] = function()
                return require("app.FightSystem.FightSkill.ActiveSkillUseCondition.PrepAndUseSkillMatchFamilyCondition")
            end
        }
    )

    return condClass:create(condArgs[2], condArgs[3], condArgs[4])
end

function NormalFightActiveSkill:isMeetUseCondtion()
    local useConditionArgList = self:__getUseConditions()

    FightUtil:printLog(string.format("角色：%s，主动技能【%s】使用条件判断：", self.__character:getAttr("name"), self:getName()))

    local isMatch = true
    if not MapIsEmpty(useConditionArgList) then
        for _, conditionArgs in ipairs(useConditionArgList) do
            local condition = self:__createUseCondition(conditionArgs)

            if condition:matchCondititon(self.__character) == false then
                isMatch = false
            end
        end
    end

    FightUtil:printLog(string.format("使用条件判断结束，结果：%s", isMatch))

    return isMatch
end

function NormalFightActiveSkill:getUseConditionTexts()
    local texts = {}

    local useConditionArgList = self:__getTextUseConditions()

    if MapIsEmpty(useConditionArgList) then
        return texts
    end

    for _, conditionArgs in ipairs(useConditionArgList) do
        local condition = self:__createUseCondition(conditionArgs)

        local text = condition:getConditionText()

        if text ~= "" and text ~= nil then
            table.insert(texts, text)
        end
    end

    return texts
end

-- 获取携带的buff
function NormalFightActiveSkill:getCarryBuffs()
    return self.__zhaoComb:getCarryBuffs()
end

return class("NormalFightActiveSkill", {}, NormalFightActiveSkill)
0000000