local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local BuffSystemUtil = require("app.FightSystem.FightBuff.BuffSystemUtil")

local SpecialAttrValueFixEffect = {}

function SpecialAttrValueFixEffect:create(effect, buffNeeded)
    local p = SpecialAttrValueFixEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function SpecialAttrValueFixEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function SpecialAttrValueFixEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    self.__attrName = self.__effect:getEffectTypeParam()[1]
    assert(type(self.__attrName) == "string", "SpecialAttrValueFixEffect:__init() the attrName is not string")

    local damageId = self.__effect:getArgsParam()[1]

    self.__fixValue = self.__effect:getDamage(damageId, self.__buffNeeded)

    BuffSystemUtil:log("特殊属性值修正：", self.__attrName, self.__fixValue)
end

function SpecialAttrValueFixEffect:getFixValue()
    return self.__attrName, self.__fixValue
end

return class("SpecialAttrValueFixEffect", {ActiveEffect}, SpecialAttrValueFixEffect)
0000000