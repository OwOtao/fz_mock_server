--[[
    author:Seven
    time:2023-10-25 14:08:39
    desc: 角色体力视图更新事件
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterTiliUpdateViewEvent = {}

function CharacterTiliUpdateViewEvent:create(...)
    return CharacterTiliUpdateViewEvent.new():__init(...)
end

function CharacterTiliUpdateViewEvent:__init(id, old, new, ft)
    self.__id = id

    self.__old = old

    self.__new = new

    self.__ft = ft

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterTiliUpdateViewEvent:doViewEvent(mainView)
    local viewCharacter = mainView:getViewCharacter(self.__id)

    viewCharacter:updateTiliView(self.__old, self.__new, self.__ft)
end

return newClass("CharacterTiliUpdateViewEvent", {IViewEvent}, CharacterTiliUpdateViewEvent)
0000000000