local TaskUI = require("app.views.ui.TaskUI")
local Task = require("app.models.task.Task")
local Item = require("app.models.item.Item")
local Resource = require("app.Resource")
-- local TaskGuajiLayer = require("app.views.layer.TaskLayer.TaskGuajiLayer")
-- local TaskZhuXianLayer = require("app.views.layer.TaskLayer.TaskZhuXianLayer")
local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
local DialogBLayer = require("app.views.layer.DialogLayer.DialogBLayer")
local AttrLayer = require("app.views.layer.AttrLayer.AttrLayer")
local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")


local TaskLayer = class("TaskLayer", cc.Layer)

local TASK_BUTTON_STATE_NONE = 1
local TASK_BUTTON_STATE_DISABLE = 2
local TASK_BUTTON_STATE_ENABLE = 3
local TASK_BUTTON_STATE_EFFECT = 4

function TaskLayer:create()
	local p = TaskLayer:new()
	p:init()
	return p
end

function TaskLayer:init()
	local TaskUI = TaskUI:create()
	self._UI = TaskUI
	TaskUI:addTo(self)
	self.TaskUI = TaskUI

	self:initTask(1)

	self:schedule(
    	function(ft)
    		self:update(ft)
    	end, 0)

	-- TaskGuajiLayer:getInstance():hide()
end

function TaskLayer:initTask(count)
	self._taskButtons = {}
	local role = User:getRole()
	self.TaskUI.ListView_task:removeAllItems()

	if PRINT_MODE == 1 then
		print("count = "..tostring(count))
	end

	local list = Task:getTaskList()
	if not count then
		count = #list
	end

	for i, task in ipairs(list) do
		if i <= count then
			local taskButton
			if task.type == "主线任务" and role:getNumAttr("jindu") and role:getNumAttr("jindu") > task.jindu then
				taskButton = self:createZhuXianButton(task)
				taskButton.task = task
				self.TaskUI.ListView_task:pushBackCustomItem(taskButton)
				table.insert(self._taskButtons, taskButton)

				taskButton.state = TASK_BUTTON_STATE_ENABLE
			end
		end
	end

	for i, task in ipairs(list) do
		-- print(task.name)
		if i <= count then
			local taskButton

			if task.type ~= "主线任务" then
				-- taskButton = self:createZhuXianButton(task)
				taskButton = self:createTaskButton(task)
				taskButton.task = task
				self.TaskUI.ListView_task:pushBackCustomItem(taskButton)

				table.insert(self._taskButtons, taskButton)

				taskButton.state = TASK_BUTTON_STATE_ENABLE
			end
		end
	end
end

--接受主线任务处理
function TaskLayer:zhuXianAccept(task)
	if not task then
		return
	end

	local role = User:getRole()

	local func = function()
		-- 玩家状态标记为已接受
		task:acceptTask()
		-- 按钮改为进行中

		PopupLayerController:showLayer("TaskZhuXianLayer", function(layer)
			layer:show(task, MainControllLayer)
		end)
	end
	if User:getRole():isInCurrState(ROLE_CURR_STATE_SHIMEN) == true then
		PopText("请先完成师门任务")
		return
	end
	RoleTaskControllor:clickZhuXianTask(func, task.id)
end

