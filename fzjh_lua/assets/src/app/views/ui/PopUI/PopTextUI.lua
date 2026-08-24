local PopTextUI = class("PopTextUI", cc.Layer)

function PopTextUI:create()
	local p = PopTextUI:new()
	p:init()
	return p
end

function PopTextUI:init()
	self._round = require("Layer/PopUI/PopTextUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUIByParent(self) -- 获得所有子节点
	self:setVisible(false)
end


function PopTextUI:setTitle(str)
	if type(str) ~= "string" then
		return
	end
	self.Panel_start.Text_title:setVisible(true)
	self.Panel_start.Text_title:setString(str)
end

function PopTextUI:setDesc(desc)
	desc = Helper:getDef(desc,"")
	self.Panel_start.Text_desc_1:setString(desc)
end

function PopTextUI:setButtonConfirm(func)
	func = Helper:getDef(func,function()
	end)
	self.Panel_start.Button_confirm:releaseFunc(function()
		func()
	end)
end


function PopTextUI:setButtonLevel(func)
	func = Helper:getDef(func,function()
	end)
	self.Panel_start.Button_leave:releaseFunc(function()
		func()
	end)
end
return PopTextUI00