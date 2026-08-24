local ComprehendCharacterUI = class("ComprehendCharacterUI", LayerEx)

function ComprehendCharacterUI:create()
	local p = ComprehendCharacterUI:new()
	p:init()
	return p
end

function ComprehendCharacterUI:init()
    self._round = require("Layer/FistFootUI/ComprehendCharacterUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ComprehendCharacterUI:setPanel1(bool,data)
    local panel = self.Panel_1
    if bool then
        panel:setVisible(true)
        panel.Text_name:setString(data.name)
        panel.Text_levelNum:setString(data.level)
        panel.Text_character:setString(data.desc)
    else
        panel:setVisible(false)
    end
end

function ComprehendCharacterUI:setPanel2(bool,data)
    local panel = self.Panel_2
    if bool then
        panel:setVisible(true)
        panel.Text_name:setString(data.name)
        panel.Text_levelNum:setString(data.level)
        panel.Text_character:setString(data.desc)
    else
        panel:setVisible(false)
    end
end

function ComprehendCharacterUI:setButton1(buttonName,func)
    if buttonName == nil then
        self.Button_1:setVisible(false)
        return
    end
    self.Button_1:setVisible(true)
    self.Button_1.Text_buttonName:setString(buttonName)
	self.Button_1:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ComprehendCharacterUI:setButton2(buttonName,func)
    if buttonName == nil then
        self.Button_2:setVisible(false)
        return
    end
    self.Button_2:setVisible(true)
    self.Button_2.Text_buttonName:setString(buttonName)
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ComprehendCharacterUI:setButton3(buttonName,func)
    if buttonName == nil then
        self.Button_3:setVisible(false)
        return
    end
    self.Button_3:setVisible(true)
    self.Button_3.Text_buttonName:setString(buttonName)
	self.Button_3:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ComprehendCharacterUI:setText1(text)
	self.Text_1:setString(text)
end

function ComprehendCharacterUI:setText2(text)
	self.Text_2:setString(text)
end

function ComprehendCharacterUI:setNotCharacterVisible(bool)
	self.Text_notCharacter:setVisible(bool)
end

return ComprehendCharacterUI0000000000000000