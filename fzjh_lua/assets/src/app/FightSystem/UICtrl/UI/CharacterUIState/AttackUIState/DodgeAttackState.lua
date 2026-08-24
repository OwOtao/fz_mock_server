local class = require("third.class.NewClass")

local BaseCharacterUIState = require("app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AudioResManager = require("app.FightSystem.ResourceManager.AudioResManager")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local Vector2Tween = require("third.dotween.Vector2Tween")

local TweenConstants = require("third.dotween.Constants")

--@RefType [src.third.dotween.DoTween#DoTween]
local DoTween = require("third.dotween.DoTween")

local DodgeAttackState = {}

function DodgeAttackState:onInit()
    self.__totalDuration = 0

    self.__isStartMovingBack = false

    --@desc 目标UI控制器
    self.__targetCtrl = nil

    --@desc 受击目标原始位置
    self.__targetOriPos = nil

    --@desc 攻击方向 1（目标在右） | -1（目标在左）
    self.__dir = 1

    --@desc 攻击者初始位置
    self.__atkerOriPos = nil

    --@desc 此次攻击对应的攻击招式
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkDodge#AtkDodge]
    self.__zhaoAtk = nil

    self.__isFirstHurt = true
end

function DodgeAttackState:onEnter(params)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkDodge#AtkDodge]
    self.__zhaoAtk = params.zhaoAtk

    --@RefType [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
    self.__attackAnims = self.__zhaoAtk:getAttackAnims()

    self.__attackAnimName = self.__attackAnims:getAttackerAnim()

    local attackEvents = AnimResManager:getAnimHurtEvents(self.__attackAnimName)

    self.__firstHitPos = attackEvents[1].stringValue

    --@RefType[src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
    self.__targetCtrl = self.__ctrl:getTarget(params.targetId)

    if self.__ctrl:getAnimUI():getAnimScaleX() > 0 then
        self.__dir = 1
    else
        self.__dir = -1
    end

    -- 设置攻击者位置
    local offsetX = AnimResManager:getAttackAnimOffset(self.__animName)

    local events = AnimResManager:getAnimHurtEvents(self.__animName)
    if #events > 0 then
        self.__vector2Tween =
            Vector2Tween:create(
            function()
                return self.__ctrl:getPosition()
            end,
            function(pos)
                self.__ctrl:setPosition(pos.x, pos.y, self.__ctrl:getPosition().h)
            end,
            {x = self.__targetCtrl:getPosition().x + offsetX * -self.__dir, y = self.__targetCtrl:getPosition().y - 0.1},
            events[1].time / 2
        ):withEase()
    end

    self.__targetOriPos = self.__targetCtrl:getPosition()
    self.__atkerOriPos = {x = self.__targetOriPos.x + offsetX * -self.__dir, y = self.__targetOriPos.y, h = self.__targetOriPos.h}

    self.__hitBindOffsetX = self.__targetOriPos.x
    self.__hitBindOffsetXLast = 0
    self.__canUpdateBinding = false

    FightUtil:printLog("$$UI Render DodgeAttackState:onEnter$$ 攻击者动画攻击开始位置 ：{ x =", self.__atkerOriPos.x, " , y = ", self.__atkerOriPos.y, " , h = ", self.__atkerOriPos.h , "}")
    FightUtil:printLog("$$UI Render DodgeAttackState:onEnter$$ 受击者动画原始位置 ：{ x =", self.__targetOriPos.x, " , y = ", self.__targetOriPos.y, " , h = ", self.__targetOriPos.h , "}")

    -- self.__target_dodgeSkill = self.__zhaoAtk:getDodgeSkill()

    --@desc 被闪避的攻击只对第一下击中做处理
    self.__ctrl:playAnim(
        self.__attackAnimName,
        false,
        function(event)
            if event.name == "Hurt" and self.__isFirstHurt == true then
                self.__vector2Tween = nil

                self.__canUpdateBinding = true
                self.__isFirstHurt = false

                self.__targetCtrl:popOverHeadText("闪避")
            end
        end
    )
end

function DodgeAttackState:__playTargetDodge()
    local targetMovePos = {x = self.__targetOriPos.x + (self.__dir * self.__zhaoAtk:getMoveBackOffset()), y = self.__targetOriPos.y}

    local dodgeAnimName, soundFileName = self.__attackAnims:getTargetAnimNameAndSoundName(self.__firstHitPos)

    self.__targetCtrl:playAnim(dodgeAnimName, false)

    self.__targetCtrl:playSound(soundFileName)

    FightUtil:printLog("$$UI Render DodgeAttackState:onEnter$$ 受击者开始播放闪避动画 ：{", dodgeAnimName , " }")

    FightUtil:printLog("$$UI Render DodgeAttackState:onEnter$$ 受击者动画后退至位置 ：{ x =", targetMovePos.x, " , y = ", targetMovePos.y , " }")

    self.__dodgeMoveTween = DoTween:create()

    self.__dodgeMoveTween:doVector2(
        function()
            local currPos = self.__targetCtrl:getPosition()
            return cc.p(currPos.x, currPos.y)
        end,
        function(new_pos)
            self.__targetCtrl:setPosition(new_pos.x, new_pos.y, self.__targetOriPos.h)
            FightUtil:printLog("$$UI Render DodgeAttackState:update$$ 受击者动画后退中 ：{ x =", new_pos.x, " , y = ", new_pos.y , " }")
        end,
        targetMovePos,
        self.__zhaoAtk:getMoveBackDuration()
    ):onKill(
        function()
            self.__dodgeMoveTween = nil
            -- self.__targetCtrl:playAnim("Funzerker/Normal/jumpforward", false)
            -- FightUtil:printLog("$$UI Render DodgeAttackState:onEnter$$ 受击者开始播放动画 ：{", "Funzerker/Normal/jumpforward" , " }")
            -- self.__dodgeMoveTween:doVector2(
            --     function()
            --         local currPos = self.__targetCtrl:getPosition()
            --         return cc.p(currPos.x, currPos.y)
            --     end,
            --     function(new_pos)
            --         self.__targetCtrl:setPosition(new_pos.x, new_pos.y, self.__targetOriPos.h)
            --         FightUtil:printLog("$$UI Render DodgeAttackState:update$$ 受击者动画回位中 ：{ x =", new_pos.x, " , y = ", new_pos.y , " }")
            --     end,
            --     cc.p(self.__targetOriPos.x, self.__targetOriPos.y),
            --     self.__zhaoAtk:getRetrunDuration()
            -- ):withEase(TweenConstants.EaseType.SlowFast)
        end
    )
end

function DodgeAttackState:onLeave()
    self.__dodgeMoveTween = nil
    -- self.__targetCtrl:setPosition(self.__targetOriPos.x, self.__targetOriPos.y, self.__targetOriPos.h)
    self.__targetCtrl:enterIdleState()
end

function DodgeAttackState:onUpdate(ft)
    local kaqiangOffsetX = 0
    if self.__vector2Tween then
        self.__vector2Tween:update(ft)
    end

    if self.__canUpdateBinding then
        local boneData = self.__ctrl:getAnimUI():getBonePosition("AttackPosition")
        local tar_pos_x = self.__atkerOriPos.x + boneData.x * self.__dir

        if self.__hitBindOffsetX ~= tar_pos_x then
            local offsetX = tar_pos_x - self.__hitBindOffsetX
            self.__hitBindOffsetX = tar_pos_x

            local toPos = {x = self.__targetCtrl:getPosition().x + offsetX, y = self.__targetCtrl:getPosition().y, h = self.__targetCtrl:getPosition().h}

            self.__targetCtrl:setPosition(toPos.x, toPos.y, toPos.h)

            kaqiangOffsetX = offsetX
        end
    end

    if self.__dodgeMoveTween then
        self.__dodgeMoveTween:update(ft)
    end

    if not self.__isStartMovingBack and self.__totalDuration >= self.__zhaoAtk:getStartMoveBackTime() then
        self:__playTargetDodge()
        self.__isStartMovingBack = true
    end

    -- 卡墙角
    local tar_pos_x = self.__targetCtrl:getPosition().x
    if tar_pos_x > 1000 then
        local offset = 1000 - tar_pos_x

        self.__ctrl:setPosition(self.__ctrl:getPosition().x + offset + kaqiangOffsetX, self.__ctrl:getPosition().y, self.__ctrl:getPosition().h)
        self.__atkerOriPos = self.__ctrl:getPosition()

        self.__hitBindOffsetX = self.__hitBindOffsetX + offset

        tar_pos_x = 1000
    elseif tar_pos_x < 80 then
        local offset = 80 - tar_pos_x

        self.__ctrl:setPosition(self.__ctrl:getPosition().x + offset + kaqiangOffsetX, self.__ctrl:getPosition().y, self.__ctrl:getPosition().h)
        self.__atkerOriPos = self.__ctrl:getPosition()

        self.__hitBindOffsetX = self.__hitBindOffsetX + offset

        tar_pos_x = 80
    end
    self.__targetCtrl:setPosition(tar_pos_x, self.__targetCtrl:getPosition().y, self.__targetCtrl:getPosition().h)

    self.__totalDuration = self.__totalDuration + ft
end

return class("DodgeAttackState", {BaseCharacterUIState}, DodgeAttackState)
0000000000000000