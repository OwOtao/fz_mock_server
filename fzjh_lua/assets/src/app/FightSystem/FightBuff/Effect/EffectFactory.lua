local Constants = require("app.FightSystem.FightBuff.Constants")

local EffectFactory = {}

local effectCreateSwitch = {
	[Constants.EffectType.ShieldHp] = require("app.FightSystem.FightBuff.Effect.ShieldEffect"),
	[Constants.EffectType.TargetAutoDodgeEffectCurrAttr] = require("app.FightSystem.FightBuff.Effect.AutoDodgeAddCurrAttrEffect"),
	[Constants.EffectType.TargetAutoParryEffectCurrAttr] = require("app.FightSystem.FightBuff.Effect.AutoParryAddCurrAttrEffect"),
	[Constants.EffectType.TargetAutoParryOnHitDamageEffectCurrAttr] = require("app.FightSystem.FightBuff.Effect.AutoParryAddCurrAttrEffect"),
	[Constants.EffectType.RemoveBuffClass] = require("app.FightSystem.FightBuff.Effect.RemoveBuffEffect"),
	[Constants.EffectType.AddActiveZhaoRemainCD] = require("app.FightSystem.FightBuff.Effect.AddActiveZhaoCDEffect"),
	[Constants.EffectType.TransferBuff] = require("app.FightSystem.FightBuff.Effect.TransferBuffEffect"),
	[Constants.EffectType.UnderAutoZhaoPierceQiDamageReduction] = require("app.FightSystem.FightBuff.Effect.UnderAutoZhaoPierceQiDamgeReductionEffect"),
	[Constants.EffectType.UnderAutoZhaoPierceQiDamageRateReduction] = require("app.FightSystem.FightBuff.Effect.UnderAutoZhaoPierceQiDamgeRateReductionEffect"),
	[Constants.EffectType.SpecialAttrValueFix] = require("app.FightSystem.FightBuff.Effect.SpecialAttrValueFixEffect"),
	[Constants.EffectType.RealDamage] = require("app.FightSystem.FightBuff.Effect.RealDamageEffect"),
	[Constants.EffectType.UnmountWeapon] = require("app.FightSystem.FightBuff.Effect.UnmountWeaponEffect"),
	[Constants.EffectType.DisableFunction] = require("app.FightSystem.FightBuff.Effect.DisableFunctionEffect"),
	[Constants.EffectType.ChangeWeapon] = require("app.FightSystem.FightBuff.Effect.ChangeWeaponEffect"),
	[Constants.EffectType.ExtraAutoSkillBuffAdder] = require("app.FightSystem.FightBuff.Effect.ExtraAutoZhaoBuffAdderEffect"),
	[Constants.EffectType.AutoSkillDodge] = require("app.FightSystem.FightBuff.Effect.AutoSkillDodgeEffect"),
	[Constants.EffectType.AutoSkillParry] = require("app.FightSystem.FightBuff.Effect.AutoSkillParryEffect"),
	default = require("app.FightSystem.FightBuff.ActiveEffect")
}

function EffectFactory:create(effect, buffNeeded)
	return switch(effect:getEffectType(), effectCreateSwitch):create(effect, buffNeeded)
end

return EffectFactory
00