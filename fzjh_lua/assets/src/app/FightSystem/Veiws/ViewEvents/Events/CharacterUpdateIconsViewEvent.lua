--[[
    author:Seven
    time:2023-11-24 14:16:27
    desc: 更新角色图标
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterUpdateIconsViewEvent = {}

function CharacterUpdateIconsViewEvent:create(...)
    return CharacterUpdateIconsViewEvent.new():__init(...)
end

function CharacterUpdateIconsViewEvent:__init(id, icons)
    self.__id = id

    self.__list = {}

    for __, icon in ipairs(icons) do
        --@RefType [src.app.FightSystem.FightRole.IconSystem.BasicIcon#BasicIcon]
        icon = icon

        table.insert(
            self.__list,
            {
                id = icon:getIconId(),
                imagePath = icon:getImgPath(),
                count = icon:getCount()
            }
        )
    end

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterUpdateIconsViewEvent:doViewEvent(mainView)
    local viewCharacter = mainView:getViewCharacter(self.__id)
    viewCharacter:setIcons(self.__list)
    viewCharacter:updateIconUI(mainView)
end

return newClass("CharacterUpdateIconsViewEvent", {IViewEvent}, CharacterUpdateIconsViewEvent)
00