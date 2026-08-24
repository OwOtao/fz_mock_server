--[[
    author:Seven
    time:2023-12-18 19:54:00
    desc:
]]
local abstract = require("third.class.abstract")

local IOperationCommandFilter = require("app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter")

local IOperationCommandQueue = require("app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue")

local isImplement = require("third.assertIsInstance.assertIsInstance")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
local AOperationCommandFilter = {}

function AOperationCommandFilter:setOperationCommandQueue(operationCommandQueue)
    --@RefType [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
    self.__operationCommandQueue = isImplement(operationCommandQueue, IOperationCommandQueue)
end

function AOperationCommandFilter:getOperationCommandQueue()
    return self.__operationCommandQueue
end

return abstract("AOperationCommandFilter", {IOperationCommandFilter}, AOperationCommandFilter)
0000