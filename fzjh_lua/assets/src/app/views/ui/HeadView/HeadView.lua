local HeadView = class("HeadView", ccui.Widget)

function HeadView:create()
    local p = HeadView.new()
    p:__init()
    return p
end

function HeadView:__init()
    self.__UI = require("Layer/HeadUI/HeadViewUI.lua").create()["root"]

    self.__UI:setAnchorPoint(0.5000, 0.5000)

    self.__UI:addTo(self)

    Helper:convertUIByParent(self.__UI)

    self:setIgnoreAnchorPointForPosition(true)

    self:setAnchorPoint(0.5000, 0.5000)

    self.__UI:setPosition(cc.p(0, 0))

    -- self:__initHeadAnimView()

    self:__initEffectAnimView()
end

function HeadView:getContentSize()
    return self.__UI:getContentSize()
end

function HeadView:__initHeadAnimView(animFolderName)
    if self.__animView then
        self.AnimParent:removeChild(self.__animView)

        self.__animView = nil
    end
    
    self.__animView = assert(spine38.NewSkeletonAnimation:createWithBinaryFile("Anim/portrait/maskV3/"..animFolderName.."/skeleton.skel", "Anim/portrait/maskV3/"..animFolderName.."/skeleton.atlas", 1), "动画初始化出错")

    self.__animView:setPosition(cc.p(self.AnimParent.Node_AnimPos:getPosition()))

    self.AnimParent:addChild(self.__animView)
end

function HeadView:__initEffectAnimView()
    self.__effectView = Resource:getSkAnim("maskEffect", 1)

    self.__effectView:setPosition(cc.p(self.AnimParent.Node_EffectPos:getPosition()))

    self.AnimParent:addChild(self.__effectView)
end

function HeadView:setBorderImg(path)
    self.Img_border:loadTexture(path)
end

function HeadView:setBorderVisible(bool)
    self.Img_border:setVisible(bool)
end

function HeadView:setHeadImageVisible(bool)
    self.Img_Static:setVisible(bool)
end

function HeadView:setHeadImage(path)
    self.Img_Static:loadTexture(path)
end

function HeadView:setHeadAnimVisible(bool)
    if self.__animView then
        self.__animView:setVisible(bool)
    end
end

function HeadView:showTheHeadAnim(animName,animFolderName)
    self:__initHeadAnimView(animFolderName)

    self.__animView:setSlotsToSetupPose()
    -- 显示动画
    self.__animView:setAnimation(0, animName, true)
end

function HeadView:setHeadEffectVisible(bool)
    self.__effectView:setVisible(bool)
end

function HeadView:playEffect(effectName)
    self.__effectView:playAnim(effectName, true)
end

function HeadView:setImageBackgroud(path)
    self.Img_bg:loadTexture(path)
end

function HeadView:releaseFunc(func)
    self.Click_Area:releaseFunc(func)
end

function HeadView:setClickEnable(bool)
    self.Click_Area:setTouchEnabled(bool)
end

return HeadView
0