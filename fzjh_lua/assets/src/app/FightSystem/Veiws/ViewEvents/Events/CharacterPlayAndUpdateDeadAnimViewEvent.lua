--[[
    author:Seven
    time:2023-11-16 15:55:02
    desc: 播放死亡动画
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

local AudioResManager = require("app.FightSystem.ResourceManager.AudioResManager")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterPlayAndUpdateDeadAnimViewEvent = {}

function CharacterPlayAndUpdateDeadAnimViewEvent:create(...)
    return CharacterPlayAndUpdateDeadAnimViewEvent.new():__init(...)
end

function CharacterPlayAndUpdateDeadAnimViewEvent:__init(id, deadAnimMap, hitPos)
    self.__id = id

    self.__deadMap = deadAnimMap

    self.__hitPos = hitPos

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterPlayAndUpdateDeadAnimViewEvent:doViewEvent(mainView)
    local viewCharacter = mainView:getViewCharacter(self.__id)

    viewCharacter:setDeadAnimAndSound(self.__deadMap)

    if not viewCharacter:isDead() then
        local deadAnim, deadSound = viewCharacter:getDeadAnimAndDeadSound(self.__hitPos)

        self.__mainView:playCharacterAnim(viewCharacter:getId(), deadAnim, false)

        if deadSound then
            self.__mainView:playSound(AudioResManager:getSoundNameByRandom(deadSound))
        end
    end
end

return newClass("CharacterPlayAndUpdateDeadAnimViewEvent", {IViewEvent}, CharacterPlayAndUpdateDeadAnimViewEvent)
0000000000