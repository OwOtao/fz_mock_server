--[[
    author:Seven
    time:2023-11-08 18:08:04
    desc: 玩家主动技能按钮刷新
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

local FightCommons = require("app.FightSystem.FightCommons")

local ViewActiveSkillFactory = require "app.FightSystem.Veiws.ViewCommonModel.ViewCharacterSkill.ViewActiveSkillFactory"

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local PlayerRefreshAcitveSkillsViewEvent = {}

function PlayerRefreshAcitveSkillsViewEvent:create(...)
    return PlayerRefreshAcitveSkillsViewEvent.new():__init(...)
end

function PlayerRefreshAcitveSkillsViewEvent:__init(id, activeSkillMap)
    self.__id = id

    self.__viewActiveSkills = {}

    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local activeSkill = activeSkillMap[tostring(i)]

        if activeSkill ~= nil then
            local viewActiveSkill = ViewActiveSkillFactory:create(activeSkill, tostring(i))

            table.insert(self.__viewActiveSkills, viewActiveSkill)
        end
    end

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function PlayerRefreshAcitveSkillsViewEvent:doViewEvent(mainView)
    if self.__id ~= mainView:getPlayerId() then
        return
    end
    
    local viewCharacter = mainView:getViewCharacter(self.__id)

    viewCharacter:clearViewActiveSkillMap()

    for i = 1, #self.__viewActiveSkills do
        local viewActiveSkill = self.__viewActiveSkills[i]

        viewCharacter:addViewActiveSkill(viewActiveSkill:getViewActivePosIndex(), viewActiveSkill)
    end

    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local viewActiveSkill = viewCharacter:getViewActiveSkillByIndex(i)
        local btnUI = mainView:getPlayerButtonViewUI(i)
        if viewActiveSkill then
            viewActiveSkill:bindClickBtnUI(mainView, btnUI)
        else
            btnUI:setBtnStatus(1)
        end
    end
end

return newClass("PlayerRefreshAcitveSkillsViewEvent", {IViewEvent}, PlayerRefreshAcitveSkillsViewEvent)
0000000