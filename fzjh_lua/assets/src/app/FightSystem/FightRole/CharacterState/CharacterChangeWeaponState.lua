local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")
--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local CharacterChangeWeaponState = {
    __state_type = CHARACTER_STATE.IDLE,
    __duration = 0
}

function CharacterChangeWeaponState:initTriggerMap()
    self.__transitionDicts = {}
end

function CharacterChangeWeaponState:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name"), "进入易武状态")

    self.__character:changeStandbyWeapon()

    local weapon = self.__character:getWeapon()

    local animName = AnimResManager:getOtherAnimNameByWeapon(BattleConstConf:get("battleAction_changeWeapon_animRes"), weapon:getWeaponModule())

    self.__duration = AnimResManager:getAnimTime(animName)

    self.__elapsed = 0

    self.__character:startAction()

    self.__character:aftChangeStandbyWeapon(animName, weapon)
end

function CharacterChangeWeaponState:onLeave()
    FightUtil:printLog(self.__character:getAttr("name"), "退出易武状态")
end

function CharacterChangeWeaponState:onUpdate(ft)
    if self.__elapsed >= self.__duration then
        self.__character:changeState(CHARACTER_STATE.IDLE, nil)
        self.__character:finishAction()
        return
    end

    self.__elapsed = self.__elapsed + ft
    FightUtil:printLog(self.__character:getAttr("name"), "播放易武动画中 , 用时: ", self.__elapsed, "/", self.__duration)
end

return class("CharacterChangeWeaponState", {ACharacterState}, CharacterChangeWeaponState)
0000000000