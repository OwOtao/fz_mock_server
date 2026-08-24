--[[
    author:Seven
    time:2022-06-23 16:30:41
    desc: 战场准备状态
]]
local newClass = require("third.class.NewClass")

local AFightState = require("app.FightSystem.FightState.State.AFightState")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightState.State.AFightState#AFightState]
local FightReadyState = {}

function FightReadyState:create()
    return FightReadyState.new()
end

function FightReadyState:ctor()
end

function FightReadyState:onInitState()
end

function FightReadyState:onDestoryState()
end

function FightReadyState:onEnterState()
    FightUtil:printLog("战场进入准备状态")
end

function FightReadyState:onExitState()
    FightUtil:printLog("战场退出准备状态")
end

function FightReadyState:onUpdateState(ft)
end

return newClass("FightReadyState", {AFightState}, FightReadyState)
000