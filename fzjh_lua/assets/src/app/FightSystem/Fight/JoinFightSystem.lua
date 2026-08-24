--[[
    --@desc 参战系统
]]
local class = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local FIGHT_STATE = FightCommons.FIGHT_STATE

--@SuperType [src.app.FightSystem.AFightSystem#AFightSystem]
local JoinFightSystem = {}

function JoinFightSystem:init()
    --@desc 等待加入的角色
    self.__waitting_list = {}

    --@desc 控制是否可以加入战场
    self.__can_enter = true

    self.__battleData = BattleGlobalData:getInstance()

    self.__waitingTime = 0

    self.__shortWaitingTime = 1
end

function JoinFightSystem:release()
    self.__waitting_list = {}
end

function JoinFightSystem:addCharacterWaitingList(f_character)
    if not self.__can_enter then
        return
    end
    table.insert(self.__waitting_list, f_character)
end

function JoinFightSystem:update(ft)
    self.__waitingTime = self.__waitingTime + ft

    if not self.__can_enter then
        if self.__fight:getFightState() == FIGHT_STATE.JOINING then
            local isAllInIdle = true
            for i, character in ipairs(self.__fight:getFightCharacters()) do
                --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
                local character = character

                if character:getCurrentStateType() ~= CHARACTER_STATE.IDLE then
                    isAllInIdle = false
                    break
                end
            end

            if isAllInIdle == true and  self.__shortWaitingTime <= self.__waitingTime then
                self.__fight:startBattale()
            end
        end

        return
    end

    if #self.__waitting_list > 0 then
        for i = 1, #self.__waitting_list do
            --@RefType[src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
            local f_character = self.__waitting_list[i]
            f_character:triggerEvent("FIGHT_ENTER")
        end

        self.__waitting_list = {}

        self.__can_enter = false
    end
end

return class("JoinFightSystem", {require("app.FightSystem.AFightSystem")}, JoinFightSystem)
0