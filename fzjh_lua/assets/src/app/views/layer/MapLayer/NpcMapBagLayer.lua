-- npc商人改写 走新流程，暂定    及时是扣除黄金，碎银也要走服务器接口 获得返回值 
local Item = require("app.models.item.Item")
local Resource = require("app.Resource")

local NpcMapBagLayer = class("NpcMapBagLayer", cc.Layer)

local roleItems1 = {}	-- 玩家1交易前的背包

-- 货币
local currency =
{
	-- specialCurrency 服务器控制的特殊货币，
	money			= {num = 0, name = "碎银",		specialCurrency = false},
	gold			= {num = 0, name = "黄金",		specialCurrency = false},
	yuanbao		= {num = 0, name = "元宝",		specialCurrency = true},
	meiyu			= {num = 0, name = "江湖美誉",	specialCurrency = true},
	deadCurrency	= {num = 0, name = "亿冥币",		specialCurrency = true},
	mingbi	= {num = 0, name = "亿冥币",		specialCurrency = true},
	zjjifen	= {num = 0, name = "功绩",		specialCurrency = true},
	yinpiao	= {num = 0, name = "银票",		specialCurrency = true},
	spcl	= {num = 0, name = "饰品材料",		specialCurrency = true},
	jiaozi	= {num = 0, name = "游字令",		specialCurrency = true},
	zhounianjf	= {num = 0, name = "七夕礼券",		specialCurrency = true},
	dreamYiYu = {num = 0, name = "梦内呓语",		specialCurrency = true},
	xiangnang = {num = 0, name = "香囊",		specialCurrency = true},
	zongheng = {num = 0, name = "雪矾",		specialCurrency = true},
	molizhu = {num = 0, name = "墨璃珠",		specialCurrency = true},
	amartial = {num = 0, name = "武学要领",		specialCurrency = true},
	dmartial = {num = 0, name = "功法学识",		specialCurrency = true},
	bmartial = {num = 0, name = "武学心得",		specialCurrency = true},
	cmartial = {num = 0, name = "武学至极",		specialCurrency = true},
	xizhaoling = {num = 0, name = "昔朝令",		specialCurrency = true},
}

currency = TableProxy:createEncryptedTableRecursive(currency)
local roleMoney = 0
local roleItems = {} --玩家临时背包
local storageItems = {} --容器临时背包，例如尸体

local sellerItems = {} --商人临时背包
local sellerSelledItemIds = {} --商人已卖出物品列表
local sellerCurrRecycledItemIds = {} --商人本次回收的物品id列表


--工具函数，查询arr中是否包含id
local IsIdInTable = function(id, arr)
	for i, v in ipairs(arr) do
		if v == id then
			return true
		end
	end
	return false
end

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

--从itemlist中添加一个itemId==id的item,要考虑数量
local function addItemById(itemlist, id)
	for i, v in ipairs(itemlist) do
		
		if v.itemId == id then
			v.count = v.count + 1
			return
		end
	end
	
	--没找到则要添加一项新的
	local itemAttr = Item:getOneItemByKey(id)
	if not itemAttr then
		--assert(nil, "NpcMapBagLayer:createItem2(mapValue) -> 没有该物品".. id)
		return false
	end
	
	table.insert(itemlist, {id = User:getRole():getItemOnlyId(), count = 1, itemId = id, name = itemAttr.name})
end


function NpcMapBagLayer:create()
	local p = NpcMapBagLayer:new()
	p:init()
	return p
end

function NpcMapBagLayer:init()
	self._UI = require("Layer/MapUI/MapBagUI.lua").create() ['root']
	self._UI:addTo(self)
	
	Helper:convertUIByParent(self)
	
	--self:setPanelBack()--没用到
	self:initButtons()
end

function NpcMapBagLayer:show()
	self:setVisible(true)
end

function NpcMapBagLayer:hide()
	self:setVisible(false)
end

