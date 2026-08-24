local class = require("third.class.NewClass")
local IBuffNeeded = require("app.FightSystem.FightBuff.IBuffNeeded")

local CustomBuffNeeded = {}

--[[
    @desc: 
    author:{author}
    time:2021-07-06 14:49:07
    @return: src.app.FightSystem.FightBuff.CustomBuffNeeded#CustomBuffNeeded
]]
function CustomBuffNeeded:create()
    local p = CustomBuffNeeded.new()
    return p
end

function CustomBuffNeeded:ctor()
    self.__hurtValueCache = {}
end

function CustomBuffNeeded:setAttacker(attacker)
    self.__attacker = attacker
end

function CustomBuffNeeded:getAttacker()
    return self.__attacker
end

function CustomBuffNeeded:setSelfWeaponType(selfWeaponType)
    self.__selfWeaponType = selfWeaponType
end

function CustomBuffNeeded:getSelfWeaponType()
    return self.__selfWeaponType
end

function CustomBuffNeeded:setTargetWeaponType(targetWeaponType)
    self.__targetWeaponType = targetWeaponType
end

function CustomBuffNeeded:getTargetWeaponType()
    return self.__targetWeaponType
end

function CustomBuffNeeded:setSelfWeaponAttrGetter(func)
    self.__selfWeaponAttrGetter = func
end

function CustomBuffNeeded:getSelfWeaponAttr(attrName)
    return self.__selfWeaponAttrGetter(attrName)
end

function CustomBuffNeeded:setTargetWeaponAttrGetter(func)
    self.__targetWeaponAttrGetter = func
end

function CustomBuffNeeded:getTargetWeaponAttr(attrName)
    return self.__targetWeaponAttrGetter(attrName)
end

function CustomBuffNeeded:setAutoAvgAtk(autoAvgAtk)
    self.__autoAvgAtk = autoAvgAtk
end

function CustomBuffNeeded:getAutoAvgAtk()
    return self.__autoAvgAtk
end

function CustomBuffNeeded:setDynamicArg1(dynamicArg1)
    self.__dynamicArg1 = dynamicArg1
end

function CustomBuffNeeded:getDynamicArg1()
    return self.__dynamicArg1
end

function CustomBuffNeeded:setDynamicArg2(dynamicArg2)
    self.__dynamicArg2 = dynamicArg2
end

function CustomBuffNeeded:getDynamicArg2()
    return self.__dynamicArg2
end

local Trie = require("third.tree.Trie")
local paramTrie = Trie:create()
paramTrie:add("-")

function CustomBuffNeeded:getDynamicArg(dynamicArgName)
    local retValue = dynamicArgName

    local array = paramTrie:partitionToArray(dynamicArgName)
    local isPositive = 1

    if #array == 2 then
        if array[1] == "-" then
            isPositive = -1
        end
        dynamicArgName = array[2]
    end

    if dynamicArgName == "dynamicArg1" then
        retValue = tonumber(self:getDynamicArg1()) * isPositive
    elseif dynamicArgName == "dynamicArg2" then
        retValue = tonumber(self:getDynamicArg2()) * isPositive
    elseif dynamicArgName == "dynamicArg3" then
        retValue = tonumber(self:getDynamicArg3()) * isPositive
    else
        retValue = tonumber(dynamicArgName) * isPositive
    end

    return retValue
end

function CustomBuffNeeded:setDynamicArg3(dynamicArg3)
    self.__dynamicArg3 = dynamicArg3
end

function CustomBuffNeeded:getDynamicArg3()
    return self.__dynamicArg3
end

function CustomBuffNeeded:setGetAttrFunc(getAttrFunc)
    self.__getAttrFunc = getAttrFunc
end

function CustomBuffNeeded:getAttr(attrName)
    return self.__getAttrFunc(attrName)
end

function CustomBuffNeeded:setGetTargetAttrFunc(getTargetAttrFunc)
    self.__getTargetAttrFunc = getTargetAttrFunc
end

function CustomBuffNeeded:getTargetAttr(attrName)
    return self.__getTargetAttrFunc(attrName)
end

return class("CustomBuffNeeded", {IBuffNeeded}, CustomBuffNeeded)
00000000000000