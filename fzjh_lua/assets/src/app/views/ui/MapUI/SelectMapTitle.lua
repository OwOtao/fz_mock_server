
local Resource = require("app.Resource")

local SelectMapTitle = {}

function SelectMapTitle:create()
	local p = Resource:getUIByName("Panel_selectMapSwitchText")
	Helper:tableCover(p, SelectMapTitle)
	p:init()
	return p
end

function SelectMapTitle:init()
	Helper:convertUI(self)
	self:setPosition(0, 0)

	self.Text_title:enableOutline(cc.c4b(15, 15, 15, 255), 5)
	self.Text_dsc:enableOutline(cc.c4b(15, 15, 15, 255), 5)
end

function SelectMapTitle:setTitle(str)
	self.Text_title:setString(str)
end

function SelectMapTitle:setDsc(str)
	self.Text_dsc:setString(str)
end

return SelectMapTitle0