-- 设置角色,参数1是玩家角色，参数2是NPC
function NpcMapBagLayer:setRoles(role1, role2, func)
	if not role1 or not role2 then
		assert(nil, "NpcMapBagLayer:setRoles(role1, role2) -> 角色1或者角色2不存在")
	end
	
	-- 背包交易界面，交易功能说明
	-- 进入界面，左边为玩家背包，右边为npc物品列表
	-- 设置标题和回调
	self.Image_title.Text_title2:setString(role2:getName())
	self._callBackFunc = func
	
	self.role1 = role1
	self.role2 = role2
	
	--为玩家临时背包填充数据
	roleItems = clone(role1:getItems())
	roleMoney = 0 --交易额置零
	
	-- 清空交易货币数量
	for k, v in pairs(currency) do
		v.num = 0
	end
	
	-- 能卖出售物品给NPC
	self.npcCanSale = true
	
	--把玩家背包的数据填充到ui
	self:setBagList(roleItems)
	
	-- 判断role2是不是商人
	if self.role2.canSale == 1 or self.role2.canSale == true then
		
		--重要的标志
		self.Is_Sales = true
		
		-- 江湖美誉
		self.meiyu = nil
		self.Text_meiyu:setVisible(false)
		
		self.deadCurrency = nil
		self.Text_deadCurrency:setVisible(false)
		
		-- 元宝
		self.yuanbao = nil
		
		self:setTextMoney(User:getRoleAttr("money"), "money")
		
		--商人的话，要把之前玩家卖的东西拿出来卖
		sellerSelledItemIds = {} --清空曾经卖掉的物品id列表，离柜概不负责
		sellerCurrRecycledItemIds = {} --清空本次典当的物品id列表
		
		--玩家以前典当的物品列表
		if role2.sellerRecycledItems == nil then
			role2.sellerRecycledItems = {}
		end
		
		--销售列表
		sellerItems = clone(role2:getItems())
		for i, v in ipairs(sellerItems) do
			--商品数量无限
			v.count = 999
		end
		
		-- 添加黑市商人物品
		for i, v in ipairs(role2.blackMarket) do
			if v.count == nil then
				v.count = 999
			end
			for j = 1, v.count do
				if addItemById(sellerItems, v.itemId) ~= false then
					-- 添加第一个物品初始化数据
					if j == 1 then
						local tab = clone(v)
						Helper:tableCover(sellerItems[#sellerItems], tab)
						sellerItems[#sellerItems].count = 1
					end
				end
			end
		end
		
		--商人模式需要额外放置回收物品，回收物品中包括玩家上次典当的物品和本次购买后又退还的物品
		for i, v in ipairs(role2.sellerRecycledItems) do
			--table.insert( sellerItems , v )
			--addItemById( sellerItems , v.itemId )
			for j = 1, v.count do
				addItemById(sellerItems, v.itemId)
			end
		end
		
		--先添加商店购买的物品
		self:setBagList2(sellerItems)
		
	else
		self.Is_Sales = false
		
		--容器存取
		storageItems = clone(role2:getItems())
		--把尸体背包的数据填充到ui
		self:setBagList2(storageItems)
		
		self.Text_money:setVisible(false)
		self.Text_deadCurrency:setVisible(false)
		self.Text_meiyu:setVisible(false)
	end
	
	self:initSafeItem(roleItems)
	self:initSafeItem(sellerItems)
	self:initSafeItem(storageItems)
	
	-- 刷新玩家临时背包容量
	self:refreshWeightUI()
	
	-- 文本隐藏
	self.Text_desc:setVisible(false)
	
	-- 按钮初始化
	self:setButtons()
end

-- 自己的背包
function NpcMapBagLayer:setBagList(list)
	if not list then
		return
	end
	

	--显示我的背包
	-- self.ListView_1:removeAllItems()
	for i, v in ipairs(list) do
		local row
		if v.count > 0 then
			local item = Item:getOneItemByKey(v.itemId)
			if not item then
				if DEBUG_MODE == 1 then
					assert(nil, "NpcMapBagLayer:createItem1(mapValue) -> 没有该物品" .. v.itemId)
				end
			else
				--  NEEDTODO 考虑优化 物品太多时。。。
				local widget = self.ListView_1:getItem(i - 1)
				row = self:createItem1(v, item, widget, i)
				if widget == nil then
					self.ListView_1:pushBackCustomItem(row)
				end
			end
		end
	end

	for i = #list + 1, #self.ListView_1:getItems() do
		self.ListView_1:removeLastItem()
	end
end


-- 对方的背包
function NpcMapBagLayer:setBagList2(list)
	
	if not list then
		return
	end
	
	-- self.ListView_2:removeAllItems()
	
	for i, v in ipairs(list) do
		local row
		if v.count > 0 then
			local item = Item:getOneItemByKey(v.itemId)
			if not item then
				if DEBUG_MODE == 1 then
					assert(nil, "NpcMapBagLayer:createItem2(mapValue) -> 没有该物品" .. v.itemId)
				end
			end
			local widget = self.ListView_2:getItem(i - 1)
			row = self:createItem2(v, item, widget, i)
			
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
function NpcMapBagLayer:createItem1(bagItem, itemData, widget, index)
	local row = widget
	if row == nil then
		row = self.Panel_item1:clone()
		Helper:convertUI(row)
	end

	row.Text_name:setColor(cc.c3b(255, 255, 255))
	
	row:setVisible(true)
	if itemData.wpType == "神兵" then
		row.Text_name:setString(tostring(itemData.name))
	else
		row.Text_name:setString(tostring(itemData.name) .. " X " .. tostring(bagItem.count))
	end
	
	local outlineColor = cc.c4b(24, 24, 24, 255)
	local outlineWidth = 5
	row.Text_name:enableOutline(outlineColor, outlineWidth)
	
	local role = User:getRole()
	-- 点击处理
	row:releaseFunc(function()
		local ret , msg = self:checkItemCanDrop( itemData )
 		if ret == false then
 			--物品不能转移
 			PopText( msg )
 			return
 		end

 		-- 设置货币单位
		local priceUnit = itemData.priceUnit
		if priceUnit == "" or priceUnit == nil then
			priceUnit = "money"
		end
		
		if self.Is_Sales == true then
			if self.npcCanSale ~= true then
				PopText("此处无法出售商品")
				return
			end
			--此处要考虑退货，卖出
			--出售给商店
			local ret, msg = self:checkItemCanSell(itemData)
			if ret == false then
				--物品不能出售
				PopText(msg)
				return
			end
			
			local bgitemToSell = roleItems[index]
			local currMoney = User:getRole():getNumAttr("money") --人物当前金钱数量
			
			--判断物品是否是刚购买的物品，如果是，则原价退回
			if IsIdInTable(bgitemToSell.itemId, sellerSelledItemIds) == true then
				
				--把物品放到商人回收物品中
				if self:pushItemFoldAll(sellerItems, bgitemToSell, 9999) == true then
					--从玩家数据中删除一件物品
					self:popItemByIndex(roleItems, index)
					
					--把刚从那件物品从购买记录中删除
					for i, v in ipairs(sellerSelledItemIds) do
						if v == bgitemToSell.itemId then
							table.remove(sellerSelledItemIds, i)
							break
						end
					end
					
					currency[priceUnit].num = currency[priceUnit].num + tonumber(itemData.buyPrice)
					roleMoney = roleMoney + tonumber(itemData.buyPrice)
					
					local desc = "你退还一" .. tostring(itemData.unit) .. tostring(itemData.name) .. "收回了" .. tostring(math.abs(itemData.buyPrice)) .. currency[priceUnit].name
					PopText(desc)
				else
					PopText("他不要!")
				end
			elseif role:checkItemIsEquip(bagItem.id) then
				PopText("装备中的物品无法出售")
			elseif role:checkIsPrepareWeapon(bagItem.id) then 
				PopText("准备中的武器无法出售")
			elseif bagItem.wanhaodu and bagItem.wanhaodu == 0 then
				PopText("此兵器已经损坏，无法出售!")
			else
				--典当一件玩家的物品
				if self:pushItemFoldAll(sellerItems, bgitemToSell, 9999) == true then
					--从玩家数据中删除一件物品
					self:popItemByIndex(roleItems, index)
					
					--把玩家典当掉的物品id记录起来，以便于记录赎回
					table.insert(sellerCurrRecycledItemIds, bgitemToSell.itemId)

					sellerCurrRecycledItemIds = TableProxy:createEncryptedTableRecursive(sellerCurrRecycledItemIds)
					
					currency[priceUnit].num = currency[priceUnit].num + tonumber(itemData.salePrice)
					
					roleMoney = roleMoney + tonumber(itemData.salePrice)
					
					local desc = "你出售一" .. tostring(itemData.unit) .. tostring(itemData.name) .. "获得了" .. tostring(math.abs(itemData.salePrice)) .. currency[priceUnit].name
					PopText(desc)
				else
					PopText("他不要!")
				end
			end
			
			self:setBagList(roleItems)
			self:setBagList2(sellerItems)
			self:refreshWeightUI()
			self:setTextMoney(nil, priceUnit)
		else
			-- add by XiaoZhiWei 2017/11/06 14:57:46 已装备的物品不能放入尸体
			if role:checkItemIsEquip(bagItem.id) then
				PopText("装备中的物品无法丢弃")
				return
			elseif role:checkIsPrepareWeapon(bagItem.id) then 
				PopText("准备中的武器无法丢弃")
				return
			else
				--转移到尸体
				local bgitem = roleItems[index]
				--
				if self:pushItem(storageItems, bgitem, 20) == true then
					self:popItemByIndex(roleItems, index)
				else
					PopText("已经无法塞更多了")
				end
			end
			self:setBagList(roleItems)
			self:setBagList2(storageItems)
			
		end
		
		
		-- 列表及金钱的刷新
		self:refreshWeightUI()
		
	end)
	return row
end

-- 对方背包的栏目
function NpcMapBagLayer:createItem2(bagItem, itemData, widget, index)
	local row = widget
	if row == nil then
		row = self.Panel_item2:clone()
		Helper:convertUI(row)
	end
	
	-- 获取货币单位
	local priceUnit = bagItem.priceUnit
	if priceUnit == nil then
		priceUnit = itemData.priceUnit
		if priceUnit == "" or priceUnit == nil then
			priceUnit = "money"
		end
	end
	
	row:setVisible(true)
	
	--显示名字
	row.Text_name:setColor(cc.c3b(255, 255, 255))
	row.Text_name:setString(tostring(itemData.name))
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
		-- 显示价格或个数
		-- 经脉系统 黑市商人元宝购买有折扣 10%
		local role = User:getRole()
		if bagItem.isBlackChapman == true and priceUnit == "yuanbao" and role:isHaveImprintingId("fuhuiyin") then
			local Meridian = require("app.models.Meridian.Meridian")
			local meridianBuffValue = Meridian:getMeridianBuffValue("fuhuiyin")
			buyPrice = math.ceil(buyPrice * meridianBuffValue)
		end
		row.Text_num:setString(tostring(math.abs(buyPrice)) .. " " .. currency[priceUnit].name)
	else
		--尸体容器
		row.Text_num:setString(" X " .. tostring(bagItem.count))
	end
	
	row:releaseFunc(function()
		--购买按钮
 		--判断物品唯一性,判断物品可以获取
 		local ret , msg = self:checkItemCanLoot( itemData )
 		if ret == false then
 			--物品不能获取
 			PopText( msg )
 			return
 		end

 		if self.Is_Sales == true then

 			--商人
			local bgitemToBuy = sellerItems[ index ]
			local weight = User:getRole():getNumAttr("weight") --人物背包容量
			local currMoney = User:getRole():getNumAttr("money") --人物当前金钱数量
			
			-- 现有的货币数额
			local currNum = User:getRole():getNumAttr(priceUnit)
			
			--查询是不是刚典当的物品id
			local isBuyBackItem = IsIdInTable(bgitemToBuy.itemId, sellerCurrRecycledItemIds)
			if currency[priceUnit].specialCurrency ~= true then
				if isBuyBackItem == true then
					--赎回
					if itemData.salePrice > currNum + currency[priceUnit].num then
						--钱不够
						PopText(currency[priceUnit].name .. "不够")
						return
					end
				else
					--购买
					--限制购买灵石
					if bgitemToBuy.itemId == "lingshi1" then
						for k, item in pairs(User:getRole():getItems()) do
							if item.itemId == "lingshi1" then
								PopText("灵石只能拥有一个")
								return
							end
						end
						
						if sellerSelledItemIds then
							for k, v in pairs(sellerSelledItemIds) do
								if v == "lingshi1" then
									PopText("灵石只能拥有一个")
									return
								end
							end
						end
					end
					local price = bgitemToBuy.price
					if price == nil then
						price = itemData.buyPrice
					end
					
					if tonumber(price) > currNum + currency[priceUnit].num then
						--钱不够
						PopText("你买不起")
						return
					end
					
				end
			end
			
			-- self:pushItem() 中参数priceUnit 此处做判断时priceUnit必须统一为 specialCurrency，暂用"yuanbao",这样才不会不经过二次判断直接加入背包
			if self:pushItem(roleItems, bgitemToBuy, weight, "yuanbao") == true then
				--此处要判断买入，赎回
				--如果要买的物品id在购物记录中，则赎回
				--如果判断要买的物品id在典当记录中，则赎回
				if isBuyBackItem == true then
					self:popItemByIndex(sellerItems, index)
					
					--从典当记录中删除记录
					for i, v in ipairs(sellerCurrRecycledItemIds) do
						if v == bgitemToBuy.itemId then
							table.remove(sellerCurrRecycledItemIds, i)
							break
						end
					end
					
					--以典当价赎回
					currency[priceUnit].num = currency[priceUnit].num - tonumber(itemData.salePrice)
					roleMoney = roleMoney - tonumber(itemData.salePrice)
					if priceUnit == "meiyu" or priceUnit == "deadCurrency" or priceUnit == "money" then
						self:pushItem(roleItems, bgitemToBuy, weight, "")
					end
					print(itemData.salePrice)
					local desc = "你赎回一" .. tostring(itemData.unit) .. tostring(itemData.name) .. "花费了" .. tostring(math.abs(itemData.salePrice)) .. currency[priceUnit].name
					PopText(desc)

				else

					self:BuyAllItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)
				end
			else
				PopText("你的包塞不下了")
			end
			
			-- 列表刷新
			self:setBagList(roleItems)
			self:setBagList2(sellerItems)
			self:refreshWeightUI()
			self:setTextMoney(nil, priceUnit)
	
		end
	end)
	return row
end
function NpcMapBagLayer:updateShenShuList(itemId)
	if itemId == nil then
		return
	end

	local ShenShuHelper = require("app.models.shenshu.shenshu")

	local role = User:getRole()

	if ShenShuHelper:checkIsInFindBook(role) == false then
		return
	end

	local isTrue = ShenShuHelper:findBook(role, itemId)

	if isTrue then
		ShenShuHelper:getHintText(itemId)
		local mapLayer = MainControllLayer:getLayer("MapLayer")
		mapLayer._currMap:removeTaskFromDelayTasks(itemId)
	end
end

function NpcMapBagLayer:lootAllItems()
	--从storageItems中把物品全部转移过来
	local exitFor = false
	local weight = User:getRole():getNumAttr("weight") --人物背包容量
	
	--寻找是否已经有这类物品了
	local tcount = #storageItems
	for i = tcount, 1, - 1 do
		--for i,bgitem in ipairs( storageItems ) do
		local bgitem = storageItems[i]
		repeat
			local itemData = Item:getOneItemByKey(bgitem.itemId)
			-- add by XiaoZhiWei 2017/11/06 15:10:27 尸体上的动气能够全部转移过来
			-- local ret, msg = self:checkItemCanDrop(itemData)
			-- if ret == false then
			-- 	--物品不能转移
			-- 	PopText(msg)
			-- 	break
			-- end
			
			local count = bgitem.count--尸体中物品数量超过1
			if itemData.canFold == ITEM_STATE_FALSE then
				count = 1
			end
			
			for j = count, 1, - 1 do
				if itemData.type == "书页" or itemData.type == "武学秘宝" or itemData.type == "毒药" or itemData.type == "制药材料" or itemData.type == "秘籍残页" 
					or itemData.type == "淬炼材料" or itemData.type == "锻造材料" then
					User:getRole():addItemCount(bgitem.itemId, 1,nil,nil,"战利品")
					self:popItemByIndex(storageItems, i)
					PopText("你获得了 " .. tostring(itemData.name))
				elseif itemData.type == "神书" then --优化神书更新方式
					if self:pushItem(roleItems, bgitem, weight) == true then
						self:popItemByIndex(storageItems, i)
						local result = User:getRole():addItemCount(bgitem.itemId, 1)
						self:updateShenShuList(bgitem.itemId)
						PopText("你获得了 " .. tostring(itemData.name))
					else
						PopText("你的包塞不下了")
					end
				else
					if self:pushItem(roleItems, bgitem, weight) == true then
						self:popItemByIndex(storageItems, i)
					else
						PopText("你的背包满了,无法拿取")
						exitFor = true
						break
					end
				end
				
				-- if self:pushItem( roleItems , bgitem , weight ) == true then
				-- 	self:popItemByIndex( storageItems , i )
				-- else
				-- 	PopText( "你的背包满了,无法拿取" )
				-- 	exitFor = true
				-- 	break
				-- end
			end
		until true
		
		if exitFor == true then
			break
		end
	end
	
	--刷新
	self:setBagList(roleItems)
	self:setBagList2(storageItems)
	self:refreshWeightUI()
end


function NpcMapBagLayer:popItemByIndex(itemlist, index)
	
	local it = itemlist[index]
	
	--print( "popItemByIndex index=" .. index )
	--self:print_lua_table( it )
	--local itemAttr = Item:getOneItemByKey( it.itemId )
	--if itemAttr.canFold == ITEM_STATE_TRUE and it.count > 1 then
	if it.count > 1 then --弹出商品不关心是否能叠加
		--多于1个，只弹出一个物品
		it.count = it.count - 1
		
		return it
	else
		--不能堆叠，或者物品只有1个
		table.remove(itemlist, index)
		
		return it
	end
end

--往itemlist中放一个item,这个list最多maxcount个item
function NpcMapBagLayer:pushItem(itemlist, bgitem, maxcount, priceUnit)
	
	--查询itemlist是否存在该物品
	local hasSameItem = false
	local sameitem = nil
	
	local itemAttr = Item:getOneItemByKey(bgitem.itemId)
	
	--寻找是否已经有这类物品了
	for i, it in ipairs(itemlist) do
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
	if sameitem ~= nil and itemAttr.canFold == ITEM_STATE_TRUE and sameitem.count > 0 then
		
		-- 查询物品是否唯一
		if priceUnit and priceUnit ~= "" and currency[priceUnit].specialCurrency == true then
		else
			sameitem.count = sameitem.count + 1
		end
	else
		--创建一个新物品
		if #itemlist >= maxcount then
			--背包已经满了超过了maxcount个物品
			print("[警告] 背包已经满了超过了maxcount=" .. maxcount .. "个物品")
			return false
		end
		
		if priceUnit and priceUnit ~= "" and currency[priceUnit].specialCurrency == true then
		else
			table.insert(itemlist, self:createSafeItem({id = User:getRole():getItemOnlyId(), count = 1, itemId = bgitem.itemId, name = itemAttr.name}))
		end
	end
	
	return true
end


--往itemlist中放一个item,这个list最多maxcount个item 无视堆叠条件和99堆叠上限，主要用于商人
function NpcMapBagLayer:pushItemFoldAll(itemlist, bgitem, maxcount)
	
	--查询itemlist是否存在该物品
	local sameitem = nil
	
	--寻找是否已经有这类物品了
	for i, it in ipairs(itemlist) do
		--itemId一样表示是同类物品
		if it.itemId == bgitem.itemId then
			sameitem = it
		end
	end
	
	local itemAttr = Item:getOneItemByKey(bgitem.itemId)
	if sameitem ~= nil then
		
		-- 查询物品是否唯一
		sameitem.count = sameitem.count + 1
	else
		--创建一个新物品
		if #itemlist >= maxcount then
			--背包已经满了超过了maxcount个物品
			print("[警告] 背包已经满了超过了maxcount=" .. maxcount .. "个物品")
			return false
		end
		print("----------------pushItemFoldAll--------------------")
		if DEBUG_MODE == 1 then
			Helper:print_lua_table(bgitem)
		end
		table.insert(itemlist, self:createSafeItem({id = User:getRole():getItemOnlyId(), count = 1, itemId = bgitem.itemId, name = itemAttr.name}))
	end
	
	return true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/25 14:50:12
-- @desc 创建防作弊物品列表
function NpcMapBagLayer:createSafeItem(itemData)
	-- local itemId = tostring(itemData.itemId)
	-- return createEncryptTable(itemData)
	-- add by XiaoZhiWei 2017/08/30 12:14:13 修改为防作弊方式
	return createSafeTable("NpcMapBagLayer.item."..tostring(itemData.itemId), itemData, function(itemData, valueName, valueFrom, valueTo)
		Collection:memoryCheat(User:getUserId(), valueName, valueFrom, valueTo)
	end)
end

--判断一个物品是否可以拾取
function NpcMapBagLayer:checkItemCanLoot(item)
	
	return true
end

-- 添加物品
function NpcMapBagLayer:checkItemCanSell(item)
	local result = true
	result = switch(item.priceUnit, {
		money = false,
		gold = false,
		yuanbao = true,
		meiyu = true,
		deadCurrency = true,
	})
	return result
end

function NpcMapBagLayer:checkItemCanDrop(item)
	
	-- 物品属性中的ID 等于 背包中的itemId
	local itemId = item.id
	local role = User:getRole()

	-- if role:checkItemIsEquipbyItemId(item.id) then
	-- 	return false, "已经穿戴的装备不能这样处理！"
	-- end 
	
	
	if item.itemCanSale ~= 1 and item.itemCanSale ~= true then
		return false, tostring(item.name) .. "不能出售丢弃购买!"
	end
	
	if itemId == "guanfugongwen" then
		return false, tostring(item.name) .. "不能出售丢弃购买!"
	end
	
	if item.priceUnit == "yuanbao" then
		return false, "此物太过珍贵,不能出售丢弃购买!"
	end
	
	if item.wpType == "神兵" then
		return false, "神兵不能出售丢弃购买!"
	end
	
	return true
end



--先解决wight上限问题   --  总结：毛线，什么BUG先找出最根本的原因，不然，改来改去，这个现象没了，那里又出问题了！！！！
--物品价格问题
function NpcMapBagLayer:getItemsWithItemId(itemId)
	local list = {}
	for i, item in ipairs(self.list1) do
		if item.itemId == itemId then
			item.index = i
			table.insert(list, item)
		end
	end
	return list
end




-- 玩家数据保存
function NpcMapBagLayer:connectToUserData()
	
	local role = User:getRole()
	
	-- 计算一下最终获得的物品数量
	self:getMapItemIdAndCount(role:getAttr("items"), roleItems)
	
	self:addSpecialItemToRole(role, roleItems) -- add by XiaoZhiWei 2017/04/08 17:28:02 遍历一遍,将特殊类型的物品添加到角色背包后,剔除出列表
	
	--保存玩家道具
	role:setAttr("items", roleItems)
	-- if TEACHER_TASK_IS_OPEN == true then
	-- 	local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
	-- 	TeacherTask:dealTypeZero()
	-- end
	
	--保存玩家的货币
	for k, v in pairs(currency) do
		if v and v.specialCurrency == true then
			
		else
			print(k .. " = " .. role:getNumAttr(k) .. " + " .. v.num)
			role:setAttr(k, role:getNumAttr(k) + v.num)
		end
		
	end
	
	
	if self.role2 then
		if self.Is_Sales then
			--商人
			--商人需要保存的是回收商品列表，便于玩家下次来看还有之前卖掉的物品，只是它们没法赎回了
			--本次典当尚未被赎回的物品需要保存
			if self.role2.sellerRecycledItems == nil then
				self.role2.sellerRecycledItems = {}
			end
			
			--把物品添加到回收列表中
			for i, v in ipairs(sellerCurrRecycledItemIds) do
				addItemById(self.role2.sellerRecycledItems, v)
			end
			
			--玩家以前典当的物品列表没卖完的还要继续销售，已经卖掉的物品要扣除
			if #self.role2.sellerRecycledItems > 0 then
				for i, v in ipairs(sellerSelledItemIds) do --遍历已经卖掉的物品id列表
					removeItemById(self.role2.sellerRecycledItems, v)
				end
			end
			
		else
			
			
			--容器尸体
			self.role2:setAttr("items", storageItems)
		end
	end
end




function NpcMapBagLayer:createButton()
	local roleButton = Resource:getUIByName("Button_4")
	Helper:convertUI(roleButton)
	roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return roleButton
end

--按钮初始化
function NpcMapBagLayer:initButtons()
	local button1 = self:createButton() --关闭按钮
	local button2 = self:createButton() --确定按钮
	self:addChild(button1)
	self:addChild(button2)
	button1:move(cc.p(270, 200))
	button2:move(cc.p(810, 200))
	self.Button_1 = button1
	self.Button_2 = button2
end

function NpcMapBagLayer:setButtons()
	-- 是否是小商贩
	if self.Is_Sales == true then
		self:setButton1()
		self:setButton2("确定", function()
			self:connectToUserData()
			self:hide()
			if type(self._callBackFunc) == "function" then
				self._callBackFunc()
			end
		end)
	else
		self:setButton1("关闭", function()
			self:connectToUserData()
			if type(self._callBackFunc) == "function" then
				self._callBackFunc()
			end
		end)
		self:setButton2("提取全部", function()
			--self:addToList(self.list1, self.list2)
			self:lootAllItems() --从storageItems里拾取所有物品
			
			self:delayFunc(0, function()
				self:setBagList(self.list1)
				self:setBagList2(self.list2)
			end)
		end)
	end
end

function NpcMapBagLayer:setButton1(name, func, isHide)
	if not name then
		self.Button_1:setVisible(false)
		return
	else
		self.Button_1:setVisible(true)
	end
	if isHide == nil then
		isHide = true
	end
	self.Button_1.Text_buttonName:setString(name)
	self.Button_1:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if func then
			func()
		end
		if isHide == true then
			self:hide()
		end
	end)
end

function NpcMapBagLayer:setButton2(name, func)
	if not name then
		self.Button_2:setVisible(false)
		return
	else
		self.Button_2:setVisible(true)
	end
	self.Button_2.Text_buttonName:setString(name)
	self.Button_2:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if func then
			func()
		end
	end)
