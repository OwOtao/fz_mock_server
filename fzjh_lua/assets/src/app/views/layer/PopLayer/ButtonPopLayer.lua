local ButtonPopLayer = class("ButtonPopLayer", ccui.Widget)

function ButtonPopLayer:create()
    local p = ButtonPopLayer.new()
    return p
end

-- 创建buttonPopLayer到runningScene
function ButtonPopLayer:createCustomInRunningScene(text, buttonName1, buttonFunc1, buttonName2, buttonFunc2)
    local buttonPopLayer = nil
    local runningScene = cc.Director:getInstance():getRunningScene()
    if runningScene then
        buttonPopLayer = ButtonPopLayer:createCustom(text, buttonName1, buttonFunc1, buttonName2, buttonFunc2)
        -- 添加到当前scene
        runningScene:addChild(buttonPopLayer)
        -- 设置为置顶
        buttonPopLayer:setGlobalZOrder(1)
        buttonPopLayer:maxZ()
        -- 显示
        buttonPopLayer:show()
    end
    return buttonPopLayer
end

-- 创建自定义
function ButtonPopLayer:createCustom(text, buttonName1, buttonFunc1, buttonName2, buttonFunc2)
    local p = ButtonPopLayer:create()
    
    -- 设置文字显示
    p:setText(text)
    
    -- 设置按钮
    p:setButton1(buttonName1, buttonFunc1)
    p:setButton2(buttonName2, buttonFunc2)
    return p
end

function ButtonPopLayer:ctor()
    self:init()
end

function ButtonPopLayer:init()
    self._UI = require("Layer/PopUI/ButtonPopUI").create()['root']
    self._UI:addTo(self)
    
    Helper:convertUI(self)-- 获得所有子节点
    
    
    -- 错误提示 add by TangJian 2017/06/25 00:35:29
    do
        local text = ccui.Text:create()
        self._UI:addChild(text)
        
        text:setFontSize(24)
        text:setString("")
        
        text:setAnchorPoint(cc.p(1, 0))
        text:setPosition(cc.p(display.width, 0))
        self._errorText = text
    end
end

function ButtonPopLayer:setErrorText(text)
	self._errorText:setString(text)
end

function ButtonPopLayer:setText(text)
    self.Text_center:setText(text)
end

function ButtonPopLayer:setButton1(name, func)
    if func == nil then
        self.Text_1:setVisible(false)
        self.Button_1:setVisible(false)
        return
    else
        end
    if name == nil then
        name = "重试"
    end
    self.Text_1:setString(name)
    self.Button_1:releaseFunc(
        function()
            func()
            self:hideAndRemoveSelf()
        end)
end

function ButtonPopLayer:setButton2(name, func)
    if func == nil then
        self.Text_2:setVisible(false)
        self.Button_2:setVisible(false)
        return
    else
        end
    if name == nil then
        name = "重试"
    end
    self.Text_2:setString(name)
    self.Button_2:releaseFunc(
        function()
            func()
            self:hideAndRemoveSelf()
        end)
end

function ButtonPopLayer:getButton1CurrTouchEvent()
    return self.Button_1:getCurrTouchEvent()
end

function ButtonPopLayer:getButton2CurrTouchEvent()
    return self.Button_2:getCurrTouchEvent()
end

function ButtonPopLayer:show()
    self:setVisible(true)
end

function ButtonPopLayer:hide()
    self:setVisible(false)
end

function ButtonPopLayer:hideAndRemoveSelf()
    self:removeFromParent()
end


Helper:classDefNodeGetInstance(ButtonPopLayer)
return ButtonPopLayer
00000000000000