--[[
    招式伤害基础类
]]
local abstract = require("third.class.abstract")

local IDamageProperty = {}

function IDamageProperty:calActualValue()
end

--@SuperType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.ADamageProperty#IDamageProperty]
local ADamageProperty = {
    __allocProjectedValue = 0,
    __actualValue = 0
}

function ADamageProperty:setDamageDescType(descTypeStr)
    self.__descType = descTypeStr
end

function ADamageProperty:getDamageDescType()
    return self.__descType
end

function ADamageProperty:setAttrName(attrName)
    self.__attrName = attrName
end

function ADamageProperty:getAttrName()
    return self.__attrName
end

function ADamageProperty:setProjectedValue(value)
    self.__projectedValue = value
end

function ADamageProperty:getProjectedValue()
    return self.__projectedValue
end

function ADamageProperty:setCombTotalWeight(totalWeight)
    self.__combtTotalWeight = totalWeight
end

function ADamageProperty:setZhaoAllocWeight(allocWeight)
    self.__zhaoAllocWeight = allocWeight
end

function ADamageProperty:setAnimHurtTotalWeight(totalWeight)
    self.__animHurtTotalWeight = totalWeight
end

function ADamageProperty:setAnimHitAllocWeight(allocWeight)
    self.__animAllocWeight = allocWeight
end

function ADamageProperty:getAllocProjectedValue()
    return self.__allocProjectedValue
end

function ADamageProperty:getActualValue()
    return self.__actualValue
end

return abstract("ADamageProperty", {IDamageProperty}, ADamageProperty)
0000000000000