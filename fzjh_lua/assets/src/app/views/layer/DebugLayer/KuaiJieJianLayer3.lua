--[[
Descripttion: 
version: 
Author: LvBin
Date: 2023-01-30 16:53:02
--]]
local KuaiJieJianLayer3 = class("KuaiJieJianLayer3", cc.Layer)
local DebugLayer = require("app.views.layer.DebugLayer.DebugLayer")

function KuaiJieJianLayer3:create()
	local p = KuaiJieJianLayer3:new();
	p:init()
	return p
end

function KuaiJieJianLayer3:init()
	self._UI = require("Layer/DebugUI/KuaiJieJianUI_new.lua").create() ['root']
	self._UI:addTo(self)
	self:setVisible(false)
	
	Helper:convertUIByParent(self)
end


local Table = {
}

local layerTab = {
	["click"] = {
		func = function(tab, self)
			local EditRoleAttrLayer = require("app.views.layer.DebugLayer.EditRoleAttrLayer3")
			local fightLayer = EditRoleAttrLayer:getInstance()
			fightLayer:show(tab)
			fightLayer:setVisible(true)
			self:removeFromParent()
		end
	},
}

function KuaiJieJianLayer3:show()
	self:setVisible(true)
	if self.Panel_item ~= nil then
		self.Panel_item:setVisible(false)
	end


	for k, v in pairs(Table) do
		if GameChannelContext:checkGMIsOpen(k) == true then
			local row = self:clonePanel()
			row:setVisible(true)
			row.Text_desc:setString(k)
			row.Button_5:releaseFunc(function()
				layerTab["click"].func(v, self)
			end)
			self.ListView_Items:pushBackCustomItem(row)
		end
	end
	
	self:setButton()
	
end

function KuaiJieJianLayer3:clonePanel()
	local row = self.Panel_item:clone()
	Helper:convertUI(row)
	return row
end

function KuaiJieJianLayer3:setButton()
	self.Text_return:releaseFunc(function()
		self:removeFromParent()
	end)
end
Helper:classDefNodeGetInstance(KuaiJieJianLayer3)
return KuaiJieJianLayer3 
00000000