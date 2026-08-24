local ShenBingAutoCuiLianDetailUI = class("ShenBingAutoCuiLianDetailUI", LayerEx)

function ShenBingAutoCuiLianDetailUI:create()
	local p = ShenBingAutoCuiLianDetailUI:new()
	p:init()
	return p
end

function ShenBingAutoCuiLianDetailUI:init()
    self._UI = require("Layer/ShenBing/ShenBingAutoCuiLianDetailUI.lua").create()['root']

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:initRichText()
end

function ShenBingAutoCuiLianDetailUI:showUI()
    self:setVisible(true)
end

function ShenBingAutoCuiLianDetailUI:hideUI()
    self:setVisible(false)
end

function ShenBingAutoCuiLianDetailUI:setTextTitle(text)
    self.Text_title:setString(text)
end

function ShenBingAutoCuiLianDetailUI:initRichText()
	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
    end
    
	local x, y = self.Image_kuang1.Panel_text:getPosition()
	local size = self.Image_kuang1.Panel_text:getContentSize()
	
	local richTextScroll = ExtRichTextScroll:create()
	self.Image_kuang1.Panel_text:getParent():addChild(richTextScroll)
	richTextScroll:move(cc.p(37, 38))
	richTextScroll:setSize(size)
	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
	richTextScroll:getRichText():setVerticalSpace(20)
	self.RichText_print = richTextScroll
	
	self.RichText_print:setTextMaxHeight(99999)
	self.RichText_print:setBounceEnabled(true)
end

function ShenBingAutoCuiLianDetailUI:creatRichContent()
	local x, y = self.Text_content:getPosition()
	local size = self.Text_content:getContentSize()
	
	local richTextScroll = ExtRichTextScroll:create()
	-- self.Text_content:getParent():addChild(richTextScroll)
	richTextScroll:setAnchorPoint(cc.p(0, 0))
	richTextScroll:setSize(size)
	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
	richTextScroll:getRichText():setVerticalSpace(20)

	-- richTextScroll:setTextMaxHeight(43)
	richTextScroll:setBounceEnabled(false)
	richTextScroll:setScrollBarEnabled(false)
	richTextScroll:setTouchEnabled(false)

	return richTextScroll
end

function ShenBingAutoCuiLianDetailUI:printText(str, verticalSpace)
	self.RichText_print:pushBackText(str, cc.c3b(102, 153, 153), 255, Resource:getFontPath("default"), 38)
	
	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end

function ShenBingAutoCuiLianDetailUI:setContentListView(array)
	self.Image_kuang2.ListView_content:removeAllItems()
    for i,text in ipairs(array) do
		local row = self:creatRichContent()
		self.Image_kuang2.ListView_content:pushBackCustomItem(row)

		row:pushBackText(text, cc.c3b(255, 255, 255), 255, Resource:getFontPath("default"), 38)
    end

	self.Image_kuang2.ListView_content:setScrollBarEnabled(false)
	self.Image_kuang2.ListView_content:setTouchEnabled(false)
end

function ShenBingAutoCuiLianDetailUI:setButtonConfirm(name,func)
    self.Button_confirm.Text_ButtonName:setString(name)
    self.Button_confirm:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return ShenBingAutoCuiLianDetailUI000000000