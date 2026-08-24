local PrayTreeDialog = class("PrayTreeDialog", require("app.views.base.BaseLayer"))

function PrayTreeDialog:create()
	local p = PrayTreeDialog:new()
	p:init()
	return p
end

local x, y
local size
function PrayTreeDialog:init()
	self._UI = require("Layer/ChineseValentineUI/PrayTreeDialogUI.lua").create() ['root']
	self._UI:addTo(self)
	
	Helper:convertUIByParent(self)
	self.Panel_UseConfirm:setVisible(true)
	x, y = self.Panel_desc.Text_name:getPosition()
	size = self.Panel_desc.Text_name:getContentSize()
	self.Panel_desc.Text_name:setVisible(false)
	self.Panel_UseConfirm.Button_Cancel:releaseFunc(function()
		PopupLayerController:hideLayer("PrayTreeDialog", function(layer)
			self:hide()
		end)
	end)
end



function PrayTreeDialog:setBtnConfirm(func)
	if type(func) ~= "function" then
		if PRINT_MODE == 1 then
			print("参数错误")
		end
		return
	end
	self.Panel_UseConfirm.Button_Confirm:releaseFunc(function()
		func()
		PopupLayerController:hideLayer("PrayTreeDialog", function(layer)
			self:hide()
		end)
	end)
end

function PrayTreeDialog:setTextName(text)
	self.Panel_desc:removeAllChildren()
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint(0.5, 0.5)
	richTextScroll:setTag(800)
	self.Panel_desc:addChild(richTextScroll)
	local pos = cc.p(x, y)
	richTextScroll:setPosition(pos)
	richTextScroll:setSize(size)
	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
	richTextScroll:getRichText():setVerticalSpace(5)
	richTextScroll:setBounceEnabled(true)
	local textColor = {r = 208, g = 208, b = 208}
	-- richTextScroll:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
	-- local name = "HIY" .. data.name .. "NOR"
	-- local str = "你确定要选择" .. name .. "进行题字么？"
	richTextScroll:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 60)
	
end



Helper:classDefNodeGetInstance(PrayTreeDialog)
return PrayTreeDialog 000000000