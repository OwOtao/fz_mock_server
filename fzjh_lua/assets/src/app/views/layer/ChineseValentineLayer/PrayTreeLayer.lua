local PrayTreeLayer = class("PrayTreeLayer", require("app.views.layer.MapLayer.MapBagLayer"))


-- local data = require("app.views.layer.ChineseValentineLayer.QifuData.lua")
local CVModel = require("app.models.Action.ChineseValentine.CVModel")

local prayMap = CVModel:getPrayItemMap()
local qifudata = CVModel:getPrayData()

function PrayTreeLayer:create()
	local p = PrayTreeLayer:new()
	p:init()
	return p
end


function PrayTreeLayer:setRoles(role1, role2, func)
	self:initAll()
	for _, v in pairs(role1.items) do
		local s = string.sub(v.itemId, 1, 8)
		if s == "qixiqifu" then
			table.insert(self._playerItems, v)
		end
	end
	self:show()
	self:setBagList(self._playerItems)
	self:setTreeList(self._treeItems)
end

function PrayTreeLayer:initAll()
	-- self.roleMoney = 0 -- 当前货币 数量
	self._playerItems = {} -- 玩家临时背包
	self._treeItems = {} -- 祈福树临时背包
	self.Image_title.Text_title2:setString("祈福树")
	
	-- 按钮初始化
	self:setButtons()
	
	self.Text_desc1:setVisible(false)
	self.Text_weight:setVisible(false)
end

--My bag list
function PrayTreeLayer:setBagList(list)
	if not list then
		return
	end
	
	-- self.ListView_1:removeAllItems()
	local index = 0
	for _, v in pairs(list) do
		local row
		-- local item = Item:getOneItemByKey(v.itemId)
		local item = qifudata[v.itemId]
		if not item then
			assert(nil, "PrayTreeLayer:setBagList(list) -> 没有该物品" .. v.itemId)			
		end
		local widget = self.ListView_1:getItem(index)
		row = self:createItem1(v, item, widget)
		if widget == nil then
			self.ListView_1:pushBackCustomItem(row)
		end
		index = index + 1
	end
	for i = index + 1, #self.ListView_1:getItems() do
		self.ListView_1:removeLastItem()
	end
	self.ListView_1:jumpToTop()
end

--Tree bag list
function PrayTreeLayer:setTreeList(list)
	if not list then
		return
	end
	
	-- self.ListView_2:removeAllItems()
	local index = 0
	for _, v in pairs(list) do
		local row
		local item = qifudata[v.itemId]
		if not item then
			assert(nil, "PrayTreeLayer:setTreeList(list) -> 没有该物品" .. v.itemId)			
		end
		local widget = self.ListView_2:getItem(index)
		row = self:createItem2(v, item, widget)
		if widget == nil then
			self.ListView_2:pushBackCustomItem(row)
		end
		index = index + 1
	end
	
	for i = index + 1, #self.ListView_2:getItems() do
		self.ListView_2:removeLastItem()
	end
	self.ListView_2:jumpToTop()
end

--My bag Item
function PrayTreeLayer:createItem1(prayItem, itemData, widget)
	local row = widget
	if row == nil then
		row = self.Panel_item1:clone()
		Helper:convertUI(row)
	end
	
	row:setVisible(true)	
	row.Text_name:setString(tostring(itemData.name))
	local outlineColor = cc.c4b(24, 24, 24, 255)
	local outlineWidth = 5
	row.Text_name:enableOutline(outlineColor, outlineWidth)
	
	row:releaseFunc(function()
		-- -- 当前选中栏目
		local index = self.ListView_1:getCurSelectedIndex() + 1
		self._click = index
		if MapIsEmpty(self._treeItems) then
			table.remove(self._playerItems, index)
			table.insert(self._treeItems, prayItem)
			self:setBagList(self._playerItems)
			self:setTreeList(self._treeItems)
		else
			PopText("一次只能祈求一个愿望")
		end
		
	end)
	
	return row
end

