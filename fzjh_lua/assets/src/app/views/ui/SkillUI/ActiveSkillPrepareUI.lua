local ActiveSkillPrepareUI = class("ActiveSkillPrepareUI", LayerEx)
local isImplement = require("third.assertIsInstance.assertIsInstance")
local IActiveSkillPreparePresenterOutput = require("app.presenters.ActiveSkillPrepare.IActiveSkillPreparePresenterOutput")

function ActiveSkillPrepareUI:create()
	local p = ActiveSkillPrepareUI:new()
	p:init()
	return p
end

function ActiveSkillPrepareUI:init()
	self._UI = require("Layer/SkillUI/ActiveSkillPrepareUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self) -- 获得所有子节点

	self.ListView_prepare:setScrollBarEnabled(false)
	self.ListView_select:setScrollBarEnabled(false)
	self.Image_tab.ListView_tab:setScrollBarEnabled(false)
	self.Panel_selectBg:releaseFunc(function()
		self:hideSelectUI()
	end)
end

function ActiveSkillPrepareUI:updateLayerSkinUI(skinConfig)
	if skinConfig.AttrTabpic then
		self.Image_tab:loadTexture(skinConfig.AttrTabpic, 0)
	else
		self.Image_tab:loadTexture("Image/UI/AttrUI/tab.png", 0)
	end

	self.__Attrclickpic = skinConfig.Attrclickpic or "Image/UI/AttrUI/tab3.png"

	self.__Skillbtnpic = skinConfig.Skillbtnpic or "Image/UI/SkillUI/02.png"
end

function ActiveSkillPrepareUI:setInput(input) 
	self.__input = input
end

function ActiveSkillPrepareUI:showLayer()
	self:hideSelectUI()
	self.__input:show()
end

function ActiveSkillPrepareUI:setTopText(text)
	self:__setText1Str(text)
end

function ActiveSkillPrepareUI:setBottomText(text)
	self:__setText2Str(text)
	self.Text_2:setTextColor({r = 208, g = 208, b = 208})
end

function ActiveSkillPrepareUI:setNavigationBar(barList, index)
	self.Image_tab.ListView_tab:removeAllItems()
	if MapIsEmpty(barList) == false then
		for i = 1, #barList do
			local item = self:__createPanel2()
			local info = {}
			info[1] = barList[i]

			if index == i then
				info[2] = true
			else
				info[2] = false
			end

			self:__initPanel2(i, item, info)
			self.Image_tab.ListView_tab:pushBackCustomItem(item)
		end
	end
end

function ActiveSkillPrepareUI:showMiddleList(listInfo)
	self.ListView_prepare:removeAllItems()
	if MapIsEmpty(listInfo) == false then
		for i = 1, #listInfo do
			local item = self:__createPanel1()
			self:__initPanel1(item, listInfo[i], i)
			self.ListView_prepare:pushBackCustomItem(item)
		end
	end
end

function ActiveSkillPrepareUI:showSelectList(list)
	self.ListView_select:removeAllItems()
	if MapIsEmpty(list) == false then
		for i, v in ipairs(list) do
			local item = self:__createPanel3()
			self:__initPanel3(i, item, v)
			self.ListView_select:pushBackCustomItem(item)
		end
	end
end

function ActiveSkillPrepareUI:showSelectUI()
	self.Panel_selectBg:setVisible(true)
	self.Image_select:setVisible(true)
	self.Text_3:setVisible(true)
	self.ListView_select:setVisible(true)
end

function ActiveSkillPrepareUI:setSelectTextStr(str)
	self.Text_3:setString(str)
end

function ActiveSkillPrepareUI:hideSelectUI()
	self.Panel_selectBg:setVisible(false)
	self.Image_select:setVisible(false)
	self.Text_3:setVisible(false)
	self.ListView_select:setVisible(false)
end

function ActiveSkillPrepareUI:__createPanel1()
	local panel = self.Panel_1:clone()
	panel:setVisible(true)
	Helper:convertUIByParent(panel)
	return panel
end

function ActiveSkillPrepareUI:__initPanel1(panel, info, idx)
	panel.Text_1:setString(Helper:getDef(info[1],""))
	panel.Text_2:setString(Helper:getDef(info[2],""))
	panel.Text_3:setString(Helper:getDef(info[3],""))
	panel.Button_1.Text_1:setString(Helper:getDef(info[4],""))
	panel.Button_1:loadTextureNormal(self.__Skillbtnpic, 0)
	if info[5] then
		self:__initText(panel.Button_1.Text_1, info[5], info[6], info[7], info[8])
	end
	panel.Button_1:releaseFunc(function()
		self.__input:clickMiddleItem(idx)
	end)
end

function ActiveSkillPrepareUI:__initText(text, textcolor, fontSize, outlineColor, outlineWidth)
	text:enableOutline(outlineColor, outlineWidth)
	text:setTextColor(textcolor)
	text:setFontSize(fontSize)
end

function ActiveSkillPrepareUI:__createPanel2()
	local panel = self.Panel_2:clone()
	panel:setVisible(true)
	Helper:convertUIByParent(panel)
	return panel
end

function ActiveSkillPrepareUI:__initPanel2(idx, panel, info)
	panel.Text_name:setString(Helper:getDef(info[1],""))
	panel.Image_back:setVisible(Helper:getDef(info[2],false))
	panel.Image_back:setScale9Enabled(true)
	panel.Image_back:ignoreContentAdaptWithSize(false)
	panel.Image_back:setCapInsets({x = -48, y = 7, width = 120, height = 11})
	panel.Image_back:loadTexture(self.__Attrclickpic, 0)
	panel:releaseFunc(function()
		self.__input:clickNavigationBar(idx)
	end)
end

function ActiveSkillPrepareUI:__createPanel3()
	local panel = self.Panel_3:clone()
	panel:setVisible(true)
	Helper:convertUIByParent(panel)
	return panel
end

function ActiveSkillPrepareUI:__initPanel3(i, panel, info)
	panel.state:setVisible(Helper:getDef(info[2],false))
	panel.Text_1:setString(Helper:getDef(info[3],""))
	panel.Text_2:setString(Helper:getDef(info[4],""))
	panel.Text_3:setString(Helper:getDef(info[5],""))
	panel.Text_4:setString(Helper:getDef(info[6],""))
	panel:releaseFunc(function()
		self.__input:clickSelectItem(info[1])
	end)
end

function ActiveSkillPrepareUI:__setText1Str(str)
	str = Helper:getDef(str, "")
	self.Text_1:setString(str)
end

function ActiveSkillPrepareUI:__setText2Str(str)
	str = Helper:getDef(str, "")
	self.Text_2:setString(str)
end

isImplement(ActiveSkillPrepareUI,IActiveSkillPreparePresenterOutput)
Helper:classDefNodeGetInstance(ActiveSkillPrepareUI)

return ActiveSkillPrepareUI0000000000000000