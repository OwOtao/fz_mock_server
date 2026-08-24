local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")

local DisableFunctionEffect = {}

function DisableFunctionEffect:create(effect, buffNeeded)
    local p = DisableFunctionEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function DisableFunctionEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function DisableFunctionEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    self.__disableFunctionArray = self.__effect:getEffectTypeParam()
end

function DisableFunctionEffect:getDisableFunctionArray()
    return self.__disableFunctionArray
end

return class("DisableFunctionEffect", {ActiveEffect}, DisableFunctionEffect)
0