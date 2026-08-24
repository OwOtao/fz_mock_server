--[[
    效果类型ID=132，武器打断打飞属性固值覆盖修正N点
        效果生效节点：无特殊触发节点，持有Buff期间生效
        效果功能执行：Buff有效期内，覆盖修正角色当前正在战斗中使用的武器打断打飞属性。
        武器属性说明见：fzjh_design\策划文档\z-战斗改版\新版战斗武器系统.md 的【打飞打断属性】部分。
            effectTypeParam配置武器属性ID，格式：修正的具体属性ID查看 表[角色属性管理] 的【武器类】的【打飞打断属性】
            argsParam配置覆盖修正效果值，可填正负整数
        效果生效文本表现：无
        效果值叠加方式：同武器打断打飞属性ID效果值N的最小值。
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory#BuffEffectDamageCalculatorFactory]
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect132 = {}

function BuffEffect132:create()
    return BuffEffect132.new():__init()
end

function BuffEffect132:__init()
    self.__isInit = false

    self.__isCalValueInit = false

    return self
end

function BuffEffect132:updateEffectValue()
    if self.__isInit == false then
        self.__attrName = tostring(self.__basicEffect:getEffectTypeParam())
        self.__isInit = true
    end
    
    self.__calValue = tonumber(self.__basicEffect:getArgsParam())

    if self.__calValue == nil then
        assert(false,"ArgsParam 配置错误，不支持除数值以外的其余类型，id =" .. tostring(self.__basicEffect:getEffectID()))
    end
end

function BuffEffect132:makeEffectOnAdd()
    if self.__isCalValueInit == false then
        self:updateEffectValue()
        self.__isCalValueInit = true
    end

    self.__addValue = self.__calValue

    FightUtil:printFormatLog("BuffEffect132：makeEffectOnAdd - %s 添加触发影响当前武器属性：%s， 影响值：%s", self.__buff:getBuffOwner():getAttr("name"), self.__attrName, self.__addValue)
    self.__onlyId = self.__buff:getBuffOwner():addBuffMinValue(self.__attrName, self.__addValue, self.__basicEffect:getEffectID())
end

function BuffEffect132:makeEffectOnRemove()
    FightUtil:printFormatLog("BuffEffect132：makeEffectOnRemove - %s 移除触发影响当前武器属性：%s， 影响值：%s", self.__buff:getBuffOwner():getAttr("name"), self.__attrName, -self.__addValue)
    self.__buff:getBuffOwner():removeBuffMinValue(self.__attrName, self.__onlyId)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect132:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect132", {ABuffEffect}, BuffEffect132)
000000