--[[
    author:Seven
    time:2023-03-02 16:28:06
    desc: 战斗结束策略抽象类
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local CharacterTeam = require("app.FightSystem.CharacterSystem.CharacterTeam")

local AFightSystem = require("app.FightSystem.Fight.BasicBattleSystem.AFightSystem")

--@SuperType [src.app.FightSystem.Fight.BasicBattleSystem.AFightSystem#AFightSystem]
local AFinishStrategy = {}

AFinishStrategy.SYSTEM_NAME = "finishStrategy"

local log = function(...)
    FightUtil:printLog("AFinishStrategy : ", ...)
end

function AFinishStrategy:ctor()
    self.__name = AFinishStrategy.SYSTEM_NAME
end

function AFinishStrategy:onInit()
end

function AFinishStrategy:onRun()
end

function AFinishStrategy:onEnter()
end

function AFinishStrategy:onStart()
end

function AFinishStrategy:onFinish()
end

--@desc: 战斗是否结束
--@author:Seven
--@time:2023-03-02 16:30:22
function AFinishStrategy:fightIsFinish()
    error("AFinishStrategy:fightIsFinish 重写该方法")
end

return newClass("AFinishStrategy", {AFightSystem}, AFinishStrategy)
000000000