
local RoleSkillInfoListBarUI = {}


local Resource = require("app.Resource")

local RoleSkillInfoListBarUI = {}

function RoleSkillInfoListBarUI:create()
	local p = Resource:getUIByName("Panel_skillInfoListBar1")
	Helper:tableCover(p, RoleSkillInfoListBarUI)
	p:init()
	return p
end

function RoleSkillInfoListBarUI:init()
	Helper:convertUI(self)
	self:setTouchEnabled(true) -- 设置为可触摸

	-- self:setTextColor(cc.c4b(0, 0, 0, 255))
	self.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	self.Text_dsc:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	self.Text_expDsc:enableOutline(cc.c4b(0, 0, 0, 255), 5)
end

function RoleSkillInfoListBarUI:setName(name)
	self.Text_name:setString(name)
end

function RoleSkillInfoListBarUI:setStageDsc(dsc)
	self.Text_dsc:setString(dsc)
end

function RoleSkillInfoListBarUI:setExpDsc(dsc)
	self.Text_expDsc:setString(dsc)
end

function RoleSkillInfoListBarUI:setDian(bool)
	self.Panel_2:setVisible(bool)
end

function RoleSkillInfoListBarUI:setImageBack(bool)
	self.Image_dark:setVisible(bool)
end

return RoleSkillInfoListBarUI00000000