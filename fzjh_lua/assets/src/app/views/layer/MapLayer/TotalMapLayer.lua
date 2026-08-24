local Resource = require("app.Resource")
-- local TotalMapUI = require("app.views.ui.MapUI.TotalMapUI")
local TotalMapLayer = class("TotalMapLayer", require("app.views.base.BaseLayer"))

function TotalMapLayer:create()
	local p = TotalMapLayer:new()
	p:init()
	return p
end

function TotalMapLayer:init()
	-- local totalMapUI = TotalMapUI:create()
	-- self:addChild(totalMapUI)


-- 	local richTextScroll = ExtRichTextScroll:create()   	
-- 	self:addChild(richTextScroll)
--    	richTextScroll:setSize(cc.size(1080, 1920))   	
--    	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
--    	richTextScroll:getRichText():setVerticalSpace(-5)
--    	self.richTextScroll = richTextScroll

--    	self.richTextScroll:setBounceEnabled(true)


--    	local mapStr = [[菜地——后院——菜地
-- 　　　　　▏
-- 马房——后院——木材房　　馆主卧室　　　　　　　　卧室——卧室　
-- 　　　　　▏　　　　　　　　　▏　　　　　　　　　　▏
-- 水房——后院——柴房　　　　长廊———书房　　　　长廊
-- 　　　　　▏　　　　　　　　　▏　　　　　　　　　　▏
-- 　　　　石路　　习武堂　　　　▏　　　学堂　　　　　▏
-- 　　　　　▏　　　　▏　　　　▏　　　　▏　　　　　▏
-- 饭厅——石路———石路———大厅———石路———物品房
-- 　　　　　▏　　　　▏　　　　▏　　　　▏　　　　　▏
-- 　　　　长廊　　习武堂　　　　▏　　　帐房　　　　长廊
-- 　　　　　▏　　　　　　　　　▏　　　　　　　　　　▏
-- 　　　西武场　　　　　　　武馆大院　　　　　　　东武场
-- 　　　　　▏　　　　　　　　　▏　　　　　　　　　　▏
-- 　　　西武场——长廊———武馆大院——长廊———东武场
-- 　　　　　　　　　　　　　　　▏
-- 　　　　　　　　　　　　　　大门]]


--    	self.richTextScroll:pushBackText(mapStr, cc.c3b(102, 153, 153), 255, Resource:getFontPath("default"), 32)
	return true
end



return TotalMapLayer0000000000000000