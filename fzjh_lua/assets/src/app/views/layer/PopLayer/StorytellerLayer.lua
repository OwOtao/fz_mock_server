-- add by ZhangShengTang 2017/06/17 15:05:36
-- 说书人界面
local StorytellerLayer = class("StorytellerLayer", LayerEx)

function StorytellerLayer:create()
	local p = StorytellerLayer:new()
	p:init()
	return p
end

function StorytellerLayer:init()
	self._UI = require("Layer/PopUI/StorytellerUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setButton()
end

function StorytellerLayer:showLayer(strList, succFunc)
	local str = ""
	local TextHeight = 0
	local hang = 0
	local panel = self.Panel_Text:clone()
	Helper:convertUIByParent(panel)

	self.succFunc = Helper:getDef(succFunc, function()end)

	for i,v in ipairs(strList) do
		panel.Text:setString(v)
		TextHeight = panel.Text:getAutoRenderSize().height + 10
		hang = hang + math.ceil(panel.Text:getAutoRenderSize().width / 864)+1
		str = str .. v.."\n\n"
	end

	panel.Text:setString(str)
	panel.Text:enableOutline({r = 17, g = 17, b = 17, a = 255}, 5)

	local height = 0
	height = (hang + 1) * TextHeight

	panel.Text:setString(str)
	panel:setSize(1080.00, height)
	panel.Text:setSize(864.00, height)
	panel.Text:setPosition(540.00, height / 2)
	if height>1920 then 
		self.Text_tishi:setVisible(true)
		self.Text_tishi:setString("上滑阅读全文")
	else
		self.Text_tishi:setVisible(false)
	end
	self.ListView_titlelistArea:pushBackCustomItem(panel)
	local currPos=self.ListView_titlelistArea:getInnerContainerPosition()

	self.ListView_titlelistArea:onScroll(function (event)
		if  event.name == "SCROLLING" then 
			if currPos.y~=self.ListView_titlelistArea:getInnerContainerPosition().y and self.isScroll ~= true then 
				self.Text_tishi:setVisible(false)
				self.isScroll= true
			end
		end
	end)
	self:show()
end

function StorytellerLayer:setButton()
	self.Button:releaseFunc(function()
		PopupLayerController:hideLayer("StorytellerLayer", function(layer)
			self:hide(function()
				self.succFunc()
			end)
		end, 0)
	end)
end

Helper:classDefNodeGetInstance(StorytellerLayer)

return StorytellerLayer0000000000