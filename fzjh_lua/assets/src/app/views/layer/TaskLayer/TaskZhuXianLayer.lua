local Resource = require("app.Resource")
local ZhuXianUI = require("app.views.ui.TaskUI.ZhuXianUI")

local TaskZhuXianLayer = class("TaskZhuXianLayer", cc.Layer)

function TaskZhuXianLayer:create()
	local p = TaskZhuXianLayer:new()
	p:init()
	return p
end


function TaskZhuXianLayer:init()
	local UI = ZhuXianUI:create()
	self._UI = UI

	self._UI:addTo(self)
end

function TaskZhuXianLayer:show(task,taskSystem)
	self._UI:show(task,taskSystem)

	self:setButtonStart(task)
	self:setButtonGO(task.id)
	self:setButtonCancel()
	self:setBack()
end

function TaskZhuXianLayer:hide()
	PopupLayerController:hideLayer("TaskZhuXianLayer", function(layer)
		self._UI:hide()
	end)
end

function TaskZhuXianLayer:setButtonStart(task)
	self._UI:setButtonStart(task)
end

function TaskZhuXianLayer:setButtonGO( id)
	self._UI:setButtonGO(id)
end

function TaskZhuXianLayer:setButtonCancel()
	self._UI:setButtonCancel()
end

function TaskZhuXianLayer:setBack()
	self._UI:setBack()
end

Helper:classDefNodeGetInstance(TaskZhuXianLayer)
return TaskZhuXianLayer00000000000