--[[
    author:Seven
    time:2023-12-18 21:20:00
    desc: 主动技能操作命令
]]
local AOperationCommand = require("app.FightSystem.FightActions.OperationCommands.Commands.AOperationCommand")

local FightCommons = require("app.FightSystem.FightCommons")

local OPERATION_TYPE = FightCommons.CHARACTER_OPERATION_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.Commands.AOperationCommand#AOperationCommand]
local ActiveSkillOperationCommand = {}

function ActiveSkillOperationCommand:create()
    return ActiveSkillOperationCommand.new():__init()
end

function ActiveSkillOperationCommand:__init()
    self:setCommandTypeId(OPERATION_TYPE.OPERATION_ACTIVE_SKILL)

    self:setCommandPriority(3)

    self.__sameActiveSkillIdFilter = nil

    return self
end

--@operationCommandQueue: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
function ActiveSkillOperationCommand:onAddCommandQueue(operationCommandQueue)
    local activeSkillOperationId = self:__getActiveSkillId()
    self.__sameActiveSkillIdFilter = require("app.FightSystem.FightActions.OperationCommands.Filters.SameActiveSkillIdFilter"):create(activeSkillOperationId, self:getCommanderId())
    operationCommandQueue:addOpeartionCommandFilter(self.__sameActiveSkillIdFilter)
end

--@operationCommandQueue: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
function ActiveSkillOperationCommand:onRemoveCommandQueue(operationCommandQueue)
    operationCommandQueue:removeOpeartionCommandFilter(self.__sameActiveSkillIdFilter)
end

--@desc: 当前命令是否满足执行条件
--@author:Seven
--@time:2023-12-21 14:48:05
--@fightContext: [src.app.FightSystem.Fight.BattleSystem#Fight]
--@return: true | false , failmsg
function ActiveSkillOperationCommand:canDoOperationCommand(fightContext)
    local character = fightContext:getCharacter(self:getCommanderId())
    local activeSkill = character:getActiveSkill(self:__getActiveSkillId())

    local cando, failMsg = activeSkill:isMeetRelease()

    return cando, failMsg
end

function ActiveSkillOperationCommand:__getActiveSkillId()
    return self:getCommandParam(1)
end

return newClass("ActiveSkillOperationCommand", {AOperationCommand}, ActiveSkillOperationCommand)
0000000000