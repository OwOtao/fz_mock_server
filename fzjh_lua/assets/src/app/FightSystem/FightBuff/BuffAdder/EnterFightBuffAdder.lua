local class = require("third.class.NewClass")
local BuffAdder = require("app.FightSystem.FightBuff.BuffAdder.BuffAdder")
local BuffSystemResource = require("app.FightSystem.FightBuff.BuffSystemResource")
local BuffAddItem = require("app.FightSystem.FightBuff.BuffAdder.BuffAddItem")

local EnterFightBuffAdder = {}

function EnterFightBuffAdder:create(buffLaunchers)
    local p = EnterFightBuffAdder.new()
    p:init(buffLaunchers)
    return p
end

function EnterFightBuffAdder:init(buffLaunchers)
    if buffLaunchers then
        for _, buffLauncher in pairs(buffLaunchers) do
            local items = BuffSystemResource:getEnterFightBuffAdderData(buffLauncher)
            for _, item in ipairs(items) do
                table.insert(self.__buffAddItems, BuffAddItem:create(item))
            end
        end
    end
end

-- function EnterFightBuffAdder:conditionCheck(fight, attacker, target, allHit, hasDodge, hasParry)
--     for i, buffAddItem in ipairs(self.__buffAddItems) do
--         local triggerType = buffAddItem:getTriggerType()
--         if (triggerType == 10 and allHit) or (triggerType == 11 and hasDodge) or (triggerType == 12 and hasParry) then
--             if buffAddItem:canAdd(fight, attacker, target) then
--                 buffAddItem:setNeedAdd(true)
--             else
--                 buffAddItem:setNeedAdd(false)
--             end
--         end
--     end
-- end

return class("EnterFightBuffAdder", {BuffAdder}, EnterFightBuffAdder)
00000