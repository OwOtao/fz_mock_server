local newClass = require("third.class.NewClass")

local BasicFightActiveSkill = require("app.FightSystem.FightSkill.BasicFightActiveSkill")

--@SuperType [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
local PlayerFightActiveSkill = {}

function PlayerFightActiveSkill:create(id, lv)
    return PlayerFightActiveSkill.new():__init(id, lv)
end

function PlayerFightActiveSkill:__getUseConditions()
    local useConditionList = table.mergeArray(self.__comb:getUseConditions(), self.__comb:getUseHideConditions())

    local conditions = {}

    if not MapIsEmpty(useConditionList) then
        for _, condition in ipairs(useConditionList) do
            table.insert(conditions, condition)
        end
    end

    return conditions
end

function PlayerFightActiveSkill:__getTextUseConditions()
    local useConditionList = self.__comb:getUseConditions()

    local conditions = {}

    if not MapIsEmpty(useConditionList) then
        for _, condition in ipairs(useConditionList) do
            table.insert(conditions, condition)
        end
    end

    return conditions
end

return newClass("PlayerFightActiveSkill", {BasicFightActiveSkill}, PlayerFightActiveSkill)
0000000000