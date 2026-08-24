local JiangHuSanYouXQLayer = class("JiangHuSanYouXQLayer",LayerEx)
function JiangHuSanYouXQLayer:create()
	local p = JiangHuSanYouXQLayer:new()
	p:init()
	return p
end

function JiangHuSanYouXQLayer:init()
	local UI = require("Layer/ActionUI/JiangHuSanYouTextUI.lua").create()['root']
	UI:addTo(self)
	-- self:setVisible(false)
	Helper:convertUIByParent(self)
	self:setBack()
end

function JiangHuSanYouXQLayer:setBack()
	self.Panel_back:releaseFunc(function()
		self:hideLayer()
	end)
end

function JiangHuSanYouXQLayer:hideLayer()
    PopupLayerController:hideLayer("JiangHuSanYouXQLayer",function ( layer )
        layer:hide()
    end,0)
end

function JiangHuSanYouXQLayer:showLayer()
	self:show()
end

function JiangHuSanYouXQLayer:setTextTitle(text)
	self.Text_title:setString(text)
end

function JiangHuSanYouXQLayer:setDsc(text)
	self.Text_dsc:setString(text)
end


Helper:classDefNodeGetInstance(JiangHuSanYouXQLayer)
return JiangHuSanYouXQLayer
00000000000