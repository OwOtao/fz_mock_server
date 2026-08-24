--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 效果类型3

        效果功能：受被动招式攻击判定轻功闪躲 闪躲率=0%
]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect3 = {}

function BuffEffect3:create()
    return BuffEffect3.new()
end

function BuffEffect3:updateEffectValue()
end

function BuffEffect3:makeEffectOnAdd()
    self.__buff:getBuffOwner():addBuffAddAttr("banAutoDodge", 1)
end

function BuffEffect3:makeEffectOnRemove()
    self.__buff:getBuffOwner():addBuffAddAttr("banAutoDodge", -1)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect3:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect3", {ABuffEffect}, BuffEffect3)
0000000000000