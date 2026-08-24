--[[
    author:Seven
    time:2023-11-24 14:16:27
    desc: 更新角色护盾
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterUpdateShieldViewEvent = {}

function CharacterUpdateShieldViewEvent:create(...)
    return CharacterUpdateShieldViewEvent.new():__init(...)
end

function CharacterUpdateShieldViewEvent:__init(id, shieldAnimId)
    self.__id = id

    self.__shieldAnimId = shieldAnimId

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterUpdateShieldViewEvent:doViewEvent(mainView)
    local viewCharacter = mainView:getViewCharacter(self.__id)
    if viewCharacter:getShieldAnimId() == self.__shieldAnimId then
        return
    end
    viewCharacter:setShieldAnimId(self.__shieldAnimId)
    viewCharacter:updateShieldUI(mainView)
end

return newClass("CharacterUpdateShieldViewEvent", {IViewEvent}, CharacterUpdateShieldViewEvent)
0000000000