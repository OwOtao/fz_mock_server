--[[
    author:Seven
    time:2023-12-19 15:44:21
    desc: 气血恢复
]]
local AOperationCommand = require("app.FightSystem.FightActions.OperationCommands.Commands.AOperationCommand")

local FightCommons = require("app.FightSystem.FightCommons")

local OPERATION_TYPE = FightCommons.CHARACTER_OPERATION_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.Commands.AOperationCommand#AOperationCommand]
local QiRecoverOperationCommand = {}

function QiRecoverOperationCommand:create()
    return QiRecoverOperationCommand.new():__init()
end

function QiRecoverOperationCommand:__init()
    self:setCommandTypeId(OPERATION_TYPE.OPERATION_QI_RECOVER)
    
    self:setCommandPriority(3)

    return self
end

--@operationCommandQueue: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
function QiRecoverOperationCommand:onAddCommandQueue(operationCommandQueue)
    self.__typeFilter = require("app.FightSystem.FightActions.OperationCommands.Filters.InterceptCommandTypeFilter"):create(self:getCommanderId(), self:getCommandTypeId())
    operationCommandQueue:addOpeartionCommandFilter(self.__typeFilter)
end

--@operationCommandQueue: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
function QiRecoverOperationCommand:onRemoveCommandQueue(operationCommandQueue)
    operationCommandQueue:removeOpeartionCommandFilter(self.__typeFilter)
end

--@desc: 当前命令是否满足执行条件
--@author:Seven
--@time:2023-12-21 14:48:05
--@fightContext: [src.app.FightSystem.Fight.BattleSystem#Fight]
--@return: true | false , failmsg
function QiRecoverOperationCommand:canDoOperationCommand(fightContext)
    local character = fightContext:getCharacter(self:getCommanderId())

    local recoverQi = character:getRecoverQi()

    local releaseResult, fialmsg = recoverQi:releaseAreMet()

    return releaseResult, fialmsg
end

return newClass("QiRecoverOperationCommand", {AOperationCommand}, QiRecoverOperationCommand)
000000