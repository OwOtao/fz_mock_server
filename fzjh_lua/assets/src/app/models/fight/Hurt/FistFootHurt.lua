local newClass = require("third.class.NewClass")

local BaseHurt = require("app.models.fight.Hurt.BaseHurt")

local FistFootHurt = {}

function FistFootHurt:create(type,value)
    local p = FistFootHurt.new()
    p:init(type,value)
    return p
end

function FistFootHurt:ctor()
	self.__isAutoHurt = true
	
	self.__isActiveHurt = false
end

return newClass("FistFootHurt", {BaseHurt}, FistFootHurt)
00000000000000