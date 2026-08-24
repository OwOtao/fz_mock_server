local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local class = require("third.class.NewClass")

local BaseCharacterUIState = require("app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AudioResManager = require("app.FightSystem.ResourceManager.AudioResManager")

local MoveTo = require("app.extends.NodeAction.MoveTo")

local Vector2Tween = require("third.dotween.Vector2Tween")

local ColorManager = require("app.models.colorRes.ColorManager")

local PopTextVm = require("app.FightSystem.UICtrl.UIModel.PopTextVm")

local HitAttackState = {
    __qiDamagePopTextPrefix = ""
}

function HitAttackState:onInit()
    --@desc 目标UI控制器
    self.__targetCtrl = nil

    --@desc 受击目标原始位置
    self.__targetOriPos = nil

    --@desc 攻击方向 1（目标在右） | -1（目标在左）
    self.__dir = 1

    --@desc 攻击者初始位置
    self.__atkerOriPos = nil

    --@desc 此次攻击对应的攻击招式
    --@RefType[src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkHit#AtkHit]
    self.__zhaoAtk = nil

    --@desc 第几次击中
    self.__hurtIndex = 1

    --@desc 能否开始刷新绑定
    self.__canUpdateBinding = false

    self.__vector2Tween = nil

    self.__underHitVisitorClass = require("app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.UnderHitVisitors.UnderHitVisitorOfHitState")
end

function HitAttackState:onEnter(params)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkHit#AtkHit]
    self.__zhaoAtk = params.zhaoAtk

    self.__attackAnims = self.__zhaoAtk:getAttackAnims()

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

    FightUtil:printLog("$$UI Render HitAttackState:onEnter$$ ", self.__ctrl:getVmAttr("name"), "进入攻击状态，使用攻击动画：", self.__animName)
    FightUtil:printLog("$$UI Render HitAttackState:onEnter$$ 攻击者动画攻击开始位置 ：{ x =", self.__atkerOriPos.x, " , y = ", self.__atkerOriPos.y, " , h = ", self.__atkerOriPos.h, "}")
    FightUtil:printLog("$$UI Render HitAttackState:onEnter$$ 受击者动画原始位置 ：{ x =", self.__targetOriPos.x, " , y = ", self.__targetOriPos.y, " , h = ", self.__targetOriPos.h, "}")

    self.__hurtIndex = 1

    self.__canUpdateBinding = false

    self.__hitSoundId = self.__attackAnims:getAttackerSoundId()

    self.__ctrl:playAnim(
        self.__animName,
        false,
        function(event)
            if event.name == "Hurt" then
                FightUtil:printLog("$$UI Render HitAttackState:onEnter Hit $$ ", self.__ctrl:getVmAttr("name"), "攻击动画：", self.__animName, "击中帧：", self.__hurtIndex)
                self.__vector2Tween = nil
                self.__canUpdateBinding = true

                --@RefType [src.app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.UnderHitVisitors.UnderHitVisitorOfHitState#UnderHitVisitorOfHitState]
                local visistor = self.__underHitVisitorClass:create()

                self.__zhaoAtk:runHitFrameVisitor(self.__hurtIndex, visistor)

                local targetPopTextArray = visistor:getTargetPopTextList()
                if table.getn(targetPopTextArray) > 0 then
                    for _, popTextVm in ipairs(targetPopTextArray) do
                        self.__targetCtrl:popOverHeadText(popTextVm:getString())
                    end
                end

                local attackerPopTextArray = visistor:getAttackerPopTextList()
                if #attackerPopTextArray > 0 then
                    for _, popTextVm in ipairs(attackerPopTextArray) do
                        self.__ctrl:popOverHeadText(popTextVm:getString())
                    end
                end

                self.__targetCtrl:beAttack(visistor:getTargetUnderHitResultMap())

                local targetQiShieldAbsorbValue = visistor:getQiShieldAbsorbValue()
                if targetQiShieldAbsorbValue > 0 then
                    self.__targetCtrl:comsumeQiShieldValue(targetQiShieldAbsorbValue)
                end

                self.__ctrl:beAttack(visistor:getAttackerUnderHitResultMap())

                self.__ctrl:playSound(AudioResManager:getSoundNameByRandom(self.__attackAnims:getAttackerSoundId()))

                if self.__hurtIndex == self.__zhaoAtk:getAnimHurtTimes() then
                    self:__doLastHit(event)
                else
                    local hurtAnimName, soundFileName = self.__attackAnims:getTargetAnimNameAndSoundName(event.stringValue)
                    self.__targetCtrl:playAnim(hurtAnimName, false)
                    self.__targetCtrl:playSound(soundFileName)
                end

                self.__hurtIndex = self.__hurtIndex + 1
            elseif string.find(event.name, "oneOffEffect_", 1) ~= nil then
                local effectMap = self.__attackAnims:getOneOffEffectMap(event.name)
                if not MapIsEmpty(effectMap) then
                    for c_id, animNames in pairs(effectMap) do
                        if not MapIsEmpty(animNames) then
                            local ok, playAnimCtrl =
                                self.__ctrl:tryGetCharacterUICtrls(
                                function(ctrl)
                                    return ctrl:getId() == c_id
                                end
                            )

                            if ok then
                                for _, animName in ipairs(animNames) do
                                    FightUtil:printLog("播放一次性动画效果：", animName)
                                    playAnimCtrl:playOneOffEffect(animName)
                                end
                            end
                        end
                    end
                end
            end
        end,
        function(animName)
            self.__ctrl:syncViewAndValue()
            self.__targetCtrl:syncViewAndValue()

            if self.__ctrl:getVmAttr("qi") <= 0 then
                local FightCommons = require("app.FightSystem.FightCommons")
                self.__ctrl:playDeadAnim(FightCommons.HIT_POS.CHEST)
            end

            if self.__targetCtrl:getVmAttr("qi") > 0 then
                self.__targetCtrl:enterIdleState()
            end
        end
    )
end

function HitAttackState:__doLastHit(event)
    self.__ctrl:syncViewAndValue()
    self.__targetCtrl:syncViewAndValue()

    if self.__targetCtrl:getVmAttr("qi") <= 0 then
        self.__targetCtrl:playDeadAnim(event.stringValue)
        return
    end

    local hurtAnimName, soundFileName = self.__attackAnims:getTargetAnimNameAndSoundName(event.stringValue)
    self.__targetCtrl:playAnim(hurtAnimName, false)
    self.__targetCtrl:playSound(soundFileName)
end

function HitAttackState:onLeave()
    if self.__vector2Tween then
        self.__vector2Tween:update(9999)
        return
    end

    self.__targetCtrl:enterIdleState()
end

function HitAttackState:onUpdate(ft)
    if self.__vector2Tween then
        self.__vector2Tween:update(ft)
        return
    end

    if self.__canUpdateBinding then
        --@desc 改变
        local boneData = self.__ctrl:getAnimUI():getBonePosition("AttackPosition")

        if math.abs(boneData.x) > 1 then
            local tar_pos_x = self.__atkerOriPos.x + (boneData.x * self.__dir)
            local tar_pos_y = self.__targetOriPos.y
            local tar_pos_h = self.__atkerOriPos.h + boneData.y

            -- 卡墙角
            if tar_pos_x > 1000 then
                local offset = 1000 - tar_pos_x
                self.__ctrl:setPosition(self.__ctrl:getPosition().x + offset, self.__ctrl:getPosition().y, self.__ctrl:getPosition().h)
                self.__atkerOriPos = self.__ctrl:getPosition()

                tar_pos_x = 1000
            elseif tar_pos_x < 80 then
                local offset = 80 - tar_pos_x
                self.__ctrl:setPosition(self.__ctrl:getPosition().x + offset, self.__ctrl:getPosition().y, self.__ctrl:getPosition().h)
                self.__atkerOriPos = self.__ctrl:getPosition()

                tar_pos_x = 80
            end

            self.__targetCtrl:setPosition(tar_pos_x, tar_pos_y, tar_pos_h)

            FightUtil:printLog('$$UI Render AttackState update$$ 骨骼 "AttackPosition" 位置 : { x = ', boneData.x, " , y = ", boneData.y, "}")
            FightUtil:printLog("$$UI Render AttackState update$$ 受击者update 位置信息：{ x = ", tar_pos_x, " , y = ", tar_pos_y, " , h = ", tar_pos_h, "}")
        end
    end
end

return class("HitAttackState", {BaseCharacterUIState}, HitAttackState)
00000000000000