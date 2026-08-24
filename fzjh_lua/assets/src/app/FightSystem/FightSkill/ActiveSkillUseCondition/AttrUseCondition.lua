--[[
    角色属性条件判断
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local IActiveUseCondition = require("app.FightSystem.FightSkill.ActiveSkillUseCondition.IActiveUseCondition")

local AttrUseCondition = {}

local LogicalSymbolCHText = {
    ["小于"] = "低于",
    ["小于等于"] = "不高于",
    ["等于"] = "为",
    ["大于等于"] = "不低于",
    ["大于"] = "高于"
}

function AttrUseCondition:create(name, logicalSymbol, value)
    local p = self.new()
    p:init(name, logicalSymbol, value)
    return p
end

function AttrUseCondition:getConditionType()
    return "1"
end

function AttrUseCondition:init(name, logicalSymbol, value)
    self.__condAttrName = name
    self.__logicalSymbol = logicalSymbol

    local numValue = tonumber(value)

    if numValue == nil then
        self.__condValue = value
    else
        self.__condValue = numValue
    end
end

--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AttrUseCondition:matchCondititon(f_character)
    local attrName = self.__condAttrName

    self.__currConditionValue = f_character:getAttr(self.__condAttrName)

    local isMatch =
        switch(
        self.__logicalSymbol,
        {
            ["小于"] = function()
                return self.__currConditionValue < self.__condValue
            end,
            ["小于等于"] = function()
                return self.__currConditionValue <= self.__condValue
            end,
            ["等于"] = function()
                return self.__currConditionValue == self.__condValue
            end,
            ["大于等于"] = function()
                return self.__currConditionValue >= self.__condValue
            end,
            ["大于"] = function()
                return self.__currConditionValue > self.__condValue
            end,
            ["default"] = false
        }
    )

    FightUtil:printLog(string.format("属性条件判断 ：【属性】：%s，【判断条件】%s，【条件值】%s，【当前值】%s，【结果】%s", self.__condAttrName, self.__logicalSymbol, self.__condValue, self.__currConditionValue, isMatch))

    return isMatch
end

function AttrUseCondition:getConditionText()
    local symbol_text = LogicalSymbolCHText[self.__logicalSymbol]

    local attr_text = FightUtil:getCharacterAttrCHName(self.__condAttrName)

    return string.format("[%s]%s%d", attr_text, symbol_text, self.__condValue)
end
return newClass("AttrUseCondition", {IActiveUseCondition}, AttrUseCondition)
000000