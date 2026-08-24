local TeacherBuildPromoteUI = class("TeacherBuildPromoteUI", LayerEx)

function TeacherBuildPromoteUI:create()
	local p = TeacherBuildPromoteUI:new()
	p:init()
	return p
end

function TeacherBuildPromoteUI:init()
    self._ui = require("Layer/TeacherBuildUI/TeacherBuildPromoteUI.lua").create()['root']
	self._ui:addTo(self)

    Helper:convertUIByParent(self)
end

function TeacherBuildPromoteUI:setText1(text)
	self.Text_1:setString(text)
end

function TeacherBuildPromoteUI:setText2(text)
	self.Text_2:setString(text)
end

function TeacherBuildPromoteUI:setText3(text)
	self.Text_3:setString(text)
end

function TeacherBuildPromoteUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function TeacherBuildPromoteUI:setButton1Func(func)
	self.Button_1:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function TeacherBuildPromoteUI:addItemToList(panel)
    self.ListView_1:pushBackCustomItem(panel)
end

function TeacherBuildPromoteUI:clearListView()
    self.ListView_1:removeAllItems()
end

function TeacherBuildPromoteUI:listViewJumpToTop()
    self.ListView_1:jumpToTop()
end

function TeacherBuildPromoteUI:getPanel()
    local panel = self.Panel_1:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function TeacherBuildPromoteUI:initPanel(panel, panelInfo)
    if MapIsEmpty(panelInfo) == false then
        panel.Text_1:setString(panelInfo.text1)
        panel.Text_2:setString(panelInfo.text2)
        panel.Text_3:setString(panelInfo.text3)
        panel.Text_4:setVisible(panelInfo.textVisible)
        panel.Panel_bg:setVisible(panelInfo.panelVisible)
        panel.Image_light:setVisible(false)
        panel:releaseFunc(function()
            if panelInfo.func then
                panelInfo.func()
            end
        end)
    end
end

function TeacherBuildPromoteUI:getListItemByIndex(index)
    return self.ListView_1:getItem(index)
end

function TeacherBuildPromoteUI:showPanelLightBg(panel)
    panel.Image_light:setVisible(true)
end

function TeacherBuildPromoteUI:hidePanelLightBg(panel)
    panel.Image_light:setVisible(false)
end

return TeacherBuildPromoteUI00000000000