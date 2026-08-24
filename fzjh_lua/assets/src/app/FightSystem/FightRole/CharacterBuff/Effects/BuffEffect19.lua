--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
        **效果类型ID=19，被动攻击必定被轻功闪躲**
        
        * 效果触发节点：13=造成被动招式攻击判定命中、15=造成被动招式攻击判定普通招架
        * 效果功能执行：闪躲率=100%
            * 如果被动攻击目标持有**效果类型ID=3，禁用轻功闪躲**，禁用优先，本次效果不执行。
            * 对应规则可产看[角色战斗属性与战斗伤害](./角色战斗属性与战斗伤害.md) - 受击者伤害结算流程
        * 效果生效表现：无
]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect19 = {}

function BuffEffect19:create()
    return BuffEffect19.new()
end

function BuffEffect19:updateEffectValue()
end

function BuffEffect19:makeEffectOnAdd()
    self.__buff:getBuffOwner():addBuffAddAttr("beAutoDodge", 1)
end

function BuffEffect19:makeEffectOnRemove()
    self.__buff:getBuffOwner():addBuffAddAttr("beAutoDodge", -1)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect19:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect19", {ABuffEffect}, BuffEffect19)
00000000000