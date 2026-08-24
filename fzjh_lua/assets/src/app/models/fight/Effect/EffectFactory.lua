local EffectFactory = {}

local effectCreateSwitch = {
	["储伤"] = require("app.models.fight.Effect.SaveDamageEffect"),
    ["监控角色属性"] = require("app.models.fight.Effect.AttrMonitorEffect"),
	["角色立即死亡"] = require("app.models.fight.Effect.SelfKillEffect"),
	default = require("app.models.fight.Effect.BaseEffect")
}

function EffectFactory:create(effect)
	return switch(effect:getType(), effectCreateSwitch):create(effect)
end

return EffectFactory
00000000