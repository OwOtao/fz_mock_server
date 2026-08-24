local EffectCheckConst = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckConst")
local EffectCheckFactory = {}

function EffectCheckFactory:create(effect)
    local effectMap = EffectCheckConst.EffectType
    local effectType = effect:getType()

    if effectMap[effectType] and effectMap[effectType] ~= -1 then
        return require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheck"..effectMap[effectType]):create(effect)
    end
end

return EffectCheckFactory0000