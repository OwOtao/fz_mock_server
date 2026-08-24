local LogSystem = require("app.models.LogSystem.LogSystem")
local SkillEffectCheckError = {}

function SkillEffectCheckError:checkError(effect)
    local EffectCheckFactory = require("app.views.layer.DebugLayer.CheckUtil.effectCheck.EffectCheckFactory")
    local checkEffect = EffectCheckFactory:create(effect)

    if checkEffect then
        local msg = checkEffect:check()

        if MapIsEmpty(msg) == false then
            LogSystem:log("武学效果检测", msg)
            return false
        end
    end

    return true
end

return SkillEffectCheckError000000