local FengXiangLayer = class("FengXiangLayer", LayerEx)

function FengXiangLayer:create()
    local p = FengXiangLayer.new()
    return p
end

function FengXiangLayer:ctor()
    self._onPauseCallback = function()end -- 暂停回调
    
    self:init()
end

function FengXiangLayer:init()
    local ui = require("Layer/CommunityUI/CommunityUI.lua").create()['root']
    self:addChild(ui)
    Helper:convertUI(self)

    self:setButtonBack()
    self:setTitle()
end

function FengXiangLayer:initWebView(url)
    if ccexp.WebView and self.url ~= nil then
        self:removeWebView()
        self.webView = ccexp.WebView:create()
        self.webView:setAnchorPoint(cc.p(0, 0))
        self.webView:setScalesPageToFit(true)
        -- self.webView:loadURL("http://fzjh.wsq.umeng.com")
        -- self.webView:loadURL("http://120.76.47.49:9091/testboard.php")
        self.webView:loadURL(self.url)
        -- self.webView:loadURL("https://itunes.apple.com/cn/app/yao-xia/id1065183549?mt=8") -- 妖侠
        -- self.webView:loadURL("https://itunes.apple.com/cn/app/id1109674878?mt=8") -- 放置江湖
        self.webView:setPosition(cc.p(-1, -1))
        self.webView:setContentSize(display.width + 2, display.height - 107)

        -- 放入展示层
        self:addChild(self.webView)
        -- self.Panel_webview:addChild(self.webView)
    end
end

function FengXiangLayer:removeWebView()
    if self.webView then
        self.webView:removeFromParent()
        self.webView = nil
    end
end

function FengXiangLayer:setUrl(url)
    url = JMForLua:decrypt(url)
    self.url = url
end


function FengXiangLayer:setOnPauseCallback(callback)
    self._onPauseCallback = Helper:getDef(callback, function()end)
end

function FengXiangLayer:onResume()
    self:initWebView()
end

function FengXiangLayer:onPause()
    self._onPauseCallback()
    self:removeWebView()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/13 17:36:33
-- @desc 设置标题
function FengXiangLayer:setTitle(title)
    title = Helper:getDef(title, "公告")
    self.Text_title:setString(title)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/13 17:35:35
-- @desc 设置返回按钮
function FengXiangLayer:setButtonBack()
    self.Button_back:releaseFunc(function()
        self:hide()
        self._onPauseCallback()
        self:removeWebView()
        self:destroyInstance()
    end)
end

Helper:classDefNodeGetInstance(FengXiangLayer)
return FengXiangLayer
0000000000000000