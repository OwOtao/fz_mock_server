--[[
    author:Seven
    time:2023-10-26 20:31:58
    desc: 玩家主动技能CD更新
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local ActiveSkillCdUpdateViewEvent = {}

function ActiveSkillCdUpdateViewEvent:create(...)
    return ActiveSkillCdUpdateViewEvent.new():__init(...)
end

function ActiveSkillCdUpdateViewEvent:__init(id, activeSkillId, oldCdValue, newCdValue, ft)
    self.__id = id

    self.__activeSkillId = activeSkillId

    self.__old = oldCdValue

    self.__new = newCdValue

    self.__ft = ft

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function ActiveSkillCdUpdateViewEvent:doViewEvent(mainView)
    if self.__id ~= mainView:getPlayerId() then
        return
    end

    local viewCharacter = mainView:getViewCharacter(self.__id)

    local viewActiveSkill = viewCharacter:getViewActiveSkillById(self.__activeSkillId)

    if viewActiveSkill == nil then
        return
    end

    viewActiveSkill:updateViewCd(mainView, self.__old, self.__new, self.__ft)
end

return newClass("ActiveSkillCdUpdateViewEvent", {IViewEvent}, ActiveSkillCdUpdateViewEvent)
00000000