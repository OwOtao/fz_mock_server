--[[
    author:Seven
    time:2023-12-18 20:16:04
    desc: 角色操作命令队列数量限制
]]
local newClass = require("third.class.NewClass")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local AOperationCommandFilter = require("app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter#AOperationCommandFilter]
local CharacterCountLimitFilter = {}

function CharacterCountLimitFilter:create()
    return CharacterCountLimitFilter.new()
end

--@desc: 执行过滤器
--@operationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
--@operationCommandResponse: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
--@filterChain: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
--@return void
function CharacterCountLimitFilter:doFilter(operationCommand, operationCommandResponse, filterChain)
    if operationCommand:getCommandTypeId() == FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_RUNAWAY then
        return filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
    end

    local commanderId = operationCommand:getCommanderId()

    local totalCount = self.__operationCommandQueue:getOperationCommandCountByCommanderId(commanderId)

    if totalCount >= BattleConstConf:get("oneRoleZhaoQueueLimit") then
        operationCommandResponse:setResult(false)

        FightUtil:printLog(string.format("CharacterCountLimitFilter:doFilter %s 队列中已申请 %d 个操作 , 无法加入队列", tostring(commanderId), totalCount))

        return
    end

    filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
end

return newClass("CharacterCountLimitFilter", {AOperationCommandFilter}, CharacterCountLimitFilter)
0000000000