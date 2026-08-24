local TeacherBuildResExchangeStoreUI = class("TeacherBuildResExchangeStoreUI", LayerEx)

function TeacherBuildResExchangeStoreUI:create()
	local p = TeacherBuildResExchangeStoreUI:new()
	p:init()
	return p
end

function TeacherBuildResExchangeStoreUI:init()
    self._ui = require("Layer/TeacherBuildUI/TeacherBuildResExchangeStoreUI.lua").create()['root']
	self._ui:addTo(self)

    Helper:convertUIByParent(self)
end

function TeacherBuildResExchangeStoreUI:setText1(text)
	self.Text_1:setString(text)
end

function TeacherBuildResExchangeStoreUI:setText2(text)
	self.Text_2:setString(text)
end

function TeacherBuildResExchangeStoreUI:setText3(text)
	self.Text_3:setString(text)
end

function TeacherBuildResExchangeStoreUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function TeacherBuildResExchangeStoreUI:setButton1Func(func)
	self.Button_1:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function TeacherBuildResExchangeStoreUI:addItemToList(panel)
    self.ListView_1:pushBackCustomItem(panel)
end

function TeacherBuildResExchangeStoreUI:clearListView()
    self.ListView_1:removeAllItems()
end

function TeacherBuildResExchangeStoreUI:getPanel()
    local panel = self.Panel_1:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function TeacherBuildResExchangeStoreUI:initPanel(panel, panelInfo)
    if MapIsEmpty(panelInfo) == false then
        panel.Text_1:setString(panelInfo.text1)
        panel.Text_2:setString(panelInfo.text2)
        panel.Text_3:setString(panelInfo.text3)
        panel.Panel_bg:setVisible(panelInfo.bgVisible)
        panel.Button_1:setVisible(panelInfo.btnVisible)
        panel.Button_1.Text_buttonName:setString(panelInfo.btnName)
        panel.Button_1:releaseFunc(function()
            if panelInfo.func then
                panelInfo.func()
            end
        end)
    end
end

return TeacherBuildResExchangeStoreUI000