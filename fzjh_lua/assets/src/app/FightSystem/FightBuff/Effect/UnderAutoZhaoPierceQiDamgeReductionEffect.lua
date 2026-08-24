local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local BuffSystemUtil = require("app.FightSystem.FightBuff.BuffSystemUtil")

local UnderAutoZhaoPierceQiDamgeReductionEffect = {}

function UnderAutoZhaoPierceQiDamgeReductionEffect:create(effect, buffNeeded)
    local p = UnderAutoZhaoPierceQiDamgeReductionEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function UnderAutoZhaoPierceQiDamgeReductionEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function UnderAutoZhaoPierceQiDamgeReductionEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    local damageId = self.__effect:getArgsParam()[1]

    self.__reduction = self.__effect:getDamage(damageId, self.__buffNeeded)

    BuffSystemUtil:log("技能伤害百分比减免：", self.__reduction)
end

function UnderAutoZhaoPierceQiDamgeReductionEffect:getAutoZhaoQiDamageReduction()
    return self.__reduction
end

return class("UnderAutoZhaoPierceQiDamgeReductionEffect", {ActiveEffect}, UnderAutoZhaoPierceQiDamgeReductionEffect)
00000000000000