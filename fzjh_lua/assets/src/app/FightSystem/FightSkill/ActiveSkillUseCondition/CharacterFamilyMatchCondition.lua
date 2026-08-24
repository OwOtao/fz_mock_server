--[[
    角色门派匹配判断
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local IActiveUseCondition = require("app.FightSystem.FightSkill.ActiveSkillUseCondition.IActiveUseCondition")

local FamilyFactory = require("app.models.family.FamilyFactory")

local CharacterFamilyMatchCondition = {}

function CharacterFamilyMatchCondition:create(familyIds, placeholder, logicalSymbol)
    local p = self.new()
    p:init(familyIds, placeholder, logicalSymbol)
    return p
end

function CharacterFamilyMatchCondition:init(familyIds, placeholder, logicalSymbol)
    self.__condFamilyIds = string.split(familyIds, "@")
    self.__placeholder = placeholder
    self.__logicalSymbol = logicalSymbol
end

function CharacterFamilyMatchCondition:getConditionType()
    return "5"
end

--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function CharacterFamilyMatchCondition:matchCondititon(f_character)
    local isMatch = false

    if #self.__condFamilyIds > 0 then
        local c_familyId = f_character:getFamilyId()
        FightUtil:printLog(string.format("角色门派判断 ：【角色门派】%s", tostring(c_familyId)))
        for i = 1, #self.__condFamilyIds do
            local condfamilyId = self.__condFamilyIds[i]
            local currMatch = false
            if self.__logicalSymbol == "是" then
                if condfamilyId == c_familyId then
                    isMatch = true
                    currMatch = true
                end
            else
                error("主动技能使用判断，角色门派判断，判断值无法识别：" .. tostring(self.__logicalSymbol))
            end
            FightUtil:printLog(string.format(" └─【条件门派Id】：%s，【判断条件】%s，【结果】%s", condfamilyId, self.__logicalSymbol, currMatch))
        end
    end

    return isMatch
end

function CharacterFamilyMatchCondition:getConditionText()
    local str = "[门派]为"

    if #self.__condFamilyIds > 0 then
        for i = 1, #self.__condFamilyIds do
            local familyId = self.__condFamilyIds[i]
            local familyFactor = FamilyFactory:getFamilyFactor(familyId)
            if i == #self.__condFamilyIds then
                str = str .. "[" .. familyFactor:getName() .. "]"
            else
                str = str .. "[" .. familyFactor:getName() .. "]或"
            end
        end
    end

    -- return string.format("[%s]%s%d", attr_text, symbol_text, self.__condValue)
    return str
end
return newClass("CharacterFamilyMatchCondition", {IActiveUseCondition}, CharacterFamilyMatchCondition)
000000000