local NewXianShiLayer = class("NewXianShiLayer", LayerEx)
function NewXianShiLayer:create()
	local p = NewXianShiLayer:new()
	p:init()
	return p
end
function NewXianShiLayer:init()
	local UI = require("Layer/ActionUI/XianShiLiBaoUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)
	-- self:hide()
	self.itemList = {}
	self:setBack()
	-- self:setButton()
	self:setVisible(false)

	-- 更新剩余时间
	self:schedule(
	function(dt)
		self:UpdateTimeAndCount(dt)
	end, 1)
end

function NewXianShiLayer:showLayer(storeItem)
	assert(type(storeItem) == "table" and storeItem.itemId )
	self.storeItem = storeItem
	self:getDateFromWeb(storeItem.itemId)
	-- self:getState()

end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author GaoHanZheng
-- -- @time 2018/01/18 10:25:05
-- -- @desc 退出回调
-- function NewXianShiLayer:setBackCallFunc(func)
-- 	if type(func) == "function" then
-- 		self.backFunc = func
-- 	end
-- end

--退出
function NewXianShiLayer:setBack()
	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("NewXianShiLayer",function(layer)
			local StoreLayer = MainControllLayer:getLayer("StoreLayer")
			StoreLayer:show()
			layer:hide()
		end)
	end)
