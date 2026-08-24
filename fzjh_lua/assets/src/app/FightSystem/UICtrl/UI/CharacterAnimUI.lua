local BaseUI = require("app.FightSystem.UICtrl.UI.BaseUI")

local NewClass = require("third.class.NewClass")

local SpineAnimator = require("third.animator.SpineAnimator.SpineAnimator")

local FightFormula = require("app.FightSystem.FightFormula")

local NodeActions = require("app.extends.NodeAction.Actions")

--@SuperType [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
local CharacterAnimUI = {
    __isJumping = false,
    __targetPos = nil,
    --@desc 跳跃方向 forward | back
    __jumpDir = "forward"
}

function CharacterAnimUI:onInit()
    self:__initEffect()

    self:__initAnimator()

    self:__initShield()

    self.AnimRoleInfoPanel:setVisible(false)

    self:setTagImgType("other")

    local NodeActionManager = require("app.extends.NodeAction.NodeActionManager")
    self.__actionManager = NodeActionManager:create()

    self:__initChrarcterStatusTextUI()

    self.__effectAnimators = {}

    self.__effectAnimatorsRemoves = {}
end

function CharacterAnimUI:__initShield()
    --@RefType[src.third.animator.SpineAnimator.SpineAnimator#SpineAnimator]
    self.__shieldAnimator =
        SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/specialEffect/specialEffect.skel", "Anim/specialEffect/specialEffect.atlas", 1), "动画初始化出错"))
    self.__shieldAnimator:getSkeletonAnimation():setPosition(cc.p(0, 0))
    self.__node:addChild(self.__shieldAnimator:getSkeletonAnimation())
    self.__shieldAnimator:getSkeletonAnimation():setVisible(false)
end

function CharacterAnimUI:__initEffect()
    --@RefType[src.third.animator.SpineAnimator.SpineAnimator#SpineAnimator]
    self.__shadowEffectAnimator =
        SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/specialEffect/specialEffect.skel", "Anim/specialEffect/specialEffect.atlas", 1), "动画初始化出错"))
    self.__shadowEffectAnimator:getSkeletonAnimation():setPosition(cc.p(0, 0))
    self.__node:addChild(self.__shadowEffectAnimator:getSkeletonAnimation())
    self.__shadowEffectAnimator:getSkeletonAnimation():setVisible(true)
end

function CharacterAnimUI:__updateAnimSlotColor()
    self.__animator:getSkeletonAnimation():setSlotsToSetupPose()
    self.__animator:getSkeletonAnimation():setSlotColor("body", cc.c4f(1, 1, 0, 1))
    self.__animator:getSkeletonAnimation():setSlotColor("body_back", cc.c4f(1, 1, 0, 1))
end

function CharacterAnimUI:__initAnimator()
    --@RefType[src.third.animator.SpineAnimator.SpineAnimator#SpineAnimator]
    self.__animator = SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/gongfu1/gongfu.skel", "Anim/gongfu1/gongfu.atlas", 1), "动画初始化出错"))

    self.__animator:getSkeletonAnimation():setPosition(cc.p(0, 0))
    self:__updateAnimSlotColor()
    self.__node:addChild(self.__animator:getSkeletonAnimation())
end

function CharacterAnimUI:__initChrarcterStatusTextUI()
    self.__statusText = ccui.Text:create()
    self.__statusText:setFontName(Resource:getFontPath("default"))
    self.__statusText:setFontSize(32)
    self.__statusText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self.__statusText:setVisible(false)
    self.__statusText:addTo(self:getNode())
end

function CharacterAnimUI:onDestroy()
end

function CharacterAnimUI:setPosition(x, y, h)
    self.__node:setPosition(cc.p(x, y))
    self.__animator:getSkeletonAnimation():setPosition(cc.p(0, h))
end

function CharacterAnimUI:setVisible(bool)
    self:getNode():setVisible(bool)
end

function CharacterAnimUI:setLocalZOrder(z)
    self.__node:setLocalZOrder(z)
end

function CharacterAnimUI:popOverHeadText(textString, color)
    color = Helper:getDef(color, cc.c4b(255, 255, 255, 255))

    local text = ccui.Text:create()
    self.__node:addChild(text)

    text:setFontName("Font/default.ttf")
    text:setFontSize(48)
    text:setTextColor(color)
    -- 文字颜色
    text:enableOutline(cc.c4b(0, 0, 0), 3)
    -- 气血文字描边
    text:setString(tostring(textString))

    text:setLocalZOrder(99999)
    text:setPositionY(130)
    self.__actionManager:runAction(
        text,
        NodeActions.Sequence:create(
            -- 显示
            NodeActions.Spawn:create(
                NodeActions.MoveTo:create(0.1, cc.p(math.random(-20, 20), math.random(130, 170))),
                NodeActions.Sequence:create(NodeActions.ScaleTo:create(0.05, 1.2), NodeActions.ScaleTo:create(0.05, 1))
            ),
            -- 停留
            NodeActions.DelayTime:create(0.3),
            -- 消失
            NodeActions.Spawn:create(NodeActions.FadeOut:create(0.5), NodeActions.MoveBy:create(0.5, cc.p(0, 30))),
            -- 移除
            NodeActions.RemoveSelf:create()
        )
    )
end

function CharacterAnimUI:setAnimScaleX(value)
    self.__animator:getSkeletonAnimation():setScaleX(value)
end

function CharacterAnimUI:getAnimScaleX()
    return self.__animator:getSkeletonAnimation():getScaleX()
end

function CharacterAnimUI:setStatusAnchorPointType(value)
    if value > 0 then
        self.__statusText:setPositionX(-0)
        self.__statusText:setAnchorPoint(cc.p(1, 0.5))
    else
        self.__statusText:setPositionX(0)
        self.__statusText:setAnchorPoint(cc.p(0, 0.5))
    end
    self.__statusText:setPositionY(100)
end

function CharacterAnimUI:showStatusText(str)
    self.__statusText:setVisible(true)
    self.__statusText:setString(str)
end

function CharacterAnimUI:hideStatusText()
    self.__statusText:setVisible(false)
end

function CharacterAnimUI:playAnim(name, isLoop)
    if isLoop == nil then
        isLoop = false
    end
    self.__animator:play(name, isLoop)
end

function CharacterAnimUI:setEventCallback(callback)
    if callback == nil then
        callback = function()
        end
    end
    self.__animator:setEventCallback(callback)
end

function CharacterAnimUI:setCompleteCallback(callback)
    -- if callback == nil then
    --     callback = nil
    -- end
    self.__animator:setCompleteCallback(callback)
end

function CharacterAnimUI:setWeaponSkin(weaponSkin)
    self.__animator:getSkeletonAnimation():setSkin(weaponSkin)
    self:__updateAnimSlotColor()
end

function CharacterAnimUI:getBonePosition(boneName)
    return self.__animator:getSkeletonAnimation():getBonePosition(boneName)
end

function CharacterAnimUI:setShadowColor(color)
    self.Shadow:setColor(color)
end

function CharacterAnimUI:setShieldAnimVisible(bool)
    self.__shieldAnimator:getSkeletonAnimation():setVisible(bool)
end

function CharacterAnimUI:playShieldAnim(name)
    self.__shieldAnimator:play(name, true)
end

function CharacterAnimUI:setShadowEffectAnimVisible(bool)
    self.__shadowEffectAnimator:getSkeletonAnimation():setVisible(bool)
end

function CharacterAnimUI:playShadowEffectAnim(name)
    self.__shadowEffectAnimator:play(name, true)
end

function CharacterAnimUI:playOneOffEffect(animName)
    --@RefType[src.third.animator.SpineAnimator.SpineAnimator#SpineAnimator]
    local effectAnimator =
        SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/specialEffect/specialEffect.skel", "Anim/specialEffect/specialEffect.atlas", 1), "动画初始化出错"))

    effectAnimator:getSkeletonAnimation():setPosition(cc.p(0, 0))

    self.__node:addChild(effectAnimator:getSkeletonAnimation())

    effectAnimator:getSkeletonAnimation():setScaleX(self:getAnimScaleX())

    effectAnimator:getSkeletonAnimation():setVisible(true)

    effectAnimator:setCompleteCallback(
        function()
            table.insert(self.__effectAnimatorsRemoves, effectAnimator)

            effectAnimator:getSkeletonAnimation():setVisible(false)
        end
    )

    table.insert(self.__effectAnimators, effectAnimator)

    effectAnimator:play(animName, false)
end

function CharacterAnimUI:__clearNeedRemoveEffectAnimNode()
    if table.getn(self.__effectAnimatorsRemoves) > 0 then
        for i = table.getn(self.__effectAnimatorsRemoves), 1, -1 do
            local needRemoveAnimator = self.__effectAnimatorsRemoves[i]
            for j = table.getn(self.__effectAnimators), 1, -1 do
                local animator = self.__effectAnimators[j]
                if animator == needRemoveAnimator then
                    table.remove(self.__effectAnimatorsRemoves, i)
                    table.remove(self.__effectAnimators, j)
                    animator:getSkeletonAnimation():removeFromParent()
                end
            end
        end

        if table.getn(self.__effectAnimatorsRemoves) > 0 then
            error("__effectAnimatorsRemoves 清理后不应还有元素存在！！")
        end
    end
end

function CharacterAnimUI:setTagVisible(bool)
    self.TagImg:setVisible(bool)
end

function CharacterAnimUI:setTagImgType(nodeType)
    if nodeType == "player" then
        self:setTagVisible(true)
        self.TagImg:loadTexture("Image/UI/WordFightUI/lvbiao.png", 0)
    elseif nodeType == "target" then
        self:setTagVisible(true)
        self.TagImg:loadTexture("Image/UI/WordFightUI/huangbiao.png", 0)
    elseif nodeType == "other" then
        self:setTagVisible(false)
    end
end

--@region 人物角色信息
function CharacterAnimUI:setQiProgress(value)
    self.AnimRoleInfoPanel.QiBar:setPercent(value)
end

function CharacterAnimUI:setQiMaxProgress(value)
    self.AnimRoleInfoPanel.QiMaxBar:setPercent(value)
end

function CharacterAnimUI:setNeiLiProgress(value)
    self.AnimRoleInfoPanel.NeiliBar:setPercent(value)
end

function CharacterAnimUI:setNeiLiMaxProgress(value)
    self.AnimRoleInfoPanel.NeiliMaxBar:setPercent(value)
end

function CharacterAnimUI:setTiliMaxProgress(percent)
    self.AnimRoleInfoPanel.TiliMaxBar:setPercent(percent)
end

function CharacterAnimUI:setTiliProgress(percent)
    self.AnimRoleInfoPanel.TiliBar:setPercent(percent)
end

--@endregion

function CharacterAnimUI:onUpdate(ft)
    self.__animator:update(ft)

    self.__shieldAnimator:update(ft)

    self.__actionManager:update(ft)

    self:__clearNeedRemoveEffectAnimNode()

    if table.getn(self.__effectAnimators) > 0 then
        for i, animator in ipairs(self.__effectAnimators) do
            animator:update(ft)
        end
    end

    local body1Position = self:getBonePosition("body1")
    self.Shadow:setPosition(cc.p(self:getAnimScaleX() * body1Position.x, 0))
    self.TagImg:setPosition(cc.p(self:getAnimScaleX() * body1Position.x, body1Position.y + 150))
    self.__shadowEffectAnimator:getSkeletonAnimation():setPosition(cc.p(self:getAnimScaleX() * body1Position.x, 0))
end

return NewClass("CharacterAnimUI", {BaseUI}, CharacterAnimUI)
000