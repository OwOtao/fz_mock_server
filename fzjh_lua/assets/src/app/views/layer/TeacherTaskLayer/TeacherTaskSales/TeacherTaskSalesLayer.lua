local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

local TeacherTaskSalesLayer = class("TeacherTaskSalesLayer", require("app.views.layer.MapLayer.MapBagLayer"))

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
	--没找到则要添加一项新的
	local itemAttr = Item:getOneItemByKey( id )
	if not itemAttr then
		assert(nil, "TeacherTaskSalesLayer:createItem2(mapValue) -> 没有该物品".. id)
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

function TeacherTaskSalesLayer:create()
    local p = TeacherTaskSalesLayer:new()
    p:init()
    return p
end

function TeacherTaskSalesLayer:initAll()
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

function TeacherTaskSalesLayer:setRoles(role1, role2, func)
	if not role1 or not role2 then
		assert(nil, "TeacherTaskSalesLayer:setRoles(role1, role2) -> 角色1或者角色2不存在")
	end

	self:initAll()

	-- 背包交易界面，交易功能说明
	-- 进入界面，左边为玩家背包，右边为npc物品列表
	-- 设置标题和回调
	self.Image_title.Text_title2:setString(role2:getName())
	self._callBackFunc = func

	--为玩家临时背包填充数据
	self.playerItems = clone( role1:getItems() )

	--把玩家背包的数据填充到ui
	self:setBagList( self.playerItems )

	--重要的标志
	self.Is_Sales = true
	-- 能卖出售物品给NPC
	self.npcCanSale = false

	-- --先添加商店购买的物品
	-- self:setBagList2( self.sellerItems )
	self:setSellerItems(clone( role2:getItems() ))

	-- 刷新玩家临时背包容量
	self:refreshWeightUI(self.playerItems)
end

function TeacherTaskSalesLayer:refreshLayer()
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
-- @desc 购买
function TeacherTaskSalesLayer:buy(index, itemData,bagItem)
	-- if index == nil then
	-- 	return
	-- end
	-- self:dealOneItem(itemData.id, - itemData.buyPrice, {itemId = itemData.id, time = GetTime(), count = 1, price = itemData.buyPrice, type = "buy", userid = User:getUserId()}, function()
		-- local bgitemToBuy = self.sellerItems[ index ]
		-- local weight = User:getRole():getNumAttr("weight") --人物背包容量
		-- self:pushItem( self.playerItems, bgitemToBuy, weight, itemData.priceUnit) 
		-- self:popItemByIndex( self.sellerItems, index )
		-- --正常购买流程
		-- -- currency[priceUnit].num = currency[priceUnit].num - tonumber(itemData.buyPrice)
		-- -- roleMoney = roleMoney - tonumber( itemData.buyPrice )

		-- local desc = "你购买一"..tostring(itemData.unit)..tostring(itemData.name).."花费了"..tostring(itemData.buyPrice) .. currencyToCN(self:getCurrency())
		-- PopText(desc)

		-- --把本次购买的商品加入购物记录，以便本次退货时能原价退回
		-- table.insert( self.playerBuyItemIds , bgitemToBuy.itemId )
	-- end)
	HttpManagerEx:buyTeacherTaskShopItem(bagItem.index,function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				-- User:getRole():addItemCount(itemData.itemId,itemData.count)
				-- PopText("获得物品"..itemData.name.."X"..tostring(itemData.count))
				-- local weight = User:getRole():getNumAttr("weight")
				local bgitemToBuy = bagItem
				Helper:print_lua_table(bgitemToBuy)
				local weight = User:getRole():getNumAttr("weight") --人物背包容量
				self:pushItem( self.playerItems, bgitemToBuy, weight, itemData.priceUnit) 
				self:popItemByIndex( self.sellerItems, index )
				--正常购买流程
				-- currency[priceUnit].num = currency[priceUnit].num - tonumber(itemData.buyPrice)
				-- roleMoney = roleMoney - tonumber( itemData.buyPrice )

				local desc = "你购买"..tostring(itemData.name).."花费了"..tostring(bagItem.price) .. currencyToCN(self:getCurrency())
				PopText(desc)

				--把本次购买的商品加入购物记录，以便本次退货时能原价退回
				table.insert( self.playerBuyItemIds , bgitemToBuy.itemId )
				self:refreshLayer()
			else
				PopText(errmsg)
			end
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end



-- @desc 出售
function TeacherTaskSalesLayer:sell(index, itemData)
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

		local desc = "你出售一"..tostring(itemData.unit)..tostring(itemData.name).."获得了"..tostring(itemData.salePrice) .. currencyToCN(self:getCurrency())
		PopText( desc )
	end)
	-- else
	-- 	PopText( "他不要!" )
	-- end
