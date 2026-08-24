--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
    效果类型ID=14，使被动招式攻击普通气血伤害无法被护盾抵消

    * 效果功能执行：Buff持有角色使用被动招式造成的气血伤害，受击者身上的气血护盾无法抵消伤害。

    * 效果生效表现：无特殊表现。
    * 效果值叠加方式：无
]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect14 = {}

function BuffEffect14:create()
    return BuffEffect14.new()
end

function BuffEffect14:updateEffectValue()
end

function BuffEffect14:makeEffectOnAdd()
    self.__buff:getBuffOwner():addBuffAddAttr("autoPassQiShiled", 1)
end

function BuffEffect14:makeEffectOnRemove()
    self.__buff:getBuffOwner():addBuffAddAttr("autoPassQiShiled", -1)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect14:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect14", {ABuffEffect}, BuffEffect14)
00