local GuaJiTaskProgressLayer = class("GuaJiTaskProgressLayer", cc.Layer)
local TeacherGuaJiTaskUtil = require("app.models.task.teacherGuaJiTask.TeacherGuaJiTaskUtil")

function GuaJiTaskProgressLayer:create()
	local p = GuaJiTaskProgressLayer:new()
	p:init()
	return p
end

function GuaJiTaskProgressLayer:init()
	self._round = require("Layer/TeacherTask/TeacherGuaJiTask/GuaJiTaskProgressUI.lua").create()['root']
	self._round:addTo(self)
	Helper:convertUIByParent(self)
	
	self:initRichText()
end

function GuaJiTaskProgressLayer:showLayer(task)
	self.currStepNum = 0 --当前进行的步骤
	self.rollTime = 8 --"文本滚动间隔时间 单位：帧"

	self.task = task
	self.rollTextType = 1 --当前文本滚动类型，1播放任务倾向文本，2播放知识倾向文本
	self:initRichText()

	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self:initButtonVisible()
	self:setButtonClose()
	self:setButtonCancel()

	self:setTitleName()
	self:setRewardText()
	self:setTongBanText()
	self:setZhiShiText()

	self._handle = self:schedule(function (ft)
		self:update()
	end,0)

	self:show()
end

--更新方法
function GuaJiTaskProgressLayer:update()
	self:initview()
end

function GuaJiTaskProgressLayer:initview()
	--刷新当前任务进程
	self:setCurrStepNum()

	--上方区域的滚动文本
	self:printTrendText()

	--下方区域的时间文本刷新
	self:setTimetext()
end

function GuaJiTaskProgressLayer:initRichText()
	if self.RichText_print then
		self.RichText_print:removeFromParent()
	end

	local x, y = self.Panel_print:getPosition()
	local size = self.Panel_print:getContentSize()

	self.RichText_print = ExtRichTextScroll:create()
   	self.Panel_print:getParent():addChild(self.RichText_print)
   	self.RichText_print:move(cc.p(x, y))
	self.RichText_print:setAnchorPoint(0.5,0.5)
   	self.RichText_print:setSize(size)   	
   	self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
   	self.RichText_print:getRichText():setVerticalSpace(5)
end

--输出任务倾向文本
function GuaJiTaskProgressLayer:printTrendText()
	if not self.time then
		self.time = 0
	end 
	self.time = self.time + 0.1
	if	self.time > self.rollTime then
		local stepId = self:getCurrStepId()
		local trendText1,trendText2 = TeacherGuaJiTaskUtil:getTaskTrendText(self.task,stepId)
		local str = ""
		if self.rollTextType == 1 then
			str = trendText1
			self.rollTextType = 2
		else
			str = trendText2
			self.rollTextType = 1
		end
		if self.time > self.rollTime then
			self.time = nil
			if str ~= nil and str ~= "" then
				str = "\n"..str
			else
				return
			end
		end

		--清除RichText缓存
		local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
		if textHeight >= 8888 then
			self:initRichText()
		end
		-- print("str     =  ",str)
		self.RichText_print:pushBackText(str, cc.c3b(255, 255, 255), 255, Resource:getFontPath("default"), 42)
		
	else
	
	end
	-- self.RichText_print:pushBackNewLine(0)
end

function GuaJiTaskProgressLayer:setTitleName()
	self.Text_title:setString(self.task.taskName)
end

function GuaJiTaskProgressLayer:setTimetext()
	local currTime = GetTime()
	local endTime = self.task.endTime 
	local time = endTime - currTime 
	if time <= 0 then
		time = 0
		self:setButtonOk()
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end
	end
	
	local hour, min,sec = Helper:sec2timeDsc(time)
	local text = hour.."小时"..min.."分钟"..sec.."秒"
	text = text.."才能完成"

	self.Text_TimeDsc_1:setString(text)
end

