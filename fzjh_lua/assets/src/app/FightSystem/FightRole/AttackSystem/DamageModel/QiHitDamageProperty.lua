local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local DamageProperty = require("app.FightSystem.FightRole.AttackSystem.DamageModel.DamageProperty")

--@SuperType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.DamageProperty#ADamageProperty]
local QiHitDamageProperty = {
    __attrName = "qi",
    __canBeAbsorb = true,
    __beAbsorbValue = 0,
    __reduces = {},
    __effectRedutionActualValueList = {}
}

function QiHitDamageProperty:create()
    return QiHitDamageProperty.new()
end

function QiHitDamageProperty:setQiDamageShield(shield)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiDamageShield#QiDamageShield]
    self.__damageShield = shield
end

function QiHitDamageProperty:getBeAbsorbValueByShield()
    return self.__beAbsorbValue
end

--@desc: 甲等免伤
--@author:Seven
--@time:2022-01-11 18:07:49
function QiHitDamageProperty:setReduceLv1(reduce)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiReduce#QiReduce]
    self.__reduceLv1 = reduce

    table.insert(self.__reduces, reduce)
end

--@desc: 乙等免伤
function QiHitDamageProperty:setReduceLv2(reduce)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiReduce#QiReduce]
    self.__reduceLv2 = reduce
    table.insert(self.__reduces, reduce)
end

--@desc: 丙等免伤
function QiHitDamageProperty:setReduceLv3(reduce)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiReduce#QiReduce]
    self.__reduceLv3 = reduce
    table.insert(self.__reduces, reduce)
end

function QiHitDamageProperty:getReduces()
    return self.__reduces
end

--@desc: 是否可被护盾吸收
--@author:Seven
--@time:2022-01-08 15:26:23
function QiHitDamageProperty:setCanBeAbsorbByShield(bool)
    if type(bool) ~= "boolean" then
        error("QiHitDamageProperty:setCanBeAbsorbByShield 参数类型非bool值 :" .. tostring(bool))
    end

    self.__canBeAbsorb = bool
end

function QiHitDamageProperty:getEffectRedutionActualValueList()
    return self.__effectRedutionActualValueList
end

function QiHitDamageProperty:__calReduceLv1()
    self.__reduceLv1:setAllocPercent(self.__allocPercent)
    self.__reduceLv1:setQiDamageValue(self.__normalDamageValue)
end

function QiHitDamageProperty:__calReduceLv2()
    self.__reduceLv2:setAllocPercent(self.__allocPercent)
    self.__reduceLv2:setQiDamageValue(self.__reduceLv1:getQiDamageConst())
end

function QiHitDamageProperty:__calReduceLv3()
    self.__reduceLv3:setAllocPercent(self.__allocPercent)
    self.__reduceLv3:setQiDamageValue(self.__reduceLv2:getQiDamageConst())
end

--@desc: 初始化单次命中结果伤害值
--@author:Seven
--@time:2023-09-27 11:20:26
function QiHitDamageProperty:__initHitNormalDamageValue()
    self.__hitNormalDamageValue = self.__projectedValue * self.__allocPercent
end

function QiHitDamageProperty:getHitNormalDamageValue()
    return self.__hitNormalDamageValue
end

--@desc: 普通单次伤害
--@author:Seven
--@time:2023-09-27 11:20:55
function QiHitDamageProperty:__initNormalDamageValue()
    self.__normalDamageValue = self.__hitNormalDamageValue
end

function QiHitDamageProperty:calActualValue()
    self:__initAllocPercent()

    self:__initHitNormalDamageValue()

    self:__initNormalDamageValue()

    self:__calReduceLv1()

    self:__calReduceLv2()

    self:__calReduceLv3()

    FightUtil:printLog("甲等免伤计算：")
    self.__reduceLv1:printString()
    FightUtil:printLog("乙等免伤计算：")
    self.__reduceLv2:printString()
    FightUtil:printLog("丙等免伤计算：")
    self.__reduceLv3:printString()

    local calValue = Helper:mathFloor(self.__reduceLv3:getQiDamageConst())

    local remainingShieldValue

    if self.__canBeAbsorb then
        remainingShieldValue = self.__damageShield:getRemaining()
    else
        remainingShieldValue = 0
    end

    self.__actualValue = math.max(calValue - remainingShieldValue, 0)

    self.__beAbsorbValue = math.abs(self.__actualValue - calValue)

    self.__damageShield:absorbDamage(self.__beAbsorbValue)
end

return newClass("QiHitDamageProperty", {DamageProperty}, QiHitDamageProperty)
000000