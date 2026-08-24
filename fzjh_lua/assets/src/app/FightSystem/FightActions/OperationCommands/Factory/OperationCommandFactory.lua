--[[
    author:Seven
    time:2023-12-25 14:36:24
    desc:
]]
local OperationCommandFactory = {}

local FightCommons = require("app.FightSystem.FightCommons")

--@desc: 创建命令操作对象
--@author:Seven
--@time:2023-12-25 20:49:51
--@fight: [src.app.FightSystem.Fight.BattleSystem#Fight]
--@operationCommandTypeId: 命令类型
--@commanderId: 命令角色id
--@args: table
--@return [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
function OperationCommandFactory:createOperationCommand(fight, operationCommandTypeId, commanderId, args)
    --@RefType [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
    local operationCommand = nil
    if operationCommandTypeId == FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_ACTIVE_SKILL then
        operationCommand = require("app.FightSystem.FightActions.OperationCommands.Commands.ActiveSkillOperationCommand"):create()
        local activeSkill = fight:getCharacter(commanderId):getActiveSkill(args[1])
        operationCommand:setCommandName(activeSkill:getName())
    elseif operationCommandTypeId == FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_CHANGE_WEAPON then
        operationCommand = require("app.FightSystem.FightActions.OperationCommands.Commands.ChangeWeaponOperationCommand"):create()
        operationCommand:setCommandName("易武")
    elseif operationCommandTypeId == FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_QI_RECOVER then
        operationCommand = require("app.FightSystem.FightActions.OperationCommands.Commands.QiRecoverOperationCommand"):create()
        operationCommand:setCommandName("恢复")
    elseif operationCommandTypeId == FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_RUNAWAY then
        operationCommand = require("app.FightSystem.FightActions.OperationCommands.Commands.RunawayOperationCommand"):create()
        operationCommand:setCommandName("逃跑")
    end

    operationCommand:setCommanderId(commanderId)

    for i = 1, #args do
        operationCommand:putCommandParam(args[i])
    end

    return operationCommand
end

return OperationCommandFactory
00000000000000