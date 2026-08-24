--[[
    攻击伤害信息
]]
local class = require("third.class.NewClass")

local Hurt = {
    __attrName = "",
    __value = 0,
    --@desc 伤害描述 对应AttackDamageDescManager中damageType和damageStage信息，填写格式“damageType#damageStage”
    __hurtDesc = nil,
    __descDamageType = nil,
    __descDamageStage = nil
}

function Hurt:create()
    return self:new()
end

function Hurt:setAttrName(name)
    self.__attrName = name
end

function Hurt:getAttrName()
    return self.__attrName
end

function Hurt:setHurtValue(value)
    self.__value = value
end

function Hurt:getHurtValue()
    return self.__value
end

function Hurt:setHurtDesc(str)
    local list = string.split(str, "#")

    local damageType = list[1]

    local damageStage = list[2]

    if damageType == nil or damageStage == nil then
        error("攻击伤害文本信息设置：参数格式错误（damageType#damageStage）, 传入参数：" .. str)
    end
    self.__hurtDesc = str

    self.__descDamageType = damageType

    self.__descDamageStage = damageStage
end

function Hurt:getHurtDesc()
    return self.__hurtDesc
end

function Hurt:getDescDamageType()
    return self.__descDamageType
end

function Hurt:getDescDamageStage()
    return self.__descDamageStage
end

--@desc: 根据权重进行对象创建
--@author:Seven
--@time:2021-07-17 16:41:34
--@totalWeight: 总权重
--@allocWeight: 分配权重
--@return [src.app.FightSystem.AttackModel.Hurt#Hurt]
function Hurt:allocByWeight(totalWeight, allocWeight)
    --@RefType [src.app.FightSystem.AttackModel.Hurt#Hurt]
    local newHurt = Hurt:create()

    local percent = allocWeight / totalWeight

    newHurt:setAttrName(self:getAttrName())

    newHurt:setHurtValue(self:getHurtValue() * percent)

    if self:getHurtDesc() ~= nil then
        newHurt:setHurtDesc(self:getHurtDesc())
    end

    return newHurt
end

return class("Hurt", {}, Hurt)
0000000000000