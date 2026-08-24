--梦境人物履历界面
local DreamRoleRecordLayer = class("DreamRoleRecordLayer", cc.Layer)  
local DreamWroldTask = require("app.models.DreamWorldModel.DreamWroldTask")

function DreamRoleRecordLayer:create()
	local p = DreamRoleRecordLayer:new()
	p:init()
	return p
end

function DreamRoleRecordLayer:init()
	self._round = require("Layer/DreamWorldUI/DreamRoleRecordUI.lua").create()['root']
	self._round:addTo(self)
	Helper:convertUIByParent(self)

    self._map = nil 

	self:setButtonBack()
	self:setTitle()
end

function DreamRoleRecordLayer:showLayer(map)
    self._map = map
    self._player = map:getPlayer()

    self:setTextDsc()
    self:initTaskList()
	self:show()
end

function DreamRoleRecordLayer:setButtonBack()
	self.Button_back:releaseFunc(function()
		PopupLayerController:hideLayer("DreamRoleRecordLayer", function(layer)
			layer:hide()
		end)
	end)
end

function DreamRoleRecordLayer:setTitle()
	self.Text_title:setString("履历")
end

function DreamRoleRecordLayer:setTextDsc()
    local dsc = self._player:getAttr("dsc")
	self.Text_Dsc:setString(dsc)
end


function DreamRoleRecordLayer:initTaskList()
	self.ListView_TaskList:removeAllItems()
	local taskList = self._map.drTasks
    
    print("任务id列表")
    Helper:print_lua_table(taskList)

    for i,taskId in ipairs(taskList) do
        local taskAttr = DreamWroldTask:getTaskRes(taskId)
		if DEBUG_MODE == 1 then
			Helper:print_lua_table(taskAttr)
		end
        local panel = self.Panel_item:clone()
        Helper:convertUIByParent(panel)

        panel.Text_name:setString(taskAttr.taskName)
        local taskStatus = DreamWroldTask:getTaskStatus(self._player, taskId)

        if taskStatus == DreamWroldTask.TASK_STATUS.RUNNING or taskStatus == DreamWroldTask.TASK_STATUS.FINISH then --进行中
            panel.Text_stateDsc:setString("  HIY（进行中）")
            panel.Text_taskDsc:setString(taskAttr.taskDesc)

            self.ListView_TaskList:pushBackCustomItem(panel)
        elseif taskStatus == DreamWroldTask.TASK_STATUS.COMMIT then --已完成
            panel.Text_stateDsc:setString("  GRN（已完成）")
            panel.Text_taskDsc:setString(taskAttr.taskedDesc)

            self.ListView_TaskList:pushBackCustomItem(panel)
        end        
    end
end


Helper:classDefNodeGetInstance(DreamRoleRecordLayer)
return DreamRoleRecordLayer0000000000000000