function GuaJiTaskProgressLayer:setRewardText()
	local rewadText = "无"

	local basicAwardMap = TeacherGuaJiTaskUtil:getBaseReward(self.task)
	local averageWCD = TeacherGuaJiTaskUtil:getTaskAverageWCD(self.task) --平均完成度

	local textList = {}
	local attrList = {}
	local role = User:getRole()

	if MapIsEmpty(basicAwardMap.loc_attr) == false then
		for attrName,value in pairs(basicAwardMap.loc_attr) do
			attrList[attrName] = value
		end
	end

	if MapIsEmpty(basicAwardMap.net_attr) == false then
		for attrName,value in pairs(basicAwardMap.net_attr) do
			attrList[attrName] = value
		end
	end

	for attrName,value in pairs(attrList) do
		local attrNameCH = role:getCHAttrName(attrName)
		local text = tostring(math.ceil(averageWCD*value))..attrNameCH
		table.insert( textList, text)
	end

	local extraAwardId = self.task.extraAward
	if extraAwardId == 0 then
	else
		table.insert( textList, "特殊道具（概率获得）")
	end

	if not MapIsEmpty(textList) then
		rewadText = ""
		for i,v in ipairs(textList) do
			if i == 1 then
				rewadText = v
			else
				rewadText = rewadText.."，"..v
			end
		end
	end

	if self.RichText_rewadText then
		self.RichText_rewadText:removeFromParent()
	end

	local x, y = self.Text_rewadText:getPosition()
	local size = self.Text_rewadText:getContentSize()

	self.RichText_rewadText = ExtRichTextScroll:create()
   	self.Text_rewadText:getParent():addChild(self.RichText_rewadText)
   	self.RichText_rewadText:move(cc.p(x, y))
	self.RichText_rewadText:setAnchorPoint(0.5,0.5)
   	self.RichText_rewadText:setSize(size)   	
   	self.RichText_rewadText:setDirection(kCCScrollViewDirectionVertical)
   	self.RichText_rewadText:getRichText():setVerticalSpace(5)
	   
	self.RichText_rewadText:pushBackText("预计获得：HIY"..rewadText, cc.c3b(255, 255, 255), 255, Resource:getFontPath("default"), 48)
end

function GuaJiTaskProgressLayer:setTongBanText()
	local teammate = TeacherGuaJiTaskUtil:getTaskTeammate(self.task)
	local teammateText = "无"
	if not MapIsEmpty(teammate) then
		teammateText = ""
		for i,v in ipairs(teammate) do
			if i == 1 then
				teammateText = v.name
			else
				teammateText = teammateText.."，"..v.name
			end
		end
	end
	
	if self.RichText_tongmenText then
		self.RichText_tongmenText:removeFromParent()
	end

	local x, y = self.Text_tongmenText:getPosition()
	local size = self.Text_tongmenText:getContentSize()

	self.RichText_tongmenText = ExtRichTextScroll:create()
   	self.Text_tongmenText:getParent():addChild(self.RichText_tongmenText)
   	self.RichText_tongmenText:move(cc.p(x, y))
	self.RichText_tongmenText:setAnchorPoint(0.5,0.5)
   	self.RichText_tongmenText:setSize(size)   	
   	self.RichText_tongmenText:setDirection(kCCScrollViewDirectionVertical)
   	self.RichText_tongmenText:getRichText():setVerticalSpace(5)

	self.RichText_tongmenText:pushBackText("同行人：HIY"..teammateText, cc.c3b(255, 255, 255), 255, Resource:getFontPath("default"), 48)
end

function GuaJiTaskProgressLayer:setZhiShiText()
	local knowlege = TeacherGuaJiTaskUtil:getTaskKnowlege(self.task)
	local knowlegeText = "无"
	if not MapIsEmpty(knowlege) then
		knowlegeText = ""
		local num = 1
		for skillId,v in pairs(knowlege) do
			local skill = Skill:getSkill(skillId)
			if skill == nil then
				assert(false,"技能id有误  skillId = "..skillId)
			end
			if num == 1 then
				knowlegeText = skill.name.."NOR"
			else
				knowlegeText = knowlegeText.."，"..skill.name.."NOR"
			end
			num = num + 1
		end
	end

	if self.RichText_zhishiText then
		self.RichText_zhishiText:removeFromParent()
	end

	local x, y = self.Text_zhishiText:getPosition()
	local size = self.Text_zhishiText:getContentSize()

	self.RichText_zhishiText = ExtRichTextScroll:create()
   	self.Text_zhishiText:getParent():addChild(self.RichText_zhishiText)
   	self.RichText_zhishiText:move(cc.p(x, y))
	self.RichText_zhishiText:setAnchorPoint(0.5,0.5)
   	self.RichText_zhishiText:setSize(size)   	
   	self.RichText_zhishiText:setDirection(kCCScrollViewDirectionVertical)
   	self.RichText_zhishiText:getRichText():setVerticalSpace(5)

	self.RichText_zhishiText:pushBackText("准备知识：HIY"..knowlegeText, cc.c3b(255, 255, 255), 255, Resource:getFontPath("default"), 48)
end

