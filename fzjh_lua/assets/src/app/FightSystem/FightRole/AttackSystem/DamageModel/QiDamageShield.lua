local newClass = require("third.class.NewClass")

local QiDamageShield = {
    __shieldValue = 0,
    __absorbDamage = 0
}

function QiDamageShield:create(value)
    local p = QiDamageShield.new()
    p:__init(value)
    return p
end

function QiDamageShield:__init(value)
    self.__shieldValue = value
end

function QiDamageShield:getShielValue()
    return self.__shieldValue
end

--@desc: 吸收伤害
--@author:Seven
--@time:2022-01-07 15:16:44
function QiDamageShield:absorbDamage(value)
    self.__absorbDamage = self.__absorbDamage + value
end

--@desc: 已吸收的伤害
--@author:Seven
--@time:2022-01-07 15:16:10
function QiDamageShield:getHasAbsorbedDamage()
    return math.min(self.__absorbDamage, self.__shieldValue)
end

--@desc: 剩余护盾值
--@author:Seven
--@time:2022-01-07 15:16:27
function QiDamageShield:getRemaining()
    return math.max(self.__shieldValue - self.__absorbDamage, 0)
end

return newClass("QiDamageShield", {}, QiDamageShield)
00000000000