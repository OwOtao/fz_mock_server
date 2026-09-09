local KuaiJieJianLayer2 = class("KuaiJieJianLayer2", cc.Layer)  
local DebugLayer = require("app.views.layer.DebugLayer.DebugLayer")
local Skill = require("app.models.skill.Skill")
local Item = require("app.models.item.Item")
local Skill = require("app.models.skill.Skill")
function KuaiJieJianLayer2:create()
	local p = KuaiJieJianLayer2:new()	
	p:init()
	return p
end
function KuaiJieJianLayer2:init()
	self._round = require("Layer/DebugUI/KuaiJieJianUI.lua").create()['root']
	self._round:addTo(self)
	
	Helper:convertUIByParent(self)
end
local Table = {
	["充值"] = {
		name = "充值"
	},
	["修改人物属性"] = {
		name = "修改人物属性"
	},
	["服务器配置"] = {
		name = "服务器配置"
	},
	["修改物品"] = {
		name = "修改物品"
	},
	["修改技能"] = {
		name = "修改技能"
	},
	["排行榜数据测试"] = 
	{
		name = "排行榜数据测试"
	},
	["佣兵测试模块"] = {
		name = "佣兵测试模块"
	},
	["常用快捷键"] = {
		name = "常用快捷键"
	}
}
local layerTab = {
	["充值"] = {
		func = function(tab,self)
			local EditRoleAttrLayer = require("app.views.layer.DebugLayer.EditRoleAttrLayer3")
	    	local fightLayer = EditRoleAttrLayer:getInstance()
			fightLayer:show(tab)
			fightLayer:setVisible(true)
		end
	},
}
function KuaiJieJianLayer2:show()
	if self.Panel_2 ~= nil then
		self.Panel_2:setVisible(false)
	end
	for k,v in pairs(Table) do 
		local row = self:clonePanel()
		row:setVisible(true)
		row.Text_desc:setString(k)
		row:releaseFunc(function()
			layerTab["充值"].func(v,self)
		end)
		self.ListView_1:pushBackCustomItem(row)
	end
	self:setButtonBack()
end
function KuaiJieJianLayer2:clonePanel()
	local row = self.Panel_2:clone()
	Helper:convertUI(row)
	return row
end
function KuaiJieJianLayer2:setButtonBack()
	self.Button_2:releaseFunc(function()
		self:removeFromParent()
	end)
end
Helper:classDefNodeGetInstance(KuaiJieJianLayer2)
return KuaiJieJianLayer2