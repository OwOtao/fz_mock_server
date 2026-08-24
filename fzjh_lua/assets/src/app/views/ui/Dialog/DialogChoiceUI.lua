local DialogChoiceUI = class("DialogChoiceUI", LayerEx)

function DialogChoiceUI:create()
	local p = DialogChoiceUI:new()
	p:init()
	return p
end

function DialogChoiceUI:init()
    self._round = require("Layer/Dialog/dialogChoiceUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function DialogChoiceUI:showUI()
    self:setVisible(true)
end

function DialogChoiceUI:hideUI()
    self:setVisible(false)
end

function DialogChoiceUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function DialogChoiceUI:setListView(array)
    self.ListView_button:removeAllItems()
    for i,v in ipairs(array) do
        local button = self:_createButton(v) 
        self.ListView_button:pushBackCustomItem(button)
    end
end

function DialogChoiceUI:_createButton(data)
    local button = self.Button_1:clone()
    Helper:convertUIByParent(button)

    button.Text_buttonName:setString(data["name"])
    button:releaseFunc(function()
		if data["func"] then
			data["func"]()
		end
    end)
    
    return button
end

return DialogChoiceUI000000000