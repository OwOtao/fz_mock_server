local StoreLayer = require("app.views.layer.StoreLayer.StoreLayer")
local NewShouChongLayer = class("NewShouChongLayer", LayerEx)
function NewShouChongLayer:create()
	local p = NewShouChongLayer:new()
	p:init()
	return p
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 16:08:09
-- @desc 奖励列表
local rewardList = 
{
	{
		name = "菩提子",
		count = 2,
		id = "putizi1",
	},
	{
		name = "潜能丹",
		count = 2,
		id = "qiannengdan"
	},
	{
		name = "武林秘籍",
		count = 1,
		id = "chunjieleiji1"
	},
	{
		name = "戏曲面具",
		count = 1,
		id = "mianju1010"
	}
}
local minaju = {
	[1] = "mianju1016", 
	[2] = "mianju1011",
	[3] = "mianju1010",
	[4] = "mianju1017"
}
-- local time = "4月28日活动上线-5月30日23时59分内累计充值\n可获得丰厚奖励"
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 16:03:50
-- @desc 首充页面显示
function NewShouChongLayer:showLayer(actionId)
	local layer = self:getInstance()
	layer:show()
	layer:updateShowChongList(actionId)
	layer:initRewardList()
end
function NewShouChongLayer:init()
	local UI = require("Layer/ActionUI/NewShouChongUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	self:setPanelBack()
	self.Panel_back:releaseFunc(function ()
    	self.Image_help:setVisible(false)
		self.Text_desc:setVisible(false)
	end)
	-- self.Text_5:setString(time)
	self:setButtonClose()
	self:setPanelsClick()
	self:setVisible(false)
end
function NewShouChongLayer:setActionTime(actionId)--设置活动时间
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
        		time ="首次充值可获得丰厚奖励"
      			print(time)
        		self.Text_5:setString(time)
        	end
        else
            PopText(errmsg)
        end
	end, IS_SHOW_WAITING)
end
function NewShouChongLayer:initRewardList()
	local role = User:getRole()
	local random = math.random(1,2)
	if role.sex == "男" then
		if random == 1 then
			rewardList[4].id = minaju[3]
		else
			rewardList[4].id = minaju[4]
		end
	else
		if random == 1 then
			rewardList[4].id = minaju[1]
		else
			rewardList[4].id = minaju[2]
		end
	end
end
function NewShouChongLayer:setImageKuang()
	self.Image_kuang:releaseFunc(function()
		if PRINT_MODE == 1 then
			print("进入活动页面")
		end
	end)
end

function NewShouChongLayer:setButtonClose()
	self.Button_close:releaseFunc(function()
		self:hide()
		self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
	end)
end

function NewShouChongLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		self:hide()
		self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 16:21:31
-- @desc 设置点击查看按钮选项
function NewShouChongLayer:setPanelsClick()
	for i=1,4 do
		local panel = self["Panel_item"..tostring(i)]
		self:setPanel(panel, rewardList[i])
	end
end

-- 设置中间区域按钮
function NewShouChongLayer:setPanel(panel, panelAttr)
	if panel == nil then
		return
	end
	local itemAttr = Item:getOneItemByKey(panelAttr.id)
	if MapIsEmpty(itemAttr) == true then
		PopText("没有这个物品 "..tostring(panelAttr.id))
		return
	end
	panel.Text_name:setString(panelAttr.name)
	panel.Text_num:setString("X"..panelAttr.count)
	if panel == self["Panel_item"..tostring(4)] then
		local role = User:getRole()
		if role.sex == "男" then
			panel.Image_zhuzi:loadTexture("Image/UI/StoreUI/mianju1001.png",0)
		else
			panel.Image_zhuzi:loadTexture("Image/UI/StoreUI/mianju1000.png",0)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 16:11:33
-- @desc 发放奖励
function NewShouChongLayer:getReward(orderId)
	local role = User:getRole()
	local rwdTab = {} 
	for k,reward in pairs(rewardList) do
		rwdTab[reward.id] = reward.count
	end
	-- 先检查背包空间是否足够
	if role:checkCanBuyTwoOrMoreThings(rwdTab) == true then
		for k,reward in pairs(rewardList) do
			role:addItemCount(reward.id, reward.count)
			local itemAttr = Item:getOneItemByKey(reward.id)
			PopText("获得物品 "..tostring(itemAttr.name).. " X "..tostring(reward.count))
		end
		--领取成功，删除到本地保存的orderid
		Order:deleteOneOrderInfo(orderId)
	else
		PopText("背包空间不足,无法领取")
	end
	self:updateShowChongList()
end

--Button_toPay.Text_buttonName
function NewShouChongLayer:setTextButtonNameString(str)
	str = Helper:getDef(str, "领取")
	self.Button_toPay.Text_buttonName:setString(str)
end

--初始化界面
function NewShouChongLayer:updateShowChongList(actionId)
	Order:checkOrderInfoWithAccountId() --检查是否有订单未处理成功, 后台静默处理,无任何交互
	HttpManagerEx:getFirstFestivalGiftList(function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 and errcode == 0  then
			-- self:show()
			if actionId then
				self:setActionTime(actionId)
			end
			self.Button_toPay:setOpacity(255)
			self.Button_toPay:setEnabled(true)
			self.Button_toPay:setTouchEnabled(true)
			self:setTextButtonNameString("领取")
			if data.status == 0 then
				self:setTextButtonNameString("去充值")
				self.Button_toPay:releaseFunc(function()
					MainControllLayer:pushLayer("StoreLayer")
					local StoreLayer=MainControllLayer:getLayer("StoreLayer")
					StoreLayer:showWithAction(function()
						self:initUI()
					end)
					self:hide()
				end)
			elseif data.status == 1 then
				self.Button_toPay:setEnabled(true)
				self.Button_toPay:releaseFunc(function()
					self.Button_toPay:setTouchEnabled(false)
					self:getOrderIdWithTypeId() -- 获取订单号之后开始交易流程
				end)
			elseif data.status == 2 then
				self:setTextButtonNameString("已领取")
				self.Button_toPay:setOpacity(255)
				self.Button_toPay:setEnabled(false)
				self.Button_toPay:releaseFunc(function()
					PopText("已经领取过首充奖励")
				end)
			else
			end
		end
	end, true)
end

--HTTP请求
--get请求
--获取order_id
function NewShouChongLayer:getOrderIdWithTypeId()
	Order:getOrderIdFromWeb(1, {key = 1}, function(orderId)
		local role = User:getRole()
		local rwdTab = {} 
		for k,reward in pairs(rewardList) do
			rwdTab[reward.id] = reward.count
		end
		-- 先检查背包空间是否足够
		if role:checkCanBuyTwoOrMoreThings(rwdTab) == true then
			self:receiveFirstFestivalGift(orderId)
		else
			PopText("背包空间不足,无法领取")
			self.Button_toPay:setTouchEnabled(true)
		end
	end)
end

--post 领取首充奖励
function NewShouChongLayer:receiveFirstFestivalGift(order_id)
	HttpManagerEx:getFirstFestivalGift(order_id ,function(status, errcode, errmsg, isEncrypted)
		if status == 200 and errcode == 0 then
			self:getReward(order_id)
		else
			PopText(errmsg)
			self.Button_toPay:setTouchEnabled(true)
		end
	end, true)
end

-- 初始化UI
function NewShouChongLayer:initUI()
	self:updateShowChongList()
end

Helper:classDefNodeGetInstance(NewShouChongLayer)
return NewShouChongLayer
00