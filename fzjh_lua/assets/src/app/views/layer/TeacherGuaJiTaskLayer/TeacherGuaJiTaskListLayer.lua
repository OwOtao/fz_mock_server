local TeacherGuaJiTaskListLayer = class("TeacherGuaJiTaskListLayer", cc.Layer)
local TeacherGuaJiTaskUtil = require("app.models.task.teacherGuaJiTask.TeacherGuaJiTaskUtil")

function TeacherGuaJiTaskListLayer:create()
	local p = TeacherGuaJiTaskListLayer:new()
	p:init()
	return p
end

function TeacherGuaJiTaskListLayer:init()
	self._round = require("Layer/TeacherTask/TeacherGuaJiTask/TeacherGuaJiTaskListUI.lua").create()['root']
	self._round:addTo(self)
	Helper:convertUIByParent(self)

	self:setButtonBack()
	self:setTitle()
end

function TeacherGuaJiTaskListLayer:showLayer()
	self:initTaskList()
	TeacherGuaJiTaskUtil:setRefreshTaskListFunc(function()
		self:initTaskList()
	end)
	self:show()
end

function TeacherGuaJiTaskListLayer:setButtonBack()
	self.Button_back:releaseFunc(function()
		--刷新师门界面声望
        local currLayer = MainControllLayer:getCurrLayer()
        if currLayer == "TeacherLayer" then
            local teacherLayer = MainControllLayer:getLayer(currLayer)
            teacherLayer:refreshPrestige(function()
	        	PopupLayerController:hideLayer("TeacherGuaJiTaskListLayer", function(layer)
					layer:hide()
				end)
			end)
        else
        	PopupLayerController:hideLayer("TeacherGuaJiTaskListLayer", function(layer)
				layer:hide()
			end)
        end 
	end)
end

function TeacherGuaJiTaskListLayer:setTitle()
	self.Text_title:setString("师门任务")
end

function TeacherGuaJiTaskListLayer:initTaskList()
	self.ListView_TaskList:removeAllItems()
	local taskList = TeacherGuaJiTaskUtil:getTeacherGuaJiTaskList()
    for k,task in pairs(taskList) do
		if DEBUG_MODE == 1 then
			Helper:print_lua_table(task)
		end
        local panel = self:createPanel(task)
        
        self.ListView_TaskList:pushBackCustomItem(panel)
    end
end

function TeacherGuaJiTaskListLayer:createPanel(task)
	local panel = self.Panel_item:clone()
	Helper:convertUIByParent(panel)
	panel.Button_1.Text_buttonName:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)

	local taskId = task.id
	panel.Text_name:setString(task.taskName)
		--根据任务状态做不同处理 前往 查看 提交
		local state = task.state --任务状态
		print("state = ",state)
		if state == TASK_STATE_IDLE then --空闲
			panel.Text_stateDsc:setString("")
			panel.Button_1.Text_buttonName:setString("接受")
			panel.Button_1:releaseFunc(function()
				PopupLayerController:showLayer("GuajiTaskDetailLayer", function(layer)
					layer:showLayer(task)
					layer:setAcceptButton(function()
						local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
						local dialog = DialogALayer:getInstance()
						dialog:hide()
						local text = TeacherGuaJiTaskUtil:getIsNeedItemText(taskId)
						dialog:show(text .. "你确定要接取该任务吗？")
						dialog:setRichText(text .. "你确定要接取该任务吗？")
						dialog:setButton1(
							"确定",
							function()
								if TeacherGuaJiTaskUtil:checkIsNeedItem(taskId) == true then
									TeacherGuaJiTaskUtil:receiveTask(taskId)
									self:initTaskList()
									layer:hideLayer()
								else
									PopText("物品不足，无法接取！")
								end 
							end
						)
						dialog:setButton2(
							"取消",
							function()
							end
						)
						dialog:setWeChatVisible(false)
					end)
				end)
				
			end)
		elseif state == TASK_STATE_ACCEPT then --接受
			panel.Text_stateDsc:setString("    HIC（未开始）")
			panel.Button_1.Text_buttonName:setString("查看")
			panel.Button_1:releaseFunc(function()
				PopupLayerController:showLayer("GuaJiTaskPrepareLayer", function(layer)
					layer:showLayer(task)

				end)
			end)
		elseif state == TASK_STATE_GUAJI then --挂机
			panel.Text_stateDsc:setString("    HIY（进行中）")
			panel.Button_1.Text_buttonName:setString("查看")
			panel.Button_1:releaseFunc(function()
				PopupLayerController:showLayer("GuaJiTaskProgressLayer", function(layer)
					layer:showLayer(task)

				end)
			end)
		elseif state == TASK_STATE_TO_SUBMIT then --已完成待提交
			panel.Text_stateDsc:setString("    GRN（已完成）")
			panel.Button_1.Text_buttonName:setString("提交")
			panel.Button_1:releaseFunc(function()
				--任务提交成功了，再刷新
				TeacherGuaJiTaskUtil:submitTask(task,function (isSuccess)
					if isSuccess == true then
						self:initTaskList()
					end
				end)
			end)
		elseif state == TASK_STATE_COMPLETE then --已提交
			--已提交的任务不会出现在列表里面了，根据刷新规则会自动改变其状态
		end

	return panel
end


Helper:classDefNodeGetInstance(TeacherGuaJiTaskListLayer)
return TeacherGuaJiTaskListLayer0000000