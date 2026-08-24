local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local BuffSystemUtil = require("app.FightSystem.FightBuff.BuffSystemUtil")

local AutoParryAddCurrAttrEffect = {}

function AutoParryAddCurrAttrEffect:create(effect, buffNeeded)
    local p = AutoParryAddCurrAttrEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function AutoParryAddCurrAttrEffect:ctor()
end

function AutoParryAddCurrAttrEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function AutoParryAddCurrAttrEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    self.__target = assert(self.__effect:getArgsParam()[1], "AutoParryAddCurrAttrEffect:__init() error, argsParam[1] is nil")
    self.__damageId = assert(self.__effect:getArgsParam()[2], "AutoParryAddCurrAttrEffect:__init() error, argsParam[2] is nil")
    self.__percent = assert(self.__effect:getArgsParam()[3], "AutoParryAddCurrAttrEffect:__init() error, argsParam[3] is nil")
    self.__attrName = assert(self.__effect:getEffectTypeParam()[1], "AutoParryAddCurrAttrEffect:__init() error, effectTypeParam[1] is nil")

    BuffSystemUtil:log("自动招架增加当前属性：", self.__target, self.__damageId, self.__percent, self.__attrName)
end

function AutoParryAddCurrAttrEffect:getEffectType()
    return self.__effect:getEffectType()
end

function AutoParryAddCurrAttrEffect:getAutoParryAttrEffect()
    return true, self.__target, self.__attrName, self.__effect:getDamage(self.__damageId, self.__buffNeeded), self.__percent
end

return class("AutoParryAddCurrAttrEffect", {ActiveEffect}, AutoParryAddCurrAttrEffect)
00000000