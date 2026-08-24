local FestivalLantern = class("FestivalLantern", LayerEx)
function FestivalLantern:create()
	local p = FestivalLantern:new()
	p:init()
	return p
end
function FestivalLantern:init()
	local UI = require("Layer/ActionUI/Festival/FestivalLantern.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
end

function FestivalLantern:showLayer()
	self:show(true)
	self:setLanternVisible(true)
end

function FestivalLantern:setLanternVisible(loop)
	print("----------------------------------------------")
	self.Image_titleBack.Image_left:setVisible(loop)
	self.Image_titleBack.Image_right:setVisible(loop)
	self:setLocalZOrder(11)
end

Helper:classDefNodeGetInstance(FestivalLantern)
return FestivalLantern0000000000000