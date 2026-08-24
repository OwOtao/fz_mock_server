--[[
    author:Seven
    time:2023-11-08 18:08:04
    desc: 角色操作视图显示
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterOperationRemoveViewEvent = {}

function CharacterOperationRemoveViewEvent:create(...)
    return CharacterOperationRemoveViewEvent.new():__init(...)
end

function CharacterOperationRemoveViewEvent:__init(c_id, operationId, releaseSuccess)
    self.__id = c_id

    self.__operationId = operationId

    if releaseSuccess == nil or type(releaseSuccess) ~= "boolean" then
        error("releaseSuccess must be a boolean")
    end

    self.__releaseSuccess = releaseSuccess

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterOperationRemoveViewEvent:doViewEvent(mainView)
    local removeAnimStyle
    if self.__releaseSuccess then
        removeAnimStyle = FightCommons.HIDE_ACTIVE_SKILL_NAME_ANIM_STYLE.FONT_GREEN
    else
        removeAnimStyle = FightCommons.HIDE_ACTIVE_SKILL_NAME_ANIM_STYLE.FONT_YELLOW
    end

    mainView:removeOperationName(self.__id, removeAnimStyle)
end

return newClass("CharacterOperationRemoveViewEvent", {IViewEvent}, CharacterOperationRemoveViewEvent)
000000000000000