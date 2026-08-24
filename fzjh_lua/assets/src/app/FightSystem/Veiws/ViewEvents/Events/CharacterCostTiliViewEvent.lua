--[[
    author:Seven
    time:2023-10-25 14:08:39
    desc: 角色体力视图更新事件
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterCostTiliViewEvent = {}

function CharacterCostTiliViewEvent:create(...)
    return CharacterCostTiliViewEvent.new():__init(...)
end

function CharacterCostTiliViewEvent:__init(id, tili, tiliMax, costValue)
    self.__id = id

    self.__tili = math.min(math.max(tili, 0), tiliMax)

    self.__tiliMax = math.max(tiliMax, 0)

    self.__costValue = costValue

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterCostTiliViewEvent:doViewEvent(mainView)
    local viewCharacter = mainView:getViewCharacter(self.__id)

    viewCharacter:costTiliView(self.__tili, self.__tiliMax, self.__costValue)
end

return newClass("CharacterCostTiliViewEvent", {IViewEvent}, CharacterCostTiliViewEvent)
0000000000000