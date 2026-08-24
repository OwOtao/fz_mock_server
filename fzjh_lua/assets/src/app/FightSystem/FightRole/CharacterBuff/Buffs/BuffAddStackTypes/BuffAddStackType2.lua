--[[
    author:Seven
    time:2023-03-14 12:12:56
    desc: 根据叠加类型2添加buff
]]
local newClass = require("third.class.NewClass")
local IBuffAddStack = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffAddStackTypes.IBuffAddStack")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffAddStackTypes.IBuffAddStack#IBuffAddStack]
local BuffAddStackType2 = {}

function BuffAddStackType2:create()
    return BuffAddStackType2.new()
end

--@desc:
--@author:Seven
--@time:2023-10-11 11:19:36
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@return: true | false
function BuffAddStackType2:tryAddToCharacter(buff, character)
    local nowStackMax = character:getBuffMaxLayerCount(buff:getBuffId())

    --@desc 最大叠加层数
    local maxStackMax

    if nowStackMax == 0 then
        maxStackMax = buff:getStackTimesMax()
    elseif nowStackMax < buff:getStackTimesMax() then
        character:setBuffMaxLayerCount(buff:getBuffId(), buff:getStackTimesMax())
        maxStackMax = buff:getStackTimesMax()
    else
        maxStackMax = nowStackMax
    end

    local live = buff:getBuffLives()
    local buffs = character:getBuffByBuffId(buff:getBuffId())
    for _, c_buff in ipairs(buffs) do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
        c_buff = c_buff
        if live > c_buff:getBuffLives() then
            c_buff:setBuffLives(live)
        end
    end

    local currentCount = character:getBuffLayerCountByBuffId(buff:getBuffId())
    if currentCount < maxStackMax then
        return true
    end

    return false
end

return newClass("BuffAddStackType2", {IBuffAddStack}, BuffAddStackType2)
00000000000