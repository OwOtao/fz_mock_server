--[[
    author:Seven
    time:2023-02-17 15:19:38
    desc: 普通格挡气血伤害
]]
local newClass = require("third.class.NewClass")
local BasicQiAttackHurt = require("app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

--@SuperType [src.app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt#BasicQiAttackHurt]
local ParryQiAttackHurt = {}

function ParryQiAttackHurt:create(damageType)
    return ParryQiAttackHurt.new():__init(damageType)
end

function ParryQiAttackHurt:setParryQiHurtFactor(value)
    self.__parryqiHurtFactor = value
end

function ParryQiAttackHurt:__initOriginValue()
    local parrySuccessQiHurtScaleCorrectionFactor = BattleConstConf:get("parrySuccessQiHurtScaleCorrectionFactor")

    self.__originValue = self.__combHurt:getHurtValue() * self.__allocPercent * (1 - parrySuccessQiHurtScaleCorrectionFactor - self.__parryqiHurtFactor)
end

return newClass("ParryQiAttackHurt", {BasicQiAttackHurt}, ParryQiAttackHurt)
0