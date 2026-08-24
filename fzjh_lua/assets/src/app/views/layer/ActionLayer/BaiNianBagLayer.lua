local SpringFestival = require("app.models.SpringFestival.SpringFestival")

local BaiNianBagLayer = class("BaiNianBagLayer", LayerEx)

function BaiNianBagLayer:create()
	local p = BaiNianBagLayer:new()
	p:init()
	return p
end

function BaiNianBagLayer:init()
	local UI = require("Layer/ActionUI/BaiNianBagUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setVisible(false)

	self.npc = nil
	self.map = nil
	self.giftListRole = {}
	self.giftListNpc = {}

	self:setShowAndHideAnimType("ROLL")

	self:setButton()
end

function BaiNianBagLayer:showLayer(npc, map)
	if SpringFestival:getBaiNianActivityState() == 1 then
		self.map = map
		self:setNpc(npc)
		self:setRoleGiftList()
		self:showGiftList()
		self:show()
	else
		PopText("活动未开启")
	end
end

function BaiNianBagLayer:setNpc(npc)
	self.npc = npc
	self.Image_title.Text_title2:setString(npc.name)
end

-- 设置角色身上已拥有的礼物
function BaiNianBagLayer:setRoleGiftList()
	self.giftListRole = {}
	self.giftListNpc = {}

	local role = User:getRole()
	local items = role:getAttr("items")

	for k,v in pairs(items) do
		local item = Item:getOneItemByKey(v.itemId)
		if item.type == "礼物" then
			table.insert(self.giftListRole, {itemId = v.itemId, count = v.count})
		end
	end
end

function BaiNianBagLayer:setButton()
	-- 确定
	self.Button_confirm:releaseFunc(function()
		local SpringFestival = require("app.models.SpringFestival.SpringFestival")
		if SpringFestival:getBaiNianActivityState() == 1 then
			local role = User:getRole()
			local weight = role:getAttr("weight")
			local items = role:getAttr("items")

			if MapIsEmpty(self.giftListNpc) then
				PopText("请选择要送的礼物")
				return
			end

			if weight - #items < 1 then
				PopText("背包剩余空间不足")
				return
			end

			local itemId = self.giftListNpc[1].itemId
			SpringFestival:doFreeBaiNian(itemId, self.npc, self.map)
		else
			PopText("活动未开启")
		end
		self:hide()
		self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
	end)

	-- 取消
	self.Button_cancel:releaseFunc(function()
		self:hide()
		self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
	end)
end

-- 显示列表， 只显示礼物物品
function BaiNianBagLayer:showGiftList()
	self.ListView_1:removeAllItems()
	self.ListView_2:removeAllItems()

	for k,v in pairs(self.giftListRole) do
		local item = Item:getOneItemByKey(v.itemId)
		if item.type == "礼物" and v.count > 0 then
			local row = self:createRoleItem(v, item)
			self.ListView_1:pushBackCustomItem(row)
		end
	end

	for k,v in pairs(self.giftListNpc) do
		local item = Item:getOneItemByKey(v.itemId)
		if item.type == "礼物" then
			local row = self:createNpcItem(v, item)
			self.ListView_2:pushBackCustomItem(row)
		end
	end
end

function BaiNianBagLayer:createRoleItem(bagItem, itemData)
	local row = self.Panel_item1:clone()
	Helper:convertUI(row)

	row:setVisible(true)
	-- if itemData.id == User:getRole().shenBingweapon.id then
	-- 	row.Text_name:setString(tostring(itemData.name))
	-- else
		row.Text_name:setString( tostring(itemData.name) .. " X " .. tostring(bagItem.count) )
	-- end

	row:releaseFunc( function()
		if MapIsEmpty(self.giftListNpc) then
			bagItem.count = bagItem.count - 1
			table.insert(self.giftListNpc, {itemId = bagItem.itemId, count = 1})

			-- 刷新列表
			self:showGiftList()
		else
			PopText("只能送一个礼物")
		end
	end)
	return row
end

function BaiNianBagLayer:createNpcItem(bagItem, itemData)
	local row = self.Panel_item2:clone()
	Helper:convertUI(row)

	row:setVisible(true)

	--显示名字
	row.Text_name:setString( tostring(itemData.name) )

	row.Text_num:setString(" X " .. tostring(bagItem.count))

	row:releaseFunc(function()
		self:setRoleGiftList()

		-- 刷新列表
		self:showGiftList()
		end)

	return row
end

Helper:classDefNodeGetInstance(BaiNianBagLayer)

return BaiNianBagLayer000