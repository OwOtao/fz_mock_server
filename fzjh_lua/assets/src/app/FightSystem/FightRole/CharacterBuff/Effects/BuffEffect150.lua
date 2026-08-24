--[[
    desc: 
        **效果类型ID=150，激活角色特殊战斗属性实际承伤值**

        * 效果触发节点：无特殊触发节点，持有Buff期间生效
            * 效果功能执行：持有当前效果才会在受伤害扣除气血时记录；当效果结束会使实际承伤值清0；实际承伤值的具体记录伤害功能见：角色战斗属性与战斗伤害.md - 角色特殊战斗属性 - 实际承伤值
                * 如果角色持有多个效果类型ID=150的Buff，不影响增加的实际承伤值，需要多个效果类型ID=150的Buff全部消失，当前实际承伤值才会清0
        * 效果生效表现：无
        * 效果值叠加方式：持有即激活效果，不影响实际承伤值本身
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect150 = {}

function BuffEffect150:create()
    return BuffEffect150.new():__init()
end

function BuffEffect150:__init()
    return self
end

function BuffEffect150:updateEffectValue()
end

function BuffEffect150:makeEffectOnAdd()
    self.__buff:getBuffOwner():addBuffAddAttr("RecordDamageBuffNum", 1)
end

function BuffEffect150:makeEffectOnRemove()
    local value = self.__buff:getBuffOwner():addBuffAddAttr("RecordDamageBuffNum", -1)

    if value <= 0 then
        self.__buff:getBuffOwner():setAttr("recordDamage", 0)
    end
end

function BuffEffect150:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect150", {ABuffEffect}, BuffEffect150)
000000000000