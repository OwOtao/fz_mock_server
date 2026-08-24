--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
        **效果类型ID=20，被动攻击必定被普通招架**

        * 效果触发节点：13=造成被动招式攻击判定命中、14=造成被动招式攻击判定轻功闪躲
        * 效果功能执行：招架率=100%
            * 如果被动攻击目标持有**效果类型ID=5，禁用普通招架**，禁用优先，本次效果不执行。
            * 对应规则可产看[角色战斗属性与战斗伤害](./角色战斗属性与战斗伤害.md) - 受击者伤害结算流程
        * 效果生效表现：无
]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect20 = {}

function BuffEffect20:create()
    return BuffEffect20.new()
end

function BuffEffect20:updateEffectValue()
end

function BuffEffect20:makeEffectOnAdd()
    self.__buff:getBuffOwner():addBuffAddAttr("beAutoParry", 1)
end

function BuffEffect20:makeEffectOnRemove()
    self.__buff:getBuffOwner():addBuffAddAttr("beAutoParry", -1)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect20:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect20", {ABuffEffect}, BuffEffect20)
000