local newClass = require("third.class.NewClass")

local BaseHurt = require("app.models.fight.Hurt.BaseHurt")

local SelfHurt = {}

function SelfHurt:create(type,value)
    local p = SelfHurt.new()
    p:init(type,value)
    return p
end

function SelfHurt:ctor()
	self.__isAutoHurt = false
	
	self.__isActiveHurt = false
end

return newClass("SelfHurt", {BaseHurt}, SelfHurt)
00000