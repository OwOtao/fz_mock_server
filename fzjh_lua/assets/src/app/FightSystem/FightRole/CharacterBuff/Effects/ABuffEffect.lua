--[[
    author:Seven
    time:2023-11-29 14:29:11
    desc: buff效果基类
]]
local abstract = require("third.class.abstract")

local IBuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
local ABuffEffect = {}

--@desc: 设置所属buff对象
--@author:Seven
--@time:2023-11-28 18:11:03
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
function ABuffEffect:setOwningBuff(buff)
    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
    self.__buff = buff
end

function ABuffEffect:setBasicEffect(basicEffect)
    --@RefType [src.app.FightSystem.FightBuff.BasicEffects.BasicEffect#BasicEffect]
    self.__basicEffect = basicEffect
end

function ABuffEffect:getResouceId()
    return tostring(self.__basicEffect:getId())
end

function ABuffEffect:getEffectId()
    return tostring(self.__basicEffect:getEffectID())
end

function ABuffEffect:getEffectType()
    return tostring(self.__basicEffect:getEffectType())
end

return abstract("ABuffEffect", {IBuffEffect}, ABuffEffect)
000