local StreetSnackLayer = class("StreetSnackLayer", cc.Layer)
function StreetSnackLayer:create()
	local p = StreetSnackLayer:new()
	p:init()
	return p
end
function StreetSnackLayer:init()
	local UI = require("Layer/ActionUI/Festival/StreetSnackUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	self:initRichText()
	self:setVisible(true)
	self:setQuitButton()
end
local MODE_A_NUM,MODE_B_NUM,MODE_C_NUM = 3,3,3 --模式节点人数
local ACTIVE_CUT_INTO_RATE = 70 --主动插队成功概率
local MODE_A_SUB_NUM,MODE_B_SUB_NUM,MODE_C_SUB_NUM = 6,5,4 --固定时间人数必定减1
function StreetSnackLayer:showLayer()
    if self.RichText_print then
        self.RichText_print:getRichText():removeAllElement()
    end
	self:setVisible(true)
	--点击背景打造界面隐藏
	self.Panel_back:releaseFunc(function (ref,eventType)
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		dialog:show("你要离开小吃摊么？")
		dialog:setBack(false)
		dialog:setButton1("确认" , function()
			for i=1,3 do
				local panel = self["Panel_queue"..i]
				panel.Button_do_0:setEnabled(true)
				panel.eventTimeCount = 0
				panel.addTimeCount = 0
				panel.addTime = 0
				panel.mode = ""
				panel.baseNum = 0
				panel.eventTime = 0
				panel.nowNum = 0
				panel.pos = nil
			end
			if self.failedFunc then
				self.failedFunc()
			end
			if self.handle ~= nil then
				self:unschedule(self.handle)
				self.handle = nil
			end
			PopupLayerController:hideLayer("StreetSnackLayer",function(layer)
				layer:hide()

			end)
		end)
		dialog:setButton2("取消" , function()
			if self.handle ~= nil then
				self:resumeSchedulerAndActions(self.handle)
			end
		end)
	
	end)
	self:show()
	self:start()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 22:23:09
-- @desc 游戏开始
function StreetSnackLayer:start()
	self.queue = nil
	self.time = 0
	self:setButtonMode()
	self:setSchedule()

	if self.RichText_print ~= nil then
		self.RichText_print:getRichText():removeAllElement()
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/17 13:27:22
-- @desc 设置游戏结果回调
function StreetSnackLayer:setResultCallFunc(successFunc,failedFunc)
	if type(successFunc) == "function" then
		self.successFunc = successFunc
	end
	if type(failedFunc) == "function" then
		self.failedFunc = failedFunc
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 11:53:47
-- @desc 游戏结束
function StreetSnackLayer:finish(result)
	if result == "成功" then
		if self.successFunc then
			self.successFunc()
		end
	else
		if self.failedFunc then
			self.failedFunc()
		end
	end

	for i=1,3 do
		local panel = self["Panel_queue"..i]
		panel.Button_do_0:setEnabled(true)
		panel.eventTimeCount = 0
		panel.addTimeCount = 0
		panel.addTime = 0
		panel.mode = ""
		panel.baseNum = 0
		panel.eventTime = 0
		panel.nowNum = 0
		panel.pos = nil
	end

	if self.handle ~= nil then
		self:unschedule(self.handle)
		self.handle = nil
	end
	PopupLayerController:hideLayer("StreetSnackLayer",function(layer)
		layer:hide()
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 00:08:43
-- @desc 时间调度
function StreetSnackLayer:setSchedule()
	self.handle = self:schedule(function()
		self.time = self.time + 1
		for i=1,3 do 
			local panel = self["Panel_queue" .. i]
			panel.eventTimeCount = panel.eventTimeCount + 1
			panel.addTimeCount = panel.addTimeCount + 1
			if panel.mode == "A" then
				if panel.addTimeCount >= panel.addTime then
					self:addOrSubQueueNum(panel)
				end 
				if self.time % MODE_A_SUB_NUM == 0 then --必然事件
					self:doLevelQueue(panel)
				end
				if panel.eventTimeCount >= panel.eventTime then--随机事件
					self:dealRandomEvent(panel)
				end
			end
			if panel.mode == "B" then
				if panel.addTimeCount == panel.addTime then
					self:addOrSubQueueNum(panel)
				end 
				if self.time % MODE_B_SUB_NUM == 0 then
					self:doLevelQueue(panel)
				end
				if panel.eventTimeCount >= panel.eventTime then--随机事件
					self:dealRandomEvent(panel)
				end
			end
			if panel.mode == "C" then
				if panel.addTimeCount>= panel.addTime then
					self:addOrSubQueueNum(panel)
				end  
				if self.time % MODE_C_SUB_NUM == 0 then
					self:doLevelQueue(panel)
				end
				if panel.eventTimeCount >= panel.eventTime then--随机事件
					self:dealRandomEvent(panel)
				end
			end

			if self.time % 3 == 0 and panel.mode == self.queue then
				self:printQueueInfo(panel)
			end
			self:setPanelNoeNumber(panel)
		end
	end,1)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 12:29:55
-- @desc 处理被动随机事件
function StreetSnackLayer:dealRandomEvent(panel)
	if panel.mode == self.queue then
		local weight = {}
		if panel.mode == "A" then
			weight = {[1] = 60,[2] = 30,[3] = 10}
		elseif panel.mode == "B" then
			weight = {[1] = 70,[2] = 20,[3] = 10}
		elseif panel.mode == "C" then
			weight = {[1] = 80,[2] = 10,[3] = 10}
		end
		local result = Helper:RandomByWeight(weight) 
		print("=============被动随机事件================",result)
		if result == 1 then
			--出发队伍签发有人离队事件
			panel.pos = panel.pos - 1
			if panel.pos <= 1 then
				self:finish("成功")
			else
				local str = "前方一位顾客似乎耐不住等待，直接离开了，你前方还有$n名客人正在等待。"
				str = string.gsub(str,"$n",tostring(panel.pos - 1))
				self:print(str)
			end
		elseif result == 2 then
			--出发被插队事件
			self:delaPassiveCuttingIntoQueue(panel)
			self:print("HIR你正好好地排着队，没想到一人竟挤到了你的前面！")
		end
	end
	self:setRandomEventTime(panel)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 14:07:07
-- @desc 处理被动插队
function StreetSnackLayer:delaPassiveCuttingIntoQueue(panel)
	if self.handle ~= nil then
		self:pauseSchedulerAndActions(self.handle)
	end
	local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
	local dialog = DialogALayer:getInstance()
	dialog:hide()
	dialog:show("有人想要插队")
	dialog:setBack(false)
	dialog:setButton1("不闻不问" , function()
		panel.pos = panel.pos + 1
		panel.nowNum = panel.nowNum + 1
		if self.handle ~= nil then
			self:resumeSchedulerAndActions(self.handle)
		end
		self:print("你对此不闻不问，假装没看见一样，那人排到了你的前面，你的前面还有"..tostring(panel.pos-1).."名顾客。")
	end)
	dialog:setButton2("上前制止" , function()
		local weight = {[1] = 45,[2] = 5,[3] = 5,[4] = 45}
		local result = Helper:RandomByWeight(weight) 
		print("================上前制止========================",result)
		if result == 1 then
			--
		elseif result == 2 then
			--成功但是要扣除200碎银
			-- local num = math.max(200,User:getRole():getNumAttr("money"))
			-- User:getRole():addAttr("money",0-num)
			-- PopText("碎银-"..num)
		elseif result == 3 then
			--失败，但是阅历+1,前方人数+1
			-- User:getRole():addAttr("yueli",1)
			-- PopText("江路阅历+1")
			panel.pos = panel.pos + 1
			panel.nowNum = panel.nowNum + 1
		elseif result == 4 then
			--失败，前方人数+1
			panel.pos = panel.pos + 1
			panel.nowNum = panel.nowNum + 1
		end
		if self.handle ~= nil then
			self:resumeSchedulerAndActions(self.handle)
		end
		self:logPassiveCuttingIntoQueue(panel,result)
	end)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 11:27:12
-- @desc 随机增减人数(非玩家选择的队伍)
function StreetSnackLayer:addOrSubQueueNum(panel)
	local randomNum = math.random(-2,2)
	-- randomNum = -2
	if randomNum + panel.baseNum < 0 then
		randomNum = 0 - panel.baseNum
	end

	if self.queue == panel.mode then
		if panel.pos < panel.baseNum + randomNum then
			panel.nowNum = randomNum + panel.baseNum
		end
		self:setRandomAddOrSubNumTime(panel)
	else
		panel.nowNum = randomNum + panel.baseNum
		self:setRandomAddOrSubNumTime(panel)
	end

	
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 10:52:05
-- @desc 输出当前所在队伍的信息
function StreetSnackLayer:printQueueInfo(panel)
	print("-------当前所在队伍的信息-------队伍共有--",panel.nowNum,"人，我的位置--",panel.pos)

	local str = ""
	local num = panel.pos - 1
	if num >= 20 then
		str = "你往前看去，前方还有X名顾客，看来还需等待很久。"
	elseif num < 20 and num >= 15 then
		str = "你往前看去，前方还有X名顾客，看来还需等待不少时间。"
	elseif num < 15 and num >= 10 then
		str = "你往前看去，前方还有X名顾客，看来还需等待一段时间。"
	elseif num < 10 and num >= 5 then
		str = "你往前看去，前方还有X名顾客，看来还需等待一些时间。"
	elseif num < 5 and num >= 1 then
		str = "你往前看去，前方还有X名顾客，看来用不了多久了。"
	end
	str = string.gsub(str,"X",tostring(num))
	-- RichPrint("main",str)
	self:print(str)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 11:11:19
-- @desc 模式固定时间间隔发生人数-1
function StreetSnackLayer:doLevelQueue(panel)
	if panel.pos then
		panel.pos = panel.pos -1
		panel.nowNum = panel.nowNum - 1
		if panel.pos <= 1 then
			-- add by XiaoZhiWei 2018/02/09 16:25:19 只有成功排队才能调用成功
			if self.queue == panel.mode then
				self:finish("成功")
			end
		else
			local str = "最前方的顾客已经购买完毕，你的前面还有$n名顾客正在等待。"
			str = string.gsub(str,"$n",panel.pos - 1)
			self:print(str)
		end
	end

	--输出购买完毕离队时间
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 22:22:19
-- @desc 随机按钮对应的模式
function StreetSnackLayer:setButtonMode()
	local modeList = {
		[1] = "A", -- 模式A：人数少，事件多模式
		[2] = "B",--模式B：普通模式
		[3] = "C" -- 模式C：人数高，来人快模式
	}
	local buttonList = {
		[1] = "Panel_queue1",
		[2] = "Panel_queue2",
		[3] = "Panel_queue3",
	}
	for k , panelName in ipairs(buttonList) do 
		local random = math.random(1,#modeList)
		if modeList[random] == nil then
			if DEBUG_MODE == 1 then
				print("-----------------------不知道什么原因模式列表出错了------------------------")
			end
			return
		end
		-- self[panelName].__panel_onlyId = panelName
		print("------------------panelNamepanelName--------------------",panelName)
		self:initButtonMode(self[panelName],modeList[random])
		table.remove(modeList,random)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 22:32:35
-- @desc 初始化按钮对应的模式
function StreetSnackLayer:initButtonMode(panel,mode)
	if mode == "A" then
			self:createButtonModeA(panel)
	elseif mode == "B" then
		self:createButtonModeB(panel)
	elseif mode == "C" then
		self:createButtonModeC(panel)
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 22:34:58
-- @desc 模式A按钮
function StreetSnackLayer:createButtonModeA(panel)
	if panel == nil then
		if DEBUG_MODE == 1 then
			print("---------------创建模式A容器panel不存在----------------")
		end
		return 
	end
	panel.nowNum = self:initQueueNumber("A")
	panel.baseNum = panel.nowNum
	panel.mode = "A"
	self:setPanelNoeNumber(panel)
	panel.Button_do:releaseFunc(function()
		-- self.queue = "A"
		self:chooseQueue(panel)
		self:logStartQueueText(panel)
	end)
	panel.Button_do.Text_button_name:setString("排队")
	self:setRandomEventTime(panel)
	self:setRandomAddOrSubNumTime(panel)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 22:34:58
-- @desc 模式B按钮
function StreetSnackLayer:createButtonModeB(panel)
	if panel == nil then
		if DEBUG_MODE == 1 then
			print("---------------创建模式B容器panel不存在----------------")
		end
		return 
	end
	panel.nowNum = self:initQueueNumber("B")
	panel.baseNum = panel.nowNum
	panel.mode = "B"
	self:setPanelNoeNumber(panel)
	panel.Button_do:releaseFunc(function()
		-- self.queue = "A"
		self:chooseQueue(panel)
		self:logStartQueueText(panel)
	end)
	panel.Button_do.Text_button_name:setString("排队")
	self:setRandomEventTime(panel)
	self:setRandomAddOrSubNumTime(panel)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 22:34:58
-- @desc 模式C按钮
function StreetSnackLayer:createButtonModeC(panel)
	if panel == nil then
		if DEBUG_MODE == 1 then
			print("---------------创建模式C容器panel不存在----------------")
		end
		return 
	end
	panel.nowNum = self:initQueueNumber("C")
	panel.baseNum = panel.nowNum
	panel.mode = "C"
	self:setPanelNoeNumber(panel)
	panel.Button_do:releaseFunc(function()
		self:chooseQueue(panel)
		self:logStartQueueText(panel)
	end)
	panel.Button_do.Text_button_name:setString("排队")
	self:setRandomEventTime(panel)
	self:setRandomAddOrSubNumTime(panel)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 23:09:00
-- @desc 选择队伍
function StreetSnackLayer:chooseQueue(panel)
	for i=1,3 do 
		if panel == self["Panel_queue"..i] then
			self.queue = panel.mode
			self:createButtonCuttingInto(self["Panel_queue"..i])
		else
			self["Panel_queue"..i].pos = nil
			self:createButtonChangeQueue(self["Panel_queue"..i])
		end
	end
end



-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 23:04:16
-- @desc 设置插队
function StreetSnackLayer:createButtonCuttingInto(panel)
	panel.Button_do_0:setEnabled(false)
	panel.Button_do.Text_button_name:setString("插队")
	panel.nowNum = panel.nowNum + 1
	panel.pos = panel.nowNum
	self:setPanelNoeNumber(panel)
	panel.Button_do:releaseFunc(function()
		self:doCuttingInto(panel)
	end)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 10:43:40
-- @desc 主动插队
function StreetSnackLayer:doCuttingInto(panel)
	panel.Button_do_0:setEnabled(false)
	local random = math.random(1,100)
	if random >= ACTIVE_CUT_INTO_RATE then
		--主动插队成功
		panel.pos = panel.pos - 1 
		print("------------------插队成功-----------------")
		--输出主动插队成功文本
		self:logActiveCuttingIntoQueue("success")
	else
		--自己动插队失败
		panel.pos = panel.nowNum  --主动插队失败回到队尾
		print("------------------插队失败-----------------")
		--输出文本
		self:logActiveCuttingIntoQueue("failed")
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 23:13:21
-- @desc 设置换队
function StreetSnackLayer:createButtonChangeQueue(panel)
	panel.Button_do_0:setEnabled(true)
	panel.Button_do.Text_button_name:setString("换到此队")
	panel.Button_do:releaseFunc(function()
		if self.handle ~= nil then
			self:pauseSchedulerAndActions(self.handle)
		end
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		dialog:show("换队需重新从该队伍最后开始排队，确定要换队么？")
		dialog:setBack(false)
		dialog:setButton1("确定" , function()
			for i=1,3 do 
				if self.queue == self["Panel_queue"..i].mode then
					self["Panel_queue"..i].nowNum = self["Panel_queue"..i].nowNum - 1
					self:setPanelNoeNumber(self["Panel_queue"..i])
					break
				end
			end
			self:chooseQueue(panel)
			self:logChangeQueueText(panel)
			if self.handle ~= nil then
				self:resumeSchedulerAndActions(self.handle)
			end
		end)
		dialog:setButton2("取消" , function()
			if self.handle ~= nil then
				self:resumeSchedulerAndActions(self.handle)
			end
		end)
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 10:53:40
-- @desc 设置随机事件时间
function StreetSnackLayer:setRandomEventTime(panel)
	local randomTime = 0
	if panel.mode == "A" then
		randomTime = math.random(1,5)
	elseif panel.mode == "B" then
		randomTime = math.random(1,7)
	elseif panel.mode == "C" then
		randomTime = math.random(1,10)
	end
	panel.eventTime = randomTime
	panel.eventTimeCount = 0
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 12:21:12
-- @desc 设置随机增减人数时间
function StreetSnackLayer:setRandomAddOrSubNumTime(panel)
	local randomTime = 0
	if panel.mode == "A" then
		randomTime = math.random(5,7)
	elseif panel.mode == "B" then
		randomTime = math.random(4,6)
	elseif panel.mode == "C" then
		randomTime = math.random(3,5)
	end
	panel.addTime = randomTime
	panel.addTimeCount = 0
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 22:56:10
-- @desc 设置队列当前显示的人数
function StreetSnackLayer:setPanelNoeNumber(panel)
	panel.Text_num:setString("现\n有\n"..panel.nowNum.."\n人")
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 22:37:55
-- @desc 初始化队列人数
function StreetSnackLayer:initQueueNumber(mode)
	local roomRoleNum
	if DEBUG_MODE == 1 then
		roomRoleNum = math.random(4,8)
	else
		local mapLayer = MainControllLayer:getLayer("MapLayer")
		roomRoleNum = Helper:getDef(#mapLayer._currRoom.playList,0)
	end
	local hour = tonumber(Helper:date("%H",GetTime()))
	local finalNum = 100
	if mode == "A" then
		if roomRoleNum > MODE_A_NUM then
			finalNum = roomRoleNum - 1
		else
			if hour >= 0 and hour < 1 then
				finalNum = math.random(8,10)
			elseif hour >= 1 and hour < 4 then
				finalNum = math.random(3,6)
			elseif hour >= 4 and hour < 8 then
				finalNum = math.random(3,6)
			elseif hour >= 8 and hour < 11 then
				finalNum = math.random(4,6)
			elseif hour >= 11 and hour < 12 then
				finalNum = math.random(3,6)
			elseif hour >= 12 and hour < 13 then
				finalNum = math.random(9,12)
			elseif hour >= 13 and hour < 18 then
				finalNum = math.random(4,6)
			elseif hour >= 18 and hour < 20 then
				finalNum = math.random(11,12)
			elseif hour >= 20 and hour < 22 then
				finalNum = math.random(6,8)
			elseif hour >= 22 and hour < 24 then
				finalNum = math.random(5,7)
			end
		end
	elseif mode == "B" then
		if roomRoleNum > MODE_B_NUM then
			finalNum = roomRoleNum
		else
			if hour >= 0 and hour < 1 then
				finalNum = math.random(3,3)
			elseif hour >= 1 and hour < 4 then
				finalNum = math.random(10,12)
			elseif hour >= 4 and hour < 8 then
				finalNum = math.random(3,8)
			elseif hour >= 8 and hour < 11 then
				finalNum = math.random(4,8)
			elseif hour >= 11 and hour < 12 then
				finalNum = math.random(3,8)
			elseif hour >= 12 and hour < 13 then
				finalNum = math.random(11,14)
			elseif hour >= 13 and hour < 18 then
				finalNum = math.random(4,8)
			elseif hour >= 18 and hour < 20 then
				finalNum = math.random(13,16)
			elseif hour >= 20 and hour < 22 then
				finalNum = math.random(7,10)
			elseif hour >= 22 and hour < 24 then
				finalNum = math.random(6,8)
			end
		end
	elseif mode == "C" then
		if roomRoleNum > MODE_B_NUM then
			finalNum = roomRoleNum + 3
		else
			if hour >= 0 and hour < 1 then
				finalNum = math.random(12,14)
			elseif hour >= 1 and hour < 4 then
				finalNum = math.random(5,10)
			elseif hour >= 4 and hour < 8 then
				finalNum = math.random(5,10)
			elseif hour >= 8 and hour < 11 then
				finalNum = math.random(6,11)
			elseif hour >= 11 and hour < 12 then
				finalNum = math.random(5,10)
			elseif hour >= 12 and hour < 13 then
				finalNum = math.random(14,17)
			elseif hour >= 13 and hour < 18 then
				finalNum = math.random(6,11)
			elseif hour >= 18 and hour < 20 then
				finalNum = math.random(18,21)
			elseif hour >= 20 and hour < 22 then
				finalNum = math.random(7,10)
			elseif hour >= 22 and hour < 24 then
				finalNum = math.random(6,8)
			end
		end
	end
	return finalNum
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 14:25:01
-- @desc 选择队伍开始排队文本
function StreetSnackLayer:logStartQueueText(panel)
	local str = "你走到队伍的最后方，开始等待了起来，你前面还有$n个人。"
	str = string.gsub(str,"$n",tostring(panel.pos - 1))
	self:print(str)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 14:32:52
-- @desc 换队输出文本
function StreetSnackLayer:logChangeQueueText(panel)
	local str = "你换了一只队伍，开始等待了起来，你前面还有$n个人。"
	str = string.gsub(str,"$n",tostring(panel.pos - 1))
	self:print(str)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 14:35:29
-- @desc 主动插队文本
function  StreetSnackLayer:logActiveCuttingIntoQueue(result)
	local text = {
		["success"] = {
			"HIC你一脸狞笑地拍了拍前面人的肩膀，那人被你这幅尊容吓到了，连忙退到一边，你趁机往前一挤，成功走到了前面。",
			"HIC你仗着武功高强，捡起了一块石子，当着你前面人的面碾成了粉末，那人被你的举动吓得说不出话，悻悻地走到了一旁，你成功走到了前面。",
			"HIC你用力挤开了前面的人，那人一脸可怜地看着你，欲言又止，止言又欲，最后还是默默地走了，你成功走到了前面。"
		},
		["failed"] = {
			"HIR你挺起胸膛撞向前面的人，没想到一股巨力传来，你被震飞了数丈有余，前面那人一脸讪笑地看着你，你拍了拍身上的尘土，爬了起来，重新排到了队伍的最后。",
			"HIR你冷笑地跟前面人示威，却没想到对方完全不吃这套，还大吵大闹引来了官差，在官差的注视下，你只得默默走到了队伍的最后。",
			"HIR你用力挤开了前面的人，那人义愤填膺，冲着你破口大骂，周围的人也围了上来，你在众人的指责下，只得灰溜溜地走到队伍最后重新排队。"

		}	
	}
	local list = Helper:getDef(text[result],{})
	local random = math.random(1,#list)
	self:print(list[random])
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 14:43:23
-- @desc 被动插队输出文本
function StreetSnackLayer:logPassiveCuttingIntoQueue(panel,randomNum)
	local textList = {
		[1] = "你见此状，连忙上前拉住这人，警告他不许插队，那人看了看你，自觉理亏，默默离开了，你的前面还有$n名顾客。",	
		[2] = "你见此状，连忙上前拉住这人，警告他不许插队，那人看了看你，自觉理亏，默默离开了，你的前面还有$n名顾客。",
		[3] = "你上前尝试阻止此人插队，却没想到此人不但武功高强，而且根本不讲道理，你无可奈何，只能让其过去了，你的前面还有$n名顾客。",
		[4] = "你上前尝试阻止此人插队，却没想到此人不但武功高强，而且根本不讲道理，你无可奈何，只能让其过去了，你的前面还有$n名顾客。",
	}
	local str = Helper:getDef(textList[randomNum],"")
	str = string.gsub(str,"$n",tostring(panel.pos-1))
	self:print(str)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/08 14:26:16
-- @desc 文本输出
local textColor = cc.c3b(102, 153, 153)
function StreetSnackLayer:print(str, verticalSpace)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 6888 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/12/15 15:54:45
-- @desc 初始化RichText
function StreetSnackLayer:initRichText()
	local x, y = self.Text_log_desc:getPosition()
	local size = self.Text_log_desc:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
   	self.Text_log_desc:getParent():addChild(richTextScroll)
   	richTextScroll:move(cc.p(x, y))
   	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(true)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/07 22:18:38
-- @desc 主动离开结束任务，默认未失败
function StreetSnackLayer:setQuitButton()
	self.Button_quit:releaseFunc(function()
		if self.failedFunc then
			self.failedFunc()
		end
		if self.handle ~= nil then
			self:unschedule(self.handle)
			self.handle = nil
		end
		PopupLayerController:hideLayer("StreetSnackLayer",function(layer)
			layer:hide()
		end)
	end)
end

Helper:classDefNodeGetInstance(StreetSnackLayer)
return StreetSnackLayer0000000000000