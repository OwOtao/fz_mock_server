local TeacherBuildItemUI = class("TeacherBuildItemUI", LayerEx)

function TeacherBuildItemUI:create()
	local p = TeacherBuildItemUI:new()
	p:init()
	return p
end

function TeacherBuildItemUI:init()
    self._round = require("Layer/TeacherBuildUI/TeacherBuildItemUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function TeacherBuildItemUI:setNotItemText(bool)
    self.Text_item:setVisible(bool)
end

function TeacherBuildItemUI:setPanelItemList(array)
    self.ListView_item:removeAllItems()
    for i,v in ipairs(array) do
        local button = self.Panel_item:clone()
        Helper:convertUIByParent(button)

        button.Text_name:setString(v.name)
        button.Text_num:setString(v.num)

        self.ListView_item:pushBackCustomItem(button)
    end
    
    self.ListView_item:jumpToTop()
end

function TeacherBuildItemUI:setPanelBack(func)
    self.Panel_back:releaseFunc(function()
        func()
    end)
end



return TeacherBuildItemUI000