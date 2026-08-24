--[[
    动画站立状态
]]
local class = require("third.class.NewClass")

local BaseCharacterUIState = require("app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_UI_STATE = FightCommons.CHARACTER_UI_STATE

local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

--@SuperType [src.app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState#BaseCharacterUIState]
local AttackState = {
    __stateType = CHARACTER_UI_STATE.ATTACK,
    __attackUIState = nil
}

function AttackState:onInit()
    --@desc 目标UI控制器
    self.__targetCtrl = nil

    --@desc 受击目标原始位置
    self.__targetOriPos = nil

    --@desc 攻击方向 1（目标在右） | -1（目标在左）
    self.__dir = 1

    --@desc 攻击者初始位置
    self.__atkerOriPos = nil

    --@desc 此次攻击对应的攻击招式
    --@RefType[src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack#IZhaoAttack]
    self.__zhaoAtk = nil

    --@desc 第几次击中
    self.__hurtIndex = 1
end

function AttackState:__initAttackUIState(zhaoAtkHurtType)
    --@RefType [src.app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState#BaseCharacterUIState]
    local state = nil
    if zhaoAtkHurtType == ATTACK_HIT_TYPE.NONE then
        state = require("app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.NoneAttackState"):create()
    elseif zhaoAtkHurtType == ATTACK_HIT_TYPE.HIT then
        state = require("app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.HitAttackState"):create()
    elseif zhaoAtkHurtType == ATTACK_HIT_TYPE.PARRY then
        state = require("app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.NormalParryAttackState"):create()
    elseif zhaoAtkHurtType == ATTACK_HIT_TYPE.DODGE or zhaoAtkHurtType == ATTACK_HIT_TYPE.DODGE_SPC then
        state = require("app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.DodgeAttackState"):create()
    elseif zhaoAtkHurtType == ATTACK_HIT_TYPE.PARRY_SPEC then
        state = require("app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.ParryAttackState"):create()
    end

    state:setCharacterUICtrl(self.__ctrl)

    state:setAnimName(self.__animName)

    return state
end

function AttackState:onEnter(params)
    self.__zhaoAtk = params.zhaoAtk

    --@RefType [src.app.FightSystem.UICtrl.UI.CharacterUIState.ICharacterUIState#ICharacterUIState]
    self.__attackUIState = self:__initAttackUIState(self.__zhaoAtk:getHurtType())

    self.__attackUIState:onInit()

    self.__attackUIState:onEnter(params)
end

function AttackState:onLeave()
    self.__attackUIState:onLeave()
end

function AttackState:onUpdate(ft)
    self.__attackUIState:onUpdate(ft)
end

return class("AttackState", {BaseCharacterUIState}, AttackState)
0000000000