local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

local MingBiRecycleLayer = class("MingBiRecycleLayer", require("app.views.layer.MapLayer.MapBagLayer"))
--[[
	冥币回收交易界面,继承自副本交易界面
]]


--工具函数，查询arr中是否包含id
local IsIdInTable = function( id , arr )
	for i,v in ipairs( arr ) do
		if v == id then
			return true
		end
	end
	return false
end

--从itemlist中移除一个itemId==id的item,要考虑数量
local function removeItemById( itemlist , id )
	for i,v in ipairs( itemlist ) do

		if v.itemId == id then
			v.count = v.count - 1

			if v.count <= 0 then
				table.remove( itemlist , i )
			end
			return true
		end
	end
	return false
end

--从itemlist中添加一个itemId==id的item,要考虑数量
local function addItemById( itemlist , id)
	-- for i,v in ipairs( itemlist ) do

	-- 	if v.itemId == id then
	-- 		v.count = v.count + 1
	-- 		return
	-- 	end
	-- end

	--没找到则要添加一项新的
	local itemAttr = Item:getOneItemByKey( id )
	if not itemAttr then
		assert(nil, "MingBiRecycleLayer:createItem2(mapValue) -> 没有该物品".. id)
		return
	end

	table.insert( itemlist , { id = User:getRole():getItemOnlyId() , count = 1 , itemId = id , name = itemAttr.name} )
end

local CNtab = {
	["mingbi"] = "亿冥币",
	["default"] = "亿冥币"
}
local function currencyToCN(currency)
	return switch(currency, CNtab)
end

function MingBiRecycleLayer:create()
    local p = MingBiRecycleLayer:new()
    p:init()
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 10:19:36
-- @desc 初始化所有数据 (每次进入交易界面的时候初始化)
function MingBiRecycleLayer:initAll()
	self.Text_money:setVisible(false)

	self.currency = "mingbi" -- 货币 默认是冥币
	self.roleMoney = 0 -- 当前货币 数量
	self.playerItems = {} -- 玩家临时背包

	self._callBackFunc = nil -- 最终回调函数
	-- 按钮初始化
	self:setButtons()
	-- self:refreshMoney()
	self:show()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/07 09:24:54
-- @desc 初始化角色物品列表
local bagItems = {
	item201_08 = 10,
	qingmingzhuangbei1 = 3200,
	qingmingzhuangbei2 = 3200,
	qingmingzhuangbei3 = 3200,
	qingmingzhuangbei4 = 3200,
	qingmingzhuangbei5 = 2800,
	qingmingzhuangbei6 = 2800,
	qingmingzhuangbei7 = 2800,
	qingmingzhuangbei8 = 2800,
	qingmingzhuangbei9 = 2800,
	qingmingzhuangbei10 = 2800,
	qingmingzhuangbei11 = 2800,
	qingmingzhuangbei12 = 2800,
	qingmingzhuangbei13 = 3600,
	qingmingzhuangbei14 = 3200,
	qingmingzhuangbei15 = 3200,
	qingmingzhuangbei16 = 3200,
	qingmingzhuangbei20 = 3200,
	jingxinwan = 100,
	qiannengdan = 200,
	tianxiangyulu1 = 180,
	jiu106 = 600,
	qingmingzhuanyong1 = 12000,
	shengongguifu1 = 20000,
	heishasishijiuzhua1 = 20000,
	hanbingguizhua1 = 20000,
	kusangbangfa1 = 20000,
	jiangshibufa1 = 20000,
	qishadaofa1 = 18000,
}

local mianjuItems = {
	mianju1021 = 2000,
	mianju1022 = 2700,
	mianju1036 = 5000,
	mianju1038 = 5000,
}

local canYeItems = {
	shuye102 = 3600,
	shuye103 = 3600,
	shuye104 = 3600,
	shuye105 = 3600,
	shuye106 = 3600,
	jiangshibufa2 = 5000,
	jiangshibufa3 = 5000,
	jiangshibufa4 = 5000,
	jiangshibufa5 = 5000,
	kusangbangfa2 = 5000,
	kusangbangfa3 = 5000,
	kusangbangfa4 = 5000,
	kusangbangfa5 = 5000,
	hanbingguizhua2 = 5000,
	hanbingguizhua3 = 5000,
	hanbingguizhua4 = 5000,
	hanbingguizhua5 = 5000,
	heishasishijiuzhua2 = 5000,
	heishasishijiuzhua3 = 5000,
	heishasishijiuzhua4 = 5000,
	heishasishijiuzhua5 = 5000,
	shengongguifu2 = 6666,
	shengongguifu3 = 6667,
	shengongguifu4 = 6667,
}

