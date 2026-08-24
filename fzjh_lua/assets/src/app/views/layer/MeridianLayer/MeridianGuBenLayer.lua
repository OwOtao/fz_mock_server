local User = require("app.models.user.User")
local Item = require("app.models.item.Item")
local Role = require("app.models.role.Role")

local Meridian = require("app.models.Meridian.Meridian")

-- 固本界面
local MeridianGuBenLayer = class("MeridianGuBenLayer", LayerEx)

function MeridianGuBenLayer:create()
	local p = MeridianGuBenLayer:new()
	p:init()
	return p
end

function MeridianGuBenLayer:init()
	self._UI = require("Layer/MeridianUI/MeridianAttrSelectUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setButton()
	self:setBack()
end

function MeridianGuBenLayer:initUI()
	local meridian = User:getRoleAttr("meridian")
	local attr1, attr2, attr3 = Meridian:getAcupointAttr(meridian.meridianCount + 1, meridian.acupointCount + 1)

	self.Button_att1.Text_buttonName:setString(attr1)
	self.Button_att2.Text_buttonName:setString(attr2)
	self.Button_att3.Text_buttonName:setString(attr3)

	self.Text_name:setString(Meridian:getAcupointName(meridian.meridianCount + 1, meridian.acupointCount + 1))
end

function MeridianGuBenLayer:showLayer(callBackFunc)
	if callBackFunc == nil then
		callBackFunc = function()
		end
	end
	self.callBackFunc = callBackFunc

	self:initUI()
	self:show()
end

function MeridianGuBenLayer:setButton()
	self.Button_att1:releaseFunc(function()
		local meridian = User:getRoleAttr("meridian")
		local attrName, attrNum = Meridian:selectGuBenSelectAttr(meridian.meridianCount + 1, meridian.acupointCount + 1, 1)
		local attr1, attr2, attr3 = Meridian:getAcupointAttr(meridian.meridianCount + 1, meridian.acupointCount + 1)
		PopText(attr1)
		self.callBackFunc(attrName)
		PopupLayerController:hideLayer("MeridianGuBenLayer", function(layer)
			self:hide()
		end)
	end)

	self.Button_att2:releaseFunc(function()
		local meridian = User:getRoleAttr("meridian")
		local attrName, attrNum = Meridian:selectGuBenSelectAttr(meridian.meridianCount + 1, meridian.acupointCount + 1, 2)
		local attr1, attr2, attr3 = Meridian:getAcupointAttr(meridian.meridianCount + 1, meridian.acupointCount + 1)
		PopText(attr2)
		self.callBackFunc(attrName)
		PopupLayerController:hideLayer("MeridianGuBenLayer", function(layer)
			self:hide()
		end)
	end)

	self.Button_att3:releaseFunc(function()
		local meridian = User:getRoleAttr("meridian")
		local attrName, attrNum = Meridian:selectGuBenSelectAttr(meridian.meridianCount + 1, meridian.acupointCount + 1, 3)
		local attr1, attr2, attr3 = Meridian:getAcupointAttr(meridian.meridianCount + 1, meridian.acupointCount + 1)
		PopText(attr3)
		self.callBackFunc(attrName)
		PopupLayerController:hideLayer("MeridianGuBenLayer", function(layer)
			self:hide()
		end)
	end)
end

function MeridianGuBenLayer:setBack()
	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("MeridianGuBenLayer", function(layer)
			self:hide()
		end, 0)
	end)
end

Helper:classDefNodeGetInstance(MeridianGuBenLayer)

return MeridianGuBenLayer000000000000