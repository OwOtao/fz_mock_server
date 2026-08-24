--[[
    author:Seven
    time:2023-11-10 16:58:19
    desc: 播放头顶文字动画事件
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterPopHeadTextViewEvent = {}

function CharacterPopHeadTextViewEvent:create(...)
    return CharacterPopHeadTextViewEvent.new():__init(...)
end

function CharacterPopHeadTextViewEvent:__init(id, text)
    self.__id = id

    self.__text = text

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterPopHeadTextViewEvent:doViewEvent(mainView)
    mainView:popHeadTextInAnimView(self.__id, self.__text)
end

return newClass("CharacterPopHeadTextViewEvent", {IViewEvent}, CharacterPopHeadTextViewEvent)
00