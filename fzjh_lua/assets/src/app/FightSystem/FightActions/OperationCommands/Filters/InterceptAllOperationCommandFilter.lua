--[[
    author:Seven
    time:2023-12-19 14:30:46
    desc: 拦截当前角色所有操作命令
]]
local newClass = require("third.class.NewClass")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local AOperationCommandFilter = require("app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter#AOperationCommandFilter]
local InterceptAllOperationCommandFilter = {}

function InterceptAllOperationCommandFilter:create(commanderId, popTextId)
    return InterceptAllOperationCommandFilter.new():__init(commanderId, popTextId)
end

function InterceptAllOperationCommandFilter:__init(commanderId, popTextId)
    self.__commanderId = commanderId

    self.__popTextId = popTextId

    return self
end

--@desc: 执行过滤器
--@operationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
--@operationCommandResponse: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
--@filterChain: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
--@return void
function InterceptAllOperationCommandFilter:doFilter(operationCommand, operationCommandResponse, filterChain)
    if operationCommand:getCommanderId() == self.__commanderId then
        operationCommandResponse:setResult(false)
        operationCommandResponse:setResultPopText(TextResManager:getText(self.__popTextId))
        return
    end

    filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
end

return newClass("InterceptAllOperationCommandFilter", {AOperationCommandFilter}, InterceptAllOperationCommandFilter)
000000000