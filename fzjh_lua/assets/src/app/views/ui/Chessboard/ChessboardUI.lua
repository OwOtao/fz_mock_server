local ChessboardUI = class("ChessboardUI", LayerEx)

function ChessboardUI:create()
	local p = ChessboardUI:new()
	p:init()
	return p
end

function ChessboardUI:init()
    self._round = require("Layer/ChessboardUI/ChessboardUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ChessboardUI:showUI()
    self:show()
end

function ChessboardUI:hideUI()
    self:hide()
end

function ChessboardUI:setTital(tital)
    self.Text_tital:setString(tital)
end

function ChessboardUI:setButtonBack(func)
	self.Button_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ChessboardUI:setListView(array)
    self.ListView_1:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self:_createPanel(v) 
        self.ListView_1:pushBackCustomItem(panel)
    end
end

function ChessboardUI:_createPanel(data)
    local panel = self.Panel_chessBoard:clone()
    Helper:convertUIByParent(panel)

    panel.Text_name:setString(data["name"])
    panel.Button_1:releaseFunc(function()
		if data["func"] then
			data["func"]()
		end
    end)
    
    return panel
end

function ChessboardUI:initPanelTip(data)
    self.Panel_tip:setVisible(true)
    self.Panel_tip.Text_desc:setString(data["desc"])
    self.Panel_tip.Button_confirm.Text_buttonName:setString(data["button1Name"])
    self.Panel_tip.Button_confirm:releaseFunc(function()
        data["button1Func"]()
        self.Panel_tip:setVisible(false)
    end)
    self.Panel_tip.Button_close.Text_buttonName:setString(data["button2Name"])
    self.Panel_tip.Button_close:releaseFunc(function()
        self.Panel_tip:setVisible(false)
    end)
end

return ChessboardUI000000000000