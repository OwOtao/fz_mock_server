local newClass = require("third.class.NewClass")
local IBuffAddStack = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffAddStackTypes.IBuffAddStack")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffAddStackTypes.IBuffAddStack#IBuffAddStack]
local BuffAddStackType3 = {}

function BuffAddStackType3:create()
    return BuffAddStackType3.new()
end

--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@return: true | false
function BuffAddStackType3:tryAddToCharacter(buff, character)
    local addBuffEffectClass = buff:getEffectClass()

    local buffIdArray = {}
    
    character:walkAllBuff(function(buff)
        if addBuffEffectClass == buff:getEffectClass() then
            table.insert(buffIdArray, buff:getId())
        end
    end)

    if #buffIdArray > 0 then
        for i, buffId in ipairs(buffIdArray) do
            character:removeCharacterBuff(buffId)
        end
    end

    return true
end

return newClass("BuffAddStackType3", {IBuffAddStack}, BuffAddStackType3)
000