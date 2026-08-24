--[[
    author:Seven
    time:2023-12-08 15:49:27
    desc:
]]
local abstract = require("third.class.abstract")

local ICharacterOperation = require("app.FightSystem.FightRole.CharacterOperation.ICharacterOperation")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.FightRole.CharacterOperation.ICharacterOperation#ICharacterOperation]
local ACharacterOperation = {
    --@desc 当前CD时间
    __cd = 0,
    __disable = false
}

function ACharacterOperation:setCharacterOperationType(characterOperationType)
    if not table.keyof(FightCommons.CHARACTER_OPERATION_TYPE, characterOperationType) then
        error("ACharacterOperation:setCharacterOperationType 角色操作类型未定义 ： " .. tostring(characterOperationType))
    end

    self.__type = characterOperationType
end

function ACharacterOperation:getCharacterOperationType()
    return self.__type
end

function ACharacterOperation:setOperationOwenr(owner)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__owner = owner
end

function ACharacterOperation:getOwner()
    return self.__owner
end

function ACharacterOperation:setOperationId(id)
    self.__id = id
end

function ACharacterOperation:getOperationId()
    return self.__id
end

function ACharacterOperation:setOperationName(name)
    self.__name = name
end

function ACharacterOperation:getOperationName()
    return self.__name
end

function ACharacterOperation:setDisable(bool)
    self.__disable = bool
end

function ACharacterOperation:isDisable()
    return self.__disable == false
end

function ACharacterOperation:setCd(cdValue)
    if cdValue < 0 then
        error("ACharacterOperation:setCd 参数不可小于0")
    end

    if cdValue > self:getCdMax() then
        error("ACharacterOperation:setCd 参数不可大于上限值：" .. tostring(cdValue) .. tostring(self:getCdMax()))
    end

    self.__cd = cdValue
end

function ACharacterOperation:getCd()
    return self.__cd
end

return abstract("ACharacterOperation", {ICharacterOperation}, ACharacterOperation)
000000000000