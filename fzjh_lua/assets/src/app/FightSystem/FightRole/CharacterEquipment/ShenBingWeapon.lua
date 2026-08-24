local class = require("third.class.NewClass")

local RegularWeapon = require("app.FightSystem.FightRole.CharacterEquipment.RegularWeapon")

local ShenBingWeapon = {
    __name = "绝世好刀",
}

function ShenBingWeapon:create(resId)
    local p = ShenBingWeapon.new()
    p:init(resId)
    return p
end

return class("ShenBingWeapon", {RegularWeapon}, ShenBingWeapon)
000000000000000