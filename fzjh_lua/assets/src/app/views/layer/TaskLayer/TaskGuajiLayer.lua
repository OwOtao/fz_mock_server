local Resource = require("app.Resource")
local User = require("app.models.user.User")
local Task = require("app.models.task.Task")

local TaskGuajiLayer = class("TaskGuajiLayer", cc.Layer)

local GUAJI_TEXT_PRINT_STATE_START = 1
local GUAJI_TEXT_PRINT_STATE_WAIT = 2
local GUAJI_TEXT_PRINT_STATE_END = 3

local function print()
end

function TaskGuajiLayer:create()
	local p = TaskGuajiLayer:new()
	p:init()
	return p
end

function TaskGuajiLayer:init()
	self._round = require("Layer/TaskUI/TaskGuajiUI.lua").create()['root']
	self._round:addTo(self)
	Helper:convertUI(self) -- 获得所有子节点
	self:initRichText()

	-- 
	self.Button_back:releaseFunc(
		function()
			self:hide(true)
		end)

	self.Button_stopGuaji:releaseFunc(
		function()
			Audio:playEffect("xiaoAnNiu")
			self:stopGuaji()
		end)

	-- 变量定义
	self._printTextTb = 
	{	
		taskId = "",
		state = GUAJI_TEXT_PRINT_STATE_START,
		startTime = 0		
	}
	self:schedule(
		function(ft)
			self:update(ft)
		end, 0.1)

	self:setVisible(false)
end

function TaskGuajiLayer:initRichText()
	if self.RichText_print then
		self.RichText_print:removeFromParent()
	end

	local x, y = self.Panel_print:getPosition()
	local size = self.Panel_print:getContentSize()

	self.RichText_print = ExtRichTextScroll:create()
   	self.Panel_print:getParent():addChild(self.RichText_print)
   	self.RichText_print:move(cc.p(x, y))
   	self.RichText_print:setSize(size)   	
   	self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
   	self.RichText_print:getRichText():setVerticalSpace(5)
   	
	RegisterRichPrint("guaji", self, self.print)
end

local textColor = cc.c3b(102, 153, 153)
function TaskGuajiLayer:print(str, color)
	self.RichText_print:pushBackText(str, color, 255, Resource:getFontPath("default"), 42)
	self.RichText_print:pushBackNewLine(0)
end

function TaskGuajiLayer:show(anim)
	-- 临时解决 richText 问题
	self:initRichText()

	local role = User:getRole()
	-- self.RichText_print:getRichText():removeAllElement()
	self._printTextTb.state = GUAJI_TEXT_PRINT_STATE_START
	self._currRoleExp = role.exp
	self._currRolePot = role.pot
	self._currRoleMoney = role.money
	--print("role.exp"..role.exp)
	--print("role.exp"..role.pot)

	local actionTag = self:getActionTagByName("move")
	self:stopActionByTag(actionTag)
	if anim then
		local action = cc.Sequence:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(0, 0)), 
			cc.CallFunc:create(
				function()
					self:show()
				end))
		action:setTag(actionTag)
		self:runAction(action)	
	else
		self:move(cc.p(0, 0))
		self:resumeSelfAndChildren()
		self:setVisible(true)
	end	
end

function TaskGuajiLayer:hide(anim)
	PopupLayerController:hideLayer("TaskGuajiLayer")

	local actionTag = self:getActionTagByName("move")
	self:stopActionByTag(actionTag)
	if anim then
		local action = cc.Sequence:create(
			cc.MoveTo:create(UI_ANIM_DURATION, cc.p(0, display.height)), 
			cc.CallFunc:create(
				function()
					self:hide()
				end))
		action:setTag(actionTag)
		self:runAction(action)	
	else
		self:move(cc.p(0, display.height))
		self:pauseSelfAndChildren()
		self:setVisible(false)
	end	
end

function TaskGuajiLayer:setTaskId(id)
	self._taskId = id

	-- 新手引导提示 
	if id == "task2"  then
		PopText("自动挂机已开始，少侠可返回进行其他事情！")	
	end
end

