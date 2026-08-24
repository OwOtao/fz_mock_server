--[[
    author:Seven
    time:2023-03-14 12:12:56
    desc: 根据叠加类型1添加buff
]]
local newClass = require("third.class.NewClass")

local IBuffAddStack = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffAddStackTypes.IBuffAddStack")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffAddStackTypes.IBuffAddStack#IBuffAddStack]
local BuffAddStackType1 = {}

function BuffAddStackType1:create()
    return BuffAddStackType1.new()
end

--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function BuffAddStackType1:tryAddToCharacter(buff, character)
    local currLayerCount = character:getBuffLayerCountByBuffId(buff:getBuffId())

    if currLayerCount >= buff:getStackTimesMax() then
        return false
    end

    return true
end

return newClass("BuffAddStackType1", {IBuffAddStack}, BuffAddStackType1)
0000