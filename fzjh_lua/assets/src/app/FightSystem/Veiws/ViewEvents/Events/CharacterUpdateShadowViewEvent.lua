--[[
    author:Seven
    time:2023-11-24 14:16:27
    desc: 更新角色影子
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterUpdateShadowViewEvent = {}

function CharacterUpdateShadowViewEvent:create(...)
    return CharacterUpdateShadowViewEvent.new():__init(...)
end

function CharacterUpdateShadowViewEvent:__init(id, shadowAnimId)
    self.__id = id

    self.__shadowAnimId = shadowAnimId

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterUpdateShadowViewEvent:doViewEvent(mainView)
    local viewCharacter = mainView:getViewCharacter(self.__id)
    viewCharacter:setShadowAnimId(self.__shadowAnimId)
    viewCharacter:updateShadowUI(mainView)
end

return newClass("CharacterUpdateShadowViewEvent", {IViewEvent}, CharacterUpdateShadowViewEvent)
0000000