local items = {
	item201_08 = 10,
	qingmingzhuangbei1 = 3200,
	qingmingzhuangbei2 = 3200,
	qingmingzhuangbei3 = 3200,
	qingmingzhuangbei4 = 3200,
	qingmingzhuangbei5 = 2800,
	qingmingzhuangbei6 = 2800,
	qingmingzhuangbei7 = 2800,
	qingmingzhuangbei8 = 2800,
	qingmingzhuangbei9 = 2800,
	qingmingzhuangbei10 = 2800,
	qingmingzhuangbei11 = 2800,
	qingmingzhuangbei12 = 2800,
	qingmingzhuangbei13 = 3600,
	qingmingzhuangbei14 = 3200,
	qingmingzhuangbei15 = 3200,
	qingmingzhuangbei16 = 3200,
	qingmingzhuangbei20 = 3200,
	jingxinwan = 100,
	qiannengdan = 200,
	tianxiangyulu1 = 180,
	jiu106 = 600,
	qingmingzhuanyong1 = 12000,
	shengongguifu1 = 20000,
	heishasishijiuzhua1 = 20000,
	hanbingguizhua1 = 20000,
	kusangbangfa1 = 20000,
	jiangshibufa1 = 20000,
	qishadaofa1 = 18000,
	mianju1021 = 2000,
	mianju1022 = 2700,
	mianju1036 = 5000,
	mianju1038 = 5000,
	shuye102 = 3600,
	shuye103 = 3600,
	shuye104 = 3600,
	shuye105 = 3600,
	shuye106 = 3600,
	jiangshibufa2 = 5000,
	jiangshibufa3 = 5000,
	jiangshibufa4 = 5000,
	jiangshibufa5 = 5000,
	kusangbangfa2 = 5000,
	kusangbangfa3 = 5000,
	kusangbangfa4 = 5000,
	kusangbangfa5 = 5000,
	hanbingguizhua2 = 5000,
	hanbingguizhua3 = 5000,
	hanbingguizhua4 = 5000,
	hanbingguizhua5 = 5000,
	heishasishijiuzhua2 = 5000,
	heishasishijiuzhua3 = 5000,
	heishasishijiuzhua4 = 5000,
	heishasishijiuzhua5 = 5000,
	shengongguifu2 = 6666,
	shengongguifu3 = 6667,
	shengongguifu4 = 6667,
}

function MingBiRecycleLayer:initRoleItems(role)
	local retList = {}
	if MapIsEmpty(role) == true then
		return retList
	end
	local cloneRole = clone(role)
	local items = {}
	for itemId,v in pairs(bagItems) do
		items = cloneRole:getItemsWithItemId(itemId, "bag")
		if MapIsEmpty(items) == false then
			retList = table.mergeArray(retList, items)
		end 
	end
	
	for itemId,v in pairs(mianjuItems) do
		items = cloneRole:getItemsWithItemId(itemId, "decorative")
		if MapIsEmpty(items) == false then
			retList = table.mergeArray(retList, items)
		end 
	end

	for itemId,v in pairs(canYeItems) do
		items = cloneRole:getItemsWithItemId(itemId, "shuxiang")
		if MapIsEmpty(items) == false then
			retList = table.mergeArray(retList, items)
		end 
	end

	return retList
end


-- 设置角色,参数1是玩家角色，参数2是NPC
function MingBiRecycleLayer:setRoles(role1, role2, func)
	if not role1 or not role2 then
		assert(nil, "MingBiRecycleLayer:setRoles(role1, role2) -> 角色1或者角色2不存在")
	end

	self:initAll()

	-- 背包交易界面，交易功能说明
	-- 进入界面，左边为玩家背包，右边为npc物品列表
	-- 设置标题和回调
	self.Image_title.Text_title2:setString(role2:getName())
	self._callBackFunc = func

	--为玩家临时背包填充数据
	-- self.playerItems = clone( role1:getAttr("zhaoShuXiang") )
	self.playerItems = self:initRoleItems(role1)

	--把玩家背包的数据填充到ui
	self:setBagList( self.playerItems )

	--重要的标志
	self.Is_Sales = true
	-- 能卖出售物品给NPC
	self.npcCanSale = true

	-- --先添加商店购买的物品
	self:setBagList2({})
	-- self:setSellerItems({})


	-- 刷新玩家临时背包容量
	self:refreshWeightUI(self.playerItems)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 12:19:08
