local class = require("third.class.NewClass")
local BuffSystemResource = require("app.FightSystem.FightBuff.BuffSystemResource")
local BuffAddItem = require("app.FightSystem.FightBuff.BuffAdder.BuffAddItem")
local Desc = require("app.FightSystem.FightBuff.Desc")

local BuffAdder = {}

function BuffAdder:create(buffLaunchers)
    local p = BuffAdder.new()
    p:init(buffLaunchers)
    return p
end

function BuffAdder:ctor()
    self.__buffAddItems = {}
end

function BuffAdder:init(buffLaunchers)
    if buffLaunchers then
        for _, buffLauncher in pairs(buffLaunchers) do
            local items = BuffSystemResource:getBuffAdderData(buffLauncher)
            for _, item in ipairs(items) do
                table.insert(self.__buffAddItems, BuffAddItem:create(item))
            end
        end
    end
end

function BuffAdder:getTriggerType()
    for _, buffAddItem in ipairs(self.__buffAddItems) do
        return buffAddItem:getTriggerType()
    end
end

function BuffAdder:setBuffNeeded(buffNeeded)
    self.__buffNeeded = buffNeeded
    for _, buffAddItem in ipairs(self.__buffAddItems) do
        buffAddItem:setBuffNeeded(buffNeeded)
    end
end

function BuffAdder:setCharacter(character)
    for _, buffAddItem in ipairs(self.__buffAddItems) do
        buffAddItem:setCharacter(character)
    end
end

--[[
    @desc: 条件判断
    author:TangJian
    time:2022-03-03 15:12:00
    --@fight:
	--@attacker:
	--@target: 
    @return:
]]
function BuffAdder:conditionCheck(fight, attacker, target, allHit, hasDodge, hasParry)
    -- 添加buff条件判断
    local preConditionMap = {}
    for i, buffAddItem in ipairs(self.__buffAddItems) do
        local preConditionIsTrue = preConditionMap[buffAddItem:getPreConditionId()] == nil or preConditionMap[buffAddItem:getPreConditionId()] == true

        if not preConditionIsTrue then
            print("添加器前置条件不成立", buffAddItem:getId())
        end

        if preConditionIsTrue and buffAddItem:canAdd(fight, attacker, target) then
            preConditionMap[buffAddItem:getContidionId()] = true
            buffAddItem:setNeedAdd(true)
        else
            preConditionMap[buffAddItem:getContidionId()] = false
            buffAddItem:setNeedAdd(false)
        end
    end
end

--[[
    @desc: 添加buff
    author:TangJian
    time:2022-03-03 15:12:09
    --@fight:
	--@attacker:
	--@target:
	--@when: 
    @return:
]]
function BuffAdder:addBuff(fight, attacker, target, when, zhaoCombHitPosName)
    local buffExecutors = {}
    -- 添加buff
    for _, buffAddItem in ipairs(self.__buffAddItems) do
        if buffAddItem:needAdd() then
            table.appendArray(buffExecutors, buffAddItem:addBuffWhen(fight, attacker, target, when, zhaoCombHitPosName))
        end
    end
    return buffExecutors
end

return class("BuffAdder", {}, BuffAdder)
00000000000000