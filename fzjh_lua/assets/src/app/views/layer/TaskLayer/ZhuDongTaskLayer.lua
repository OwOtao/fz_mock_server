-- 挂机任务中的  江湖送信;缉拿恶徒;南阳匪乱;飞贼横行 整合进新页面  历练 中
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


local ZhuDongTaskLayer = class("ZhuDongTaskLayer", cc.Layer)

local TASK_BUTTON_STATE_NONE = 1
local TASK_BUTTON_STATE_DISABLE = 2
local TASK_BUTTON_STATE_ENABLE = 3
local TASK_BUTTON_STATE_EFFECT = 4

function ZhuDongTaskLayer:create()
	local p = ZhuDongTaskLayer:new()
	p:init()
	return p
end

function ZhuDongTaskLayer:init()
	local TaskUI = TaskUI:create()
	self._UI = TaskUI
	TaskUI:addTo(self)
	
	self.TaskUI = TaskUI
	self._rankings = {}
	-- self:setVisible(false)
	self.__currTitle = "任务" --  当前界面标题
	self.__oldOffset = 0 --  记录上一次抬头的坐标值
	self:initMonitorPool()
	self:schedule(
		function(ft)
			self:update(ft)
		end, 0)
   
end



function ZhuDongTaskLayer:initTask(count,title)
	local role = User:getRole()
	if PRINT_MODE == 1 then
		print("count = "..tostring(count))
	end

	local index
	if title == "任务" then
		index =1 
	elseif title == "历练" then
		index =2
	else 
		index =1 
	end

	local exp = role:getExp()
	local list = Task:getTaskList()
	local taskList, totalCount = {}, 0
	do
		for i,task in ipairs(list) do
			if title == "历练" and task.type == "主线任务" then
				totalCount = totalCount + 1
				if Map:getMapState(task.jindu) == MAP_STATE.COMPLETE then
					--限时主线任务位置提前
					--@desc 主线任务满足开启条件时应该设置成空闲状态
					local roleTask = role:getTask(task.id)
					if roleTask.state == TASK_STATE_DISABLE then
						roleTask.state = TASK_STATE_IDLE
					end

					if task.id =="task18" then
						if  GetTime() < Helper:getTimeStampWithStringDate("20180206", 0) then  --GetTime() > Helper:getTimeStampWithStringDate("20180117", 0)  and
							table.insert(taskList,2,task)
						else
							role:setFlag("隐藏孝敬按钮",1)
						end
					else
						table.insert(taskList, task)
					end
				end
			elseif title == "任务" and task.type == "挂机任务" then
				totalCount = totalCount + 1
				if (exp < 1000 and i > 1) or (exp < 2000 and exp >= 1000 and i > 2) then
					break
				else
				end
				table.insert(taskList, task)
			end
		end
	end
	count = Helper:getDef(count, #taskList)

	local taskLayerChildUI
	local layout = self.TaskUI.PageView_ranking:getPageByIndex(index-1)
	if layout ==  nil then
		layout = ccui.Layout:create()
		self.TaskUI.PageView_ranking:addPage(layout)
		taskLayerChildUI = require("Layer/TaskUI/TaskUI_child.lua").create()['root']
		Helper:convertUI(taskLayerChildUI)
		taskLayerChildUI.ListView_task:setSwallowTouches(false)
		taskLayerChildUI.ListView_task:removeAllItems()
		layout:addChild(taskLayerChildUI)
		self:delayFunc(0.1, function()
			self._UI.PageView_ranking:playScrollPageAnim(index-1)
		end)
	else
		taskLayerChildUI = layout:getChildren()[1]
		taskLayerChildUI.ListView_task:setSwallowTouches(false)
	end
	
	if #taskLayerChildUI.ListView_task:getItems() ~= count then
		taskLayerChildUI.ListView_task:removeAllItems()
		for i,task in ipairs(taskList) do
			local taskButton 
			if task.type == "主线任务" then
				taskButton = self:createZhuXianButton(task)
			elseif task.type == "挂机任务" then
				taskButton = self:createTaskButton(task)
			else
				break
			end
			taskButton.task = task
			taskLayerChildUI.ListView_task:pushBackCustomItem(taskButton)
			taskButton.state = TASK_BUTTON_STATE_ENABLE
		end
	end

	self._taskButtons = taskLayerChildUI.ListView_task:getItems()
end

--接受主线任务处理
function ZhuDongTaskLayer:zhuXianAccept(task)
	if not task then
		return
	end

	local role = User:getRole()

	local func = function()
		-- 玩家状态标记为已接受
		task:acceptTask()
		-- 按钮改为进行中

		PopupLayerController:showLayer("TaskZhuXianLayer", function(layer)
			layer:show(task)
		end)
	end
	if User:getRole():isInCurrState(ROLE_CURR_STATE_SHIMEN) == true then
		PopText("请先完成师门任务")
		return
	end
	RoleTaskControllor:clickZhuXianTask(func, task.id)
end

--创建主线任务栏目
function ZhuDongTaskLayer:createZhuXianButton(task)
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
	acceptButton.Text_buttonName:enableOutline(cc.c4b(26, 26, 26, 255), 5)

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
				if Map:getMapState(task.jindu) ~= MAP_STATE.COMPLETE then
					PopText(task.warnText)
					return
				end
			end
			local style = Task:getTaskStyle(task.id)
			if style == "待提交" then
				if task.id == "task15" and role:isInCurrState(ROLE_CURR_STATE_ZHUDONG) == true then
					PopText("正在进行其他主动任务，不能领取奖励")
					return
				else
				end
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
				if task.id == "task15" then
					PopText("你本周已完成，请下周再来。")
				else
					PopText("你今天已达到完成次数上限，请明天再来。")
				end
			elseif style == "已派遣" then
				PopText("该任务已派遣")
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
		elseif style == "已派遣" then
			self.acceptButton.Text_buttonName:setString("已派遣")
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
	if User:getRole():getBuffAttr("xingzhenGuaJi") >= 1 then
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
		task12 = "fb20",
	}
	if DEBUG_MODE ~= 1 and tabs[task.id] and Map:getMapState(tabs[task.id]) ~= MAP_STATE.COMPLETE then
		local mapId = tabs[task.id]

		local volumeId = Map:getVolumeIdByMapId(mapId)

		local volumeInfo = Map:getVolumeByVolumeId(volumeId)

		local mapDefaultInfo = Map:getDefaultMapById(mapId)

		PopText("需通关“"..volumeInfo.name.."”"..mapDefaultInfo.title.."才能接取该任务")
		return
	end
	
	-- 开始挂机动作
	if PRINT_MODE == 1 then
		print(task.id)
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
			local maxExp = math.floor(reward.maxExp*3600 * buff)
			-- local num = math.min(math.floor((reward.avgExp + role:getBuffAttr("xingzhenGuaJiSY"))*3600 * buff),maxExp)
			local num = math.floor(reward.avgExp *3600 * buff)
			if role:getBuffAttr("xingzhenGuaJiSY") == 0 then 
			    num = math.floor(reward.avgExp *3600 * buff)
			else
				num =  math.min(math.floor(num +(num * role:getBuffAttr("xingzhenGuaJiSY")),maxExp))
			end
			table.insert(list, {title = "成长速度", num = num.."经验值/小时"})
			table.insert(list, {title = "最高成长速度", num = maxExp.."经验值/小时"})
			end

		dialogB:show(list)
		dialogB:setButton1("开始挂机", function()
			RoleTaskControllor:clickGuaJiLayer(function() button:guaji() end)
		end)
		dialogB:setButton2("取消")
	end


