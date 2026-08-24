--[[
    author:Seven
    time:2023-11-27 21:33:44
    desc:
]]

local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local FightFinishViewEvent = {}

function FightFinishViewEvent:create(...)
    return FightFinishViewEvent.new():__init(...)
end

function FightFinishViewEvent:__init(texts)
    self.__texts = texts

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function FightFinishViewEvent:doViewEvent(mainView)
    mainView:fightFinish(self.__texts)
end

return newClass("FightFinishViewEvent", {IViewEvent}, FightFinishViewEvent)
000000000