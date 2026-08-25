local newClass = require("third.class.NewClass")

local BaseHurt = require("app.models.fight.Hurt.BaseHurt")

local ActiveHurt = {}

function ActiveHurt:create(type,value)
    local p = ActiveHurt.new()
    p:init(type,value)
    return p
end

function ActiveHurt:ctor()
	self.__isAutoHurt = false
	
	self.__isActiveHurt = true
end

return newClass("ActiveHurt", {BaseHurt}, ActiveHurt)
0000000000