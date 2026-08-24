--[[
    author:Seven
    time:2023-10-31 19:51:21
    desc:
]]
local newClass = require("third.class.NewClass")

local AViewEventAction = require("app.FightSystem.Veiws.ViewEvents.EventActions.AViewEventAction")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local AudioResManager = require("app.FightSystem.ResourceManager.AudioResManager")

local Vector2Tween = require("third.dotween.Vector2Tween")

--@SuperType [src.app.FightSystem.Veiws.ViewEvents.EventActions.AViewEventAction#AViewEventAction]
local HitAttackViewEventAction = {}

function HitAttackViewEventAction:create(mainView, ...)
    return HitAttackViewEventAction.new():__init(mainView, ...)
end

function HitAttackViewEventAction:ctor()
    self.__zhaoQiHurtPrefixText = ""
end

function HitAttackViewEventAction:__init(mainView, context, zhaoAttack, buffContext)
    --@RefType [FightMainView]
    self.__mainView = mainView

    --@desc 当前攻击的上下文对象
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context

    --@desc 当前招式击中对象
    --@RefType [src.app.FightSystem.ZhaoAttacks.Hit.BasicAtkHit#BasicAtkHit]
    self.__zhaoAttack = assert(zhaoAttack)

    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffContext.IBuffContext#IBuffContext]
    self.__buffContext = assert(buffContext)

    self.__attackerId = self.__context:getAttacker():getId()

    self.__targetId = self.__context:getTarget():getId()

    self.__attackerViewCharacter = self.__mainView:getViewCharacter(self.__attackerId)

    self.__targetViewCharacter = self.__mainView:getViewCharacter(self.__targetId)

    self:__initStartPos()

    self:__initAttackerPosTween()

    self:__initAttackAnim()

    return self
end

function HitAttackViewEventAction:updateEventAction(dt)
    if self.__vector2Tween then
        self.__vector2Tween:update(dt)
        return
    end

    if self.__canUpdateBingding == true then
        self:__updateTargetPos(dt)
    end
end

function HitAttackViewEventAction:__updateTargetPos(dt)
    --@desc 改变
    local boneData = self.__mainView:getCharacterBonePosition(self.__attackerViewCharacter:getId(), "AttackPosition")

    if math.abs(boneData.x) > 1 then
        local tar_pos_x = self.__attackStartPos.x + (boneData.x * self.__dirFactor)
        local tar_pos_y = self.__targetStartPos.y
        local tar_pos_h = self.__attackStartPos.h + boneData.y

        -- 卡墙角
        if tar_pos_x > 1000 then
            local offset = 1000 - tar_pos_x

            self.__attackerViewCharacter:setPositionX(self.__attackerViewCharacter:getPositionX() + offset)

            self.__mainView:setCharacterAnimPosition(
                self.__attackerViewCharacter:getId(),
                self.__attackerViewCharacter:getPositionX(),
                self.__attackerViewCharacter:getPositionY(),
                self.__attackerViewCharacter:getPositionH()
            )

            self.__attackStartPos = self.__attackerViewCharacter:getPosition()

            tar_pos_x = 1000
        elseif tar_pos_x < 80 then
            local offset = 80 - tar_pos_x

            self.__attackerViewCharacter:setPositionX(self.__attackerViewCharacter:getPositionX() + offset)

            self.__mainView:setCharacterAnimPosition(
                self.__attackerViewCharacter:getId(),
                self.__attackerViewCharacter:getPositionX(),
                self.__attackerViewCharacter:getPositionY(),
                self.__attackerViewCharacter:getPositionH()
            )

            self.__attackStartPos = self.__attackerViewCharacter:getPosition()

            tar_pos_x = 80
        end

        self.__targetViewCharacter:setPosition(tar_pos_x, tar_pos_y, tar_pos_h)
        self.__mainView:setCharacterAnimPosition(
            self.__targetViewCharacter:getId(),
            self.__targetViewCharacter:getPositionX(),
            self.__targetViewCharacter:getPositionY(),
            self.__targetViewCharacter:getPositionH()
        )
    end
end

function HitAttackViewEventAction:__initStartPos()
    local offsetX = AnimResManager:getAttackAnimOffset(self.__zhaoAttack:getAttackerAnim())
    self.__offsetX = offsetX
    self.__dirFactor = self.__attackerViewCharacter:getScaleX()
    self.__targetStartPos = self.__targetViewCharacter:getPosition()
    self.__attackStartPos = {
        x = self.__targetStartPos.x + offsetX * -self.__dirFactor,
        y = self.__targetStartPos.y,
        h = self.__targetStartPos.h
    }
end

function HitAttackViewEventAction:__initAttackerPosTween()
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

            self.__mainView:setCharacterAnimPosition(self.__attackerId, pos.x, pos.y, pos.h)
        end,
        {
            x = self.__attackStartPos.x,
            y = self.__attackStartPos.y - 0.1
        },
        events[1].time / 2
    ):withEase()
end

function HitAttackViewEventAction:__initAttackAnim()
    self.__canUpdateBingding = false

    local animName = self.__zhaoAttack:getAttackerAnim()

    local hurtCount = self.__zhaoAttack:getHitCount()

    self.__hurtIndex = 0

    self.__mainView:playCharacterAnim(
        self.__attackerId,
        animName,
        false,
        function(event)
            if event.name == "Hurt" then
                self.__vector2Tween = nil
                self.__canUpdateBingding = true
                self.__hurtIndex = self.__hurtIndex + 1

                --@RefType [src.app.FightSystem.Veiws.ViewEvents.EventActions.OneAttackResultUIVisitor#OneAttackResultUIVisitor]
                local resultVisitor = require("app.FightSystem.Veiws.ViewEvents.EventActions.OneAttackResultUIVisitor"):create(self.__zhaoQiHurtPrefixText)
                self.__zhaoAttack:runOneAttackVisitor(self.__hurtIndex, resultVisitor)
                self:__targetHitHandle(resultVisitor)
                self:__attackerHitHandle(resultVisitor)
                self:__targetOnHitAnim(event.stringValue, self.__hurtIndex >= hurtCount)
            elseif string.find(event.name, "oneOffEffect_", 1) ~= nil then
                self:__playOneOffEffects(event.name)
            end
        end,
        function()
            self:finish()
        end
    )
end

function HitAttackViewEventAction:__playOneOffEffects(animEventName)
    local list = self.__buffContext:popOneOffEffects(animEventName)

    if #list <= 0 then
        return
    end

    for _, oneOffEffect in ipairs(list) do
        self.__mainView:playOneOffEffectAnim(oneOffEffect.targetId, AnimResManager:getOtherAnimName(oneOffEffect.animId))
    end
end

--@resultVisitor: [src.app.FightSystem.Veiws.ViewEvents.EventActions.OneAttackResultUIVisitor#OneAttackResultUIVisitor]
function HitAttackViewEventAction:__targetHitHandle(resultVisitor)
    local targetPopTexts = resultVisitor:getTargetPopTextList()
    if table.getn(targetPopTexts) > 0 then
        for _, popText in ipairs(targetPopTexts) do
            self.__mainView:popHeadTextInAnimView(self.__targetViewCharacter:getId(), popText)
        end
    end

    local hurts = resultVisitor:getTargetHurts()

    for i = 1, table.getn(hurts) do
        --@RefType [src.app.FightSystem.CharacterHurt.ABasicHurt#ABasicHurt]
        local hurt = hurts[i]

        local attr = hurt:getAttrName()

        local value = hurt:getHurtValue()

        local newValue = self.__targetViewCharacter:getAttr(attr) + value

        self.__targetViewCharacter:setAttr(attr, newValue)
    end

    self.__targetViewCharacter:updateAttrUI(self.__mainView)
end

--@resultVisitor: [src.app.FightSystem.Veiws.ViewEvents.EventActions.OneAttackResultUIVisitor#OneAttackResultUIVisitor]
function HitAttackViewEventAction:__attackerHitHandle(resultVisitor)
    local attackerPopTexts = resultVisitor:getAttackerPopTextList()
    if table.getn(attackerPopTexts) > 0 then
        for _, popText in ipairs(attackerPopTexts) do
            self.__mainView:popHeadTextInAnimView(self.__attackerViewCharacter:getId(), popText)
        end
    end

    local hurts = resultVisitor:getAttackerHurts()

    for i = 1, table.getn(hurts) do
        --@RefType [src.app.FightSystem.CharacterHurt.ABasicHurt#ABasicHurt]
        local hurt = hurts[i]

        local attr = hurt:getAttrName()

        local value = hurt:getHurtValue()

        local newValue = self.__attackerViewCharacter:getAttr(attr) + value

        self.__attackerViewCharacter:setAttr(attr, newValue)
    end

    self.__attackerViewCharacter:updateAttrUI(self.__mainView)
end

function HitAttackViewEventAction:__targetOnHitAnim(pos, lastHit)
    if lastHit and self.__targetViewCharacter:getAttr("qi") <= 0 then
        self.__targetViewCharacter:setDead(true)
        local deadAnim, deadSound = self.__targetViewCharacter:getDeadAnimAndDeadSound(pos)
        self.__mainView:playCharacterAnim(self.__targetViewCharacter:getId(), deadAnim, false)

        if deadSound then
            self.__mainView:playSound(AudioResManager:getSoundNameByRandom(deadSound))
        end
        return
    end

    local hurtAnim, hurtSound = self.__targetViewCharacter:getHurtAnimAndHurtSound(pos)
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

    if hurtSound then
        self.__mainView:playSound(AudioResManager:getSoundNameByRandom(hurtSound))
    end 
end

return newClass("HitAttackViewEventAction", {AViewEventAction}, HitAttackViewEventAction)
000