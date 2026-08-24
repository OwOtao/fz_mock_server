local BiWu = require("app.models.BiWu.BiWu")
local BiWuNoticeUI = require("app.views.ui.BiWuUI.BiWuNoticeUI")
local Item = require("app.models.item.Item")
local BiWuPrintUI = require("app.views.ui.BiWuUI.BiWuPrintUI")

local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

local BiWuNoticeLayer = class("BiWuNoticeLayer",cc.Layer)

function BiWuNoticeLayer:create()
	local p = BiWuNoticeLayer:new()
	p:init()
	return p
end

function BiWuNoticeLayer:init()
	local BiWuNoticeUI = BiWuNoticeUI:create()
	self._UI = BiWuNoticeUI
	BiWuNoticeUI:addTo(self)

end

--进入界面的时候就先判断是挑战还是上台
function BiWuNoticeLayer:onResume()


end
---
function BiWuNoticeLayer:show()
	self._UI:show()
	self._UI.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("BiWuNoticeLayer",function(layer)
			layer._UI:hideLayer()
		end)
	end)
	self._UI.Panel_attr:releaseFunc(function()
		PopupLayerController:hideLayer("BiWuNoticeLayer",function(layer)
			layer._UI:hideLayer()
		end)
	end)
end

Helper:classDefNodeGetInstance(BiWuNoticeLayer)

return  BiWuNoticeLayer
00000000