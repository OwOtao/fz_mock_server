-- 界面控制器,用来控制界面切换


local TeacherControllLayer = class("TeacherControllLayer", require("app.views.template.ControllLayer"))

local layers = -- 
{	
	SelectTeacherLayer = require("app.views.layer.TeacherLayer.SelectTeacherLayer")
}

function TeacherControllLayer:create()
	local p = TeacherControllLayer:new()
	p:init()
	return p
end

function TeacherControllLayer:init()
	self._layers = layers

	self:preLoad()
	self:initLayerStack()

	self:getLayer("SelectTeacherLayer")
end

Helper:classDefNodeGetInstance(TeacherControllLayer)
return TeacherControllLayer0000000000000000