end

-- @desc 自己背包的栏目
function TeacherTaskSalesLayer:createItem1(bagItem,itemData, widget)
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

-- @desc 商人的背包的栏目
function TeacherTaskSalesLayer:createItem2(bagItem,itemData, widget)
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
				--购买
				if itemData.buyPrice > currNum then
					--钱不够
					PopText( "师门贡献点不足" )
     				return
				end
				-- --此处要判断买入，赎回
				-- --如果要买的物品id在购物记录中，则赎回
				-- --如果判断要买的物品id在典当记录中，则赎回
				local dialog = DialogALayer:getInstance()
					dialog:show(tostring(itemData.name).."\n\n"..tostring(itemData.dsc).."\n花费:"..tostring(bagItem.price)..currencyToCN(self:getCurrency()), "是否确定购买")
					dialog:setButton1("确定", function()
						if self:checkCanBuyThings(itemData.id) == true then
							self:buy(index,itemData, bagItem)	
						else
							-- PopText( "你的包塞不下了" )
						end
					end)
					dialog:setButton2("取消")
				-- end

		end
	end)
	return row

end

-- @desc 检查是否能够购买残页
function TeacherTaskSalesLayer:checkCanBuyThings(itemId)

	return User:getRole():checkCanBuyThings(itemId,1)
end

-- @desc 往itemlist中放一个item,这个list最多maxcount个item
function TeacherTaskSalesLayer:pushItem( itemlist , bgitem , maxcount, priceUnit )
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
		--创建一个新物品
		if #itemlist >= maxcount then
			--背包已经满了超过了maxcount个物品
			print( "[警告] 背包已经满了超过了maxcount="..maxcount.."个物品" )
			return false
		end

		-- if priceUnit == "yuanbao" or priceUnit == "meiyu" then
		-- else
			table.insert( itemlist , self:createSafeItem({ id = User:getRole():getItemOnlyId() , count = 1 , itemId = bgitem.itemId , name = itemAttr.name } ))
		-- end
	end

	return true
end

-- @desc 玩家数据保存
function TeacherTaskSalesLayer:connectToUserData()

	local role = User:getRole()

	-- 计算一下最终获得的物品数量

	--保存玩家道具
	role:setAttr( "items" , self.playerItems )

end

-- @desc 设置金钱数量
function TeacherTaskSalesLayer:setTextMoney(money)
	self.roleMoney = Helper:getDef(money, 0)
	self.Text_money:setVisible(true)
	self.Text_money:move(cc.p(580, 1710))
	self.Text_money:setString("师门贡献点： "..tostring(math.floor(self.roleMoney)))
	-- 江湖美誉
	-- self:setTextMeiYu()
end

-- @desc 刷新金钱数量
function TeacherTaskSalesLayer:refreshMoney(func)
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

