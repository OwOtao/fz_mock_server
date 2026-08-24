local TeacherFeatClassUI = class("TeacherFeatClassUI", LayerEx)

function TeacherFeatClassUI:create()
	local p = TeacherFeatClassUI:new()
	p:init()
	return p
end

function TeacherFeatClassUI:init()
    self._round = require("Layer/TeacherBuildUI/TeacherFeatClassUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function TeacherFeatClassUI:setTextFeatPoint(text)
	self.Text_featPoint:setString(text)
end

function TeacherFeatClassUI:setTextFeatClass(text)
	self.Text_featClass:setString(text)
end

function TeacherFeatClassUI:setListViewFeat(array)
    self.ListView_feat:removeAllItems()

    for i,v in ipairs(array) do
        local panel = self.Panel_1:clone()
        Helper:convertUIByParent(panel)

        panel.Text_num:setString(i)
        
        panel.Text_name:setString(v.name)

        panel.Text_dsc:setString(v.dsc)

        panel.Text_point:setString(v.point)

        self.ListView_feat:pushBackCustomItem(panel)
    end
    
    self.ListView_feat:jumpToTop()
end

return TeacherFeatClassUI0000000