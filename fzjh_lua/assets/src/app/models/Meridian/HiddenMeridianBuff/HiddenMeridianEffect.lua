local newClass = require("third.class.NewClass")

local HiddenMeridianResources = require("app.models.Meridian.HiddenMeridianResources.HiddenMeridianResources")

local HiddenMeridianEffect = {}

function HiddenMeridianEffect:create(effectData)
    local p = HiddenMeridianEffect:new()
    p:__init(effectData)
    return p
end

function HiddenMeridianEffect:ctor()
end

function HiddenMeridianEffect:__init(effectData)
    assert(effectData[1] == "damageAttr","HiddenMeridianEffect:__init effectData[1] must be damageAttr")

    assert(effectData[2] == "atkDamageClass" or "defDamageClass","HiddenMeridianEffect:__init effectData[2] must be atkDamageClass or defDamageClass")

    assert(effectData[3],"HiddenMeridianEffect:__init effectData[3] is nil") 

    assert(type(effectData[4]) == "number","HiddenMeridianEffect:__init effectData[4] must be number")

    self.__type = "damageAttr"

    self.__damageType = effectData[2]
    
    self.__damageId = effectData[3]

    self.__value = effectData[4]
end

function HiddenMeridianEffect:getDamageId()
    return self.__damageId
end

function HiddenMeridianEffect:getDamageType()
    return self.__damageType
end

function HiddenMeridianEffect:getDamageName()
    return HiddenMeridianResources:getDamageAttrName(self.__damageType,self.__damageId)
end

function HiddenMeridianEffect:getValue()
    return self.__value
end

return newClass("HiddenMeridianEffect", {}, HiddenMeridianEffect)
0000000000000