end

-- 创建挂机任务按钮
function ZhuDongTaskLayer:createTaskButton(task)
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
	local guajiButton = Resource:getUIByName("Button_5")
	Helper:convertUIByParent(guajiButton)

	guajiButton.Text_buttonName:setPosition(75, 75)
	guajiButton:setSize({width = 149, height = 143})
	guajiButton:move(cc.p(800, buttonSize.height / 2))

	-- local guajiButton = ccui.Button:create(Resource:getImgPath("taskGuaJi"))
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

	-- function button:setUIState(name)
	-- 	if name == "work" then
	-- 		self.guajiButton:setVisible(false)
	-- 		self.text:setVisible(false)
	-- 	elseif name == "guaji" then
	-- 		self.guajiButton:setVisible(true)
	-- 		self.text:setVisible(false)
	-- 	elseif name == "disable" then
	-- 		self.guajiButton:setVisible(false)
	-- 		self.text:setVisible(false)
	-- 		self:setTitlePercent(0)
	-- 	end
	-- end

	function button:work()
		local task = self.task
		RichPrint("main", task:getStartWorkText())
		local ok, reward = Task:work(task.id)
		if ok then
			currTaskLayer:playRewardAnim(reward.exp, reward.pot, reward.money)
		end
	end

	function button:guaji()
		local task = self.task
		RichPrint("main", task:getStartGuajiText())
		-- 新手提示
		if task.id == "task2" and  User:getRole():getInheritFlag("新手引导") == 1  then
			User:getRole():setInheritFlag("新手引导",2)
			RichPrint("main", "YEL酒馆老板：听闻最近江湖各大派都在招收弟子，看你年轻力壮，不考虑HIR加入一个门派NORYEL闯荡一番吗？")
		end
	
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
				self.guajiButton.Text_buttonName:setString("挂 机")
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
		elseif style == "已派遣" then
			if self.style ~= style then
				self.guajiButton:setVisible(true)
				self.guajiButton.Text_buttonName:setString("已派遣")
				self.text:setOpacity(0)
				self.text:setVisible(true)
				self.text:setTextColor(cc.c4b(0, 0, 0, 255))

				local actionTag = self.text:getActionTagByName("fade")
				self.text:stopActionByTag(actionTag)
				local action = cc.Sequence:create(cc.FadeIn:create(0.5))
				action:setTag(actionTag)
				self.text:runAction(action)
				self.guajiButton:releaseFunc(
				function()
					PopText("该任务已派遣")
				end)
				self:releaseFunc(
					function()
						PopText("该任务已派遣")
					end
					)
			end
		end

		self.style = style
	end
	return button
