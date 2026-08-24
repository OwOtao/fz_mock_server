local TeacherBuildMenuUI = class("TeacherBuildMenuUI", LayerEx)

function TeacherBuildMenuUI:create()
	local p = TeacherBuildMenuUI:new()
	p:init()
	return p
end

function TeacherBuildMenuUI:init()
    self._round = require("Layer/TeacherBuildUI/TeacherBuildMenuUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function TeacherBuildMenuUI:setTextLv(text)
	self.Text_lv:setString(text)
end

function TeacherBuildMenuUI:setTextExp(text)
	self.Text_exp:setString(text)
end

function TeacherBuildMenuUI:setPercent(percent)
	self.LoadingBar:setPercent(percent)
end

function TeacherBuildMenuUI:setTextMaterial1(text)
	self.Panel_1.Text_material1:setString(text)
end

function TeacherBuildMenuUI:setTextMaterial2(text)
	self.Panel_1.Text_material2:setString(text)
end

function TeacherBuildMenuUI:setTextMaterial3(text)
	self.Panel_1.Text_material3:setString(text)
end

function TeacherBuildMenuUI:setTextMaterial4(text)
	self.Panel_1.Text_material4:setString(text)
end

function TeacherBuildMenuUI:setImageBack(imagePath)
	if imagePath == nil then
		self.Panel_4:setVisible(false)
		return
	end

	self.Panel_4:setVisible(true)
	self.Panel_4.Image_back:loadTexture(imagePath,0)
end

function TeacherBuildMenuUI:setButtonTask(name,func)
	self.Button_task.Text_name:setString(name)
	self.Button_task:releaseFunc(function()
		func()
	end)
end

function TeacherBuildMenuUI:setButton1(name,func)
	self.Button_1.Text_name:setString(name)
	self.Button_1:releaseFunc(function()
		func()
	end)
end

function TeacherBuildMenuUI:setButton2(name,func)
	self.Button_2.Text_name:setString(name)
	self.Button_2:releaseFunc(function()
		func()
	end)
end

function TeacherBuildMenuUI:setButton3(name,func)
	self.Button_3.Text_name:setString(name)
	self.Button_3:releaseFunc(function()
		func()
	end)
	end

function TeacherBuildMenuUI:setButton4(name,func)
	self.Button_4.Text_name:setString(name)
	self.Button_4:releaseFunc(function()
		func()
	end)
end

function TeacherBuildMenuUI:setFamilyStatePanelVisible(visible)
	self.Panel_familyState:setVisible(visible)
end

function TeacherBuildMenuUI:setFamilyStateVisible(index, visible)
	self.Panel_familyState["Image_"..tostring(index)]:setVisible(visible)
end

function TeacherBuildMenuUI:setFamilyStateTexture(index, texture)
	self.Panel_familyState["Image_"..tostring(index)]:loadTexture(texture)
end

function TeacherBuildMenuUI:setFamilyStateFunc(index, func)
	self.Panel_familyState["Image_"..tostring(index)]:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function TeacherBuildMenuUI:setFamilyStateDescPanelVisible(visible)
	self.Panel_familyStateDesc:setVisible(visible)
end

function TeacherBuildMenuUI:setFamilyStateDescPanelFunc(func)
	self.Panel_familyStateDesc:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function TeacherBuildMenuUI:setFamilyStateDescName(name)
	self.Panel_familyStateDesc.Text_stateName:setString(name)
end

function TeacherBuildMenuUI:setFamilyStateDescText(text)
	self.Panel_familyStateDesc.Text_stateDesc:setString(text)
end

function TeacherBuildMenuUI:__cloneButton()
	local button = self.Panel_3:clone()
	Helper:convertUIByParent(button)
	return button
end


return TeacherBuildMenuUI0000000000000