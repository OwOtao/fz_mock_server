local class = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local CharacterStateMachine = {
    --@desc 状态机拥有者
    __character = nil,
    --@desc 当前状态
    __state = nil
}

function CharacterStateMachine:create(character)
    local p = self.new()

    p:init(character)

    return p
end

function CharacterStateMachine:init(character)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__character = character

    --@RefType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
    self.__state = nil
end

function CharacterStateMachine:getCurrentState()
    return self.__state
end

function CharacterStateMachine:getCurrStateType()
    return self.__state:getType()
end

function CharacterStateMachine:trigger(event)
    if self.__state == nil then
        assert(false, "角色当前没有状态，请检查代码。")
        return
    end

    self.__state:triggerEvent(event)
end

function CharacterStateMachine:changeState(state_type, params)
    if self.__state then
        self.__state:onLeave()
    end

    local state_class
    if state_type == CHARACTER_STATE.READY then
        state_class = require("app.FightSystem.FightRole.CharacterState.CharacterReayState")
    elseif state_type == CHARACTER_STATE.JOINING then
        state_class = require("app.FightSystem.FightRole.CharacterState.CharacterJoiningState")
    elseif state_type == CHARACTER_STATE.IDLE then
        state_class = require("app.FightSystem.FightRole.CharacterState.CharacterIdleState")
    elseif state_type == CHARACTER_STATE.DEAD then
        state_class = require("app.FightSystem.FightRole.CharacterState.CharacterDeadState")
    elseif state_type == CHARACTER_STATE.RUNAWAY then
        state_class = require("app.FightSystem.FightRole.CharacterState.CharacterRunawayState")
    elseif state_type == CHARACTER_STATE.AUTO_SKILL_JUMPFORWAR then
        state_class = require("app.FightSystem.FightRole.CharacterState.AutoSkillAttackStates.AutoAttackJumpForwardState")
    elseif state_type == CHARACTER_STATE.AUTO_SKILL_JUMPBACK then
        state_class = require("app.FightSystem.FightRole.CharacterState.AutoSkillAttackStates.AutoAttackJumpBackState")
    elseif state_type == CHARACTER_STATE.AUTO_SKILL_ATTACK then
        state_class = require("app.FightSystem.FightRole.CharacterState.AutoSkillAttackStates.AutoAttackState")
    elseif state_type == CHARACTER_STATE.AUTO_SKILL_ATTACK_END then
        state_class = require("app.FightSystem.FightRole.CharacterState.AutoSkillAttackStates.AutoAttackEndState")
    elseif state_type == CHARACTER_STATE.ACTIVE_SKILL_JUMPFORWARD then
        state_class = require("app.FightSystem.FightRole.CharacterState.ActiveSkillAttackStates.ActiveAttackJumpForward")
    elseif state_type == CHARACTER_STATE.ACTIVE_SKILL_JUMPBACK then
        state_class = require("app.FightSystem.FightRole.CharacterState.ActiveSkillAttackStates.ActiveAttackJumpBackState")
    elseif state_type == CHARACTER_STATE.ACTIVE_SKILL_READY then
        state_class = require("app.FightSystem.FightRole.CharacterState.ActiveSkillAttackStates.ActiveAttackReadyState")
    elseif state_type == CHARACTER_STATE.ACTIVE_SKILL_ATTACK then
        state_class = require("app.FightSystem.FightRole.CharacterState.ActiveSkillAttackStates.ActiveAttackState")
    elseif state_type == CHARACTER_STATE.ACTIVE_SKILL_ATTACK_END then
        state_class = require("app.FightSystem.FightRole.CharacterState.ActiveSkillAttackStates.ActiveAttackEndState")
    elseif state_type == CHARACTER_STATE.RECOVER_QI then
        state_class = require("app.FightSystem.FightRole.CharacterState.CharacterRecoverQiState")
    elseif state_type == CHARACTER_STATE.CHANGE_WEAPON then
        state_class = require("app.FightSystem.FightRole.CharacterState.CharacterChangeWeaponState")
    else
        assert(false, "角色状态未定义 ： " .. state_type)
    end

    self.__state = state_class:create(self.__character, self)

    self.__state:onEnter(params)
end

function CharacterStateMachine:update(ft)
    if self.__state ~= nil then
        self.__state:onUpdate(ft)
    end
end

return class("CharacterStateMachine", {}, CharacterStateMachine)
000000000000000