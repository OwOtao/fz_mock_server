--[[
    author:Seven
    time:2022-06-21 16:25:07
    desc: 战斗系统抽象类
]]
local abstract = require("third.class.abstract")

local interface = require("third.class.interface")

local IFightSystem = require("app.FightSystem.Fight.BasicBattleSystem.IFightSystem")

local FightCommons = require("app.FightSystem.FightCommons")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")
local log = function(msg, ...)
    FightUtil:printLog(string.format("FightSystem : " .. msg, ...))
end

--@SuperType [src.app.FightSystem.Fight.BattleSystem.AFightSystem#IFightSystem]
local AFightSystem = {}

function AFightSystem:setFight(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight
end

function AFightSystem:getName()
    if self.__name == nil then
        error("Fight system error ： 系统未命名")
    end

    return self.__name
end

function AFightSystem:fightInit()
    log("%s init start", self.__name)
    self:onInit()
    log("%s init finish", self.__name)
end

function AFightSystem:fightStart()
    log("%s fightStart start", self.__name)
    self:onStart()
    log("%s fightStart finish", self.__name)
end

function AFightSystem:fightFinish()
    log("%s fightFinish start", self.__name)
    self:onFinish()
    log("%s fightFinish finish", self.__name)
end

function AFightSystem:updateSystem(ft)
end

return abstract("AFightSystem", {IFightSystem}, AFightSystem)
000000000000