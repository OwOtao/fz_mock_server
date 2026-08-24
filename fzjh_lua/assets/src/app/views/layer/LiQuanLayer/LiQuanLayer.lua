local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

local LiQuanLayer = class("LiQuanLayer", require("app.views.layer.MapLayer.MapBagLayer"))
--[[
	礼券交易界面,继承自副本交易界面
    购买完成的商品无法出售
    背包中商品无法出售
]]

local CNtab = {
	["money"] = "碎银",
	["liquan"] = "礼券",
	["chunfen"] = "仲春礼券",
	["qingming"] = "清明礼券",
	["duanwu"] = "端午礼券",
	["qixi"] = "七夕礼券",
	["zhongqiu"] = "金秋礼券",
	["lidong"]="立冬礼券",
	["xiayuan"]="下元礼券",
	["dongzhi"]="冬至礼券",
	["xinchun"]="新春礼券",
	["wujueling"] = "五绝令",
	["duanjian"] = "断简",
	["default"] = "礼券",
}
local function currencyToCN(currency)
	return switch(currency, CNtab)
end

function LiQuanLayer:create()
    local p = LiQuanLayer:new()
    p:init()
    return p
end


-- function LiQuanLayer:init()
-- 	self._UI = require("Layer/MapUI/MapBagUI.lua").create() ['root']
-- 	self._UI:addTo(self)
	
-- 	Helper:convertUIByParent(self)
-- end

-- 初始化所有数据 (每次进入交易界面的时候初始化)
function LiQuanLayer:initAll()
	self.currency = "duanjian" -- 货币 默认是贡献点
	self.roleMoney = 0 -- 当前货币 数量
	self.playerItems = {} -- 玩家临时背包
	self.sellerItems = {} -- 商人临时背包
	self.sellerType = 3 -- 商人类型 1:师门商人 2:副本商人 默认值1   (增加一个活动礼券商人,类型:3)
    self._shopId = "zhounianqin_jf"
	self._callBackFunc = nil -- 最终回调函数
    --不同商人显示商品不同,setRoles时传入该显示的商品参数list  格式 {itemID,num}
	self.itemsList = {}
	-- 按钮初始化
	self:setButtons()

end

-- 设置角色,参数1是玩家角色，参数2是NPC,参数3是策划配的当前商人显示商品列表
function LiQuanLayer:setRoles(role1, role2, itemsList, func)
	if not role1 or not role2 then
		assert(nil, "LiQuanLayer:setRoles(role1, role2) -> 角色1或者角色2不存在")
	end

	self:initAll()

	-- 背包交易界面，交易功能说明
	-- 进入界面，左边为玩家背包，右边为npc物品列表
	-- 设置标题和回调
	self.Image_title.Text_title2:setString(role2:getName())
	self._callBackFunc = func
    
	--为玩家临时背包填充数据
	self.playerItems = clone( role1:getItems())

	--把玩家背包的数据填充到ui
	self:setBagList( self.playerItems )
  
	--重要的标志
	self.Is_Sales = true
	-- 能卖出售物品给NPC
	self.npcCanSale = false
    
	-- 商店应该显示的商品
    self.itemsList = itemsList
     
	-- --先添加商店购买的物品
	-- self:setBagList2( self.sellerItems )
	-- self:setSellerItems(clone( role2:getItems() ))
    self:getSellerItems()

	-- 刷新玩家临时背包容量
	self:refreshWeightUI(self.playerItems)
end

-- @desc 刷新整个界面
function LiQuanLayer:refreshLayer()
	TransCheck:checkAllTrans(function()end, 6)
	TransCheck:checkAllTrans(function()end, 7)

	self:setBagList( self.playerItems )
	self:refreshWeightUI(self.playerItems)
	self:refreshMoney(function()
		self:getSellerItems()
	end)
	self:connectToUserData()
end


-- 购买
    
function LiQuanLayer:buy(index, itemData)
	if index == nil then
		return
	end
	self:dealOneItem(itemData.id, - itemData.buyPrice, {itemId = itemData.id, time = GetTime(), count = 1, price = itemData.buyPrice, type = "buy", userid = User:getUserId()}, function()
		local bgitemToBuy = self.sellerItems[ index ]
		local weight = User:getRole():getNumAttr("weight") --人物背包容量
		self:pushItem( self.playerItems, bgitemToBuy, weight, itemData.priceUnit) 
		self:popItemByIndex( self.sellerItems, index )

		-- --正常购买流程
		-- -- currency[priceUnit].num = currency[priceUnit].num - tonumber(itemData.buyPrice)
		-- -- roleMoney = roleMoney - tonumber( itemData.buyPrice )

		-- local desc = "你购买一"..tostring(itemData.unit)..tostring(itemData.name).."花费了"..tostring(itemData.buyPrice) .. currencyToCN(self:getCurrency())
		-- PopText(desc)

		-- --把本次购买的商品加入购物记录，以便本次退货时能原价退回
		-- table.insert( self.playerBuyItemIds , bgitemToBuy.itemId )

	end)	
