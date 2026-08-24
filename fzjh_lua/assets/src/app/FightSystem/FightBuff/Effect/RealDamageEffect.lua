local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")

local RealDamageEffect = {}

function RealDamageEffect:create(effect, buffNeeded)
    local p = RealDamageEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function RealDamageEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function RealDamageEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded
end

return class("RealDamageEffect", {ActiveEffect}, RealDamageEffect)
00000