--[[
    author:Seven
    time:2024-03-01 11:57:21
    desc: 气血恢复功能是否满足释放条件
]]
local newClass = require("third.class.NewClass")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local AOperationCommandFilter = require("app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter#AOperationCommandFilter]
local QiRecoverAreMeetReleaseFilter = {}

function QiRecoverAreMeetReleaseFilter:create()
    return QiRecoverAreMeetReleaseFilter.new()
end

--@desc: 执行过滤器
--@operationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
--@operationCommandResponse: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
--@filterChain: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
--@return void
function QiRecoverAreMeetReleaseFilter:doFilter(operationCommand, operationCommandResponse, filterChain)
    if operationCommand:getCommandTypeId() ~= FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_QI_RECOVER then
        return filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
    end

    local commander = self.__operationCommandQueue:getCommander(operationCommand:getCommanderId())

    local qiRecover = commander:getRecoverQi()

    local releaseResult, fialmsg = qiRecover:releaseAreMet()
    if releaseResult == false then
        operationCommandResponse:setResult(false)
        operationCommandResponse:setResultPopText(fialmsg)
        return
    end

    filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
end

return newClass("QiRecoverAreMeetReleaseFilter", {AOperationCommandFilter}, QiRecoverAreMeetReleaseFilter)
000000