end

-- 当前值的计数在list的重新渲染中统计
function NpcMapBagLayer:refreshWeightUI()
	self.Text_weight:setString((#roleItems) .. "/" .. User:getRoleAttr("weight"))
end

function NpcMapBagLayer:setTextMoney(num, ctype)
	local text = ""

	if num ~= nil then
		self._num = num
	elseif self._num == nil then
		return
	end

	num = self._num + currency[ctype].num
	if ctype == "money" then
		text = "HIW碎银： " .. tostring(math.floor(num))
	elseif ctype == "yuanbao" then
		text = "HIW元宝： " .. tostring(math.floor(num))
	elseif ctype == "mingbi" or ctype == "deadCurrency" then
		local deadCurrency
		if math.abs(currency.deadCurrency.num) >= math.abs(currency.mingbi.num) then
			deadCurrency  = num - currency[ctype].num + currency.deadCurrency.num
		else
			deadCurrency  = num - currency[ctype].num + currency.mingbi.num
		end

		text = "HIM冥币： " .. tostring(math.floor(deadCurrency)) .. "亿"
	elseif ctype == "meiyu" then
		text = "GLD江湖美誉： " .. tostring(math.floor(num))
	elseif ctype == "zjjifen" then
		text = "HIW功绩： " .. tostring(math.floor(num))
	elseif ctype == "spcl" then
		text = "HIW饰品材料： " .. tostring(math.floor(num))
	elseif ctype == "yinpiao" then
		text = "HIW银票： " .. tostring(math.floor(num))
	elseif ctype == "jiaozi" then
		text = "HIW游字令： " .. tostring(math.floor(num))
	elseif ctype == "zhounianjf" then
		text = "HIW七夕礼券： " .. tostring(math.floor(num))
	elseif ctype == "dreamYiYu" then
		text = "HIW梦内呓语： " .. tostring(math.floor(num))
	elseif ctype == "xiangnang" then
		text = "HIW香囊： " .. tostring(math.floor(num))
	elseif ctype == "zongheng" then
		text = "HIW雪矾： " .. tostring(math.floor(num))
	elseif ctype == "molizhu" then
		text = "HIW墨璃珠： " .. tostring(math.floor(num))
	elseif ctype == "amartial" then
		text = "HIW武学要领： " .. tostring(math.floor(num))
	elseif ctype == "dmartial" then
		text = "HIW功法学识： " .. tostring(math.floor(num))
	elseif ctype == "bmartial" then
		text = "HIW武学心得： " .. tostring(math.floor(num))
	elseif ctype == "cmartial" then
		text = "HIW武学至极： " .. tostring(math.floor(num))
	elseif ctype == "xizhaoling" then
		text = "HIW昔朝令： " .. tostring(math.floor(num))
	end
	self.Text_money:setVisible(true)
	self.Text_money:setString(text)

	self.Text_desc:setVisible(false)
	if ctype == "meiyu" then
		self.Text_desc:setVisible(true)
		self.Text_desc:setString("花费50元宝立即刷新")
	end

	if currency[ctype].name then
		self.logOrigin = "商人"..currency[ctype].name.."购买"
	else
		self.logOrigin = "商人交易"
	end
end

-- 能否将物品出售给NPC
function NpcMapBagLayer:setNpcCanSale(flag)
	self.npcCanSale = flag
end

-- 获取价格单位
function NpcMapBagLayer:getPriceUnit(first, second)
	-- 设置货币单位
	local priceUnit = first
	if priceUnit == nil then
		priceUnit = second
	end
	if priceUnit == "" or priceUnit == nil then
		priceUnit = "money"
	end
	return priceUnit
end
local function getVoucherPrice(item,price,npcId)
	--折扣物品Id,最大折扣个数,每个物品享有的折扣率,商人Id
	if item.voucherId == nil or item.voucherId == "" or type(npcId) ~= "string" then
		print("返回1")
		return 0,price,nil
	end
	if tonumber(price) == nil or price < 0 then
		assert(nil,"商品价格要必须是数字且数值不小于0")
	end
	local list = string.split(item.voucherId,",")
	if #list ~= 4 then
		print(item.voucherId)
		if DEBUG_MODE == 1 then
			assert(nil)
		end
		print("返回2")
		return 0,price,nil
	end
	if list[4] ~= npcId then
		if DEBUG_MODE ==1 then
			print("不是在指定的npc商人处购买，不享有折扣")
		end
		print("返回3",npcId,list[4])
		return 0,price,nil
	end
	local itemNum = math.min(User:getRole():getItemCount(list[1]),tonumber(list[2]))
	print(itemNum,math.floor(price * (1 - itemNum * tonumber(list[3]))))
	return itemNum,math.floor(price * (1 - itemNum * tonumber(list[3]))),User:getRole():getOneItemByKey(list[1]),(itemNum * tonumber(list[3]))*100
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/18 14:44:28
-- @desc 获取最终得到物品的列表及数量
function NpcMapBagLayer:getMapItemIdAndCount(beforeItems, afterItems)
	beforeItems = Helper:getDef(beforeItems, {})
	afterItems = Helper:getDef(afterItems, {})
	local retMap = {}
	local function mergeItemCountToItemId(items)
		local retItems = {}
		for i, item in pairs(items) do
			if retItems[item.itemId] ~= nil then
				retItems[item.itemId] = retItems[item.itemId] + item.count
			else
				retItems[item.itemId] = item.count
			end
		end
		return retItems
	end
	local Record = require("app.models.Record.Record")
	local logData = {}
	beforeItems = mergeItemCountToItemId(beforeItems)
	afterItems = mergeItemCountToItemId(afterItems)
	local itemsFlag={}
	for k, v in pairs(beforeItems) do
		if v ~= afterItems[k] then
			retMap[k] = Helper:getDef(afterItems[k], 0) - v
			Statistics:recordItemCount(k, retMap[k])
			logData[k] = retMap[k]
		end
		itemsFlag[k] = true
	end

	for k, v in pairs(afterItems) do
		if itemsFlag[k] ~= true then
			retMap[k] = v
			Statistics:recordItemCount(k, retMap[k])
			logData[k] = retMap[k]
		end
	end
	Record:addLog(Record.LOG_TYPE.ITEM,logData,"商人交易")
	return retMap
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/08 17:18:08
-- @desc 将物品添加到指定角色身上. 判断物品类型,将其添加到指定列表
function NpcMapBagLayer:addSpecialItemToRole(role, items)
	if MapIsEmpty(role) == true or MapIsEmpty(items) == true then
		return
	end
	local itemAttr, item
	for i = #items, 1, - 1 do -- add by XiaoZhiWei 2017/04/08 17:26:36 必须使用倒序
		item = items[i]
		itemAttr = Item:getOneItemByKey(item.itemId)
		switch(itemAttr.type,
		{
			["秘籍残页"] = function()
				role:addItemCount(item.itemId, item.count)
				table.remove(items, i)
			end
		})
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/25 15:48:14
-- @desc 初始化后调用,创建防修改物品列表
function NpcMapBagLayer:initSafeItem(items)
	for k, v in pairs(items) do
		items[k] = self:createSafeItem(v)
	end
end

-- 统一的购买接口  目前可以购买 商品币种类型（元宝，冥币，美誉，黄金，碎银）
function NpcMapBagLayer:BuyAllItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)

	-- 设置货币单位
	local priceUnit = bagItem.priceUnit
	if priceUnit == nil then
		priceUnit = itemData.priceUnit
		if priceUnit == "" or priceUnit == nil then
			priceUnit = "money"
		end
	end
	local transType = -1  --交易凭证类型  1 元宝类 2 月卡类 3 福缘丹 4 论剑奖励 5 江湖美誉 8 冥币 12 积分 (从服务器获取订单ID)  此处暂时默认-1
	if priceUnit == "deadCurrency" or priceUnit == "mingbi" then
		transType = 8
	elseif priceUnit == "money" or  priceUnit == "meiyu" or  priceUnit == "gold" then
		transType = 5
	elseif priceUnit == "yuanbao" then
		transType = 1
	end
	local price = sellerItems[index].price
	local unitName = currency[priceUnit].name

	local textList = {
		Text_tital = itemData.name,
		Text_type = itemData:getItemShowType(),
		Text_dsc = itemData.dsc,
		Text_price = "售价:"..price..unitName,
		Text_affirm = "确定购买"..itemData.name.."吗？",
		Text_havenum = "已拥有:".. User:getRole():getItemTotalCount(itemData.id)..itemData.unit,
	}

	-- local ShoppingDialogLayer = require("app.views.layer.DialogLayer.ShoppingDialogLayer")
	PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
		layer:showLayer(textList,function()
		end)
		if self:isShowDiscountLayer(self.role2.id) then
			layer:isShowDiscountLayer(true)
		else
			layer:isShowDiscountLayer(false)
		end
		layer:setButton_confirm("确定", function(couponsId)
			TransCheck:setTransWithWebOrderId(function(transId)		
				HttpManagerEx:buyNewNpcChapmanItem(self.role2.baseId, sellerItems[index].itemId,transId,couponsId, function(status, errcode, errmsg, data)
					if status == 200 then
						if DEBUG_MODE == 1 then
							Helper:print_lua_table(data)
						end
						if errcode == 0 then

							if couponsId then
								--扣除优惠券
								User:getRole():addItemCount(couponsId,-1)
								for i = #roleItems,1,-1 do
									if roleItems[i] and roleItems[i].itemId == couponsId then
										self:popItemByIndex(roleItems, i)
										local itemAttr = Item:getOneItemByKey(couponsId)
										PopText("您消耗了 " .. itemAttr.name .. " X1")
										break
									end
								end
							end
							
							TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
							local desc = "你花费了"..data.remove_point..unitName.."购买了" .. tostring(itemData.name)
							PopText(desc)
							
							-- 确认购买成功再放入玩家背包
							if itemData.id == "item201_08" then
							else
								-- self:popItemByIndex(sellerItems, index)
							end
							
							-- 先放入背包，避免玩家直接关闭游戏没有保存元宝购买的道具
							User:getRole():addItemCount(itemData.id, 1,nil,nil,self.logOrigin)
							
							if itemData.type == "书页" or itemData.type == "武学秘宝" or itemData.type == "毒药" or itemData.type == "制药材料" or itemData.type == "秘籍残页" 
								or itemData.type == "淬炼材料" or itemData.type == "锻造材料" then
							else
								self:pushItem(roleItems, bgitemToBuy, weight, "")
							end

							currency[priceUnit].num = currency[priceUnit].num - tonumber(data.remove_point)

							
							self:refreshList2()
							self:setBagList(roleItems)
							-- self:setBagList2(sellerItems)
							self:refreshWeightUI()
							self:setTextMoney(nil, priceUnit)
							
						else
							PopText(errmsg)
						end
						return true
					else
				
						PopText(errmsg)
					end
				end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
			end, itemData.id, 1,transType)
		end)
		layer:setButton_close("取消", function()
		end)
	end)
end

--	刷新商店内容
function NpcMapBagLayer:refreshList2()
	 -- 获取npc商人列表
	 local list = {}
	 HttpManagerEx:getNewNpcChapmanItemList(self.role2.baseId, function(status, errcode, errmsg, data, isEncrypted)
        -- PopText("返回数据 是否有加密  == "..tostring(isEncrypted))
        if isEncrypted == false then
            Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
            return
        end
        if status == 200 then
            if errcode ~= 0 then
            else
                if data then
                    local items = data.list
					if DEBUG_MODE == 1 then
						Helper:print_lua_table(data)
					end
                    for k,v in pairs(items) do
                        print("商人添加道具 again" .. v.itemId,v.unit)
                        -- 添加至商人
                        table.insert( list, { id = User:getRole():getItemOnlyId() , count = 1 , itemId = v.itemId, price = v.price, priceUnit = v.unit } )
                      
                    end
					
					-- -- 刷新显示的货币
                    -- local type = data.unit
                    -- if type then
                    --     if  type == "yuanbao" then
                    --         self:setTextYuanBao(data.point)
                    --     elseif  type == "meiyu" then
                    --         self:setTextMeiYu(data.points)
                    --     elseif  type == "mingbi" or  type == "deadCurrency" then
                    --         self:setTextDeadCurrency(data.point)
                    --     end
					-- end

					sellerItems = {}
					-- 刷新显示的商品
					for i, v in ipairs(list) do
						for j = 1, v.count do
							if addItemById(sellerItems, v.itemId) ~= false then
								-- 添加第一个物品初始化数据
								if j == 1 then
									local tab = clone(v)
									Helper:tableCover(sellerItems[#sellerItems], tab)
									sellerItems[#sellerItems].count = 1
								end
							end
						end
					end
					
					self:setBagList2(sellerItems)
             
                end
            end
        end
    end, IS_SHOW_WAITING)
end

--显示打折页面的npc id
local roleIdList = {
	shuangsytssr1 = true,
	shuangsytssr2 = true,
	shuangsytssr3 = true,
	xcsmsr1 = true,
	xcsmsr2 = true,
	xcsmsr3 = true
}

function NpcMapBagLayer:isShowDiscountLayer(roleId)
	if roleId == nil then
		return false
	end
	if roleIdList[roleId] == true then
		return true
	end

	return false
end


Helper:classDefNodeGetInstance(NpcMapBagLayer)

return NpcMapBagLayer 00000000000000