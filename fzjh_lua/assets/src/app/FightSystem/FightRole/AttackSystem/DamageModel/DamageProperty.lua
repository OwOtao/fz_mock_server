local newClass = require("third.class.NewClass")

local ADamageProperty = require("app.FightSystem.FightRole.AttackSystem.DamageModel.ADamageProperty")

--@SuperType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.DamageProperty#ADamageProperty]
local DamageProperty = {}

function DamageProperty:create()
    return DamageProperty.new()
end

function DamageProperty:__initAllocPercent()
    self.__allocPercent = (self.__zhaoAllocWeight / self.__combtTotalWeight) * (self.__animAllocWeight / self.__animHurtTotalWeight)
end

function DamageProperty:calActualValue()
    self:__initAllocPercent()

    self.__allocProjectedValue = self.__projectedValue * self.__allocPercent

    self.__actualValue = self.__allocProjectedValue
end

return newClass("DamageProperty", {ADamageProperty}, DamageProperty)
00000000000000