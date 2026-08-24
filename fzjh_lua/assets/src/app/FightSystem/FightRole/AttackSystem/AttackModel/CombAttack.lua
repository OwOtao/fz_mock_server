--[[
    攻击中武学组合和武学招式相关信息
]]
local newClass = require("third.class.NewClass")

local CombAttack = {
    __id = "temp",
    __combTotalWeight = 0,
    __zhaoAllocWeight = 0,
    __animHurtTimeWeightArray = {},
    __projectedDamages = {}
}

function CombAttack:create()
    return CombAttack.new()
end

function CombAttack:setId(id)
    self.__id = id
end

function CombAttack:getId()
    return self.__id
end

function CombAttack:setCombProjectedDamages(damages)
    self.__projectedDamages = damages
end

function CombAttack:getCombProjectedDamages()
    return self.__projectedDamages
end

function CombAttack:setCombTotalWeight(value)
    self.__combTotalWeight = value
end

function CombAttack:getCombTotalWeight()
    return self.__combTotalWeight
end

function CombAttack:setZhaoAllocWeight(value)
    self.__zhaoAllocWeight = value
end

function CombAttack:getZhaoAllocWeight()
    return self.__zhaoAllocWeight
end

function CombAttack:setAnimHurtWeightArray(weightArray)
    self.__animHurtTimeWeightArray = weightArray
end

function CombAttack:getAnimHurtWeightArray()
    return self.__animHurtTimeWeightArray
end

function CombAttack:getAnimHurtAllocWeight(index)
    return self.__animHurtTimeWeightArray[index]
end

function CombAttack:getAnimHurtTotalWeight()
    local weight = 0

    for _, v in ipairs(self.__animHurtTimeWeightArray) do
        weight = weight + v
    end

    return weight
end

function CombAttack:setAnimHurtTimes(count)
    self.__animHurtTimes = count
end

function CombAttack:getAnimHurtTimes()
    return self.__animHurtTimes
end

return newClass("CombAttack", {}, CombAttack)
0000000000000