
local SkillInfoListBarUI = {}



local Resource = require("app.Resource")

local SkillInfoListBarUI = {}

function SkillInfoListBarUI:create()
	local p = Resource:getUIByName("Panel_skillInfoListBar")
	Helper:tableCover(p, SkillInfoListBarUI)
	p:init()
	return p
end

function SkillInfoListBarUI:init()
	Helper:convertUI(self)
	self:setTouchEnabled(true) -- 设置为可触摸

	-- self:setTextColor(cc.c4b(0, 0, 0, 255))
	self.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	self.Text_dsc:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	self.Text_expDsc:enableOutline(cc.c4b(0, 0, 0, 255), 5)
end

function SkillInfoListBarUI:setName(name)
	self.Text_name:setString(name)
end

function SkillInfoListBarUI:setStageDsc(dsc)
	self.Text_dsc:setString(dsc)
end

function SkillInfoListBarUI:setExpDsc(dsc)
	self.Text_expDsc:setString(dsc)
end

function SkillInfoListBarUI:setImageBack(bool)
	self.Image_dark:setVisible(bool)
end

function SkillInfoListBarUI:setDian(bool)
	self.Image_5:setPositionX(200)
	self.dian:setVisible(bool)
end

return SkillInfoListBarUI00000