end

--  自己背包的栏目
--  礼券商人不支持出售
function LiQuanLayer:createItem1(bagItem,itemData, widget)
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
        PopText( "此商品无法在此出售") 
	end)
	return row
end


-- 商人的背包的栏目
function LiQuanLayer:createItem2(bagItem,itemData, widget)
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
    local a = 1
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
				if  bagItem.price > currNum then
					--钱不够
					-- PopText( "buyPrice"..bagItem.price)
					PopText( currencyToCN(self:getCurrency()).."不足")
     				return
				end
				-- --此处要判断买入，赎回
				-- --如果要买的物品id在购物记录中，则赎回
				-- --如果判断要买的物品id在典当记录中，则赎回
			local textList = {
				Text_tital = itemData.name,
				Text_type = itemData:getItemShowType(),
				Text_dsc = itemData.dsc,
				Text_price = "售价:"..bagItem.price..currencyToCN(self:getCurrency()),
				Text_affirm = "确定购买"..itemData.name.."吗？",
				Text_havenum = "已拥有:"..User:getRole():getItemTotalCount(itemData.id)..itemData.unit,
			}
			local ShoppingDialogLayer = require("app.views.layer.DialogLayer.ShoppingDialogLayer")
			PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
				layer:showLayer(textList,function()
				end)
				layer:setButton_confirm("确定", function()
					local item = {}
					item = itemData
					item.buyPrice = bagItem.price

					if User:getRole():checkCanBuyTwoOrMoreThings({[item.id] = 1}, false) == false then
						PopText("背包容量达到上限，无法继续获得物品")
					else
						self:buy(index, item)
					end
					
				end)
				layer:setButton_close("取消", function()
				end)
			end)

		end
	end)
	return row

end

-- 往itemlist中放一个item,这个list最多maxcount个item
function LiQuanLayer:pushItem( itemlist , bgitem , maxcount, priceUnit )
	--查询itemlist是否存在该物品
	local hasSameItem = false
	local sameitem = nil

	local itemAttr = Item:getOneItemByKey( bgitem.itemId )

	--寻找是否已经有这类物品了
	for i,it in ipairs( itemlist ) do
		--itemId一样表示是同类物品
		if it.itemId == bgitem.itemId then

			hasSameItem = true --有同类物品

			--判断当前是否是装备物品
            if itemAttr.canFold == ITEM_STATE_FALSE then
			   break 
			end
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
		if User:getRole():checkCanBuyTwoOrMoreThings({[bgitem.itemId] = 1}, false) == false then
			--背包已经满了超过了maxcount个物品
			print( "[警告] 背包已经满了超过了maxcount="..maxcount.."个物品" )
			return false
		end

		if itemAttr.type == "秘籍残页" or itemAttr.type == "书页" then
		else
			table.insert( itemlist , self:createSafeItem({ id = User:getRole():getItemOnlyId() , count = 1 , itemId = bgitem.itemId , name = itemAttr.name } ))
		end
	end

	return true
end


-- 玩家数据保存
function LiQuanLayer:connectToUserData()

	local role = User:getRole()
	--保存玩家道具
	role:setAttr( "items" , self.playerItems )
end

-- 设置礼券数量
function LiQuanLayer:setTextMoney(money)
	self.roleMoney = Helper:getDef(money, 0)
	self.Text_money:setVisible(true)
	self.Text_money:move(cc.p(580, 1710))
	self.Text_money:setString(currencyToCN(self:getCurrency()).."： "..tostring(math.floor(self.roleMoney)))
end

