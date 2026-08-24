--[[
    author:Seven
    time:2023-11-08 18:08:04
    desc: 更新角色视图武器皮肤
]]
local newClass = require("third.class.NewClass")

local IViewEvent = require("app.FightSystem.Veiws.ViewEvents.Events.IViewEvent")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.Events.IViewEvent#IViewEvent]
local CharacterWeaponSkinUpdateViewEvent = {}

function CharacterWeaponSkinUpdateViewEvent:create(...)
    return CharacterWeaponSkinUpdateViewEvent.new():__init(...)
end

function CharacterWeaponSkinUpdateViewEvent:__init(c_id, weaponSkin)
    self.__id = c_id

    self.__weaponSkin = weaponSkin

    return self
end

--@author:Seven
--@time:2023-10-24 16:33:02
--@mainView: [FightMainView]
function CharacterWeaponSkinUpdateViewEvent:doViewEvent(mainView)
    local viewCharacter = mainView:getViewCharacter(self.__id)
    local currWeaponSkin = viewCharacter:getWeaponSkin()
    if currWeaponSkin == self.__weaponSkin then
        return
    end
    viewCharacter:setWeaponSkin(self.__weaponSkin)
    mainView:setCharacterAnimWeaponSkin(viewCharacter:getId(), viewCharacter:getWeaponSkin())
end

return newClass("CharacterWeaponSkinUpdateViewEvent", {IViewEvent}, CharacterWeaponSkinUpdateViewEvent)
00000000000000