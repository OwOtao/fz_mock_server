local TeacherBuildUpgradeUI = class("TeacherBuildUpgradeUI", LayerEx)

function TeacherBuildUpgradeUI:create()
	local p = TeacherBuildUpgradeUI:new()
	p:init()
	return p
end

function TeacherBuildUpgradeUI:init()
    self._round = require("Layer/TeacherBuildUI/TeacherBuildUpgradeUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function TeacherBuildUpgradeUI:setTextDesc(text)
	self.Text_desc:setString(text)
end

function TeacherBuildUpgradeUI:setTextCondition(text)
	self.Text_condition:setString(text)
end

function TeacherBuildUpgradeUI:setTexteffectDesc1(text)
	self.Text_effectDesc1:setString(text)
end

function TeacherBuildUpgradeUI:setTexteffectDesc2(text)
	self.Text_effectDesc2:setString(text)
end

function TeacherBuildUpgradeUI:setButton1(name,func)
    self.Button_1.Text_ButtonName:setString(name)
    self.Button_1:releaseFunc(function()
        func()
    end)
end

function TeacherBuildUpgradeUI:setButton2(name,func)
    self.Button_2.Text_ButtonName:setString(name)
    self.Button_2:releaseFunc(function()
        func()
    end)
end

return TeacherBuildUpgradeUI00000000000