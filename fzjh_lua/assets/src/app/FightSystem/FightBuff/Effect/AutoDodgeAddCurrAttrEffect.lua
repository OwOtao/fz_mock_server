local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local BuffSystemUtil = require("app.FightSystem.FightBuff.BuffSystemUtil")

local AutoDodgeAddCurrAttrEffect = {}

function AutoDodgeAddCurrAttrEffect:create(effect, buffNeeded)
    local p = AutoDodgeAddCurrAttrEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function AutoDodgeAddCurrAttrEffect:ctor()
end

function AutoDodgeAddCurrAttrEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function AutoDodgeAddCurrAttrEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    self.__target = self.__effect:getArgsParam()[1]
    self.__damageId = self.__effect:getArgsParam()[2]
    self.__percent = self.__effect:getArgsParam()[3]
    self.__attrName = self.__effect:getEffectTypeParam()[1]

    BuffSystemUtil:log("自动招架增加当前属性：", self.__target, self.__damageId, self.__percent, self.__attrName)
end

function AutoDodgeAddCurrAttrEffect:getEffectType()
    return self.__effect:getEffectType()
end

function AutoDodgeAddCurrAttrEffect:getAutoDodgeAttrEffect()
    return true, self.__target, self.__attrName, self.__effect:getDamage(self.__damageId, self.__buffNeeded), self.__percent
end

return class("AutoDodgeAddCurrAttrEffect", {ActiveEffect}, AutoDodgeAddCurrAttrEffect)
000000