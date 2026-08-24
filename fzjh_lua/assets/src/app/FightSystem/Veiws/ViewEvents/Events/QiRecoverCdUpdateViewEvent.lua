--[[
    author:Seven
    time:2023-10-26 20:31:58
    desc: 玩家主动技能CD更新
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local QiRecoverCdUpdateViewEvent = {}

function QiRecoverCdUpdateViewEvent:create(...)
    return QiRecoverCdUpdateViewEvent.new():__init(...)
end

function QiRecoverCdUpdateViewEvent:__init(id, oldCdValue, newCdValue, ft)
    self.__id = id

    self.__old = oldCdValue

    self.__new = newCdValue

    self.__ft = ft

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function QiRecoverCdUpdateViewEvent:doViewEvent(mainView)
    if self.__id ~= mainView:getPlayerId() then
        return
    end

    local viewCharacter = mainView:getViewCharacter(self.__id)

    viewCharacter:getQiRecover():updateViewCd(mainView, self.__old, self.__new, self.__ft)
end

return newClass("QiRecoverCdUpdateViewEvent", {IViewEvent}, QiRecoverCdUpdateViewEvent)
0000000000000