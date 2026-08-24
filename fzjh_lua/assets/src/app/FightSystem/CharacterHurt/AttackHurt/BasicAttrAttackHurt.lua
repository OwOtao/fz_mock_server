--[[
    author:Seven
    time:2023-02-07 20:34:45
    desc: 基本属性伤害计算类
]]
local newClass = require("third.class.NewClass")
local ABasicAttackHurt = require("app.FightSystem.CharacterHurt.AttackHurt.ABasicAttackHurt")

--@SuperType [src.app.FightSystem.CharacterHurt.AttackHurt.ABasicAttackHurt#ABasicAttackHurt]
local BasicAttrAttackHurt = {}

function BasicAttrAttackHurt:create()
    return BasicAttrAttackHurt.new()
end

--@desc: 当击中时执行的计算
--@author:Seven
--@time:2023-02-08 11:17:20
--@attacker: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@target:  [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function BasicAttrAttackHurt:inAttack(attacker, target)
    self.__value = self.__originValue
    target:addAttr(self.__attrName, -self.__value)
end

return newClass("BasicAttrAttackHurt", {ABasicAttackHurt}, BasicAttrAttackHurt)
0000000000