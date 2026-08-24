--[[
    author:Seven
    time:2023-12-19 14:10:31
    desc: 主动技能是否满足释放条件
]]
local newClass = require("third.class.NewClass")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local AOperationCommandFilter = require("app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter#AOperationCommandFilter]
local ActiveSkillAreMeetReleaseFilter = {}

function ActiveSkillAreMeetReleaseFilter:create()
    return ActiveSkillAreMeetReleaseFilter.new()
end

--@desc: 执行过滤器
--@operationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
--@operationCommandResponse: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
--@filterChain: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
--@return void
function ActiveSkillAreMeetReleaseFilter:doFilter(operationCommand, operationCommandResponse, filterChain)
    if operationCommand:getCommandTypeId() ~= FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_ACTIVE_SKILL then
        return filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
    end

    local commander = self.__operationCommandQueue:getCommander(operationCommand:getCommanderId())

    local activeSkillId = operationCommand:getCommandParam(1)

    local activeSkill = commander:getActiveSkill(activeSkillId)

    local releaseResult, fialmsg = activeSkill:releaseAreMet()
    if releaseResult == false then
        operationCommandResponse:setResult(false)
        operationCommandResponse:setResultPopText(fialmsg)
        return
    end

    filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
end

return newClass("ActiveSkillAreMeetReleaseFilter", {AOperationCommandFilter}, ActiveSkillAreMeetReleaseFilter)
0000000000