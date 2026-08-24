--[[
    author:Seven
    time:2023-11-10 16:58:19
    desc: 播放动画事件
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterPlayAnimViewEvent = {}

function CharacterPlayAnimViewEvent:create(...)
    return CharacterPlayAnimViewEvent.new():__init(...)
end

function CharacterPlayAnimViewEvent:__init(id, animName, isFinishIdle)
    self.__id = id

    self.__animName = animName

    if isFinishIdle == nil then
        self.__isFinishIdle = false
    end

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterPlayAnimViewEvent:doViewEvent(mainView)
    if self.__isFinishIdle == false then
        mainView:playCharacterAnim(self.__id, self.__animName, false)
    else
        mainView:playCharacterAnim(
            self.__id,
            self.__animName,
            false,
            nil,
            function()
                local animTarget = mainView:getViewCharacter(self.__id)
                mainView:playCharacterAnim(self.__id, animTarget:getIdleAnimName(), false, nil, nil)
            end
        )
    end
end

return newClass("CharacterPlayAnimViewEvent", {IViewEvent}, CharacterPlayAnimViewEvent)
000000000000