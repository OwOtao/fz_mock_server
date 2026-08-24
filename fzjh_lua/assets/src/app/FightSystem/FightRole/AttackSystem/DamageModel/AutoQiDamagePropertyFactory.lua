local newClass = require("third.class.NewClass")

local QiReduce = require("app.FightSystem.FightRole.AttackSystem.DamageModel.QiReduce")

local AutoQiDamagePropertyFactory = {
    --@desc 甲等配置
    __reduceIdConfLv1 = {
        setReduceRateIdLv1 = 100,
        setReduceRateIdLv2 = 101,
        setReduceRateIdLv3 = 102,
        setReduceValueIdLv1 = 109,
        setReduceValueIdLv2 = 110,
        setReduceValueIdLv3 = 111,
        setReduceBreakId = 300
    },
    --@desc 乙等配置
    __reduceIdConfLv2 = {
        setReduceRateIdLv1 = 103,
        setReduceRateIdLv2 = 104,
        setReduceRateIdLv3 = 105,
        setReduceValueIdLv1 = 112,
        setReduceValueIdLv2 = 113,
        setReduceValueIdLv3 = 114,
        setReduceBreakId = 301
    },
    --@desc 丙等配置
    __reduceIdConfLv3 = {
        setReduceRateIdLv1 = 106,
        setReduceRateIdLv2 = 107,
        setReduceRateIdLv3 = 108,
        setReduceValueIdLv1 = 115,
        setReduceValueIdLv2 = 116,
        setReduceValueIdLv3 = 117,
        setReduceBreakId = 302
    }
}

function AutoQiDamagePropertyFactory:create()
    return AutoQiDamagePropertyFactory.new()
end

function AutoQiDamagePropertyFactory:setDamagePropertyClass(class)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiHitDamageProperty#QiHitDamageProperty]
    self.__propertyClass = class
end

function AutoQiDamagePropertyFactory:setQiShield(qiShield)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiDamageShield#QiDamageShield]
    self.__damageShield = qiShield
end

function AutoQiDamagePropertyFactory:setReduceEffectMap(effectMap)
    self.__reduceEffectMap = effectMap
end

function AutoQiDamagePropertyFactory:setDamageDescType(damageTypeStr)
    self.__damageTypeStr = damageTypeStr
end

function AutoQiDamagePropertyFactory:setProjectedValue(value)
    self.__projectedValue = value
end

function AutoQiDamagePropertyFactory:setCombTotalWeight(value)
    self.__combTotalWeight = value
end

function AutoQiDamagePropertyFactory:setZhaoAllocWeight(value)
    self.__zhaoAllocWeight = value
end

function AutoQiDamagePropertyFactory:setAnimHitAllocWeight(value)
    self.__animHitAllocWeight = value
end

function AutoQiDamagePropertyFactory:setAnimHurtTotalWeight(value)
    self.__animHurtTotalWeight = value
end

function AutoQiDamagePropertyFactory:setCanBeAbsorbByShield(bool)
    self.__canBeAbsorb = bool
end

function AutoQiDamagePropertyFactory:__initReduce(conf)
    local reduce = QiReduce:create()

    reduce:setConfClass(require("app.FightSystem.Configuration.QiDamageReduceConf"))

    reduce:setEffectMap(self.__reduceEffectMap)

    for k, v in pairs(conf) do
        reduce[k](reduce, v)
    end

    return reduce
end

function AutoQiDamagePropertyFactory:__initReduceLv1()
    return self:__initReduce(self.__reduceIdConfLv1)
end

function AutoQiDamagePropertyFactory:__initReduceLv2()
    return self:__initReduce(self.__reduceIdConfLv2)
end

function AutoQiDamagePropertyFactory:__initReduceLv3()
    return self:__initReduce(self.__reduceIdConfLv3)
end

function AutoQiDamagePropertyFactory:getDamageProperty()
    local reduceLv1 = self:__initReduceLv1()
    local reduceLv2 = self:__initReduceLv2()
    local reduceLv3 = self:__initReduceLv3()

    --@RefType[src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiHitDamageProperty#QiHitDamageProperty]
    local damageProperty = self.__propertyClass:create()

    damageProperty:setQiDamageShield(self.__damageShield)

    damageProperty:setReduceLv1(reduceLv1)

    damageProperty:setReduceLv2(reduceLv2)

    damageProperty:setReduceLv3(reduceLv3)

    damageProperty:setDamageDescType(self.__damageTypeStr)

    damageProperty:setProjectedValue(self.__projectedValue)

    damageProperty:setCombTotalWeight(self.__combTotalWeight)

    damageProperty:setZhaoAllocWeight(self.__zhaoAllocWeight)

    damageProperty:setAnimHitAllocWeight(self.__animHitAllocWeight)

    damageProperty:setAnimHurtTotalWeight(self.__animHurtTotalWeight)

    damageProperty:setCanBeAbsorbByShield(self.__canBeAbsorb)

    damageProperty:calActualValue()

    return damageProperty
end

return newClass("AutoQiDamagePropertyFactory", {}, AutoQiDamagePropertyFactory)
00000000