--[[
    author:Seven
    time:2023-11-05 18:05:46
    desc:
]]
--[[
    author:Seven
    time:2023-10-31 19:51:21
    desc:
]]
local newClass = require("third.class.NewClass")

local HitAttackViewEventAction = require("app.FightSystem.Veiws.ViewEvents.EventActions.HitAttackViewEventAction")

local AudioResManager = require("app.FightSystem.ResourceManager.AudioResManager")

local AViewEventAction = require("app.FightSystem.Veiws.ViewEvents.EventActions.AViewEventAction")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.EventActions.HitAttackViewEventAction#HitAttackViewEventAction]
local ParryAttackViewEventAction = {}

function ParryAttackViewEventAction:create(mainView, ...)
    return ParryAttackViewEventAction.new():__init(mainView, ...)
end

function ParryAttackViewEventAction:ctor()
    self.__zhaoQiHurtPrefixText = "招架"
end

function ParryAttackViewEventAction:__targetOnHitAnim(pos, lastHit)
    if lastHit then
        if self.__targetViewCharacter:getAttr("qi") <= 0 then
            return self:__playDead(pos)
        end

        local lastResult = self.__zhaoAttack:getOneHitResult(self.__hurtIndex)
        local flyOrBlockInfo = lastResult:getTargetWeaponFlyOrBlockInfo()
        if flyOrBlockInfo ~= nil then
            return self:__flyOrBlockWeapon(flyOrBlockInfo, pos)
        end
    end

    local hurtAnim, hurtSound = self.__targetViewCharacter:getParryHurtAnimAndHurtSound(pos)
    self.__mainView:playCharacterAnim(
        self.__targetViewCharacter:getId(),
        hurtAnim,
        false,
        nil,
        function()
            if lastHit then
                self.__targetViewCharacter:setPositionH(0)
                self.__mainView:setCharacterAnimPosition(
                    self.__targetViewCharacter:getId(),
                    self.__targetViewCharacter:getPositionX(),
                    self.__targetViewCharacter:getPositionY(),
                    self.__targetViewCharacter:getPositionH()
                )

                self.__mainView:playCharacterAnim(self.__targetViewCharacter:getId(), self.__targetViewCharacter:getIdleAnimName(), false, nil, nil)
            end
        end
    )
    self.__mainView:playSound(AudioResManager:getSoundNameByRandom(hurtSound))
end

function ParryAttackViewEventAction:__playDead(pos)
    self.__targetViewCharacter:setDead(true)
    local deadAnim, deadSound = self.__targetViewCharacter:getDeadAnimAndDeadSound(pos)
    self.__mainView:playCharacterAnim(self.__targetViewCharacter:getId(), deadAnim, false)

    if deadSound then
        self.__mainView:playSound(AudioResManager:getSoundNameByRandom(deadSound))
    end
end

function ParryAttackViewEventAction:__flyOrBlockWeapon(flyOrBlockInfo, pos)
    self.__mainView:playCharacterAnim(self.__targetViewCharacter:getId(), flyOrBlockInfo.targetUnderHitAnim, false, nil, nil)
    local _, hurtSound = self.__targetViewCharacter:getParryHurtAnimAndHurtSound(pos)
    self.__mainView:playSound(AudioResManager:getSoundNameByRandom(hurtSound))
    
    local desc = flyOrBlockInfo.printText
    if desc then
        self.__mainView:printText(desc)
    end
end

return newClass("ParryAttackViewEventAction", {HitAttackViewEventAction}, ParryAttackViewEventAction)
0000000000000