--[[
    author:Seven
    time:2023-12-18 21:04:36
    desc:
]]
local abstract = require("third.class.abstract")

local IOperationCommand = require("app.FightSystem.FightActions.OperationCommands.IOperationCommand")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
local AOperationCommand = {
    __commandParam = {}
}

function AOperationCommand:setOperationCommandId(id)
    self.__operationCommandId = id
end

function AOperationCommand:getOperationCommandId()
    return self.__operationCommandId
end

function AOperationCommand:setLogicFrame(frame)
    self.__logicFrame = frame
end

--@desc: 获取添加时的逻辑帧数
--@return: number
function AOperationCommand:getLogicFrame()
    return self.__logicFrame
end

function AOperationCommand:setCommanderId(commanderId)
    self.__commanderId = commanderId
end

function AOperationCommand:getCommanderId()
    return self.__commanderId
end

--@desc: 设置命令优先级
--@author:Seven
--@time:2023-12-20 16:57:05
function AOperationCommand:setCommandPriority(value)
    self.__priority = value
end

--@desc: 获取命令优先级
--@author:Seven
--@time:2023-12-20 16:57:37
--@return: number
function AOperationCommand:getCommandPriority()
    return self.__priority
end

function AOperationCommand:setCommandTypeId(commandTypeId)
    self.__commandTypeId = commandTypeId
end

--@desc: 设置命令名称
--@author:Seven
--@time:2023-12-20 17:35:17
--@name: string
function AOperationCommand:setCommandName(name)
    self.__name = name
end

--@desc: 获取命令名称
--@author:Seven
--@time:2023-12-20 17:35:29
function AOperationCommand:getCommandName()
    return self.__name
end

function AOperationCommand:getCommandTypeId()
    return self.__commandTypeId
end

function AOperationCommand:putCommandParam(commandParam)
    table.insert(self.__commandParam, commandParam)
end

function AOperationCommand:getCommandParam(index)
    return self.__commandParam[index]
end

return abstract("AOperationCommand", {IOperationCommand}, AOperationCommand)
00000