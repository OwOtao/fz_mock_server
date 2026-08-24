local interface = require("third.class.interface")

local IUnderHitVisitor = {}

function IUnderHitVisitor:visitZhaoDamagePopText(damageProperty)
end

function IUnderHitVisitor:visitAttackerEffectDamagePopText(effectChangeAttrByQiHitDamage)
end

function IUnderHitVisitor:visitTargetEffectDamagePopText(effectChangeAttrByQiHitDamage)
end

return interface("IUnderHitVisitor", IUnderHitVisitor)
00000000