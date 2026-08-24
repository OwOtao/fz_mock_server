local XiSuiJingInfoUI = class("XiSuiJingInfoUI", LayerEx)

function XiSuiJingInfoUI:create()
	local p = XiSuiJingInfoUI:new()
	p:init()
	return p
end

function XiSuiJingInfoUI:init()
	local Ui = require("Layer/SkillUI/XiSuiJingInfoUI.lua").create()['root']
	Ui:addTo(self)
	
	Helper:convertUIByParent(self) -- 获得所有子节点
end

function XiSuiJingInfoUI:showUI()
	self:show()
end

function XiSuiJingInfoUI:hideUI()
	self:hide()
end

function XiSuiJingInfoUI:showLayer()
	self:showUI()
end

function XiSuiJingInfoUI:setBackFunc(func)
	self.Panel_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function XiSuiJingInfoUI:setSkillExpDesc(dsc)
	self.Panel_1.Image_infoArea.Text_expDsc:setString(dsc)
end

function XiSuiJingInfoUI:setSkillSkillDesc(desc)
	self.Panel_1.Image_infoArea.Text_detailDsc:setString(desc)
end

function XiSuiJingInfoUI:setSkillName(name)
	self.Panel_1.Image_infoArea.Text_title:setString(name)
end

function XiSuiJingInfoUI:initPanelItem1(itemInfo)
	self.Panel_1.Image_infoArea.Panel_item_1.Text_detailDsc1_1:setString(itemInfo.text1)
	self.Panel_1.Image_infoArea.Panel_item_1.Text_detailDsc1_2:setString(itemInfo.text2)
	self.Panel_1.Image_infoArea.Panel_item_1.Text_detailDsc1_3:setString(itemInfo.text3)
	self.Panel_1.Image_infoArea.Panel_item_1.Text_detailDsc1_4:setString(itemInfo.text4)
	self.Panel_1.Image_infoArea.Panel_item_1.Text_detailDsc1_5:setString(itemInfo.text5)
	self.Panel_1.Image_infoArea.Panel_item_1.Text_detailDsc1_6:setString(itemInfo.text6)
end

function XiSuiJingInfoUI:initPanelItem2(itemInfo)
	self.Panel_1.Image_infoArea.Panel_item_2.Text_detailDsc1_1:setString(itemInfo.text1)
	self.Panel_1.Image_infoArea.Panel_item_2.Text_detailDsc1_2:setString(itemInfo.text2)
	self.Panel_1.Image_infoArea.Panel_item_2.Text_detailDsc1_3:setString(itemInfo.text3)
	self.Panel_1.Image_infoArea.Panel_item_2.Text_detailDsc1_4:setString(itemInfo.text4)
	self.Panel_1.Image_infoArea.Panel_item_2.Text_detailDsc1_5:setString(itemInfo.text5)
	self.Panel_1.Image_infoArea.Panel_item_2.Text_detailDsc1_6:setString(itemInfo.text6)
end

function XiSuiJingInfoUI:setPanelItem2Visible(visible)
	self.Panel_1.Image_infoArea.Panel_item_2:setVisible(visible)
end

Helper:classDefNodeGetInstance(XiSuiJingInfoUI)
return XiSuiJingInfoUI000000000000000