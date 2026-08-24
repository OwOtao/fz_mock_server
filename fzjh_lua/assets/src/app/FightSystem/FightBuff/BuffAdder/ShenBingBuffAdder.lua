local class = require("third.class.NewClass")
local BuffAdder = require("app.FightSystem.FightBuff.BuffAdder.BuffAdder")
local BuffSystemResource = require("app.FightSystem.FightBuff.BuffSystemResource")
local BuffAddItem = require("app.FightSystem.FightBuff.BuffAdder.BuffAddItem")

local ShenBingBuffAdder = {}

function ShenBingBuffAdder:create(buffLaunchers, dynamicParamMap)
    local p = ShenBingBuffAdder.new()
    p:init(buffLaunchers, dynamicParamMap)
    return p
end

function ShenBingBuffAdder:init(buffLaunchers, dynamicParamMap)
    if buffLaunchers then
        for _, buffLauncher in pairs(buffLaunchers) do
            local items = BuffSystemResource:getShenBingBuffAdderData(buffLauncher)
            for _, item in ipairs(items) do
                table.insert(self.__buffAddItems, BuffAddItem:create(item, dynamicParamMap))
            end
        end
    end
end

function ShenBingBuffAdder:conditionCheck(fight, attacker, target, allHit, hasDodge, hasParry)
    for i, buffAddItem in ipairs(self.__buffAddItems) do
        local triggerType = buffAddItem:getTriggerType()
        if (triggerType == 10 and allHit) or (triggerType == 11 and hasParry) or (triggerType == 12 and hasDodge) then
            if buffAddItem:canAdd(fight, attacker, target) then
                buffAddItem:setNeedAdd(true)
            else
                buffAddItem:setNeedAdd(false)
            end
        end
    end
end

return class("ShenBingBuffAdder", {BuffAdder}, ShenBingBuffAdder)
00000