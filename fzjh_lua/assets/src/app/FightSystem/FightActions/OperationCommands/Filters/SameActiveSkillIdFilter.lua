--[[
    author:Seven
    time:2023-12-19 14:44:09
    desc: 相同主动技能不允许
]]
local newClass = require("third.class.NewClass")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local AOperationCommandFilter = require("app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.Filters.AOperationCommandFilter#AOperationCommandFilter]
local SameActiveSkillIdFilter = {}

function SameActiveSkillIdFilter:create(activeSkillOperationId, commanderId)
    return SameActiveSkillIdFilter.new():__init(activeSkillOperationId, commanderId)
end

function SameActiveSkillIdFilter:__init(activeSkillOperationId, commanderId)
    self.__activeSkillOperationId = activeSkillOperationId

    self.__commanderId = commanderId

    return self
end

--@desc: 执行过滤器
--@operationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
--@operationCommandResponse: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
--@filterChain: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
--@return void
function SameActiveSkillIdFilter:doFilter(operationCommand, operationCommandResponse, filterChain)
    if operationCommand:getCommandTypeId() ~= FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_ACTIVE_SKILL then
        filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
        return
    end

    if self.__commanderId == operationCommand:getCommanderId() and self.__activeSkillOperationId == operationCommand:getCommandParam(1) then
        operationCommandResponse:setResult(false)
        return
    end

    filterChain:doFilter(operationCommand, operationCommandResponse, filterChain)
end

return newClass("SameActiveSkillIdFilter", {AOperationCommandFilter}, SameActiveSkillIdFilter)
00000000000