--[[
    author:Seven
    time:2023-10-30 21:01:00
    desc: 信息输出
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local MessageShowPrintViewEvent = {}

function MessageShowPrintViewEvent:create(...)
    return MessageShowPrintViewEvent.new():__init(...)
end

function MessageShowPrintViewEvent:__init(msg)
    self.__msg = msg

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function MessageShowPrintViewEvent:doViewEvent(mainView)
    mainView:printText(self.__msg)
end

return newClass("MessageShowPrintViewEvent", {IViewEvent}, MessageShowPrintViewEvent)
00000