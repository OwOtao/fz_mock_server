local LeiJiChongZhiLayer = class("LeiJiChongZhiLayer", LayerEx)
function LeiJiChongZhiLayer:create()
	local p = LeiJiChongZhiLayer:new()
	p:init()
	return p
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 14:48:48
-- @desc 奖励列表
local rewardList = 
{
	["30"] = 
	{
		{
			name = "潜能丹",
			count = 2,
			id = "qiannengdan",
			des = "潜能丹",
			image = "Image/UI/StoreUI/qiannengdan.png",
			nameDes = ""
		},
		{
			name = "醉梦生",
			count = 1,
			id = "jiu106",
			des = "醉梦生",
			image = "Image/UI/StoreUI/juhuajiu100.png",
			nameDes = ""
		}
	},
	["100"] = 
	{
		{
			name = "潜能丹",
			count = 3,
			id = "qiannengdan",
			des = "潜能丹",
			image = "Image/UI/StoreUI/qiannengdan.png",
			nameDes = ""
		},
		{
			name = "醉梦生",
			count = 2,
			id = "jiu106",
			des = "醉梦生",
			image = "Image/UI/StoreUI/juhuajiu100.png",
			nameDes = ""
		}
	},
	["300"] = 
	{
		{
			name = "武功秘籍",
			count = 1,
			id = "mianju1012",
			des = "武功秘籍",
			image = "Image/UI/StoreUI/miji.png",
			nameDes = "（江湖）"
		},
		{
			name = "戏曲面具",
			count = 1,
			id = "mianju1011",
			des = "面具1",
			image = "Image/UI/StoreUI/mianju1000.png",
			nameDes = "（岳小妹）"
		}
	},

	["500"] = 
	{
		{
			name = "武功秘籍",
			count = 1,
			id = "mianju1012",
			des = "武功秘籍",
			image = "Image/UI/StoreUI/miji.png",
			nameDes = "（江湖）"
		},
		{
			name = "戏曲面具",
			count = 1,
			id = "mianju1012",
			des = "面具2",
			image = "Image/UI/StoreUI/mianju1001.png",
			nameDes = "（杨大侠）"
		}
	},

	["800"] = 
	{
		{
			name = "武功秘籍",
			count = 1,
			id = "mianju1012",
			des = "武功秘籍",
			image = "Image/UI/StoreUI/miji.png",
			nameDes = "（江湖）"
		},
		{
			name = "戏曲面具",
			count = 1,
			id = "mianju1013",
			des = "面具3",
			image = "Image/UI/StoreUI/mianju1000.png",
			nameDes = "（龙姑娘）"
		}
	},
}
local itemIdList = 
{
	chunjieleiji2 = true,
	chunjieleiji3 = true,
	chunjieleiji4 = true
}
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 16:03:50
-- @desc 首充页面测试方法
function LeiJiChongZhiLayer:test()
	local layer = self:getInstance()
	layer:getNultiFestivalGiftList()
end

function LeiJiChongZhiLayer:init()
	local UI = require("Layer/ActionUI/LeiJiChongZhiUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)
	self.Panel_back:releaseFunc(function ()
    	self.Image_help:setVisible(false)
		self.Text_desc:setVisible(false)
	end)
	self:setButtonClose()
	self:setButtonGoToPay()
end

function LeiJiChongZhiLayer:setImageKuang()
	self.Image_kuang:releaseFunc(function()
		if PRINT_MODE == 1 then
			print("进入活动页面")
		end
	end)
end

function LeiJiChongZhiLayer:setButtonClose()
	self.Button_close:releaseFunc(function()
		self:hide()
		self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
	end)
end

function LeiJiChongZhiLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
			-- self:hide()
			-- self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
		end)
end

--获取累计充值奖励列表
function LeiJiChongZhiLayer:getNultiFestivalGiftList()
	Order:checkOrderInfoWithAccountId() --检查是否有订单未处理成功, 后台静默处理,无任何交互
	HttpManagerEx:getMultiFestivalGiftList(function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 then
			if errcode == 0 then
				self:show()
				Helper:print_lua_table(data)
				self:setLoadingBar(data.list, data.shopping_money)
				self:setButtonTotalPrize(data.list, data.shopping_money)
			else
				PopText(errmsg)
			end
		end
	end, IS_SHOW_WAITING)
end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/01/09 16:21:31
-- -- @desc 设置点击查看按钮选项

function LeiJiChongZhiLayer:setPanel(nowMoney)
	local data = rewardList[tostring(nowMoney)]
	for i =3,4 do 
		local panel = self["Panel_item"..tostring(i)]
		if panel ~= nil then
			panel.Text_name:setString(data[i-2].name)
			panel.Text_num:setString("X"..data[i-2].count)
			panel.Image_zhuzi:loadTexture(data[i-2].image,0)
			panel.Text_NameDdes:setString(data[i-2].nameDes)
			-- panel.Button_1:releaseFunc(function()
		 --    	self.Image_help:setVisible(true)
		 --    	self.Text_desc:setVisible(true)
		 --    	self.Text_desc:setString(data[i-2].des)
			-- end)
		end
	end
