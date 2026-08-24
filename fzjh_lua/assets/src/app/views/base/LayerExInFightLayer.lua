-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/22 17:55:40
-- @desc 增加Layer类, 提供 不同显示和隐藏动画, 以及切换过程防止触摸的支持.
local LayerEx = class("LayerEx", cc.Layer)

LayerEx.title = "加载中"

-- 显示和隐藏动画类型
LayerEx.ShowAndHideAnimType =
    {
        FAST = 1,
        FADE = 2,
        ROLL = 3,
        DARK = 4 -- 变黑过度
    }

-- 懒惰初始化
function LayerEx:lazyInit()
    if self._showAndHideAnimType == nil then
        self._showAndHideAnimType = LayerEx.ShowAndHideAnimType.FADE
    end
    if self._showAndHideAnimDuration == nil then
        self._showAndHideAnimDuration = 1 --0.2
    end
end

-- 设置显示和隐藏的动画类型
function LayerEx:setShowAndHideAnimType(showAndHideAnimType)
    if LayerEx.ShowAndHideAnimType[showAndHideAnimType] then
        self._showAndHideAnimType = LayerEx.ShowAndHideAnimType[showAndHideAnimType]
    end
end

-- 显示触摸遮盖层
function LayerEx:showTouchSwallowLayer()
    if self._touchSwallowLayer == nil then
        self._touchSwallowLayer = ccui.Widget:create()
        self._touchSwallowLayer:ignoreContentAdaptWithSize(false)
        self:addChild(self._touchSwallowLayer, 10)
        self._touchSwallowLayer:setSize(1080, 1920)
        self._touchSwallowLayer:setAnchorPoint(cc.p(0, 0))
    end
    self._touchSwallowLayer:setTouchEnabled(true)
end

-- 隐藏触摸遮盖层
function LayerEx:hideTouchSwallowLayer()
    if self._touchSwallowLayer == nil then
        return
    end
    self._touchSwallowLayer:setTouchEnabled(false)
end

-- 显示
function LayerEx:show(endFunc)
    self:resumeSelfAndChildren()-- 显示前恢复
    self:setVisible(true)
    
    -- 局部变量初始化
    endFunc = Helper:getDef(endFunc, EMPTY_FUNC)
    
    -- 懒惰初始化
    self:lazyInit()
    
    -- 显示触摸遮盖层
    self:showTouchSwallowLayer()
    
    -- 显示前事件 onPreShow
    Helper:getDef(self.onPreShow, EMPTY_FUNC)(self)
    
    -- 显示动画完成回调
    local secondEndFunc = function()
        self:delayFunc(0, function()
            self:hideTouchSwallowLayer()
            
            -- 显示后事件 onAftShow
            Helper:getDef(self.onAftShow, EMPTY_FUNC)(self)
            
            if endFunc then
                endFunc()
            end
        end)
    end
    
    -- 播放动画
    switch(self._showAndHideAnimType,
        {
            [LayerEx.ShowAndHideAnimType.FAST] = function()
                self:showFast(secondEndFunc)
            end,
            [LayerEx.ShowAndHideAnimType.FADE] = function()
                self:showWithFade(secondEndFunc)
            end,
            [LayerEx.ShowAndHideAnimType.ROLL] = function()
                self:showWithRoll(secondEndFunc)
            end,
            [LayerEx.ShowAndHideAnimType.DARK] = function()
                self:showWithDark(secondEndFunc)
            end,
            default = function()
                self:showWithFade(secondEndFunc)
            end
        })
end

function LayerEx:hide(endFunc)
    -- 局部变量初始化
    endFunc = Helper:getDef(endFunc, EMPTY_FUNC)
    
    -- 懒惰初始化
    self:lazyInit()
    
    -- 显示触摸遮盖层
    self:showTouchSwallowLayer()
    
    -- 隐藏前事件 onPreHide
    Helper:getDef(self.onPreHide, EMPTY_FUNC)(self)
    
    -- 显示动画完成回调
    local secondEndFunc = function()
        self:delayFunc(0, function()
            self:hideTouchSwallowLayer()
            self:setVisible(false)
            self:pauseSelfAndChildren()-- 隐藏后暂停

            -- 隐藏后事件 onAftHide
            Helper:getDef(self.onAftHide, EMPTY_FUNC)(self)
            
            if endFunc then
                endFunc()
            end
        end)
    end
    
    -- 播放动画
    switch(self._showAndHideAnimType,
        {
            [LayerEx.ShowAndHideAnimType.FAST] = function()
                self:hideFast(secondEndFunc)
            end,
            [LayerEx.ShowAndHideAnimType.FADE] = function()
                self:hideWithFade(secondEndFunc)
            end,
            [LayerEx.ShowAndHideAnimType.ROLL] = function()
                self:hideWithRoll(secondEndFunc)
            end,
            [LayerEx.ShowAndHideAnimType.DARK] = function()
                self:hideWithDark(secondEndFunc)
            end,
            default = function()
                self:hideWithFade(secondEndFunc)
            end
        })
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 快速显示
function LayerEx:showFast(endFunc)
    self:lazyInit()
    -- self:resumeSelfAndChildren()-- 显示前恢复
    self:setSelfAndChildrenCascadeOpacityEnabled(true)
    self:setOpacity(255)
    
    Helper:getDef(endFunc, EMPTY_FUNC)()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 快速隐藏
