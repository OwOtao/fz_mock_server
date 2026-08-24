--[[
    攻击伤害信息
]]
local class = require("third.class.NewClass")

local AttackHurtInfo = {
    __attrName = "",
    __value = 0,
    --@desc 伤害描述 对应AttackDamageDescManager中damageType和damageStage信息，填写格式“damageType#damageStage”
    __hurtDesc = nil,
    __descDamageType = nil,
    __descDamageStage = nil
}

function AttackHurtInfo:create()
    return self.new()
end

function AttackHurtInfo:setAttrName(name)
    self.__attrName = name
end

function AttackHurtInfo:getAttrName()
    return self.__attrName
end

function AttackHurtInfo:setHurtValue(value)
    self.__value = value
end

function AttackHurtInfo:getHurtValue()
    return self.__value
end

function AttackHurtInfo:setHurtDesc(str)
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

function AttackHurtInfo:getHurtDesc()
    return self.__hurtDesc
end

function AttackHurtInfo:getDescDamageType()
    return self.__descDamageType
end

function AttackHurtInfo:getDescDamageStage()
    return self.__descDamageStage
end

return class("AttackHurtInfo", {}, AttackHurtInfo)
0000000000000