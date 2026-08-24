--[[
    author:Seven
    time:2023-10-25 14:08:39
    desc: 角色内力视图更新事件
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterCostNeiliViewEvent = {}

function CharacterCostNeiliViewEvent:create(...)
    return CharacterCostNeiliViewEvent.new():__init(...)
end

function CharacterCostNeiliViewEvent:__init(id, neili, neiliMax, costValue)
    self.__id = id

    self.__neili = math.max(neili, 0)

    self.__neilMax = math.max(neiliMax, 0)

    self.__costValue = costValue

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterCostNeiliViewEvent:doViewEvent(mainView)
    local viewCharacter = mainView:getViewCharacter(self.__id)

    viewCharacter:costNeiliView(self.__neili, self.__neilMax, self.__costValue)
end

return newClass("CharacterCostNeiliViewEvent", {IViewEvent}, CharacterCostNeiliViewEvent)
00