end

function ZhuDongTaskLayer:update(ft)
	Task:update(ft)
	
	self.monitorPool:update()
	self:updateTask(ft)
	self:updateCategory()
	self:updateCurrPageData()
	self:refreshUI(ft)
	-- print(" self.__currTitle:".. self.__currTitle)
end

function ZhuDongTaskLayer:updateTask(ft)
	-- local taskButtons
	-- if self.__currTitle == "任务" then
	-- 	taskButtons = self._taskButtons
	-- elseif self.__currTitle == "历练" then
	-- 	taskButtons = self._lilianTaskButtons
	-- end
	local taskButtons = self._taskButtons
	if taskButtons ==  nil then
		return
	end
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
			elseif roleTask.state == TASK_STATE_DISPATCH then
				taskButton.text:setString("已派遣")
			end
		end
	end

end
function ZhuDongTaskLayer:initMonitorPool()
	local role = User:getRole()
	self.monitorPool = MonitorPool:create("ZhuDongTaskLayer")
	self.monitorPool:add(role, "exp", self, self.refreshUI)
	self.monitorPool:add(role, "pot", self, self.refreshUI)
	self.monitorPool:add(role, "money", self, self.refreshUI)
	
end
function ZhuDongTaskLayer:refreshUI()
	local exp = User:getRole():getNumAttr("exp")
	local pot = User:getRole():getNumAttr("pot")
	local money = User:getRole():getNumAttr("money")

	self._UI:setTextExp(exp)
	self._UI:setTextPot(pot)
	self._UI:setTextMoney(money)

	local title = self.__currTitle
	if exp < 1000 and not self.Init_State1 then
		self.Init_State1 = true
		self:initTask(1,title)
	elseif exp < 2000 and exp >= 1000 and not self.Init_State2 then
		self.Init_State2 = true
		self:initTask(2,title)
	elseif not self.Init_State3 and exp >= 2000 then
		self.Init_State3 = true
		self:initTask(nil,title)
	else
	end
	if self.isNeedRefresh==true then
		if self.Init_State3 == true then 
			self:initTask(nil,title)
		end
	end
