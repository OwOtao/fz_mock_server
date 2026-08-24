local newClass = require("third.class.NewClass")

local HiddenMeridianResources = require("app.models.Meridian.HiddenMeridianResources.HiddenMeridianResources")

local Skill = require("app.models.skill.Skill")

local HiddenMeridianActiveEffect = {}

function HiddenMeridianActiveEffect:create(effectData)
    local p = HiddenMeridianActiveEffect:new()
    p:__init(effectData)
    return p
end

function HiddenMeridianActiveEffect:ctor()
end

function HiddenMeridianActiveEffect:__init(effectData)
    assert(effectData[1] == "activeEffect","HiddenMeridianActiveEffect:__init effectData[1] must be activeEffect")
    
    assert(effectData[2],"HiddenMeridianActiveEffect:__init effectData[2] is nil") 

    assert(type(effectData[3]) == "number","HiddenMeridianActiveEffect:__init effectData[3] must be number")

    assert(type(effectData[4]) == "number","HiddenMeridianActiveEffect:__init effectData[4] must be number")

    assert(type(effectData[5]) == "number","HiddenMeridianActiveEffect:__init effectData[5] must be number")
    
    self.__type = effectData[1]
    
    local effectId = effectData[2]
    
    local effect = Skill:getSkillEffect(effectId):clone()

    local zArgs = {
        effectData[3],
        effectData[4],
        effectData[5],
    }

    effect:setZArgs(zArgs)

    self.__activeEffect = effect
end

function HiddenMeridianActiveEffect:getActiveEffect()
    return self.__activeEffect
end

return newClass("HiddenMeridianActiveEffect", {}, HiddenMeridianActiveEffect)
000000000000000