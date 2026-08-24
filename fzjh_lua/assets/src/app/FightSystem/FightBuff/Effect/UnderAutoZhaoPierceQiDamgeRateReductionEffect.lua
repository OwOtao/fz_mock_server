local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local BuffSystemUtil = require("app.FightSystem.FightBuff.BuffSystemUtil")

local UnderAutoZhaoPierceQiDamgeRateReductionEffect = {}

function UnderAutoZhaoPierceQiDamgeRateReductionEffect:create(effect, buffNeeded)
    local p = UnderAutoZhaoPierceQiDamgeRateReductionEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function UnderAutoZhaoPierceQiDamgeRateReductionEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function UnderAutoZhaoPierceQiDamgeRateReductionEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    local damageId = self.__effect:getArgsParam()[1]

    self.__reduction = self.__effect:getDamage(damageId, self.__buffNeeded)

    BuffSystemUtil:log("技能伤害减免：", self.__reduction)
end

function UnderAutoZhaoPierceQiDamgeRateReductionEffect:getAutoZhaoQiDamageReduction()
    return self.__reduction
end

return class("UnderAutoZhaoPierceQiDamgeRateReductionEffect", {ActiveEffect}, UnderAutoZhaoPierceQiDamgeRateReductionEffect)
0000000