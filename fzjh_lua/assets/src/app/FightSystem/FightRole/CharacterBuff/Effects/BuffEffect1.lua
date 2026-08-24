--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 效果类型1

        效果功能：拥有该效果时无法使用被动招式
]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect1 = {}

function BuffEffect1:create()
    return BuffEffect1.new()
end

function BuffEffect1:makeEffectOnAdd()
    self.__banIndex = self.__buff:getBuffOwner():addBanAutoAttack()
end

function BuffEffect1:makeEffectOnRemove()
    self.__buff:getBuffOwner():removeBanAutoAttack(self.__banIndex)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect1:makeEffectOnTransfer(buffEffect)
end

function BuffEffect1:updateEffectValue()
end

return newClass("BuffEffect1", {ABuffEffect}, BuffEffect1)
00