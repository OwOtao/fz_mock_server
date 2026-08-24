--[[
    author:Seven
    time:2022-11-14 20:00:57
    desc: 战场行为 基础类
]]
local abstract = require("third.class.abstract")

local interface = require("third.class.interface")

local IBattleAction = {}

function IBattleAction:onInit()
end

function IBattleAction:onStart()
end

function IBattleAction:onFinish()
end

function IBattleAction:onDestory()
end

function IBattleAction:onUpdate(ft)
end

IBattleAction = interface("IBattleAction", IBattleAction)

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#IBattleAction]
local ABaseBattleAction = {
    __fight = nil,
    __isFinish = false,
    __isStart = false
}

function ABaseBattleAction:init(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight

    self:onInit()
end

function ABaseBattleAction:start()
    if self.__isStart == true then
        assert(false, "该Aciton已开始，请勿二次调用！")
    end

    self.__isStart = true

    self:onStart()
end

function ABaseBattleAction:update(ft)
    if self:isFinish() then
        return
    end

    self:onUpdate(ft)
end

function ABaseBattleAction:finish()
    if self.__isFinish == true then
        assert(false, "该Aciton已经完成，请勿二次调用！")
    end

    self.__isFinish = true
    self:onFinish()
end

function ABaseBattleAction:destory()
    self:onDestory()
end

function ABaseBattleAction:isFinish()
    return self.__isFinish
end

function ABaseBattleAction:isStart()
    return self.__isStart
end

return abstract("ABaseBattleAction", {IBattleAction}, ABaseBattleAction)
000000000