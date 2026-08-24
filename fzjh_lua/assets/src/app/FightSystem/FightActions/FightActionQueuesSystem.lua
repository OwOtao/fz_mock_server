--[[
    author:Seven
    time:2022-10-27 15:03:46
    desc: 战斗角色行动队列系统

        1、 被动攻击行动队列
        2、 玩家操作相关队列命令
]]
local newClass = require("third.class.NewClass")

local AFightSystem = require("app.FightSystem.Fight.BasicBattleSystem.AFightSystem")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.Fight.BasicBattleSystem.AFightSystem#AFightSystem]
local FightActionQueuesSystem = {}

FightActionQueuesSystem.SYSTEM_NAME = "FightActionQueuesSystem"

function FightActionQueuesSystem:create()
    return FightActionQueuesSystem.new()
end

function FightActionQueuesSystem:ctor()
    self.__name = FightActionQueuesSystem.SYSTEM_NAME

    --@desc 被动攻击队列
    self.__autoAttackList = {}

    --@desc 用于生成操作id
    self.__operationIdIndex = 10000
end

function FightActionQueuesSystem:onInit()
    --@RefType [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
    self.__operationCommandQueue = require("app.FightSystem.FightActions.OperationCommands.OperationCommandQueue"):create(self.__fight)
end

function FightActionQueuesSystem:onRun()
end

function FightActionQueuesSystem:onEnter()
end

function FightActionQueuesSystem:onStart()
end

function FightActionQueuesSystem:onFinish()
end

--@region 被动攻击
function FightActionQueuesSystem:pushCharacterAutoAttackAction(aAtk_action)
    table.insert(self.__autoAttackList, aAtk_action)
end

--@desc: 获取被动攻击动作信息
--@author:Seven
--@time:2022-10-27 17:27:09
--@return: [src.app.FightSystem.FightActions.AutoAttackAction#AutoAttackAction]
function FightActionQueuesSystem:getAutoAttackAction()
    if table.getn(self.__autoAttackList) <= 0 then
        return nil
    end

    local list = {}

    self:__walkAutoAttackQueues(
        function(index, action)
            if table.getn(list) <= 0 then
                table.insert(list, {index, action})
            else
                local theFirstActionInfo = list[1]

                --@RefType [src.app.FightSystem.FightActions.AutoAttackAction#AutoAttackAction]
                local theFirstAction = theFirstActionInfo[2]

                if theFirstAction:getLogicIndex() == action:getLogicIndex() then
                    table.insert(list, {index, action})
                elseif theFirstAction:getLogicIndex() > action:getLogicIndex() then
                    list = {}
                    table.insert(list, {index, action})
                end
            end

            return false
        end
    )

    if table.getn(list) <= 0 then
        error("被动攻击筛选列表不该为空，检查代码")
    end

    local randomIndex = FightUtil:random(1, #list)

    local actionInfo = list[randomIndex]

    local actionIndex, action = actionInfo[1], actionInfo[2]

    table.remove(self.__autoAttackList, actionIndex)

    return action
end

function FightActionQueuesSystem:hasCharacterAutoAttackAction(c_id)
    local isIn = false

    self:__walkAutoAttackQueues(
        function(_, autoAttackAction)
            if autoAttackAction:getCharacterId() == c_id then
                isIn = true
                return true
            end

            return false
        end
    )

    return isIn
end

--@desc: 遍历被动攻击列表
--@author:Seven
--@time:2022-10-28 14:29:41
--@func: 遍历方法
function FightActionQueuesSystem:__walkAutoAttackQueues(func)
    if table.getn(self.__autoAttackList) <= 0 then
        return
    end

    for i, v in ipairs(self.__autoAttackList) do
        if func(i, v) == true then
            break
        end
    end
end

--@endregion

function FightActionQueuesSystem:__getNewOperationId()
    self.__operationIdIndex = self.__operationIdIndex + 1
    return self.__operationIdIndex
end

--@region 玩家操作相关

--@desc: 添加操作命令
--@author:Seven
--@time:2023-12-20 15:58:37
--@operationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
function FightActionQueuesSystem:addOperationCommand(operationCommand)
    local response = self.__operationCommandQueue:addOperationCommand(operationCommand)

    if response:getResult() == true then
        self.__fight:notifyVeiwEvent(
            require("app.FightSystem.Veiws.ViewEvents.Events.CharacterOperationShowViewEvent"):create(
                operationCommand:getCommanderId(),
                operationCommand:getOperationCommandId(),
                operationCommand:getCommandName()
            )
        )
    end

    if response:getResult() == false and operationCommand:getCommanderId() == self.__fight:getPlayerId() then
        self.__fight:popText(response:getResultPopText())
    end
end

function FightActionQueuesSystem:getFirstOperationCommand()
    return self.__operationCommandQueue:getFirstOperationCommand()
end

function FightActionQueuesSystem:popFirstOperationCommand()
    local operationCommand = self.__operationCommandQueue:popFirstOperationCommand()
    if operationCommand ~= nil then
        return operationCommand
    end

    return nil
end

function FightActionQueuesSystem:removeAllCharacterOperation(c_id)
    self.__operationCommandQueue:removeCommanderAllOperationCommand(c_id)
end

function FightActionQueuesSystem:characterDead(c_id)
    self.__operationCommandQueue:removeCommanderAllOperationCommand(c_id)

    if #self.__autoAttackList <= 0 then
        return
    end
    for i = #self.__autoAttackList, 1, -1 do
        local autoAction = self.__autoAttackList[i]
        if autoAction:getCharacterId() == c_id then
            table.remove(self.__autoAttackList, i)
        end
    end
end

--@endregion

return newClass("FightActionQueuesSystem", {AFightSystem}, FightActionQueuesSystem)
0000000