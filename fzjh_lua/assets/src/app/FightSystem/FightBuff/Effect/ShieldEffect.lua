local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local BuffSystemUtil = require("app.FightSystem.FightBuff.BuffSystemUtil")

local ShieldEffect = {}

function ShieldEffect:create(effect, buffNeeded)
    local p = ShieldEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function ShieldEffect:ctor()
    self.__shieldValue = 1
end

function ShieldEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function ShieldEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    local damageId = self.__effect:getArgsParam()[1]

    -- 护盾测试值
    self.__shieldValue = self.__effect:getDamage(damageId, self.__buffNeeded)

    BuffSystemUtil:log("护盾值：", self.__shieldValue)
end

function ShieldEffect:getShieldValue()
    return self.__shieldValue
end

function ShieldEffect:comsumeShieldValue(value)
    self.__shieldValue = self.__shieldValue - value
end

function ShieldEffect:getEffect()
    return self.__effect
end

function ShieldEffect:getShieldAnimIdAndPriority()
    return self.__effect:getRoleShieldAnimIdAndPriority()
end

return class("ShieldEffect", {ActiveEffect}, ShieldEffect)
0000000000000000