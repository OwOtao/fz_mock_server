--[[
    author:Seven
    time:2023-12-22 14:54:47
    desc: 攻击行动工具类
]]
local FightCommons = require("app.FightSystem.FightCommons")

local AttackBattleActionUtil = {}

--@desc:
--@author:Seven
--@time:2023-12-22 15:12:34
--@operationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
--@fight: [src.app.FightSystem.Fight.BattleSystem#Fight]
--@return [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
function AttackBattleActionUtil:createAttackBattleActionFromOperationCommand(operationCommand, fight)
    local attackBattleAction = nil

    switch(
        operationCommand:getCommandTypeId(),
        {
            [FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_ACTIVE_SKILL] = function()
                local ActiveAttackContext = require("app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext")

                local context =
                    ActiveAttackContext.createContext(fight, operationCommand:getCommanderId(), fight:getAttackTarget(operationCommand:getCommanderId()):getId(), operationCommand:getCommandParam(1))

                local ActiveAttackBattleAction = require("app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackBattleAction")

                attackBattleAction = ActiveAttackBattleAction:create(context)
            end,
            [FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_CHANGE_WEAPON] = function()
                local action = require("app.FightSystem.BattleActions.AttackBattleAction.OtherActions.ChangeWeaponAction")
                attackBattleAction = action:create(operationCommand:getCommanderId())
            end,
            [FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_QI_RECOVER] = function()
                local RecoverQiAction = require("app.FightSystem.BattleActions.AttackBattleAction.RecoverAction.RecoverQiAction")

                attackBattleAction = RecoverQiAction:create(operationCommand:getCommanderId())
            end,
            [FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_RUNAWAY] = function()
                local action = require("app.FightSystem.BattleActions.AttackBattleAction.OtherActions.RunawayAction")

                attackBattleAction = action:create(operationCommand:getCommanderId())
            end,
            ["default"] = function()
                error("AttackBattleActionUtil:createAttackBattleActionFromOperationCommand 未知的操作类型" .. tostring(operationCommand:getCommandTypeId()))
            end
        }
    )
    
    attackBattleAction:init(fight)

    return attackBattleAction
end

return AttackBattleActionUtil
0000000000000000