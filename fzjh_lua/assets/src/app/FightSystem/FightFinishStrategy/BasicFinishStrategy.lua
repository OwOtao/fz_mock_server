--[[
    author:Seven
    time:2023-03-02 16:39:11
    desc: 基础战斗结束策略
        该策略适用范围：
            1、玩家非观众
            2、玩家队伍只有一人的情况
]]
local newClass = require("third.class.NewClass")

local AFinishStrategy = require("app.FightSystem.FightFinishStrategy.AFinishStrategy")

local FightCommons = require("app.FightSystem.FightCommons")

local FINISH_STATE = FightCommons.FINISH_STATE

--@SuperType [src.app.FightSystem.FightFinishStrategy.AFinishStrategy#AFinishStrategy]
local BasicFinishStrategy = {}

function BasicFinishStrategy:create()
    return BasicFinishStrategy.new()
end

function BasicFinishStrategy:ctor()
    AFinishStrategy.ctor(BasicFinishStrategy)

    self.__isFinish = false

    self.__result = nil

    self.__resultText = {
        text1 = nil,
        text2 = nil
    }
end

function BasicFinishStrategy:__checkAndGetFinishResult()
    local player = self.__fight:getCharacter(self.__fight:getPlayerId())

    if player:isRunaway() then
        self.__resultText = {
            text1 = "逃跑",
            text2 = "你大喝一声：“三十六计，走为上计”，成功逃跑了"
        }
        return true, FINISH_STATE.RUNAWAY
    end

    local playerIsDead = player:isDead()

    local targetTeam = self.__fight:getTargetTeam(player:getId())

    local targetIsAllDead = true
    for i, targetCharacter in ipairs(targetTeam:getCharacters()) do
        if not targetCharacter:isDead() then
            targetIsAllDead = false
            break
        end
    end

    --@desc 失败
    if playerIsDead == true and targetIsAllDead == false then
        self.__resultText = {
            text1 = "失败",
            text2 = "\n你被对方打趴在地\n"
        }

        return true, FINISH_STATE.LOSE
    end

    if playerIsDead == true and targetIsAllDead == true then
        self.__resultText = {
            text1 = "平局",
            text2 = "你和双方同时倒在地上"
        }

        return true, FINISH_STATE.NO_WINNER
    end

    if playerIsDead == false and targetIsAllDead == true then
        local winText = "你成功战胜了："

        for i, targetCharacter in ipairs(targetTeam:getCharacters()) do
            if i == 1 then
                winText = winText .. targetCharacter:getAttr("name")
            else
                winText = winText .. "\n" .. "                     " .. targetCharacter:getAttr("name")
            end
        end

        self.__resultText = {
            text1 = "胜利",
            text2 = winText
        }
        return true, FINISH_STATE.WIN
    end

    return false
end

function BasicFinishStrategy:checkBattaleFinish()
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
function BasicFinishStrategy:getFinishResult()
    return self.__result
end

function BasicFinishStrategy:getResultText()
    return self.__resultText
end

return newClass("BasicFinishStrategy", {AFinishStrategy}, BasicFinishStrategy)
0000000000000000