local newClass = require("third.class.NewClass")

local ZhaoAttackAttrsEffect = {
    __ownerId = nil,
    __effectFuncId = nil,
    __targetType = nil,
    __attrName = nil,
    __value = nil
}

function ZhaoAttackAttrsEffect:create()
    return ZhaoAttackAttrsEffect.new()
end

function ZhaoAttackAttrsEffect:setOwnerId(ownerId)
    self.__ownerId = ownerId
end

function ZhaoAttackAttrsEffect:getOwnerId()
    return self.__ownerId
end

function ZhaoAttackAttrsEffect:getEffectFuncId()
    return self.__effectFuncId
end

function ZhaoAttackAttrsEffect:setEffectFuncId(value)
    self.__effectFuncId = value
end

function ZhaoAttackAttrsEffect:getTargetType()
    return self.__targetType
end

function ZhaoAttackAttrsEffect:setTargetType(value)
    self.__targetType = value
end

function ZhaoAttackAttrsEffect:getAttrName()
    return self.__attrName
end

function ZhaoAttackAttrsEffect:setAttrName(value)
    self.__attrName = value
end

function ZhaoAttackAttrsEffect:getValue()
    return self.__value
end

function ZhaoAttackAttrsEffect:setValue(value)
    self.__value = value
end

return newClass("ZhaoAttackAttrsEffect", {}, ZhaoAttackAttrsEffect)
0