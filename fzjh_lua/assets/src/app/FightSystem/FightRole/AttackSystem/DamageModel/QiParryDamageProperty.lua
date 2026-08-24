local newClass = require("third.class.NewClass")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local QiHitDamageProperty = require("app.FightSystem.FightRole.AttackSystem.DamageModel.QiHitDamageProperty")

--@SuperType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.DamageProperty#ADamageProperty]
local QiParryDamageProperty = {
    __reductionPercentValue = 0,
    __reductionConstValue = 0,
    __reductionPercentByEffectArray = {},
    __reductionConstValueByEffectArray = {},
    __effectRedutionActualValueList = {}
}

function QiParryDamageProperty:create()
    return QiParryDamageProperty.new()
end

function QiParryDamageProperty:__initNormalDamageValue()
    local parrySuccessQiHurtScaleCorrectionFactor = BattleConstConf:get("parrySuccessQiHurtScaleCorrectionFactor")

    self.__normalDamageValue = self:getHitNormalDamageValue() * (1 - parrySuccessQiHurtScaleCorrectionFactor)
end

return newClass("QiParryDamageProperty", {QiHitDamageProperty}, QiParryDamageProperty)
0000000000000000