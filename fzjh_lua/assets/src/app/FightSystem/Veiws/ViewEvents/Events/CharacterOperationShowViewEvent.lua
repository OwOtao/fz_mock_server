--[[
    author:Seven
    time:2023-11-08 18:08:04
    desc: 角色操作视图显示
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterOperationShowViewEvent = {}

function CharacterOperationShowViewEvent:create(...)
    return CharacterOperationShowViewEvent.new():__init(...)
end

function CharacterOperationShowViewEvent:__init(c_id, operationId, name)
    self.__id = c_id

    self.__operationId = operationId

    self.__name = name

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterOperationShowViewEvent:doViewEvent(mainView)
    mainView:showOperationName(self.__id, self.__name)
end

return newClass("CharacterOperationShowViewEvent", {IViewEvent}, CharacterOperationShowViewEvent)
00000