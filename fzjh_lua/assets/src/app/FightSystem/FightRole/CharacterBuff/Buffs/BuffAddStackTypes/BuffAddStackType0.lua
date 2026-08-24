--[[
    author:Seven
    time:2023-03-14 12:12:56
    desc: 根据叠加类型0添加buff
]]
local newClass = require("third.class.NewClass")

local IBuffAddStack = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffAddStackTypes.IBuffAddStack")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffAddStackTypes.IBuffAddStack#IBuffAddStack]
local BuffAddStackType0 = {}

function BuffAddStackType0:create()
    return BuffAddStackType0.new()
end

--@desc: 是否需要添加
--@author:Seven
--@time:2023-10-11 10:57:53
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@return:  true | false
function BuffAddStackType0:tryAddToCharacter(buff, character)
    local currentCount = character:getBuffLayerCountByBuffId(buff:getBuffId())

    if currentCount > 1 then
        error("BuffAddStackType0:tryAddBuff 不应该存在当前层数大于1的情况，检查代码，buffid：" .. tostring(buff:getBuffId()))
    end

    if currentCount > 0 then
        local currBuff = character:getBuffByBuffId(buff:getBuffId())[1]

        if currBuff:getBuffLives() < buff:getBuffLives() then
            --@desc 把当前buff先移除
            character:removeCharacterBuff(currBuff:getId())

            return true
        else
            return false
        end
    else
        return true
    end

    return false
end

return newClass("BuffAddStackType0", {IBuffAddStack}, BuffAddStackType0)
0000000000000000