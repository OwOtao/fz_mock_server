--[[
    author:Seven
    time:2023-10-21 14:43:24
    desc: 角色动画UI
]]
local BaseViewUI = require("app.FightSystem.Veiws.ViewCommon.BaseViewUI")

local NewClass = require("third.class.NewClass")

local SpineAnimator = require("third.animator.SpineAnimator.SpineAnimator")

local NodeActions = require("app.extends.NodeAction.Actions")

--@SuperType [src.app.FightSystem.Veiws.ViewCommon.BaseViewUI#BaseViewUI]
local CharacterAnimViewUI = {}

local NODE_LOCALZORDERS = {
    BACKGROUND_LAYER = 0, --背景特效层
    BACKGROUND_EFFECT_LAYER = 1, --背景特效层
    CHARACTER_LAYER = 10, --角色层
    EFFECT_LAYER = 20, --特效层
    UI_TOP_LAYER = 30 -- UI最顶层
}

function CharacterAnimViewUI:onInit()
    self.Shadow:setLocalZOrder(NODE_LOCALZORDERS.BACKGROUND_LAYER)

    self:__initBodyAnimator()
    self:__initEnterVictoryAnimator()
    self:__initEffectAnimator()
    self:__initShieldAnimtor()
    self:__initChrarcterStatusTextUI()

    self.AnimRoleInfoPanel:setVisible(false)
    self.__flipFactor = 1
    self.__effectAnimators = {}
    self.__effectAnimatorsRemoves = {}
end

function CharacterAnimViewUI:onDestroy()
end

function CharacterAnimViewUI:onUpdate(ft)
    self.__currAnimator:update(ft)
    self.__shieldAnimator:update(ft)
    self.__shadowEffectAnimator:update(ft)
    self:__clearNeedRemoveEffectAnimNode()

    if table.getn(self.__effectAnimators) > 0 then
        for i, animator in ipairs(self.__effectAnimators) do
            animator:update(ft)
        end
    end

    local body1Position = self:getBonePosition("body1")
    self.Shadow:setPosition(cc.p(self:getBodyScaleX() * body1Position.x, 0))
    self.TagImg:setPosition(cc.p(self:getBodyScaleX() * body1Position.x, body1Position.y + 150))
    self.__shadowEffectAnimator:getSkeletonAnimation():setPosition(cc.p(self:getBodyScaleX() * body1Position.x, 0))
end

function CharacterAnimViewUI:__initEffectAnimator()
    --@RefType[src.third.animator.SpineAnimator.SpineAnimator#SpineAnimator]
    self.__shadowEffectAnimator =
        SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/specialEffect/specialEffect.skel", "Anim/specialEffect/specialEffect.atlas", 1), "动画初始化出错"))
    self.__shadowEffectAnimator:getSkeletonAnimation():setPosition(cc.p(0, 0))
    self.__node:addChild(self.__shadowEffectAnimator:getSkeletonAnimation(), NODE_LOCALZORDERS.BACKGROUND_EFFECT_LAYER)
    self.__shadowEffectAnimator:getSkeletonAnimation():setVisible(true)
end

function CharacterAnimViewUI:__initBodyAnimator()
    --@RefType[src.third.animator.SpineAnimator.SpineAnimator#SpineAnimator]
    self.__animator = SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/gongfu1/gongfu.skel", "Anim/gongfu1/gongfu.atlas", 1), "动画初始化出错"))

    self.__animator:getSkeletonAnimation():setPosition(cc.p(0, 0))
    self:__updateBodyAnimSlotColor()
    self.__node:addChild(self.__animator:getSkeletonAnimation(), NODE_LOCALZORDERS.CHARACTER_LAYER)
    self.__animator:getSkeletonAnimation():setVisible(true)
    self:setCurrUseAnimator(self.__animator)
end

function CharacterAnimViewUI:__initEnterVictoryAnimator()
    --@RefType[src.third.animator.SpineAnimator.SpineAnimator#SpineAnimator]
    self.__enterVictoryAnimator = SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/enterVictory/enterVictory.skel", "Anim/enterVictory/enterVictory.atlas", 1), "动画初始化出错"))

    self.__enterVictoryAnimator:getSkeletonAnimation():setPosition(cc.p(0, 0))
    self.__enterVictoryAnimator:getSkeletonAnimation():setSlotsToSetupPose()
    self.__enterVictoryAnimator:getSkeletonAnimation():setSlotColor("body", cc.c4f(1, 1, 0, 1))
    self.__enterVictoryAnimator:getSkeletonAnimation():setSlotColor("body_back", cc.c4f(1, 1, 0, 1))
    self.__node:addChild(self.__enterVictoryAnimator:getSkeletonAnimation(), NODE_LOCALZORDERS.CHARACTER_LAYER)
    self.__enterVictoryAnimator:getSkeletonAnimation():setVisible(false)
end

function CharacterAnimViewUI:__updateBodyAnimSlotColor()
    self.__animator:getSkeletonAnimation():setSlotsToSetupPose()
    self.__animator:getSkeletonAnimation():setSlotColor("body", cc.c4f(1, 1, 0, 1))
    self.__animator:getSkeletonAnimation():setSlotColor("body_back", cc.c4f(1, 1, 0, 1))
end

function CharacterAnimViewUI:__initShieldAnimtor()
    --@RefType[src.third.animator.SpineAnimator.SpineAnimator#SpineAnimator]
    self.__shieldAnimator =
        SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/FightEffect/fanghu.skel", "Anim/FightEffect/fanghu.atlas", 1), "动画初始化出错"))
    self.__shieldAnimator:getSkeletonAnimation():setPosition(cc.p(0, 0))
    self.__node:addChild(self.__shieldAnimator:getSkeletonAnimation(), NODE_LOCALZORDERS.EFFECT_LAYER)
    self.__shieldAnimator:getSkeletonAnimation():setVisible(false)
end

function CharacterAnimViewUI:__initChrarcterStatusTextUI()
    self.__statusText = ccui.Text:create()
    self.__statusText:setFontName(Resource:getFontPath("default"))
    self.__statusText:setFontSize(32)
    self.__statusText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self.__statusText:setVisible(false)
    self.__statusText:setZOrder(NODE_LOCALZORDERS.UI_TOP_LAYER)
    self.__statusText:addTo(self:getNode())
end

--@desc: 翻转系数（用于节点中文本）
--@author:Seven
--@time:2022-09-05 15:45:54
--@factor: 翻转系数
function CharacterAnimViewUI:setFlipFactor(factor)
    if factor ~= 1 and factor ~= -1 then
        assert(false, "CharacterAnimViewUI:setFlipFactor 参数只能为1或者-1")
    end

    self.__flipFactor = factor
end

function CharacterAnimViewUI:getFlipFactor()
    return self.__flipFactor
end

function CharacterAnimViewUI:setVisible(bool)
    self.__node:setVisible(bool)
end

function CharacterAnimViewUI:setLocalZOrder(z)
    self.__node:setLocalZOrder(z)
end

function CharacterAnimViewUI:setPosition(x, y, h)
    self.__node:setPosition(cc.p(x, y))
    self.__animator:getSkeletonAnimation():setPosition(cc.p(0, h))
    self.__enterVictoryAnimator:getSkeletonAnimation():setPosition(cc.p(0, h))
end

function CharacterAnimViewUI:getPosition()
    return self.__node:getPosition()
end

function CharacterAnimViewUI:popOverHeadText(textString, color)
    color = Helper:getDef(color, cc.c4b(255, 255, 255, 255))

    local text = ccui.Text:create()

    self.__node:addChild(text, NODE_LOCALZORDERS.UI_TOP_LAYER)

    text:setScaleX(self.__flipFactor)

    text:setFontName("Font/default.ttf")
    text:setFontSize(48)
    text:setTextColor(color)
    -- 文字颜色
    text:enableOutline(cc.c4b(0, 0, 0), 3)
    -- 气血文字描边
    text:setString(tostring(textString))

    text:setLocalZOrder(99999)
    text:setPositionY(130)

    self.__mainView:runUINodeAction(
        text,
        NodeActions.Sequence:create(
            -- 显示
            NodeActions.Spawn:create(
                NodeActions.MoveTo:create(0.1, cc.p(math.random(-20, 20), math.random(130, 170))),
                NodeActions.Sequence:create(NodeActions.ScaleTo:create(0.05, 1.2 * self.__flipFactor, 1), NodeActions.ScaleTo:create(0.05, 1 * self.__flipFactor, 1))
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

function CharacterAnimViewUI:setCurrUseAnimator(animator)
    self.__currAnimator = animator
end

function CharacterAnimViewUI:setBodyScaleX(value)
    self.__animator:getSkeletonAnimation():setScaleX(value)
    self.__enterVictoryAnimator:getSkeletonAnimation():setScaleX(value)
end

function CharacterAnimViewUI:getBodyScaleX()
    return self.__animator:getSkeletonAnimation():getScaleX()
end

function CharacterAnimViewUI:setStatusTextAnchorPointType(value)
    if value > 0 then
        self.__statusText:setPositionX(-0)
        self.__statusText:setAnchorPoint(cc.p(1, 0.5))
    else
        self.__statusText:setPositionX(0)
        self.__statusText:setAnchorPoint(cc.p(0, 0.5))
    end
end

function CharacterAnimViewUI:showStatusText(str)
    self.__statusText:setPositionY(100)
    self.__statusText:setVisible(true)
    self.__statusText:setScaleX(self.__flipFactor)
    if self:getBodyScaleX() > 0 then
        self.__statusText:setPositionX(-0)
        self.__statusText:setAnchorPoint(cc.p(1, 0.5))
    else
        self.__statusText:setPositionX(0)
        self.__statusText:setAnchorPoint(cc.p(0, 0.5))
    end
    self.__statusText:setString(str)
end

function CharacterAnimViewUI:hideStatusText()
    self.__statusText:setVisible(false)
end

function CharacterAnimViewUI:playAnim(name, isLoop, eventCallback, completeCallback)
    if self.__currAnimator ~= self.__animator then
        self:setCurrUseAnimator(self.__animator)
        
        self.__animator:getSkeletonAnimation():setVisible(true)

        self.__enterVictoryAnimator:getSkeletonAnimation():setVisible(false)
    end

    self:__playAnim(name, isLoop, eventCallback, completeCallback)
end

function CharacterAnimViewUI:playEnterVictoryAnim(name, isLoop, eventCallback, completeCallback)
    if self.__currAnimator ~= self.__enterVictoryAnimator then
        self:setCurrUseAnimator(self.__enterVictoryAnimator)
        
        self.__enterVictoryAnimator:getSkeletonAnimation():setVisible(true)

        self.__animator:getSkeletonAnimation():setVisible(false)
    end

    self:__playAnim(name, isLoop, eventCallback, completeCallback)
end

function CharacterAnimViewUI:__playAnim(name, isLoop, eventCallback, completeCallback)
    if isLoop == nil then
        isLoop = false
    end

    self.__currAnimator:setEventCallback(Helper:getDef(eventCallback, EMPTY_FUNC))

    self.__currAnimator:setCompleteCallback(completeCallback)

    self.__currAnimator:play(name, isLoop)
end

function CharacterAnimViewUI:setWeaponSkin(weaponSkin)
    self.__animator:getSkeletonAnimation():setSkin(weaponSkin)
    self:__updateBodyAnimSlotColor()
end

function CharacterAnimViewUI:getBonePosition(boneName)
    return self.__currAnimator:getSkeletonAnimation():getBonePosition(boneName)
end

function CharacterAnimViewUI:setShadowColor(color)
    self.Shadow:setColor(color)
end

function CharacterAnimViewUI:setShieldAnimVisible(bool)
    self.__shieldAnimator:getSkeletonAnimation():setVisible(bool)
end

function CharacterAnimViewUI:playShieldAnim(name)
    self.__shieldAnimator:play(name, true)
end

function CharacterAnimViewUI:setShadowEffectAnimVisible(bool)
    self.__shadowEffectAnimator:getSkeletonAnimation():setVisible(bool)
end

function CharacterAnimViewUI:playShadowEffectAnim(name)
    self.__shadowEffectAnimator:play(name, true)
end

function CharacterAnimViewUI:playOneOffEffect(animName)
    --@RefType[src.third.animator.SpineAnimator.SpineAnimator#SpineAnimator]
    local effectAnimator =
        SpineAnimator:create(assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/specialEffect/specialEffect.skel", "Anim/specialEffect/specialEffect.atlas", 1), "动画初始化出错"))

    effectAnimator:getSkeletonAnimation():setPosition(cc.p(0, 0))

    self.__node:addChild(effectAnimator:getSkeletonAnimation(), NODE_LOCALZORDERS.EFFECT_LAYER)

    effectAnimator:getSkeletonAnimation():setScaleX(self:getBodyScaleX())

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

function CharacterAnimViewUI:__clearNeedRemoveEffectAnimNode()
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

function CharacterAnimViewUI:setHeadTagVisible(bool)
    self.TagImg:setVisible(bool)
end

function CharacterAnimViewUI:setTagImgType(nodeType)
    if nodeType == "player" then
        self:setHeadTagVisible(true)
        self.TagImg:loadTexture("Image/UI/WordFightUI/lvbiao.png", 0)
    elseif nodeType == "target" then
        self:setHeadTagVisible(true)
        self.TagImg:loadTexture("Image/UI/WordFightUI/huangbiao.png", 0)
    elseif nodeType == "other" then
        self:setHeadTagVisible(false)
    end
end

return NewClass("CharacterAnimViewUI", {BaseViewUI}, CharacterAnimViewUI)
000000