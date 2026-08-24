local JiangHuAnecdoteUI = class("JiangHuAnecdoteUI", LayerEx)

function JiangHuAnecdoteUI:create()
	local p = JiangHuAnecdoteUI:new()
	p:init()
	return p
end

function JiangHuAnecdoteUI:init()
    self._round = require("Layer/ChallengeMapUI/JiangHuAnecdoteUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function JiangHuAnecdoteUI:setListView(array)
    self.ListView_map:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self:_createPanel(v) 
        self.ListView_map:pushBackCustomItem(panel)
    end
end

function JiangHuAnecdoteUI:_createPanel(data)
    local panel = self.Panel_item:clone()
    Helper:convertUIByParent(panel)

    panel.Text_name:setString(data["name"])
    panel:releaseFunc(function()
		if data["func"] then
			data["func"]()
		end
    end)
    
    return panel
end

return JiangHuAnecdoteUI00000000