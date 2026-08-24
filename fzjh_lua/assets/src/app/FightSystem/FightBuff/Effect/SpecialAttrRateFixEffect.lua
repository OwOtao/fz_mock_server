local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local BuffSystemUtil = require("app.FightSystem.FightBuff.BuffSystemUtil")

local SpecialAttrRateFixEffect = {}

function SpecialAttrRateFixEffect:create(effect, buffNeeded)
    local p = SpecialAttrRateFixEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function SpecialAttrRateFixEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function SpecialAttrRateFixEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    self.__attrName = self.__effect:getEffectTypeParam()[1]
    assert(type(self.__attrName) == "string", "SpecialAttrRateFixEffect:__init() the attrName is not string")

    local damageId = self.__effect:getArgsParam()[1]

    self.__fixRate = self.__effect:getDamage(damageId, self.__buffNeeded)

    BuffSystemUtil:log("特殊属性百分比修正：", self.__attrName, self.__fixRate)
end

function SpecialAttrRateFixEffect:getFixRate()
    return self.__attrName, self.__fixRate
end

return class("SpecialAttrRateFixEffect", {ActiveEffect}, SpecialAttrRateFixEffect)
00000000000000