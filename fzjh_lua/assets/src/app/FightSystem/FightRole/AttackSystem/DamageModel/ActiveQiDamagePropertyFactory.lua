local newClass = require("third.class.NewClass")

local QiReduce = require("app.FightSystem.FightRole.AttackSystem.DamageModel.QiReduce")

local AutoQiDamagePropertyFactory = require("app.FightSystem.FightRole.AttackSystem.DamageModel.AutoQiDamagePropertyFactory")

local ActiveQiDamagePropertyFactory = {
    --@desc 甲等配置
    __reduceIdConfLv1 = {
        setReduceRateIdLv1 = 200,
        setReduceRateIdLv2 = 201,
        setReduceRateIdLv3 = 202,
        setReduceValueIdLv1 = 209,
        setReduceValueIdLv2 = 210,
        setReduceValueIdLv3 = 211,
        setReduceBreakId = 400
    },
    --@desc 乙等配置
    __reduceIdConfLv2 = {
        setReduceRateIdLv1 = 203,
        setReduceRateIdLv2 = 204,
        setReduceRateIdLv3 = 205,
        setReduceValueIdLv1 = 212,
        setReduceValueIdLv2 = 213,
        setReduceValueIdLv3 = 214,
        setReduceBreakId = 401
    },
    --@desc 丙等配置
    __reduceIdConfLv3 = {
        setReduceRateIdLv1 = 206,
        setReduceRateIdLv2 = 207,
        setReduceRateIdLv3 = 208,
        setReduceValueIdLv1 = 215,
        setReduceValueIdLv2 = 216,
        setReduceValueIdLv3 = 217,
        setReduceBreakId = 402
    }
}

function ActiveQiDamagePropertyFactory:create()
    return ActiveQiDamagePropertyFactory.new()
end

return newClass("ActiveQiDamagePropertyFactory", {AutoQiDamagePropertyFactory}, ActiveQiDamagePropertyFactory)
00000