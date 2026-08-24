--[[
    **效果类型ID=131，武器属性固值修正N点**

    - 效果生效节点：无特殊触发节点，持有Buff期间生效
    - 效果功能执行：Buff有效期内，修正(增加或者减少)角色装备的武器属性。
    - 武器属性说明见：`fzjh_design\策划文档\z-战斗改版\新版战斗武器系统.md` 的【硬度】、【韧度】、【重量】、【打飞打断属性】部分。
    - effectTypeParam配置武器属性ID，格式：修正的具体属性ID查看 `表[角色属性管理]` 的【武器类】
    - argsParam配置修正的效果值公式ID，公式ID读取 `表[总Buff表效果伤害].id`。
        - 效果值=`表[总Buff表效果伤害].id` 对应返回结果值（小数）
    - 效果生效文本表现：无
    - 效果值叠加方式：同武器属性ID效果值N的总和。
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory#BuffEffectDamageCalculatorFactory]
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect131 = {}

function BuffEffect131:create()
    return BuffEffect131.new():__init()
end

function BuffEffect131:__init()
    self.__isInit = false

    self.__isCalValueInit = false

    return self
end

function BuffEffect131:updateEffectValue()
    if self.__isInit == false then
        self.__attrName = tostring(self.__basicEffect:getEffectTypeParam())

        self.__calculatorId = self.__basicEffect:getArgsParam()

        self.__isInit = true
    end

    self.__calValue = BuffEffectDamageCalculatorFactory:create(self.__calculatorId, self.__buff):getDamage()
end

function BuffEffect131:makeEffectOnAdd()
    if self.__isCalValueInit == false then
        self:updateEffectValue()
        self.__isCalValueInit = true
    end

    self.__addValue = self.__calValue

    FightUtil:printFormatLog("BuffEffect131：makeEffectOnAdd - %s 添加触发影响当前武器属性：%s， 影响值：%s", self.__buff:getBuffOwner():getAttr("name"), self.__attrName, self.__addValue)
    self.__buff:getBuffOwner():addBuffWeaponAddAttr(self.__attrName, self.__addValue)
end

function BuffEffect131:makeEffectOnRemove()
    FightUtil:printFormatLog("BuffEffect131：makeEffectOnRemove - %s 移除触发影响当前武器属性：%s， 影响值：%s", self.__buff:getBuffOwner():getAttr("name"), self.__attrName, -self.__addValue)
    self.__buff:getBuffOwner():addBuffWeaponAddAttr(self.__attrName, -self.__addValue)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect131:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect131", {ABuffEffect}, BuffEffect131)
0