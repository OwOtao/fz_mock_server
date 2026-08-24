local WebViewTest = class("WebViewTest", cc.Layer)


function WebViewTest:create()
	local p = WebViewTest:new()
	return p
end


function WebViewTest:ctor()
	local webView = ccexp.WebView:create()
	webView:setContentSize(display.width, display.height)
	webView:setAnchorPoint(cc.p(0, 0))
	webView:setScalesPageToFit(true)
	webView:loadURL("http://120.76.47.49:9091/testboard.php")
	webView:addTo(self)
end
00000000000