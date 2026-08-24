local WarmPromptUI = class("WarmPromptUI", LayerEx)

function WarmPromptUI:create()
	local p = WarmPromptUI:new()
	p:init()
	return p
end

function WarmPromptUI:init()
    self._UI = require("Layer/Dialog/WarmPromptUI.lua").create()['root']
    self._UI:addTo(self)
    Helper:convertUI(self)
    self:setVisible(false)
end

function WarmPromptUI:showUI()
    self:show()
end

function WarmPromptUI:hideUI()
    self:hide()
end

function WarmPromptUI:setTextTital(text)
    self.Text_title:setString(text)
end

function WarmPromptUI:setTextName(text)
    self.Text_name:setString(text)
end

function WarmPromptUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function WarmPromptUI:setButtonClose(buttonName,func)
    self.Text_buttonName:setString(buttonName)
    self.Button_close:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

return WarmPromptUI00000000000000