--创建主线任务栏目
function TaskLayer:createZhuXianButton(task)
	local button = ccui.Button:create(Resource:getImgPath("button1"))
	local buttonSize = button:getContentSize()

	local imgButtonA = ccui.LoadingBar:create(Resource:getImgPath(task.buttonA))
	local imgButtonB = ccui.ImageView:create(Resource:getImgPath(task.buttonB))

	button:addChild(imgButtonB)
	button:addChild(imgButtonA)
	imgButtonB:move(cc.p(300, buttonSize.height / 2))
	imgButtonA:move(cc.p(300, buttonSize.height / 2))
	imgButtonA:setPercent(100)

	-- 按钮
	local acceptButton = Resource:getUIByName("Button_5")
	Helper:convertUI(acceptButton)

	-- 文本
	local text = Resource:getTextByStyleName("taskButton")
	text:setTextAreaSize(cc.size(300, buttonSize.height))
	text:setTextHorizontalAlignment(1)
	text:setTextVerticalAlignment(1)

	text:setString("")
	button:addChild(text)
	text:move(cc.p(786, buttonSize.height / 2))

	-- acceptButton.Text_buttonName:setAnchorPoint(0.5000, 0.5000)
	acceptButton.Text_buttonName:setPosition(75, 75)
	acceptButton:setSize({width = 149, height = 143})
	button:addChild(acceptButton)
	acceptButton:move(cc.p(800, buttonSize.height / 2))

	button.state = TASK_BUTTON_STATE_NONE

	button.imgA = imgButtonA
	button.imgB = imgButtonB
	button.acceptButton = acceptButton
	button.text = text

	task:updateCount()

	acceptButton:releaseFunc(
		function()
			local role = User:getRole()
			if DEBUG_MODE == 2 then
				if role:getNumAttr("jindu") and role:getNumAttr("jindu") <= task.jindu then
					PopText(task.warnText)
					return
				end
			end
			local style = Task:getTaskStyle(task.id)
			if style == "待提交" then
				local dialog = DialogALayer:getInstance()
				dialog:show("是否提交任务")
				dialog:setButton1("是", function()
					if PRINT_MODE == 1 then
						print("是的，我提交任务")
					end
					task:submitTask()
				end)
				dialog:setButton2("否", function()
					if PRINT_MODE == 1 then
						print("暂时我还不提交任务")
					end
				end)
			elseif style == "已完成" then
				PopText("你今天已达到完成次数上限，请明天再来。")
			else
				self:zhuXianAccept(task)
			end
		end)

	function button:refresh()
		local task = self.task
		local style = Task:getTaskStyle(task.id)
		self.acceptButton:setTouchEnabled(true)
		local roleTask = Task:getRoleTask(task.id)
		if style == "已接受" then
			if self.style ~= style then
				self.acceptButton.Text_buttonName:setString("进行中")
				self.text:setString("")
				self.acceptButton:setVisible(true)
			end
		elseif style == "待提交" then
			if self.style ~= style then
				self.acceptButton.Text_buttonName:setString("任务完成")
				self.text:setString("")
				self.acceptButton:setVisible(true)
			end
		elseif style == "冷却中" then
			if 1 then--self.style ~= style then
				if PRINT_MODE == 1 then
					print("测试冷却时间---------------------------")
				end
				-- self.acceptButton.Text_buttonName:setString("冷却中")
				self:setTouchEnabled(false)
				--self.text:setString("冷却中...")
				-- self.acceptButton:setTouchEnabled(false)
				self.text:setString(task:getCoolDownDsc())
				self.acceptButton:setVisible(false)
			end
			self.imgA:setPercent((GetTime() - roleTask.startTime) / task.coolDown * 100) --冷却时间从完成任务后开始时计算
		elseif style == "已完成" then
			self.acceptButton.Text_buttonName:setString("已完成")
			self.text:setString("")
			self:setTouchEnabled(true)
			self.acceptButton:setVisible(true)
		else
			self.acceptButton.Text_buttonName:setString("接受")
			self.text:setString("")
			self:setTouchEnabled(true)
			self.acceptButton:setVisible(true)
		end
		self.style = style
	end

	return button
end

