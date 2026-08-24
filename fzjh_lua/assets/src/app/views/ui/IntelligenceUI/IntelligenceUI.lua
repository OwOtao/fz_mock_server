local IntelligenceUI = class("IntelligenceUI", LayerEx)
local IIntelligenceOutput = require("app.presenters.intelligence.intelligence.IIntelligenceOutput")
local IIntelligenceInput = require("app.presenters.intelligence.intelligence.IIntelligenceInput")
local isImplement = require("third.assertIsInstance.assertIsInstance")

function IntelligenceUI:create()
	local p = IntelligenceUI:new()
	p:init()
	return p
end

function IntelligenceUI:init()
    self._round = require("Layer/IntelligenceUI/IntelligenceUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function IntelligenceUI:showLayer(presenter)
    self._Input = isImplement(presenter, IIntelligenceInput)

    self._Input:showLayer()
end

function IntelligenceUI:setShowLayer()
    self:show()
end

function IntelligenceUI:setDsec(text)
	self.Text_dsec:setString(text)
end

function IntelligenceUI:setBackButton(func)
	self.Image_title.Button_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function IntelligenceUI:setListView(array)
    self.ListView_1:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self:_createPanel(v) 
        self.ListView_1:pushBackCustomItem(panel)
    end
end

function IntelligenceUI:_createPanel(data)
    local panel = self.Panel_intelligence:clone()
    Helper:convertUIByParent(panel)

    panel.Text_isNew:setVisible(data["new_isVisible"])
    panel.Text_name:setString(data["name"])
    panel:releaseFunc(function()
		if data["func"] then
			data["func"](panel.Text_isNew)
		end
    end)
    
    return panel
end

function IntelligenceUI:hideLayer()
    PopupLayerController:hideLayer("IntelligenceUI",function(layer)
        layer:hide()
    end)
end

isImplement(IntelligenceUI,IIntelligenceOutput)
Helper:classDefNodeGetInstance(IntelligenceUI)
return IntelligenceUI0