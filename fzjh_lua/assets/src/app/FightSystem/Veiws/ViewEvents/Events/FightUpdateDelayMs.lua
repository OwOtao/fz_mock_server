--[[
    author:Seven
    time:2023-10-30 21:01:00
    desc: 输出延迟
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local MessagePopViewEvent = {}

function MessagePopViewEvent:create(...)
    return MessagePopViewEvent.new():__init(...)
end

function MessagePopViewEvent:__init(ms)
    self.__ms = ms

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function MessagePopViewEvent:doViewEvent(mainView)
    mainView:updateMs(self.__ms)
end

return newClass("MessagePopViewEvent", {IViewEvent}, MessagePopViewEvent)
0000