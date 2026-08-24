
local Resource = require("app.Resource")

local SelectTeacherButton = {}

function SelectTeacherButton:create()
	local p = Resource:getUIByName("Button_1")
	Helper:tableCover(p, SelectTeacherButton)
	p:init()
	return p
end

function SelectTeacherButton:init()	
	Helper:convertUI(self) -- 获得所有子节点
	self.Text_buttonTitleText:enableOutline(cc.c4b(0, 0, 0, 255), 5)
end

function SelectTeacherButton:enable()
end

function SelectTeacherButton:disable()	
	self:setTitleColor(cc.c4b(122, 122, 122, 255))
end

function SelectTeacherButton:setTitle(str)
	self.Text_buttonTitleText:setString(str)
end

function SelectTeacherButton:setTitleColor(color)
	if color then
		self.Text_buttonTitleText:setTextColor(color)
	end
end

function SelectTeacherButton:setDsc(str)
	self.Text_dsc:setString(str)
end

function SelectTeacherButton:loadNormalTexture(texture)
	if texture == nil or texture == "" then
		texture = "Image/UI/MainUI/anniu01.png"
	end

	if cc.FileUtils:getInstance():isFileExist(texture) == false then
		texture = "Image/UI/MainUI/anniu01.png"
	end

	self:loadTextureNormal(texture,0)
end

return SelectTeacherButton00