local ShouChongLayer = class("ShouChongLayer", LayerEx)
function ShouChongLayer:create()
	local p = ShouChongLayer:new()
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
		name = "戏曲面具",
		count = 1,
		id = "mianju1010",
	},
	{
		name = "菩提子",
		count = 2,
		id = "putizi1"
	},
	{
		name = "潜能丹",
		count = 2,
		id = "qiannengdan"
	},
	{
		name = "五煞神掌",
		count = 1,
		id = "chunjieleiji1"
	}
}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 16:03:50
-- @desc 首充页面测试方法
function ShouChongLayer:test()
	local layer = self:getInstance()
	layer:initUI()
end

function ShouChongLayer:init()
	local UI = require("Layer/ActionUI/ShouChongUI.lua").create()['root']
	UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setPanelBack()
	self.Panel_back:releaseFunc(function ()
    	self.Image_help:setVisible(false)
		self.Text_desc:setVisible(false)
	end)

	self:setButtonClose()
	self:setPanelsClick()
	self:setVisible(false)
end

function ShouChongLayer:setImageKuang()
	self.Image_kuang:releaseFunc(function()
		if PRINT_MODE == 1 then
			print("进入活动页面")
		end
	end)
end

function ShouChongLayer:setButtonClose()
	self.Button_close:releaseFunc(function()
		self:hide()
		self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
	end)
end

function ShouChongLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		self:hide()
		self:destroyInstance() -- add by XiaoZhiWei 2017/09/11 15:05:38 弹出类窗口,隐藏时删除自身
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/09 16:21:31
-- @desc 设置点击查看按钮选项
function ShouChongLayer:setPanelsClick()
	for i=1,4 do
		local panel = self["Panel_item"..tostring(i)]
		self:setPanel(panel, rewardList[i])
	end
end

-- 设置中间区域按钮
function ShouChongLayer:setPanel(panel, panelAttr)
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
	-- panel.Button_1:releaseFunc(function()
 --    	self.Image_help:setVisible(true)
 --    	self.Text_desc:setVisible(true)
 --    	self.Text_desc:setString(itemAttr.dsc)
	-- end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/14 16:11:33
-- @desc 发放奖励
function ShouChongLayer:getReward(orderId)
	local role = User:getRole()
	local rwdTab = {} 
	for k,reward in pairs(rewardList) do
		rwdTab[reward.id] = reward.count
	end
	-- 先检查背包空间是否足够
	if role:checkCanBuyTwoOrMoreThings(rwdTab) == true then
		for k,reward in pairs(rewardList) do
			role:addItemCount(reward.id, reward.count)
			PopText("获得物品 "..tostring(reward.name).. " X "..tostring(reward.count))
		end
		--领取成功，删除到本地保存的orderid
		Order:deleteOneOrderInfo(orderId)
	else
		PopText("背包空间不足,无法领取")
	end
	self:updateShowChongList()
end

--Button_toPay.Text_buttonName
function ShouChongLayer:setTextButtonNameString(str)
	str = Helper:getDef(str, "领取")
	self.Button_toPay.Text_buttonName:setString(str)
end

--初始化界面
function ShouChongLayer:updateShowChongList()
	Order:checkOrderInfoWithAccountId() --检查是否有订单未处理成功, 后台静默处理,无任何交互
	HttpManagerEx:getFirstFestivalGiftList(function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 and errcode == 0  then
			self:show()
			self.Button_toPay:setOpacity(255)
			self.Button_toPay:setEnabled(true)
			self:setTextButtonNameString("领取")
			if data.status == 0 then
				self:setTextButtonNameString("去充值")
				self.Button_toPay:releaseFunc(function()
					MainControllLayer:getLayer("StoreLayer"):showWithAction(function()
						self:initUI()
					end)
				end)
			elseif data.status == 1 then
				self.Button_toPay:setEnabled(true)
				self.Button_toPay:releaseFunc(function()
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
	end)
end

--HTTP请求
--get请求
--获取order_id
function ShouChongLayer:getOrderIdWithTypeId()
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
	end
	end)
end

--post 领取首充奖励
function ShouChongLayer:receiveFirstFestivalGift(order_id)
	HttpManagerEx:getFirstFestivalGift(order_id ,function(status, errcode, errmsg, isEncrypted)
		if status == 200 and errcode == 0 then
			self:getReward(order_id)
		else
			PopText(errmsg)
		end
	end)
end

-- 初始化UI
function ShouChongLayer:initUI()
	self:updateShowChongList()
end

Helper:classDefNodeGetInstance(ShouChongLayer)
return ShouChongLayer
00000000