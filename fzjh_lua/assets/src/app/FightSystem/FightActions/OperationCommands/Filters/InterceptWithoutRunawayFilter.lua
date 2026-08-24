--[[
    author:Seven
    time:2023-12-19 14:19:09
    desc: 拦截除逃跑外的所有操作命令
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local AOperationCommandFilter = require("app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter#AOperationCommandFilter]
local InterceptWithoutRunawayFilter = {}

function InterceptWithoutRunawayFilter:create(commderId)
    return InterceptWithoutRunawayFilter.new():__init(commderId)
end

function InterceptWithoutRunawayFilter:__init(commderId)
    self.__commanderId = commderId

    return self
end

--@desc: 执行过滤器
--@operationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
--@operationCommandResponse: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
--@filterChain: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
--@return void
function InterceptWithoutRunawayFilter:doFilter(operationCommand, operationCommandResponse, filterChain)
    if operationCommand:getCommanderId() ~= self.__commanderId then
        return filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
    end

    if operationCommand:getCommandTypeId() == FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_RUNAWAY then
        return filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
    end

    operationCommandResponse:setResult(false)
end

return newClass("InterceptWithoutRunawayFilter", {AOperationCommandFilter}, InterceptWithoutRunawayFilter)
00000000000