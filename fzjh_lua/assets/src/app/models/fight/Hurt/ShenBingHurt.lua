local newClass = require("third.class.NewClass")

local BaseHurt = require("app.models.fight.Hurt.BaseHurt")

local ShenBingHurt = {}

function ShenBingHurt:create(type,value)
    local p = ShenBingHurt.new()
    p:init(type,value)
    return p
end

function ShenBingHurt:ctor()
	self.__isAutoHurt = true
	
	self.__isActiveHurt = false
end

return newClass("ShenBingHurt", {BaseHurt}, ShenBingHurt)
00000000000000