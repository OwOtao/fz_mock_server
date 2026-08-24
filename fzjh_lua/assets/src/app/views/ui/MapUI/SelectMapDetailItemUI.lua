
local Resource = require("app.Resource")

local SelectMapDetailItemUI = {}

function SelectMapDetailItemUI:create()
	local p = Resource:getUIByName("Panel_selectMapDetailItemUI")
	Helper:tableCover(p, SelectMapDetailItemUI)
	p:init()
	return p
end

function SelectMapDetailItemUI:init()
	Helper:convertUI(self)
	
	self.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	self.Text_title:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	self.Text_stateDsc:enableOutline(cc.c4b(0, 0, 0, 255), 5)


	self:setHightLight(false)
	--进入其他界面，先隐藏所有的时间
	self:HideResetTime()
end

function SelectMapDetailItemUI:setTitle(str)
	return self.Text_title:setString(str)
end


function SelectMapDetailItemUI:setResetTime(dsc)
	return self.Text_Reset_Time:setString(dsc)
end

function SelectMapDetailItemUI:ShowResetTime()
	return self.Text_Reset_Time:setVisible(true)
end
function SelectMapDetailItemUI:HideResetTime()
	return self.Text_Reset_Time:setVisible(false)
end

function SelectMapDetailItemUI:setName(str)
	return self.Text_name:setString(str)
end

function SelectMapDetailItemUI:getName()
	return self.Text_name:getString()
end

function SelectMapDetailItemUI:setState(str)
	self.Text_stateDsc:setVisible(true)
	if str == "已完成" then
		self.Text_name:setColor(cc.c3b(144, 138, 71))
		self.Text_title:setColor(cc.c3b(144, 138, 71))
		self.Text_stateDsc:setColor(cc.c3b(0, 181, 0))
	elseif str == "未解锁" then
		self.Text_name:setColor(cc.c3b(100, 100, 100))
		self.Text_title:setColor(cc.c3b(100, 100, 100))
		self.Text_stateDsc:setColor(cc.c3b(100, 100, 100))
	end
	return self.Text_stateDsc:setString(str)
end
function SelectMapDetailItemUI:HideState(str)
	return self.Text_stateDsc:setVisible(false)
end

function SelectMapDetailItemUI:setHightLight(b)
	self.Image_Click:setVisible(false)
	if b then
		self.Image_back_hgith_light:setVisible(true)
		self.Image_back:setVisible(false)
	else
		self.Image_back_hgith_light:setVisible(false)
		self.Image_back:setVisible(true)
	end
end

return SelectMapDetailItemUI00