

local TaskUI = class("TaskUI", cc.Layer)

function TaskUI:create()
	local p = TaskUI:new()
	p:init()
	return p
end

function TaskUI:init()
	self._round = require("Layer/TaskUI.lua").create()['root']
	self._round:addTo(self)
	
	Helper:convertUI(self) -- 获得所有子节点
end

function TaskUI:setTextExp(exp)
	exp = tostring(exp)
	self.Text_exp:setString("『经验』"..exp)
end

function TaskUI:setTextPot(pot)
	pot = tostring(pot)
	self.Text_pot:setString("『潜能』"..pot)
end

function TaskUI:setTextMoney(money)
	money = tostring(money)
	self.Text_money:setString("『金钱』"..money)
end

return TaskUI00000