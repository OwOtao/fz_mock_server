local HurtFactory = {}

local hurtCreateSwitch = {
    ["0"] = require("app.models.fight.Hurt.AutoHurt"),
	["1"] = require("app.models.fight.Hurt.ActiveHurt"),
    ["2"] = require("app.models.fight.Hurt.ShenBingHurt"),
	["3"] = require("app.models.fight.Hurt.FistFootHurt"),
    ["4"] = require("app.models.fight.Hurt.PoisonHurt"),
	["5"] = require("app.models.fight.Hurt.AutoZhaoAddEffectHurt"),
	default = require("app.models.fight.Hurt.BaseHurt"),
}

function HurtFactory:create(type,value)
	return switch(tostring(type), hurtCreateSwitch):create(type,value)
end

return HurtFactory
00000