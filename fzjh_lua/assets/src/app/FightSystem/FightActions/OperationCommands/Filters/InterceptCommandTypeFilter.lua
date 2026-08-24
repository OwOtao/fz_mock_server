--[[
    author:Seven
    time:2023-12-19 14:19:09
    desc: 相同类型操作不允许
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local AOperationCommandFilter = require("app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter#AOperationCommandFilter]
local InterceptCommandTypeFilter = {}

function InterceptCommandTypeFilter:create(commderId, commandTypeId)
    return InterceptCommandTypeFilter.new():__init(commderId, commandTypeId)
end

function InterceptCommandTypeFilter:__init(commderId, commandTypeId)
    self.__commderId = commderId

    self.__filterTypeId = commandTypeId

    return self
end

--@desc: 执行过滤器
--@operationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
--@operationCommandResponse: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
--@filterChain: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
--@return void
function InterceptCommandTypeFilter:doFilter(operationCommand, operationCommandResponse, filterChain)
    if operationCommand:getCommanderId() == self.__commderId and operationCommand:getCommandTypeId() == self.__filterTypeId then
        operationCommandResponse:setResult(false)
        return
    end

    filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
end

return newClass("InterceptCommandTypeFilter", {AOperationCommandFilter}, InterceptCommandTypeFilter)
00000