local NewHeadView = class("NewHeadView", ccui.Layout)

function NewHeadView:create(node)
    local p = NewHeadView:new()
    p:init(node)
    return p
end

function NewHeadView:init(node)
    self._size = cc.size(256, 256)
    self._imageView = nil
    self._animView = nil
    self._effectView = nil
    self._node = nil
    self._headPath = nil
    self._animName = nil
    self._effectName = nil

    self:_setNode(node)
end

function NewHeadView:_setNode(node)
    node:loadTexture("Image/UI/AttrUI/mianju/none.png")
    node:setTouchAnimEnabled(false)
    node:addChild(self)
    self:setName("headView")
    self:setContentSize(self._size)
    self:setClippingEnabled(true)
    self:setTouchEnabled(false)
    self._node = node
    self:setScale(self._node:getSizeWidth() / 256)
end

function NewHeadView:showHead(headPath)
    if not headPath or self._headPath == headPath then
        return
    end

    self._headPath = headPath
    -- 初始化图片
    if self._imageView == nil then
        self._imageView = ccui.ImageView:create()
        self:addChild(self._imageView)
    end

    -- 显示图片
    self._imageView:loadTexture(headPath)

    -- 设置渲染节点的坐标
    self._imageView:setPosition(cc.p(self._size.width / 2, self._size.height / 2))

    -- 移除动画
    if self._animView then
        self._animView:removeFromParent()
        self._animView = nil
        self._animName = nil
    end
end

function NewHeadView:showAnim(animName,animFolderName)
    if not animName or not animFolderName or self._animName == animName then
        return
    end
    self._animName = animName
    local animView = assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/portrait/maskV3/"..animFolderName.."/skeleton.skel", "Anim/portrait/maskV3/"..animFolderName.."/skeleton.atlas", 1), "动画初始化出错")
    if self._animView then
        self:removeChild(self._animView)
    end
    self:addChild(animView)
    self._animView = animView

    self._animView:setSlotsToSetupPose()
    -- 显示动画
    self._animView:setAnimation(0, animName, true)

    -- 设置渲染节点的坐标
    do
        self._animView:setPosition(cc.p(self._size.width / 2, self._size.height / 2))
    end

    -- 移除图片
    if self._imageView then
        self._imageView:removeFromParent()
        self._imageView = nil
        self._headPath = nil
    end
end

function NewHeadView:playEffect(effectName)
    if effectName == nil then
        if self._effectView then
            self._effectView:removeFromParent()
            self._effectName = nil
            self._effectView = nil
        end
        return
    end

    if self._effectName ~= effectName then
        self._effectName = effectName
        if self._effectView then
            self._effectView:removeFromParent()
        end
        local effectView = Resource:getSkAnim("maskEffect", 1)
        self:addChild(effectView)
        self._effectView = effectView
        self._effectView:setPosition(cc.p(self._size.width / 2, self._size.height / 2))
        self._effectView:playAnim(effectName, true)
    end

end

return NewHeadView
000000000000