-- 挂机方法
local function guaJiFunc(task, button)
	local role = User:getRole()
	if role:getBuffAttr("xingzhenGuaJi") >= 1 then
		PopText("受行针走穴影响，你浑身乏力，想必一段时间内无法再行动了。")
		return 
	end
	-- 关卡限制挂机的接取
	local tabs =
	{
		task4 = "fb01",
		task5 = "fb03",
		task6 = "fb05",
		task7 = "fb10",
		task8 = "fb12",
		task9 = "fb15",
		task10 = "fb18",
		task11 = "fb20",
		task12 = "fb20", -- add by LvBin 2018/12/04 18:33:20 改成通过第二十章解锁
	}

	if DEBUG_MODE ~= 1 and tabs[task.id] and Map:getMapState(tabs[task.id]) ~= MAP_STATE.COMPLETE then
		local mapId = tabs[task.id]

		local volumeId = Map:getVolumeIdByMapId(mapId)

		local volumeInfo = Map:getVolumeByVolumeId(volumeId)

		local mapDefaultInfo = Map:getDefaultMapById(mapId)

		PopText("需通关“"..volumeInfo.name.."”"..mapDefaultInfo.title.."才能接取该任务")
		return
	end

	if task.id == "task1" or task.id == "task2" or task.id == "task3" or task.id == "task4" or task.id == "task5" then
		RoleTaskControllor:clickGuaJiLayer(function() button:guaji() end)
	else
		local dialogB = DialogBLayer:getInstance()
		local kongfu= User:getRole():getKongfuDsc()

		local reward = task:getGuajiReward()
		local list = {}
		if kongfu then
			table.insert(list, {title = "人物评价", num = kongfu})
		end
		if reward then
			local buff = User:getRole():getInheritBuff()
			table.insert(list, {title = "成长速度", num = math.floor(reward.avgExp*3600 * buff).."经验值/小时"})
			table.insert(list, {title = "最高成长速度", num = math.floor(reward.maxExp*3600 * buff).."经验值/小时"})
			end

		dialogB:show(list)
		dialogB:setButton1("开始挂机", function()
			RoleTaskControllor:clickGuaJiLayer(function() button:guaji() end)
		end)
		dialogB:setButton2("取消")
	end


end

