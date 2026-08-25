local newClass = require("third.class.NewClass")

local BaseHurt = require("app.models.fight.Hurt.BaseHurt")

local AutoZhaoAddEffectHurt = {}

function AutoZhaoAddEffectHurt:create(type,value)
    local p = AutoZhaoAddEffectHurt.new()
    p:init(type,value)
    return p
end

function AutoZhaoAddEffectHurt:ctor()
	self.__isAutoHurt = true
	
	self.__isActiveHurt = false
end

return newClass("AutoZhaoAddEffectHurt", {BaseHurt}, AutoZhaoAddEffectHurt)
00000000