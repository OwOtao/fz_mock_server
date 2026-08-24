local EffectTriggerFactory = {}
local Constants = require("app.FightSystem.FightBuff.Constants")

function EffectTriggerFactory:create(activeEffect, eventName, eventParam)
    return switch(
        activeEffect:getEffectType(),
        {
            [Constants.EffectType.AutoZhaoReductionOfInjurySub] = function()
            end
        }
    )
end

return EffectTriggerFactory
00000