-- @desc 设置商人的背包
function TeacherTaskSalesLayer:setSellerItems(data)
	if MapIsEmpty(data) == false then
		self.sellerItems = {}
		for k,v in pairs(data) do
			-- v.status = 0 or v.status == true 
			-- add by XiaoZhiWei 2017/03/28 15:19:18 和服务器约定, 状态为0 则代表未购买
			if v.status == 0 or v.status == true then
				v.count = v.number
				v.number = nil 
				v.index = k
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
-- @desc 获取商人的出售列表
function TeacherTaskSalesLayer:getSellerItems(func)
	HttpManagerEx:getTeacherTaskShop("normal", self.mengpai, function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				if MapIsEmpty(data) == false then
					self:setTextDesc(data.need_yuanbao)
					if self:setSellerItems(data.goods_list) == true then
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

-- @desc 刷新商人出售列表
function TeacherTaskSalesLayer:refreshSalesItem(func)
	local func = function(transId)
		HttpManagerEx:getTeacherTaskShop("refresh", self.mengpai, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
					if MapIsEmpty(data) == false then
						self:setTextDesc(data.need_yuanbao)
						if self:setSellerItems(data.goods_list) == true then
							if func then
								func()
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
	TransCheck:setTransWithWebOrderId(func, {itemId = "TeacherTaskShop", time = GetTime(), userid = User:getUserId()}, 1, 7)
end

-- @desc 商品买卖
function TeacherTaskSalesLayer:dealOneItem(itemId, points, itemInfo, func)
	local func = function(transId)
		self:updateMenpaiGongxiangdian(transId, itemId, points, itemInfo, func)
	end
	TransCheck:setTransWithWebOrderId(func, itemInfo, 1, 6)
end

-- @desc 更新贡献点
function TeacherTaskSalesLayer:updateMenpaiGongxiangdian(orderid, itemId, points, info, func)
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
function TeacherTaskSalesLayer:setSellerType(stype)
	if stype == nil then
		stype = 1
	end
	self.sellerType = stype
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/30 15:03:28
-- @desc 获取商人类型
function TeacherTaskSalesLayer:getSellerType()
	return self.sellerType
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/30 16:05:00
-- @desc 按钮初始化
function TeacherTaskSalesLayer:initButtons()
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
function TeacherTaskSalesLayer:setButtons(playerSelledItemIds, playerBuyItemIds)
	self:setButton1("立即刷新", function()
        Audio:playEffect("xiaoAnNiu")
		-- 只有没有任何交易记录的情况下,才能刷新
		-- if MapIsEmpty(playerSelledItemIds) == true and MapIsEmpty(playerBuyItemIds) == true then
			local dialog = DialogALayer:getInstance()
			dialog:show("刷新将消耗"..tostring(self.refreshYuanBao).."元宝", "是否确定")
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
function TeacherTaskSalesLayer:setButton1(name, func)
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

-- @desc 按钮上方增加小文本
function TeacherTaskSalesLayer:setTextDesc(yuanbao)
	yuanbao = Helper:getDef(yuanbao, 0)
	self.refreshYuanBao = yuanbao
	self.Text_desc:setVisible(true)
	self.Text_desc:setString("每天0点自动刷新\n或花费"..tostring(self.refreshYuanBao).."元宝")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 10:37:38
-- @desc 当前值的计数在list的重新渲染中统计
function TeacherTaskSalesLayer:refreshWeightUI(items)
	if MapIsEmpty(items) == true then
		items = {}
	end
	self.Text_weight:setString( (#items).."/"..User:getRoleAttr("weight"))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 10:49:29
-- @desc 设置货币
function TeacherTaskSalesLayer:setCurrency(currency)
	if currency == nil then
		currency = "money"
	end
	self.currency = currency
end

function TeacherTaskSalesLayer:getCurrency()
	return self.currency
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/31 14:13:57
-- @desc 设置商人门派
function TeacherTaskSalesLayer:setSallerMenPai(mengpai)
	self.mengpai = mengpai
end
Helper:classDefNodeGetInstance(TeacherTaskSalesLayer)
return TeacherTaskSalesLayer
00000