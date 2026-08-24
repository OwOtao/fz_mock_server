--[[
    author:Seven
    time:2023-10-31 19:34:57
    desc:
]]
local interface = require("third.class.interface")

local IViewEventAction = {}

function IViewEventAction:updateEventAction(ft)
end

interface("IViewEventAction", IViewEventAction)

local abstract = require("third.class.abstract")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.EventActions.AViewEventAction#IViewEventAction]
local AViewEventAction = {}

function AViewEventAction:finish()
    self.__isFinished = true
end

function AViewEventAction:isFinished()
    return self.__isFinished == true
end

return abstract("AViewEventAction", {IViewEventAction}, AViewEventAction)
00000000000