local class = require("third.class.NewClass")

local NormalFightParryClass = {
    __parryRes = nil
}

function NormalFightParryClass:create()
    return self.new()
end

function NormalFightParryClass:setParryRes(parry_res)
    self.__parryRes = parry_res
end

function NormalFightParryClass:getId()
    return self.__parryRes.id
end

function NormalFightParryClass:getParryClass()
    return self.__parryRes.parryClass
end

function NormalFightParryClass:getHitPos()
    return self.__parryRes.hitPos
end

function NormalFightParryClass:getActionColor()
    return self.__parryRes.actionColor
end

function NormalFightParryClass:getActionNormal()
    return self.__parryRes.actionNormal
end

function NormalFightParryClass:getOffsetNormal()
    return self.__parryRes.offsetNormal
end

function NormalFightParryClass:getSoundNormal()
    return self.__parryRes.soundNormal
end

function NormalFightParryClass:getActionText()
    return self.__parryRes.actionText
end

function NormalFightParryClass:getActionSpecial()
    return self.__parryRes.actionSpecial
end

function NormalFightParryClass:getOffsetSpecial()
    return self.__parryRes.offsetSpecial
end

function NormalFightParryClass:getSoundSpecial()
    return self.__parryRes.soundSpecial
end

return class("NormalFightParryClass", {}, NormalFightParryClass)
0000000000000