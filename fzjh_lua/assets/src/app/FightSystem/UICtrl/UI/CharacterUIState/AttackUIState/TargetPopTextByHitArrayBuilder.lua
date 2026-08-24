local newClass = require("third.class.NewClass")

local PopTextByHitArrayBuilder = require("app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.PopTextByHitArrayBuilder")

local PopTextVm = require("app.FightSystem.UICtrl.UIModel.PopTextVm")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local TargetPopTextByHitArrayBuilder = {}

function TargetPopTextByHitArrayBuilder:create()
    return TargetPopTextByHitArrayBuilder.new()
end

function TargetPopTextByHitArrayBuilder:__initEffectAttrsByQiDamagePopText()
    if #self.__effectAttrsByQiDamageArray <= 0 then
        return
    end

    if #self.__effectAttrsByQiDamageArray > 0 then
        for i = 1, #self.__effectAttrsByQiDamageArray do
            local effectAttrInfo = self.__effectAttrsByQiDamageArray[i]

            local effectFuncId = effectAttrInfo.effectFuncId
            
            local value = effectAttrInfo.value

            local effect = BuffConf:getEffect(tostring(effectFuncId))

            local popPrefix = effect:getActiveEffectHurtRolePop()

            --@RefType[src.app.FightSystem.UICtrl.UIModel.PopTextVm#PopTextVm]
            local popVm = PopTextVm:create()

            if popPrefix ~= nil then
                popVm:setPrefix(popPrefix)

                popVm:setValueString(tostring(value))

                table.insert(self.__popTextArray, popVm)
            end
        end
    end
end

return newClass("TargetPopTextByHitArrayBuilder",{PopTextByHitArrayBuilder},TargetPopTextByHitArrayBuilder)00