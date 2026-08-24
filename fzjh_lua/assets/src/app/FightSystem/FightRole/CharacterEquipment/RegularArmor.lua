local newClass = require("third.class.NewClass")

local IArmor = require("app.FightSystem.FightRole.CharacterEquipment.IArmor")

--@SuperType [src.app.FightSystem.FightRole.Armor.IArmor#IArmor]
local RegularArmor = {
    __name = "",
    __protect = 0
}

function RegularArmor:create()
    local p = RegularArmor.new()
    return p
end

function RegularArmor:setName(name)
    self.__name = name
end

function RegularArmor:getName()
    return self.__name
end

function RegularArmor:setProtect(value)
    self.__protect = value
end

function RegularArmor:getProtect()
    return self.__protect
end

return newClass("RegularArmor", {IArmor}, RegularArmor)
0