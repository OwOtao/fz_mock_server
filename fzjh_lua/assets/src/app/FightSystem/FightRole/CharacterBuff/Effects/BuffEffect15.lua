--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
        **效果类型ID=15，战斗中将Buff持有者的武器卸下**

        * 效果功能执行：Buff添加后，立刻将Buff持有者的武器改为拳脚、并将武器的战斗状态改为指定状态，对应武器皮肤、武学、主动等都一起修改。被改变武器的角色，已经在攻击队列的主动会自动取消。
            * 被修改的武器指定战斗状态配置在 `效果类型参数;effectTypeParam`
                * 战斗状态包含：正常（normal）、击飞（fly）、损坏（destroy）、丢弃（giveUp）

        * 效果生效表现：无特殊表现。

        * 效果值叠加方式：无
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [Constants]
local BUFF_CONSTANS = require("app.FightSystem.FightBuff.Constants")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect15 = {}

function BuffEffect15:create()
    return BuffEffect15.new():__init()
end

function BuffEffect15:__init()
    self.__isInit = false

    return self
end

function BuffEffect15:updateEffectValue()
    self.__umountWeaponState = self.__basicEffect:getEffectTypeParam()
end

function BuffEffect15:makeEffectOnAdd()

    
    if self.__isInit == false then
        self:updateEffectValue()
        self.__isInit = true
    end

    local owner = self.__buff:getBuffOwner()

    if owner:weaponIsEmptyHand() then
        return
    end

    local prevWeapon = owner:getWeapon()

    owner:unmountCharacterWeapon()

    prevWeapon:updateFightState(self.__umountWeaponState)

    local prepActMap = {}
    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local activeSkill = owner:getPrepActiveSkillByPosIndex(i)
        if activeSkill then
            prepActMap[tostring(i)] = activeSkill
        end
    end

    self.__buff:getBuffOwner():getFight():notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.PlayerRefreshAcitveSkillsViewEvent":create(owner:getId(), prepActMap))
end

function BuffEffect15:makeEffectOnRemove()
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect15:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect15", {ABuffEffect}, BuffEffect15)
0000