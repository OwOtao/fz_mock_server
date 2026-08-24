local class = require("third.class.NewClass")

local NormalFightDodgeClass = {
    __dodgeRes = nil
}

function NormalFightDodgeClass:create()
    return self.new()
end

function NormalFightDodgeClass:setDodgeRes(dodge_res)
    self.__dodgeRes = dodge_res
end

function NormalFightDodgeClass:getId()
    return self.__dodgeRes.id
end

function NormalFightDodgeClass:getDodgeClass()
    return self.__dodgeRes.dodgeClass
end

function NormalFightDodgeClass:getHitPos()
    return self.__dodgeRes.hitPos
end

function NormalFightDodgeClass:getActionColor()
    return self.__dodgeRes.actionColor
end

function NormalFightDodgeClass:getActionNormal()
    return self.__dodgeRes.actionNormal
end

function NormalFightDodgeClass:getOffsetNormal()
    return self.__dodgeRes.offsetNormal
end

function NormalFightDodgeClass:getSoundNormal()
    return self.__dodgeRes.soundNormal
end

function NormalFightDodgeClass:getActionTextSpecial()
    return self.__dodgeRes.actionTextSpecial
end

function NormalFightDodgeClass:getActionSpecial()
    return self.__dodgeRes.actionSpecial
end

function NormalFightDodgeClass:getOffsetSpecial()
    return self.__dodgeRes.offsetSpecial
end

function NormalFightDodgeClass:getSoundSpecial()
    return self.__dodgeRes.soundSpecial
end

return class("NormalFightDodgeClass", {}, NormalFightDodgeClass)
000000000000000