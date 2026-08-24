local BaseLayer = class("BaseLayer", cc.Layer)

function BaseLayer:create()
	local p = BaseLayer:create()
	p:init()
	return p
end

function BaseLayer:init()
	self:hide()
end

function BaseLayer:show(anim, height)
    if not height then
        height = display.height
    end
    
    self:setVisible(true)
    self:resumeSelfAndChildren()
    
    local actionTag = self:getActionTagByName("ShowAndHide")
    self:stopActionByTag(actionTag)
    self:move(cc.p(0, height))
    if anim then
        local action = cc.Sequence:create(
            cc.MoveTo:create(UI_ANIM_DURATION, cc.p(0, 0)),
            cc.CallFunc:create(
                function()
                    self:show()
                end))
        action:setTag(actionTag)
        self:runAction(action)
    else
        self:move(cc.p(0, 0))
    end
end

function BaseLayer:hide(anim, height)
    if not height then
        height = display.height
    end
    
    self:setVisible(true)
    self:resumeSelfAndChildren()
    
    local actionTag = self:getActionTagByName("ShowAndHide")
    self:stopActionByTag(actionTag)
    if anim then
        local action = cc.Sequence:create(
            cc.MoveTo:create(UI_ANIM_DURATION, cc.p(0, height)),
            cc.CallFunc:create(
                function()
                    self:hide()
                end))
        action:setTag(actionTag)
        self:runAction(action)
    else
        self:move(cc.p(0, height))
        self:pauseSelfAndChildren()
        self:setVisible(false)
    end
end

--显示 带有渐变效果
function BaseLayer:showWithFade(anim, height)
    if not height then
        height = display.height
    end
    
    self:setVisible(true)
    self:resumeSelfAndChildren()
    
    local actionTag = self:getActionTagByName("ShowAndHide")
    self:stopActionByTag(actionTag)
    self:move(cc.p(0, height))
    if anim then
        local action = cc.Sequence:create(
            cc.Spawn:create(
                cc.MoveTo:create(UI_ANIM_DURATION, cc.p(0, 0)),
                cc.FadeIn:create(UI_ANIM_DURATION)
            ),
            cc.CallFunc:create(
                function()
                    self:showWithFade()
                end))
        action:setTag(actionTag)
        self:runAction(action)
    else
        self:move(cc.p(0, 0))
        self:resumeSelfAndChildren()
        self:setVisible(true)
    end
end

function BaseLayer:hideWithFade(anim, height)
    if not height then
        height = display.height
    end
    
    self:setVisible(true)
    self:resumeSelfAndChildren()
    
    local actionTag = self:getActionTagByName("ShowAndHide")
    self:stopActionByTag(actionTag)
    self:move(cc.p(0, 0))
    if anim then
        self:setCascadeOpacityEnabled(true)
        self:callAllChild(function(child)
            child:setCascadeOpacityEnabled(true)
        end)
        local action = cc.Sequence:create(
            cc.Spawn:create(
                cc.MoveTo:create(UI_ANIM_DURATION, cc.p(0, height)),
                cc.FadeOut:create(UI_ANIM_DURATION)
            ),
            cc.CallFunc:create(
                function()
                    self:hideWithFade()
                end))
        action:setTag(actionTag)
        self:runAction(action)
    else
        self:move(cc.p(0, height))
        self:pauseSelfAndChildren()
        self:setVisible(false)
    end
end

function BaseLayer:fadeIn(duration, func)
    
    self:setVisible(true)
    self:resumeSelfAndChildren()
    
    self:setCascadeOpacityEnabled(true)
    self:callAllChild(
        function(child)
            child:setCascadeOpacityEnabled(true)
        end)
    
    self:runAction(
        cc.Sequence:create(
            cc.FadeIn:create(duration)
            , cc.CallFunc:create(function()
                if type(func) == "function" then
                    func(self)
                end
            end)))
end

function BaseLayer:fadeOut(duration, func)
    self:setVisible(true)
    self:resumeSelfAndChildren()
    
    self:setCascadeOpacityEnabled(true)
    self:callAllChild(
        function(child)
            child:setCascadeOpacityEnabled(true)
        end)
    
    self:runAction(
        cc.Sequence:create(
            cc.FadeOut:create(duration)
            , cc.CallFunc:create(function()
                if func then
                    self:pauseSelfAndChildren()
                    self:setVisible(false)
                    
                    if type(func) == "function" then
                        func(self)
                    end
                end
            end)))
end

return BaseLayer0000000000000