-- @desc 刷新整个界面
function MingBiRecycleLayer:refreshLayer()
	-- add by XiaoZhiWei 2017/03/29 19:50:42 刷新的时候检查 是否有未完成的订单
	-- TransCheck:checkAllTrans(function()end, 8)

	self:setBagList( self.playerItems )
	self:refreshWeightUI(self.playerItems)
	self:refreshMoney()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 11:31:37
-- @desc 出售
function MingBiRecycleLayer:sell(index, itemData)
	if index == nil then
		return
	end
	local role = User:getRole()
	self:dealOneItem(itemData.id, {itemId = itemData.id, time = GetTime(), count = 1, price = items[itemData.id], type = "sell", userid = User:getUserId()}, function()
		local bgitemToSell = self.playerItems[ index ]
		--典当一件玩家的物品
			--从玩家数据中删除一件物品
		self:popItemByIndex( self.playerItems , index )

		if itemData.type == "面具" then
			role:addDecorative(itemData.id, -1)

			if role:getPortraitId("portrait") == itemData.id and role:getDecorative(itemData.id) == nil then
				role:setAttr("portrait", {id = "",lv = 1})
			end
		else
			role:addItemCount(itemData.id, -1) -- add by XiaoZhiWei 2018/05/07 11:11:54 直接从身上扣除

			if role:checkItemIsEquipbyItemId(itemData.id) == true then
				role:setEquipByName(itemData.equipPart, nil)
			end
		end

		local itemHistory = Helper:getDef(role:getInheritFlag("ming_bi_item_list"), {})
		table.insert(itemHistory, itemData.id)
		role:setInheritFlag("ming_bi_item_list", itemHistory)

		--把玩家典当掉的物品id记录起来，以便于记录赎回
		local desc = "回收一"..tostring(itemData.unit)..tostring(itemData.name).."，你获得了"..tostring(math.abs(items[itemData.id])) .. currencyToCN(self:getCurrency())
		PopText( desc )
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 09:58:23
-- @desc 商品买卖
function MingBiRecycleLayer:dealOneItem(itemId, itemInfo, func)
	-- local func = function(transId)
		self:updateMingBiNumber(transId, itemId, func)
	-- end
	TransCheck:setTransWithWebOrderId(func, itemInfo, nil, 8)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/28 15:20:55
-- @desc 更新冥币点
function MingBiRecycleLayer:updateMingBiNumber(orderid, itemId, func)
	HttpManagerEx:updateCurrencyByType("add", "mingbi", items[itemId],nil, function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				TransCheck:updateTrans(orderid, RESPONSE_STATUS_SUCCESS)
				if func then
					func()
				end
				self:refreshLayer()
			else
				PopText(errmsg)
				TransCheck:updateTrans(orderid, RESPONSE_STATUS_FAILED)
			end
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
	-- HttpManagerEx:RecycleDeadCurrencyGoods(orderid, itemId, items[itemId], function(status, errcode, errmsg, data)
	-- 	if status == 200 then
	-- 		if errcode == 0 then
	-- 			TransCheck:updateTrans(orderid, RESPONSE_STATUS_SUCCESS)
	-- 			if func then
	-- 				func()
	-- 			end
	-- 			self:refreshLayer()
	-- 		else
	-- 			PopText(errmsg)
	-- 			TransCheck:updateTrans(orderid, RESPONSE_STATUS_FAILED)
	-- 		end
	-- 	else
	-- 		PopText(errmsg)
	-- 	end
	-- end, IS_SHOW_WAITING)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 10:43:20
-- @desc 自己背包的栏目
function MingBiRecycleLayer:createItem1(bagItem,itemData, widget)
	local row = widget
	if row == nil then
		row = self.Panel_item1:clone()
		Helper:convertUI(row)
	end

	row.Image_tiao:move(cc.p(0, 50))
	row.Text_name:move(cc.p(20, 50))
	row.Panel_dian:move(cc.p(-30, 60))
	row:setVisible(true)
	-- if itemData.id == User:getRole().shenBingweapon.id then
	-- 	row.Text_name:setString(tostring(itemData.name))
	-- else
		row.Text_name:setString( tostring(itemData.name) .. " X " .. tostring(bagItem.count) )
	-- end

	local outlineColor = cc.c4b(24, 24, 24, 255)
	local outlineWidth = 5
	row.Text_name:enableOutline(outlineColor, outlineWidth)

	-- 点击处理
	row:releaseFunc( function()
		-- 当前选中栏目
		local index = self.ListView_1:getCurSelectedIndex() + 1
     		--local status
 		if self.Is_Sales == true then
 			if self.npcCanSale ~= true then
 				PopText( "此商品无法在此出售")
 				return
 			end
 			--此处要考虑退货，卖出
 			--出售给商店
 			local ret , msg = self:checkItemCanSell( itemData )
 			if ret == false then
 				--物品不能出售
 				PopText( msg )
 				return
 			end

 			local bgitemToSell = self.playerItems[ index ]

			--判断物品是否是刚购买的物品，如果是，则原价退回
			local dialog = DialogALayer:getInstance()
			dialog:show("回收“"..tostring(itemData.name).."”将获得"..tostring(items[itemData.id])..currencyToCN(self:getCurrency()).."。")
			dialog:setButton1("确定", function()
				self:sell(index, itemData)
			end)
			dialog:setButton2("取消")
 		end
	end)
	return row
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/24 13:15:50
-- @desc 检查是否能够购买残页
function MingBiRecycleLayer:checkCanBuyThings()
	return true -- add by XiaoZhiWei 2017/04/24 13:16:18 当前书箱是没有容量限制的,所以可以直接购买放入
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/28 10:39:24
-- @desc 设置金钱数量
function MingBiRecycleLayer:setTextMoney(money)
	self.roleMoney = Helper:getDef(money, 0)
	self.Text_deadCurrency:setVisible(true)
	self.Text_deadCurrency:move(cc.p(580, 1710))
	self.Text_deadCurrency:setString("HIM冥币： " .. math.floor(self.roleMoney) .. "亿")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/28 11:05:16
-- @desc 刷新金钱数量
function MingBiRecycleLayer:refreshMoney(func)
	HttpManagerEx:viewCurrencyByType("mingbi", User:getRole():getCurrencyVersion(), function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			self:setTextMoney(tonumber(data.number))
			if User:getRole():getInheritFlag("ming_bi_curr_num") == 0 then
				User:getRole():setInheritFlag("ming_bi_curr_num", data.number)
			end
			if data.number >= 0 then
				local mingbiCount = User:getRole():getInheritFlag("ming_bi_curr_num")
				local itemHistory = User:getRole():getInheritFlag("ming_bi_item_list")
				local ret = false
				if MapIsEmpty(itemHistory) == true and mingbiCount > 0 then
					ret = true
				else
					local count = 0
					for k,itemId in pairs(itemHistory) do
						count = items[itemId] + count
					end

					if count ~= (tonumber(data.number) - mingbiCount) then
						ret = true
					end
				end

				if ret == true then
					Collection:memoryCheat(User:getUserId(), "MingBiCountError", mingbiCount, data.number)
				end

				if DEBUG_MODE == 1 then
					PopText("您所欠冥币已全部还清")
				end
				self:hide()
				return
			end
			if func then
				func()
			end
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/30 16:05:00
-- @desc 按钮初始化
function MingBiRecycleLayer:initButtons()
	local button2 = self:createButton() --确定按钮
	self:addChild(button2)
	button2:move(cc.p(810, 130))
	self.Button_2 = button2
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 10:28:05
-- @desc 设置按钮
function MingBiRecycleLayer:setButtons(playerSelledItemIds, playerBuyItemIds)
	self:setButton2("关闭", function()
        Audio:playEffect("xiaoAnNiu")
		self:hide()
		if type(self._callBackFunc) == "function" then
			self._callBackFunc()
		end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 10:37:38
-- @desc 当前值的计数在list的重新渲染中统计
function MingBiRecycleLayer:refreshWeightUI(items)
	if MapIsEmpty(items) == true then
		items = {}
	end
	self.Text_weight:setString( (#items) .. "/" .. User:getRoleAttr("weight"))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 10:49:29
-- @desc 设置货币
function MingBiRecycleLayer:setCurrency(currency)
	if currency == nil then
		currency = "money"
	end
	self.currency = currency
end

function MingBiRecycleLayer:getCurrency()
	return self.currency
end

Helper:classDefNodeGetInstance(MingBiRecycleLayer)
return MingBiRecycleLayer000000000000000