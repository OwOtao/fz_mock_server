local class = require("third.class.NewClass")

local HitAttackState = require("app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.HitAttackState")

--@SuperType [src.app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.HitAttackState#HitAttackState]
local NormalParryAttackState = {}

function NormalParryAttackState:onInit()
    self.onInit(HitAttackState)
    self.__underHitVisitorClass = require("app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.UnderHitVisitors.UnderHitVisitorOfNormalParryState")
end

function NormalParryAttackState:__doLastHit(event)
    if self.__targetCtrl:getVmAttr("qi") <= 0 then
        self.__targetCtrl:playDeadAnim(event.stringValue)
        return
    end

    if self.__zhaoAtk:getTargetWeaponBlock() or self.__zhaoAtk:getTargetWeaponFly() then
        local targetViewInfo = self.__zhaoAtk:getTargetWeaponBlockOrFlyInfo()

        self.__targetCtrl:playAnim(targetViewInfo.targetUnderHitAnim, false)

        self.__targetCtrl:changeWeapon(targetViewInfo.weapon)

        self.__targetCtrl:setStandAnim(targetViewInfo.viewInfo.stand_anim)

        self.__targetCtrl:setJoinAnim(targetViewInfo.viewInfo.join_anim)

        self.__targetCtrl:setJumpForwardAnim(targetViewInfo.viewInfo.jumpForwardAnim)

        self.__targetCtrl:setJumpBackAnim(targetViewInfo.viewInfo.jumpbackAnim)

        self.__targetCtrl:changeAllActiveSkills(targetViewInfo.activeSkillVm)

        return
    end

    local hurtAnimName, soundFileName = self.__attackAnims:getTargetAnimNameAndSoundName(event.stringValue)
    self.__targetCtrl:playAnim(hurtAnimName, false)
    self.__targetCtrl:playSound(soundFileName)
end

return class("NormalParryAttackState", {HitAttackState}, NormalParryAttackState)
000000000000000