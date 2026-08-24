local YaShiLayer = class("YaShiLayer", cc.Layer)
local TaskConst = require("app.models.Task2.TaskConst")
local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")

function YaShiLayer:create()
	local p = YaShiLayer:new()
	p:init()
	return p
end

-- 初始化
function YaShiLayer:init()
	local UI = require("Layer/StoreUI/YaShiUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUI(self)

	self:setPanelBack()
	self:setVisible(false)
	self.buyTimeLimit = 24 * 3600
	--0 可申请购买 1 可领取福利 2已领取福利
	self.state = 0
end

function YaShiLayer:show(expiredTime, exchangeCount, callback)
	Game:updatePayInfo()

	-- 手谈渠道直接关闭充值 
	if Game:getChannelId() == "shoutan" then
		PopupLayerController:hideLayer("YaShiLayer", function(layer)
			self:hide()
		end)
		return
	end

	self.YaShiTime = expiredTime
	self.exchangeCount = exchangeCount
	self.callback = callback

	self:initState()
	self:setTextEarn()
	self:setTextTime()
	self:setCost()
	self:setButtonName()
	self:setButtonBuy()
	self:setHongDian()
	self:setVisible(true)
end

function YaShiLayer:refreshUI()
	self:initState()
	self:setHongDian()
	self:setButtonName()
	self:setCost()
	self:setTextTime()
	if self.callback then
		self.callback()
	end
end

function YaShiLayer:setTextEarn()
	local value = Helper:getRoundNumber(TaskConst:getHangUpTaskConfigValue("yaShiAwardExpAdd") * 100)
    self.Text_1:setString(string.format("      解锁江湖雅士权益的玩家，可以在当前挂机任务中，额外获得%s%%的基础任务收益。（任务基础收益是指不含福缘、走穴十四针、传承的额外加成下获得的当前挂机任务基础任务收益，而江湖雅士所增加的%s%%，是指增加%s%%玩家当前任务基础收益。）",value,value,value))
end

function YaShiLayer:setTextTime()
	local desc = "未获得该身份"
	if self.YaShiTime ~= 0 and self.YaShiTime > GetTime() then
		local time = self.YaShiTime - GetTime()
		if time > 60 then
			local day = math.floor( time / (3600 * 24))
			local hours = math.floor((time / 3600) % 24)
			local minutes = math.floor((time / 60) % 60)
			desc = "剩余 "..tostring(day).."天 "..tostring(hours).." 小时"..tostring(minutes).." 分"
		end
	end	
	self.Text_time:setString(desc)
end

function YaShiLayer:setCost()
	if self.state == 0 then
		self.Text_cost:setString("(30元/月)")
	else
		self.Text_cost:setString("")
	end
end

function YaShiLayer:setButtonBuy()
	self.Button_buy:releaseFunc(function()
		if self.state == 1 or self.state == 2 then
			PopupLayerController:showLayer("YaShiBenefitPresenter",function(layer)
				layer:showLayer(self.exchangeCount, function(yaShiTime, exchangeCount)
					self.exchangeCount = exchangeCount
					self.YaShiTime = yaShiTime
					self:refreshUI()
				end)
			end)
			return
		end

		if self.YaShiTime ~= 0 and self.YaShiTime > GetTime() + self.buyTimeLimit then
			PopText("你已拥有此身份，剩余时间为24小时内可再次购买")
			return
		end

		PopupLayerController:showLayer("StoreDialogLayer", function(layer)
			local item = 
			{
				dsc1 = "确定购买可获得【江湖雅士】身份",
				name = "江湖雅士",
				number = 0,
				itemId = "yashi",
				price = "30元/月",
			}

			layer:show(item,function()
				self:getShenQingFunc("com.mkjump.fzjha.product124")
			end)
		end)
	end)
end

function YaShiLayer:initState()
	if self.exchangeCount > 0 then
		self.state = 1
	elseif self.exchangeCount == 0 then
		if self.YaShiTime - GetTime() > self.buyTimeLimit then
			self.state = 2 
		else
			self.state = 0
		end
	end
end

function YaShiLayer:setButtonName()
	local str = ""
	if self.state == 0 then
		str = "申请"
	elseif self.state == 1 then
		str = "领取专属福利"
	elseif self.state == 2 then
		str = "领取专属福利"
	end

	self.Text_buttonName:setString(str)
end

function YaShiLayer:setHongDian()
	if self.state == 1 then
		self.Image_hongdian:setVisible(true)
	else
		self.Image_hongdian:setVisible(false)
	end
end

function YaShiLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("YaShiLayer", function(layer)
			layer:hide()
		end)
	end)
