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
local OnlyPlayAnimEventAction = {}

function OnlyPlayAnimEventAction:create(mainView, ...)
    return OnlyPlayAnimEventAction.new():__init(mainView, ...)
end

function OnlyPlayAnimEventAction:__init(mainView, context, zhaoAttack)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context

    --@RefType [FightMainView]
    self.__mainView = mainView

    --@RefType [src.app.FightSystem.ZhaoAttacks.None.BasicAtkNone#BasicAtkNone]
    self.__zhaoAttack = zhaoAttack

    self.__viewCharacter = self.__mainView:getViewCharacter(self.__context:getAttacker():getId())

    self.__mainView:playSound(AudioResManager:getSoundNameByRandom(self.__zhaoAttack:getAttackerSoundId()))

    local animName = self.__zhaoAttack:getAttackerAnim()

    FightUtil:printFormatLog("OnlyPlayAnimEventAction:播放攻击动画:%s", animName)

    self.__mainView:playCharacterAnim(
        self.__context:getAttacker():getId(),
        animName,
        false,
        function(event)
        end,
        function()
            self.__mainView:playCharacterAnim(self.__viewCharacter:getId(), self.__viewCharacter:getIdleAnimName(), false, nil, nil)
            self:finish()
        end
    )

    return self
end

function OnlyPlayAnimEventAction:updateEventAction(dt)
end

return newClass("OnlyPlayAnimEventAction", {AViewEventAction}, OnlyPlayAnimEventAction)
00000