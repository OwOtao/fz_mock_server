local NewLeiJiChongZhiLayer = class("NewLeiJiChongZhiLayer", LayerEx)
function NewLeiJiChongZhiLayer:create()
	local p = NewLeiJiChongZhiLayer:new()
	p:init()
	return p
end
local rewardList = {}
local panelPos = {
	[3] = {
		[1] = {
			x = 280,
			y = 1030,
		},
		[2] = {
			x = 790,
			y = 1030,
		},
		[3] = {
			x = 517,
			y = 780,
		},
	},
	[4] = {
		[1] = {
			x = 280,
			y = 1030,
		},
		[2] = {
			x = 790,
			y = 1030,
		},
		[3] = {
			x = 280,
			y = 780,
		},
		[4] = {
			x = 790,
			y = 780,
		},
	},
	[5] =  {
		[1] = {
			x = 280,
			y = 1030,
		},
		[2] = {
			x = 790,
			y = 1030,
		},
		[3] = {
			x = 280,
			y = 780,
		},
		[4] = {
			x = 790,
			y = 780,
		},
		[5] = {
			x = 280,
			y = 530,
		},
	},
}
local panelList = {}
function NewLeiJiChongZhiLayer:init()
	local UI = require("Layer/ActionUI/AnZhuoLeiJiChongZhi.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	self:setButtonCloseAndGoToPay()
	self.chooseItemId = nil

	self:setVisible(false)
end
function NewLeiJiChongZhiLayer:showLayer(tab)
	local layer = self:getInstance()
	-- self:show()
	-- layer:getGiftList()
	layer:getNultiFestivalGiftList(tab)
end
function NewLeiJiChongZhiLayer:getNultiFestivalGiftList(tab)--初始化界面
	Order:checkOrderInfoWithAccountId() --检查是否有订单未处理成功, 后台静默处理,无任何交互
	HttpManagerEx:getMultiFestivalGiftList(function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 then
			if errcode == 0 then
				-- Helper:print_lua_table(data)
				self:show() -- add by XiaoZhiWei 2017/09/12 17:28:13 改为成功获取服务器数据之后再显示界面
				if tab ~= nil then
					self:setActionTime(tab)--设置活动时间
				end
				self:initGiftTable(data.config)
				self:setLoadingBar(data)--设置充值进度条
				self:createGiftPanel(data)--初始化奖励界面
				self:setButtonTotalPrize(data)--设置领取按钮
			else
				PopText(errmsg)
			end
		end
	end, IS_SHOW_WAITING)
end
function NewLeiJiChongZhiLayer:setActionTime(actionId)--设置活动时间
	if actionId == nil then
		return
	end
	HttpManagerEx:getNewYearFestivalState(actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0  then
        	if data ~= nil and data.is_open == 1 and data.status == 1 then
        		local month,day,time,hour,min
        		month = tonumber(Helper:date("%m", tonumber(data.start)))
        		day = tonumber(Helper:date("%d", tonumber(data.start)))
        		time = month.."月"..day.."日活动上线-"
        		month = tonumber(Helper:date("%m", tonumber(data["end"])))
        		day = tonumber(Helper:date("%d", tonumber(data["end"])))
        		hour = tonumber(Helper:date("%H", tonumber(data["end"])))
        		min = tonumber(Helper:date("%M", tonumber(data["end"])))
        		time =time..month.."月"..day.."日"..hour.."时"..min.."分内累计充值\n可获得丰厚奖励"
        		self.Text_5:setString(time)
        	end
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end
function NewLeiJiChongZhiLayer:setLoadingBar(data)--设置充值进度条
	local list = data.list
	local shopping_money = data.shopping_money
	local Itemlist = data.gift_list
	if MapIsEmpty(list) == true or shopping_money == nil or type(shopping_money) ~= "number" then
		return
	end
	local nowMoney = self:getMinMoney(list)
	nowMoney = self:getNowMoney(list)
	self.LoadingBar.Text_TotalDayName:setString(shopping_money.."/"..nowMoney)
	self.Text_name_0:setString("累计充值达到"..nowMoney.."即可获得以下奖励")
	self.LoadingBar:setPercent((shopping_money/nowMoney)*100)
end
function NewLeiJiChongZhiLayer:createGiftPanel(data)--初始化奖励界面
	local list, shopping_money,giftList = data.list, data.shopping_money,data.gift_list
	if MapIsEmpty(list) == true or shopping_money == nil then
		return
	end
	local nowMoney = self:getMinMoney(list)
	self:createPanelItem(rewardList[tostring(self:getNowMoney(list))],self:getMaxMoney(list))
end
function NewLeiJiChongZhiLayer:setButtonTotalPrize(data)--初始化领取按钮
	local list, shopping_money,giftList = data.list, data.shopping_money,data.gift_list
	if MapIsEmpty(list) == true or shopping_money == nil then
		return
	end
	local nowMoney = self:getMinMoney(list)
	local tab = self:serializeTable(list)
	self:setButtonEnabled(self.Button_TotalPrize,true)
	self:setNodeTouchEnable(self.Button_TotalPrize,true)
	local func = function()
		PopText("没有可领取的奖励")
		self:getNultiFestivalGiftList()
	end
	if list[tostring(self:getNowMoney(list))] == 0 then
		func = function()
			PopText("没有可领取的奖励")
			self.Button_TotalPrize:setTouchEnabled(false)
			self:getNultiFestivalGiftList()
		end
	elseif list[tostring(self:getNowMoney(list))] == 1 then
		func = function()
			local rewards = nil
			rewards = clone(rewardList[tostring(self:getNowMoney(list))])
			if rewards == nil then
				PopText("setButtonTotalPrize rewards a nil value")
				return
			end 
			local _type = self:helpSetGiftButton(rewards)
			if _type == 2 and self.chooseItemId == nil then
				for k,v in pairs(rewards) do 
					if v.chooseList ~= nil and #v.chooseList>1 then
						for k,value in pairs(v.chooseList) do 
							self:createChoosePanel(self["Panel_itemchoose"..tostring(k)],value,panelList[4])
						end
						self:setChooseNodeVisibled(true)
						break
					elseif v.chooseList ~= nil and #v.chooseList == 1 then
						v.id= v.chooseList[1].id
						v.count = v.chooseList[1].count
						self:setGetGiftButton(rewards,data.list)
						break
					end
				end
				self.Button_TotalPrize:setTouchEnabled(true)
			elseif _type == 2 and self.chooseItemId ~= nil then
				for k,v in pairs(rewards) do
					if v.chooseList ~= nil and #v.chooseList>1 then
						local chooseTab = self:getChooseList(self.chooseItemId,v.chooseList)
						if chooseTab ~= nil then
							v.id= chooseTab.id
							v.count = chooseTab.count
						end
					elseif v.chooseList ~= nil and #v.chooseList==1 then
						v.id= v.chooseList[1].id
						v.count = v.chooseList[1].count
					end
				end
				self:setGetGiftButton(rewards,data.list)
			elseif _type == 3 then
				for k,v in pairs(rewards) do 
					if v.chooseList ~= nil then
						local randomTab = self:getRandomList(v.chooseList)
						-- v.id= randomTab.id
						-- v.count = randomTab.count
						PopText(randomTab.count)
						self.Button_TotalPrize:setTouchEnabled(true)
					end
				end
				--self:setGetGiftButton(rewards,data.list)
			else
				self:setGetGiftButton(rewards,data.list)
			end
		end
	elseif list[tostring(self:getNowMoney(list))] == 2 then
		self.Button_TotalPrize:setEnabled(false)
	end
	self.Button_TotalPrize:releaseFunc(function()
		self.Button_TotalPrize:setTouchEnabled(false)
		func()
	end)
end
function NewLeiJiChongZhiLayer:createPanelItem(list,maxMoney)--设置奖励panel的位置
	if list == nil then
		PopText("奖励列表出错，请联系客服")
		return
	end
	local posTab = panelPos[#list]
	for k,v in pairs(list) do 
		local panel = self["Panel_item"..tostring(k)]
		panel:setPosition(posTab[k].x,posTab[k].y)
		self:setPanelDetail(panel,list[k])
		panelList[k] = panel
	end
	local i = #list+1
	while(panelList[i] ~= nil) do
		panelList[i]:setPosition(-1200,1300)
		i=i+1
	end
	-- if #list == 3 and panelList[4] ~= nil then
	-- 	panelList[4]:setPosition(-1200,1300)
	-- end
end
function NewLeiJiChongZhiLayer:setPanelDetail(panel,list)
	if panel == nil or list == nil then
		return
	end
	if type(list) == "table" then
		if self.chooseItemId == nil then
			self:helpSetPanelDetail(panel,list)
		else
			local chooseList = self:getChooseList(self.chooseItemId,list.chooseList)
			if chooseList == nil then
				self:helpSetPanelDetail(panel,list)
				return
			end
			if chooseList.returnType ~= nil and chooseList.returnType == 1 then
				local tab = clone(list)
				tab.nameDes = chooseList.nameDes
				list = tab
			elseif chooseList.returnType ~= nil and chooseList.returnType == 2 then
				list = chooseList
			else
			end
			self:helpSetPanelDetail(panel,list)
		end
	end
end
function NewLeiJiChongZhiLayer:helpSetPanelDetail(panel,list)
	panel.Text_name:setString(list.name)
	panel.Text_num:setString("X"..list.count)
	if list.showType ~= nil and list.showType == 1 then
		self:setNodeVisibled(panel.Image_di,false)
		self:setNodeVisibled(panel.Image_di_kuang,false)
		panel.Image_zhuzi:loadTexture(list.image,0)
	elseif list.showType ~= nil and list.showType == 2 then
		if panel.Image_zhuzi ~=nil and list.image ~= nil then
			local present = require("app.presenters.HeadView.HVIPresent"):create(panel.Image_zhuzi,{path = list.image})
			present:showHead()
		end
		self:setNodeVisibled(panel.Image_di,true)
		self:setNodeVisibled(panel.Image_di_kuang,false)
		if list.di_image ~= nil then
			self:setNodeVisibled(panel.Image_di_kuang,true)
			if panel.di_image ~= nil then
				local present = require("app.presenters.HeadView.HVIPresent"):create(panel.di_image,{path = list.di_image})
				present:showHead()
			end
		end
	else
		PopText("奖励列表出错，请联系客服")
		return
	end
	if list.getType ~= nil and list.getType == 2 then
		if #list.chooseList>1 then
			panel:releaseFunc(function()
				self:setChooseNodeVisibled(true)
				for k,v in pairs(list.chooseList) do 
					self:createChoosePanel(self["Panel_itemchoose"..tostring(k)],v,panel)
				end
			end)
		end
	end
	panel.Text_NameDdes:setString(list.nameDes)
end
function NewLeiJiChongZhiLayer:createChoosePanel(panel,list,rPanel)
	self:setPanelDetail(panel,list)
	panel.Button_1:releaseFunc(function()
 		self:setChooseNodeVisibled(false)
 		self.chooseItemId = list.id
 		self:dealChoosePanel(rPanel,list)
 		--self:getNultiFestivalGiftList()
 	end)
end
function NewLeiJiChongZhiLayer:dealChoosePanel(panel,list)--初始化选择奖励
	if panel == nil or list == nil then
		return
	end
	panel.Text_num:setString("X"..list.count)
	panel.Text_NameDdes:setString(list.nameDes)
	if list.returnType ~= nil and list.returnType == 2 then
		if list.showType ~= nil and list.showType == 1 then
			self:setNodeVisibled(panel.Image_di,false)
			self:setNodeVisibled(panel.Image_di_kuang,false)
			panel.Image_zhuzi:loadTexture(list.image,0)
		elseif list.showType ~= nil and list.showType == 2 then
			if panel.Image_zhuzi ~=nil then
				local present = require("app.presenters.HeadView.HVIPresent"):create(panel.Image_zhuzi,{path = list.image})
				present:showHead()
			end
			self:setNodeVisibled(panel.Image_di_kuang,false)
			if list.di_image ~= nil then
				self:setNodeVisibled(panel.Image_di_kuang,true)
				if panel.di_image ~= nil then
					local present = require("app.presenters.HeadView.HVIPresent"):create(panel.di_image,{path = list.di_image})
					present:showHead()
				end
			end
		else
			PopText("奖励列表出错，请联系客服")
			return
		end
	end
end
function NewLeiJiChongZhiLayer:setGetGiftButton(rewards,list)
	print("奖励列表详情信息")
	Helper:print_lua_table(rewards)
	local role = User:getRole()
	local rwdTab = {} -- 用于检查背包空间是否足够
	for k,reward in pairs(rewards) do -- 转换为
		if reward.id ~= nil and reward.id ~= "" then
			rwdTab[reward.id] = reward.count
		end
	end
	Helper:print_lua_table(rwdTab)
	-- 先检查背包空间是否足够
	if role:checkCanBuyTwoOrMoreThings(rwdTab) == true then
		Order:checkOrderInfoWithParams({ orderType = 2, key = v, accountid = User:getAccountId() }, function()
			self:getOrderIdWithTypeId(2,self:getNowMoney(list),rewards)	
		end)
	else
		self.Button_TotalPrize:setTouchEnabled(true)
		PopText("背包空间不足,无法领取")
	end
end
function NewLeiJiChongZhiLayer:getOrderIdWithTypeId(typeid, key,rewards)--获取订单的orderId
	Order:getOrderIdFromWeb(2, {key = key}, function(orderId)
		self:receiveNultiFestivalGift(key, orderId,rewards)
	end)
end
function NewLeiJiChongZhiLayer:receiveNultiFestivalGift(key, order_id,rewards)--领取奖励
	Helper:print_lua_table(rewards)
	local tab = rewards[6]
	if tab == nil then 
		HttpManagerEx:getMultiFestivalGift(key, order_id,nil,function(status, errcode, errmsg,data,isEncrypted)
			if status == 200 and errcode == 0 then
				self:getReward(key, order_id ,data.itemId,rewards)
			else
				PopText(errmsg)
				self.Button_TotalPrize:setTouchEnabled(true)
			end
		end, IS_SHOW_WAITING)
	else
		HttpManagerEx:getMultiFestivalGift(key, order_id,tab.id,function(status, errcode, errmsg,data,isEncrypted)
			if status == 200 and errcode == 0 then
				PopText("发送的itemId:"..tab.id)
				self:getReward(key, order_id ,data.itemId,rewards)
			else
				PopText(errmsg)
				self.Button_TotalPrize:setTouchEnabled(true)
			end
		end, IS_SHOW_WAITING)
	end
end
function NewLeiJiChongZhiLayer:getReward(key, order_id,itemId,rewards)
	--local rewards = clone(rewardList[tostring(key)])
	if MapIsEmpty(rewards) == true then
		self.Button_TotalPrize:setTouchEnabled(true)
		return
	end
	local role = User:getRole()
	if rewards == nil then
		PopText("getReward rewards a nil value")
		return
	end
	local _type = self:helpSetGiftButton(rewards)
	if _type == 2 and self.chooseItemId ~= nil then
		for k,v in pairs(rewards) do
			if v.chooseList ~= nil then
				local chooseTab = self:getChooseList(self.chooseItemId,v.chooseList)
				if chooseTab ~= nil then
					v.id= chooseTab.id
					v.count = chooseTab.count
				end
			end
		end
	end
	local rwdTab = {} -- 用于检查背包空间是否足够

	for k,reward in pairs(rewards) do -- 转换为
		if reward.id ~= nil and reward.id ~= "" then
			rwdTab[reward.id] = reward.count
		end
	end
	-- 先检查背包空间是否足够
	if role:checkCanBuyTwoOrMoreThings(rwdTab) == true then
		for k,reward in pairs(rewards) do
			if reward.id == nil then
				PopText("获得物品 "..tostring(reward.name).. " X "..tostring(reward.count))
			else
				role:addItemCount(reward.id, reward.count)
				print(reward.id)
				local itemAttr = Item:getOneItemByKey(reward.id)
				PopText("获得物品 "..tostring(itemAttr.name).. " X "..tostring(reward.count))	
			end
		end
		for k,reward in pairs(rwdTab) do

		end
		--领取成功，删除到本地保存的orderid
		Order:deleteOneOrderInfo(order_id)
		self.chooseItemId = nil 
	else
		PopText("背包空间不足,无法领取")
	end
	self:getNultiFestivalGiftList()
end
function NewLeiJiChongZhiLayer:setButtonCloseAndGoToPay()
	self.Button_close:releaseFunc(function()
		self:hide()
		self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
	end)
	self.Button_toPay:releaseFunc(function()
		MainControllLayer:getLayer("StoreLayer"):showWithAction(function()
			self:getNultiFestivalGiftList(nil)
		end)
	end)
end
function NewLeiJiChongZhiLayer:helpSetGiftButton(list)
	if list == nil then
		print("helpSetGiftButton list a nil value")
		return
	end
	local _type = 1
	for k,v in pairs(list) do 
		if v.getType ~= nil and v.getType == 2 then
			_type = 2 
		elseif v.getType ~= nil and v.getType == 3 and _type ~= 2 then
			_type = 3
		end
	end
	return _type
end
function NewLeiJiChongZhiLayer:getChooseList(id,list)--
	if 	id == nil or list == nil then
		return
	end
	for k,v in pairs(list) do
		if v.id == id then
			return v
		end
	end
	return nil 
end
function NewLeiJiChongZhiLayer:getRandomList(list)--随机获取奖励
	if list == nil then
		return
	end
	return list[math.random(1,#list)]
end
function NewLeiJiChongZhiLayer:getMinMoney(list)--获取最小充值奖励金额
	if list == nil or type(list) ~= "table"  then
		return
	end
	local min = 1000000
	for k,v in pairs(list) do
		if tonumber(k)<min then
			min = tonumber(k)
		end
	end
	return min
end
function NewLeiJiChongZhiLayer:getMaxMoney(list)--获取最大充值奖励金额
	if list == nil or type(list) ~= "table"  then
		return
	end
	local max = 0
	for k,v in pairs(list) do 
		if tonumber(k) > max then
			max = tonumber(k)
		end
	end
	return max
end
function NewLeiJiChongZhiLayer:getNowMoney(list)--获取当前可领取奖励档位金额
	if list == nil  or type(list) ~= "table" then
		return
	end
	local tab = self:serializeTable(list)
	for k,v in pairs(tab) do 
		if list[tostring(v)] == 0 then
			return v
		elseif list[tostring(v)] == 1 then
			return v
		elseif k == #tab then
			return v
		end
	end
end
function NewLeiJiChongZhiLayer:serializeTable(list)--序列化一个表
	 local tab = {}
	 local i = 1
	 for k,v in pairs(list) do 
	 	table.insert(tab,tonumber(k))
	 end
	 table.sort(tab)
	 return tab
end
function NewLeiJiChongZhiLayer:setNodeTouchEnable(node,loop)--设置节点是否可以触摸
	if node == nil then
		return
	end
	if loop ~= nil then
		node:setTouchEnabled(loop)
	end
end
function NewLeiJiChongZhiLayer:setButtonEnabled(button,loop)--设置按钮是否可以点击
	if button == nil then
		return
	end
	if loop ~= nil then
		button:setEnabled(loop)
	end
end
function NewLeiJiChongZhiLayer:setNodeVisibled(node,loop)
	if node == nil then
		return
	end
	if loop ~= nil then
		node:setVisible(loop)
	end
end
function NewLeiJiChongZhiLayer:setChooseNodeVisibled(loop)
	if loop ~= nil then
		if self["Panel_itemchoose1"] ~= nil then
			self:setNodeVisibled(self["Panel_itemchoose1"],loop)
		end
		if self["Panel_itemchoose2"] ~= nil then
 			self:setNodeVisibled(self["Panel_itemchoose2"],loop)
 		end
 		if self.di_1 ~= nil then
 			self:setNodeVisibled(self.di_1,loop)
 		end
 		if self.Text_15 ~= nil then
 			self:setNodeVisibled(self.Text_15,loop)
 		end
	end
end
function NewLeiJiChongZhiLayer:initGiftTable(tab)
	local list = tab
	for k,v in pairs(list.base) do 
		rewardList[tostring(k)] = {}
		for i,value in pairs(v) do 
			rewardList[tostring(k)][i] = {}
			for n,m in pairs(value) do 
				if n == "itemId" then
					if m == "" then
						rewardList[tostring(k)][i].id = nil
					else
						rewardList[tostring(k)][i].id = m
					end
				elseif n == "number" then
					rewardList[tostring(k)][i].count = m
				elseif n == "name" then
					rewardList[tostring(k)][i].name = m
				elseif n == "imagePath" then
					rewardList[tostring(k)][i].image = m
				elseif n == "showType" then
					rewardList[tostring(k)][i].showType = m
				elseif n == "nameDes" then
					rewardList[tostring(k)][i].nameDes = m
				end
				if list.strategy_id == 1 then
					rewardList[tostring(k)][i].getType = 1
				elseif list.strategy_id == 2 then

				elseif list.strategy_id == 3 then

				end
			end
		end
	end
end
Helper:classDefNodeGetInstance(NewLeiJiChongZhiLayer)

return NewLeiJiChongZhiLayer0000000000000