local newClass = require("third.class.NewClass")

local IActiveSkillReleaseCondition = require("app.FightSystem.FightSkill.ActiveSkillRelaseCondition.IActiveSkillReleaseCondition")

local FightFormula = require("app.FightSystem.FightFormula")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightSkill.ActiveSkillRelaseCondition.IActiveSkillReleaseCondition#IActiveSkillReleaseCondition]
local AttrPercentCondition = {
    __type = 1
}

function AttrPercentCondition:create(attrName, logicalSymbol, condAttrName, condValue, failureTextId)
    local p = AttrPercentCondition.new()
    p:__init(attrName, logicalSymbol, condAttrName, condValue, failureTextId)
    return p
end

function AttrPercentCondition:__init(attrName, logicalSymbol, condAttrName, condValue, failureTextId)
    self.__attrName = attrName

    self.__logicalSymbol = logicalSymbol

    self.__condAttrName = condAttrName

    self.__condValue = condValue

    self.__failureTextId = failureTextId
end

--@desc:
--@author:Seven
--@time:2021-11-17 16:15:19
--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AttrPercentCondition:canRelease(f_character)
    local currConditionValue = f_character:getAttr(self.__attrName)

    local condiValue = f_character:getAttr(self.__condAttrName) * self.__condValue

    local isMatch =
        switch(
        self.__logicalSymbol,
        {
            ["小于"] = function()
                return currConditionValue < condiValue
            end,
            ["小于等于"] = function()
                return currConditionValue <= condiValue
            end,
            ["等于"] = function()
                return currConditionValue == condiValue
            end,
            ["大于等于"] = function()
                return currConditionValue >= condiValue
            end,
            ["大于"] = function()
                return currConditionValue > condiValue
            end,
            ["default"] = false
        }
    )

    if not isMatch then
        --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
        local fightDesc = require("app.FightSystem.FightUtil.FightDesc"):create()
        fightDesc:setText(TextResManager:getText(self.__failureTextId))
        fightDesc:setActiveZhaoNeedAttr(FightUtil:getCharacterAttrCHName(self.__attrName), math.ceil(condiValue))

        return false, fightDesc:getString()
    end

    return true
end

return newClass("AttrPercentCondition", {IActiveSkillReleaseCondition}, AttrPercentCondition)
0