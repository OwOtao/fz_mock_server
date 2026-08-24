local newClass = require("third.class.NewClass")

local EffectChangeAttrByQiHitDamage = {
    __actualValue = 0,
    __qiProjectedValue = 0
}

function EffectChangeAttrByQiHitDamage:create()
    return EffectChangeAttrByQiHitDamage.new()
end

function EffectChangeAttrByQiHitDamage:setEffectFuncId(effectId)
    self.__effectId = effectId
end

function EffectChangeAttrByQiHitDamage:getEffectId()
    return self.__effectId
end

function EffectChangeAttrByQiHitDamage:setOwnerId(id)
    self.__ownerId = id
end

function EffectChangeAttrByQiHitDamage:getOwnerId()
    return self.__ownerId
end

function EffectChangeAttrByQiHitDamage:setTargetId(id)
    self.__targetId = id
end

function EffectChangeAttrByQiHitDamage:getTargetId()
    return self.__targetId
end

function EffectChangeAttrByQiHitDamage:setQiDamageProjectedValue(value)
    self.__qiProjectedValue = value
end

function EffectChangeAttrByQiHitDamage:setPercent(percent)
    self.__percent = percent
end

function EffectChangeAttrByQiHitDamage:setChangeAttrName(attrName)
    self.__attrName = attrName
end

function EffectChangeAttrByQiHitDamage:getAttrName()
    return self.__attrName
end

function EffectChangeAttrByQiHitDamage:getActualValue()
    return self.__actualValue
end

function EffectChangeAttrByQiHitDamage:calActualValue()
    self.__actualValue = Helper:mathFloor(self.__qiProjectedValue * self.__percent)
end

return newClass("EffectChangeAttrByQiHitDamage", {}, EffectChangeAttrByQiHitDamage)
0000000000000