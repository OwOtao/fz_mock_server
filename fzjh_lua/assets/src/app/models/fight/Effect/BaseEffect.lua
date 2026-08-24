local newClass = require("third.class.NewClass")

local BaseEffect = {
    __id = nil,
    __fightRole = nil
}

function BaseEffect:create(effect)
    local p = BaseEffect.new()
    p:init(effect)
    return p
end

function BaseEffect:ctor()
    self.__id = nil

    self.__fightRole = nil
end

function BaseEffect:init(effect)
end

function BaseEffect:setPlayer(fightRole)
    self.__fightRole = fightRole
end

function BaseEffect:getPlayer()
    return self.__fightRole
end

function BaseEffect:setId(id)
    self.__id = id
end

function BaseEffect:getId()
    return self.__id
end

function BaseEffect:isTakeEffect()
    return true
end

return newClass("BaseEffect", {}, BaseEffect)
000000