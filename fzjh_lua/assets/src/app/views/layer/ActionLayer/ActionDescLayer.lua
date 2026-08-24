

local ActionDescLayer = class("ActionDescLayer", cc.Layer)

function ActionDescLayer:create()
	local p = ActionDescLayer:new()
	p:init()
	return p
end

function ActionDescLayer:init()
	local UI = require("Layer/ActionUI/ActionDescUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUI(self)

	self:setButtonClose()
	self:setPanelBack()
end

function ActionDescLayer:show(action)
	if not action then
		PopupLayerController:hideLayer("ActionDescLayer")
		return
	end
	self:setVisible(true)
	self.Text_title:setString(action.name)
	self:setDesc(action)
end

function ActionDescLayer:hide()
	PopupLayerController:hideLayer("ActionDescLayer")
	self:setVisible(false)
end

function ActionDescLayer:setImageKuang()
	self.Image_kuang:releaseFunc(function()
			if PRINT_MODE == 1 then
				print("进入活动页面")
			end
		end)
end

function ActionDescLayer:setButtonClose()
	self.Button_close:releaseFunc(function()
			self:hide()
		end)
end

function ActionDescLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
			self:hide()
		end)
end

function ActionDescLayer:setDesc(action)
	if not MapIsEmpty(action.detail_desc) and action.detail_time ~= nil then
		local desc = "活动时间:\n" .. action.detail_time .. "\n活动内容:\n"

		local index = 1
		for k,v in pairs(action.detail_desc) do
			desc = desc .. v .. "\n"
			index = index + 1
		end
		-- self.Text_desc:setString(desc)
		local textColor = cc.c3b(255,255,255)
		self:initRichTextPreview("dsc",self.Text_desc,self,desc,textColor)
	else
		-- self.Text_desc:setString("")
		local textColor = cc.c3b(255,255,255)
		self:initRichTextPreview("dsc",self.Text_desc,self,"",textColor)
	end
end
function ActionDescLayer:initRichTextPreview(name,DscArea,parent,str,textColor,verticalSpace)
	local size = self.Text_desc:getContentSize()
	Helper:print_lua_table(size)
		local x, y = DscArea:getPosition()
	local size = DscArea:getContentSize()
	DscArea:setVisible(false)
	if parent[name] then
		parent[name]:removeFromParent()
		parent[name] = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	DscArea:getParent():addChild(richTextScroll)
   	local point = cc.p(DscArea:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	parent[name] = richTextScroll
   	parent[name]:setBounceEnabled(true)
   	parent[name]:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 48)
   	parent[name]:pushBackNewLine()
	parent[name]:pushBackNewLine(verticalSpace)
	parent[name]:setCascadeOpacity(0)
	parent[name]:setTouchEnabled(true)
	self:delayFunc(0.3,function ()
		parent[name]:jumpToTop()
		parent[name]:setCascadeOpacity(255)
	end)
end
Helper:classDefNodeGetInstance(ActionDescLayer)

return ActionDescLayer
00000