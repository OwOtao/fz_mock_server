local DialogEventChoiceUI = class("DialogEventChoiceUI", LayerEx)

function DialogEventChoiceUI:create()
	local p = DialogEventChoiceUI:new()
	p:init()
	return p
end

function DialogEventChoiceUI:init()
    self._round = require("Layer/Dialog/DialogEventChoiceUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function DialogEventChoiceUI:showUI()
    self:setVisible(true)
end

function DialogEventChoiceUI:hideUI()
    self:setVisible(false)
end

function DialogEventChoiceUI:setTitle(text)
    self.Text_title:setString(text)
end

function DialogEventChoiceUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function DialogEventChoiceUI:setButton1(name,func)
    self.Button_1.Text_ButtonName:setString(name)
    self.Button_1:releaseFunc(function()
		if func then
			func()
		end
    end)
end

function DialogEventChoiceUI:setButton2(name,func)
    self.Button_2.Text_ButtonName:setString(name)
    self.Button_2:releaseFunc(function()
		if func then
			func()
		end
    end)
end

return DialogEventChoiceUI00000000