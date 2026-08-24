local PayLayer = require("app.views.layer.StoreLayer.PayLayer")

local StoreLayer = class("StoreLayer", cc.Layer)

local StoreGoodsType = {
	Net_NotBatchBuy_Goods = 13,--非批量购买类网络物品
}

function StoreLayer:create()
	local p = StoreLayer:new()
	p:init()
	return p
end

function StoreLayer:init()
	local UI = require("Layer/StoreUI/StoreUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUI(self)

	self.actionBackFunc = nil -- 配合活动界面使用,存回调函数

	self:setTextPay()
	self:setButtonBack()
	self.Panel_item:setVisible(false)
	self.Panel_row:setVisible(false)
	self.Panel_type:setVisible(false)
	self.ListView_type:setScrollBarEnabled(false)
	self.goodsType=2

	self:schedule(function(ft)
		self.Text_count:setString("我的元宝："..User:getRoleAttr("yuanbao"))
	end,1)

	self:setVisible(false)
	self.Text_qun:setString("官方客服："..Game:getKFQQ())
	if Game:isOpenKFQQ() == true or Game:isCheckNewPackage() == NEED_CHECK_AND_IS_OPEN then
		self.Text_qun:setVisible(false)
	end

	self:refreshYueKaHongDian()
end

function StoreLayer:show(goodsType)
	Game:updatePayInfo() -- 更新支付信息
	self:refreshYueKaHongDian()
	self:refreshStoreList("",goodsType)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 16:40:07
-- @desc 新入口 ,配合活动界面使用 弹出形式
function StoreLayer:showWithAction(func)
	Game:updatePayInfo() -- 更新支付信息
	self:refreshStoreList(function()
		self:setVisible(true)
	end)
	self:refreshYueKaHongDian()
	self.actionBackFunc = func
end
--返回时刷新界面并显示活动按钮
function StoreLayer:showWithShowAction(tag,func)
	Game:updatePayInfo() -- 更新支付信息
	self:refreshStoreList(function()
		self:setVisible(true)
	end)
	self:refreshYueKaHongDian()
	self.actionBackFunc = func
end
-- 刷新列表
function StoreLayer:refreshStoreList(func,goodsType)
	--NEEDTODO 具体数据填充
	TransCheck:checkAllTrans(function()
		-- 获取元宝数量
		-- HttpManagerEx:getYuanBao(function(status, errcode, errmsg, data)
		-- 	if 1 == PRINT_MODE then
		-- 		print("status ="..status)
		-- 		print("errcode ="..tostring(errcode))
		-- 	end
		-- 	if status == 200 then
		-- 		if errcode == 0 then
		-- 			User:setRoleAttr("yuanbao", data.yuanbao)
		-- 			self.Text_count:setString(data.yuanbao)
					-- 获取商城列表
					HttpManagerEx:getStoreData(function(status, errcode, errmsg, data, isEncrypted)
						-- PopText("返回数据 是否有加密  == "..tostring(isEncrypted))
						if isEncrypted == false then
							PopText("数据异常，请不要使用第三方工具进行游戏。")
							Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
							return
						end
						if status == 200 then
							if errcode ~= 0 then
								PopText(errmsg)
								self:hide()
								return
							else
								local list = {}
								if data.status == "OPEN" and data.list then
									list = data.list
								else
									self:hide()
									return
								end

								User:setRoleAttr("yuanbao", data.yuanbao)
								self.Text_count:setString("我的元宝："..data.yuanbao)

								do
									--保存双十一限时显示的标识,控制显示
									if data.eleven then
										self.Image_timeLimitAccelerate:setVisible(true)
										self.Image_timeLimitAccelerate_1:setVisible(true)
									else
										self.Image_timeLimitAccelerate:setVisible(false)
										self.Image_timeLimitAccelerate_1:setVisible(false)
									end
								end

								-- 设置列表数据
								if not goodsType then 
								else
									self.goodsType=tonumber(goodsType)
								end
								if list[self.goodsType]["items"]~=nil and type(list[self.goodsType]["items"])=="table" then
									self:setViewList(list[self.goodsType]["items"])
								end

								self:createOneType(list)

								self:setPanelMingShi(data.yueka_expired_time)
								self:setButtonYaShi(data.yashi_expired_time, data.yashi_welfare_point)

								User:getRole():setViewingHallPrivilegeExpiredTime(data.privilege_expired_time)
								User:getRole():setViewingHallPrivilegeRemainingWatches(data.privilege_remaining_watches)

								self:setPanelViewingHall()

								if func and type(func)=="function" then
									func()
								end
								
								if MainControllLayer ~= nil and MainControllLayer:getCurrLayer() ~= "StoreLayer" then
									MainControllLayer:pushLayer("StoreLayer")
								else
								end
							end
						else
							PopText("网络异常,无法查看商城界面")
						end
					end, IS_SHOW_WAITING)
		-- 		else
		-- 			if type(errmsg) == "string" then
		-- 				PopText(errmsg)
		-- 			end
		-- 		end
		-- 	else
		-- 		self:hide()
		-- 	end
		-- end, IS_SHOW_WAITING)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/14 15:12:21
-- @desc 刷新元宝数量

function StoreLayer:refreshYuanBaoNumber()
	HttpManagerEx:getYuanBao(function(status, errcode, errmsg, data)
		if 1 == PRINT_MODE then
			print("status ="..status)
			print("errcode ="..tostring(errcode))
		end
		if status == 200 and errcode == 0 then
			self.Text_count:setString("我的元宝："..data.yuanbao)
			User:setRoleAttr("yuanbao", data.yuanbao)
		end
	end)
end

function StoreLayer:hide()
	if MainControllLayer ~= nil then
		MainControllLayer:popLayer(nil, "StoreLayer")
	else
		self:setVisible(false)
	end

	-- 配合活动界面使用,回调函数
	if self.actionBackFunc ~= nil then
		self.actionBackFunc()
	end
	--清除缓存的回调函数
	self.actionBackFunc = nil
	-- self:setVisible(false)
end

function StoreLayer:setTextPay()
	if GameChannelContext:isOpenPay() == false then
		self.Panel_4:setVisible(false)
		return
	end

	self.Panel_4:releaseFunc(function()
		Game:openPayLayer(function()
			PopupLayerController:showLayer("PayLayer", function(layer)
				layer:show()
			end)
		end)
		-- if Game:getChannelId() == "shoutan" then
		-- 	return
		-- end
		
		-- if device.platform == "android" then
		-- 	if Game:getChannelId() == "huawei" or Game:getChannelId() == "oppo" or Game:getChannelId() == "yyb" then
		-- 		PopupLayerController:showLayer("PayLayer", function(layer)
		-- 			layer:show()
		-- 		end)
		-- 		return
		-- 	else
		-- 	end
		-- 	-----------------------------------------------------------------------------------------------------------
		-- 	-- @author XiaoZhiWei
		-- 	-- @time 2017/02/21 09:45:42
		-- 	-- @desc  判断是否绑定邮箱
		-- 	Account:getEmail(
		-- 	function(eventName, errmsg, email, isBind, isLogout)
		-- 		if eventName == "有邮箱" then
		-- 			-- isBind 为true的时候 才是已绑定邮箱
		-- 			if isBind == true then
		-- 				PopupLayerController:showLayer("PayLayer", function(layer)
		-- 					layer:show()
		-- 				end)
		-- 				return
		-- 			else
		-- 			end
		-- 		elseif eventName == "找不到帐号" then
		-- 		elseif eventName == "无邮箱" then
		-- 		else
		-- 		end
		-- 		PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
		-- 	end)
		-- elseif device.platform == "ios" then
		-- 	PopupLayerController:showLayer("PayLayer", function(layer)
		-- 		layer:show()
		-- 	end)
    	-- elseif device.platform == "windows" then
		-- 	PopupLayerController:showLayer("PayLayer", function(layer)
		-- 		layer:show()
		-- 	end)
		-- else
		-- end
	end)
end

function StoreLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		self:hide()
	end)
end

function StoreLayer:setButtonBack()
	self.Button_back:releaseFunc(function()
		-- MainControllLayer:popLayer()
		self:hide()
	end)
end

--江湖名士奖励红点
function StoreLayer:refreshYueKaHongDian()
	local role = User:getRole()
	if role:yueKaIsValid()==true and role:getDayFlag("yueKa_reward") == 0 then 
		self.Image_hongdian_mingshi:setVisible(true)
	else
		self.Image_hongdian_mingshi:setVisible(false)
	end
end


-- 检查是否能够购买商品
function StoreLayer:checkCanBuyGoods(storeItem)
	local role = User:getRole()

	
	if storeItem.itype == 11 then
		local m_volmues = {
			volume_3 = "volume_2",
			volume_4 = "volume_3",
			volume_5 = "volume_4",
			volume_6 = "volume_2",
			volume_7 = "volume_6",
		}

		if m_volmues[storeItem.itemId] ~= nil then
			local roleVolume = role:getAttr("m_volume")

			if roleVolume[m_volmues[storeItem.itemId]] ~= true then
				local item = role:getOneItemByKey(m_volmues[storeItem.itemId])
				PopText("请购买"..item.name.."后再购买此商品")
				return false
			end
		end
		
	end

	if storeItem.itype == 12 then
		return true
	end

	if storeItem.itype == StoreGoodsType.Net_NotBatchBuy_Goods then
		return true
	end

	--包月分身符 原关卡 itype 1 
	if storeItem.itype ~= 11 and storeItem.itype ~= 1 and not role:checkCanBuyThings(storeItem.itemId, tonumber(storeItem.number)) then
		-- PopText("背包已满，请清理后再购买")
		return false
	end

	-- local m_voloum = role:getAttr("m_volume")
	-- local startIndex = string.find(storeItem.itemId,"fuben")
	-- if startIndex ~= nil and storeItem.itemId ~= "fuben11-20" and m_voloum["volume_2"] ~= true then
	-- 	PopText("请购买前面章节后再购买此商品")
	-- 	return false
	-- end

	-- if (storeItem.itemId == "fuben21-30" and role:getNumAttr("guanqiaLimit") < 20) or (storeItem.itemId == "fuben31-35" and role:getNumAttr("guanqiaLimit") < 30) or (storeItem.itemId == "fuben36-40" and role:getNumAttr("guanqiaLimit") < 35) then
	-- 	PopText("请购买前面章节后再购买此商品")
	-- 	return false
	-- end

	if storeItem.itemId == "guanfugongwen" then
		local itemList = role:getItemsWithItemId(storeItem.itemId)
		local itemCkList = role:getItemsWithItemIdck(storeItem.itemId)
		if MapIsEmpty(itemList) == false or MapIsEmpty(itemCkList) == false then
			PopText("你已经拥有该物品了")
			return false
		end
	end

	return true
end

-- 成功购买商品后处理
function StoreLayer:aftreBuyGoodsSuccess(storeItem)
	if storeItem == nil then
		return nil
	end
	local role = User:getRole()

	if storeItem.itype == 1 then
		role:addAttr("guanqiaLimit", storeItem.number)
		PopText("成功购买"..tostring(storeItem.name).. " X " ..tostring(1))
	elseif storeItem.itype == 11 then
		--@desc 关卡购买
		local m_volume = role:getAttr("m_volume")
		
		m_volume[storeItem.itemId] = true

		PopText("成功购买"..tostring(storeItem.name).. " X " ..tostring(1))
	elseif storeItem.itype == 12 then --神功虚拟物品
		PopText("成功购买"..tostring(storeItem.name).. " X " ..tostring(storeItem.number))
	elseif storeItem.itype == StoreGoodsType.Net_NotBatchBuy_Goods then
		PopText("成功购买"..tostring(storeItem.name).. " X " ..tostring(storeItem.number))
	else
		PopText("成功购买"..tostring(storeItem.name).. " X " ..tostring(storeItem.number))
		if storeItem.itype == 2 then
			-- 购买成功后直接使用 类型
			local item = Item:getOneItemByKey(storeItem.itemId)
			if item ~= nil then
				item:itemUseDescShow()
			end
		elseif storeItem.itemId == "byfenshenfu" then
			-- 包月分身符
			--@TODO 2019-01-08 17:28:01 没有用到？
			role:updateMonthFenShenFuStatus(GetTime() + 100)
		elseif storeItem.itemId == "shuye93" or storeItem.itemId == "changshengjueshengji2" or storeItem.itemId == "changshengjueshengji3" or storeItem.itemId == "changshengjueshengji4" or storeItem.itemId == "changshengjueshengji5" then
			role:setInheritFlag("item_"..storeItem.itemId, false)
			role:addItemCount(storeItem.itemId, tonumber(storeItem.number))
		else
			role:addItemCount(storeItem.itemId, tonumber(storeItem.number),nil,nil,"商城购买")
		end
	end
	self.Panel_Item_Number:setVisible(false)
end

-- 更新玩家身上商品的状态
function StoreLayer:updateItemStatus(storeItem)
	if storeItem == nil then
		return nil
	end
	local role = User:getRole()

	-- 包月分身符
	if storeItem.itemId == "byfenshenfu" then
		role:updateMonthFenShenFuStatus(storeItem.expired_time)
	end
end

local dis_img_path = {
	["0.9"] = "Image/UI/StoreUI/jiuzhe.png",
	["0.8"] = "Image/UI/StoreUI/bazhe.png",
	["0.6"] = "Image/UI/StoreUI/liuzhe.png",
	default = "Image/UI/StoreUI/jiuzhe.png"
}

--特殊物品 包月分身符 掌门令 御汇令
local specialItem = {
	["byfenshenfu"] = true,
	["shimenbuff1"] = true,
	["yuhuiling"] = true,
}

-- 创建一个 商品显示栏目
function StoreLayer:createPanelItem(storeItem)
	if not storeItem or type(storeItem) ~= "table" then
		return
	end
	--  更新玩家身上的商品状态  例： 包月分身斧
	self:updateItemStatus(storeItem)

	local item = self.Panel_item:clone()
	Helper:convertUI(item)
	item.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	item.Text_num:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	item.Image_zhuzi:loadTexture(storeItem.icon,0)

	local itemName = self:__getGoodsShowName(storeItem)
	item.Text_name:setString(itemName)
	item.Text_num:setString(storeItem.price)
	item:setVisible(true)

	---双十一活动  限时显示处理
	do
		if  storeItem.eleven ~= nil then
			item.Image_timeLimitShop:setVisible(true)
		else
			item.Image_timeLimitShop:setVisible(false)
		end
	end

	---春节打八折活动  限时显示处理
	do
		if  storeItem.discount ~= nil then
			local img_path = switch(tostring(storeItem.discount),dis_img_path)
			item.Image_DaZhe:loadTexture(img_path,0)
			item.Image_DaZhe:setVisible(true)
		else
			item.Image_DaZhe:setVisible(false)
		end
	end
	
	do  --特殊道具 购买边框效果与置顶
		if storeItem.expired_time and specialItem[storeItem.itemId] then 
			item.Image_item:loadTexture("Image/UI/StoreUI/sc033.png")
		end
	end

	local status = true
	-- 特殊的显示处理
	do
		local poptext = "你已购买该商品，无需再次购买。"
		-- 包月分身符处理
		if storeItem.expired_time ~= nil and (specialItem[storeItem.itemId] or storeItem.itemId == "buchang" or storeItem.itemId == "yiheyuebing") and storeItem.expired_time > GetTime() + 60 then
			local year, month, day, hour, minute, second = Helper:getExpiredTime(storeItem.expired_time, GetTime())
			day = 12 * 30 * year + month * 30 + day
			if storeItem.itemId == "buchang" or storeItem.itemId == "yiheyuebing" then
				status = true
			elseif specialItem[storeItem.itemId] and day > 182 then 
				day = 182
				hour = 23
				status = false
			end
			local desc = tostring(day).."天 "..tostring(hour).."小时"
			item.Text_num:setString(desc)
		end

		-- 关卡已购处理
		local goods = Item:getOneItemByKey(storeItem.itemId)
		local role = User:getRole()

		if goods and string.find(goods.id,"volume_") then
			local m_volume = role:getAttr("m_volume")
			if m_volume[goods.id] == true then
				item.Image_IsBuy:setVisible(true)
				status = false
			end
		end
		
		if goods and goods.seeCondition and goods.seeValue and role:getNumAttr(goods.seeCondition) > tonumber(goods.seeValue) then
			item.Image_IsBuy:setVisible(true)
			status = false
		end

		if status == false then
			item:releaseFunc(function()
				PopText(poptext)
			end)
		end
	end

	if status == true then
		item:releaseFunc(function()
			if not self:checkCanBy(storeItem) then
				return
			end


			if storeItem.itemId == "xianshilibao" then
				PopupLayerController:showLayer("NewXianShiLayer",function(layer)
					layer:showLayer(storeItem)
				end)
			elseif tonumber(storeItem.itype) == 100 then
				PopupLayerController:showLayer("NewXianShiLayer",function(layer)
					layer:showLayer(storeItem)
				end)
			elseif storeItem.itemId == "jianghukuanghuan1" then
				local currTime = GetTime()
				local yuanxiaoTime = Helper:getTimeStampWithStringDate("20170212",0)

				-- 根据时间判断春节与元宵限时礼包
				local XianShiLayer = require("app.views.layer.ActionLayer.KuangHuanLayer")
				XianShiLayer:getInstance():getState("kuanghuanlibao")
				XianShiLayer:getInstance():show()
			elseif storeItem.itype == 10 or storeItem.itype == 12 then
				self:showItemBuyNumberPanel(storeItem)
			elseif storeItem.itype == StoreGoodsType.Net_NotBatchBuy_Goods then
				self:__buyNetNotBatchBuyTypeGoods(storeItem)
			elseif self:checkCanBuyGoods(storeItem) == true then
				YuanBaoPayLayer.buyStoreItem(storeItem.id, storeItem.itemId, function(eventType)
					if eventType == "success" then
						self:aftreBuyGoodsSuccess(storeItem)
					end
					self:show(self.goodsType)
				end,1,{isOpenPay = true})
			end
		end)
	end
	return item
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/22 15:41:49
-- @desc 增加购买限制判断
function StoreLayer:checkCanBy(storeItem)
	local condition = {
		["familyName"] = function()
			return User:getRole():getFamilyName()
		end,
		["age"] = function()
			return User:getRole():getAge()
		end,
	}
	local result,text = true,""
	if PRINT_MODE==1 then 
		Helper:print_lua_table(storeItem.client_exp)
	end
	if not MapIsEmpty(storeItem.client_exp) then
		for k,v in pairs(storeItem.client_exp) do 
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
					elseif v.op == "!=" then
						if userValue == tonumber(v.v1) then
							PopText(v.dsc)
							result = false
						end
					elseif v.op == ">=" then
						if userValue < tonumber(v.v1) then
							PopText(v.dsc)
							result = false
						end
					elseif v.op == "<=" then
						if userValue > tonumber(v.v1) then
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
	return result
end


-- 创建一行 商品显示栏目
function StoreLayer:createOneRow(params)
	if not params or type(params) ~= "table" then
		return
	end
	local row = self.Panel_row:clone()
	for i,v in ipairs(params) do
		local item = self:createPanelItem(v)
		if item then
			row:addChild(item)
			item:move(500, 0)
			if i == 1 then
				item:move(cc.p(0, 0))
			end
		end
	end
	row:setVisible(true)
	return row
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/07/13 10:38:33
-- @desc 排序
function StoreLayer:sortItemList(list)
	list = Helper:getDef(list,{})

	local role = User:getRole()

	local m_volume = role:getAttr("m_volume")
	local tab = {}
	-- local number = 0
	--expired_time  包月分身符、掌门令、御汇令特有
	for i=1,#list do 
		list[i].sortIndex = i
	end
	table.sort(list,function(a,b)
		if a.expired_time and b.expired_time then 
			if  a.expired_time > b.expired_time then 
				return true
			else
				return false
			end
		end

		if a.expired_time then 
			return true
		elseif b.expired_time then 
			return false
		elseif a.sortIndex < b.sortIndex then 
			return true
		else
			return false
		end
		
	end)
	
	for i=#list,1,-1 do 
		if list[i].itype == 11 and list[i].itemId ~= "byfenshenfu" then
			if list[i].itemId == "volume_2" and m_volume["volume_2"] == true then
				table.insert(tab,list[i])
				table.remove(list,i)
			elseif list[i].itemId == "volume_3" and m_volume["volume_3"] == true then
				table.insert(tab,list[i])
				table.remove(list,i)
			elseif list[i].itemId == "volume_4" and m_volume["volume_4"] == true then
				table.insert(tab,list[i])
				table.remove(list,i)
			elseif list[i].itemId == "volume_5" and m_volume["volume_5"] == true then
				table.insert(tab,list[i])
				table.remove(list,i)
			elseif list[i].itemId == "volume_6" and m_volume["volume_6"] == true then
				table.insert(tab,list[i])
				table.remove(list,i)
			elseif list[i].itemId == "volume_7" and m_volume["volume_7"] == true then
				table.insert(tab,list[i])
				table.remove(list,i)
			end
		end

	end
	for i=#tab,1,-1 do 
		table.insert(list,tab[i])
	end

	return list
end


function StoreLayer:setViewList(list)
	if not list or type(list) ~= "table" then
		print("setviewlist error")
		return
	end
	if PRINT_MODE ==1 then 
		Helper:print_lua_table(list)
	end
	list = self:sortItemList(list)
	local tab = {}
	self.ListView_list:removeAllItems()
	local index = 0
	for i,v in ipairs(list) do
		table.insert(tab, v)
		index = index + 1
		if math.mod(index, 2) == 0 then
			local row = self:createOneRow(tab)
			self.ListView_list:pushBackCustomItem(row)
			tab = {}
		elseif i == table.getn(list) then
			local row = self:createPanelItem(v)
			self.ListView_list:pushBackCustomItem(row)
		end
	end
end

-- 江湖名士列表
function StoreLayer:setPanelMingShi(expiredTime)
	if expiredTime == nil or expiredTime <= 0 then
		expiredTime = GetTime()
	end

	-- 计算剩余天数文本
	do
		local leftTime = expiredTime - GetTime()
		local leftDesc = ""
		if leftTime > 60 then
			local day = math.floor( leftTime / (3600 * 24))
			local hours = math.floor((leftTime / 3600) % 24)
			leftDesc = tostring(day).."天 "..tostring(hours).." 小时"
		else
			leftDesc = "未获得该身份"
		end
		self.Text_left_time:setString(leftDesc)	
	end
	User:getRole():updateYueKaStatus(expiredTime)

	self.Button_mingshi:setVisible(true)
	self.Button_mingshi:releaseFunc(function()
		if device.platform == "android" then
			-----------------------------------------------------------------------------------------------------------
			-- @author XiaoZhiWei
			-- @time 2017/02/21 09:45:42
			-- @desc  判断是否绑定邮箱
			Account:getEmail(
			function(eventName, errmsg, email, isBind, isLogout)
				if eventName == "有邮箱" then
					-- isBind 为true的时候 才是已绑定邮箱
					if isBind == true then
						PopupLayerController:showLayer("YueKaLayer", function(layer)
							layer:show(self)
						end)
						return
					else
					end
				elseif eventName == "找不到帐号" then
				elseif eventName == "无邮箱" then
				else
				end
				PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
			end)
		elseif device.platform == "ios" then
			PopupLayerController:showLayer("YueKaLayer", function(layer)
				layer:show(self)
			end)
		elseif device.platform == "windows" then
			PopupLayerController:showLayer("YueKaLayer", function(layer)
				layer:show(self)
			end)
		else
		end
	end)
end

function StoreLayer:setButtonYaShi(expired_time, exchangeCount)
	if expired_time == nil or expired_time <= 0 then
		expired_time = GetTime()
	end

	local YaShiBenefit = require("app.models.YaShiBenefit.YaShiBenefit")
	local canExchange = exchangeCount > 0
	YaShiBenefit:setCanExchange(canExchange)

	self:refreshYaShiHongDian(canExchange)

	-- 计算剩余天数文本
	do
		local rightTime = expired_time - GetTime()
		local rightDesc = ""
		if rightTime > 60 then
			local day = math.floor( rightTime / (3600 * 24))
			local hours = math.floor((rightTime / 3600) % 24)
			rightDesc = tostring(day).."天 "..tostring(hours).." 小时"
		else
			rightDesc = "未获得该身份"
		end
		self.Text_yashi_time:setString(rightDesc)
		User:getRole():updateYaShiStatus(expired_time)
	end

	local callback = function()
		self:refreshStoreList()
	end

	self.Button_yaShi:setVisible(true)
	self.Button_yaShi:releaseFunc(function()
		if device.platform == "android" then
			Account:getEmail(
			function(eventName, errmsg, email, isBind, isLogout)
				if eventName == "有邮箱" then
					if isBind == true then
						PopupLayerController:showLayer("YaShiLayer", function(layer)
							layer:show(expired_time, exchangeCount, callback)
						end)
						return
					else
					end
				elseif eventName == "找不到帐号" then
				elseif eventName == "无邮箱" then
				else
				end
				PopText("请先返回主界面，并点击右上角设置，绑定您的邮箱")
			end)
		elseif device.platform == "ios" then
			PopupLayerController:showLayer("YaShiLayer", function(layer)
				layer:show(expired_time, exchangeCount, callback)
			end)
		else
			PopupLayerController:showLayer("YaShiLayer", function(layer)
				layer:show(expired_time, exchangeCount, callback)
			end)
		end
	end)
end

function StoreLayer:onResume()
	-- self:refreshStoreList()
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/07/12 16:52:13
-- @desc 显示购买数量选择UI
function StoreLayer:showItemBuyNumberPanel(storeItem)
	self.Panel_Item_Number:setVisible(true)
	self.Panel_Item_Number:releaseFunc(function()
		self.Panel_Item_Number:setVisible(false)
	end)
	self.Text_5:setString("您要购买多少"..storeItem.name.."？")

	local buyItemsFunc = function (num)
		num = Helper:getDef(num,1)
		storeItem.number = num
		if 	self:checkCanBuyGoods(storeItem) == true then
			YuanBaoPayLayer.buyStoreItem(storeItem.id, storeItem.itemId, function(eventType)
				if eventType == "success" then
					self:aftreBuyGoodsSuccess(storeItem)
				end
				self.Panel_Item_Number:setVisible(false)
				self:show()
			end,num,{isOpenPay = true})
		end
	end

	self.Button_num1:releaseFunc(function()
		buyItemsFunc(1)
	end)
	self.Button_num2:releaseFunc(function()
		buyItemsFunc(10)
	end)
	self.Button_num3:releaseFunc(function()
		buyItemsFunc(99)
	end)
end

-- 创建类别标签

function StoreLayer:createOneType(list)
	if not list or type(list) ~= "table" then
		return
	end

	local selfCreatedSkillSystem = User:getRole():getSelfCreatedSkillSystem()
	local isOpen = selfCreatedSkillSystem:isOpenSystem()

	if MapIsEmpty(list) == false then
		for k,storeList in ipairs(list) do
			if storeList["name"] == "神功" then
				if isOpen ~= true then
					list[k] = nil
				end
			end
		end
	end

	local goodsTabelIndex={"限时","商城","关卡","神功"}
	self.ListView_type:removeAllItems()
	
	if isOpen == false then
		self.ListView_type:setItemsMargin(140)
	else
		self.ListView_type:setItemsMargin(20)
	end
	
	for i,v in ipairs(list) do
		if not v then 
		else
			local table=v
			if not table or type(table) ~= "table" then
			else
				if table["name"] then
					local item = self:createPanelTypeItem(table["name"])
					if item then
						if goodsTabelIndex[self.goodsType]==table["name"] then
							item.Text_type:setColor(cc.c3b(255, 239, 57))
							item.Image_4:setVisible(true)
							item:setBackGroundColorOpacity(255)
							item:setTouchEnabled(false)
							-- item:move(100,0)
						end
						item:setVisible(true)
						self.ListView_type:pushBackCustomItem(item)
					end
					local itemsList=table["items"]
					item:releaseFunc(function ()
						if not itemsList or type(itemsList) ~= "table" then
						else
							self.goodsType=i
							local layoutList=self.ListView_type:getItems()
							for i=1,#layoutList do
								local item1=layoutList[i]
								item1.Text_type:setColor(cc.c3b(255, 255, 255))
								item1.Image_4:setVisible(false)
								item1:setBackGroundColorOpacity(0)
								item1:setTouchEnabled(true)
							end
							if item.Text_type:getString()==table["name"] then 
								item.Text_type:setColor(cc.c3b(255, 239, 57))
								item.Image_4:setVisible(true)
								self:showGoodsItem(itemsList)
								item:setBackGroundColorOpacity(255)
								item:setTouchEnabled(false)
							end
						end

					end)
				end
			end	
		end
	end
	self.ListView_type:setVisible(true)
end

-- 创建一个 商品类别栏目

function StoreLayer:createPanelTypeItem(itemName)
	if not itemName then
		return 
	end
	local item = self.Panel_type:clone()
	Helper:convertUI(item)
	item.Text_type:setString(itemName)
	return item
end

--显示商品

function StoreLayer:showGoodsItem(list)
	if list==nil or type(list)~="table" then 
		return 
	end
	self:setViewList(list)
end

function StoreLayer:refreshGuanYingTangHongDian()
	self.Image_hongdian_guanyingtang:setVisible(User:getRole():isShowViewingHallHongDian())
end

function StoreLayer:refreshYaShiHongDian(isVisible)
	self.Image_hongdian_yashi:setVisible(isVisible)
end

--类型13，网络物品非批量购买
function StoreLayer:__buyNetNotBatchBuyTypeGoods(storeItem)
	YuanBaoPayLayer.buyStoreItem(storeItem.id, storeItem.itemId, function(eventType)
		if eventType == "success" then
			self:aftreBuyGoodsSuccess(storeItem)
		end
		self:show(self.goodsType)
	end,storeItem.number,{isOpenPay = true})
end

function StoreLayer:__getGoodsShowName(storeItem)
	if storeItem.itype == StoreGoodsType.Net_NotBatchBuy_Goods then
		return storeItem.name
	end

	return storeItem.name
end

--观影堂
function StoreLayer:setPanelViewingHall()
	local privilegeTime = User:getRole():getViewingHallPrivilegeExpiredTime() - GetTime()
	if privilegeTime > 60 then
		local day = math.floor( privilegeTime / (3600 * 24))
		local hours = math.floor((privilegeTime / 3600) % 24)
		local privilegeDesc = tostring(day).."天 "..tostring(hours).." 小时"

		self.Text_privilege_time:setVisible(true)
		self.Text_privilege_time:setString(privilegeDesc)
		self.Text_guanyingtang:setPosition(180,71)
	else
		self.Text_privilege_time:setVisible(false)
		self.Text_guanyingtang:setPosition(180,55)
	end
	
	self:refreshGuanYingTangHongDian()

	self.Panel_10:releaseFunc(function()
		PopupLayerController:showLayer("CommercialTimePresenter",function(layer)
			layer:showLayer()
			layer:setHideCallFunc(function()
				self:refreshStoreList()
				self:refreshYuanBaoNumber()
				self:refreshGuanYingTangHongDian()
			end)

			User:getRole():setDayFlag("guanYingHongDian", 1)
		end)
	end)
end


Helper:classDefNodeGetInstance(StoreLayer)

-- 加密标记
StoreLayer.isEncrypted = true
return StoreLayer
000000000000