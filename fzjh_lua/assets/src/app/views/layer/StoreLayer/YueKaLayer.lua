local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
local YueKaModel = require("app.models.YueKa.YueKaModel")

local YueKaLayer = class("YueKaLayer", cc.Layer)

--最大补领天数
local maxBuLingDay = 14

function YueKaLayer:create()
	local p = YueKaLayer:new()
	p:init()
	return p
end

-- 初始化
function YueKaLayer:init()
	local UI = require("Layer/StoreUI/YueKaUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUI(self)

	self:setPanelBack()
	self:refreshYueKaHongDian()
	self:setVisible(false)

	if GetTime() > Helper:getTimeStampWithStringDate("20181220", 0) and GetTime() < Helper:getTimeStampWithStringDate("20190105", 24) then
		self.Text_miaoshu:setVisible(true)
	else
		self.Text_miaoshu:setVisible(false)
	end
end

-- 显示 num = 1 江湖名士跳转进来    num = 2  活动列表跳转进来
function YueKaLayer:show(StoreLayer,num)
	if StoreLayer ~= nil then
		if num ~= 2 then
			self.__StoreLayer = StoreLayer	
		end
	end

	Game:updatePayInfo()

	-- 手谈渠道直接关闭充值 
	if Game:getChannelId() == "shoutan" then
		PopupLayerController:hideLayer("YueKaLayer", function(layer)
			self:hide()
		end)
		return
	end
	--红点刷新
	self:refreshYueKaHongDian()

	HttpManagerEx:getJhmsDesc(function(status, errcode, errmsg, data)
		if 200 == status then
			if 0 == errcode then
				---控制就双十一活动的  加速购买显示
				if data.eleven then
					self.Image_timeLimitAccelerate:setVisible(true)
				else
					self.Image_timeLimitAccelerate:setVisible(false)
				end
				-- 关闭 直接退出
				if data.status == "CLOSE" then
					if data.errmsg ~= nil then
						PopText(data.errmsg)
					end
					PopupLayerController:hideLayer("YueKaLayer", function(layer)
						self:hide()
					end)
					return
				end
				if DEBUG_MODE == 1 then
					Helper:print_lua_table(data)
				end
				self.Is_Click_1 = nil
				if MapIsEmpty(data.title_status) == false then
					if data.title_status.expired_time ~= nil and tonumber(data.title_status.expired_time) ~= 0 then
						self.YueKaTime  = data.title_status.expired_time
					end
				end
				if not self.YueKaTime then
					self.YueKaTime = 0
				end
				
								
				self:setPanelShow(data)
				self:setVisible(true)
				self:setButton2("申请", function()
					if self.Is_Click_1 then 
						return
					end

					local yuekaDay = (self.YueKaTime - GetTime()) / 3600 / 24
					
					-- 普通情况判断
					if YueKaModel:canBuy(yuekaDay) == false then
						PopText("江湖名士最长只能购买2年")
						return
					end
					
					-- 购买过一次后判断
					if self.YueKaAfterBuyTime ~= nil then
						if YueKaModel:canBuy(yuekaDay + 30) == false then
							PopText("江湖名士最长只能购买2年")
							return
						end
					end

					if data.canBuy == false then
						PopText(data.message)
						return
					end

					PopupLayerController:showLayer("StoreDialogLayer", function(layer)
						local item = 
						{
							dsc1 = "确定购买可获得【江湖名士】身份",
							name = "江湖名士",
							number = 0,
							itemId = "mingshi",
							price = "30元/月",
						}

						layer:show(item, function()
							self:getShenQingFunc(data.product_id)
						end)
					end)
				end)
			else
				PopText(tostring(errmsg))
			end
		else
			PopupLayerController:hideLayer("YueKaLayer", function(layer)
				self:hide()
			end)
		end
	end, IS_SHOW_WAITING)
end

-- 申请部分逻辑处理
function YueKaLayer:getShenQingFunc(key)
	if self.Is_Click == true or key == nil then
		-- PopText("您已发出充值请求，请不要重复点击")
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
						local role = User:getRole()
						-- 真实价格,支付渠道1:游戏客户端
						Mob.pay(30, 21, "江湖名士", 1, 30)
						role:updateYueKaStatus(GetTime() + 100)
						PopText("恭喜你成为【江湖名士】，有效期30天", cc.c3b(246,244,80))
						self.Is_Click_1 = true
						self.Is_Click = false
						self.YueKaAfterBuyTime = self.YueKaTime + 3600 * 24 * 30
						self:show()
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

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- UI显示部分
-- 窗口显示
function YueKaLayer:setPanelShow(params)
	if MapIsEmpty(params) == true then
		PopupLayerController:hideLayer("YueKaLayer", function(layer)
			self:hide()
		end)
		return
	end
	local role = User:getRole()
	if MapIsEmpty(params.title_name) == false then
		self.Text_chenghao:setString(params.title_name.title)
		self.Text_chenghao_desc:setString(params.title_name.desc)
	end
	--江湖名士一个月天数
	self.Text_title_2_1:setString("31天")

	if MapIsEmpty(params.title_receive_per_day) == false then
		self.Text_yuanbao:setString("元宝 + "..tostring(params.title_receive_per_day.yuanbao))
		self.Text_suiying:setString("碎银 + "..tostring(params.title_receive_per_day.money))
		self.Text_jingyan:setString("经验 + "..tostring(params.title_receive_per_day.exp))
		self.Text_qianneng:setString("潜能 + "..tostring(params.title_receive_per_day.pot))

		-- add by XiaoZhiWei 2016-12-20 判断是否有额外的物品奖励,trans校验是需要补偿给玩家
		if params.itemId ~= nil then
			params.title_receive_per_day.itemId = params.itemId
		end

		self:setButton1("今日福利", function()
			self:fuLiFunc(params.title_receive_per_day,params.extra_award)
		end)
	end

	if MapIsEmpty(params.title_receive_once_prize) == false then
		self.Text_fuyuan:setString("福缘丹 + "..tostring(params.title_receive_once_prize.fuyuandan))
		self.Text_fuyuan_desc:setString(params.title_receive_once_prize.desc)
	end

	if MapIsEmpty(params.title_extra_rights) == false then
		self.ListView_tequan:removeAllItems()
		for i=1,#params.title_extra_rights do
			local value = params.title_extra_rights[i]
			if i<5 then 
				self["Text_tequan"..i]:setString(value)
			end
			local Text_tequanStr=self.Text_tequan1:clone()
			Text_tequanStr:setString(value)
			Text_tequanStr:setFontSize(43)
			self.ListView_tequan:pushBackCustomItem(Text_tequanStr)
		end
	end

	self.Image_tishi1:releaseFunc(function()
		self.Panel_back_1:setVisible(true)
		self.Image_tishi2:setVisible(true)
	end)
	self.Panel_back_1:releaseFunc(function()
		self.Panel_back_1:setVisible(false)
		self.Image_tishi2:setVisible(false)
	end)



	if MapIsEmpty(params.title_status) == false then
		self.Text_shuaxin_desc:setString(params.title_status.refresh_time)
		self.Text_cost:setString(params.title_status.price_desc)

		local leftDesc = "未获得该身份"
		self:setButtonShow(false)
		if params.title_status.expired_time ~= nil and tonumber(params.title_status.expired_time) ~= 0 then
			local leftTime = params.title_status.expired_time - GetTime()
			if leftTime > 60 then
				local day = math.floor( leftTime / (3600 * 24))
				local hours = math.floor((leftTime / 3600) % 24)
				local minutes = math.floor((leftTime / 60) % 60)
				leftDesc = "剩余 "..tostring(day).."天 "..tostring(hours).." 小时"..tostring(minutes).." 分"
				self:setButtonShow(true)
			end
		end	

		--商场页面及时刷新
		if self.__StoreLayer ~= nil then
			self.__StoreLayer:setPanelMingShi(params.title_status.expired_time)
			self.__StoreLayer:refreshStoreList()
		end

		role:updateYueKaStatus(params.title_status.expired_time)
		self.Text_left_time:setString(leftDesc)

		if tonumber(params.title_status.not_received_days) ~= nil and tonumber(params.title_status.not_received_days) > 0 then
			self:setPanelLingQu(params.title_status.not_received_days,params.title_status.notjia_received_days,params.title_receive_per_day,params.title_status.today_not_received_days)
		else
			self:setPanelLingQu(0,0,params.title_receive_per_day,params.title_status.today_not_received_days)
		end
	end
end

-- 今日福利 
function YueKaLayer:fuLiFunc(perDayParams,extra_award)
	if MapIsEmpty(perDayParams) == true then
		self.Button_1:setTouchEnabled(true)
		return
	end

	-----------------------------------------------------------------------------------------------------------
	-- @author XiaoZhiWei
	-- @time 2016/12/20 14:57:53
	-- @desc 将 福利奖励列表结构初始化
	--[[
		{
			attr = {attr1 = num, attr2 = num}
			items = {itemId1 = num, itemId2 = num}
		}
	]]
	local transTab = 
	{
		attr = 
		{
			exp = Helper:getDef(perDayParams.exp, 10000),
			pot = Helper:getDef(perDayParams.pot, 10000),
			money = Helper:getDef(perDayParams.money, 20000)
		},
		items = 
		{
			
		}
	}

	--额外属性奖励
	do
		local extraExp,extraPot,extraMoney = 0,0,0 
		if MapIsEmpty(extra_award) == false then
			for k,v in pairs(extra_award) do
				if k == "exp" then
					extraExp = v
				elseif k == "pot" then
					extraPot = v
				elseif k == "money" then
					extraMoney = v
				end
			end
		end
		transTab.attr.exp = transTab.attr.exp + extraExp
		transTab.attr.pot = transTab.attr.pot + extraPot
		transTab.attr.money = transTab.attr.money + extraMoney
	end

	-- add by XiaoZhiWei 2017/09/26 16:13:13 itemId 结构初始化  itemId,1;itemid2,3
	do
		if type(perDayParams.itemId) == "string" then
			if string.find(perDayParams.itemId, ";") == nil or string.find(perDayParams.itemId, ",") == nil then
				transTab.items[perDayParams.itemId] = 1
			else
				while string.find(perDayParams.itemId, ";") ~= nil do
					local itemsList = string.split(perDayParams.itemId, ";")
					for k,item in pairs(itemsList) do
						if string.find(item, ",") ~= nil then
							local list = string.split(item, ",")
							if list[1] == nil or list[2] == nil then
							else
								transTab.items[list[1]] = list[2]
							end
							-- transTab.items[list[1]] = list[2]
						end
					end
				end				
			end
		elseif type(perDayParams.itemId) == "table" then
			transTab.items = perDayParams.itemId
		else
		end
	end


	-- if perDayParams.itemId ~= nil then
	-- 	transTab.items[perDayParams.itemId] = 1
	-- end

	local role = User:getRole()

	if role:yueKaIsValid() == true then
		-- add by XiaoZhiWei 2017/09/26 20:07:35 检查是否能够获得物品
		if role:checkCanBuyTwoOrMoreThings(transTab.items) == false then
			self.Button_1:setTouchEnabled(true)
			return
		end

		local transId = TransCheck:setTrans(transTab, 1, 2)
		if transId == nil or (type(transId) == "number" and transId <= 0) then
			self.Button_1:setTouchEnabled(true)
			return
		end

		local homeland_open = 0
		local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
        if HomelandUtil:sysIsOpen(false) == true then
			homeland_open = 1
		end

		HttpManagerEx:getReward2(1, transId,homeland_open, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)

					-- add by XiaoZhiWei 以下部分只显示文本, 数量的加减 在trans里面有方法计算
					local index = 0
					for k,v in pairs(perDayParams) do
						if k == "itemId" then
						else
							-- role:addAttr(k,v)
							self:delayFunc(index, function()
								local text = role:getCHAttrName(k)
								if text ~= nil and text ~= "" then
									text = tostring(text).." + "..tostring(v)
								end
								PopText(text)
							end)
							index = index + 0.5
						end
					end

					--额外属性奖励
					if MapIsEmpty(extra_award) == false then
						for k,v in pairs(extra_award) do
							if k == "itemId" then
							else
								-- role:addAttr(k,v)
								self:delayFunc(index, function()
									local text = role:getCHAttrName(k)
									if text ~= nil and text ~= "" then
										text = tostring(text).." + "..tostring(v)
									end
									PopText(text)
								end)
								index = index + 0.5
							end
						end
					end

					-- 江湖名士 物品 特殊奖励
					if MapIsEmpty(transTab.items) == false then
						for itemId, count in pairs(transTab.items) do
							local item = Item:getOneItemByKey(itemId)
							if MapIsEmpty(item) == false then
								-- role:addItemCount(item.id, count)
								self:delayFunc(index, function()
									PopText("获得"..tostring(item.name).." X"..tostring(count))
								end)
								index = index + 0.5
							end
						end
					end

					role:setDayFlag("yueKa_reward", 1)
					self:refreshYueKaHongDian()

				else
					TransCheck:updateTrans(transId, RESPONSE_STATUS_FAILED)
					PopText(tostring(errmsg))
				end
				self:show()
				self.Button_1:setTouchEnabled(true)
				return true
			else
				self.Button_1:setTouchEnabled(true)
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
	else
		self.Button_1:setTouchEnabled(true)
		PopText("您未获得江湖名士身份，无法领取今日福利")
	end
end

-- 补领区域
function YueKaLayer:setPanelLingQu(num,jiayuan_num, perDayParams,todayNotReceivedDays)
	if num == nil or todayNotReceivedDays == nil or num == 0 or todayNotReceivedDays == 0 then
		self.Image_buling:setVisible(false)
	else
		self.Image_buling:setVisible(true)
	end
	self.Text_buling:setString(tostring(num))
	self.Image_buling:releaseFunc(function()
		self:lingQuFunc(num,jiayuan_num, perDayParams,todayNotReceivedDays)
	end)
end

--领取按钮实现方法
function YueKaLayer:lingQuFunc(num,jiayuan_num, perDayParams,todayNotReceivedDays)
		local role = User:getRole()
		local dialog = DialogALayer:getInstance()
		local text = "名士福利共有"..tostring(num).."天可领取\n本日剩余可领取补领天数"..tostring(todayNotReceivedDays).."天\n请选择补领天数"		

		local homeland_open = 0
		local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
		if HomelandUtil:sysIsOpen(false) == true then
			homeland_open = 1
		end
		dialog:show(text)

		local function buling(days)
			local text = "是否补领"..days.."天,可获得\n \n \n 元宝 + "..tostring(perDayParams.yuanbao * days).."    碎银 + "..tostring(perDayParams.money * days).." \n 经验 + "..tostring(perDayParams.exp * days).." 潜能 + "..tostring(perDayParams.pot * days)..""

			local homeland_open = 0
			local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
			if HomelandUtil:sysIsOpen(false) == true then
				homeland_open = 1
			end
		
			dialog:show(text,"（补领将消耗 "..tostring(tonumber(days) * perDayParams.yuanbao / 2).."元宝）")
		
			dialog:setButton1("确定",function()
		
				local transId = TransCheck:setTrans(perDayParams, days, 2)
				if transId == nil or (type(transId) == "number" and transId <= 0) then
					return
				end

				HttpManagerEx:getJhmsReward(transId,homeland_open,days,function(status, errcode, errmsg, data)
					if 200 == status then
						if 0 == errcode then
							local textTab = 
							{
								yuanbao = perDayParams.yuanbao,
								money = perDayParams.money,
								pot = perDayParams.pot,
								exp = perDayParams.exp
							}
		
							if homeland_open == 1 then
								textTab["yinpiao"] = perDayParams.yinpiao
							end
		
							local index = 0
							for k,v in pairs(textTab) do
								self:delayFunc(index, function()
									local text = role:getCHAttrName(k)
									if text ~= nil then
										if text == "银票" then
											if v*jiayuan_num  > 0  then
												if jiayuan_num < days then
													text = tostring(text).." + "..tostring(v*jiayuan_num)
												else
													text = tostring(text).." + "..tostring(v*days)
												end
											else
												text = ""
											end
										else
											text = tostring(text).." + "..tostring(v*days)
										end
									end
									PopText(text)
								end)
								index = index + 0.5
							end
							TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
						else
							TransCheck:updateTrans(transId, RESPONSE_STATUS_FAILED)
							PopText(tostring(errmsg))
						end
						self:show()
					end
				end, IS_SHOW_WAITING)
			end)
			dialog:setButton2("取消")
		end

		local btn1Name,btn2Name,btn3Name = "补领一天","补领五天","补领全部"
		local day1,day2,day3 = 1,5,num
		local btn1Visible,btn2Visible,btn3Visible = true,true,true

		if day2 >= num then
			btn3Visible = false
			day2 = num

			if day2 > todayNotReceivedDays then
				day2 = todayNotReceivedDays
			end

			btn2Name = "补领全部"
		end

		if day3 > maxBuLingDay then
			day3 = maxBuLingDay
			btn3Name = "补领十四天"
		end

		if day3 <= maxBuLingDay and day3 > todayNotReceivedDays then
			day3 = todayNotReceivedDays
		end

		if btn1Visible then
			dialog:setButton1(btn1Name,function()
				if day1 > todayNotReceivedDays then
					PopText("每日最多只能补领"..tostring(maxBuLingDay).."天")
				else
					buling(day1)
				end
			end)
		end

		if btn2Visible then
			dialog:setButton2(btn2Name,function()
				if day2 > todayNotReceivedDays then
					PopText("每日最多只能补领"..tostring(maxBuLingDay).."天")
				else
					buling(day2)
				end
			end)
		end
		
		if btn3Visible then
			dialog:setButton3(btn3Name,function()
				if day3 > todayNotReceivedDays then
					PopText("每日最多只能补领"..tostring(maxBuLingDay).."天")
				else
					buling(day3)
				end
			end)
		end
end

-- 按钮显示控制方法	isValid 月卡是否有效 true false
function YueKaLayer:setButtonShow(isValid)
	if isValid == nil then
		isValid = false
	end

	-- 有效
	if isValid == false then
		self.Button_1:setVisible(false)
		self.Text_shuaxin_desc:setVisible(false)
		self.Button_2:move(cc.p(540, 420))
		self.Text_cost:move(cc.p(540, 320))
	else
	-- 无效
		self.Button_1:setVisible(true)
		self.Text_shuaxin_desc:setVisible(true)
		self.Button_2:move(cc.p(850, 420))
		self.Text_cost:move(cc.p(860, 320))
	end
end

-- 申请按钮
function YueKaLayer:setButton2(name, func)
	if name == nil then
		self.Button_2:setVisible(false)
	else
		self.Button_2:setVisible(true)
	end
	self.Text_button_2_Name:setString(name)
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
	end)
end

-- 每日领取
function YueKaLayer:setButton1(name, func)
	if name == nil then
		self.Button_1:setVisible(false)
	else
		self.Button_1:setVisible(true)
	end
	self.Text_button_1_Name:setString(name)
	self.Button_1:releaseFunc(function()
		self.Button_1:setTouchEnabled(false)
		if func then
			func()
		end
	end)
end

function YueKaLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("YueKaLayer", function(layer)
			self:hide()
			MainControllLayer:getLayer("StoreLayer"):refreshYueKaHongDian()
		end)
	end)
end

--红点刷新
function YueKaLayer:refreshYueKaHongDian()
	local role = User:getRole()
	if role:yueKaIsValid()==true and role:getDayFlag("yueKa_reward") == 0 then  
		self.Image_hongdian_mingshi:setVisible(true)
	else
		self.Image_hongdian_mingshi:setVisible(false)
	end
end

function YueKaLayer:onResume()
end


Helper:classDefNodeGetInstance(YueKaLayer)
return YueKaLayer
0000000000000