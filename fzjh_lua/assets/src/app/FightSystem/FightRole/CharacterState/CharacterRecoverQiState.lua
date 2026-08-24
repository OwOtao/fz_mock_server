local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local FightFormula = require("app.FightSystem.FightFormula")

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")
--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local CharacterRecoverQiState = {
    __state_type = CHARACTER_STATE.IDLE
}

function CharacterRecoverQiState:initTriggerMap()
    self.__transitionDicts = {}
end

function CharacterRecoverQiState:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name"), "进入气血恢复状态")
    local animName = AnimResManager:getOtherAnimName(BattleConstConf:get("battleAction_healthy_animRes"))

    self.__character:startAction()

    self.__duration = AnimResManager:getAnimTime(animName)

    self.__elapsed = 0

    local neiliMax = self.__character:getAttr("neiliMax")

    local healthyQi = self.__character:getAttr("healthyQi")

    local healReduceqi = self.__character:getAttr("healReduceqi")

    local value =  FightFormula:calReocverQiValue(neiliMax,healthyQi,healReduceqi)

    self.__character:recoverQi(animName, value)
end

function CharacterRecoverQiState:onLeave()
    FightUtil:printLog(self.__character:getAttr("name"), "退出气血恢复状态")
end

function CharacterRecoverQiState:onUpdate(ft)
    if self.__elapsed >= self.__duration then
        self.__character:changeState(CHARACTER_STATE.IDLE, nil)
        self.__character:finishAction()
        return
    end

    self.__elapsed = self.__elapsed + ft
    FightUtil:printLog(self.__character:getAttr("name"), "播放气血恢复动画中 , 用时: ", self.__elapsed, "/", self.__duration)
end

return class("CharacterRecoverQiState", {ACharacterState}, CharacterRecoverQiState)
0000000