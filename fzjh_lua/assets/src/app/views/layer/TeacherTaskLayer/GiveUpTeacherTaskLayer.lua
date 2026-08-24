local GiveUpTeacherTaskLayer = class("GiveUpTeacherTaskLayer", cc.Layer)
local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
function GiveUpTeacherTaskLayer:create()
	local p = GiveUpTeacherTaskLayer:new()
	p:init()
	return p
end
function GiveUpTeacherTaskLayer:init()
	local UI= require("Layer/TeacherTask/GiveUpTeacherTask.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self) -- 获得所有子节点

end
function GiveUpTeacherTaskLayer:enterLayer()
	local layer = self:getInstance()
	layer:show()
	layer:initLayer()

end
function GiveUpTeacherTaskLayer:initLayer()
	self:setGiveUpButton()
	self:setNoButton()
	local role = User:getRole()

end
function GiveUpTeacherTaskLayer:setGiveUpButton()
	self.Text_dsc:setString("放弃任务将消耗100碎银，并且在5分钟后才能再接取师门任务。")
	self.Button_YES:releaseFunc(function()
		local role = User:getRole()
		role:giveUpTeacherTask()
		self:hide()
		MainControllLayer:getInstance():getLayer("TeacherTaskLayer"):initLayer()
	end)
end
function GiveUpTeacherTaskLayer:setNoButton()
	self.Button_NO:releaseFunc(function()
		self:hide()
	end)
end
Helper:classDefNodeGetInstance(GiveUpTeacherTaskLayer)
return GiveUpTeacherTaskLayer
000