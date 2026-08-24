--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-08-13 17:39:48
--]]
local StoreDialog2UI = class("StoreDialog2UI", LayerEx)

function StoreDialog2UI:create()
	local p = StoreDialog2UI:new()
	p:init()
	return p
end

function StoreDialog2UI:init()
    self._round = require("Layer/StoreUI/StoreDialog2UI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function StoreDialog2UI:showUI()
    self:show()
end

function StoreDialog2UI:hideUI()
    self:hide()
end

function StoreDialog2UI:setTextTitle(text)
    self.Text_title:setString(text)
end

function StoreDialog2UI:setText1(text)
    self.Text_1:setString(text)
end

function StoreDialog2UI:setText2(text)
    self.Text_2:setString(text)
end

function StoreDialog2UI:setText3(text)
    self.Text_3:setString(text)
end

function StoreDialog2UI:setImage(imagePath)
	self.Image_Goods:loadTexture(imagePath, 0)
end

function StoreDialog2UI:setButton1(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function StoreDialog2UI:setButton2(func)
    self.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return StoreDialog2UI000