--[[
    author:Seven
    time:2023-10-26 20:31:58
    desc: 玩家主动技能CD更新
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local ActiveSkillEnableViewEvent = {}

function ActiveSkillEnableViewEvent:create(...)
    return ActiveSkillEnableViewEvent.new():__init(...)
end

function ActiveSkillEnableViewEvent:__init(id, activeSkillId, isEnable)
    self.__id = id

    self.__activeSkillId = activeSkillId

    self.__isEnable = isEnable

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function ActiveSkillEnableViewEvent:doViewEvent(mainView)
    if self.__id ~= mainView:getPlayerId() then
        return
    end

    local viewCharacter = mainView:getViewCharacter(self.__id)

    local viewActiveSkill = viewCharacter:getViewActiveSkillById(self.__activeSkillId)

    if viewActiveSkill == nil then
        return
    end

    viewActiveSkill:updateEnable(mainView, self.__isEnable)
end

return newClass("ActiveSkillEnableViewEvent", {IViewEvent}, ActiveSkillEnableViewEvent)
000000000000