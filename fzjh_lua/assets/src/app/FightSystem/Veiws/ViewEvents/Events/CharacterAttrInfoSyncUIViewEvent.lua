--[[
    author:Seven
    time:2023-11-10 14:22:40
    desc:
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterAttrInfoSyncUIViewEvent = {}

function CharacterAttrInfoSyncUIViewEvent:create(...)
    return CharacterAttrInfoSyncUIViewEvent.new():__init(...)
end

function CharacterAttrInfoSyncUIViewEvent:__init(character)
    self.__syncUI = require("app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacterSyncUI"):create(character)

    self.__id = character:getId()

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterAttrInfoSyncUIViewEvent:doViewEvent(mainView)
    self.__syncUI:syncUI(mainView:getViewCharacter(self.__id), mainView)
end

return newClass("CharacterAttrInfoSyncUIViewEvent", {IViewEvent}, CharacterAttrInfoSyncUIViewEvent)
0000000000000000