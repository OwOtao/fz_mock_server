--[[
    author:Seven
    time:2023-12-19 11:10:30
    desc: 主动技能CD过滤器
]]
local newClass = require("third.class.NewClass")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local AOperationCommandFilter = require("app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter#AOperationCommandFilter]
local ActiveSkillCDFilter = {}

function ActiveSkillCDFilter:create()
    return ActiveSkillCDFilter.new()
end

--@desc: 执行过滤器
--@operationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
--@operationCommandResponse: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
--@filterChain: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
--@return void
function ActiveSkillCDFilter:doFilter(operationCommand, operationCommandResponse, filterChain)
    if operationCommand:getCommandTypeId() ~= FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_ACTIVE_SKILL then
        return filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
    end

    local commander = self.__operationCommandQueue:getCommander(operationCommand:getCommanderId())

    local activeSkillId = operationCommand:getCommandParam(1)

    local activeSkill = commander:getActiveSkill(activeSkillId)

    if activeSkill:getCD() > 0 then
        operationCommandResponse:setResult(false)
        operationCommandResponse:setResultPopText(TextResManager:getText("1010"))
        return
    end

    filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
end

return newClass("ActiveSkillCDFilter", {AOperationCommandFilter}, ActiveSkillCDFilter)
0000000