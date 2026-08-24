local PopConfirmLayer = class("PopConfirmLayer", cc.Layer)

function PopConfirmLayer:create()
	local p = PopConfirmLayer:new()
	p:init()
	return p
end

function PopConfirmLayer:init()
	self._UI = require("Layer/Dialog/Dialog13UI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	-- self:setCanelButtonNameAndCallFunc()
end
function PopConfirmLayer:showRefreshPannel()
	-- local layer = self:getInstence()
	self.Panel_refresh.Text_desc1:setVisible(false)
	self.Panel_refresh.Text_desc2:setVisible(false)
	self:show()
end

function PopConfirmLayer:closeRefreshPannel()	
	self:hide()
end
function PopConfirmLayer:setPromoted(str)
	local textColor = cc.c3b(159, 159, 159)
	str = Helper:getDef(str,"")
	self:initRichText(str,self.Panel_refresh.Text_104,textColor)
end
function PopConfirmLayer:setButtonNameAndCallFunc(name,func)
	name = Helper:getDef(name,"刷新")
	self.Panel_refresh.Button_refresh:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
	self.Panel_refresh.Button_refresh.Text_refresh:setString(name)
	self.Panel_refresh.Button_refresh:releaseFunc(function()
		if func then
			func()
		end
		self:closeRefreshPannel()
	end)
end

function PopConfirmLayer:setDesc1(desc,coler)
	desc = Helper:getDef(desc,"")
	self.Panel_refresh.Text_desc1:setVisible(true)
	local commands = Resource:getColorTb()
	if coler and commands[coler] then
		self.Panel_refresh.Text_desc1:setColor(commands[coler].color)
	end
	self.Panel_refresh.Text_desc1:setString(desc)
end
function PopConfirmLayer:setDesc2(desc,coler)
	desc = Helper:getDef(desc,"")
	local commands = Resource:getColorTb()
	if coler and commands[coler] then
		self.Panel_refresh.Text_desc2:setColor(commands[coler].color)
	end
	self.Panel_refresh.Text_desc2:setVisible(true)
	self.Panel_refresh.Text_desc2:setString(desc)
end
function PopConfirmLayer:setCanelButtonNameAndCallFunc(name,func)
	name = Helper:getDef(name,"取消")
	self.Panel_refresh.Button_close:setButtonType(WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON)
	self.Panel_refresh.Button_close.Text_close:setString(name)
	self.Panel_refresh.Button_close:releaseFunc(function()
		if func then
			func()
		end
		self:closeRefreshPannel()
	end)
end
function PopConfirmLayer:setDsc(str)
	str = Helper:getDef(str,"")
	local textColor = cc.c3b(159, 159, 159)
	self:initRichText(str,"Panel_refresh.Text_104",textColor)
end
function PopConfirmLayer:dealChildName(name)
	name = Helper:getDef(name,"")
	local child = nil
	name = string.split(name,".")
	for k,v in pairs(name) do
		if child == nil then
			child = self[v]
		else
			child = child[v]
		end
	end
	return child
end
function PopConfirmLayer:initRichText(str,name,textColor,verticalSpace)
	local DscArea = self:dealChildName(name)
	local x,y = DscArea:getPosition()
	local size = DscArea:getContentSize()
	DscArea:setVisible(false)
	local parent = DscArea:getParent()
	if parent[name.."text"] then
		parent[name.."text"]:removeFromParent()
		parent[name.."text"] = nil	
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
	parent:addChild(richTextScroll)
	richTextScroll:setPosition(x,y)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	parent[name.."text"] = richTextScroll
   	parent[name.."text"]:setBounceEnabled(false)
   	parent[name.."text"]:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 60)
   	parent[name.."text"]:pushBackNewLine()
	parent[name.."text"]:pushBackNewLine(verticalSpace)
	parent[name.."text"]:setCascadeOpacity(255)
	parent[name.."text"]:setAnchorPoint(0.5000, 0.5000)
	parent[name.."text"]:setTouchEnabled(false)
end
Helper:classDefNodeGetInstance(PopConfirmLayer)
return PopConfirmLayer 0000000