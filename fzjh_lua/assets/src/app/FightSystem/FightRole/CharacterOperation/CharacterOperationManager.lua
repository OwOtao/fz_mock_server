--[[
    author:Seven
    time:2023-12-08 11:07:22
    desc:玩家操作管理类
]]
local newClass = require("third.class.NewClass")

local isImpl = require("third.assertIsInstance.assertIsInstance")

local FightCommons = require("app.FightSystem.FightCommons")

local IOperationManager = require("app.FightSystem.FightRole.CharacterOperation.IOperationManager")

--@SuperType [src.app.FightSystem.FightRole.CharacterOperation.IOperationManager#IOperationManager]
local CharacterOperationManager = {}

function CharacterOperationManager:create(character)
    local p = CharacterOperationManager:new()
    p:__init(character)
    return p
end

function CharacterOperationManager:__init(character)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = assert(character, "CharacterOperationManager:__init(character) - character is nil")
    self.__operations = {}
end

--@desc: 注册玩家操作
--@author:Seven
--@time:2023-12-08 11:37:26
--@index: 注册插槽位置 number
--@operation: [src.app.FightSystem.FightRole.CharacterOperation.ICharacterOperation#ICharacterOperation]
function CharacterOperationManager:registerOperation(index, characterOperation)
    self:__checkIndex(index)

    if self.__operations[tostring(index)] ~= nil then
        self:unregisterOperation(index)
    end

    self.__operations[tostring(index)] = isImpl(characterOperation, require("app.FightSystem.FightRole.CharacterOperation.ICharacterOperation"))
end

--@desc: 删除玩家操作
--@author:Seven
--@time:2023-12-08 11:19:33
--@index: 取消注册位置
--@return [src.app.FightSystem.FightRole.CharacterOperation.ICharacterOperation#ICharacterOperation]
function CharacterOperationManager:unregisterOperation(index)
    self:__checkIndex(index)
    local operation = self.__operations[tostring(index)]

    if operation == nil then
        return nil
    end

    self.__operations[tostring(index)] = nil

    return operation
end

--@desc: 获取操作插槽位置操作对象
--@author:Seven
--@time:2023-12-08 11:41:56
--@index: 操作插槽索引
--@return [src.app.FightSystem.FightRole.CharacterOperation.ICharacterOperation#ICharacterOperation]
function CharacterOperationManager:getOperation(index)
    self:__checkIndex(index)
    return self.__operations[tostring(index)]
end

--@desc 检测插槽索引合法性
--@index: index 插槽索引
function CharacterOperationManager:__checkIndex(index)
    if index < 1 or index > FightCommons.CHARACTER_OPERATION_MAX_INDEX then
        error(string.format("CharacterOperationManager:__checkIndex(index) - invalid index %s", tostring(index)))
    end
end

function CharacterOperationManager:getOperationById(operationId)
    for _, operation in pairs(self.__operations) do
        if operation:getOperationId() == operationId then
            return operation
        end
    end

    return nil
end

return newClass("CharacterOperationManager", {IOperationManager}, CharacterOperationManager)
0000000000