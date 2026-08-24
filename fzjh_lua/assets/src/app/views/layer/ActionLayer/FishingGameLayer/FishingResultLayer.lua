--钓鱼结果界面
local FishingResultLayer = class("FishingResultLayer", cc.Layer)
local FishingGameUtil = require("app.models.Action.Fishing.FishingGameUtil")

function FishingResultLayer:create()
	local p = FishingResultLayer:new()
	p:init()
	return p
end

function FishingResultLayer:init()
	self._UI = require("Layer/ActionUI/FishingGame/FishingGameResultUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)

	self:setButtonBack()
end

function FishingResultLayer:showLayer(fishTab)
	self:initText(fishTab)
	self:show()
end

function FishingResultLayer:setButtonBack()
	self.Button_5:releaseFunc(function()
		PopupLayerController:hideLayer("FishingResultLayer", function(layer)
            User:getRole():setFlag("PVP活动状态", "空闲中")
            layer:hide()
        end)
	end)
end

function FishingResultLayer:initText(fishTab)
    for i = 1 ,4 do
        self["Text_haveDsc"..i]:setString("")
    end
    if MapIsEmpty(fishTab) then
        self.Text_text:setString("你在本次钓鱼中未能钓到鱼！")
    else
        self.Text_text:setString("你在本次钓鱼中钓到了")

        local count = 0
        for fishId ,num in pairs(fishTab) do
            count = count + 1
            local fishName = FishingGameUtil:getFishAttr(fishId).fishname

            local text = fishName.."X"..num

            self["Text_haveDsc"..count]:setString(text)
        end
    end
end

function FishingResultLayer:setExp(exp)
    self.Text_jingyan:setString("获得经验："..tostring(exp))
end

function FishingResultLayer:setPot(pot)
    self.Text_qianneng:setString("获得潜能："..tostring(pot))
end


Helper:classDefNodeGetInstance(FishingResultLayer)
return FishingResultLayer000000000000