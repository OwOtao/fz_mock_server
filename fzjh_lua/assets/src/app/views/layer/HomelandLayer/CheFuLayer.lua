local Item = require("app.models.item.Item")
local Resource = require("app.Resource")
local CheFuLayer = class("CheFuLayer", cc.Layer)
local List_view = {}
local roleItems = {} --玩家临时背包

--从itemlist中移除一个itemId==id的item,要考虑数量
local function removeItemById(itemlist, id)
	for i, v in ipairs(itemlist) do		
		if v.itemId == id then
			v.count = v.count - 1			
			if v.count <= 0 then
				table.remove(itemlist, i)
			end
			return true
		end
	end
	return false
end

function CheFuLayer:create()
	local p = CheFuLayer:new()
	p:init()
	return p
end

function CheFuLayer:init()
	self._UI = require("Layer/MapUI/MapBagUI.lua").create() ['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)
	
end

function CheFuLayer:show()
	self:setVisible(true)
end

function CheFuLayer:hide()
	self:setVisible(false)
end


-- 设置角色,参数1是玩家角色
function CheFuLayer:setRoles(role)
	if not role then
		assert(nil, "CheFuLayer:setRoles(role) -> 角色1不存在")
	end
		
	self.role = role
		
	--为玩家临时背包填充数据
	roleItems = clone(role:getItems())	
	self.Image_title.Text_title2:setString("车夫")
	self.Panel_item2.Text_num:setVisible(false)

	-- 能卖出售物品给NPC
	--self.npcCanSale = true
	
	--把玩家背包的数据填充到ui
	self:setBagList1(roleItems)
	
	-- 刷新玩家临时背包容量
	self:refreshWeightUI()
	
	-- 文本隐藏
	self.Text_desc:setVisible(false)
	
	-- 按钮初始化
	self:initButtons()
end

-- 自己的背包
function CheFuLayer:setBagList1(list)
	if not list then
		return
	end
	for i, v in ipairs(list) do
		local row
		if v.count > 0 then
			local item = Item:getOneItemByKey(v.itemId)
			
			if not item then
				if DEBUG_MODE == 1 then
					print("====================================================================================没有该物品",v.itemId)
					assert(nil, "CheFuLayer:createItem1(mapValue) -> 没有该物品" .. v.itemId)
				end
			end
			local widget = self.ListView_1:getItem(i - 1)
			row = self:createItem1(v, item, widget)
			if widget == nil then
				self.ListView_1:pushBackCustomItem(row)
			end
		end
	end

	for i = #list + 1, #self.ListView_1:getItems() do
		self.ListView_1:removeLastItem()
	end
end

-- 对方的背包
function CheFuLayer:setBagList2(list)
	if not list then
		return
	end
	
	-- self.ListView_2:removeAllItems()
	for i, v in ipairs(list) do
		local row
		print("------------------------------------------------------------")
		Helper:print_lua_table(v)
		if v.count > 0 then
			local item = Item:getOneItemByKey(v.itemId)
			if not item then
				if DEBUG_MODE == 1 then
					assert(nil, "CheFuLayer:createItem2(mapValue) -> 没有该物品" .. v.itemId)
				end
			end
			local widget = self.ListView_2:getItem(i - 1)
			row = self:createItem2(v, item, widget)
			
			if widget == nil then
				self.ListView_2:pushBackCustomItem(row)
			end
		end
	end

	for i = #list + 1, #self.ListView_2:getItems() do
		self.ListView_2:removeLastItem()
	end

end

-- 自己背包的栏目
function CheFuLayer:createItem1(bagItem, itemData, widget)
	
	local row = widget
	if row == nil then
		row = self.Panel_item1:clone()
		Helper:convertUI(row)
	end
	row:setVisible(true)
	row.Text_name:setString(tostring(itemData.name) .. " X " .. tostring(bagItem.count))
	local outlineColor = cc.c4b(24, 24, 24, 255)
	local outlineWidth = 5
	row.Text_name:enableOutline(outlineColor, outlineWidth)
	local role = User:getRole()
	-- 点击处理
	row:releaseFunc(function()
		-- 当前选中栏目
		if itemData.type  == "邀请函" then
			if #self.ListView_2:getItems() == 0 then				
				local list2 = {[1] = bagItem}
				for i,v in ipairs(roleItems) do
					if v.itemId == itemData.id then
						table.remove(roleItems,i)
					end
				end
				self:setBagList1(roleItems)
				self:setBagList2(list2)
				self:refreshWeightUI()
				self:setButton2("确定",itemData)				
			else
				PopText("只能放一个邀请函")
			end
		else
			PopText("车夫只接受邀请函")
		end
		-- 列表及金钱的刷新
		self:refreshWeightUI()
		
	end)
	return row
end

-- 对方背包的栏目
function CheFuLayer:createItem2(bagItem, itemData, widget)
	
	local row = widget
	if row == nil then
		
		row = self.Panel_item2:clone()
		Helper:convertUI(row)
	end
	row:setVisible(true)
	--显示名字
	row.Text_name:setString(tostring(itemData.name))
	local outlineColor = cc.c4b(24, 24, 24, 255)
	local outlineWidth = 5
	row.Text_name:enableOutline(outlineColor, outlineWidth)
	row:releaseFunc(function()
		local role = User:getRole()		
		self:setBagList1(role:getItems())
		self.ListView_2:removeAllItems()
	end)
	return row
end

--按钮初始化
function CheFuLayer:initButtons()
	local button1 = self:createButton() --关闭按钮
	local button2 = self:createButton()
	self:addChild(button1)
	self:addChild(button2)
	button1:move(cc.p(270, 200))
	button2:move(cc.p(810, 200))
	self.Button_1 = button1
	self.Button_2 = button2
	self:setButton1("取消")
	self:setButton2("确定")
end

function CheFuLayer:createButton()
	local roleButton = Resource:getUIByName("Button_4")
	Helper:convertUI(roleButton)
	roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return roleButton
end

function CheFuLayer:setButton1(name)
	self.Button_1.Text_buttonName:setString(name)
	self.Button_1:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self:hide()
		self.ListView_2:removeLastItem()
	end)
