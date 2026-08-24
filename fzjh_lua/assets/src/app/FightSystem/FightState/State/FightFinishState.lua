--[[
    author:Seven
    time:2022-06-23 17:19:42
    desc: 战斗结束状态
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AFightState = require("app.FightSystem.FightState.State.AFightState")

--@SuperType [src.app.FightSystem.FightState.State.AFightState#AFightState]
local FightFinishState = {}

function FightFinishState:create()
    return FightFinishState.new()
end

function FightFinishState:ctor()
end

function FightFinishState:onInitState()
end

function FightFinishState:onDestoryState()
end

function FightFinishState:onEnterState()
    FightUtil:printLog("战场进入结束状态")

    local finishTexts = self.__fight:getFightFinishResultTexts()

    self.__fight:notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.FightFinishViewEvent":create(finishTexts))

    self.__fight:fightFinish()
end

function FightFinishState:onExitState()
end

function FightFinishState:onUpdateState(ft)
end

return newClass("FightFinishState", {AFightState}, FightFinishState)
000000