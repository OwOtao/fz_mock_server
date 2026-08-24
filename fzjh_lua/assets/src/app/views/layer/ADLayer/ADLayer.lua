local ADLayer = class("ADLayer", LayerEx)

function ADLayer:create()
    local p = ADLayer.new()
    return p
end

function ADLayer:ctor()
    self._hideCallback = function()end -- 界面隐藏回调

    -- 初始化
    self:init()
end

function ADLayer:init()
    local ui = require("Layer/CommunityUI/CommunityUI.lua").create()['root']
    self:addChild(ui)
    Helper:convertUI(self)

    self.Button_back:releaseFunc(function()
        self:hideLayer()
    end)
end

function ADLayer:initWebView()
    if ccexp.WebView then
        self:removeWebView()
        self.webView = ccexp.WebView:create()
        self.webView:setAnchorPoint(cc.p(0, 0))
        self.webView:setScalesPageToFit(true)
        -- self.webView:loadURL("http://fzjh.wsq.umeng.com")
        -- self.webView:loadURL("http://120.76.47.49:9091/testboard.php")

        self.webView:loadURL("http://120.76.45.120:1704/index.html")
        -- self.webView:loadURL("https://itunes.apple.com/cn/app/yao-xia/id1065183549?mt=8") -- 妖侠
        -- self.webView:loadURL("https://itunes.apple.com/cn/app/id1109674878?mt=8") -- 放置江湖
        self.webView:setContentSize(display.width, display.height - 108)

        -- 放入展示层
        self:addChild(self.webView)
        -- self.Panel_webview:addChild(self.webView)
    end
end

function ADLayer:removeWebView()
    if self.webView then
        self.webView:removeFromParent()
        self.webView = nil
    end
end

function ADLayer:setHideCallback(callback)
    self._hideCallback = Helper:getDef(callback, function()end)
end

function ADLayer:setButtonBackEnabled(bool)
    self.Button_back:setTouchEnabled(Helper:getDef(bool, false))
end

function ADLayer:showLayer()
    self:initWebView()
    self:show()
end

function ADLayer:hideLayer()
    PopupLayerController:hideLayer("ADLayer",function(layer)
        self._hideCallback()
        self:removeWebView()
        self:hide()
    end)
end

Helper:classDefNodeGetInstance(ADLayer)

return ADLayer
000