-- 创建挂机任务按钮
function TaskLayer:createTaskButton(task)
	local currTaskLayer = self

	local button = ccui.Button:create(Resource:getImgPath("button1"))
	local buttonSize = button:getContentSize()

	-- 图片
	-- local imgButtonA = cc.ProgressTimer:create(cc.Sprite:create(Resource:getImgPath(task.buttonA)))
	local imgButtonA = ccui.LoadingBar:create(Resource:getImgPath(task.buttonA))
	local imgButtonB = ccui.ImageView:create(Resource:getImgPath(task.buttonB))

	button:addChild(imgButtonB)
	button:addChild(imgButtonA)
	imgButtonB:move(cc.p(300, buttonSize.height / 2))
	imgButtonA:move(cc.p(300, buttonSize.height / 2))
	imgButtonA:setPercent(100)

	-- 文本
	local text = Resource:getTextByStyleName("taskButton")
	text:setTextAreaSize(cc.size(300, buttonSize.height))
	text:setTextHorizontalAlignment(1)
	text:setTextVerticalAlignment(1)

	text:setString("奖励:碎银100 潜力100")
	button:addChild(text)
	text:move(cc.p(786, buttonSize.height / 2))

	-- 按钮
	local guajiButton = ccui.Button:create(Resource:getImgPath("taskGuaJi"))
	button:addChild(guajiButton)
	guajiButton:move(cc.p(800, buttonSize.height / 2))

	button.state = TASK_BUTTON_STATE_NONE

	button.imgA = imgButtonA
	button.imgB = imgButtonB
	button.text = text
	button.guajiButton = guajiButton

	function button:setTitlePercent(percent)
		local imgA = button.imgA
		return imgA:setPercent(percent)
	end

	function button:getTitlePercent()
		local imgA = button.imgA
		return imgA:getPercent()
	end

	function button:setUIState(name)
		if name == "work" then
			self.guajiButton:setVisible(false)
			self.text:setVisible(false)
		elseif name == "guaji" then
			self.guajiButton:setVisible(true)
			self.text:setVisible(false)
		elseif name == "disable" then
			self.guajiButton:setVisible(false)
			self.text:setVisible(false)
			self:setTitlePercent(0)
		end
	end

	function button:work()
		local task = self.task
		local ok, reward = Task:work(task.id)
		if ok then
			RichPrint("main", task:getStartWorkText())
			currTaskLayer:playRewardAnim(reward.exp, reward.pot, reward.money)
		end
	end

	function button:guaji()
		local task = self.task
		RichPrint("main", task:getStartGuajiText())
		PopupLayerController:showLayer("TaskGuajiLayer", function(layer)
			layer:setTaskId(task.id)
			layer:show(true)
		end)
		Task:guaji(task.id)
	end

	function button:refresh()
		local task = self.task
		local style = Task:getTaskStyle(task.id)

		if style == "可工作" then
			if self.style ~= style then
				self.guajiButton:setVisible(false)
				self.text:setOpacity(0)
				self.text:setVisible(true)
				self.text:setTextColor(cc.c4b(0, 0, 0, 255))
				self.text:setString(Task:getWorkRewardDsc(task.id))
				self:setTitlePercent(100)

				local actionTag = self.text:getActionTagByName("fade")
				self.text:stopActionByTag(actionTag)
				local action = cc.Sequence:create(cc.FadeIn:create(0.5))
				action:setTag(actionTag)
				self.text:runAction(action)

				self:releaseFunc(
				function()
					Audio:playEffect("daAnNiu")
					self:work()
				end)
			end
		elseif style == "可挂机" then
			if self.style ~= style then
				self.guajiButton:setVisible(true)
				self.text:setOpacity(255)
				self.text:setVisible(false)
				self:setTitlePercent(100)
				self.guajiButton:releaseFunc(
				function()
					Audio:playEffect("daAnNiu")
					guaJiFunc(task, self)
				end)
				self:releaseFunc(
					function()
						Audio:playEffect("daAnNiu")
					end
					)
			end
		elseif style == "冷却中" then
			if self.style ~= style then
				self.guajiButton:setVisible(false)
				self.text:setOpacity(0)
				self.text:setVisible(true)
				self.text:setTextColor(cc.c4b(0, 0, 0, 255))

				local actionTag = self.text:getActionTagByName("fade")
				self.text:stopActionByTag(actionTag)
				local action = cc.Sequence:create(cc.FadeIn:create(0.5))
				action:setTag(actionTag)
				self.text:runAction(action)

				self:releaseFunc(
					function()
						Audio:playEffect("daAnNiu")
						self:work()
					end
					)
			end
			local percent = Task:getTaskPercent(task.id)
			self:setTitlePercent(percent)
			self.text:setString(task:getCoolDownDsc())
			-- print("percent = "..tostring(percent))
		elseif style == "挂机中" then
			if self.style ~= style then
				self.guajiButton:setVisible(false)
				self.text:setOpacity(0)
				self.text:setVisible(true)
				self.text:setTextColor(cc.c4b(0, 0, 0, 255))
				self.text:setString(Task:getGuajiRewardDsc(task.id))
				self:setTitlePercent(100)

				self:releaseFunc(
				function()
					Audio:playEffect("daAnNiu")
					PopupLayerController:showLayer("TaskGuajiLayer", function(layer)
						layer:setTaskId(task.id)
						layer:show(true)
					end)
				end)

				local actionTag = self.text:getActionTagByName("fade")
				self.text:stopActionByTag(actionTag)
				local action = cc.Sequence:create(cc.FadeIn:create(0.5))
				action:setTag(actionTag)
				self.text:runAction(action)
			end
		elseif style == "不可用" then
			if self.style ~= style then
				self.guajiButton:setVisible(false)
				self.text:setOpacity(0)
				self.text:setVisible(true)
				self:setTitlePercent(0)
				self.text:setTextColor(cc.c4b(255, 0, 0, 255))
				self.text:setString(Task:getTaskConditionDsc(task.id))

				self:releaseFunc(
				function()
					Audio:playEffect("daAnNiu")
					local actionTag = self.text:getActionTagByName("fade")
					self.text:stopActionByTag(actionTag)
					local action = cc.Sequence:create(cc.FadeIn:create(0.5), cc.DelayTime:create(1), cc.FadeOut:create(0.5))
					action:setTag(actionTag)
					self.text:runAction(action)
				end)
			end
		end

		self.style = style
	end
	return button
