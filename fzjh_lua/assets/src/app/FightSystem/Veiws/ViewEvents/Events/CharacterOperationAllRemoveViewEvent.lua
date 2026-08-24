--[[
    author:Seven
    time:2023-11-08 18:08:04
    desc: 角色操作视图显示
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterOperationAllRemoveViewEvent = {}

function CharacterOperationAllRemoveViewEvent:create(...)
    return CharacterOperationAllRemoveViewEvent.new():__init(...)
end

function CharacterOperationAllRemoveViewEvent:__init(c_id)
    self.__id = c_id


    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterOperationAllRemoveViewEvent:doViewEvent(mainView)
    mainView:removeAllOperation(self.__id)
end

return newClass("CharacterOperationAllRemoveViewEvent", {IViewEvent}, CharacterOperationAllRemoveViewEvent)
0