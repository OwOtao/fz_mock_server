local DunDiFuLayer = class("DunDiFuLayer", LayerEx)
local ControllLayer = require("app.views.layer.ControllLayer")

function DunDiFuLayer:create()
	local p = DunDiFuLayer:new()
	p:init()
	return p
end
function DunDiFuLayer:init()
	local UI = require("Layer/Dialog/Dialog3UI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self) -- 获得所有子节点
end
function DunDiFuLayer:initLayer(tag,book,func)
	local layer = self:getInstance()
	layer:show()
	if tag then
		layer:showXunBaolayer(book,func)
	else
		layer:showlayer(book,func)
	end
end
function DunDiFuLayer:showlayer(book)
	self.Button_1:setVisible(true)
	self.Button_1.Text_name:setString("前往")
	self.Button_2:setVisible(true)
	self.Button_2.Text_name:setString("取消")
	self.Button_3:setVisible(false)
	self.Button_4:setVisible(false)
	self.Panel_title.Text_title:setString("神书任务")
	self.Image_kuang.Panel_state:setVisible(false)
	self.Text_desc3:setVisible(false)
	self.Text_desc2:setVisible(false)
	self.Image_kuang.Panel_row:setVisible(false)
	self.Button_2:releaseFunc(function()
		PopupLayerController:hideLayer("DunDiFuLayer", function(layer)
			self:hide()
		end)
	end)
	local role = User:getRole()
		local map  = Map:getMapById(book.mapId)
		local room 
		for k,v in pairs(map["room"]) do 
			if v.id == book.randomRoom then
				room = v
			end
		end
		local str--randomType
		local showStr
		if book.randomType == 1 then
			str = "根据灵石所示，神书出现在HIY"..map.name..room.name.."NOR附近，可使用遁地符飞往该处。"
			showStr="HIY"..map.name..room.name.."NOR"
		elseif book.randomType == 2 then
			str = "根据灵石所示，神书出现在HIY"..room.name.."NOR附近，可使用遁地符飞往该处。"
			showStr="HIY"..room.name.."NOR"
		else
			str = "根据灵石所示，神书出现在HIY"..map.name.."NOR附近，可使用遁地符飞往该处。"
			showStr="HIY"..map.name.."NOR"
		end
		self:createRichText(str)
		self.Button_1:releaseFunc(function()
			local text = "选择前往"..showStr.."的方式。\n（选择遁地方式前往，会偶然出现意想不到的结果，请谨慎使用。）"
			local backClick = false
			local callfunc = function(result, failureState)
				if result == true then
					self:setVisible(false)
				end
			end

			local JumpMapStylePrensenter = require("app.presenters.JumpMapStyle.JumpMapStylePrensenter"):create()
			JumpMapStylePrensenter:showLayer(User:getRole(), book.mapId, book.randomRoom, text, backClick, callfunc)
		end)

end
function DunDiFuLayer:createRichText(str)
	local x, y = self.Image_kuang:getPosition()
	local size = self.Image_kuang:getContentSize()
	size.height = size.height -100
	size.width = size.width -100
	if self.RichText_Print then
		self.RichText_Print:removeFromParent()
		self.RichText_Print = nil
	end
	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Image_kuang:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Image_kuang:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_Print = richTextScroll
   	self.RichText_Print:setTouchEnabled(false)
	
	self.RichText_Print:pushBackText(str, cc.c3b(159,159,159), 255, Resource:getFontPath("default"), 42)
end
function DunDiFuLayer:showXunBaolayer(list,func)
	self.Button_1:setVisible(true)
	self.Button_1.Text_name:setString("前往")
	self.Button_2:setVisible(true)
	self.Button_2.Text_name:setString("取消")
	self.Button_3:setVisible(false)
	self.Button_4:setVisible(false)
	self.Panel_title.Text_title:setString(list.title)
	self.Image_kuang.Panel_state:setVisible(false)
	self.Text_desc3:setVisible(false)
	self.Text_desc2:setVisible(false)
	self.Image_kuang.Panel_row:setVisible(false)
	self.Button_2:releaseFunc(function()
		PopupLayerController:showLayer("DunDiFuLayer", function(layer)
			self:hide()
		end)
	end)
	self:createRichText(list.str)
	self.Button_1:releaseFunc(function()
		local role = User:getRole()
		local map = Map:getMapById(list.mapId)
		local room 
		for k,v in pairs(map["room"]) do 
			if v.id == list.roomId then
				room = v
			end
		end

		local text = "选择前往HIY"..map.name..room.name.."NOR的方式。\n（选择遁地方式前往，会偶然出现意想不到的结果，请谨慎使用。）"
		local backClick = false
		local callfunc = function(result, failureState)
			if result == true then
				self:setVisible(false)
			end
		end

		local JumpMapStylePrensenter = require("app.presenters.JumpMapStyle.JumpMapStylePrensenter"):create()
        JumpMapStylePrensenter:showLayer(User:getRole(), list.mapId, list.roomId, text, backClick, callfunc)
	end)

end
Helper:classDefNodeGetInstance(DunDiFuLayer)
return DunDiFuLayer000000000000