end

function CheFuLayer:setButton2(name,itemData)
	
	local jumpToMap = function (toMap)
		toMap._isComingIn = true
		toMap.toMapId = itemData.toMapId
		
		
		toMap:setCallBackAndConnect(function ()
			local mapLayer = MainControllLayer:getLayer("MapLayer")
			-- map:setMapForTask()	--主动任务，地图调整
			mapLayer:setMap(toMap)
			FubenClient:comeIn(toMap.id, mapLayer._currRoom.id, toMap:getRoomNameById(mapLayer._currRoom.id), Helper:getOnlyId())
	
		end)
	end


	self.Button_2.Text_buttonName:setString(name)
	self.Button_2:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")		
		--@RefType [app.models.role.Role#Role]
		local role = User:getRole()
		if #self.ListView_2:getItems() ~= 0 then
			local UserMap = require("app.models.map.UserMap")
			UserMap:getUserMap(itemData.mid,tonumber(itemData.from_id),function(map,isSuccess)
				if isSuccess == false then
                    return
                end

				RichPrint("main", "HIC你进入大车，对车夫吆喝了几句。")
				RichPrint("main", "HIC车夫扬起手中鞭，吆喝道：看车！去"..tostring(map.name).."了。")
	
				local entryMapLayer = MainControllLayer:getLayer("EntryMapLayer")
				entryMapLayer:maxZ()
				entryMapLayer:show()
				
				local titleLayer = MainControllLayer:getLayer("TitleLayer")
				local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
				mapRoleLayer:onResume()
				titleLayer:hide(true)

				
				self:delayFunc(1,
				function()
					--@RefType [app.models.map.BaseMap#BaseMap]
					local currMap = role:getCurrMap()

					local mapLayer = MainControllLayer:getLayer("MapLayer")

					local currMapState = currMap:getCurrConnectStatus()

					jumpToMap(map)
					entryMapLayer:hide(function()
						RichPrint("main", "HIC你身形一转，跃下马来，姿势十分优美。")
					end) -- 隐藏界面
					MainControllLayer:removeLayer("EntryMapLayer")						
					MainControllLayer:pushLayer("MapLayer")
					
                    MessageCenter:notify("EnterMap",{map=map})
				end)

			end)
			self:hide()
			self.ListView_2:removeLastItem()
		else
			PopText("请把邀请函给车夫")
		end		
	end)
end

-- 当前值的计数在list的重新渲染中统计
function CheFuLayer:refreshWeightUI()
	self.Text_weight:setString((#roleItems) .. "/" .. User:getRoleAttr("weight"))
end

Helper:classDefNodeGetInstance(CheFuLayer)

return CheFuLayer 000