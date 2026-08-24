local class = require("third.class.NewClass")
local AttrsEffect = {}

function AttrsEffect:create()
    local p = AttrsEffect.new()
    return p
end

function AttrsEffect:ctor()
    self.__addAttrs = {}
    self.__mulAttrs = {}
end

function AttrsEffect:setTarget(target)
    self.__target = target
end

function AttrsEffect:getTarget()
    return self.__target
end

function AttrsEffect:setAddAttrs(addAttrs)
    self.__addAttrs = addAttrs
end

function AttrsEffect:getAddAttrs()
    return self.__addAttrs
end

function AttrsEffect:setMulAttrs(mulAttrs)
    self.__mulAttrs = mulAttrs
end

function AttrsEffect:getMulAttrs()
    return self.__mulAttrs
end

function AttrsEffect:merge(attrsEffect)
    table.addToLeft(self.__addAttrs, attrsEffect:getAddAttrs())
    table.addToLeft(self.__mulAttrs, attrsEffect:getMulAttrs())
end

return class("AttrsEffect", {}, AttrsEffect)
00000000