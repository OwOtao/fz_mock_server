--[[
    author:Seven
    time:2023-03-24 20:01:08
    desc: 一个招式攻击的抽象伤害类
]]
local newClass = require("third.class.NewClass")

local ABasicHurt = require("app.FightSystem.CharacterHurt.ABasicHurt")

--@SuperType [src.app.FightSystem.CharacterHurt.ABasicHurt#ABasicHurt]
local AAttackHurt = {
    __hurtDesc = nil,
    __damageType = nil,
    __damageStage = nil,
    --@desc 是否可穿透当前属性的护盾
    __bypassShield = false
}

function AAttackHurt:__setHurtDesc(str)
    local list = string.split(str, "#")

    local damageType = list[1]

    local damageStage = list[2]

    if damageType == nil or damageStage == nil then
        error("攻击伤害文本信息设置：参数格式错误（damageType#damageStage）, 传入参数：" .. str)
    end
    self.__hurtDesc = str

    self.__damageType = damageType

    self.__damageStage = damageStage
end

function AAttackHurt:getHurtDesc()
    return self.__hurtDesc
end

function AAttackHurt:getDamageType()
    return self.__damageType
end

function AAttackHurt:getDamageStage()
    return self.__damageStage
end

function AAttackHurt:__setBypassShield(isbool)
    self.__bypassShield = isbool
end

function AAttackHurt:isBypassShield()
    return self.__bypassShield
end

return newClass("AAttackHurt", {ABasicHurt}, AAttackHurt)
0000000000