local BaseItemDetailPanelLayer = class("BaseItemDetailPanelLayer", cc.Layer)

function BaseItemDetailPanelLayer:create()
    local p = BaseItemDetailPanelLayer:new()
    p:init()
    return p
end

function BaseItemDetailPanelLayer:init()
    -- body
end

function BaseItemDetailPanelLayer:hideLayer()

	if self.handle ~= nil then
		self:unschedule(self.handle)
		self.handle = nil
	end
	self:hide()
	-- self.backFunc()
end

function BaseItemDetailPanelLayer:show()
    self:setTouchEnabled(true)
    self:setVisible(true)
    local actionTag = self:getActionTagByName("move")
    self:stopActionByTag(actionTag)
    self:move(cc.p(0, 170))
    -- self:move(cc.p(0, 1536))
    local action =
        cc.Sequence:create(
        cc.Spawn:create(cc.MoveTo:create(UI_ANIM_DURATION, cc.p(0, 0)), cc.FadeIn:create(UI_ANIM_DURATION)),
        cc.CallFunc:create(
            function()
                self:resumeSelfAndChildren()-- 隐藏后暂停
            end
        )
    )
    action:setTag(actionTag)
    self:runAction(action)
end


function BaseItemDetailPanelLayer:hide(anim)
    self:setTouchEnabled(false)
    local actionTag = self:getActionTagByName("move")
    self:stopActionByTag(actionTag)
    self:setCascadeOpacityEnabled(true)
    -- self:callAllChild(
    --     function(child)
    --         child:setCascadeOpacityEnabled(true)
    --     end
    -- )

    if anim == true then
        local action =
            cc.Sequence:create(
            cc.Spawn:create(cc.MoveTo:create(UI_ANIM_DURATION, cc.p(0, 170)), cc.FadeOut:create(UI_ANIM_DURATION)),
            cc.CallFunc:create(
                function()
                    self:setVisible(false)
                    self:pauseSelfAndChildren()-- 隐藏后暂停
                end
            )
        )
        action:setTag(actionTag)
        self:runAction(action)
    else
        self:setVisible(false)
        self:pauseSelfAndChildren()-- 隐藏后暂停
    end

end

function BaseItemDetailPanelLayer:hideLayer()
    PopupLayerController:hideLayer(
        "BaseItemDetailPanelLayer",
        function(layer)
            layer:hide()
        end
    )
end

function BaseItemDetailPanelLayer:showLayer(item, itemAttr)
end


--@desc 背包界面调用的刷新方法
function BaseItemDetailPanelLayer:update(ft)
    -- body
end

Helper:classDefNodeGetInstance(BaseItemDetailPanelLayer)
return BaseItemDetailPanelLayer
0000000000000000