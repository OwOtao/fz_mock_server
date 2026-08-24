local JiangHuAttrLayer = class("JiangHuAttrLayer", cc.Layer)

function JiangHuAttrLayer:create()
	local p = JiangHuAttrLayer:new()
	p:init()
	return p
end

function JiangHuAttrLayer:init()
	local JiangHuAttrUI = require("app.views.ui.AttrUI.JiangHuAttrUI"):create()
	self._UI = JiangHuAttrUI
	JiangHuAttrUI:addTo(self)
end

function JiangHuLayer:update(ft)
    self._UI:update(ft)
end

Helper:classDefNodeGetInstance(JiangHuAttrLayer)

return JiangHuAttrLayer0