function TaskGuajiLayer:update(ft)

	if PRINT_MODE == 1 then
		print("function TaskGuajiLayer:update(ft)")
	end



	--[[


	print("function TaskGuajiLayer:showDesc()")
	local currtaskId = self._taskId
	if currtaskId then
		local task = Task:getTask(currtaskId)
		local text = task:getRandPrintText("guajiing")
		local index = 1
		self:delayFunc(1, function()
			if type(text[index]) == "string" then
				self:print(text[index], cc.c3b(208, 208, 208))
			end
			if not task.interval then
				task.interval = 2
			end
			index = index + 1
			self:delayFunc(task.interval - 1, function()
				for i=index,#text do
					local str = text[i]
					if type(text) == "string" then
						self:print(str, cc.c3b(102, 153, 153))
					end
				end
				-- self:print("HIC你一共获得"..tostring(math.floor(exp)).."经验，"..tostring(math.floor(pot)).."潜能，"..tostring(math.floor(money)).."碎银。")
			end)
		end)
	end


	]]


	local currtaskId = self._taskId
	if PRINT_MODE == 1 then
		print("currtaskId = "..tostring(currtaskId))	
	end
	if currtaskId then
		local task = Task:getTask(currtaskId)
		local roleTask = Task:getRoleTask(currtaskId)
		self:setRightBottomText(roleTask)
		if PRINT_MODE == 1 then
			print("roleTask.state = "..tostring(roleTask.state))
		end
		if roleTask.state == TASK_STATE_GUAJI then

			local role = User:getRole()
			if not self._currRoleExp then
				self._currRoleExp = role.exp
				self._currRolePot = role.pot
				self._currRoleMoney = role.money
			end

			if self._printTextTb.taskId == task.id then
				-- 正在挂机
				if PRINT_MODE == 1 then
					print("self._printTextTb.state = "..self._printTextTb.state)
				end
				if self._printTextTb.state == GUAJI_TEXT_PRINT_STATE_START then
					self._printTextTb.texts = task:getRandPrintText("guajiing")
					self._printTextTb.currTextId = 1
					self._printTextTb.state = GUAJI_TEXT_PRINT_STATE_WAIT
					local text = self._printTextTb.texts[self._printTextTb.currTextId]
					local textType = type(text)
					if textType == "string" then
						self:print(text, cc.c3b(208, 208, 208))
					end
					self._printTextTb.currTextId = self._printTextTb.currTextId + 1
					self._printTextTb.startTime = GetTime()
					-- self:print(self._printTextTb.text[self._printTextTb.currTextId])
				elseif self._printTextTb.state == GUAJI_TEXT_PRINT_STATE_WAIT then
					local currTime = GetTime()
					local endTime = self._printTextTb.startTime + (task.interval -1)
					if currTime >= endTime then
						self._printTextTb.currTextId = self._printTextTb.currTextId + 1
						self._printTextTb.state = GUAJI_TEXT_PRINT_STATE_END
					end
				elseif self._printTextTb.state == GUAJI_TEXT_PRINT_STATE_END and role.exp ~= self._currRoleExp then
					local text = self._printTextTb.texts[self._printTextTb.currTextId]
					local textType = type(text)
					if textType == "string" then
						self:print(text, cc.c3b(102, 153, 153))
					end
					self:print("HIC你一共获得"..tostring(math.floor(role.exp) - math.floor(self._currRoleExp)).."经验，"..tostring(math.floor(role.pot) - math.floor(self._currRolePot)).."潜能，"..tostring(math.floor(role.money) - math.floor(self._currRoleMoney)).."碎银。")
					self._currRoleExp = role.exp
					self._currRolePot = role.pot
					self._currRoleMoney = role.money
					self._printTextTb.startTime = GetTime()
				elseif self._printTextTb.state == GUAJI_TEXT_PRINT_STATE_END then
					local currTime = GetTime()
					local endTime = self._printTextTb.startTime + 1
					if currTime >= endTime then
						self._printTextTb.state = GUAJI_TEXT_PRINT_STATE_START
					end
				end
			else
				-- 启动挂机
				self._printTextTb.taskId = task.id
				self._printTextTb.state = GUAJI_TEXT_PRINT_STATE_START
			end

		else
			self:autoStopGuaji() -- 停止挂机
		end
	end
end

function TaskGuajiLayer:stopGuaji()	
	self:hide(true)
	if self._taskId then
		local task = Task:getTask(self._taskId)
		task:stopGuaji()
		RichPrint("main", task:getRandPrintText("stopGuaji"))
		self._taskId = nil
	end
end

function TaskGuajiLayer:autoStopGuaji()
	self:hide(true)
	if self._taskId then
		local task = Task:getTask(self._taskId)
		task:stopGuaji()
		RichPrint("main", task:getRandPrintText("autoStopGuaji"))
		self._taskId = nil
	end
end

function TaskGuajiLayer:setRightBottomText(roleTask)
	local expStr, potStr, moneyStr = "", "", ""
	local str = ""	
	if roleTask.exp and roleTask.exp ~= 0 then
		local role = User:getRole()
		local task = Task:getTask(self._taskId)
		local reward = task:getGuajiReward()
		local buff = User:getRole():getInheritBuff()
		local maxExp = math.floor(reward.maxExp*3600 * buff)
		local  num = math.floor(roleTask.exp / roleTask.times * 3600)
		if role:getBuffAttr("xingzhenGuaJiSY") ~= 0 then
			if num + math.floor(num * role:getBuffAttr("xingzhenGuaJiSY")) > maxExp then
				expStr = maxExp.."经验 / 小时"
			else
				expStr = tostring(num + math.floor(num* role:getBuffAttr("xingzhenGuaJiSY"))).."经验 / 小时"
			end
		else
			expStr = num.."经验 / 小时"
		end
		-- expStr = tostring(math.floor(roleTask.exp / roleTask.times * 3600)).."经验 / 小时"
		str = str..expStr
	end
	if roleTask.pot and roleTask.pot ~= 0 then
		potStr = tostring(math.floor(roleTask.pot / roleTask.times * 3600)).."潜能 / 小时"
		str = str.."\n"..potStr
	end
	if roleTask.money and roleTask.money ~= 0 then
		moneyStr = tostring(math.floor(roleTask.money / roleTask.times * 3600)).."碎银 / 小时"
		str = str.."\n"..moneyStr
	end
	self.Text_rightBottom:setString(str)
end

Helper:classDefNodeGetInstance(TaskGuajiLayer)
return TaskGuajiLayer0000000