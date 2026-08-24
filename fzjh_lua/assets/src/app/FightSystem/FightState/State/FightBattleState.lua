--[[
    author:Seven
    time:2022-06-23 16:30:41
    desc: 对战状态
]]
local newClass = require("third.class.NewClass")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local AttackBattleAction = require("app.FightSystem.BattleActions.AttackBattleAction")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [src.app.FightSystem.FightState.FightStateMachine#FightStateMachine]
local FightStateMachine = require("app.FightSystem.FightState.FightStateMachine")

local AFightState = require("app.FightSystem.FightState.State.AFightState")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")
local log = function(...)
    FightUtil:printLog("FightBattleState ：", ...)
end

--@SuperType [src.app.FightSystem.FightState.State.AFightState#AFightState]
local FightBattleState = {
    --@desc 行动者id
    __actionCharacterId = nil
}

function FightBattleState:create()
    return FightBattleState.new()
end

function FightBattleState:ctor()
end

function FightBattleState:onInitState()
end

function FightBattleState:onDestoryState()
end

function FightBattleState:onEnterState()
    self.__characters = self.__fight:getCharacters()
end

function FightBattleState:onExitState()
end

function FightBattleState:onUpdateState(ft)
    --@desc 先销毁已完成的攻击
    if self.__finishBattleAction then
        self.__finishBattleAction:destory()
    end

    --@desc 攻击刷新
    if self.__attackBattleAction then
        if not self.__attackBattleAction:isStart() then
            self.__attackBattleAction:start()
        end

        self.__attackBattleAction:update(ft)

        if self.__attackBattleAction:isFinish() then
            self.__finishBattleAction = self.__attackBattleAction
            self.__attackBattleAction = nil
            self.__actionCharacterId = nil

            --@desc 是否结束战斗
            if self.__fight:checkFightIsFinish() then
                return self.__fight:changeFightState(FightStateMachine.STATE_TYPES.FINISH)
            else
                --@desc 检查攻击角色分配
                self.__fight:checkAndAllocTarget()
            end
        end
    else
        --@desc 是否结束战斗
        if self.__fight:checkFightIsFinish() then
            return self.__fight:changeFightState(FightStateMachine.STATE_TYPES.FINISH)
        end
    end

    --@desc 检查并生成攻击动作
    self:__checkAndInitAttackAction()

    --@desc 战斗中角色系统刷新
    for i, character in ipairs(self.__characters) do
        character:update(ft)

        character:aiCheckAndRelease()

        if not character:isDead() and not character:autoAttackIsBan() and character:getAttr("tili") >= BattleConstConf:get("autoUseSkillTili") then
            if self.__actionCharacterId == nil or self.__actionCharacterId ~= character:getId() then
                --@desc 角色可以出手，申请进入攻击队列
                if self.__fight:characterApplyAutoAttack(character:getId()) then
                    log(character:getAttr("name") .. "申请进入被动攻击队列")
                end
            end
        end
    end
end

function FightBattleState:__checkAndInitAttackAction()
    if self.__attackBattleAction ~= nil then
        --@desc 已有攻击动作
        return
    end

    --@desc 玩家操作动作流程生成
    local operationCommand = self.__fight:popFirstOperationCommand()
    if operationCommand ~= nil then
        local canDo, failMsg = operationCommand:canDoOperationCommand(self.__fight)
        if canDo then
            self.__actionCharacterId = operationCommand:getCommanderId()

            local AttackBattleActionUtil = require("app.FightSystem.BattleActions.AttackBattleAction.AttackBattleActionUtil")

            self.__attackBattleAction = AttackBattleAction:create(AttackBattleActionUtil:createAttackBattleActionFromOperationCommand(operationCommand, self.__fight))

            self.__attackBattleAction:init(self.__fight)

            self.__fight:notifyVeiwEvent(
                require("app.FightSystem.Veiws.ViewEvents.Events.CharacterOperationRemoveViewEvent"):create(operationCommand:getCommanderId(), operationCommand:getOperationCommandId(), true)
            )

            return
        else
            if operationCommand:getCommanderId() == self.__fight:getPlayerId() and #failMsg > 0 then
                self.__fight:popText(failMsg)
            end
            self.__fight:notifyVeiwEvent(
                require("app.FightSystem.Veiws.ViewEvents.Events.CharacterOperationRemoveViewEvent"):create(operationCommand:getCommanderId(), operationCommand:getOperationCommandId(), false)
            )
        end
    end

    while true do
        local autoAction = self.__fight:getAutoAttackAction()
        if autoAction ~= nil then
            local canRelease, failMsg = autoAction:checkPreRelease()
            if canRelease == true then
                self.__actionCharacterId = autoAction:getCharacterId()

                self.__attackBattleAction = AttackBattleAction:create(autoAction:getAndDoAttackAction())

                self.__attackBattleAction:init(self.__fight)

                break
            else
                if autoAction:getCharacterId() == self.__fight:getPlayerId() then
                    if failMsg ~= nil and failMsg ~= "" then
                        self.__fight:popText(failMsg)
                    end
                end
            end
        else
            break
        end
    end
end

return newClass("FightBattleState", {AFightState}, FightBattleState)
00000000