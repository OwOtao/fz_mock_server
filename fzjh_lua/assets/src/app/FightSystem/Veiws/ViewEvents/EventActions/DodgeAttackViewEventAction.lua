--[[
    author:Seven
    time:2023-11-05 18:05:46
    desc:
]]
local newClass = require("third.class.NewClass")

local AudioResManager = require("app.FightSystem.ResourceManager.AudioResManager")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local Vector2Tween = require("third.dotween.Vector2Tween")

local AViewEventAction = require("app.FightSystem.Veiws.ViewEvents.EventActions.AViewEventAction")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.EventActions.AViewEventAction#AViewEventAction]
local DodgeAttackViewEventAction = {}

function DodgeAttackViewEventAction:create(mainView, ...)
    return DodgeAttackViewEventAction.new():__init(mainView, ...)
end

function DodgeAttackViewEventAction:__init(mainView, context, zhaoAttack)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context

    --@RefType [FightMainView]
    self.__mainView = mainView

    --@RefType [src.app.FightSystem.ZhaoAttacks.Dodge.BasicAtkDodge#BasicAtkDodge]
    self.__zhaoAttack = zhaoAttack

    self.__firstHurted = true

    self.__isStartDodge = false

    self.__duration = 0

    --@RefType [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
    self.__attackerViewCharacter = self.__mainView:getViewCharacter(self.__context:getAttacker():getId())

    --@RefType [src.app.FightSystem.Veiws.ViewCommonModel.Character.ViewCharacter#ViewCharacter]
    self.__targetViewCharacter = self.__mainView:getViewCharacter(self.__context:getTarget():getId())

    self:__initStart()

    self:__initAttackerPosTween()

    self:__playAttackerAnim()

    return self
end

function DodgeAttackViewEventAction:updateEventAction(dt)
    if self.__duration >= self.__zhaoAttack:getDuration() then
        self:finish()
        return
    end

    if self.__vector2Tween then
        self.__vector2Tween:update(dt)
    end

    if self.__isStartDodge == false and self.__duration >= self.__zhaoAttack:getTargetStartMoveTime() then
        self:__playTargetDodge()
        self.__isStartDodge = true
    end

    self:__updateTargetPos(dt)

    self.__duration = self.__duration + dt
end

function DodgeAttackViewEventAction:__initStart()
    local offsetX = AnimResManager:getAttackAnimOffset(self.__zhaoAttack:getAttackerAnim())
    self.__offsetX = offsetX
    self.__dirFactor = self.__attackerViewCharacter:getScaleX()
    self.__targetStartPos = self.__targetViewCharacter:getPosition()
    self.__attackStartPos = {
        x = self.__targetStartPos.x + offsetX * -self.__dirFactor,
        y = self.__targetStartPos.y,
        h = self.__targetStartPos.h
    }

    self.__hitBindOffsetX = self.__targetStartPos.x

    local events = AnimResManager:getAnimHurtEvents(self.__zhaoAttack:getAttackerAnim())

    self.__hitPart = events[1].stringValue
end

function DodgeAttackViewEventAction:__initAttackerPosTween()
    local events = AnimResManager:getAnimHurtEvents(self.__zhaoAttack:getAttackerAnim())

    if #events == 0 then
        return
    end

    self.__vector2Tween =
        Vector2Tween:create(
        function()
            local pos = self.__attackerViewCharacter:getPosition()
            return cc.p(pos)
        end,
        function(pos)
            self.__attackerViewCharacter:setPositionX(pos.x)

            self.__attackerViewCharacter:setPositionY(pos.y)

            local pos = self.__attackerViewCharacter:getPosition()

            self.__mainView:setCharacterAnimPosition(self.__attackerViewCharacter:getId(), pos.x, pos.y, pos.h)
        end,
        {
            x = self.__attackStartPos.x,
            y = self.__attackStartPos.y - 0.1
        },
        events[1].time / 2
    ):withEase()
end

function DodgeAttackViewEventAction:__updateTargetPos(dt)
    local cornerOffsetX = 0

    if self.__canUpdateBingding == true then
        --@desc 改变
        local boneData = self.__mainView:getCharacterBonePosition(self.__attackerViewCharacter:getId(), "AttackPosition")
        local tar_pos_x = self.__attackStartPos.x + (boneData.x * self.__dirFactor)

        if self.__hitBindOffsetX ~= tar_pos_x then
            local offsetX = tar_pos_x - self.__hitBindOffsetX
            self.__hitBindOffsetX = tar_pos_x

            self.__targetViewCharacter:setPositionX(self.__targetViewCharacter:getPositionX() + offsetX)

            self.__mainView:setCharacterAnimPosition(
                self.__targetViewCharacter:getId(),
                self.__targetViewCharacter:getPositionX(),
                self.__targetViewCharacter:getPositionY(),
                self.__targetViewCharacter:getPositionH()
            )

            cornerOffsetX = offsetX
        end
    end

    local tar_pos_x = self.__targetViewCharacter:getPositionX()

    -- 卡墙角
    if tar_pos_x > 1000 then
        local offset = 1000 - tar_pos_x

        self.__attackerViewCharacter:setPositionX(self.__attackerViewCharacter:getPositionX() + offset + cornerOffsetX)

        self.__mainView:setCharacterAnimPosition(
            self.__attackerViewCharacter:getId(),
            self.__attackerViewCharacter:getPositionX(),
            self.__attackerViewCharacter:getPositionY(),
            self.__attackerViewCharacter:getPositionH()
        )

        self.__attackStartPos = self.__attackerViewCharacter:getPosition()

        self.__hitBindOffsetX = self.__hitBindOffsetX + offset
        tar_pos_x = 1000
    elseif tar_pos_x < 80 then
        local offset = 80 - tar_pos_x

        self.__attackerViewCharacter:setPositionX(self.__attackerViewCharacter:getPositionX() + offset + cornerOffsetX)

        self.__mainView:setCharacterAnimPosition(
            self.__attackerViewCharacter:getId(),
            self.__attackerViewCharacter:getPositionX(),
            self.__attackerViewCharacter:getPositionY(),
            self.__attackerViewCharacter:getPositionH()
        )

        self.__attackStartPos = self.__attackerViewCharacter:getPosition()

        self.__hitBindOffsetX = self.__hitBindOffsetX + offset
        tar_pos_x = 80
    end

    self.__targetViewCharacter:setPositionX(tar_pos_x)
    self.__mainView:setCharacterAnimPosition(
        self.__targetViewCharacter:getId(),
        self.__targetViewCharacter:getPositionX(),
        self.__targetViewCharacter:getPositionY(),
        self.__targetViewCharacter:getPositionH()
    )
end

function DodgeAttackViewEventAction:__playAttackerAnim()
    self.__mainView:playCharacterAnim(
        self.__attackerViewCharacter:getId(),
        self.__zhaoAttack:getAttackerAnim(),
        false,
        function(event)
            if event.name == "Hurt" and self.__firstHurted == true then
                self.__vector2Tween = nil
                self.__firstHurted = false
                self.__canUpdateBingding = true
                self.__mainView:popHeadTextInAnimView(self.__targetViewCharacter:getId(), "闪避")
            end
        end
    )
end

function DodgeAttackViewEventAction:__playTargetDodge()
    -- local dodgeAnim
    local anim, sound, offset = self.__targetViewCharacter:getDodgeAnimAndSound(self.__hitPart)

    self.__mainView:playCharacterAnim(self.__targetViewCharacter:getId(), anim, false)
    self.__mainView:playSound(AudioResManager:getSoundNameByRandom(sound))

    self.__mainView:doUITween(
        Vector2Tween:create(
            function()
                local pos = self.__targetViewCharacter:getPosition()
                return cc.p(pos)
            end,
            function(next)
                self.__targetViewCharacter:setPositionX(next.x)
                self.__targetViewCharacter:setPositionY(next.y)
                local pos = self.__targetViewCharacter:getPosition()
                self.__mainView:setCharacterAnimPosition(self.__targetViewCharacter:getId(), pos.x, pos.y, pos.h)
            end,
            {
                x = self.__targetStartPos.x + self.__dirFactor * offset,
                y = self.__targetStartPos.y
            },
            self.__zhaoAttack:getTargetMoveBackDuration()
        )
    ):onComplete(
        function()
            self.__mainView:playCharacterAnim(self.__targetViewCharacter:getId(), self.__targetViewCharacter:getIdleAnimName(), true)
        end
    )
end

return newClass("DodgeAttackViewEventAction", {AViewEventAction}, DodgeAttackViewEventAction)
0000