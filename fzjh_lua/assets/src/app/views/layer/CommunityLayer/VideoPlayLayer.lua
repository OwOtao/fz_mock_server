local VideoPlayLayer = class("VideoPlayLayer", LayerEx)

function VideoPlayLayer:create()
    local p = VideoPlayLayer:new()
    p:init()
    return p
end

function VideoPlayLayer:init()
    local ui = require("Layer/CommunityUI/CommunityUI.lua").create()["root"]
    self:addChild(ui)
    Helper:convertUIByParent(self)

    self.Panel_webview:setVisible(false)
    -- self.Image_titleBack:setVisible(false)

    self:setButtonBack()
end

function VideoPlayLayer:hideLayer()
    PopupLayerController:hideLayer(
        "VideoPlayLayer",
        function(layer)
            layer:removeWebView()
            self._closeCallBack()
            layer:hide()
        end,
        0
    )
end

function VideoPlayLayer:showLayer(fileName, delayCloseTime, closeCallBack)
    if fileName == nil then
        return
    end

    delayCloseTime = delayCloseTime or 30
    delayCloseTime = delayCloseTime + 3

    self._closeCallBack = Helper:getDef(closeCallBack, EMPTY_FUNC)

    self:initWebView(fileName)

    self:show()
    self:delayFunc(
        delayCloseTime,
        function()
            self:hideLayer()
        end
    )
end

function VideoPlayLayer:initWebView(fileName)
    if ccexp.WebView then
        local htmlPath = cc.FileUtils:getInstance():fullPathForFilename("html/testpic.html")

        if string.sub(htmlPath, 1, 1) ~= "/" then
            htmlPath = "html/testpic.html"
        end

        local htmlString = cc.FileUtils:getInstance():getStringFromFile(htmlPath)
        
        local gifFileName = cc.FileUtils:getInstance():fullPathForFilename("html/" .. fileName .. ".gif")

        local jqFileName = cc.FileUtils:getInstance():fullPathForFilename("html/jquery-3.4.1.min.js")

        local jsFileName = cc.FileUtils:getInstance():fullPathForFilename("html/jweixin-1.2.0.js")

        if string.sub(gifFileName, 1, 1) ~= "/" then
            gifFileName = fileName .. ".gif"
        end

        if string.sub(jqFileName, 1, 1) ~= "/" then
            jqFileName = "jquery-3.4.1.min.js"
        end

        if string.sub(jsFileName, 1, 1) ~= "/" then
            jsFileName = "jweixin-1.2.0.js"
        end
        
        htmlString = string.gsub(htmlString, "{FILENAME_GIF}", gifFileName)

        htmlString = string.gsub(htmlString, "{JQ_NAME}", jqFileName)

        htmlString = string.gsub(htmlString, "{JS_NAME}", jsFileName)

        if PRINT_MODE == 1 then
            print("============================")
            print("html path:",htmlPath)
            print("-------------------------------------------------------------------------")
            print("gif path:",gifFileName)
            print("-------------------------------------------------------------------------")
            print("jqFileName path:",jqFileName)
            print("-------------------------------------------------------------------------")
            print("jsFileName path:",jsFileName)
            print("============================\n")
            print(htmlString)
            print("============================\n")
        end

        self:removeWebView()
        self.webView = ccexp.WebView:create()
        self.webView:setAnchorPoint(cc.p(0, 0))
        self.webView:setScalesPageToFit(true)
        if Game:isNewPackage() == true and Game:getVersion() ~= "1.5.10" then
            self.webView:setBounces(false)
        end
        self.webView:loadHTMLString(htmlString, "res/html")
        self.webView:setPosition(cc.p(0, 0))
        self.webView:setContentSize(display.width, display.height)
        -- 放入展示层
        self:addChild(self.webView)
    end
end

function VideoPlayLayer:removeWebView()
    if self.webView then
        self.webView:removeFromParent()
        self.webView = nil
    end
end

function VideoPlayLayer:setButtonBack()
    self.Image_titleBack.Button_back:releaseFunc(
        function()
            self:hideLayer()
        end
    )
end

Helper:classDefNodeGetInstance(VideoPlayLayer)
return VideoPlayLayer000000000000000