function GuaJiTaskProgressLayer:setCurrStepNum()
	local oneStepTime = TeacherGuaJiTaskUtil:calOneStepNeedTime(self.task.id)
	local currTime = GetTime()
	local startTime = self.task.startTime

	local num = math.floor((currTime - startTime)/oneStepTime)
	if num < 0 then
		assert(false,"当前时间小于任务开始时间")
	end

	if type(self.currStepNum) ~= "number" or self.currStepNum < num + 1 then
		--节点切换，刷新节点列表
		self.currStepNum = num + 1
		self:initStepList()
	end
end

function GuaJiTaskProgressLayer:getCurrStepId()
	local stepId
	local stepIdList = self:getTaskStepIdList()
	local finalStepNum = #stepIdList --步骤总数
	if self.currStepNum > finalStepNum then
		stepId = stepIdList[finalStepNum]
	else
		stepId = stepIdList[self.currStepNum]
	end
	return stepId
end

--节点列表  只有在切换节点的时候需要刷新
function GuaJiTaskProgressLayer:initStepList()
	self.ListView_TaskList:removeAllItems()
	local stepIdList = self:getTaskStepIdList()
	for i,stepId in ipairs(stepIdList) do
		local stepAttr = TeacherGuaJiTaskUtil:getStepAttrByStepId(stepId)
		local stepWCD = TeacherGuaJiTaskUtil:getStepWanChengDu(self.task,stepId)
		local stepDsc = TeacherGuaJiTaskUtil:getStepDscByStepWanChengDu(stepWCD)
		local panel = self.Panel_item:clone()
		Helper:convertUIByParent(panel)
		panel.Panel_ButtonDsc.Text_name:enableOutline({r = 0, g = 0, b = 0, a = 255}, 5)
		
		if self.currStepNum > i then
			--已经完成的步骤
			panel.Panel_ButtonDsc.Text_name:setString(stepAttr.stepName)
			panel.Text_stateDsc:setString(stepDsc)
		elseif self.currStepNum == i then
			--正在进行的步骤
			panel.Panel_ButtonDsc.Text_name:setString(stepAttr.stepName)
			panel.Text_stateDsc:setString("进行中")
		else
			--未开始的步骤
			panel.Panel_ButtonDsc.Text_name:setString("未开始")
			panel.Text_stateDsc:setString("")
		end
        self.ListView_TaskList:pushBackCustomItem(panel)
	end
end

--获取任务步骤id列表
function GuaJiTaskProgressLayer:getTaskStepIdList()
	local stepIdList = {}
	local taskId = self.task.id
	stepIdList = TeacherGuaJiTaskUtil:getTaskStepIdList(taskId)
	return stepIdList
end

function GuaJiTaskProgressLayer:hideLayer()
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end
	PopupLayerController:hideLayer("GuaJiTaskProgressLayer", function(layer)
		layer:hide()
	end)
end

function GuaJiTaskProgressLayer:setButtonClose()
	self.Button_close:releaseFunc(function()
		self:hideLayer()
	end)
end

--取消任务按钮
function GuaJiTaskProgressLayer:setButtonCancel()
	self.Button_cancel:releaseFunc(function()
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:hide()
		dialog:show("你确定要中断任务吗？（中断任务不会获得任何物品奖励，只会获得数值奖励。）")
		dialog:setButton1(
			"确定",
			function()

				if self.task.state ~= TASK_STATE_GUAJI then
					PopText("任务已完成，无法中断")
					return
				end

				self:hideLayer()
				
				TeacherGuaJiTaskUtil:cancelTask(self.task,function (isSuccess)
					--刷新任务列表
					local refreshTaskListFunc = TeacherGuaJiTaskUtil:getRefreshTaskListFunc()
					if refreshTaskListFunc then
						refreshTaskListFunc()
					end
				end)

			end
		)
		dialog:setButton2(
			"取消",
			function()
			end
		)
		dialog:setWeChatVisible(false)
	end)
end

--完成按钮
function GuaJiTaskProgressLayer:setButtonOk()
	self.Button_close:setVisible(false)
	self.Button_cancel:setVisible(false)
	self.Button_ok:setVisible(true)
	self.Button_ok:releaseFunc(function()
		TeacherGuaJiTaskUtil:completeTask(self.task,function ()
			--刷新任务列表
			local refreshTaskListFunc = TeacherGuaJiTaskUtil:getRefreshTaskListFunc()
			if refreshTaskListFunc then
				refreshTaskListFunc()
			end
		end) --挂机完成


		self:hideLayer()
	end)
end

function GuaJiTaskProgressLayer:initButtonVisible()
	self.Button_close:setVisible(true)
	self.Button_cancel:setVisible(true)
	self.Button_ok:setVisible(false)
end


Helper:classDefNodeGetInstance(GuaJiTaskProgressLayer)
return GuaJiTaskProgressLayer000000000000