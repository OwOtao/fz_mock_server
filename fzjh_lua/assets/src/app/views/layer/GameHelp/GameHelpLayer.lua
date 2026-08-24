local GameHelpLayer = class("GameHelpLayer", LayerEx)

function GameHelpLayer:create()
    local p = GameHelpLayer.new()
    return p
end

function GameHelpLayer:ctor()
    self._onPauseCallback = function()end -- 暂停回调
    self:init()
end

function GameHelpLayer:init()
    local ui = require("Layer/GameHelpUI/GameHelpUI.lua").create()['root']
    self:addChild(ui)
    Helper:convertUI(self)
    self:setButtonBack()
    self:setTitle()
end

function GameHelpLayer:initWebView(url)
    if ccexp.WebView and self.url ~= nil then
        self:removeWebView()
        self.webView = ccexp.WebView:create()
        self.webView:setAnchorPoint(cc.p(0, 0))
        self.webView:setScalesPageToFit(true)
        self.webView:loadURL(self.url)
        self.webView:setPosition(cc.p(-1, -1))
        self.webView:setContentSize(display.width + 2, display.height - 107)
        self:addChild(self.webView)
    end
end

function GameHelpLayer:removeWebView()
    if self.webView then
        self.webView:removeFromParent()
        self.webView = nil
    end
end

function GameHelpLayer:setUrl(url)
    url = JMForLua:decrypt(url)
    self.url = url
end


function GameHelpLayer:setOnPauseCallback(callback)
    self._onPauseCallback = Helper:getDef(callback, function()end)
end

function GameHelpLayer:onResume()
    self:initWebView()
end

function GameHelpLayer:onPause()
    self._onPauseCallback()
    self:removeWebView()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/13 17:36:33
-- @desc 设置标题
function GameHelpLayer:setTitle(title)
    title = Helper:getDef(title, "放置江湖攻略客栈")
    self.Text_title:setString(title)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/13 17:35:35
-- @desc 设置返回按钮
function GameHelpLayer:setButtonBack()
    self.Button_back:releaseFunc(function()
        PopupLayerController:hideLayer("GameHelpLayer", function(layer)
            self:hide()
        end)
    end)
end
Helper:classDefNodeGetInstance(GameHelpLayer)
return GameHelpLayer
000000000