end

-- 申请部分逻辑处理
function YaShiLayer:getShenQingFunc(key)
	if self.Is_Click == true or key == nil then
		return
	end
	self.Is_Click = true
	HttpManagerEx:checkPaySign(key,function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 then
			if errcode == 0 then
				local dialog = DialogALayer:getInstance()
				dialog:show("正在充值,请稍后")
				dialog:setBack(false)
				dialog:setButton1()
				dialog:setButton2()
				
				SdkMethod:IosPurchase_SetCallback(function(eventName)
					if not eventName or string.len(eventName) <= 0 then
						PopText("异常，请联系客服人员")
						return
					end
					local errcode = tonumber(eventName)
			
					local text 
					if errcode == 1 then
						text = "仅支持IOS7以上系统"
					elseif errcode == 2 then
						text = "不允许程序内付费，玩家关闭了应用内购买功能"
					elseif errcode == 3 then
						text = "没有该商品"
					elseif errcode == 4 then
						text = "购买出错"
						HttpManagerEx:updateOrderState()
					elseif errcode == 7 then
						text = "已经购买过此商品"
					elseif errcode == 9 then
						text = "交易失败"
						HttpManagerEx:updateOrderState()
					elseif errcode == 12 then
						text = "错误的头信息"
					elseif 13 <= errcode and errcode <= 14  then
						text = "服务器异常，物品可能延迟到账"
					elseif 15 <= errcode and errcode <= 20  then
						text = "请勿使用非法渠道购买物品"
					elseif errcode == 21 then
						text = "未知错误"
					elseif errcode == 22 then
						text = "订单ID获取失败,请重新尝试"
					elseif errcode == 23 then
						text = "交易失败，订单ID非法。"
					elseif errcode == 24 then
						text = "订单异常，服务器无法获取订单信息。"
					elseif errcode == 25 then
						text = "角色存档数据不存在，请联系客服。"
					elseif errcode == 26 then
						text = "取消登录"
					elseif errcode == 27 then
						text = "放弃支付"
						HttpManagerEx:updateOrderState()
					elseif errcode == 28 then
						text = "登录成功"
					elseif errcode == 29 then
						text = "登录失败"
					elseif errcode == 30 then
						text = "订单已提交或处理中"
					elseif errcode == 31 then
						text = "登录状态过期"
					else
						text = ""
					end
			
					if errcode == 0 then
						-- 真实价格,支付渠道1:游戏客户端
						Mob.pay(30, 21, "江湖雅士", 1, 30)
						PopText("恭喜你成为【江湖雅士】，有效期30天", cc.c3b(246,244,80))
						self.Is_Click = false
						self.YaShiTime = GetTime() + 30*24*60*60
						User:getRole():updateYaShiStatus(self.YaShiTime)
						self.exchangeCount = 1000
						self:refreshUI()
						dialog:hide()
					else
						PopText(text)
					end
			
					if text ~= "" then
						self.Is_Click = false
						dialog:hide()
					end
				end)
				SdkMethod:IosPurchase_BuyItem(key)
			else
				self.Is_Click = false
				PopText(errmsg)
			end
		else
			self.Is_Click = false
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end

Helper:classDefNodeGetInstance(YaShiLayer)
return YaShiLayer
0000000000