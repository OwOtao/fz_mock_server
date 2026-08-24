local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local Constants = require("app.FightSystem.FightBuff.Constants")

local ExtraAutoZhaoBuffAdderEffect = {}

function ExtraAutoZhaoBuffAdderEffect:create(effect, buffNeeded)
	local p = ExtraAutoZhaoBuffAdderEffect.new()
	p:__init(effect, buffNeeded)
	return p
end

function ExtraAutoZhaoBuffAdderEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function ExtraAutoZhaoBuffAdderEffect:__init(effect, buffNeeded)
	self.__effect = effect
	self.__buffNeeded = buffNeeded

	self.__buffAdderId = self:getEffectTypeParam(1)

	self.__buffAddParams = self:getArgsParams()
end

function ExtraAutoZhaoBuffAdderEffect:getBuffAdderId()
	return self.__buffAdderId
end

function ExtraAutoZhaoBuffAdderEffect:getBuffAddParams()
	return self.__buffAddParams
end

return class("ExtraAutoZhaoBuffAdderEffect", {ActiveEffect}, ExtraAutoZhaoBuffAdderEffect)
0000000000000000