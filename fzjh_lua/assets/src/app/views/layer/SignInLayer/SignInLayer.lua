local SignInLayer = class("SignInLayer", LayerEx)

local errMsgList = {} -- add by XiaoZhiWei 2017/04/17 15:05:32 用于统计签到日期不正确的信息

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/15 17:37:25
-- @desc 弹出签到页面 
function SignInLayer:showLayer()
	HttpManagerEx:getSignList(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			PopupLayerController:showLayer("SignInLayer", function(layer)
				layer:setMarkData(data)
				layer:show()
				layer:createMarkPanel()
				layer:refreshUI()
			end)
		else
			print(status, errcode, errmsg, data)
		end
	end)
end

function SignInLayer:create()
	local signInLayer = SignInLayer:new()
	signInLayer:init()
	return signInLayer
end

function SignInLayer:init()
	self:setShowAndHideAnimType("ROLL")

	self._UI = require("Layer.SignInUI.SignInUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self.__markData = {
		-- { "beginDate":"20161128", "endDate":"20170107", "seasonId":1, "signedList":[], "historySignCount":0, "prizeList":[], "prizeId":15}
	} -- 测试使用

	self.Button_back:releaseFunc(function ()
		MainControllLayer:getLayer("StoreLayer"):refreshYuanBaoNumber()
		PopupLayerController:hideLayer("SignInLayer", function(layer)
			layer:hide()
		end)
	end)

	self:getPrizeReward()
	self:__setRuleFunc()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/14 16:59:02
