local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
local Record = require("app.models.Record.Record")
local SalesLayer = class("SalesLayer", require("app.views.layer.MapLayer.MapBagLayer"))
--[[
	师门商人交易界面,继承自副本交易界面
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
		assert(nil, "SalesLayer:createItem2(mapValue) -> 没有该物品".. id)
		return
	end

	table.insert( itemlist , { id = User:getRole():getItemOnlyId() , count = 1 , itemId = id , name = itemAttr.name} )
end

local CNtab = {
	["money"] = "碎银",
	["gongxian"] = "贡献点",
	["default"] = "贡献点"
}
local function currencyToCN(currency)
	return switch(currency, CNtab)
end

function SalesLayer:create()
    local p = SalesLayer:new()
    p:init()
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 10:19:36
-- @desc 初始化所有数据 (每次进入交易界面的时候初始化)
function SalesLayer:initAll()
	self.currency = "gongxian" -- 货币 默认是贡献点
	self.roleMoney = 0 -- 当前货币 数量
	self.playerItems = {} -- 玩家临时背包
	self.playerBuyItemIds = {} -- 玩家购买的列表
	self.playerSelledItemIds = {} --玩家出售的列表
	self.sellerItems = {} -- 商人临时背包
	self.sellerType = 1 -- 商人类型 1:师门商人 2:副本商人 默认值1
	self.refreshYuanBao = 0 -- 刷新所需元宝数量 
	self.mengpai = nil

	self._callBackFunc = nil -- 最终回调函数

	-- 按钮初始化
	self:setButtons(self.playerBuyItemIds, self.playerSelledItemIds)
	self:refreshMoney()
end

-- 设置角色,参数1是玩家角色，参数2是NPC
function SalesLayer:setRoles(role1, role2, func)
	if not role1 or not role2 then
		assert(nil, "SalesLayer:setRoles(role1, role2) -> 角色1或者角色2不存在")
	end

	self:initAll()

	-- 背包交易界面，交易功能说明
	-- 进入界面，左边为玩家背包，右边为npc物品列表
	-- 设置标题和回调
	self.Image_title.Text_title2:setString(role2:getName())
	self._callBackFunc = func

	--为玩家临时背包填充数据
	self.playerItems = clone( role1:getAttr("zhaoShuXiang") )

	--把玩家背包的数据填充到ui
	self:setBagList( self.playerItems )

	--重要的标志
	self.Is_Sales = true
	-- 能卖出售物品给NPC
	self.npcCanSale = true

	--玩家以前典当的物品列表
	-- if role2.sellerRecycledItems == nil then
	-- 	role2.sellerRecycledItems = {}
	-- end

	--销售列表
	-- self.sellerItems = clone( role2:getAttr("zhaoShuXiang") )
	-- -- for i,v in ipairs( self.sellerItems ) do
	-- -- 	-- 购买数量1
	-- -- 	v.count = 1
	-- -- end

	-- -- -- --商人模式需要额外放置回收物品，回收物品中包括玩家上次典当的物品和本次购买后又退还的物品
	-- -- -- for i,v in ipairs( role2.sellerRecycledItems ) do
	-- -- -- 	--table.insert( sellerItems , v )
	-- -- -- 	--addItemById( sellerItems , v.itemId )
	-- -- -- 	for j = 1,v.count do
	-- -- -- 		addItemById( self.sellerItems , v.itemId )
	-- -- -- 	end
	-- -- -- end
	-- for i=10, 1, -1 do
	-- 	local v = self.sellerItems[i]
	-- 	if v ~= nil and v.status ~= 0 then
	-- 		table.remove(self.sellerItems, i)
	-- 	end
	-- end

	-- --先添加商店购买的物品
	-- self:setBagList2( self.sellerItems )
	self:setSellerItems(clone( role2:getAttr("zhaoShuXiang") ))

	-- 刷新玩家临时背包容量
	self:refreshWeightUI(self.playerItems)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 12:19:08
-- @desc 刷新整个界面
function SalesLayer:refreshLayer()
	-- add by XiaoZhiWei 2017/03/29 19:50:42 刷新的时候检查 是否有未完成的订单
	TransCheck:checkAllTrans(function()end, 6)
	TransCheck:checkAllTrans(function()end, 7)

	self:setBagList( self.playerItems )
	self:refreshWeightUI(self.playerItems)
	self:refreshMoney(function()
		self:getSellerItems()
	end)
	self:connectToUserData()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 11:30:20
-- @desc 购买
function SalesLayer:buy(index, itemData)
	if index == nil then
		return
	end
	self:dealOneItem(itemData.id, - itemData.buyPrice, {itemId = itemData.id, time = GetTime(), count = 1, price = itemData.buyPrice, type = "buy", userid = User:getUserId()}, function()
		local bgitemToBuy = self.sellerItems[ index ]
		local weight = User:getRole():getNumAttr("weight") --人物背包容量
		self:pushItem( self.playerItems, bgitemToBuy, weight, itemData.priceUnit) 
		self:popItemByIndex( self.sellerItems, index )
		--正常购买流程
		-- currency[priceUnit].num = currency[priceUnit].num - tonumber(itemData.buyPrice)
		-- roleMoney = roleMoney - tonumber( itemData.buyPrice )

		local desc = "你购买一"..tostring(itemData.unit)..tostring(itemData.name).."花费了"..tostring(math.abs(itemData.buyPrice)) .. currencyToCN(self:getCurrency())
		PopText(desc)

		--把本次购买的商品加入购物记录，以便本次退货时能原价退回
		table.insert( self.playerBuyItemIds , bgitemToBuy.itemId )
		local logData = {}
		logData[itemData.id] = 1
		Record:addLog(Record.LOG_TYPE.ITEM,logData,"师门贡献点商人交易")
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 11:31:01
-- @desc 退还
function SalesLayer:recycled(index, itemData)
	-- if index == nil then
	-- 	return
	-- end
	-- local bgitemToSell = self.playerItems[ index ]
	-- --把物品放到商人回收物品中 
	-- if self:pushItemFoldAll( self.sellerItems , bgitemToSell , 1 ) == true then
	-- 	--从玩家数据中删除一件物品
	-- 	self:popItemByIndex( self.playerItems , index )

	-- 	--把刚从那件物品从购买记录中删除
	-- 	for i,v in ipairs( self.playerBuyItemIds ) do
	-- 		if v == bgitemToSell.itemId then
	-- 			table.remove( self.playerBuyItemIds , i )
	-- 			break
	-- 		end
	-- 	end

	-- 	-- self.roleMoney = self.roleMoney + tonumber( itemData.buyPrice )

	-- 	local desc = "你退还一"..tostring(itemData.unit)..tostring(itemData.name).."收回了"..tostring(itemData.buyPrice) .. currencyToCN(self:getCurrency())
	-- 	PopText( desc )
	-- else
	-- 	PopText( "他不要!" )
	-- end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 11:31:37
-- @desc 出售
function SalesLayer:sell(index, itemData)
	if index == nil then
		return
	end

	self:dealOneItem(itemData.id, itemData.salePrice, {itemId = itemData.id, time = GetTime(), count = 1, price = itemData.salePrice, type = "sell", userid = User:getUserId()}, function()
		local bgitemToSell = self.playerItems[ index ]
		--典当一件玩家的物品
		-- if self:pushItemFoldAll( self.sellerItems , bgitemToSell , 1 ) == true then
			--从玩家数据中删除一件物品
		self:popItemByIndex( self.playerItems , index )

		--把玩家典当掉的物品id记录起来，以便于记录赎回
		table.insert( self.playerSelledItemIds , bgitemToSell.itemId )

		-- self.roleMoney = self.roleMoney + tonumber( itemData.salePrice )
		local desc = "你出售一"..tostring(itemData.unit)..tostring(itemData.name).."获得了"..tostring(math.abs(itemData.salePrice)) .. currencyToCN(self:getCurrency())
		PopText( desc )

		local logData = {}
		logData[itemData.id] = -1
		Record:addLog(Record.LOG_TYPE.ITEM,logData,"师门贡献点商人交易")
	end)
	-- else
	-- 	PopText( "他不要!" )
	-- end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 11:32:22
-- @desc 赎回
function SalesLayer:redeem(index, itemData)
	-- if index == nil then
	-- 	return
	-- end
	-- local bgitemToBuy = self.sellerItems[ index ]
	-- self:popItemByIndex( self.sellerItems, index )

	-- --从典当记录中删除记录 
	-- for i,v in ipairs( self.playerSelledItemIds ) do
	-- 	if v == bgitemToBuy.itemId then
	-- 		table.remove( self.playerSelledItemIds , i )
	-- 		break
	-- 	end
	-- end

	-- --以典当价赎回
	-- -- currency[priceUnit].num = currency[priceUnit].num - tonumber(itemData.salePrice)
	-- -- roleMoney = roleMoney - tonumber(itemData.salePrice)

	-- local desc = "你赎回一" .. tostring(itemData.unit)..tostring(itemData.name).."花费了"..tostring(itemData.salePrice) .. currencyToCN(self:getCurrency())
	-- PopText(desc)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 10:43:20
-- @desc 自己背包的栏目
function SalesLayer:createItem1(bagItem,itemData, widget)
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
			-- local currMoney = User:getRole():getNumAttr("money") --人物当前金钱数量

			--判断物品是否是刚购买的物品，如果是，则原价退回
			local dialog = DialogALayer:getInstance()
			-- if IsIdInTable( bgitemToSell.itemId , self.playerBuyItemIds ) == true then
			-- 	dialog:show("你将退还一本"..tostring(itemData.name), "是否确定")
			-- 	dialog:setButton1("确定", function()
			-- 		self:recycled(index, itemData)
	 	-- 			self:refreshLayer()
			-- 	end)
			-- 	dialog:setButton2("取消")
			-- else
				dialog:show(tostring(itemData.name).."\n\n"..tostring(itemData.dsc).."\n获得:"..tostring(itemData.salePrice)..currencyToCN(self:getCurrency()), "是否确定出售")
				dialog:setButton1("确定", function()
					self:sell(index, itemData)
	 				-- self:refreshLayer()
				end)
				dialog:setButton2("取消")
 			-- end
 		end
	end)
	return row
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 11:12:58
-- @desc 商人的背包的栏目
function SalesLayer:createItem2(bagItem,itemData, widget)
	local row = widget
	if row == nil then
		row = self.Panel_item2:clone()
		Helper:convertUI(row)
	end
	row:setVisible(true)

	--显示名字
	row.Text_name:setString( tostring(itemData.name) )
	local outlineColor = cc.c4b(24, 24, 24, 255)
	local outlineWidth = 5
	row.Text_name:enableOutline(outlineColor, outlineWidth)
	row.Text_num:enableOutline(outlineColor, outlineWidth)

	if self.Is_Sales then
		local buyPrice
		if bagItem.price ~= nil then
			buyPrice = bagItem.price
		else
			buyPrice = itemData.buyPrice
		end
		--显示价格或个数
		row.Text_num:setString( tostring( buyPrice ) .. " " .. currencyToCN(self:getCurrency()))
	end

	row:releaseFunc(function()
		--购买按钮
		local index = self.ListView_2:getCurSelectedIndex() + 1

 		--判断物品唯一性,判断物品可以获取
 		local ret , msg = self:checkItemCanLoot( itemData )
 		if ret == false then
 			--物品不能获取
 			PopText( msg )
 			return
 		end

 		if self.Is_Sales == true then

 			--商人
			local bgitemToBuy = self.sellerItems[ index ]

			-- 现有的货币数额
			local currNum = self.roleMoney

			--查询是不是刚典当的物品id
			-- local isBuyBackItem = IsIdInTable( bgitemToBuy.itemId , self.playerSelledItemIds )
			-- print( ">>>>>>>>>>>>>>>>>>>>>> isBuyBackItem=" .. tostring(isBuyBackItem) )
			-- print( ">>>>>>>>>>>>>>>>>>>>>> itemData.salePrice=" .. itemData.salePrice )
			-- print( ">>>>>>>>>>>>>>>>>>>>>> currMoney + roleMoney=" .. (currMoney + roleMoney) )

			-- if isBuyBackItem == true then
			-- 	--赎回
			-- 	if itemData.salePrice > currNum then
			-- 		--钱不够
			-- 		PopText( currencyToCN(self:getCurrency()) .. "不够" )
 		-- 			return
 		-- 		end
			-- else
				--购买
				if itemData.buyPrice > currNum then
					--钱不够
					PopText( "师门贡献点不足" )
     				return
				end
			-- end

			

				-- --此处要判断买入，赎回
				-- --如果要买的物品id在购物记录中，则赎回
				-- --如果判断要买的物品id在典当记录中，则赎回
				local dialog = DialogALayer:getInstance()
				-- if isBuyBackItem == true then
				-- 	dialog:show("你将退还一本"..tostring(itemData.name), "是否确定")
				-- 	dialog:setButton1("确定", function()
				-- 		self:redeem(index, itemData)	
	 		-- 			self:refreshLayer()
				-- 	end)
				-- 	dialog:setButton2("取消")
				-- else
					dialog:show(tostring(itemData.name).."\n\n"..tostring(itemData.dsc).."\n花费:"..tostring(itemData.buyPrice)..currencyToCN(self:getCurrency()), "是否确定购买")
					dialog:setButton1("确定", function()
						if self:checkCanBuyThings() == true then
							self:buy(index, itemData)	
		 					-- self:refreshLayer()
						else
							PopText( "你的包塞不下了" )
						end
					end)
					dialog:setButton2("取消")
				-- end

		end
	end)
	return row

end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/24 13:15:50
-- @desc 检查是否能够购买残页
function SalesLayer:checkCanBuyThings()
	return true -- add by XiaoZhiWei 2017/04/24 13:16:18 当前书箱是没有容量限制的,所以可以直接购买放入
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 17:20:06
-- @desc 往itemlist中放一个item,这个list最多maxcount个item
function SalesLayer:pushItem( itemlist , bgitem , maxcount, priceUnit )
	--查询itemlist是否存在该物品
	local hasSameItem = false
	local sameitem = nil

	local itemAttr = Item:getOneItemByKey( bgitem.itemId )

	--寻找是否已经有这类物品了
	for i,it in ipairs( itemlist ) do
		--itemId一样表示是同类物品
		if it.itemId == bgitem.itemId then

			hasSameItem = true --有同类物品

			--判断这个物品的数量是否还没超过99个
			if it.count < 99 then
				sameitem = it
				break
			end
		end
	end
	--print( "======== itemAttr ")
	--self:print_lua_table( itemAttr )
	if sameitem ~= nil and sameitem.count > 0 then

		-- 查询物品是否唯一
		-- if priceUnit == "yuanbao" or priceUnit == "meiyu" then
		-- else
			sameitem.count = sameitem.count + 1
		-- end
	else
		-- add by XiaoZhiWei 2017/10/13 14:44:47 残页不检查背包容量
		--创建一个新物品
		-- if #itemlist >= maxcount then
		-- 	--背包已经满了超过了maxcount个物品
		-- 	print( "[警告] 背包已经满了超过了maxcount="..maxcount.."个物品" )
		-- 	return false
		-- end

		-- if priceUnit == "yuanbao" or priceUnit == "meiyu" then
		-- else
			table.insert( itemlist , self:createSafeItem({ id = User:getRole():getItemOnlyId() , count = 1 , itemId = bgitem.itemId , name = itemAttr.name } ))
		-- end
	end

	return true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 15:04:41
-- @desc 玩家数据保存
function SalesLayer:connectToUserData()

	local role = User:getRole()

	-- 计算一下最终获得的物品数量
	-- self:getMapItemIdAndCount(role:getAttr("items"), roleItems)

	--保存玩家道具
	role:setAttr( "zhaoShuXiang" , self.playerItems )


	--保存玩家的货币
	-- for k,v in pairs(currency) do
	-- 	if k == "yuanbao" or k == "meiyu" then

	-- 	else
	-- 		print(k .. " = " .. role:getNumAttr(k) .. " + " .. v.num)
	-- 		role:setAttr( k , role:getNumAttr(k) + v.num )
	-- 	end

	-- end

	-- if self.role2 then
	-- 	--商人
	-- 	--商人需要保存的是回收商品列表，便于玩家下次来看还有之前卖掉的物品，只是它们没法赎回了
	-- 	--本次典当尚未被赎回的物品需要保存
	-- 	if self.role2.sellerRecycledItems == nil then
	-- 		self.role2.sellerRecycledItems = {}
	-- 	end

	-- 	-- --把物品添加到回收列表中
	-- 	-- for i,v in ipairs( sellerCurrRecycledItemIds ) do
	-- 	-- 	addItemById( self.role2.sellerRecycledItems , v )
	-- 	-- end

	-- 	-- --玩家以前典当的物品列表没卖完的还要继续销售，已经卖掉的物品要扣除
	-- 	-- if #self.role2.sellerRecycledItems > 0 then
	-- 	-- 	for i,v in ipairs( sellerSelledItemIds ) do --遍历已经卖掉的物品id列表
	-- 	-- 		removeItemById( self.role2.sellerRecycledItems , v )
	-- 	-- 	end
	-- 	-- end
	-- end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/28 10:39:24
-- @desc 设置金钱数量
function SalesLayer:setTextMoney(money)
	self.roleMoney = Helper:getDef(money, 0)
	self.Text_money:setVisible(true)
	self.Text_money:move(cc.p(580, 1710))
	self.Text_money:setString("师门贡献点： "..tostring(math.floor(self.roleMoney)))
	-- 江湖美誉
	-- self:setTextMeiYu()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/28 11:05:16
-- @desc 刷新金钱数量
function SalesLayer:refreshMoney(func)
	HttpManagerEx:getDevotePoint(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			self:setTextMoney(tonumber(data.dev_point))
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
-- @time 2017/03/28 15:18:49
-- @desc 设置商人的背包
function SalesLayer:setSellerItems(data)
	if MapIsEmpty(data) == false then
		self.sellerItems = {}
		for k,v in pairs(data) do
			-- add by XiaoZhiWei 2017/03/28 15:19:18 和服务器约定, 状态为0 则代表未购买
			if v.status == 0 then
				v.count = 1
				table.insert(self.sellerItems, v)
			end
		end

		-- -- add by XiaoZhiWei 2017/03/29 14:59:09 典当列表也需要显示
		-- for k,v in pairs(self.playerSelledItemIds) do
		-- 	addItemById(self.sellerItems, v)
		-- end

		self:setBagList2(self.sellerItems)
	else
		return false
	end
	return true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/28 12:20:50
-- @desc 获取商人的出售列表
function SalesLayer:getSellerItems(func)
	HttpManagerEx:getDevoteList(self:getSellerType(), self.mengpai, function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				if MapIsEmpty(data) == false then
					self:setTextDesc(data.yuanbao)
					if self:setSellerItems(data.list) == true then
						if func then
							func()
						end
					else
						-- 如果刷新获取数据失败,则重新获取列表数据
						self:getSellerItems(func)
					end
				end
			else
				PopText(errmsg)
			end
			return true
		end
	end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/28 10:39:44
-- @desc 刷新商人出售列表
function SalesLayer:refreshSalesItem(func)
	local func = function(transId)
		HttpManagerEx:getDevoteListByYuanbao(self:getSellerType(), transId, self.mengpai, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
					if MapIsEmpty(data) == false then
						self:setTextDesc(data.yuanbao)
						if self:setSellerItems(data.list) == true then
							if func then
								func()
							end

							do
								local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience")
						
								if LimitedTimeExperience:checkTaskIsOpen("smjyshuaxin") then
									LimitedTimeExperience:setRole(User:getRole())
									LimitedTimeExperience:finishTaskByTaskType("smjyshuaxin")
								end
							end
						else
							-- 如果刷新获取数据失败,则重新获取列表数据
							self:getSellerItems(func)
						end
					else
						-- 如果刷新获取数据失败,则重新获取列表数据
						self:getSellerItems(func)
					end
					
				else
					PopText(errmsg)
					TransCheck:updateTrans(transId, RESPONSE_STATUS_FAILED)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end
	TransCheck:setTransWithWebOrderId(func, {itemId = "DevoteListByYuanbao", time = GetTime(), userid = User:getUserId()}, 1, 7)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 09:58:23
-- @desc 商品买卖
function SalesLayer:dealOneItem(itemId, points, itemInfo, func)
	local func = function(transId)
		self:updateMenpaiGongxiangdian(transId, itemId, points, itemInfo, func)
	end
	TransCheck:setTransWithWebOrderId(func, itemInfo, 1, 6)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/28 15:20:55
-- @desc 更新贡献点
function SalesLayer:updateMenpaiGongxiangdian(orderid, itemId, points, info, func)
	HttpManagerEx:updateMenpaiGongxiangdian(orderid, itemId, points, info, function(status, errcode, errmsg, data)
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
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/30 15:02:33
-- @desc 设置商人类型
function SalesLayer:setSellerType(stype)
	if stype == nil then
		stype = 1
	end
	self.sellerType = stype
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/30 15:03:28
-- @desc 获取商人类型
function SalesLayer:getSellerType()
	return self.sellerType
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/30 16:05:00
-- @desc 按钮初始化
function SalesLayer:initButtons()
	local button1 = self:createButton() --关闭按钮
	local button2 = self:createButton() --确定按钮
	self:addChild(button1)
	self:addChild(button2)
	button1:move(cc.p(270, 130))
	button2:move(cc.p(810, 130))
	self.Button_1 = button1
	self.Button_2 = button2
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 10:28:05
-- @desc 设置按钮
function SalesLayer:setButtons(playerSelledItemIds, playerBuyItemIds)
	self:setButton1("立即刷新", function()
        Audio:playEffect("xiaoAnNiu")
		-- 只有没有任何交易记录的情况下,才能刷新
		-- if MapIsEmpty(playerSelledItemIds) == true and MapIsEmpty(playerBuyItemIds) == true then
			local dialog = DialogALayer:getInstance()
			local text = ""
			if self.refreshYuanBao == 0 then
				text = "使用名士特权，此次刷新免费"
			else
				text = "刷新将消耗"..tostring(self.refreshYuanBao).."元宝"
			end
			
			dialog:show(text,"是否确定")
			dialog:setButton1("确定", function()
				self:refreshSalesItem()	
			end)
			dialog:setButton2("取消")
		-- else
		-- 	PopText("只有没有任何交易记录的情况下,才能刷新")
		-- end
	end)
	self:setButton2("关闭", function()
		-- self:connectToUserData()
        Audio:playEffect("xiaoAnNiu")
		self:hide()
		if type(self._callBackFunc) == "function" then
			self._callBackFunc()
		end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 17:24:19
-- @desc 按钮1
function SalesLayer:setButton1(name, func)
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

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/30 15:20:14
-- @desc 按钮上方增加小文本
function SalesLayer:setTextDesc(yuanbao)
	yuanbao = Helper:getDef(yuanbao, 0)
	self.refreshYuanBao = yuanbao
	self.Text_desc:setVisible(true)
	if yuanbao == 0 then
		self.Text_desc:setString("每天0点自动刷新\n此次刷新免费")
	else
		self.Text_desc:setString("每天0点自动刷新\n或花费"..tostring(self.refreshYuanBao).."元宝")
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 10:37:38
-- @desc 当前值的计数在list的重新渲染中统计
function SalesLayer:refreshWeightUI(items)
	if MapIsEmpty(items) == true then
		items = {}
	end
	self.Text_desc1:setString("残页数量")
	self.Text_weight:setString( (#items))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 10:49:29
-- @desc 设置货币
function SalesLayer:setCurrency(currency)
	if currency == nil then
		currency = "money"
	end
	self.currency = currency
end

function SalesLayer:getCurrency()
	return self.currency
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/31 14:13:57
-- @desc 设置商人门派
function SalesLayer:setSallerMenPai(mengpai)
	self.mengpai = mengpai
end

Helper:classDefNodeGetInstance(SalesLayer)
return SalesLayer000000000000000