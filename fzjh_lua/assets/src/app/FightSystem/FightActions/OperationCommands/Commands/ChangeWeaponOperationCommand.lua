--[[
    author:Seven
    time:2023-12-19 16:52:51
    desc: 易武操作命令
]]
local AOperationCommand = require("app.FightSystem.FightActions.OperationCommands.Commands.AOperationCommand")

local FightCommons = require("app.FightSystem.FightCommons")

local OPERATION_TYPE = FightCommons.CHARACTER_OPERATION_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.Commands.AOperationCommand#AOperationCommand]
local ChangeWeaponOperationCommand = {}

function ChangeWeaponOperationCommand:create()
    return ChangeWeaponOperationCommand.new():__init()
end

function ChangeWeaponOperationCommand:__init()
    self:setCommandTypeId(OPERATION_TYPE.OPERATION_CHANGE_WEAPON)
    self:setCommandPriority(2)

    return self
end

--@operationCommandQueue: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
function ChangeWeaponOperationCommand:onAddCommandQueue(operationCommandQueue)
    operationCommandQueue:removeCommanderAllOperationCommand(self:getCommanderId())
    self.__withRunawayFilter = require("app.FightSystem.FightActions.OperationCommands.Filters.InterceptWithoutRunawayFilter"):create(self:getCommanderId(), self:getCommandTypeId())
    operationCommandQueue:addOpeartionCommandFilter(self.__withRunawayFilter)
end

--@operationCommandQueue: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
function ChangeWeaponOperationCommand:onRemoveCommandQueue(operationCommandQueue)
    operationCommandQueue:removeOpeartionCommandFilter(self.__withRunawayFilter)
end

--@desc: 当前命令是否满足执行条件
--@author:Seven
--@time:2023-12-21 14:48:05
--@fightContext: [src.app.FightSystem.Fight.BattleSystem#Fight]
--@return: true | false , failmsg
function ChangeWeaponOperationCommand:canDoOperationCommand(fightContext)
    local character = fightContext:getCharacter(self:getCommanderId())
    return character:checkCanDoChangeWeaponFunc()
end

return newClass("ChangeWeaponOperationCommand", {AOperationCommand}, ChangeWeaponOperationCommand)
000000000000000