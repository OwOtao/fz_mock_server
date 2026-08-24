--[[
    author:Seven
    time:2022-12-14 14:39:12
    desc:
]]
local class = require("third.class.NewClass")

local BasicSkillParryClass = {
    __parryRes = nil
}

function BasicSkillParryClass:create(parry_res)
    return BasicSkillParryClass.new():__init(parry_res)
end

function BasicSkillParryClass:__init(parry_res)
    self.__parryRes = parry_res
    
    return self
end


function BasicSkillParryClass:getId()
    return self.__parryRes.id
end

function BasicSkillParryClass:getParryClass()
    return self.__parryRes.parryClass
end

function BasicSkillParryClass:getHitPos()
    return self.__parryRes.hitPos
end

function BasicSkillParryClass:getActionColor()
    return self.__parryRes.actionColor
end

function BasicSkillParryClass:getActionNormal()
    return self.__parryRes.actionNormal
end

function BasicSkillParryClass:getOffsetNormal()
    return self.__parryRes.offsetNormal
end

function BasicSkillParryClass:getSoundNormal()
    return self.__parryRes.soundNormal
end

function BasicSkillParryClass:getActionText()
    return self.__parryRes.actionText
end

function BasicSkillParryClass:getActionSpecial()
    return self.__parryRes.actionSpecial
end

function BasicSkillParryClass:getOffsetSpecial()
    return self.__parryRes.offsetSpecial
end

function BasicSkillParryClass:getSoundSpecial()
    return self.__parryRes.soundSpecial
end

return class("BasicSkillParryClass", {}, BasicSkillParryClass)
000000000