--Tree bag Item
function PrayTreeLayer:createItem2(prayItem, itemData, widget)
	local row = widget
	if row == nil then
		row = self.Panel_item2:clone()
		Helper:convertUI(row)
	end
	row:setVisible(true)	
	row.Text_name:setString(tostring(itemData.name))
	local outlineColor = cc.c4b(24, 24, 24, 255)
	local outlineWidth = 5
	row.Text_name:enableOutline(outlineColor, outlineWidth)
	row.Text_num:setVisible(false)
	row.Text_name:setPosition(185, 85)
	
	row:releaseFunc(function()
		local index = self.ListView_2:getCurSelectedIndex()
		self.ListView_2:removeItem(index)
		table.remove(self._treeItems, index + 1)
		table.insert(self._playerItems, self._click, prayItem)
		self:setBagList(self._playerItems)
		self:setTreeList(self._treeItems)
	end)
	return row
end


function PrayTreeLayer:setButtons()
	self:setButton1("取消", function()
		Audio:playEffect("fanHuiQuXiao ")
		self:hide()
	end)
	self:setButton2("祈福", function()
		-- self:connectToUserData()
		Audio:playEffect("xiaoAnNiu")
		if MapIsEmpty(self._treeItems) then
			PopText("请选择祈福的物品")
		else
			local itemAttr = require("app.models.Action.ChineseValentine.CVModel").getPrayData() [self._treeItems[1].itemId]
			local wish_val = itemAttr.value
			local wish_type = itemAttr.type
			local wish_id = self._treeItems[1].itemId
			local item = Item:getOneItemByKey(self._treeItems[1].itemId)
			
			PopupLayerController:showLayer("PrayTreeDialog", function(layer)
				layer:setTextName("你确定要选择" .. "HIY" .. item.name .. "NOR" .. "进行祈福么？")
				layer:show()
				layer:setBtnConfirm(function()
					local role = User:getRole()
					HttpManagerEx:uploadWishData(wish_val, wish_type, wish_id, function(status, errcode, errmsg, data)
						if status == 200 and errcode == 0 then			
							-- local openMark = Helper:getDef(data.open_mark,"")
							-- local prayRoomId = Helper:getDef(data.room_id,"")
							-- role:setAttr("openMark", openMark)
							-- role:setAttr("prayRoomId",prayRoomId)
							--解决交互数据刷新不及时的情况
							-- FubenClient:setValue("prayRoomId",prayRoomId)
							
							local itemName = item:getNcname(item.name)
							if tonumber(data.total_wish) == 7 then
								RichPrint("main", "CYN你将" .. itemName .. "挂上祈福树，双手合十，诚心祈祷，待到睁开双眼，不远处的元苦大师招你招了招手，似乎示意你过去。")
							else
								RichPrint("main", "CYN你将" .. itemName .. "挂上祈福树，双手合十，诚心祈祷，希望你的祈求能够成真。")
							end
						
							local pot = role:getAttr("pot")
							local prize_pot = switch(itemAttr.tape, {
								["qixiqiyuan1"] = function()
									return 10000
								end,
								["qixiqiyuan2"] = function()
									return 15000
								end,
								["qixiqiyuan3"] = function()
									return 20000
								end
							})
							role:setAttr("pot", pot + prize_pot)
							role:setAttr("yueli", role:getAttr("yueli") + 30)
							self:hide()
							RichPrint("main","潜能 +"..prize_pot)
							RichPrint("main","阅历 + 30")
							PopText("潜能 +" .. prize_pot)
							PopText("阅历 + 30")
							role:addItemCount(self._treeItems[1].itemId, - 1)
						elseif errcode == 1 then
							PopText(errmsg)
						end
					end)
				end)
			end)
		end
	end)
end

function PrayTreeLayer:initButtons()
local button1 = self:createButton() --关闭按钮
local button2 = self:createButton() --祈福按钮
self:addChild(button1)
self:addChild(button2)
button1:move(cc.p(270, 130))
button2:move(cc.p(810, 130))
self.Button_1 = button1
self.Button_2 = button2
end

function PrayTreeLayer:setButton1(name, func)
if not name then
	self.Button_1:setVisible(false)
	return
else
	self.Button_1:setVisible(true)
end
self.Button_1.Text_buttonName:setString(name)
self.Button_1:releaseFunc(function()
	if func then
		func()
	end
end)
end

Helper:classDefNodeGetInstance(PrayTreeLayer)
return PrayTreeLayer 000000