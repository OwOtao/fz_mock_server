--[[
    author:Seven
    time:2023-12-18 16:33:36
    desc:
]]
local IOperationCommandQueue = require("app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue")

local IOperationCommandFilter = require("app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter")

local IOperationCommand = require("app.FightSystem.FightActions.OperationCommands.IOperationCommand")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
local OperationCommandQueue = {
    __queue = {},
    __filters = {},
    __filterChainIndex = 0
}

function OperationCommandQueue:create(...)
    return OperationCommandQueue.new():__init(...)
end

function OperationCommandQueue:__init(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight
    return self
end

function OperationCommandQueue:ctor()
    self:addOpeartionCommandFilter(require("app.FightSystem.FightActions.OperationCommands.Filters.QueueTotalCountFilter"):create())
    self:addOpeartionCommandFilter(require("app.FightSystem.FightActions.OperationCommands.Filters.CharacterCountLimitFilter"):create())
    self:addOpeartionCommandFilter(require("app.FightSystem.FightActions.OperationCommands.Filters.QiRecoverAreMeetReleaseFilter"):create())
    self:addOpeartionCommandFilter(require("app.FightSystem.FightActions.OperationCommands.Filters.ChangeWeaponAreMeetReleaseFilter"):create())
    self:addOpeartionCommandFilter(require("app.FightSystem.FightActions.OperationCommands.Filters.ActiveSkillAreMeetReleaseFilter"):create())
    self:addOpeartionCommandFilter(require("app.FightSystem.FightActions.OperationCommands.Filters.ActiveSkillBanFilter"):create())
    self:addOpeartionCommandFilter(require("app.FightSystem.FightActions.OperationCommands.Filters.ActiveSkillCDFilter"):create())
    self:addOpeartionCommandFilter(require("app.FightSystem.FightActions.OperationCommands.Filters.ActiveSkillIsPrepFilter"):create())
end

--@desc: 添加操作命令
--@author:Seven
--@time:2023-12-18 15:14:11
--@operationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
--@return [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
function OperationCommandQueue:addOperationCommand(operationCommand)
    isImplement(operationCommand, IOperationCommand)

    local operationCommandResponse = self:__doFilter(operationCommand)

    if operationCommandResponse:getResult() == true then
        operationCommand:setLogicFrame(self.__fight:getCurrentFrameIndex())
        operationCommand:onAddCommandQueue(self)
        table.insert(self.__queue, operationCommand)
        FightUtil:printLog("添加操作命令成功，命令：" .. operationCommand:getCommandName())
        self:__sortQueues()
    end

    return operationCommandResponse
end

--@desc: 移除操作命令
--@operationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
function OperationCommandQueue:removeOperationCommand(operationCommand)
    for i = table.getn(self.__queue), 1, -1 do
        if self.__queue[i] == operationCommand then
            table.remove(self.__queue, i):onRemoveCommandQueue(self)
            break
        end
    end
end

--@desc: 弹出队头操作命令
--@author:Seven
--@time:2023-12-18 16:38:39
--@return [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
function OperationCommandQueue:popFirstOperationCommand()
    local operationCommand = self.__queue[1]

    self:removeOperationCommand(operationCommand)

    return operationCommand
end

function OperationCommandQueue:getFirstOperationCommand()
    return self.__queue[1]
end

function OperationCommandQueue:addOpeartionCommandFilter(operationCommandFilter)
    table.insert(self.__filters, 1, isImplement(operationCommandFilter, IOperationCommandFilter))
    operationCommandFilter:setOperationCommandQueue(self)
end

function OperationCommandQueue:removeOpeartionCommandFilter(operationCommandFilter)
    for i = table.getn(self.__filters), 1, -1 do
        if self.__filters[i] == operationCommandFilter then
            table.remove(self.__filters, i)
            break
        end
    end
end

--@desc: 根据角色id获取该角色的所有命令
--@author:Seven
--@time:2023-12-20 16:14:22
--@commanderId: 命令者id
--@return: array [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
function OperationCommandQueue:getOperationCommandByCommanderId(commanderId)
    local list = {}
    self:__walkOperationCommandQueue(
        function(operationCommand)
            if operationCommand:getCommanderId() == commanderId then
                table.insert(list, operationCommand)
            end
        end
    )
    return list
end

function OperationCommandQueue:removeCommanderAllOperationCommand(commanderId)
    local list = {}
    for i = table.getn(self.__queue), 1, -1 do
        if self.__queue[i]:getCommanderId() == commanderId then
            table.insert(list, self.__queue[i])
        end
    end

    for i, v in ipairs(list) do
        self:removeOperationCommand(v)
    end

    if #list > 0 then
        self.__fight:notifyVeiwEvent(require("app.FightSystem.Veiws.ViewEvents.Events.CharacterOperationAllRemoveViewEvent"):create(commanderId))
    end
end

--@desc: 根据命令释放者id获取队列中命令数量
--@author:Seven
--@time:2023-12-18 16:52:50
--@commanderId: 命令者id
--@return number
function OperationCommandQueue:getOperationCommandCountByCommanderId(commanderId)
    local count = 0
    self:__walkOperationCommandQueue(
        function(operationCommand)
            if operationCommand:getCommanderId() == commanderId then
                count = count + 1
            end
        end
    )
    return count
end

--@desc: 获取队列中命令数量
--@author:Seven
--@time:2023-12-18 16:53:47
function OperationCommandQueue:getTotalOperationCommandCount()
    return #self.__queue
end

--@desc: 执行添加操作命令过滤器
--@author:Seven
--@time:2023-12-18 17:01:21
--@return [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
function OperationCommandQueue:__doFilter(operationCommand)
    self.__filterChainIndex = 1

    local operationCommandResponse = require("app.FightSystem.FightActions.OperationCommands.Response.OperationCommandResponse"):create()

    self:doFilter(operationCommand, operationCommandResponse, self)

    return operationCommandResponse
end

--@desc: 执行添加操作命令过滤器
--@author:Seven
--@time:2023-12-18 17:00:00
--@IOperationCommand:
--@IOperationCommandResponse:
--@filterChain:
--@return: void
function OperationCommandQueue:doFilter(IOperationCommand, IOperationCommandResponse, filterChain)
    if self.__filterChainIndex > #self.__filters then
        return
    end

    --@RefType [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
    local filter = self.__filters[self.__filterChainIndex]

    self.__filterChainIndex = self.__filterChainIndex + 1

    return filter:doFilter(IOperationCommand, IOperationCommandResponse, filterChain)
end

function OperationCommandQueue:__walkOperationCommandQueue(func)
    if #self.__queue <= 0 then
        return
    end

    for index, v in ipairs(self.__queue) do
        if func(v, index) == true then
            break
        end
    end
end

function OperationCommandQueue:getCommander(commanderId)
    return self.__fight:getCharacter(commanderId)
end

function OperationCommandQueue:__sortQueues()
    table.heapSort(
        self.__queue,
        function(a, b)
            --@RefType [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
            a = a

            --@RefType [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
            b = b

            if a:getCommandPriority() > b:getCommandPriority() then
                return true
            end

            if a:getCommandPriority() == b:getCommandPriority() then
                return a:getLogicFrame() >= b:getLogicFrame()
            end

            return false
        end
    )
end

return newClass("OperationCommandQueue", {IOperationCommandQueue}, OperationCommandQueue)
00000000