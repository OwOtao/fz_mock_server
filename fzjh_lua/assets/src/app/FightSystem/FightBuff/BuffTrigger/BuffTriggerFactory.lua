local LogSystem = require("app.models.LogSystem.LogSystem")
local oldPrint = print
local function print(...)
    LogSystem:log("增益日志.BuffTriggerFactory:", ...)
end

--@RefType[src.app.FightSystem.FightBuff.Constants#Constants]
local BuffSystemConstants = require("app.FightSystem.FightBuff.Constants")

local BuffTriggerFactory = {}

function BuffTriggerFactory:create(buffSystem, roleId, eventName, eventParam)
    return switch(
        eventName,
        {
            [BuffSystemConstants.BuffTriggerType.Add] = function()
                return require("app.FightSystem.FightBuff.BuffTrigger.BuffTriggerAddBuff"):create(buffSystem, roleId, eventName, eventParam)
            end,
            [BuffSystemConstants.BuffTriggerType.GetBuffClass] = function()
                return require("app.FightSystem.FightBuff.BuffTrigger.BuffTriggerUseAutoZhao"):create(buffSystem, roleId, eventName, eventParam)
            end,
            [BuffSystemConstants.BuffTriggerType.SomeBodyAttackEnd] = function()
                return require("app.FightSystem.FightBuff.BuffTrigger.BuffTriggerUseAutoZhao"):create(buffSystem, roleId, eventName, eventParam)
            end,
            [BuffSystemConstants.BuffTriggerType.UseAutoZhao] = function()
                return require("app.FightSystem.FightBuff.BuffTrigger.BuffTriggerUseAutoZhao"):create(buffSystem, roleId, eventName, eventParam)
            end,
            [BuffSystemConstants.BuffTriggerType.UseActiveZhao] = function()
                return require("app.FightSystem.FightBuff.BuffTrigger.BuffTriggerUseAutoZhao"):create(buffSystem, roleId, eventName, eventParam)
            end,
            [BuffSystemConstants.BuffTriggerType.UnderAutoZhao] = function()
                return require("app.FightSystem.FightBuff.BuffTrigger.BuffTriggerUseAutoZhao"):create(buffSystem, roleId, eventName, eventParam)
            end,
            [BuffSystemConstants.BuffTriggerType.UnderActiveZhao] = function()
                return require("app.FightSystem.FightBuff.BuffTrigger.BuffTriggerUseAutoZhao"):create(buffSystem, roleId, eventName, eventParam)
            end,
            default = function()
                print("没有实现的事件 roleId, eventName, eventParam = ", roleId, eventName, eventParam)
                return require("app.FightSystem.FightBuff.BuffTrigger.DoNothingTrigger"):create(buffSystem, roleId, eventName, eventParam)
            end
        }
    )
end

return BuffTriggerFactory
0000000