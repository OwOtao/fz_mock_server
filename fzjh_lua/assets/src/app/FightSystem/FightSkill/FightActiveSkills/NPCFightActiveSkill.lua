local newClass = require("third.class.NewClass")

local BasicFightActiveSkill = require("app.FightSystem.FightSkill.BasicFightActiveSkill")

--@SuperType [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
local NPCFightActiveSkill = {}

function NPCFightActiveSkill:create(id, lv)
    return NPCFightActiveSkill.new():__init(id, lv)
end

function NPCFightActiveSkill:__getUseConditions()
    local useConditionList = table.mergeArray(self.__comb:getUseConditions(), self.__comb:getUseHideConditions())

    local conditions = {}

    if not MapIsEmpty(useConditionList) then
        for _, condition in ipairs(useConditionList) do
            if condition:getConditionType() == "4" then
                table.insert(conditions, condition)
            end
        end
    end

    return conditions
end

function NPCFightActiveSkill:__getTextUseConditions()
    local useConditionList = self.__comb:getUseConditions()

    local conditions = {}

    if not MapIsEmpty(useConditionList) then
        for _, condition in ipairs(useConditionList) do
            if condition:getConditionType() == "4" then
                table.insert(conditions, condition)
            end
        end
    end

    return conditions
end

return newClass("NPCFightActiveSkill", {BasicFightActiveSkill}, NPCFightActiveSkill)
000