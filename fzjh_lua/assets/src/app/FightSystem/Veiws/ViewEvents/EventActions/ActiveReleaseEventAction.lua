--[[
    author:Seven
    time:2023-11-13 16:23:04
    desc: 主动技能释放流程
]]
local newClass = require("third.class.NewClass")

local AudioResManager = require("app.FightSystem.ResourceManager.AudioResManager")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local Vector2Tween = require("third.dotween.Vector2Tween")

local AViewEventAction = require("app.FightSystem.Veiws.ViewEvents.EventActions.AViewEventAction")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.EventActions.AViewEventAction#AViewEventAction]
local ActiveReleaseEventAction = {}

function ActiveReleaseEventAction:create(mainView, ...)
    return ActiveReleaseEventAction.new():__init(mainView, ...)
end

function ActiveReleaseEventAction:__init(mainView, context, zhaoAttack, buffContext)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context

    --@RefType [FightMainView]
    self.__mainView = mainView

    --@RefType [src.app.FightSystem.ZhaoAttacks.None.AcitveAtkRelease#AcitveAtkRelease]
    self.__zhaoAttack = zhaoAttack

    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffContext.IBuffContext#IBuffContext]
    self.__buffContext = assert(buffContext)

    self.__viewCharacter = self.__mainView:getViewCharacter(self.__context:getAttacker():getId())

    self.__mainView:playSound(AudioResManager:getSoundNameByRandom(self.__zhaoAttack:getAttackerSoundId()))

    local animName = self.__zhaoAttack:getAttackerAnim()

    FightUtil:printFormatLog("ActiveReleaseEventAction:播放攻击动画:%s", tostring(animName))

    self.__mainView:playCharacterAnim(
        self.__context:getAttacker():getId(),
        animName,
        false,
        function(event)
            if string.find(event.name, "oneOffEffect_", 1) ~= nil then
                self:__playOneOffEffects(event.name)
            end
        end,
        function()
            self.__mainView:playCharacterAnim(self.__viewCharacter:getId(), self.__viewCharacter:getIdleAnimName(), false, nil, nil)
            self:finish()
        end
    )

    return self
end

function ActiveReleaseEventAction:__playOneOffEffects(animEventName)
    local list = self.__buffContext:popOneOffEffects(animEventName)

    if #list <= 0 then
        return
    end

    for _, oneOffEffect in ipairs(list) do
        FightUtil:printFormatLog("ActiveReleaseEventAction:播放一次性特效:%s , 目标id：%s", tostring(oneOffEffect.animId), tostring(oneOffEffect.targetId))
        self.__mainView:playOneOffEffectAnim(oneOffEffect.targetId, AnimResManager:getOtherAnimName(oneOffEffect.animId))
    end
end

function ActiveReleaseEventAction:updateEventAction(dt)
end

return newClass("ActiveReleaseEventAction", {AViewEventAction}, ActiveReleaseEventAction)
0000000000000