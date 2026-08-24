local newClass = require("third.class.NewClass")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

-- local AFightSystem = require("app.FightSystem.Fight.BasicBattleSystem.AFightSystem")

--@RefType [src.app.FightSystem.CharacterSystem.CharacterSystem#CharacterSystem]
local CharacterSystem = require("app.FightSystem.CharacterSystem.CharacterSystem")

--@RefType [src.app.FightSystem.FightActions.FightActionQueuesSystem#FightActionQueuesSystem]
local FightActionQueuesSystem = require("app.FightSystem.FightActions.FightActionQueuesSystem")

--@RefType [src.app.FightSystem.FightState.FightStateMachine#FightStateMachine]
local FightStateMachine = require("app.FightSystem.FightState.FightStateMachine")

local AFinishStrategy = require("app.FightSystem.FightFinishStrategy.AFinishStrategy")

local FightCommons = require("app.FightSystem.FightCommons")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local IBuffContext = require("app.FightSystem.FightRole.CharacterBuff.BuffContext.IBuffContext")

local Fight = {
    __battleScene = BattleConstConf:get("fightBackgroundDefaultID"),
    __systems = {},
    __playerId = nil
}

function Fight:create(...)
    return Fight.new():__init(...)
end

function Fight:__init(systemConfig, finishCallback)
    --@RefType [src.app.FightSystem.FightState.FightStateMachine#FightStateMachine]
    self.__stateMachine = require("app.FightSystem.FightState.FightStateMachine"):create(self)

    --@RefType [src.app.FightSystem.FightMessage.FightFrameMessageSystem#FightFrameMessageSystem]
    self.__frameMessageQueue = require("app.FightSystem.FightMessage.FightFrameMessageSystem"):create(self)

    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffContext.BuffEffectHurtArray#BuffEffectHurtArray]
    self.__buffEffectHurtArray = require("app.FightSystem.FightRole.CharacterBuff.BuffContext.BuffEffectHurtArray"):create()

    self.__oneOffEffectAnimDict = {}

    self:__systemInit(systemConfig)

    self.__finishCallback = isImplement(finishCallback, require("app.FightSystem.Fight.FightFinishCallback"))

    return self
end

function Fight:__systemInit(systemConfig)
    local basicConfig = require("app.FightSystem.Fight.SystemConfig.BasicBattleSystemConfig")

    local getBasicConfigPath = function(name)
        return basicConfig.systemMap[name]
    end

    local getSystemConfigPath = function(name)
        return systemConfig.systemMap[name]
    end

    local getConfig = function(name)
        local path = getSystemConfigPath(name)
        if path == nil then
            path = getBasicConfigPath(name)
        end

        return path
    end

    self:addFightSystem(require(getConfig("characterSystem")):create())
    self:addFightSystem(require(getConfig("fightActionQueuesSystem")):create())
    self:addFightSystem(require(getConfig("finishStrategy")):create())
end

function Fight:setFightOutput(fightOutput)
    --@RefType [FightMainView]
    self.__fightOutput = fightOutput
end

function Fight:getCurrentFrameIndex()
    return self.__updater:getLogicIndex()
end

function Fight:setPlayerId(id)
    self.__playerId = id
end

function Fight:getPlayerId()
    return self.__playerId
end

function Fight:setLogicIndex(index)
    self.__logicIndex = index
end

function Fight:start(updater)
    --@RefType [src.app.FightSystem.Updater.LocalUpdater#LocalUpdater]
    self.__updater = updater

    self.__updater:setFight(self)

    self:__walkAllSystems(
        function(system)
            -- @RefType [src.app.FightSystem.Fight.BasicBattleSystem.AFightSystem#AFightSystem]
            system = system
            system:fightInit()
        end
    )

    for i, v in ipairs(self:getCharacters()) do
        v:startFight()
    end

    if self.__fightOutput then
        self.__updater:setView(self.__fightOutput)
        self.__fightOutput:showFightStart(
            self,
            self.__updater:isOnline(),
            function()
                self:__start()
            end
        )
    else
        self.__start()
    end
end

function Fight:__start()
    self.__stateMachine:changeState(FightStateMachine.STATE_TYPES.ENTER)

    self.__updater:startFight()
end

function Fight:changeFightState(state)
    if table.keyof(FightStateMachine.STATE_TYPES, state) == nil then
        error("Fight:changeFightState : args-【state】 error " .. tostring(state))
    end

    self.__stateMachine:changeState(state)
end

-- @desc: 战斗结束
-- @author:Seven
-- @time:2022-06-22 15:11:47
function Fight:fightEnd()
    if self.__finishCallback then
        self.__finishCallback:runFinish(self)
    end

    self:__walkAllSystems(
        function(system)
            --@RefType [src.app.FightSystem.Fight.BasicBattleSystem.AFightSystem#AFightSystem]
            -- local system = system
            system:fightFinish()
        end
    )

    self.__updater:fightEnd()

    self:destory()
end
function Fight:destory()
    if self.__finishCallback then
        self.__finishCallback:runDestoryFunc()
    end

    self.__updater:destory()

    self.__handle = nil
end

-- @desc: 添加战斗系统
-- @author:Seven
-- @time:2022-06-22 14:29:22
--@system: [src.app.FightSystem.Fight.BasicBattleSystem.AFightSystem#AFightSystem]
function Fight:addFightSystem(system)
    local IFightSystem = require("app.FightSystem.Fight.BasicBattleSystem.IFightSystem")
    table.insert(self.__systems, isImplement(system, IFightSystem))

    system:setFight(self)
end

-- @desc: 获取战斗相关系统
-- @author:Seven
-- @time:2022-06-22 17:27:58
-- @name: 系统名称
-- @return: [src.app.FightSystem.Fight.BasicBattleSystem.AFightSystem#AFightSystem]
function Fight:getFightSystem(name)
    local count = table.getn(self.__systems)
    for i = 1, count do
        local system = self.__systems[i]
        if system:getName() == name then
            return system
        end
    end
end

function Fight:__walkAllSystems(func)
    local count = table.getn(self.__systems)
    for i = 1, count do
        func(self.__systems[i])
    end
end

--@region 角色相关

-- @desc: 添加角色
-- @author:Seven
-- @time:2022-06-22 15:28:28
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function Fight:addCharacter(character)
    self:getFightSystem(CharacterSystem.SYSTEM_NAME):addCharacter(character:getTeamId(), character)
    character:setFight(self)
end

-- @desc: 获取角色
-- @author:Seven
-- @time:2022-06-23 15:19:44
--@characterId: 角色id
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function Fight:getCharacter(characterId)
    return self:getFightSystem(CharacterSystem.SYSTEM_NAME):getCharacter(characterId)
end

--@desc: 获取所有角色
--@author:Seven
--@time:2023-03-02 20:20:32
function Fight:getCharacters()
    return self:getFightSystem(CharacterSystem.SYSTEM_NAME):getCharacters()
end

function Fight:checkAndAllocTarget()
    return self:getFightSystem(CharacterSystem.SYSTEM_NAME):checkAndAllocTarget()
end

--@desc: 角色死亡
--@author:Seven
--@time:2023-03-02 20:21:17
--@c_id: 角色id
function Fight:charaterDead(c_id)
    return self:getFightSystem(FightActionQueuesSystem.SYSTEM_NAME):characterDead(c_id)
end

--@desc: 获取所有队伍
--@author:Seven
--@time:2023-03-02 20:20:49
function Fight:getTeams()
    return self:getFightSystem(CharacterSystem.SYSTEM_NAME):getTeams()
end

--@desc: 获取队友
--@author:Seven
--@time:2022-07-01 17:25:01
--@characterId: 角色id
--@return: []
function Fight:getTeammates(characterId)
    return self:getFightSystem(CharacterSystem.SYSTEM_NAME):getTeammates(characterId)
end

--@desc: 获取队伍所有成员
--@author:Seven
--@time:2022-07-02 14:55:42
--@teamId: 队伍ID
--@return: []
function Fight:getTeamCharacters(teamId)
    return self:getFightSystem(CharacterSystem.SYSTEM_NAME):getTeamCharacters(teamId)
end

--@desc: 获取攻击目标
--@author:Seven
--@time:2023-02-27 22:09:10
--@characterId: 角色id
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function Fight:getAttackTarget(characterId)
    return self:getFightSystem(CharacterSystem.SYSTEM_NAME):getAttackTarget(characterId)
end

--@desc: 获取对手队伍
--@author:Seven
--@time:2023-03-02 17:07:23
--@characterId: 角色id
--@return [src.app.FightSystem.CharacterSystem.CharacterTeam#CharacterTeam]
function Fight:getTargetTeam(characterId)
    return self:getFightSystem(CharacterSystem.SYSTEM_NAME):getTargetTeam(characterId)
end

--@desc: 角色进入战场等待列表
--@author:Seven
--@time:2023-02-05 15:57:45
function Fight:getWaitingEnterCharacters()
    return self:getFightSystem(CharacterSystem.SYSTEM_NAME):getWaitingEnterCharacters()
end

--@desc: 移除等待进入战场的角色
--@author:Seven
--@time:2023-02-05 15:58:00
--@c_id: 角色id
function Fight:removeWaitingEnterCharacter(c_id)
    return self:getFightSystem(CharacterSystem.SYSTEM_NAME):removeWaitingEnterCharacter(c_id)
end
--@endregion

--@region 攻击队列
function Fight:characterApplyAutoAttack(c_id)
    if self:getFightSystem(FightActionQueuesSystem.SYSTEM_NAME):hasCharacterAutoAttackAction(c_id) then
        return false
    end

    local action = require("app.FightSystem.FightActions.AutoAttackAction"):create():init(c_id, self.__logicIndex, self)

    self:getFightSystem(FightActionQueuesSystem.SYSTEM_NAME):pushCharacterAutoAttackAction(action)
end

--@desc: 获取被动攻击招式
--@author:Seven
--@time:2023-02-05 16:56:50
--@return: [src.app.FightSystem.FightActions.AutoAttackAction#AutoAttackAction]
function Fight:getAutoAttackAction()
    return self:getFightSystem(FightActionQueuesSystem.SYSTEM_NAME):getAutoAttackAction()
end

--@desc: 获取当前操作命令队列中的第一个操作命令
--@author:Seven
--@time:2023-12-21 16:37:49
--@return [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
function Fight:getFirstOperationCommand()
    return self:getFightSystem(FightActionQueuesSystem.SYSTEM_NAME):getFirstOperationCommand()
end

--@desc: 弹出操作命令队列中的第一个操作命令
--@author:Seven
--@time:2023-12-21 16:39:08
--@return [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
function Fight:popFirstOperationCommand()
    return self:getFightSystem(FightActionQueuesSystem.SYSTEM_NAME):popFirstOperationCommand()
end

--@desc: 添加玩家操作
--@author:Seven
--@time:2022-10-31 14:36:52
--@o_type: 操作类型
--@args: 操作参数
function Fight:pushCharacterOperationAction(o_type, c_id, args)
    local FightCommons = require("app.FightSystem.FightCommons")

    if table.keyof(FightCommons.CHARACTER_OPERATION_TYPE, o_type) == nil then
        error("Fight:pushCharacterOperationAction : args-【o_type】 error " .. tostring(o_type))
    end
    local OperationCommandFactory = require("app.FightSystem.FightActions.OperationCommands.Factory.OperationCommandFactory")

    local operationCommand = OperationCommandFactory:createOperationCommand(self, o_type, c_id, args)

    self:getFightSystem(FightActionQueuesSystem.SYSTEM_NAME):addOperationCommand(operationCommand)
end

--@endregion

function Fight:sendOperationMesaage(c_id, o_type, args)
    self.__updater:sendPlayerPrepOperation(
        {
            c_id = c_id,
            o_type = o_type,
            args = args
        }
    )
end

function Fight:__fightReport()
    local data = {
        frame = self.__logicIndex,
        playersStatus = {}
    }

    local playerTeamId = self:getCharacter(self:getPlayerId()):getTeamId()

    local targetTeamId = self:getCharacter(self:getPlayerId()):getTarget():getTeamId()

    data.winner =
        switch(
        self:getFightFinishResult(),
        {
            [FightCommons.FINISH_STATE.WIN] = function()
                return playerTeamId
            end,
            [FightCommons.FINISH_STATE.RUNAWAY] = function()
                return targetTeamId
            end,
            [FightCommons.FINISH_STATE.LOSE] = function()
                return targetTeamId
            end,
            [FightCommons.FINISH_STATE.NO_WINNER] = "-1",
            ["default"] = function()
                error("Fight:fightFinishReport : 未知的战斗结果")
            end
        }
    )

    local characters = self:getCharacters()
    for _, character in ipairs(characters) do
        table.insert(
            data.playersStatus,
            {
                uid = character:getId(),
                qi = character:getAttr("qi"),
                qiMax = character:getAttr("qiMax"),
                neili = character:getAttr("neili")
            }
        )
    end

    if self.__updater:isOnline() then
        self.__updater:sendData("fight_finish", data)
    else
        FightUtil:printLog("战斗结束报告，如下：")
        Helper:print_lua_table(data)
    end
end

function Fight:fightFinish()
    self:__fightReport()
    self.__updater:finish()
end

function Fight:putCurrentFrameData(frameData)
    self.__frameMessageQueue:putCurrentFrameData(frameData)
end

function Fight:update(ft)
    -- --@desc 处理上一帧玩家发送的信息
    self.__frameMessageQueue:handleCurrFrameData()
    self.__stateMachine:updateSystem(ft)
end

--@desc: 获取战斗是否结束
--@author:Seven
--@time:2023-03-02 17:40:29
--@return true | false
function Fight:checkFightIsFinish()
    return self:getFightSystem(AFinishStrategy.SYSTEM_NAME):checkBattaleFinish()
end

--@desc: 获取战斗结果
--@author:Seven
--@time:2023-03-02 17:41:09
function Fight:getFightFinishResult()
    return self:getFightSystem(AFinishStrategy.SYSTEM_NAME):getFinishResult()
end

--@desc: 获取战斗结果文本
--@author:Seven
--@time:2023-03-02 18:08:09
function Fight:getFightFinishResultTexts()
    return self:getFightSystem(AFinishStrategy.SYSTEM_NAME):getResultText()
end

--@desc: 输出战斗结果视图
--@author:Seven
--@time:2023-03-02 19:37:28
--@texts: 战斗结果文本
function Fight:outputFightFinish(texts)
    if self.__fightOutput then
        self.__fightOutput:showfinishFightView(texts)
    end
end

--@desc: 通知界面切换攻击目标
--@author:Seven
--@time:2022-07-04 11:29:39
--@characterId: 角色ID
--@targetId: 切换的目标id
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function Fight:outputSwitchAttackTarget(characterId, targetId)
    if self:getPlayerId() == characterId then
        local targetTeamates = self:getTeammates(targetId)

        local list = {targetId}
        if table.getn(targetTeamates) > 0 then
            for i, v in ipairs(targetTeamates) do
                table.insert(list, v:getId())
            end
        end

        self:notifyVeiwEvent(require("app.FightSystem.Veiws.ViewEvents.Events.PlayerSwitchAttackTargetViewEvent"):create(characterId, targetId, self))
    end
end

function Fight:removeCharacterAllOperation(characterId)
    self:getFightSystem(FightActionQueuesSystem.SYSTEM_NAME):removeAllCharacterOperation(characterId)
end

--@desc: 通知视图执行事件
--@author:Seven
--@time:2023-10-27 11:03:55
--@event: [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
function Fight:notifyVeiwEvent(event)
    if self.__fightOutput then
        self.__fightOutput:addViewEvent(event)
    end
end

function Fight:popText(msg)
    self:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.MessagePopViewEvent":create(msg))
end

function Fight:showPrintText(msg)
    self:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.MessageShowPrintViewEvent":create(msg))
end

--@region IBuffContext 接口实现

--@desc: 添加buff效果造成的伤害
--@author:Seven
--@time:2023-11-22 17:04:09
--@effectHurt: [src.app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr#BasicBuffEffectModifierAttr]
function Fight:addBuffEffectHurt(effectHurt)
    self.__buffEffectHurtArray:addHurt(effectHurt)
end

--@desc: 弹出所有buff效果造成的伤害
--@author:Seven
--@time:2023-11-22 17:06:51
function Fight:walkBuffEffcetHurts(func)
    for effectHurt in self.__buffEffectHurtArray:getIterator() do
        if func(effectHurt) == true then
            break
        end
    end
end

function Fight:clearBuffEffectHurts()
    self.__buffEffectHurtArray:clear()
end

--@desc: 添加一次性特效
--@author:Seven
--@time:2023-11-22 17:08:38
--@animEventName: 动画触发事件名
--@animId:特效动画id
--@ownerId: 特效目标
--@return:
function Fight:addOneOffEffect(animEventName, animId, targetId)
    if self.__oneOffEffectAnimDict[animEventName] == nil then
        self.__oneOffEffectAnimDict[animEventName] = {}
    end

    table.insert(
        self.__oneOffEffectAnimDict[animEventName],
        {
            animId = animId,
            targetId = targetId
        }
    )
end

--@desc: 弹出所有一次性特效数据
--@author:Seven
--@time:2023-11-22 17:13:16
--@return: array
function Fight:popOneOffEffects(animEventName)
    local oneOffEffects = self.__oneOffEffectAnimDict[animEventName]

    self.__oneOffEffectAnimDict[animEventName] = nil

    return Helper:getDef(oneOffEffects, {})
end

function Fight:clearOneOffEffects()
    self.__oneOffEffectAnimDict = {}
end

function Fight:recordAddBuffDesc(desc)
    if self.__buffAddDescArray == nil then
        self.__buffAddDescArray = {}
    end

    table.insert(self.__buffAddDescArray, desc)
end

function Fight:showAndClearAddBuffDesc()
    if self.__buffAddDescArray == nil then
        return
    end

    for i, v in ipairs(self.__buffAddDescArray) do
        self:showPrintText(v)
    end

    self.__buffAddDescArray = nil
end

function Fight:recordDeleteDesc(desc)
    if self.__buffDeleteDescArray == nil then
        self.__buffDeleteDescArray = {}
    end

    table.insert(self.__buffDeleteDescArray, desc)
end

function Fight:showAndClearDeleteBuffDesc()
    if self.__buffDeleteDescArray == nil then
        return
    end

    for i, v in ipairs(self.__buffDeleteDescArray) do
        self:showPrintText(v)
    end

    self.__buffDeleteDescArray = nil
end
--@endregion

return newClass("Fight", {IBuffContext}, Fight)
000000000000000