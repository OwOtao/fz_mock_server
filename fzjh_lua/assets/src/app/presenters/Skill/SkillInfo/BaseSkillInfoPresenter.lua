--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-11-18 11:57:00
--]]
local class = require("third.class.NewClass")

local BaseSkillInfoPresenter = {}

function BaseSkillInfoPresenter:create()
    local p = BaseSkillInfoPresenter:new()
    p:__init()
    return p
end

function BaseSkillInfoPresenter:__init()
end

function BaseSkillInfoPresenter:showPresenter()
end

function BaseSkillInfoPresenter:setTitleName()
end

function BaseSkillInfoPresenter:getViewModel()
	return self.__viewModel
end

function BaseSkillInfoPresenter:setPopPresenter(popPresenter)
	self.__popPresenter = popPresenter
end

function BaseSkillInfoPresenter:setCurrTabIndex(index)
    self.__currTabIndex = index
end

function BaseSkillInfoPresenter:getCurrTabIndex()
    return self.__currTabIndex
end

function BaseSkillInfoPresenter:lightTab()
	local items = self.__ui:getListViewTabItems()
	
	for i, item in ipairs(items) do
		if i == self:getCurrTabIndex() then
			item:light()
		else
			item:dark()
		end
	end
end

function BaseSkillInfoPresenter:hideSkillInfoPopUI()
	if self.__popPresenter then
		local popUI = self.__popPresenter:getUI()
		if popUI then
			popUI:removeFromParent()
		end

		self.__popPresenter = nil
	end
end

function BaseSkillInfoPresenter:hideSkillListImageBack()
	local items = self.__ui:getSkillListView():getItems()

	for i,item in ipairs(items) do
		item:setImageBack(false)
	end
end

function BaseSkillInfoPresenter:hideSkillInfoPresenter()
	self:unListViewSchedule()

	self:hideSkillInfoPopUI()

	self.__ui:removeTitleTabListViewAllItems()

	self.__ui:removeSkillListViewAllItems()
end

function BaseSkillInfoPresenter:unListViewSchedule()
	if self.listViewSchedule then
		self.__mainPresenter:unschedule(self.listViewSchedule)
		self.listViewSchedule = nil
	end
end


return class("BaseSkillInfoPresenter", {}, BaseSkillInfoPresenter)
00000000000