end

function ZhuDongTaskLayer:playRewardAnim(exp, pot, money)
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

function ZhuDongTaskLayer:onResume()
	self.Init_State1 = false
	self.Init_State2 = false
	self.Init_State3 = false
	self.isNeedRefresh = true
	if PRINT_MODE == 1 then
		-- print("1111111111111111111111111111111")
	end
	self:refreshZhuDongTaskStatus()

	--@RefType 派遣任务检查
	local tasks = User:getRole():getTasks()
	--@RefType [app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager#DispatchTaskManager]
	local DispatchTaskManager = require("app.models.HomelandModel.DispatchTaskModel.DispatchTaskManager")
	for taskId,task in pairs(tasks) do
		if task.state == TASK_STATE_DISPATCH and task.endTime <= GetTime() then
			DispatchTaskManager:finishTask(taskId,task)
		end
	end

end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/12/19 17:34:21
-- @desc 刷新主动任务列表,页面唤醒的时候处理一次
function ZhuDongTaskLayer:refreshZhuDongTaskStatus()
	local taskButtons = self._taskButtons
	if taskButtons ==  nil then
		return
	end
	for i=1, #taskButtons do
		local taskButton = taskButtons[i]
		local task = taskButton.task
		if task.type == "主线任务" then
			task:updateCount()
		else
		end
	end
end



-- 及时更新标题和内容list
local lastTitle = ""
function ZhuDongTaskLayer:updateCurrPageData()
	if lastTitle == "" then
		lastTitle = self.__currTitle
	end

	if lastTitle ~= self.__currTitle then
		-- PopText("update内容")
		lastTitle = self.__currTitle
		
	end
end

-- 创建标题
function ZhuDongTaskLayer:createCategory(index, title)
	-- print("...createCategory")P
	if index == nil or title == nil then
		return
	end
	local ranking = self._rankings[index]
	local text = ranking.categoryText
	local Image_hongdian  = ranking.hongdian
	if text == nil and Image_hongdian == nil then
		text = ccui.Text:create(title, "Font/HYCFS.ttf", 60)
		text:setColor(cc.c3b(255, 255, 255))
		text:setAnchorPoint(0.5000, 0.5000)
		self._UI.Panel_category:addChild(text)
		ranking.categoryText = text
		text:enableOutline(cc.c4b(0, 0, 0, 255), 5) -- 描边无效, 不知道咋了.
		text:setTouchEnabled(true)
		
		--添加红点
		Image_hongdian = ccui.ImageView:create()
		Image_hongdian:ignoreContentAdaptWithSize(false)
		Image_hongdian:loadTexture("Image/UI/TeacherUI/hongdian.png",0)
		Image_hongdian:setLayoutComponentEnabled(true)
		Image_hongdian:setName("Image_hongdian")
		Image_hongdian:setTag(141)
		Image_hongdian:setCascadeColorEnabled(true)
		Image_hongdian:setCascadeOpacityEnabled(true)
		Image_hongdian:setPosition(130,60)
		Image_hongdian:setAnchorPoint(0.5000,0.5000)
		ranking.hongdian = Image_hongdian
		text:addChild(Image_hongdian)
		if User:getRole():getDayFlag("红点") == 0 then
			Image_hongdian:setVisible(true)
		else
			Image_hongdian:setVisible(false)
		end
		

	end

	if index == 1 then
		text:setFontSize(60)
		text:setOpacity(255)
		if Image_hongdian ~= nil then
			Image_hongdian:setVisible(false)
	    end
	else
		text:setFontSize(60)
		text:setOpacity(125)
	end

	text:releaseFunc(function()
	
		if User:getRole():getDayFlag("红点") == 0 then
			User:getRole():setDayFlag("红点",1)
			Image_hongdian:setVisible(false)
		end 
		self.__currTitle = title
		self:initcurrTitle(title, function()
			self._UI.PageView_ranking:playScrollPageAnim(index-1)
			self:delayFunc(0, function()
				self._UI.PageView_ranking:getPageByIndex(index-1)

			end)
		end)
		self:initTask(nil,title)

	end)
	
end
-- 刷新标题
function ZhuDongTaskLayer:updateCategory()
	-- print("function RankingUI:updateCategory()")
	if self._UI.PageView_ranking == nil then
		return
	end
		
	local offsetX = self._UI.PageView_ranking:getInnerContainerPosX()

	local totalWidth = #self._rankings * 1080
	local gapWidth = 200
	-- print("#self._rankings:"..#self._rankings)
	for i = 1, #self._rankings do
		local ranking = self._rankings[i]
		if ranking.categoryText then
			ranking.categoryText:setPositionY(self._UI.Panel_category:getContentSize().height / 2)
			ranking.categoryText:setPositionX((offsetX / 1080) * gapWidth + (i - 1) * gapWidth + display.width / 2 )--+ 340)

			-- 缩放效果
			local posX = ranking.categoryText:getPositionX()
			if posX > display.width / 2 - gapWidth and posX < display.width / 2 + gapWidth then
				local scale = 1 + 0.3 * (1 - math.abs(display.width / 2 - posX) / gapWidth)
			-- 	-- ranking.categoryText:setScale(scale)

				if scale > 1.2 then
					ranking.categoryText:setZ(5) -- 层级有点问题需要调整
					ranking.categoryText:setFontSize(60)
					ranking.categoryText:setOpacity(255)

					if self.__oldOffset == offsetX then
						self.__currTitle = ranking.name
						self.isNeedRefresh=false
					else
						self.__oldOffset = offsetX
						self.__currTitle = ranking.name
						self.isNeedRefresh=true
					end
				else
					ranking.categoryText:setZ(1)
					ranking.categoryText:setFontSize(60)
					ranking.categoryText:setOpacity(125)
				end
			else
				-- ranking.categoryText:setScale(1)
				ranking.categoryText:setZ(1)
				ranking.categoryText:setFontSize(60)
				ranking.categoryText:setOpacity(125)
			end
		end
	end
end
-- function ZhuDongTaskLayer:setButtonBack()
-- 	self._UI.Button_back:releaseFunc(function()
-- 		MainControllLayer:popLayer()
-- 	end)
-- end
function ZhuDongTaskLayer:initData(func)
	if	self.__currTitle == "" then
		self.__currTitle = "任务"
	end
	
	local list1 = Task:getTaskType()

	local index =1
	self._rankings = Helper:getDef(self._rankings, {})
	for k,v in pairs(list1) do
		self._rankings[index] = Helper:getDef(self._rankings[index], {})
		self._rankings[index].name = v.title
		self:createCategory(index, v.title)
		index = index + 1
		if index > #list1 then
			index = #list1
		end
		
		--未通关10章不显示历练
		local player = User:getRole()
		local lastMapState = player:getMapState("fb10")
		if lastMapState.isCompleted then
		else
			break
		end
	end
end
function ZhuDongTaskLayer:initcurrTitle(title, func)
	self:updateCategory()
	if func then
		func()
	end
end
Helper:classDefNodeGetInstance(ZhuDongTaskLayer)

-- 加密标记
ZhuDongTaskLayer.isEncrypted = true
return ZhuDongTaskLayer

000000000000000