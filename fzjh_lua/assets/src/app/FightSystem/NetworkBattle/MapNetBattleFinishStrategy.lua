--[[
    author:Seven
    time:2024-02-27 17:13:43
    desc: PVP战斗结束策略 
        只适合 1V1 的情况
]]
local newClass = require("third.class.NewClass")

local AFinishStrategy = require("app.FightSystem.FightFinishStrategy.AFinishStrategy")

local FightCommons = require("app.FightSystem.FightCommons")

local FINISH_STATE = FightCommons.FINISH_STATE

--@SuperType [src.app.FightSystem.FightFinishStrategy.AFinishStrategy#AFinishStrategy]
local MapNetBattleFinishStrategy = {}

function MapNetBattleFinishStrategy:create()
    return MapNetBattleFinishStrategy.new()
end

function MapNetBattleFinishStrategy:ctor()
    AFinishStrategy.ctor(MapNetBattleFinishStrategy)

    self.__isFinish = false

    self.__result = nil

    self.__resultText = {
        text1 = nil,
        text2 = nil
    }
end

function MapNetBattleFinishStrategy:__checkAndGetFinishResult()
    local player = self.__fight:getCharacter(self.__fight:getPlayerId())

    if player:isRunaway() then
        self.__resultText = {
            text1 = "逃跑",
            text2 = "你大喝一声：“三十六计，走为上计”，成功逃跑了"
        }
        return true, FINISH_STATE.RUNAWAY
    end

    local target = player:getTarget()
    if not player:isDead() and target:isOutOfBattleState() then
        local winText = "你成功战胜了：" .. target:getAttr("name")

        self.__resultText = {
            text1 = "胜利",
            text2 = winText
        }
        return true, FINISH_STATE.WIN
    end

    if player:isDead() and not target:isOutOfBattleState() then
        self.__resultText = {
            text1 = "失败",
            text2 = "\n你被对方打趴在地\n"
        }

        return true, FINISH_STATE.LOSE
    end

    if player:isDead() and target:isOutOfBattleState() then
        self.__resultText = {
            text1 = "平局",
            text2 = "你和双方同时倒在地上"
        }

        return true, FINISH_STATE.NO_WINNER
    end

    return false
end

function MapNetBattleFinishStrategy:checkBattaleFinish()
    if self.__isFinish == true then
        --@desc 已经结束了 则不需要再判断
        return self.__isFinish
    end

    local isFinish, result = self:__checkAndGetFinishResult()

    self.__isFinish = isFinish

    self.__result = result

    return self.__isFinish
end

--@desc: 获取结束类型
--@author:Seven
--@time:2023-03-02 17:31:18
function MapNetBattleFinishStrategy:getFinishResult()
    return self.__result
end

function MapNetBattleFinishStrategy:getResultText()
    return self.__resultText
end

return newClass("MapNetBattleFinishStrategy", {AFinishStrategy}, MapNetBattleFinishStrategy)
000000