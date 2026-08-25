local newClass = require("third.class.NewClass")

local BaseHurt = require("app.models.fight.Hurt.BaseHurt")

local PoisonHurt = {}

function PoisonHurt:create(type,value)
    local p = PoisonHurt.new()
    p:init(type,value)
    return p
end

function PoisonHurt:ctor()
	self.__isAutoHurt = true
	
	self.__isActiveHurt = false
end

return newClass("PoisonHurt", {BaseHurt}, PoisonHurt)
0000000000