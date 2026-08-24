--[[
    author:Seven
    time:2023-12-18 17:40:52
    desc: 队列总数限定
]]
local newClass = require("third.class.NewClass")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local AOperationCommandFilter = require("app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter#AOperationCommandFilter]
local QueueTotalCountFilter = {}

function QueueTotalCountFilter:create()
    return QueueTotalCountFilter.new()
end

--@desc: 执行过滤器
--@operationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
--@operationCommandResponse: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
--@filterChain: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
--@return void
function QueueTotalCountFilter:doFilter(operationCommand, operationCommandResponse, filterChain)
    if operationCommand:getCommandTypeId() == FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_RUNAWAY then
        return filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
    end

    local totalCount = self.__operationCommandQueue:getTotalOperationCommandCount()

    if totalCount >= BattleConstConf:get("zhaoQueueLimit") then
        operationCommandResponse:setResult(false)
        operationCommandResponse:setResultPopText(TextResManager:getText("1011"))
        return
    end

    filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
end

return newClass("QueueTotalCountFilter", {AOperationCommandFilter}, QueueTotalCountFilter)
000000000000