end

function TaskLayer:update(ft)
	Task:update(ft)
	self:refreshUI(ft)
	self:updateTask(ft)
end

function TaskLayer:updateTask(ft)
	local taskButtons = self._taskButtons
	for i=1, #taskButtons do
		local taskButton = taskButtons[i]
		local task = taskButton.task
		local roleTask = Task:getRoleTask(task.id)
		taskButton:refresh()

		if task.type == "主线任务" then
		else
			if roleTask.state == TASK_STATE_DISABLE then
				local roleData = User:getRole():getData()
				if roleData.exp >= task.minExp then
					-- 尝试激活按钮
					local currPercent = taskButton:getTitlePercent()
					taskButton:setTitlePercent(currPercent + 3)
					if currPercent >= 100 then
						-- 激活完成
						roleTask.state = TASK_STATE_IDLE
					end
				end
			elseif roleTask.state == TASK_STATE_GUAJI then
				taskButton.text:setString(Task:getGuajiRewardDsc(task.id))
			end
		end
	end
end

function TaskLayer:refreshUI()
	local exp = User:getRole():getNumAttr("exp")
	local pot = User:getRole():getNumAttr("pot")
	local money = User:getRole():getNumAttr("money")

	self._UI:setTextExp(exp)
	self._UI:setTextPot(pot)
	self._UI:setTextMoney(money)

	-- self.TaskUI.ListView_task:removeAllItems()
	-- local role = User:getRole()
	--
	if exp < 1000 and not self.Init_State1 then
		self.Init_State1 = true
		self:initTask(1)
	elseif exp >= 1000 and not self.Init_State1 then
		self.Init_State1 = true
		self:initTask(1)
	elseif exp < 2000 and exp >= 1000 and not self.Init_State2 then
		self.Init_State2 = true
		self:initTask(2)
	elseif not self.Init_State3 and exp >= 2000 then
		self.Init_State3 = true
		self:initTask()
	else
	end
end

function TaskLayer:playRewardAnim(exp, pot, money)
	local function _playRewardAnim(root, value)
		-- if root.animText == nil then
		root.animText = Resource:getTextByStyleName("taskRewardAnim")
		root:getParent():addChild(root.animText)
		root.animText:setAnchorPoint(cc.p(0, 0.5))
		-- end
		root.animText:setString("+"..tostring(exp)) -- 设置字符

		local x, y = root:getPosition()
		x = x + root:getContentSize().width - root.animText:getContentSize().width
		root.animText:setPosition(cc.p(x, y))



		-- 动画
		root.animText:setOpacity(255)

		local actionTag = root.animText:getActionTagByName("taskRewardAnim")
		local showAction = cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, 80)), cc.FadeOut:create(0.5))
		local hideAction = cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, -50)))
		local action = cc.Sequence:create(showAction, cc.RemoveSelf:create(true))
		action:setTag(actionTag)
		root.animText:runAction(action)
	end

	if exp and exp ~= 0 then
		_playRewardAnim(self._UI.Text_exp, exp)
	end
	if pot and pot ~= 0 then
		_playRewardAnim(self._UI.Text_pot, pot)
	end
	if money and money ~= 0 then
		_playRewardAnim(self._UI.Text_money, money)
	end
end

function TaskLayer:onResume()
	self.Init_State1 = false
	self.Init_State2 = false
	self.Init_State3 = false
	if PRINT_MODE == 1 then
		-- print("1111111111111111111111111111111")
	end
end

Helper:classDefNodeGetInstance(TaskLayer)

-- 加密标记
TaskLayer.isEncrypted = true
return TaskLayer
000000000000