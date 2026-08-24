local class = require("third.class.NewClass")
local IEffectTrigger = require("app.FightSystem.FightBuff.EffectTrigger.IEffectTrigger")

local EffectTriggerUnderAutoZhao = {}

function EffectTriggerUnderAutoZhao:create()
end

function EffectTriggerUnderAutoZhao:trigger()
end

return class("EffectTriggerUnderAutoZhao", {IEffectTrigger}, EffectTriggerUnderAutoZhao)
0000000