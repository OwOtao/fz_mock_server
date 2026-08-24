local LogSystem = require("app.models.LogSystem.LogSystem")
local oldPrint = print
local function print(...)
    LogSystem:log("增益日志.BuffTriggerAddBuff:", ...)
end

local Desc = require("app.FightSystem.FightBuff.Desc")
local class = require("third.class.NewClass")
local IBuffTrigger = require("app.FightSystem.FightBuff.BuffTrigger.IBuffTrigger")
local Constants = require("app.FightSystem.FightBuff.Constants")

local BuffTriggerAddBuff = {}

function BuffTriggerAddBuff:create(buffSystem, roleId, eventName, eventParam)
    local p = BuffTriggerAddBuff.new()
    p:init(buffSystem, roleId, eventName, eventParam)
    return p
end

function BuffTriggerAddBuff:init(buffSystem, roleId, eventName, eventParam)
    self.__buffSystem, self.__roleId, self.__eventName, self.__eventParam = buffSystem, roleId, eventName, eventParam
end

function BuffTriggerAddBuff:trigger()
    local canAddBuff = true

    -- 先移除需要移除的buff
    local buffLookup = {}
    self.__buffSystem:__walkActiveBuff(
        function(activeBuff, roleId, buffId, buffIndex)
            if buffLookup[buffId] == nil then 
                buffLookup[buffId] = true
                local levelCount = self.__eventParam:removeBuff(activeBuff:getClass(), activeBuff:getId())
                self.__buffSystem:addNeedRemoveBuffByLevelCount(roleId, buffId, levelCount)
            end
        end,
        self.__roleId
    )

    -- 尝试移除buff
    self.__buffSystem:__removeBuff(self.__roleId)

    local hasTrigger, triggerdActiveEffectArray = self.__eventParam:tryTrigger(self.__eventName, self.__eventParam)

    local activeEffectArray = triggerdActiveEffectArray

    local retEffectArray = {}

    if hasTrigger then
        local combinedActiveEffectArray = self.__buffSystem:combineActiveEffect(activeEffectArray)
        table.appendArray(retEffectArray, combinedActiveEffectArray)
    end

    return canAddBuff, retEffectArray
end

return class("BuffTriggerAddBuff", {IBuffTrigger}, BuffTriggerAddBuff)
0000000000000000