-- 刷新礼券数量
function LiQuanLayer:refreshMoney(func)
    local shopId = self._shopId
	HttpManagerEx:getShopInfo(shopId, function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
		   self:setTextMoney(tonumber(data.total_points))
			if func then
				func()
			end
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
	
end

--  设置商人的背包
function LiQuanLayer:setSellerItems(data)
	if MapIsEmpty(data) == false then
		self.sellerItems = {}
		local tab = {}
		for k,v in pairs(data) do 
			tab[k] = {}
			for i,value in pairs(v) do 
				if i == "itemId" then
					tab[k].itemId = value
				elseif i == "price" then
					tab[k].price = value
				elseif i == "number" then
					tab[k].number = value
				elseif i == "is_again" then
					if value == "N" then
						tab[k].max = data[k].times
						tab[k].limit = data[k].extra.limit
					else
						tab[k].max = 100000
					end
				elseif i == "inde" then
					tab[k].id = value
				end
			end
			tab[k].words = "您已经达到购买上限"
			tab[k].count = 1
		end

		--用传入的itemsList进行筛选商品总表tab,只显示itemsList有的商品
		local buyitem = {}
		for k,v in pairs(tab) do
		    for i,value in pairs(self.itemsList) do
				local itemId = string.split(value,",")
				if v.itemId == itemId[1] then
					buyitem[i] = v
				end
			end			
		end 
        
		-- self.sellerItems = tab
		self.sellerItems = buyitem
		self:setBagList2(self.sellerItems)
	else
		return false
	end
	return true
end


--获取商人的出售列
function LiQuanLayer:getSellerItems(func)
    local shopId = self._shopId
	HttpManagerEx:getShopInfo(shopId, function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				if MapIsEmpty(data) == false then
					data.shop_info = Helper:getDef(data.shop_info,{})
					if self:setSellerItems(data.shop_info.goods) == true then
					    self:setTextMoney(tonumber(data.total_points))
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
	end, IS_SHOW_WAITING)
end

-- 商品买卖
function LiQuanLayer:dealOneItem(itemId, points, itemInfo, func)
	local func = function(transId)
	    local tab = {
			itemId = itemId,
			client_trans_id = transId,
			shop_id = self._shopId
		}
		self:updateLiQuandian(tab,transId, itemId, points, itemInfo, func)
	end
	TransCheck:setTransWithWebOrderId(func, itemInfo, 1, 6)
end

--更新礼券并购买
function LiQuanLayer:updateLiQuandian(tab,transId, itemId, points, itemInfo, func)
    local shopId = self._shopId
	HttpManagerEx:shopExchangeGoods(tab, function(status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then			    
				local item = User:getRole():getOneItemByKey(tab.itemId)
				if item == nil then
					item = {}
					item.name = User:getRole():getCHAttrName(tab.itemId)
				else
					if item.type == "秘籍残页" or item.type == "书页" then
						User:getRole():addItemCount(tab.itemId,1,nil,nil,"礼券商人交易")
					else
						local Record = require("app.models.Record.Record")
						local logData = {}
						logData[tab.itemId] = 1
						Record:addLog(Record.LOG_TYPE.ITEM,logData,"礼券商人交易")
					end
				end

				if data.romove_point and data.romove_point > 0 then
					local desc = "你购买一"..tostring(item.unit)..tostring(item.name).."花费了"..tostring(data.romove_point) .. currencyToCN(self:getCurrency())

					PopText(desc)
				end
				
				-- PopText("获得物品"..item.name.."X"..tostring(points).."礼券")
			
				TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
				if func then
					func()
				end
				self:refreshLayer()
			else
				PopText(errmsg)
				TransCheck:updateTrans(transId, RESPONSE_STATUS_FAILED)
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
function LiQuanLayer:setSellerType(stype)
	if stype == nil then
		stype = 1
	end
	self.sellerType = stype
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/30 15:03:28
-- @desc 获取商人类型
function LiQuanLayer:getSellerType()
	return self.sellerType
end

-----------------------------------------------------------------------------------------------------------
-- @desc 按钮初始化
function LiQuanLayer:initButtons()
	-- local button1 = self:createButton() --关闭按钮
	local button2 = self:createButton() --确定按钮
	-- self:addChild(button1)
	self:addChild(button2)
	-- button1:move(cc.p(270, 130))
	button2:move(cc.p(810, 130))
	-- self.Button_1 = button1
	self.Button_2 = button2
end

-- @desc 设置按钮
function LiQuanLayer:setButtons()
	self:setButton2("关闭", function()
        Audio:playEffect("xiaoAnNiu")
		self:hide()
		if type(self._callBackFunc) == "function" then
			self._callBackFunc()
		end
	end)
end

-- @desc 当前值的计数在list的重新渲染中统计
function LiQuanLayer:refreshWeightUI(items)
	if MapIsEmpty(items) == true then
		items = {}
	end
	self.Text_weight:setString( (#items).."/"..User:getRoleAttr("weight"))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/29 10:49:29
-- @desc 设置货币
function LiQuanLayer:setCurrency(currency)
	if currency == nil then
		currency = "money"
	end
	self.currency = currency
end

function LiQuanLayer:getCurrency()
	return self.currency
end

function LiQuanLayer:checkItemIsSpcial(itemId)
	if type(itemId) ~= "string" then
		return
	end
	for k,v in pairs(special) do 
		if v.id == itemId then
			return true,v.name
		end
	end
	return false
end

function LiQuanLayer:getSpecialItemDsc(itemId)
	if type(itemId) ~= "string" then
		return
	end
	for k,v in pairs(special) do 
		if v.id == itemId then
			return v.dsc
		end
	end
	return ""	
end

Helper:classDefNodeGetInstance(LiQuanLayer)
return LiQuanLayer
00000000000