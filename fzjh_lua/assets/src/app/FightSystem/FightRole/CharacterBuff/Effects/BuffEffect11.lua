--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
    **效果类型ID=11，被动招式随机基本武学**

    * 效果功能执行：改为使用基本武学的被动招式，主动招式调用的平均普通气血伤害也是用基本武学的计算。

]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect11 = {}

function BuffEffect11:create()
    return BuffEffect11.new()
end

function BuffEffect11:updateEffectValue()
end

function BuffEffect11:makeEffectOnAdd()
    self.__buff:getBuffOwner():addBuffAddAttr("useBaseAttackSkill", 1)
end

function BuffEffect11:makeEffectOnRemove()
    self.__buff:getBuffOwner():addBuffAddAttr("useBaseAttackSkill", -1)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect11:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect11", {ABuffEffect}, BuffEffect11)
000000000000000