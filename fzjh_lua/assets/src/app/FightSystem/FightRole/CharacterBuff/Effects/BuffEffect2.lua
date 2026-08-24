--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 效果类型2

        效果功能：拥有该效果时无法使用指定类型主动招式

        effectTypeParam 格式：主动类型ID
            主动类型ID=0，所有主动；
            主动类型ID=1，主动招式攻击类；对应 表[武功主动招式组合].主动招式类型;activeType = 1
            主动类型ID=2，主动招式释放类；对应 表[武功主动招式组合].主动招式类型;activeType = 2
            主动类型ID=11，武学攻击准备位的主动；对应 表[武功主动招式组合].主动招式使用对应准备武学类型;methods = 1 或 5
            主动类型ID=12，武学内功准备位的主动；对应 表[武功主动招式组合].主动招式使用对应准备武学类型;methods = 2
            主动类型ID=13，武学轻功准备位的主动；对应 表[武功主动招式组合].主动招式使用对应准备武学类型;methods = 3
            主动类型ID=14，武学招架准备位的主动；对应 表[武功主动招式组合].主动招式使用对应准备武学类型;methods = 4
]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect2 = {}

function BuffEffect2:create()
    return BuffEffect2.new():__init()
end

function BuffEffect2:__init()
    self.__isInit = false
    return self
end

function BuffEffect2:updateEffectValue()
    self.__banActiveType = self.__basicEffect:getEffectTypeParam()
    self.__tips = self.__basicEffect:getActiveEffectUseZhaoTips()
end

function BuffEffect2:makeEffectOnAdd()
    if self.__isInit == false then
        self:updateEffectValue()
        self.__isInit = true
    end

    self.__banIndex = self.__buff:getBuffOwner():addBanActiveAttack(self.__banActiveType, self.__tips)
end

function BuffEffect2:makeEffectOnRemove()
    self.__buff:getBuffOwner():removeBanActiveAttack(self.__banActiveType, self.__banIndex)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect2:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect2", {ABuffEffect}, BuffEffect2)
00000000000