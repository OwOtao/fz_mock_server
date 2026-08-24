--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 效果类型5

        效果功能：受被动招式攻击判定普通招架 招架率=0%
]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect5 = {}

function BuffEffect5:create()
    return BuffEffect5.new()
end

function BuffEffect5:updateEffectValue()
end

function BuffEffect5:makeEffectOnAdd()
    self.__buff:getBuffOwner():addBuffAddAttr("banAutoParry", 1)
end

function BuffEffect5:makeEffectOnRemove()
    self.__buff:getBuffOwner():addBuffAddAttr("banAutoParry", -1)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect5:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect5", {ABuffEffect}, BuffEffect5)
0000000000000