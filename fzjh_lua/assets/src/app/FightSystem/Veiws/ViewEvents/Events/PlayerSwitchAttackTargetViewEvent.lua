--[[
    author:Seven
    time:2023-11-28 11:18:33
    desc:
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

local FightCommons = require("app.FightSystem.FightCommons")

local ViewActiveSkillFactory = require "app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewActiveSkillFactory"

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local PlayerSwitchAttackTargetViewEvent = {}

function PlayerSwitchAttackTargetViewEvent:create(...)
    return PlayerSwitchAttackTargetViewEvent.new():__init(...)
end

function PlayerSwitchAttackTargetViewEvent:__init(playerId, targetId, fight)
    self.__playerId = playerId

    self.__targetId = targetId

    local list = {targetId}
    local target_teammates = fight:getTeammates(targetId)
    for i = 1, #target_teammates do
        table.insert(list, target_teammates[i]:getId())
    end

    self.__targetList = list

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function PlayerSwitchAttackTargetViewEvent:doViewEvent(mainView)
    local viewCharacter = mainView:getViewCharacter(self.__playerId)

    viewCharacter:setTargetId(self.__targetId)

    for i, c_id in ipairs(self.__targetList) do
        local v_character = mainView:getViewCharacter(c_id)

        mainView:bindRightInfoPanel(i, v_character)

        if i == 1 then
            mainView:setAnimHeadTag(c_id, "target")
        else
            mainView:setAnimHeadTag(c_id, "other")
        end
    end
end

return newClass("PlayerSwitchAttackTargetViewEvent", {IViewEvent}, PlayerSwitchAttackTargetViewEvent)
000000000