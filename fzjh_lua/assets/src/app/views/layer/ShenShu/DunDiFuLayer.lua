local DunDiFuLayer = class("DunDiFuLayer", LayerEx)
local ControllLayer = require("app.views.layer.ControllLayer")
local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
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
			local item = Item:getOneItemByKey("dundifu")
			if not item then
				return
			end
			local role = User:getRole()
			local item_count = role:getItemCount("dundifu")
			local skill = role:getSkill("wuxingdunfa")
			-- if item_count >= 1 and MapIsEmpty(skill) == false then
				local dialog = DialogALayer:getInstance()
				dialog:show("选择前往"..showStr.."的方式。\n（选择遁地方式前往，会偶然出现意想不到的结果，请谨慎使用。）")
				dialog:setBack(false)
				dialog:setWeChatVisible(false)
				dialog:setButton1("自行前往", function()
					local jump_to_map_select = function()
						local mapIndex = Map:getMapIndexById(book.mapId)
						if MainControllLayer:getCurrLayer()=="MapLayer" then 
							local mapLayer = MainControllLayer:getLayer("MapLayer")
							mapLayer:quit()
							mapLayer:setVisible(false)
						end
						self:setVisible(false)
						MainControllLayer:pushLayer("SelectMapLayer")
						local selectMapLayer = MainControllLayer:getLayer("SelectMapLayer")
						selectMapLayer:setMap(book.mapId)
					end

					local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
					if RoleTaskControllor:clickMapLayer(role, jump_to_map_select) == false then
						return
					else
						jump_to_map_select()
					end
				end)
				dialog:setButton2("用遁地符", function()
					self:setVisible(false)
					item:useDunDiFu(role, book.mapId, book.randomRoom,EMPTY_FUNC,SKILL_ITEM_DUNDIFU_TYPE)
				end)
				if MapIsEmpty(skill) == false then
					dialog:setButton3("五行遁法", function()
						item:useDunDiFu(role, book.mapId, book.randomRoom, function(useResult)
							if useResult == false then 
								dialog:setVisible(true)
							else
								self:setVisible(false)
							end
						end,SKILL_ITEM_TYPE)
					end)
				end
			-- elseif MapIsEmpty(skill) == false then
			-- 	--@desc 直接使用五行遁法
			-- 	item:useDunDiFu(role, book.mapId, book.randomRoom, function (useResult)
			-- 		if useResult == false then 
			-- 		else
			-- 			self:setVisible(false)
			-- 		end
			-- 	end,SKILL_ITEM_TYPE)
			-- else
			-- 	self:setVisible(false)
			-- 	item:useDunDiFu(role, book.mapId, book.randomRoom,EMPTY_FUNC,SKILL_ITEM_DUNDIFU_TYPE,true)
			-- end
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
		local item = Item:getOneItemByKey("dundifu")
		if not item then
			return
		end
		local role = User:getRole()
		local map  = Map:getMapById(list.mapId)
		local room 
		for k,v in pairs(map["room"]) do 
			if v.id == list.roomId then
				room = v
			end
		end

		local showStr="HIY"..map.name..room.name.."NOR"
		local item_count = role:getItemCount("dundifu")
		local skill = role:getSkill("wuxingdunfa")
			local dialog = DialogALayer:getInstance()
			dialog:show("选择前往"..showStr.."的方式。\n（选择遁地方式前往，会偶然出现意想不到的结果，请谨慎使用。）")
			dialog:setBack(false)
			dialog:setWeChatVisible(false)
			dialog:setButton1("自行前往", function()
				local jump_to_map_select = function()
					if MainControllLayer:getCurrLayer() == "MapLayer" then
						local mapLayer = MainControllLayer:getLayer("MapLayer")
						mapLayer:quit()
						mapLayer:setVisible(false)
					end
					self:setVisible(false)
					MainControllLayer:pushLayer("SelectMapLayer")
					local selectMapLayer = MainControllLayer:getLayer("SelectMapLayer")
					selectMapLayer:setMap(list.mapId)
				end
				local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")
				if RoleTaskControllor:clickMapLayer(role, jump_to_map_select) == false then
					return
				else
					jump_to_map_select()
				end
			end)
			dialog:setButton2("用遁地符", function()
				self:setVisible(false)
				item:useDunDiFu(role, list.mapId, list.roomId,EMPTY_FUNC,SKILL_ITEM_DUNDIFU_TYPE)
			end)
			if MapIsEmpty(skill) == false then
				dialog:setButton3("五行遁法", function()
					item:useDunDiFu(role, list.mapId, list.roomId, function(useResult)
						if useResult == false then 
							dialog:setVisible(true)
						else
							self:setVisible(false)
						end
					end,SKILL_ITEM_TYPE)
				end)
			end
	end)
end
Helper:classDefNodeGetInstance(DunDiFuLayer)
return DunDiFuLayer000000