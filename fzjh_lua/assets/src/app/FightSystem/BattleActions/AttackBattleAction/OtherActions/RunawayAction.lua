--[[
    author:Seven
    time:2023-03-02 16:13:12
    desc: 逃跑
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local FightFormula = require("app.FightSystem.FightFormula")

local FightCommons = require("app.FightSystem.FightCommons")

local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local RunawayAction = {}

function RunawayAction:create(characterId)
    return RunawayAction.new():__init(characterId)
end

function RunawayAction:__init(characterId)
    self.__characterId = characterId
    return self
end

function RunawayAction:onInit()
    FightUtil:printLog("RunawayAction:onInit 逃跑初始化")

    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = self.__fight:getCharacter(self.__characterId)
end

function RunawayAction:onStart()
    self.__character:doRunawayFunc()

    self.__fight:removeCharacterAllOperation(self.__character:getId())


    self:finish()
end

function RunawayAction:onFinish()
    FightUtil:printLog("RunawayAction:onFinish 逃跑动作结束")
end

function RunawayAction:onDestory()
end

function RunawayAction:onUpdate(ft)
    -- if self.__elapsedTime >= self.__duration then
    --     self:finish()
    --     return
    -- end
    -- self.__elapsedTime = self.__elapsedTime + ft
end

function RunawayAction:getNextBattleAction()
    return nil
end

return newClass("RunawayAction", {ABaseBattleAction}, RunawayAction)
000