--[[
    author:Seven
    time:2023-02-10 16:59:13
    desc: buff 添加的气血护盾
]]
local newClass = require("third.class.NewClass")

local BasicShield = require("app.FightSystem.FightRole.CharacterShield.BasicShield")

--@SuperType [src.app.FightSystem.FightRole.CharacterShield.BasicShield#BasicShield]
local BuffShield = {
    __source = "buffShield"
}

function BuffShield:create(buffId)
    return BuffShield.new():__init(buffId)
end

function BuffShield:__init(buffId)
    --@desc 该护盾来源buffid
    self.__buffId = buffId

    return self
end

function BuffShield:getBuffId()
    return self.__buffId
end

--@desc: 设置护盾拥有者
--@author:Seven
--@time:2023-02-10 17:06:19
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function BuffShield:setCharacter(character)
    self.__character = character
end

return newClass("BuffShield", {BasicShield}, BuffShield)
00