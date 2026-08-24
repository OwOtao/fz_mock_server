--[[
    author:Seven
    time:2023-02-28 20:46:39
    desc: 气血恢复
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local FightFormula = require("app.FightSystem.FightFormula")

local FightCommons = require("app.FightSystem.FightCommons")

local FightDesc = require("app.FightSystem.FightUtil.FightDesc")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@RefType [Constants]
local BUFF_CONSTANT = require("app.FightSystem.FightBuff.Constants")
local BUFF_ADDER_TRIGGER_TYPE = BUFF_CONSTANT.ADDER_TRIGGER_TYPE
local ADD_BUFF_NODE_TYEP = BUFF_CONSTANT.ADD_BUFF_NODE_TYEP
local BUFF_EFFECT_ON_TYPE = BUFF_CONSTANT.BUFF_MAKE_EFFECT_ON_NODE_TYPE

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local RecoverQiAction = {}

function RecoverQiAction:create(characterId)
    return RecoverQiAction.new():__init(characterId)
end

function RecoverQiAction:__init(characterId)
    self.__characterId = characterId
    return self
end

function RecoverQiAction:onInit()
    FightUtil:printLog("RecoverQiAction:onInit 气血恢复初始化")

    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = self.__fight:getCharacter(self.__characterId)
end

function RecoverQiAction:onStart()
    self.__elapsedTime = 0

    local recoverQi = self.__character:getRecoverQi()

    local cdTime = recoverQi:getCoolDownTime()

    recoverQi:setCD(cdTime)

    local costList = recoverQi:getAttrCost()

    for i = 1, table.getn(costList) do
        local info = costList[i]
        local attrName = info.attrName
        if attrName == "neili" then
            self.__character:consumeNeili(info.value)
        else
            self.__character:addAttr(attrName, -value)
        end
        FightUtil:printLog(string.format(" - 消耗：%s - %s", FightUtil:getCharacterAttrCHName(attrName), info.value))
    end

    local neiliMax = self.__character:getAttr("neiliMax")

    local healthyQi = self.__character:getAttr("healthyQi")

    local healReduceqi = self.__character:getAttr("healReduceqi")

    local healReduceqiSXBH = self.__character:getAttr("healReduceqiSXBH")

    local value = FightFormula:calReocverQiValue(neiliMax, healthyQi, healReduceqi, healReduceqiSXBH)

    self.__character:addAttr("qi", value)

    FightUtil:printLog(string.format("角色(%s)释放【恢复】：%s", self.__character:getAttr("name"), value))

    local animName = AnimResManager:getOtherAnimName(BattleConstConf:get("battleAction_healthy_animRes"))

    local textValue = Helper:mathFloor(value)

    local animTime = AnimResManager:getAnimTime(animName)
    self.__fight:notifyVeiwEvent(require "src.app.FightSystem.Veiws.ViewEvents.Events.CharacterPopHeadTextViewEvent":create(self.__character:getId(), "HIG+" .. textValue))
    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.CharacterPlayAnimViewEvent":create(self.__character:getId(), animName, true))

    --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
    local printText = FightDesc:create()
    printText:setText(TextResManager:getText("1100"))
    printText:setAttacker(self.__character)
    printText:setHurtValue(textValue)
    self.__fight:showPrintText(printText:getString())

    self.__duration = animTime

    self.__character:makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnUseQiRecoverAction)
    self.__character:tryRemoveBuffs()
    self.__character:updateSelfAlive()
end

function RecoverQiAction:onFinish()
    self.__character:updateViews()
    FightUtil:printLog("RecoverQiAction:onFinish 气血恢复动作结束")
end

function RecoverQiAction:onDestory()
end

function RecoverQiAction:onUpdate(ft)
    if self.__elapsedTime >= self.__duration then
        self:finish()
        return
    end
    self.__elapsedTime = self.__elapsedTime + ft
end

function RecoverQiAction:getNextBattleAction()
    return nil
end

return newClass("RecoverQiAction", {ABaseBattleAction}, RecoverQiAction)
0