local Dialog17UI = class("Dialog17UI", LayerEx)

function Dialog17UI:create()
	local p = Dialog17UI:new()
	p:init()
	return p
end

function Dialog17UI:init()
    self._UI = require("Layer/Dialog/Dialog17UI.lua").create()['root']
    self._UI:addTo(self)
    Helper:convertUI(self)
    self:setVisible(false)
end

function Dialog17UI:showUI()
    self:show()
end

function Dialog17UI:hideUI()
    self:hide()
end

function Dialog17UI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function Dialog17UI:setButtonClose(buttonName,func)
    self.Text_closeButtonName:setString(buttonName)
    self.Button_close:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function Dialog17UI:setButtonConfirm(buttonName,func)
    self.Text_confirmButtonName:setString(buttonName)
    self.Button_confirm:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

return Dialog17UI000