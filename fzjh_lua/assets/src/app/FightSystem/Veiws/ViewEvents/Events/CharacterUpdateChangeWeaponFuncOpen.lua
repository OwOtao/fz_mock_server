--[[
    author:Seven
    time:2023-11-08 18:08:04
    desc: 更新角色静态动画并播放
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterUpdateChangeWeaponFuncOpen = {}

function CharacterUpdateChangeWeaponFuncOpen:create(...)
    return CharacterUpdateChangeWeaponFuncOpen.new():__init(...)
end

function CharacterUpdateChangeWeaponFuncOpen:__init(c_id, isOpen)
    self.__id = c_id

    self.__isOpen = isOpen

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterUpdateChangeWeaponFuncOpen:doViewEvent(mainView)
    local viewCharacter = mainView:getViewCharacter(self.__id)

    local viewChangeWeaponFunc = viewCharacter:getChangeWeapon()

    viewChangeWeaponFunc:setViewIsOpen(self.__isOpen)

    if self.__isOpen == false and mainView:getPlayerId() == self.__id then
        viewChangeWeaponFunc:closeChangeWeaponView(mainView)
    end
end

return newClass("CharacterUpdateChangeWeaponFuncOpen", {IViewEvent}, CharacterUpdateChangeWeaponFuncOpen)
00000