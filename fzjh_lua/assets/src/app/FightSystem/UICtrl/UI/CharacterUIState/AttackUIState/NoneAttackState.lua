local class = require("third.class.NewClass")

local BaseCharacterUIState = require("app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local AudioResManager = require("app.FightSystem.ResourceManager.AudioResManager")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [src.third.dotween.DoTween#DoTween]
local DoTween = require("third.dotween.DoTween")

--@SuperType [src.app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState#BaseCharacterUIState]
local NoneAttackState = {}

function NoneAttackState:onInit()
end

function NoneAttackState:onEnter(params)
    --@RefType[src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkNone#AtkNone]
    local zhaoAttack = params.zhaoAtk

    local aninName = self.__animName
    local attackAnims = zhaoAttack:getAttackAnims()

    if aninName then
        FightUtil:printLog("$$UI Render NoneAttackState:onEnter$$ ", self.__ctrl:getVmAttr("name"), "纯播放动画：", self.__animName)

        self.__ctrl:playAnim(aninName, false)
    end

    self.__ctrl:playSound(AudioResManager:getSoundNameByRandom(attackAnims:getAttackerSoundId()))
end

function NoneAttackState:onLeave()
end

function NoneAttackState:onUpdate(ft)
end

return class("NoneAttackState", {BaseCharacterUIState}, NoneAttackState)
00