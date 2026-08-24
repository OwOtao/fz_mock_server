local class = require("third.class.NewClass")
local IBuffTrigger = require("app.FightSystem.FightBuff.BuffTrigger.IBuffTrigger")

local DoNothingTrigger = {}

function DoNothingTrigger:create()
    return DoNothingTrigger.new()
end

function DoNothingTrigger:trigger()
    return false, {}
end

return class("DoNothingTrigger", {IBuffTrigger}, DoNothingTrigger)
00000000