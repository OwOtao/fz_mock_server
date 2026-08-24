local FistFootMenuUI = class("FistFootMenuUI", LayerEx)

function FistFootMenuUI:create()
	local p = FistFootMenuUI:new()
	p:init()
	return p
end

function FistFootMenuUI:init()
    self._round = require("Layer/FistFootUI/FistFootMenuUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function FistFootMenuUI:setPanelButton(widgetName,callback)
    if self[widgetName] == nil then
        return
    end
    
	self[widgetName]:releaseFunc(function()
		if callback then
			callback()
		end
	end)
end

function FistFootMenuUI:setLightButton(widgetName)
    if self[widgetName] == nil then
        return
    end
    
    self.Panel_10010.Image_1:setVisible(false)
    self.Panel_10020.Image_1:setVisible(false)
    self.Panel_10030.Image_1:setVisible(false)
    self.Panel_10040.Image_1:setVisible(false)
    self.Panel_10050.Image_1:setVisible(false)

    self[widgetName].Image_1:setVisible(true)
end

function FistFootMenuUI:setPanelText(textMap)
    self.Panel_text.Text_name:setString(textMap.name)
    self.Panel_text.Text_title1:setString(textMap.title1)
    self.Panel_text.Text_title2:setString(textMap.title2)
    self.Panel_text.Text_title3:setString(textMap.title3)
    self.Panel_text.Text_title4:setString(textMap.title4)
    self.Panel_text.Text_title5:setString(textMap.title5)
    self.Panel_text.Text_title6:setString(textMap.title6)
    self.Panel_text.Text_value1:setString(textMap.value1)
    self.Panel_text.Text_value2:setString(textMap.value2)
    self.Panel_text.Text_value3:setString(textMap.value3)
    self.Panel_text.Text_value4:setString(textMap.value4)
    self.Panel_text.Text_value5:setString(textMap.value5)
    self.Panel_text.Text_value6:setString(textMap.value6)
end

function FistFootMenuUI:setButtonGuaJi(buttonName,func)
    self.Button_guaji.Text_ButtonName:setString(buttonName)
	self.Button_guaji:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function FistFootMenuUI:setButtonTechnique(buttonName,func)
    self.Button_technique.Text_ButtonName:setString(buttonName)
	self.Button_technique:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function FistFootMenuUI:setButtonReset(buttonName,func)
    self.Button_reset.Text_ButtonName:setString(buttonName)
	self.Button_reset:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return FistFootMenuUI000