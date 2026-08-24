-- add by XiaoZhiWei 2017/09/18 10:26:47 暂未使用 为开发完

-- local Resource = require("app.Resource")
-- local PopRichText = class(PopRichText, require("app.views.base.BaseLayer"))

-- function PopRichText:create(text, color, font, fontSize)
-- 	local p = PopRichText:new()
-- 	p:init(text, color, font, fontSize)
-- 	return p
-- end

-- function PopRichText:pop(text, color, font, fontSize)
-- 	local runningScene = cc.Director:getInstance():getRunningScene()
--     if runningScene then
--     	local p = PopRichText:create(text, color, font, fontSize)
--     	runningScene:addChild(p)
--     	p:move(display.cx, display.cy)
--     	p:maxZ()
--     end
-- end

-- function PopRichText:init(text, color, font, fontSize)
-- 	local sprite = cc.Sprite:create("test.png")
-- 	self:addChild(sprite)

-- 	if color == nil then
-- 		color = cc.c3b(255, 255, 255)
-- 	end
-- 	if font == nil then
-- 		font = Resource:getFontPath("default")
-- 	end
-- 	if fontSize == nil then
-- 		fontSize = 42
-- 	end

	
	
-- 	local richText = ExtRichTextScroll:create()
-- 	self:addChild(richText)
-- 	richText:pushBackText("123456", color, 255, font, fontSize)
-- end

-- return PopRichText00000000000