end 
--服务器获取数据
function NewXianShiLayer:getDateFromWeb(itemId)
	print("--------------------------------------------------:",itemId)
	self.itemList = {
		-- items = {
		-- 	[1] = {
		-- 		itemId = "xiyanshui",
		-- 		imagePath = "Image/UI/StoreUI/xiyanshui.png",
		-- 		count = 10,
		-- 		name = "洗颜水",
		-- 		price = 190
		-- 	},
		-- 	[2] = {
		-- 		itemId = "xiyanshui",
		-- 		imagePath = "Image/UI/StoreUI/xiyanshui.png",
		-- 		count = 5,
		-- 		name = "洗颜水",
		-- 		price = 190
		-- 	},
		-- 	[3] = {
		-- 		itemId = "xiyanshui",
		-- 		imagePath = "Image/UI/StoreUI/xiyanshui.png",
		-- 		count = 5,
		-- 		name = "洗颜水",
		-- 		-- price = 190
		-- 	},
		-- },
		-- totalPrice = 3800,
		-- salePeice = 688,
		-- beyond = 552,
		-- limit = 15,
		-- surplusCount = 12,
		-- surplusTime = GetTime() + 3600,
		-- connection = false
	}

	HttpManagerEx:getXianShiGiftBag(itemId,function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			data = Helper:getDef(data,{})
			Helper:print_lua_table(data)
			self:setItemList(data)
			self.Button_confirm:setEnabled(true)
			self:createPanelList()
			self:setBuyButton(itemId)
			self:setDengMiQuanButton(itemId)
			self:setDiscount()
			self:UpdateTimeAndCount()
			self:show()
		else
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
			-- self:setItemList(data)
			-- self:show()
			-- self.Button_confirm:setEnabled(true)
			-- self:createPanelList()
			-- self:setBuyButton(itemId)
			-- self:setDiscount()
end

function NewXianShiLayer:setDengMiQuanButton(itemId)
	if itemId == "libao218" then
		self.Button_confirm_1:setVisible(true)
		self.Text_Count1:setVisible(true)
	else
		self.Button_confirm_1:setVisible(false)
		self.Text_Count1:setVisible(false)
		return
	end
	
	local role = User:getRole()
	local dengmiquanTimes = role:getFlag("领取灯谜券次数")
	local buyTimes = self.itemList.limit - self.itemList.surplusCount
	print("已经购买次数 = ",buyTimes)
	print("领取灯谜券次数 = ",dengmiquanTimes)

	if buyTimes > dengmiquanTimes then
		self.Button_confirm_1:setEnabled(true)
		local num = (buyTimes - dengmiquanTimes)*10
		self.Text_Count1:setString("剩余可领"..num.."张")
		self.Button_confirm_1:releaseFunc(function()
			local tab = {["2020yxdmq"] = num}
			if role:checkCanBuyTwoOrMoreThings(tab) == false then
				return
			end
			self.Button_confirm_1:setEnabled(false)
			self.Text_Count1:setString("剩余可领0张")
			role:addItemCount("2020yxdmq",num)
			PopText("领取了"..num.."张灯谜券")
			role:setFlag("领取灯谜券次数",buyTimes)
		end)
	else
		self.Button_confirm_1:setEnabled(false)
		self.Text_Count1:setString("剩余可领0张")
	end
end

function NewXianShiLayer:setItemList(list)

	if MapIsEmpty(list) == true then
		assert(nil)
	end
	self.reward = {}
	local tab = {}
	for k,v in pairs(list) do 
		if k == "price" then
			tab.salePeice = tonumber(v)
			tab.totalPrice = math.floor(tonumber(v) * tonumber(list.beyond) / 1000) *10
		elseif k == "limit_num" then
			tab.limit = tonumber(v)
		elseif k == "beyond" then
			tab.beyond = tonumber(v)
		elseif k == "end_time" then
			tab.surplusTime = tonumber(v)
		elseif k == "list" then
			for i,item in pairs(v) do 
				item.count = tonumber(item.number)
				item.number = nil
				item.name = Helper:getDef(Item:getOneItemByKey(item.itemId),{}).name
				self.reward[item.itemId] = item.count
			end
			tab.items = v
		elseif k == "buy_times" then
			tab.surplusCount = tonumber(list["limit_num"]) - tonumber(v)
		elseif k == "special_reward_itemId" then
			--特殊奖励物品
			if v and v ~= "" then
				self.speRewardItemId = v
			end
		end
	end
	tab.connection = false
	self.itemList = tab
	-- Helper:print_lua_table(self.itemList)
end
--
function NewXianShiLayer:setDiscount()
	if MapIsEmpty(self.itemList) == true then
		return
	end
	self.Text_5:setString("活动期间,购买限时礼包后\n可获得超值奖励(限" .. Helper:getDef(self.itemList.limit,0) .. "次)")
	self.Text_Discount:setString("道具超值额度\n" .. Helper:getDef(self.itemList.beyond,0) .. "%")
	self.Button_confirm_0.Text_confirmName:setString("原价" .. Helper:getDef(self.itemList.totalPrice,0) .. "元宝")
end
--设置活动剩余时间
function NewXianShiLayer:UpdateTimeAndCount(dt)
	if self.itemList == nil or self.itemList.surplusTime == nil then
		return
	end
	local overTime = self.itemList.surplusTime
	local currTime = GetTime()
	if currTime >= overTime then
		if self.itemList.connection == true then
			self.Button_confirm:setEnabled(false)
			self:getDateFromWeb()
		else
			self.Text_Time:setString("活动已经结束")
			-- self.Text_Count:setString("剩余0个")
			-- self.itemList.surplusCount = 0
			-- self.Text_Count:setString("")
			self.expiration = true
		end
	else
		local year, month, day, hour, minute, second = Helper:getExpiredTime(overTime, currTime)
		if month ~= 0 then
			self.Text_Time:setString(month .. "月" .. day .. "天" .. hour .. "小时" .. minute .. "分" .. second .. "秒")
		else
			self.Text_Time:setString(day .. "天" .. hour .. "小时" .. minute .. "分" .. second .. "秒")
		end

		self.Text_Count:setString("剩余" .. self.itemList.surplusCount .. "个")
	end
end
--创建物品列表
function NewXianShiLayer:createPanelList()
	if MapIsEmpty(self.itemList) == true then
		return 
	end
	if MapIsEmpty(self.itemList.items) == true then
		return
	end
	self.ListView_titlelistArea:removeAllItems()
	local panen_streamer = nil
	for k,v in pairs(self.itemList.items) do 
		local panel = self:createPanel(v)
		if k % 2 == 1 then
			panen_streamer = self.Panel_Item_0:clone()
			panel:addTo(panen_streamer)
			panel:setPosition(20,115)
			self.ListView_titlelistArea:pushBackCustomItem(panen_streamer)
		else
			panel:addTo(panen_streamer)
			panel:setPosition(560,115)
		end
	end
end

local specialItems = {
	["yuhuiling"] = "八方游侠"
}
local specialLibao = {
	["libao267"] = true
}
local function specialItemsFun(itemId)
	local itemsText={
		["yuhuiling"] = "八方游侠时间增加14天"
	}
	PopText(itemsText[itemId])
end

--创建物品展示
function NewXianShiLayer:createPanel(item)
	if MapIsEmpty(item) == true then
		return
	end
	if item.itemId == nil or item.imagePath == nil or item.count == nil then
		print(item.itemId,item.imagePath,item.count)
		return
	end
	local itemAttr = User:getRole():getOneItemByKey(item.itemId)
	--特殊道具特殊处理
	if specialItems[item.itemId] then 
		itemAttr = item
		itemAttr.name = specialItems[item.itemId]
	end

	if itemAttr == nil then
		assert(nil,"资源中找不到"..item.itemId..",请策划检查资源")
	end
	local panel = self.Panel_item_1_0:clone()
	Helper:convertUIByParent(panel)
	local textColor = cc.c4b(255, 255, 255, 255)
	local outlineColor = cc.c4b(0, 0, 0, 255)
	local function initPanel(itemData,item, panel)
		local textColor = cc.c4b(255, 255, 255, 255)
		local outlineColor = cc.c4b(0, 0, 0, 255)

		panel:setVisible(true)
		panel.Text_name:setString(itemData.name)
		panel.Text_num:setString("X" .. item.count)

		panel.Text_name:setColor(textColor)
		panel.Text_num:setColor(textColor)

		panel.Text_name:enableOutline(outlineColor, 5)
		panel.Text_num:enableOutline(outlineColor, 5)

		panel.Image_zhuzi:loadTexture(item.imagePath)
	end
	panel:setVisible(true)
	initPanel(itemAttr,item,panel)
	return panel
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/22 12:03:42
-- @desc 特殊购买条件判断
function NewXianShiLayer:checkCanBuy()
	local condition = {
		["familyName"] = function()
			return User:getRole():getFamilyName()
		end,
		["age"] = function()
			return User:getRole():getAge()
		end,
	}
	
	--礼包最终奖励 也需要判断背包
	if self.itemList.surplusCount == 1 then
		local id = self.speRewardItemId
		if id then
			self.reward[id] = 1
		end
	end
	--特殊礼包处理 八方游侠
	if specialLibao[self.storeItem.itemId] then
		for k,v in pairs(self.reward) do 
			if specialItems[k] then 
				self.reward[k] = nil
			end
		end
	end


	local result = true
	if self.expiration == true then
		PopText("该礼包已经下架")
		result = false
	elseif self.itemList.surplusCount <= 0 then
		PopText("礼包已经卖完了")
		result = false
		self.Button_confirm:setEnabled(true)
	elseif #self.itemList.items == 0 then
		PopText("购买失败")
		result = false
		self.Button_confirm:setEnabled(true)
	elseif User:getRole():checkCanBuyTwoOrMoreThings(self.reward) ~= true then
		-- PopText("背包空间不足")
		result = false
		self.Button_confirm:setEnabled(true)
	else
		if self.storeItem ~= nil and type(self.storeItem.client_exp) == "table" then
			for k,v in ipairs(self.storeItem.client_exp) do 
				assert(v.field and v.v1 and v.op and v.dsc)
				if condition[v.field] then
					local userValue = condition[v.field]()
					if v.op == "=" then
						if userValue ~= tonumber(v.v1) then
							PopText(v.dsc)
							result = false
						end
					elseif v.op == ">" then
						if userValue > tonumber(v.v1) then
						else
							PopText(v.dsc)
							result = false
						end	
					elseif v.op == "<" then
						if userValue < tonumber(v.v1) then
						else
							PopText(v.dsc)
							result = false
						end	
					elseif v.op == "between" then
						if userValue > tonumber(v.v2) or userValue < tonumber(v.v1) then
							PopText(v.dsc)
							result = false
						end
					end
				end
			end
		end
		self.Button_confirm:setEnabled(true)
		return result
	end
end


--购买按钮设置
function NewXianShiLayer:setBuyButton(itemId)
	self.itemList.salePeice = Helper:getDef(self.itemList.salePeice,688)
	self.itemList.surplusCount = Helper:getDef(self.itemList.surplusCount,0)
	self.Button_confirm.Text_confirmName:setString(tostring(self.itemList.salePeice).."元宝")
	self.Text_Count:setString("剩余"..tostring(self.itemList.surplusCount).."个")
	self.Button_confirm:releaseFunc(function()
		self.Button_confirm:setEnabled(false)
		if not self:checkCanBuy() then
			return
		else
			PopYuanBaoBuyItemLayer(itemId, function(eventType, reward)
                if eventType == "success" then
                	Helper:print_lua_table(self.itemList.items)
                	for i,v in ipairs(self.itemList.items) do
                		if specialItems[v.itemId] then 
                			specialItemsFun(v.itemId)
                		else
	                		User:getRole():addItemCount(v.itemId, v.count,nil,nil,"限时购买")
	                		PopText("获得 " .. v.name .. " X" .. v.count)
	                	end
                	end

					if itemId == "chefugift001" then
						local chefuitem = User:getRole():getItem("chefuitem004")
						if chefuitem then
							User:getRole():addItemCount("chefuitem004", -1)
							PopText("消耗一张车行徽记")
						end
					end
					self.itemList.surplusCount = self.itemList.surplusCount - 1
					if not MapIsEmpty(reward) then
						local itemAttr = Item:getOneItemByKey(reward.itemId)
						if itemAttr then
							User:getRole():addItemCount(reward.itemId,1)
							if reward.awardtext then
								PopText(reward.awardtext)
							end
						end
					end

					self:setDengMiQuanButton(itemId)
                end
                self.Button_confirm:setEnabled(true)
            end,{isOpenPay = true})
		end
	end)
end
--[[
	礼包内容  物品的ItemId , 数量  , 图片路径 , 价格 
	礼包原价,玩家购买价格,折扣,限购个数，优惠额度,剩余个数,当前礼包的结束时间，
]]
Helper:classDefNodeGetInstance(NewXianShiLayer)

return NewXianShiLayer00000