end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/01/09 16:15:05
-- -- @desc 去充值 按钮
function LeiJiChongZhiLayer:setLoadingBar(list, shopping_money)
	if MapIsEmpty(list) == true or shopping_money == nil or type(shopping_money) ~= "number" then
		return
	end

	local nowMoney = 30
	
	-- 顺序化tab
	local tab = {}
	for k,v in pairs(list) do
		table.insert(tab, tonumber(k))
	end
	table.sort(tab)

	for i,v in ipairs(tab) do
		if list[tostring(v)] == 0 then
			nowMoney = v
			break
		elseif list[tostring(v)] == 1 then
			nowMoney = v
			break
		elseif i == #tab then
			nowMoney = v
		end
	end
	self:setPanel(nowMoney)
	self.LoadingBar.Text_TotalDayName:setString(shopping_money.."/"..nowMoney)
	self.Text_name_0:setString("累计充值达到"..nowMoney.."即可获得以下奖励")
	self.LoadingBar:setPercent((shopping_money/nowMoney)*100)
end
function LeiJiChongZhiLayer:setButtonTotalPrize(list, shopping_money)
	if MapIsEmpty(list) == true or shopping_money == nil then
		return
	end

	local nowMoney = 30
	-- 顺序化tab
	local tab = {}
	for k,v in pairs(list) do
		table.insert(tab, tonumber(k))
	end
	table.sort(tab)

	local func = function()
		PopText("没有可领取的奖励")
		self:getNultiFestivalGiftList()
	end
	self.Button_TotalPrize:setOpacity(255)
	self.Button_TotalPrize:setEnabled(true)
	for i,v in ipairs(tab) do
		if list[tostring(v)] == 0 then
			nowMoney = v
			break
		elseif list[tostring(v)] == 1 then--获取order_id前先判断
			nowMoney = v
			func = function()
				local rewards = clone(rewardList[tostring(v)])
				local role = User:getRole()
				local rwdTab = {} -- 用于检查背包空间是否足够
				for k,reward in pairs(rewards) do -- 转换为
					rwdTab[reward.id] = reward.count
				end
				-- 先检查背包空间是否足够
				if role:checkCanBuyTwoOrMoreThings(rwdTab) == true then
					Order:checkOrderInfoWithParams({ orderType = 2, key = v, accountid = User:getAccountId() }, function()
						self:getOrderIdWithTypeId(2,nowMoney)	
					end)
				else
					PopText("背包空间不足,无法领取")
				end
			end
			break
		elseif i == #tab then
			nowMoney = v
			-- self.Text_name_0:setString(shopping_money)
			self.LoadingBar.Text_TotalDayName:setString(shopping_money)
			self.Button_TotalPrize:setOpacity(255)
			self.Button_TotalPrize:setEnabled(false)
		end
	end
	self.Button_TotalPrize:releaseFunc(function()
		func()
	end)
end
function LeiJiChongZhiLayer:setButtonGoToPay()
	self.Button_toPay:releaseFunc(function()
		MainControllLayer:pushLayer("StoreLayer")
		MainControllLayer:getLayer("StoreLayer"):showWithAction(function()
			self:initUI()
		end)
	end)
end

--获取累计充值的order_id
function LeiJiChongZhiLayer:getOrderIdWithTypeId(typeid, key)
	Order:getOrderIdFromWeb(2, {key = key}, function(orderId)
		self:receiveNultiFestivalGift(key, orderId)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 14:50:37
-- @desc 获取奖励
function LeiJiChongZhiLayer:getReward(key, order_id,itemId)
	local rewards = clone(rewardList[tostring(key)])
	if MapIsEmpty(rewards) == true then
		return
	end

	-- 武功秘籍三选一 判断
	if itemId ~= nil and itemIdList[itemId] ~= nil then
		local itemAttr = Item:getOneItemByKey(itemId)
		for k ,reward in pairs(rewards) do 
			if reward.des == "武功秘籍" then
				reward.id = itemId
				if MapIsEmpty(itemAttr) == false then
					reward.name = itemAttr.name
				end
			end
		end
	end

	local role = User:getRole()
	local rwdTab = {} -- 用于检查背包空间是否足够
	for k,reward in pairs(rewards) do -- 转换为
		rwdTab[reward.id] = reward.count
	end
	-- 先检查背包空间是否足够
	if role:checkCanBuyTwoOrMoreThings(rwdTab) == true then
		for k,reward in pairs(rewards) do
			role:addItemCount(reward.id, reward.count)
			PopText("获得物品 "..tostring(reward.name).. " X "..tostring(reward.count))	
		end
		--领取成功，删除到本地保存的orderid
		Order:deleteOneOrderInfo(order_id)
	else
		PopText("背包空间不足,无法领取")
	end
	self:getNultiFestivalGiftList()
end
--检查itemId是否在奖励列表中
function LeiJiChongZhiLayer:checkItemId(itemId,list)
	if itemId == nil or MapIsEmpty(list) == true then
		return false
	end
	for k,v in pairs(list) do
		if v == itemId then
			return true
		end
	end
	return false
end
--领取奖励
function LeiJiChongZhiLayer:receiveNultiFestivalGift(key, order_id)
	HttpManagerEx:getMultiFestivalGift(key, order_id, nil,function(status, errcode, errmsg,data,isEncrypted)
		if status == 200 and errcode == 0 then
			if key >100 and data ~=nil and data.itemId ~= nil then
				-- data.itemId = "chunjieleiji2"
				print("*******************************************************************")
				self:getReward(key, order_id ,data.itemId)
			else
				print("没有ItemId")
				self:getReward(key, order_id ,nil)
			end
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end

--初始化界面
function LeiJiChongZhiLayer:initUI()
	self:getNultiFestivalGiftList()
end

Helper:classDefNodeGetInstance(LeiJiChongZhiLayer)

return LeiJiChongZhiLayer
00000000000