--[[
    author:Seven
    time:2023-11-08 18:08:04
    desc: 更新角色静态动画并播放
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterUpdateAndPlayIdleAnimNameViewEvent = {}

function CharacterUpdateAndPlayIdleAnimNameViewEvent:create(...)
    return CharacterUpdateAndPlayIdleAnimNameViewEvent.new():__init(...)
end

function CharacterUpdateAndPlayIdleAnimNameViewEvent:__init(c_id, animId)
    self.__id = c_id

    self.__animId = animId

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterUpdateAndPlayIdleAnimNameViewEvent:doViewEvent(mainView)
    local viewCharacter = mainView:getViewCharacter(self.__id)

    local currAnim = viewCharacter:getIdleAnimName()
    viewCharacter:setIdleAnim(self.__animId)

    if currAnim ~= viewCharacter:getIdleAnimName() then
        mainView:playCharacterAnim(viewCharacter:getId(), viewCharacter:getIdleAnimName(), false, nil, nil)
    end
end

return newClass("CharacterUpdateAndPlayIdleAnimNameViewEvent", {IViewEvent}, CharacterUpdateAndPlayIdleAnimNameViewEvent)
00000000