local DialogELayer = class("DialogELayer", cc.Layer)

function DialogELayer:create()
	local p = DialogELayer:new()
	p:init()
	return p
end

function DialogELayer:init()
	self._round = require("Layer/Dialog/Dialog5UI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self)
	self:setVisible(false)
	self:initRichTextItem()

	self.lastPoistionType = nil
end

function DialogELayer:show(text,poistionType)
	self:maxZ()
	self:setVisible(true)

	self:setText_desc(text,poistionType)
end

function DialogELayer:hide()
	self:setVisible(false)
end

function DialogELayer:setText_desc(text,poistionType)
	if not text then
		self:hide()
		return
	end
	self:initRichText(text,poistionType)
	-- self.Text_desc:setString(text)
end

function DialogELayer:initRichTextItem()
	if self.RichText_Print then
		self.RichText_Print:getRichText():removeFromParent()
	end
	
	local x, y = self.Text_desc:getPosition()
	local size = self.Text_desc:getContentSize()
	
	self.RichText_Print = ExtRichTextScroll:create()
	self.RichText_Print:setAnchorPoint( 0.5 , 0.5 )
	self:addChild(self.RichText_Print)
	self.RichText_Print:move(cc.p(x, y))
	self.RichText_Print:setSize(size)
	self.RichText_Print:setVerticalSpace(5)
	self.RichText_Print:setDirection(kCCScrollViewDirectionVertical)
end

local positionList = {
	up = {positionX = 540,positionY = 1150 },
	centre = {positionX = 540,positionY = 800 },
	down = {positionX = 540,positionY = 450}
}

local textColor = cc.c3b(102, 153, 153)
function DialogELayer:initRichText(str,poistionType)
	if self.RichText_Print then
		self.RichText_Print:getRichText():removeAllElement()
	end

	if not poistionType or not positionList[poistionType] then
		poistionType = "down"
	end

	if poistionType ~= self.lastPoistionType then
		local positionX ,positionY = positionList[poistionType].positionX,positionList[poistionType].positionY
		self.Image_help:setPosition(positionX,positionY)
		self.Text_desc:setPosition(positionX,positionY)

		local x, y = self.Text_desc:getPosition()
		self.RichText_Print:move(cc.p(x, y))

		self.lastPoistionType  = poistionType
	end

   	self.RichText_Print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
	self.RichText_Print:setTouchEnabled(true)
	self:delayFunc(0.1,function ()
		self.RichText_Print:jumpToTop()
		self.Panel_back:setTouchEnabled(true)
		self.canBack = true
	end)
end

function DialogELayer:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
		self:hide()
		if func then
			func()
		end
	end)
end

Helper:classDefNodeGetInstance(DialogELayer)
return DialogELayer0000000000000000