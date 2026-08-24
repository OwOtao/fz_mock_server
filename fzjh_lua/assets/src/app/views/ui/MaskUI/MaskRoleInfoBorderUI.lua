local MaskRoleInfoBorderUI = class("MaskRoleInfoBorderUI", LayerEx)

function MaskRoleInfoBorderUI:create()
	local p = MaskRoleInfoBorderUI:new()
	p:init()
	return p
end

function MaskRoleInfoBorderUI:init()
    self._round = require("Layer/HomelandUI/MaskRoleInfoBorderUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function MaskRoleInfoBorderUI:showUI()
	self:show()
end

function MaskRoleInfoBorderUI:hideUI()
	self:hide()
end

function MaskRoleInfoBorderUI:setTextTitle(text)
	self.Text_title:setString(text)
end

function MaskRoleInfoBorderUI:setImageBack(imagePath)
    self.Image_back:loadTexture(imagePath)

    local texture = cc.TextureCache:getInstance():getTextureForKey(imagePath);
    self.Image_back:setSize(texture:getContentSize())
end

function MaskRoleInfoBorderUI:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
        if func then
            func()
        end
    end)
end


return MaskRoleInfoBorderUI000000000000000