-- @desc 刷新签到页面数据
function SignInLayer:refreshData()
	HttpManagerEx:getSignList(function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			self:setMarkData(data)
			self:refreshUI()
		end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/08 12:14:47
-- @desc 获取签到数据记录
function SignInLayer:getMarkData()
	return self.__markData
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/08 12:15:27
-- @desc 设置更新签到数据记录
function SignInLayer:setMarkData(markData)
	self.__markData = markData
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/09 10:53:04
-- @desc 签到奖励列表 (客户端固定)
function SignInLayer:getReward(index)
	return switch(index, 
	{
		"qiandao1",
		"qiandao2y",
		"qiandao1",
		"qiandao4",
		"qiandao1",
		"qiandao1",
		"qiandao7",

		"qiandao8",
		"qiandao9y",
		"qiandao8",
		"qiandao11",
		"qiandao8",
		"qiandao8",
		"qiandao14",

		"qiandao15",
		"qiandao16y",
		"qiandao15",
		"qiandao18",
		"qiandao15",
		"qiandao15",
		"qiandao21",

		"qiandao22",
		"qiandao23y",
		"qiandao22",
		"qiandao25",
		"qiandao22",
		"qiandao22",
		"qiandao28",

		"qiandao29",
		"qiandao30y",
		"qiandao29",
		"qiandao32",
		"qiandao29",
		"qiandao29",
		"qiandao35",

		"qiandao36",
		"qiandao37y",
		"qiandao36",
		"qiandao39",
		"qiandao36",
		"qiandao36",
		"qiandao42",

		"qiandao43",
		"qiandao44y",
		"qiandao43",
		"qiandao46",
		"qiandao43",
		"qiandao43",
		"qiandao49",
	})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/17 11:48:52
-- @desc 获取元宝类奖励描述
function SignInLayer:getYuanBaoItemDesc(itemId)
	return switch(itemId, 
	{
		qiandao2y = "元宝X30",
		qiandao9y = "元宝X35",
		qiandao16y = "元宝X40",
		qiandao23y = "元宝X45",
		qiandao30y = "元宝X50",
		qiandao37y = "元宝X60",
		qiandao44y = "元宝X70",
		default = "补签奖励"
	})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/14 09:58:41
-- @desc 累计签到奖励列表
function SignInLayer:getRewardWithPrizeId(prizeId)
	-- 奖励ID是数字 累计签到天数要大于30天 并且 是30的倍数的时候奖励一个累计签到面具
	if type(prizeId) == "number" and prizeId > 30 and prizeId % 30 == 0 then
		prizeId = 30
	end

	return switch(prizeId, 
	{
		[15] = {itemId = "qiannengdan", num = 5},
		[30] = "leijiqiandao"
	})
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/08 15:27:08
-- @desc 签到成功后设置
function SignInLayer:afterDateMarkSuccess(stringDate, itemId)
	if stringDate == nil or itemId == nil then
		print("数据错误")
		return
	end
	self:addSignPrize(itemId)

	local markData = self:getMarkData()
	-- 更新数据记录
	markData.signedList = Helper:getDef(markData.signedList, {})
	markData.historySignCount = markData.historySignCount + 1
	
	table.insert(markData.signedList, stringDate)
	self:setMarkData(markData)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/09 10:41:47
-- @desc 累计签到次数奖励领取成功之后的数据变化
function SignInLayer:afterGetPrizeReward(prizeId)
	local markData = self:getMarkData()
	if MapIsEmpty(markData) == true then
		PopText("数据有误,请重新打开签到界面再来查看")
		return 
	end

	local prizeList = markData.prizeList
	-- 判断补领列表是否为空,如果为空看,则累积签到的次数上限用当前的次数表示
	if MapIsEmpty(prizeList) == true then
		markData.prizeId = markData.historySignCount

	else
		for i,prizeId in ipairs(prizeList) do
			if prizeId > tonumber(markData.prizeId) then
				markData.prizeId = prizeList[i]
				break
			end
		end
	end
	self:setMarkData(markData)

	local reward = self:getRewardWithPrizeId(prizeId)
	if reward ~= nil then
		switch(type(reward), 
		{
			string = function()
				-- 领取后直接调用一次使用
				self:addSignPrize(reward)
			end,
			table = function()
				if reward.itemId == nil or reward.num == nil then
					return
				end
				User:getRole():addItemCount(reward.itemId, reward.num)
				local itemAttr = User:getRole():getOneItemByKey(reward.itemId)
				if MapIsEmpty(itemAttr) == false then
					PopText(tostring(itemAttr.name).." + "..tostring(reward.num))
				else
					PopText("获得累计签到奖励")
				end
			end
		})
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/08 12:07:45
-- @desc 刷新Ui
function SignInLayer:refreshUI()
	self:showButtonSign()
	self:showLoadingBarAndButton()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/08 12:08:24
-- @desc 签到按钮的控制
function SignInLayer:showButtonSign()
	local markState = self:checkDateIsMark(Helper:date("%Y%m%d", GetTime()))
	if markState == false then
		self.Button_Sign:setOpacity(255)
	else
		self.Button_Sign:setOpacity(255/2)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/08 16:22:33
-- @desc 累计签到次数进度条的控制及按钮控制
function SignInLayer:showLoadingBarAndButton()
	self.LoadingBar:setPercent(0)
	self.LoadingBar.Text_TotalDayName:setString("0/0")
	local markData = self:getMarkData()
	if MapIsEmpty(markData) == true then
		return
	end
	self.LoadingBar:setPercent(tonumber(markData.historySignCount) / tonumber(markData.prizeId) * 100)
	self.LoadingBar.Text_TotalDayName:setString(tostring(markData.historySignCount).."/"..tostring(markData.prizeId))
	self:setPrizeRewardDesc(markData.prizeId)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/07 18:34:36
-- @desc 检查日期是否已经签到过 0 未签到, 1已签到 2 需补签
function SignInLayer:checkDateIsMark(stringDate)
	if stringDate == nil or string.len(stringDate) <= 0 then
		return false
	end
	local markData = self:getMarkData()
	if MapIsEmpty(markData) == true or MapIsEmpty(markData.signedList) == true then
		return false
	end

	for i,date in ipairs(markData.signedList) do
		if stringDate == date then
			return true
		end
	end
	return false
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/08 11:41:28
-- @desc 指定 日期格式 和 天数 返回 那天的日期格式
function SignInLayer:getStringDate(stringDate, dayCount)
	dayCount = Helper:getDef(dayCount, 0) -- 默认值是0
	if stringDate == nil or string.len(stringDate) <= 0 then
		return nil
	end
	local beginDateTime = Helper:getTimeStampWithStringDate(stringDate, 12)
	return Helper:date("%Y%m%d", beginDateTime + dayCount * 24 * 3600)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/07 18:00:57
-- @desc 获取指定日期到当前日期的字符串列表
function SignInLayer:getAllStringDateMap(stringDate, dayCount)
	if stringDate == nil or string.len(stringDate) <= 0 then
		return nil
	end
	local retList = {}
	dayCount = Helper:getDef(dayCount, 49)
	local nowDateTime = Helper:getDayTime(GetTime())

	-- 在今天之前没签到的状态为需补签,之后的为未签到
	for i=1 ,dayCount do
		local dateString = self:getStringDate(stringDate, i - 1)
		retList[dateString] = 
		{
			markState = tonumber(dateString) < tonumber(Helper:date("%Y%m%d", GetTime())) and 2 or 0 --当前日期的时间戳比今天的起始时间戳还小,则代表是补签状态
		}
	end
	return retList
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/07 17:47:39
-- @desc 获取签到状况列表
function SignInLayer:getMarkMap()
	local markData = self:getMarkData()
	if MapIsEmpty(markData) == true then
		PopText("数据有误, 请重新打开签到界面再来查看")
		return 
	end
	--[[
		返回结构
		{
			20161204 = 
			{
				markState = 1, -- 是否签到 0 未签到 1 已签到 2 可补签
			}
		}
	]]
	-- 判断开始签到的日期是否正确
	if markData.beginDate == nil or tonumber(markData.beginDate) > tonumber(Helper:date("%Y%m%d", GetTime())) then
		if DEBUG_MODE == 1 then
			PopText("签到的开始日期不正确,请重新确认")
		end
		return nil
	end

	-- 获取开始签到的日期到现在的所有日期的字符串(20160201)列表 
	local dateMap = self:getAllStringDateMap(markData.beginDate, 49)
	-- for循环遍历已签到的日期
	for i,stringDate in ipairs(markData.signedList) do
		if dateMap[stringDate] ~= nil then
			dateMap[stringDate].markState = 1 
		end
	end
	return dateMap
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/08 10:39:36
-- @desc 创建多行签到面板
function SignInLayer:createOneMarkPanelRow()
	return self.Panel_ListView.ListView_row_list:clone()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/08 12:29:45
-- @desc 创建一个签到栏目
function SignInLayer:createOneMarkItem()
	local button = self.Panel_ListView.Button_Reward:clone()
	Helper:convertUIByParent(button)
	return button
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/09 15:24:42
-- @desc 获取签到图片 注:暂定随机,如果需要可重写规则
function SignInLayer:getItemImage(index)
	local resName = switch(index, {
		"signInChest1",
		"signInYuanBao1",
		"signInChest1",
		"signInTianXiang1",
		"signInChest1",
		"signInChest1",
		"signInZuiMengSheng1",

		"signInChest1",
		"signInYuanBao1",
		"signInChest1",
		"signInTianXiang1",
		"signInChest1",
		"signInChest1",
		"signInZuiMengSheng1",

		"signInChest2",
		"signInYuanBao2",
		"signInChest2",
		"signInTianXiang2",
		"signInChest2",
		"signInChest2",
		"signInZuiMengSheng2",

		"signInChest2",
		"signInYuanBao2",
		"signInChest2",
		"signInTianXiang2",
		"signInChest2",
		"signInChest2",
		"signInZuiMengSheng2",

		"signInChest2",
		"signInYuanBao2",
		"signInChest2",
		"signInTianXiang2",
		"signInChest2",
		"signInChest2",
		"signInZuiMengSheng2",

		"signInChest3",
		"signInYuanBao3",
		"signInChest3",
		"signInTianXiang3",
		"signInChest3",
		"signInChest3",
		"signInZuiMengSheng3",

		"signInChest3",
		"signInYuanBao3",
		"signInChest3",
		"signInTianXiang3",
		"signInChest3",
		"signInChest3",
		"signInZuiMengSheng3",
	})
	return Resource:getImgPath(resName)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/17 15:42:45
-- @desc 判断账户的创建时间是否大于开始时间 大于 返回true  小于 返回false 
function SignInLayer:checkAccountCreateTime(stringDate)
	local markData = self:getMarkData()
	if MapIsEmpty(markData) == true or stringDate == nil then
		if PRINT_MODE == 1 then
			PopText("数据有误,请重新打开签到界面再来查看")
		end
		return true -- 按钮是否能够点击的地方使用, 如果true 则 不能点击
	end
	local createDate = Helper:getDef(markData.createDate, Helper:date("%Y%m%d", GetTime()))
	return tonumber(createDate) > tonumber(stringDate)
end

local function errorHandler(errmsg)
    local msg = errmsg
    local traceback_msg = debug.traceback()
    print(msg)
    print(traceback_msg)

    local ErrmsgRecord = require("app.models.Record.ErrmsgRecord.ErrmsgRecord")

    ErrmsgRecord:addErrmsg(msg .. " ; " .. traceback_msg)
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/07 17:45:39
-- @desc 创建签到面板
function SignInLayer:createMarkPanel()
	-- 检查这两个接口的trans
	xpcall(TransCheck.checkTransWithUrl, errorHandler, TransCheck, "check_failed_normal_sign")
	xpcall(TransCheck.checkTransWithUrl, errorHandler, TransCheck, "check_failed_history_sign")

	local markData = self:getMarkData()
	if MapIsEmpty(markData) == true then
		-- print("11111111111111111111111111111111111")
		PopText("数据有误,请重新打开签到界面进行签到")
		return nil
	end

	local markMap = self:getMarkMap()
	if MapIsEmpty(markMap) == true then
		if DEBUG_MODE == 1 then
			PopText("数据异常,请检查数据 markMap 未获取到")
		end
		return nil
	end

	-- 判断开始签到的日期是否正确
	if markData.beginDate == nil or tonumber(markData.beginDate) > tonumber(Helper:date("%Y%m%d", GetTime())) then
		if DEBUG_MODE == 1 then
			PopText("签到的开始日期不正确,请重新确认")
		end
		return nil
	end


	---索引所有日期
	local index = 1
	---创建49个签到按钮
	for j=1,7 do
		local rowListView = self.Panel_ListView.ListView_ranking:getItem(j - 1)
		if rowListView == nil then
			rowListView = self:createOneMarkPanelRow()
			self.Panel_ListView.ListView_ranking:pushBackCustomItem(rowListView)
		else
		end

		---根据list数据初始化列表
		for i=1,7 do
			local item = rowListView:getItem(i - 1)
			if item == nil then
				item = self:createOneMarkItem()
				rowListView:pushBackCustomItem(item)
			else
			end

			local signImage = Resource:getImgPath("unSignIn")
			local func = function() end
			local stringDate = self:getStringDate(markData.beginDate, index - 1)
			local markState = markMap[stringDate].markState
			local goodsImage = self:getItemImage(index)


			item:setTouchEnabled(true)
			item.Image_Sign:setVisible(true)
			item.Image_goods:loadTexture(goodsImage)

			-- 签到的各种情况
			-- 未签到
			if markState == 0 then
				item.Image_Sign:setVisible(false)
				func = function ()
					table.insert(errMsgList, "当前签到的日期, markData.beginDate = "..tostring(markData.beginDate).."; type(markData.beginDate) = "..type(markData.beginDate).."; stringDate = "..tostring(stringDate).."; type(stringDate) = "..type(stringDate).."; index = "..tostring((j - 1) * 7 + i).."; 当前时间 = "..tostring(GetTime()))
					self:setDateMark(stringDate, function ()
						item.Image_Sign:loadTexture(Resource:getImgPath("signIn"))
						item.Image_Sign:setVisible(true)
					end)	
				end
			-- 已签到
			elseif markState == 1 then
				signImage = Resource:getImgPath("signIn")
				func = function ()
					PopText("今天已成功签到，请勿重复点击")
				end
			-- 需补签
			elseif markState == 2  then
				---监听补签按钮
				func = function ()
					table.insert(errMsgList, "当前补签的日期, markData.beginDate = "..tostring(markData.beginDate).."; type(markData.beginDate) = "..type(markData.beginDate).."; stringDate = "..tostring(stringDate).."; type(stringDate) = "..type(stringDate).."; index = "..tostring((j - 1) * 7 + i).."; 当前时间 = "..tostring(GetTime()))
					self:setHistoryDateMark(stringDate, goodsImage, function ()
						item.Image_Sign:loadTexture(Resource:getImgPath("signIn"))
						item.Image_Sign:setVisible(true)
					end)
				end
			else
				error()
			end

			item:releaseFunc(function ()
				errMsgList = {}
				Helper:getDef(func, EMPTY_FUNC)()
			end)
			item.Image_Sign:loadTexture(signImage)

			if stringDate == Helper:date("%Y%m%d", GetTime()) then
				self.Button_Sign:releaseFunc(function()
					errMsgList = {}
					Helper:getDef(func, EMPTY_FUNC)()
				end)
			end

			-- 判断日期是否比 账户创建时间小 
			if self:checkAccountCreateTime(stringDate) == true then
				item:setTouchEnabled(false)
				item.Image_Sign:setVisible(false)
				item.Image_goods:setColor({r = 77, g = 77, b = 77})
			else
				item.Image_goods:setColor({r = 255, g = 255, b = 255})
			end

			index = index + 1
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/13 11:26:37
-- @desc 获取签到奖励物品ID
function SignInLayer:getRewardItemId(stringDate)
	local markData = self:getMarkData()
	if MapIsEmpty(markData) == true or stringDate == nil then
		print("数据出错了,重新获取一下")
		return
	end
	local startStringDate = markData.beginDate

	if PRINT_MODE == 1 then
		print("markData.beginDate = "..tostring(markData.beginDate))
		print("markData.stringDate = "..tostring(stringDate))
		print("Helper:getDaysBetweenTwoDate2(startStringDate, stringDate) = "..tostring(Helper:getDaysBetweenTwoDate2(startStringDate, stringDate)))
	end
	table.insert(errMsgList, "计算日期查看,得到物品ID, index = "..tostring(Helper:getDaysBetweenTwoDate2(startStringDate, stringDate) + 1).."; stringDate = "..tostring(stringDate).."; type(stringDate) = "..type(stringDate).."; startStringDate = "..tostring(startStringDate).."; type(startStringDate) = "..type(startStringDate))
	return self:getReward(Helper:getDaysBetweenTwoDate2(startStringDate, stringDate) + 1)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/15 12:09:02
-- @desc 签到相关的Http请求
function SignInLayer:httpForDateMark(stringDate, func)
	local itemId = self:getRewardItemId(stringDate)
	if itemId == nil then
		table.insert(errMsgList, "奖励ID不存在, itemId = "..tostring(itemId).."; stringDate = "..tostring(stringDate).."; type(stringDate) = "..type(stringDate).."; func = "..tostring(func))
		User:getRole():saveErrMsg("signIn", table.concat(errMsgList, "||||||||"))
		PopText("签到日期不正确,请重新打开签到界面进行签到")
		return
	end
	local transId = TransCheck:setTransIdWithUrl("check_failed_normal_sign")
	if transId == nil or (type(transId) == "number" and transId <= 0) then
		if DEBUG_MODE == 1 then
			assert(nil,"trans_id 获取失败")
		end
		return
	end

	local homeland_open = 0
	local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
	if HomelandUtil:sysIsOpen(false) == true then
		homeland_open = 1
	end

	HttpManagerEx:getSignPrize(transId, stringDate, itemId,homeland_open, function(status, errcode, errmsg, data)
	    if status == 200 then
	    	if errcode == 0 then
	    		-- 领取奖励
	    		-- PopText("领取奖励成功")
				self:afterDateMarkSuccess(stringDate, itemId)

				if homeland_open == 1 and tonumber(data.yinpiao) ~= 0 then
					PopText("获得银票 +"..data.yinpiao)
				end

				if data.yuanbao ~= nil and tonumber(data.yuanbao) ~= 0 then
					PopText("获得元宝 +" .. data.yuanbao )
				end

				if data.daily_point ~= nil and tonumber(data.daily_point) ~= 0 then
					PopText("获得积分 +" .. data.daily_point )
				end

	    		if func then
	    			func()
	    		end
    		else
    			PopText(tostring(errmsg))
	    	end
			TransCheck:deleteOneTransWithUrl("check_failed_normal_sign", transId)
	    end
		self:refreshUI() -- 不管情况如何,刷新下UI
	end,IS_SHOW_WAITING)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/08 15:00:44
-- @desc 签到
function SignInLayer:setDateMark(stringDate, func)
	local todayDate = Helper:date("%Y%m%d", GetTime())
	---今天的日期
	if tonumber(todayDate) < tonumber(stringDate) then
		PopText("签到日期还未到达,请明天再来签到")
		return
	elseif not stringDate or string.len(stringDate) ~= 8 then
		PopText("数据异常,补签日期格式不正确 ["..tostring(stringDate).."]")
		return
	elseif self:checkDateIsMark(stringDate) == true then
		PopText("今天已成功签到，请勿重复点击")
		return
	elseif self:bagIsFull() == true then
		PopText("背包空间不够，请空出两个格子再来领取")
		return
	else
	end

	self:httpForDateMark(stringDate, func)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/08 15:12:16
-- @desc 补签
function SignInLayer:setHistoryDateMark(stringDate, goodsImage, func)
	local todayDate = Helper:date("%Y%m%d", GetTime())
	---今天的日期
	if tonumber(todayDate) < tonumber(stringDate) then
		PopText("签到日期还未到达,请明天再来签到")
		return
	elseif not stringDate or string.len(stringDate) ~= 8 then
		PopText("数据异常,补签日期格式不正确 ["..tostring(stringDate).."]")
		return
	elseif self:checkDateIsMark(stringDate) == true then
		PopText("今天已成功签到，请勿重复点击")
		return
	elseif self:bagIsFull() == true then
		PopText("背包空间不够，请空出两个格子再来领取")
		return
	else
	end

	local markData = self:getMarkData()
	if MapIsEmpty(markData) == true then
		PopText("数据有误, 请重新打开签到界面进行补签")
		return
	end

	--弹出框是否确定消耗20元宝补签
	PopupLayerController:showLayer("SignInPayYuanBaoLayer", function(layer)
		layer:show()

		local itemId = self:getRewardItemId(stringDate)
		local itemAttr = User:getRole():getOneItemByKey(itemId)
		if itemAttr == nil then
			layer:setItemName(self:getYuanBaoItemDesc(itemId))
		else
			layer:setItemName(itemAttr.name)
		end
		layer:setItemIcon(goodsImage)
		layer:setItemPrice(markData.yuanbao)

		layer:setPayFunc(function ()
			self:httpForDateMark(stringDate, func)
			PopupLayerController:hideLayer("SignInPayYuanBaoLayer", function(layer)
				layer:hide()
			end)
		end)
		layer:setCancelFunc(function ()
			PopupLayerController:hideLayer("SignInPayYuanBaoLayer", function(layer)
				layer:hide()
			end)
		end)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/09 10:33:21
-- @desc 领取累积签到奖励
function SignInLayer:getPrizeReward()
	self.Button_TotalPrize:releaseFunc(function()
		local markData = self:getMarkData()
		if MapIsEmpty(markData) == true then
			PopText("数据有误,请重新打开签到界面进行签到")
			return
		end
		-- 判断签到次数够够不够
		if tonumber(markData.historySignCount) >= tonumber(markData.prizeId) then
			if self:bagIsFull() == true then
				PopText("背包空间不够，请空出两个格子再来领取")
				return
			end

			-- 记录（设置）交易凭证item ,count  , transType 1 元宝类 2 月卡类 3 福缘丹 4 论剑奖励
			local transId = TransCheck:setTransIdWithUrl("check_failed_history_sign")
			if transId == nil or (type(transId) == "number" and transId <= 0) then
				if DEBUG_MODE == 1 then
					assert(nil,"trans_id 获取失败")
				end
				return
			end
			HttpManagerEx:getSignHistoryPrize(transId, markData.prizeId, function(status, errcode, errmsg, data)
			    if status == 200 then
			    	if errcode == 0 then
			    		-- PopText("领取累计签到成功")
			    		self:afterGetPrizeReward(markData.prizeId)
			    		self:refreshData()
		    		else
		    			PopText(tostring(errmsg))
			    	end
					TransCheck:deleteOneTransWithUrl("check_failed_history_sign", transId)
			    end
			   	self:refreshUI()
			end,IS_SHOW_WAITING)
		else
			PopText("累计签到次数不够,请明天再来")
		end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/14 15:45:36
-- @desc 设置累计签到描述文本
function SignInLayer:setPrizeRewardDesc(prizeId)
	local desc = "累计签到15天，奖励         *5"
	if tonumber(prizeId) ~= nil and tonumber(prizeId) > 15 then
		desc = "累计签到"..tostring(prizeId).."天，必定奖励随机面具*1"
		self.Text_totalSign_qiannengdan:setVisible(false)
	else
		self.Text_totalSign_qiannengdan:setVisible(true)
		self.Text_totalSign_qiannengdan:setString("HIY潜能丹")
	end
	self.Text_totalSign_desc:setString(desc)
end


---判断玩家背包是否满了
function SignInLayer:bagIsFull()
	local  role = User:getRole()
	local BagItems = role:getItems()
	-- 至少剩余两个格子才能领取
	if #BagItems + 2 > role:getAttr("weight") then
		return true
	end
	return false
end


-------  得到 签到 或者补签的奖励
function SignInLayer:addSignPrize( itemId ,func)
	-- local itemId = data.itemId
	if itemId == nil then
		return
	end
	local Item = require("app.models.item.Item")
	local itemAttr = Item:getOneItemByKey(itemId)
	if MapIsEmpty(itemAttr) == false then
		User:getRole():addItemCount(itemAttr.id, 1)
		self:delayFunc(0.1, function()
			itemAttr:useItem(nil,nil,false,false)
			if func then
				func()
			end
			----获取元宝的提示
			-- if data.msg  then
			-- 	PopText(tostring(data.msg))
			-- end
		end)
	else
		local num = switch(itemId, 
		{
			qiandao2y = 30,
			qiandao9y = 35,
			qiandao16y = 40,
			qiandao23y = 45,
			qiandao30y = 50,
			qiandao37y = 60,
			qiandao44y = 70
		})
		PopText("元宝 + "..tostring(num))
	end
end

function SignInLayer:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function SignInLayer:__setRuleFunc()
	self.Image_rule:releaseFunc(function()
        self:__showRule()
    end)
end

function SignInLayer:__showRule()
	PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("活动规则")
        layer:showPanel_1(self.__ruleInfo)
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

Helper:classDefNodeGetInstance(SignInLayer)

return SignInLayer0