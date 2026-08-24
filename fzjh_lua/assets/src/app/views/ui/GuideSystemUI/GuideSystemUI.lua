local GuideSystemUI = class("GuideSystemUI", cc.Layer)

function GuideSystemUI:create()
    local p = GuideSystemUI:new()
    p:init()
    return p
end

function GuideSystemUI:init()
	local UI = require("Layer/GuideSystemUI/GuideSystemUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	
	self.Panel_title_1.Image_back:setVisible(true)
	self.Panel_title_2.Image_back:setVisible(false)
	self.Panel_title_3.Image_back:setVisible(false)
    self:hide()
end

function GuideSystemUI:showUI()
	self:show()
end

function GuideSystemUI:hideUI()
	self:hide()
end

function GuideSystemUI:showInfos(infos)
	self.ListView_item:removeAllItems()
	if MapIsEmpty(infos) == false then
		for index,info in pairs(infos) do
			local panel = self:__clonePanel()
			self:__initPanel(panel,info)
			self.ListView_item:pushBackCustomItem(panel)
		end
	end
end

function GuideSystemUI:setTitleName(name)
    name = Helper:getDef(name,"")
	self.Text_title:setString(name)
end

function GuideSystemUI:setPoint(point)
    point = Helper:getDef(point,"0")
	self.Text_pointsNum:setString(point)
end

function GuideSystemUI:setPointVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Text_pointsNum:setVisible(visible)
	self.Text_pointsName:setVisible(visible)
end

function GuideSystemUI:setTipsVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Text_tips:setVisible(visible)
end

function GuideSystemUI:setTitle_1Func(func)
	self.Panel_title_1:releaseFunc(function()
		self.Panel_title_1.Image_back:setVisible(true)
		self.Panel_title_2.Image_back:setVisible(false)
		self.Panel_title_3.Image_back:setVisible(false)
		if func then
			func()
		end
	end)
end

function GuideSystemUI:setTitle_2Func(func)
	self.Panel_title_2:releaseFunc(function()
		self.Panel_title_1.Image_back:setVisible(false)
		self.Panel_title_2.Image_back:setVisible(true)
		self.Panel_title_3.Image_back:setVisible(false)
		if func then
			func()
		end
	end)
end

function GuideSystemUI:setTitle_3Func(func)
	self.Panel_title_3:releaseFunc(function()
		self.Panel_title_1.Image_back:setVisible(false)
		self.Panel_title_2.Image_back:setVisible(false)
		self.Panel_title_3.Image_back:setVisible(true)
		if func then
			func()
		end
	end)
end

function GuideSystemUI:setButtonBackFunc(func)
	self.Button_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function GuideSystemUI:setPanelInfoVisible(visible)
	visible = Helper:getDef(visible,false)
	self.Panel_infoBg:setVisible(visible)
    self.Panel_info:setVisible(visible)
end

function GuideSystemUI:setPanelInfoDescText(text)
	self.Panel_info.Text_desc:setString(text)
end

function GuideSystemUI:setPanelInfoNameText(text)
	self.Panel_info.Text_name:setString(text)
end

function GuideSystemUI:setPanelInfoFunc()
	self.Panel_info.Button_close:releaseFunc(function()
		self:setPanelInfoVisible(false)
	end)
end

function GuideSystemUI:__clonePanel()
	local panel = self.Panel_item:clone()
	Helper:convertUIByParent(panel)
	return panel
end

function GuideSystemUI:__initPanel(panel,panelInfo)
	panel.Text_title:setString(panelInfo.title)
	panel.Image_1:loadTexture("Image/UI/GuideSystemUI/baidi.png")
	panel.Image_1.Text_name:setString("查看")
	
	--0 待接取  1 进行中  2 完成待领取奖励  3奖励领取
	if panelInfo.state == 0 then
		panel.Image_2:loadTexture("Image/UI/GuideSystemUI/kongdi.png")
		panel.Image_2.Text_name:setString("接取")
	elseif panelInfo.state == 1 then
		panel.Image_2:loadTexture("Image/UI/GuideSystemUI/kongdi.png")
		panel.Image_2.Text_name:setString("进入")
	elseif panelInfo.state == 2 then
		panel.Image_2:loadTexture("Image/UI/GuideSystemUI/kongdi.png")
		panel.Image_2.Text_name:setString("完成")
	elseif panelInfo.state == 3 then
		panel.Image_2:loadTexture("Image/UI/GuideSystemUI/kongdihui.png")
		panel.Image_2.Text_name:setString("已完成")
	end

	panel.Image_2:setVisible(true)
	panel.Text_point:setVisible(false)
	panel.Text_point:setString("点数+"..tostring(panelInfo.point))

	panel.Image_1:releaseFunc(function()
		if panelInfo.func_1 then
			panelInfo.func_1()
		end
	end)

	panel.Image_2:releaseFunc(function()
		if panelInfo.func_2 then
			panelInfo.func_2()
		end
	end)
end

Helper:classDefNodeGetInstance(GuideSystemUI)

return GuideSystemUI

000000000000