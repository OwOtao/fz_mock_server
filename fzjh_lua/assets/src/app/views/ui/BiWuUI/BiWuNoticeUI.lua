local Resource = require("app.Resource")
local RoleInfoLayer = require("app.views.layer.RoleLayer.RoleInfoLayer")

local BiWuNoticeUI = class("BiWuNoticeUI",cc.Layer)

function BiWuNoticeUI:create()
	local p = BiWuNoticeUI:new()
	p:init()
	return p
end


function BiWuNoticeUI:init()
	self._UI = require("Layer.BiWuUI.BiWuNoticeUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setVisible(true)
	-- self.Panel_back:releaseFunc(function()
	-- 	PopupLayerController:hideLayer()
	-- end)

end

function BiWuNoticeUI:setTitle(title)
	if type(title) ~= "string" then
		return
	end
	self.Panel_attr.Text_title:setString(title)
end


function BiWuNoticeUI:setDsc(dsc)
	if type(dsc) ~= "string" then
 		return
	end
	self.Panel_attr.Text_desc:setString(dsc)
end
function BiWuNoticeUI:hideLayer()
	self:hide()
end
Helper:classDefNodeGetInstance(BiWuNoticeUI)

return BiWuNoticeUI
000000000