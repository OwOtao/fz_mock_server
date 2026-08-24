--[[
    author:Seven
    time:2023-10-18 20:36:59
    desc: 战斗视图事件管理器
]]
local ViewEventsManager = {}

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

local AViewEventAction = require("app.FightSystem.Veiws.ViewEvents.EventActions.AViewEventAction")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local newClass = require("third.class.NewClass")

function ViewEventsManager:create(mainView)
    return ViewEventsManager.new():__init(mainView)
end

function ViewEventsManager:__init(mainView)
    --@RefType [src.app.FightSystem.Veiws.FightMainView#FightMainView]
    self.__mainView = mainView

    self.__viewEvents = {}

    self.__viewEventActions = {}

    return self
end

function ViewEventsManager:addViewEventAction(eventAction)
    table.insert(self.__viewEventActions, isImplement(eventAction, AViewEventAction))
end

function ViewEventsManager:addViewEvent(event)
    table.insert(self.__viewEvents, isImplement(event, IViewEvent))
end

function ViewEventsManager:doViewEvents()
    for _, event in ipairs(self.__viewEvents) do
        event:doViewEvent(self.__mainView)
    end

    self.__viewEvents = {}
end

function ViewEventsManager:updateEventActions(dt)
    for i = #self.__viewEventActions, 1, -1 do
        local eventAction = self.__viewEventActions[i]

        if eventAction:isFinished() then
            table.remove(self.__viewEventActions, i)
        end
    end

    for _, eventAction in ipairs(self.__viewEventActions) do
        if not eventAction:isFinished() then
            eventAction:updateEventAction(dt)
        end
    end
end

return newClass("ViewEventsManager", {}, ViewEventsManager)
000000