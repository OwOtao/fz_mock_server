--[[
    author:Seven
    time:2023-11-24 14:16:27
    desc: 更新角色头顶挂字
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterUpdateHeadStatusTextViewEvent = {}

function CharacterUpdateHeadStatusTextViewEvent:create(...)
    return CharacterUpdateHeadStatusTextViewEvent.new():__init(...)
end

function CharacterUpdateHeadStatusTextViewEvent:__init(id, text)
    self.__id = id

    self.__text = text

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterUpdateHeadStatusTextViewEvent:doViewEvent(mainView)
    local viewCharacter = mainView:getViewCharacter(self.__id)
    viewCharacter:setHeadText(self.__text)
    viewCharacter:updateHeadTextUI(mainView)
end

return newClass("CharacterUpdateHeadStatusTextViewEvent", {IViewEvent}, CharacterUpdateHeadStatusTextViewEvent)
00000000000