--[[
    author:Seven
    time:2023-12-19 15:44:21
    desc: 逃跑操作命令
]]
local AOperationCommand = require("app.FightSystem.FightActions.OperationCommands.Commands.AOperationCommand")

local FightCommons = require("app.FightSystem.FightCommons")

local OPERATION_TYPE = FightCommons.CHARACTER_OPERATION_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.Commands.AOperationCommand#AOperationCommand]
local RunawayOperationCommand = {}

function RunawayOperationCommand:create()
    return RunawayOperationCommand.new():__init()
end

function RunawayOperationCommand:__init()
    self:setCommandTypeId(OPERATION_TYPE.OPERATION_RUNAWAY)
    self:setCommandPriority(1)

    return self
end

--@operationCommandQueue: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
function RunawayOperationCommand:onAddCommandQueue(operationCommandQueue)
    operationCommandQueue:removeCommanderAllOperationCommand(self:getCommanderId())
    self.__interceptAllOperationCommandFilter = require("app.FightSystem.FightActions.OperationCommands.Filters.InterceptAllOperationCommandFilter"):create(self:getCommanderId(), "1012")
    operationCommandQueue:addOpeartionCommandFilter(self.__interceptAllOperationCommandFilter)
end

--@operationCommandQueue: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
function RunawayOperationCommand:onRemoveCommandQueue(operationCommandQueue)
    operationCommandQueue:removeOpeartionCommandFilter(self.__interceptAllOperationCommandFilter)
end

--@desc: 当前命令是否满足执行条件
--@author:Seven
--@time:2023-12-21 14:48:05
--@fightContext: [src.app.FightSystem.Fight.BattleSystem#Fight]
--@return: true | false , failmsg
function RunawayOperationCommand:canDoOperationCommand(fightContext)
    return true
end

return newClass("RunawayOperationCommand", {AOperationCommand}, RunawayOperationCommand)
00000