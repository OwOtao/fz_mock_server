local RoleAttrTabUI = class("RoleAttrTabUI", cc.Layer)

function RoleAttrTabUI:create(resPath)
	local p = RoleAttrTabUI:new()
	p:init(resPath)
	return p
end

function RoleAttrTabUI:init(resPath)
	local resPath = resPath or "Layer/AttrUI/RoleAttrTabUI.lua"
	self._round = require(resPath).create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) -- 获得所有子节点
	
end

local lightColor = cc.c4b(0, 179, 230, 255)
local darkColor = cc.c4b(208, 208, 208, 255)

function RoleAttrTabUI:lightTable(name)
	local tbs = 
	{
		attr = "roleAttr",
		jiangHu = "jianghuAttr",
		bag = "bag"
	}
	for k,v in pairs(tbs) do

		if k == name then
			self["Image_"..v]:setVisible(true)
			self["Text_"..v]:setTextColor(lightColor)
		else
			self["Text_"..v]:setTextColor(darkColor)
			self["Image_"..v]:setVisible(false)
		end
	end
end



return RoleAttrTabUI00000000000000