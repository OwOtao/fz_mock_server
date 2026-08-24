local class = require("third.class.NewClass")

local BaseCharacterUIState = require("app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AudioResManager = require("app.FightSystem.ResourceManager.AudioResManager")

--@RefType [src.third.dotween.DoTween#DoTween]
local DoTween = require("third.dotween.DoTween")

local ParryAttackState = {}

function ParryAttackState:onInit()
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
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkParry#AtkParry]
    self.__parryZhaoAtk = nil

    self.__isFirstHurt = true
end

function ParryAttackState:onEnter(params)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkParry#AtkParry]
    self.__parryZhaoAtk = params.zhaoAtk

    self.__attackAnims = self.__parryZhaoAtk:getAttackAnims()

    self.__attackAnimName = self.__attackAnims:getAttackerAnim()

    local attackEvents = AnimResManager:getAnimHurtEvents(self.__attackAnimName)

    self.__firstHitPos = attackEvents[1].stringValue

    --@RefType[src.app.FightSystem.UICtrl.CharacterUICtrl#CharacterUICtrl]
    self.__targetCtrl = self.__ctrl:getTarget(params.targetId)

    self.__targetOriPos = self.__targetCtrl:getPosition()

    self.__atkerOriPos = self.__ctrl:getPosition()

    if self.__ctrl:getAnimUI():getAnimScaleX() > 0 then
        self.__dir = 1
    else
        self.__dir = -1
    end

    FightUtil:printLog("$$UI Render ParryAttackState:onEnter$$ 攻击者动画攻击开始位置 ：{ x =", self.__atkerOriPos.x, " , y = ", self.__atkerOriPos.y, " , h = ", self.__atkerOriPos.h , "}")
    FightUtil:printLog("$$UI Render ParryAttackState:onEnter$$ 受击者动画原始位置 ：{ x =", self.__targetOriPos.x, " , y = ", self.__targetOriPos.y, " , h = ", self.__targetOriPos.h , "}")

    --@desc 被闪避的攻击只对第一下击中做处理
    self.__ctrl:playAnim(
        self.__attackAnimName,
        false,
        function(event)
            if event.name == "Hurt" and self.__isFirstHurt == true then
                self:__playTargetParry()
                self.__targetCtrl:popOverHeadText("闪避")
                self.__isFirstHurt = false
            end
        end
    )
end

function ParryAttackState:__playTargetParry()
    local parryAnimName = self.__attackAnims:getTargetHurtAnim(self.__firstHitPos)

    self.__targetCtrl:playAnim(parryAnimName, false)

    local fileName = AudioResManager:getSoundNameByRandom(self.__attackAnims:getTargetSoundId())
    
    self.__targetCtrl:playSound(fileName)
    
    FightUtil:printLog("$$UI Render DodgeAttackState:onEnter$$ 受击者开始播放格挡动画 ：{", parryAnimName , " }")
    
    local offset = self.__parryZhaoAtk:getMoveBackOffset()
    if offset > 0 then
        local targetMovePos = {x = self.__targetOriPos.x + (self.__dir * offset), y = self.__targetOriPos.y}
        FightUtil:printLog("$$UI Render ParryAttackState:onEnter$$ 受击者动画后退位置 ：{ x =", targetMovePos.x, " , y = ", targetMovePos.y , " }")
        self.__parryMoveTween = DoTween:create()
        self.__parryMoveTween:doVector2(
            function()
                local currPos = self.__targetCtrl:getPosition()
                return cc.p(currPos.x, currPos.y)
            end,
            function(new_pos)
                self.__targetCtrl:setPosition(new_pos.x, new_pos.y, self.__targetOriPos.h)
                FightUtil:printLog("$$UI Render ParryAttackState:update$$ 受击者动画后退中 ：{ x =", new_pos.x, " , y = ", new_pos.y , " }")
            end,
            targetMovePos,
            self.__parryZhaoAtk:getMoveBackDuration()
        ):onKill(
            function()
                self.__targetCtrl:playAnim("Funzerker/Normal/jumpforward", false)
                self.__parryMoveTween:doVector2(
                    function()
                        local currPos = self.__targetCtrl:getPosition()
                        return cc.p(currPos.x, currPos.y)
                    end,
                    function(new_pos)
                        self.__targetCtrl:setPosition(new_pos.x, new_pos.y, self.__targetOriPos.h)
                        FightUtil:printLog("$$UI Render ParryAttackState:update$$ 受击者动画回位中 ：{ x =", new_pos.x, " , y = ", new_pos.y , " }")
                    end,
                    cc.p(self.__targetOriPos.x, self.__targetOriPos.y),
                    self.__parryZhaoAtk:getRetrunDuration()
                )
            end
        )
    end
end

function ParryAttackState:onLeave()
    self.__parryMoveTween = nil
    self.__targetCtrl:setPosition(self.__targetOriPos.x, self.__targetOriPos.y, self.__targetOriPos.h)
    self.__targetCtrl:enterIdleState()
end

function ParryAttackState:onUpdate(ft)
    if self.__parryMoveTween then
        self.__parryMoveTween:update(ft)
    end


    self.__totalDuration  = self.__totalDuration + ft
end

return class("ParryAttackState", {BaseCharacterUIState}, ParryAttackState)
000000000000