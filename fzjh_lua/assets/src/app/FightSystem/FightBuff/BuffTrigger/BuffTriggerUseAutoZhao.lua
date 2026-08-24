local LogSystem = require("app.models.LogSystem.LogSystem")
local oldPrint = print
local function print(...)
    LogSystem:log("增益日志.BuffTriggerUseAutoZhao:", ...)
end

local Desc = require("app.FightSystem.FightBuff.Desc")
local class = require("third.class.NewClass")
local IBuffTrigger = require("app.FightSystem.FightBuff.BuffTrigger.IBuffTrigger")
local Constants = require("app.FightSystem.FightBuff.Constants")

local BuffTriggerUseAutoZhao = {}

function BuffTriggerUseAutoZhao:create(buffSystem, roleId, eventName, eventParam)
    local p = BuffTriggerUseAutoZhao.new()
    p:init(buffSystem, roleId, eventName, eventParam)
    return p
end

function BuffTriggerUseAutoZhao:init(buffSystem, roleId, eventName, eventParam)
    self.__buffSystem, self.__roleId, self.__eventName, self.__eventParam = buffSystem, roleId, eventName, eventParam
end

function BuffTriggerUseAutoZhao:trigger()
    local hasTrigger = false
    local activeEffectArray = {}
    self.__buffSystem:__walkActiveBuff(
        function(activeBuff)
            local success, triggerdActiveEffectArray = activeBuff:tryTrigger(self.__eventName, self.__eventParam)
            if success then
                hasTrigger = true

                -- 效果
                table.appendArray(activeEffectArray, triggerdActiveEffectArray)
            end
        end,
        self.__roleId
    )

    local retEffectArray = {}

    if hasTrigger then
        local combinedActiveEffectArray = self.__buffSystem:combineActiveEffect(activeEffectArray)
        table.appendArray(retEffectArray, combinedActiveEffectArray)
    end

    return hasTrigger, retEffectArray
end

return class("BuffTriggerUseAutoZhao", {IBuffTrigger}, BuffTriggerUseAutoZhao)
0000000000000