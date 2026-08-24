local class = require("third.class.NewClass")
local FightCommons = require("app.FightSystem.FightCommons")
local Desc = require("app.FightSystem.FightBuff.Desc")
local LogSystem = require("app.models.LogSystem.LogSystem")
local FightBuffConstants = require("app.FightSystem.FightBuff.Constants")
local IBuffExecutor = require("app.FightSystem.FightBuff.IBuffExecutor")

local function print(...)
    return LogSystem:logWithTab("BuffEmptyExecutor:", ...)
end

local BuffEmptyExecutor = {}

function BuffEmptyExecutor:create()
    return BuffEmptyExecutor.new()
end

function BuffEmptyExecutor:attackExecute(attackBuffExecutors)
    print("BuffEmptyExecutor:attackExecute(attackBuffExecutors)")
end

return class("BuffExecutor", {IBuffExecutor}, BuffEmptyExecutor)
00000000000000