local CommunityLayer = class("CommunityLayer", LayerEx)

function CommunityLayer:create()
    local p = CommunityLayer.new()
    return p
end

function CommunityLayer:ctor()
    self._onPauseCallback = function()
    end -- 暂停回调

    self:init()
end

function CommunityLayer:init()
    local ui = require("Layer/CommunityUI/CommunityUI.lua").create()["root"]
    self:addChild(ui)
    Helper:convertUI(self)

    self:setButtonBack()
    self:setTitle()
end

function CommunityLayer:initWebView(url)
    if ccexp.WebView and self.url ~= nil then
        self:removeWebView()
        self.webView = ccexp.WebView:create()
        self.webView:setAnchorPoint(cc.p(0, 0))
        self.webView:setScalesPageToFit(true)
        self.webView:loadURL(self.url, self.cleanCache)
        self.webView:setPosition(cc.p(-1, -1))
        self.webView:setContentSize(display.width + 2, display.height - 107)

        -- 放入展示层
        self:addChild(self.webView)
    end
end

function CommunityLayer:removeWebView()
    if self.webView then
        self.webView:removeFromParent()
        self.webView = nil
    end
end

function CommunityLayer:setUrl(url, cleanCache)
    cleanCache = Helper:getDef(cleanCache, false)
    url = JMForLua:decrypt(url)
    self.url = url
    self.cleanCache = cleanCache
end

function CommunityLayer:setOnPauseCallback(callback)
    self._onPauseCallback =
        Helper:getDef(
        callback,
        function()
        end
    )
end

function CommunityLayer:onResume()
    self:initWebView()
end

function CommunityLayer:onPause()
    self._onPauseCallback()
    self:removeWebView()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/13 17:36:33
-- @desc 设置标题
function CommunityLayer:setTitle(title)
    title = Helper:getDef(title, "公告")
    self.Text_title:setString(title)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/13 17:35:35
-- @desc 设置返回按钮
function CommunityLayer:setButtonBack()
    self.Button_back:releaseFunc(
        function()
            self:hide()
        end
    )
end

function CommunityLayer:setButtonBackVisible(visible)
    visible = Helper:getDef(visible, false)
    self.Button_back:setVisible(visible)
end

Helper:classDefNodeGetInstance(CommunityLayer)
return CommunityLayer
0