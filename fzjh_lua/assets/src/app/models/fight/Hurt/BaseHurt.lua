local Ihurt = require("app.models.fight.Hurt.Ihurt")
local newClass = require("third.class.NewClass")

local BaseHurt = {
    __type = nil,

    __value= 0
}

function BaseHurt:create(type,value)
    local p = BaseHurt.new()
    p:init(type,value)
    return p
end

function BaseHurt:ctor()
    self.__type = nil

    self.__value = 0
end

function BaseHurt:init(type,value)
    self.__type = type

    if value then
        self.__value = value
    end
end

function BaseHurt:getType()
    return self.__type
end

function BaseHurt:getValue()
    return self.__value
end

return newClass("BaseHurt", {Ihurt}, BaseHurt)
00000000000000