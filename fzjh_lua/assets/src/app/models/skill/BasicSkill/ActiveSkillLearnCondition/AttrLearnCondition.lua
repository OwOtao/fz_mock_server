--[[
    角色属性条件判断
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local IActiveLearnCondition = require("app.models.skill.BasicSkill.ActiveSkillLearnCondition.IActiveLearnCondition")

local AttrLearnCondition = {}

local LogicalSymbolCHText = {
    ["小于"] = "低于",
    ["小于等于"] = "不高于",
    ["等于"] = "为",
    ["大于等于"] = "不低于",
    ["大于"] = "高于"
}

function AttrLearnCondition:create(name, logicalSymbol, value)
    local p = AttrLearnCondition.new()
    p:init(name, logicalSymbol, value)
    return p
end

function AttrLearnCondition:init(name, logicalSymbol, value)
    --@desc 由于学习条件的属性目前按照旧表在使用，因此先进行一次属性名映射，后续全游戏替换的话此处映射可以去掉
    local new_name =
        switch(
        name,
        {
            ["currStr"] = "strCondSkill",
            ["currDex"] = "dexCondSkill",
            ["currCon"] = "conCondSkill",
            ["currInt"] = "intCondSkill",
            ["default"] = name
        }
    )
    self.__condAttrName = new_name
    self.__logicalSymbol = logicalSymbol

    local numValue = tonumber(value)

    if numValue == nil then
        self.__condValue = value
    else
        self.__condValue = numValue
    end
end

function AttrLearnCondition:matchCondititon(f_character)
    --@desc 暂未开放使用
    return false
end

function AttrLearnCondition:getConditionText()
    local symbol_text = LogicalSymbolCHText[self.__logicalSymbol]

    local attr_text = FightUtil:getCharacterAttrCHName(self.__condAttrName)

    return string.format("[%s]%s%d", attr_text, symbol_text, self.__condValue)
end
return newClass("AttrLearnCondition", {IActiveLearnCondition}, AttrLearnCondition)
0000000000000000