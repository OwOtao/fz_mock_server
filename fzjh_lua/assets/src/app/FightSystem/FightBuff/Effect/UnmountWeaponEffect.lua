local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local Constants = require("app.FightSystem.FightBuff.Constants")

local UnmountWeaponEffect = {}

function UnmountWeaponEffect:create(effect, buffNeeded)
    local p = UnmountWeaponEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function UnmountWeaponEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function UnmountWeaponEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    self.__weaponState = assert(self.__effect:getEffectTypeParam()[1], "AutoParryAddCurrAttrEffect:__init() error, effectTypeParam[1] is nil")
end

function UnmountWeaponEffect:tryTrigger(eventType, eventParam)
    if eventType == Constants.BuffTriggerType.Add then
        if self.__buffNeeded:getTargetWeaponType() ~= "空手" then
            return true
        end
    end
    return false
end

-- 获得卸载武器的状态
function UnmountWeaponEffect:getWeaponState()
    return self.__weaponState
end

return class("UnmountWeaponEffect", {ActiveEffect}, UnmountWeaponEffect)
00