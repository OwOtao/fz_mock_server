
local BagUI = require("app.views.ui.AttrUI.BagUI")
local User = require("app.models.user.User")
local Item = require("app.models.item.Item")

local BagLayer = class("BagLayer", cc.Layer)

function BagLayer:create()
	local p = BagLayer:new()	
	p:init()
	return p
end

function BagLayer:init()
	local BagUI = BagUI:create()
	self._UI = BagUI
	BagUI:addTo(self)
end

function BagLayer:showItemList()
	self._UI:showItemList()
	-- self._UI:showcangkuItem()
end

function BagLayer:update(ft)
    self._UI:update(ft)
end

Helper:classDefNodeGetInstance(BagLayer)

return BagLayer00000