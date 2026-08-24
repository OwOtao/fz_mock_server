local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local Constants = require("app.FightSystem.FightBuff.Constants")

local AutoSkillParryEffect = {}

function AutoSkillParryEffect:create(effect, buffNeeded)
	local p = AutoSkillParryEffect.new()
	p:__init(effect, buffNeeded)
	return p
end

function AutoSkillParryEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function AutoSkillParryEffect:__init(effect, buffNeeded)
	self.__effect = effect
	self.__buffNeeded = buffNeeded
end

return class("AutoSkillParryEffect", {ActiveEffect}, AutoSkillParryEffect)
000000