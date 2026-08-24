local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local Constants = require("app.FightSystem.FightBuff.Constants")

local AutoSkillDodgeEffect = {}

function AutoSkillDodgeEffect:create(effect, buffNeeded)
	local p = AutoSkillDodgeEffect.new()
	p:__init(effect, buffNeeded)
	return p
end

function AutoSkillDodgeEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function AutoSkillDodgeEffect:__init(effect, buffNeeded)
	self.__effect = effect
	self.__buffNeeded = buffNeeded
end

return class("AutoSkillDodgeEffect", {ActiveEffect}, AutoSkillDodgeEffect)
000000