function LayerEx:hideFast(endFunc)
    self:lazyInit()
    -- self:pauseSelfAndChildren()-- 显示前恢复
    self:setSelfAndChildrenCascadeOpacityEnabled(true)
    self:setOpacity(0)
    
    Helper:getDef(endFunc, EMPTY_FUNC)()
end

-- 透明度显示
function LayerEx:showWithFade(endFunc)
    self:lazyInit()
            
    self:setSelfAndChildrenCascadeOpacityEnabled(true)
    
    self:runActionWithName("showAndHide",
        cc.Sequence:create(
            cc.FadeIn:create(self._showAndHideAnimDuration)
            , cc.CallFunc:create(function()
                if endFunc then
                    endFunc(self)
                end
            end)))
end

-- 透明度隐藏
function LayerEx:hideWithFade(endFunc)
    self:lazyInit()
    
    self:setSelfAndChildrenCascadeOpacityEnabled(true)
    self:runActionWithName("showAndHide",
        cc.Sequence:create(
            cc.FadeOut:create(self._showAndHideAnimDuration)
            , cc.CallFunc:create(function()                
                if endFunc then
                    endFunc(self)
                end
            end)))
end

-- 滚动显示
function LayerEx:showWithRoll(endFunc)
    local height = display.height
    self:lazyInit()
    -- self:resumeSelfAndChildren()-- 显示前恢复
    self:move(cc.p(0, height))
    
    self:runActionWithName("showAndHide",
        cc.Sequence:create(
            cc.MoveTo:create(self._showAndHideAnimDuration, cc.p(0, 0)),
            cc.CallFunc:create(function()
                if endFunc then
                    endFunc(self)
                end
            end)))
end

-- 滚动隐藏
function LayerEx:hideWithRoll(endFunc)
    local height = display.height
    self:lazyInit()
    -- self:resumeSelfAndChildren()-- 显示前恢复
    self:runActionWithName("showAndHide",
        cc.Sequence:create(
            cc.MoveTo:create(self._showAndHideAnimDuration, cc.p(0, height)),
            cc.CallFunc:create(function()
                if endFunc then
                    endFunc(self)
                end
            end)))
end

-- 变黑显示 add by TangJian 2016/11/26 17:06:05
function LayerEx:showWithDark(endFunc)
    -- self:resumeSelfAndChildren()-- 显示前恢复
    
    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    layerColor:setSelfAndChildrenCascadeOpacityEnabled(true)
    self:getParent():addChild(layerColor)
    layerColor:maxZ()
    
    local text = ccui.Text:create()
    text:setFontName(Resource:getFontPath("default"))
    text:setTextColor(cc.c3b(203, 203, 203))
    text:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    text:setFontSize(48)
    text:setString(self.title)
    layerColor:addChild(text)
    text:setPositionX(display.width / 2)
    text:setPositionY(display.height / 2)
    
    layerColor:setOpacity(0)
    layerColor:runActionWithName("showAndHide",
        cc.Sequence:create(
            cc.FadeIn:create(self._showAndHideAnimDuration),
            cc.CallFunc:create(function()
                self:showFast(endFunc)
                self:showTouchSwallowLayer()
                
                -- 隐藏颜色层
                layerColor:runActionWithName("showAndHide", cc.Sequence:create(
                    cc.FadeOut:create(self._showAndHideAnimDuration),
                    cc.CallFunc:create(function()
                        self:hideTouchSwallowLayer()
                    end), cc.RemoveSelf:create()))
            end)))
end

-- 变黑隐藏 add by TangJian 2016/11/26 17:06:06
function LayerEx:hideWithDark(endFunc)
    self:hideWithFade(endFunc)

-- local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
-- self:getParent():addChild(layerColor)
-- layerColor:maxZ()
-- layerColor:setOpacity(0)
-- layerColor:runActionWithName("showAndHide",
--     cc.Sequence:create(
--         cc.FadeIn:create(self._showAndHideAnimDuration),
--         cc.CallFunc:create(function()
--             Helper:safeCall(function()
--                 self:hideFast()
--                 self:showTouchSwallowLayer()
--                 -- 隐藏颜色层
--                 layerColor:runActionWithName("showAndHide", cc.Sequence:create(
--                     cc.FadeOut:create(self._showAndHideAnimDuration),
--                     cc.CallFunc:create(function()
--                         self:hideTouchSwallowLayer()
--                         Helper:getDef(endFunc, EMPTY_FUNC)()
--                     end), cc.RemoveSelf:create()))
--             end)
--         end)))
end

return LayerEx
0000000000000000