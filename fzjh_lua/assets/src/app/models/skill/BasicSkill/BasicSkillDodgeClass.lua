--[[
    author:Seven
    time:2022-12-14 14:37:40
    desc:
]]
local class = require("third.class.NewClass")

local BasicSkillDodgeClass = {
    __dodgeRes = nil
}

function BasicSkillDodgeClass:create(dodge_res)
    return BasicSkillDodgeClass.new():__init(dodge_res)
end

function BasicSkillDodgeClass:__init(dodge_res)
    self.__dodgeRes = dodge_res
    return self
end

function BasicSkillDodgeClass:getId()
    return self.__dodgeRes.id
end

function BasicSkillDodgeClass:getDodgeClass()
    return self.__dodgeRes.dodgeClass
end

function BasicSkillDodgeClass:getHitPos()
    return self.__dodgeRes.hitPos
end

function BasicSkillDodgeClass:getActionColor()
    return self.__dodgeRes.actionColor
end

function BasicSkillDodgeClass:getActionNormal()
    return self.__dodgeRes.actionNormal
end

function BasicSkillDodgeClass:getOffsetNormal()
    return self.__dodgeRes.offsetNormal
end

function BasicSkillDodgeClass:getSoundNormal()
    return self.__dodgeRes.soundNormal
end

function BasicSkillDodgeClass:getActionTextSpecial()
    return self.__dodgeRes.actionTextSpecial
end

function BasicSkillDodgeClass:getActionSpecial()
    return self.__dodgeRes.actionSpecial
end

function BasicSkillDodgeClass:getOffsetSpecial()
    return self.__dodgeRes.offsetSpecial
end

function BasicSkillDodgeClass:getSoundSpecial()
    return self.__dodgeRes.soundSpecial
end

return class("BasicSkillDodgeClass", {}, BasicSkillDodgeClass)
000