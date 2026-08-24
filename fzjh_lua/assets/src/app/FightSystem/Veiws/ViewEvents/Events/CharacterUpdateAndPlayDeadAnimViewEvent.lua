--[[
    author:Seven
    time:2023-11-08 18:08:04
    desc: 更新角色静态动画并播放
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

local AudioResManager = require("app.FightSystem.ResourceManager.AudioResManager")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterUpdateAndPlayDeadAnimViewEvent = {}

function CharacterUpdateAndPlayDeadAnimViewEvent:create(...)
    return CharacterUpdateAndPlayDeadAnimViewEvent.new():__init(...)
end

function CharacterUpdateAndPlayDeadAnimViewEvent:__init(c_id, hitPos)
    self.__id = c_id

    self.__hitPos = hitPos

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterUpdateAndPlayDeadAnimViewEvent:doViewEvent(mainView)
    local viewCharacter = mainView:getViewCharacter(self.__id)

    if not viewCharacter:isDead() then
        viewCharacter:setDead(true)

        local animName, soundId = viewCharacter:getDeadAnimAndDeadSound(self.__hitPos)

        mainView:playCharacterAnim(viewCharacter:getId(), animName, false, nil, nil)
        if soundId then
            mainView:playSound(AudioResManager:getSoundNameByRandom(soundId))
        end
    end
end

return newClass("CharacterUpdateAndPlayDeadAnimViewEvent", {IViewEvent}, CharacterUpdateAndPlayDeadAnimViewEvent)
000000