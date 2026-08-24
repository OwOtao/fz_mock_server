local SelectMapMenuUI = class("SelectMapMenuUI", LayerEx)

function SelectMapMenuUI:create()
	local p = SelectMapMenuUI:new()
	p:init()
	return p
end

function SelectMapMenuUI:init()
    self._round = require("Layer/MapUI/SelectMapMenuUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function SelectMapMenuUI:showUI()
    self:show()
end

function SelectMapMenuUI:hideUI()
    self:hide()
end

function SelectMapMenuUI:setButtonOldMap(text,func)
	self.Button_oldMap.Text_ButtonName:setString(text)
	self.Button_oldMap:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function SelectMapMenuUI:setButtonNewMap(text,func)
	self.Button_newMap.Text_ButtonName:setString(text)
	self.Button_newMap:releaseFunc(function()
		if func then
			func()
		end
	end)
end


return SelectMapMenuUI0000000000000000