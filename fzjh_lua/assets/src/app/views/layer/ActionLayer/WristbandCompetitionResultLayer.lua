--
-- Author: TanQinJian
-- Date: 2020-06-12 15:04:23
--
--掰手腕大赛奖励
local WristbandCompetitionResultLayer = class("WristbandCompetitionResultLayer", cc.Layer)


function WristbandCompetitionResultLayer:create()
	local p = WristbandCompetitionResultLayer:new()
	p:init()
	return p
end

function WristbandCompetitionResultLayer:init()
	self._UI = require("Layer/ActionUI/FishingGame/FishingGameResultUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)

	self:setButtonBack()
end

function WristbandCompetitionResultLayer:showLayer()
	self:show()
end

function WristbandCompetitionResultLayer:setButtonBack()
	self.Button_5:releaseFunc(function()
		PopupLayerController:hideLayer("WristbandCompetitionResultLayer", function(layer)
            User:getRole():setFlag("PVP活动状态", "空闲中")
            layer:hide()
        end)
	end)
end

function WristbandCompetitionResultLayer:initText()
    for i = 1 ,4 do
        self["Text_haveDsc"..i]:setVisible(false)
    end
end

function WristbandCompetitionResultLayer:setExp(str)
    self.Text_jingyan:setString(str)
end

function WristbandCompetitionResultLayer:setPot(str)
    self.Text_qianneng:setString(str)
end

function WristbandCompetitionResultLayer:setTextsStr(str)
    self.Text_text:setString(str)
end

function WristbandCompetitionResultLayer:setTextHaveDsc(text_index,desc)
    if self["Text_haveDsc"..text_index] then 
        self["Text_haveDsc"..text_index]:setString(desc)
        self["Text_haveDsc"..text_index]:setVisible(true)
    end
end


Helper:classDefNodeGetInstance(WristbandCompetitionResultLayer)
return WristbandCompetitionResultLayer00000000