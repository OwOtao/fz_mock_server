--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-12-26 16:09:47
--]]
local NewClass = require("third.class.NewClass")

local BaseSkillInfoPresenter = require("app.presenters.Skill.SkillInfo.BaseSkillInfoPresenter")

local RoleSkillInfoTabBarUI = require("app.views.ui.SkillUI.RoleSkillInfoTabBarUI")

local RoleSkillInfoListBarUI = require("app.views.ui.SkillUI.RoleSkillInfoListBarUI")

local SkillConst = require("app.models.skill.SkillConst")

local MapSkillInfoPresenter = {}

function MapSkillInfoPresenter:create(mainPresenter,viewModel)
    local p = MapSkillInfoPresenter:new()
    p:__init(mainPresenter,viewModel)
    return p
end

--@desc: init 初始化
--@author:Seven
--@time:2024-10-31 15:20:16
--@mainPresenter:[MapRoleLayer]
	--@viewModel: 
--@return:
function MapSkillInfoPresenter:__init(mainPresenter,viewModel)
	--@RefType [MapRoleLayer]
	self.__mainPresenter = mainPresenter

    self.__viewModel = viewModel

	self.__viewModel:setPresenter(self)

	self.__role = viewModel:getRole()
end

function MapSkillInfoPresenter:getViewModel()
	return self.__viewModel
end

--@desc: 
--@author:LvBin
--@time:2024-12-31 11:28:07
--@return
function MapSkillInfoPresenter:showPresenter()
	PopupLayerController:showLayer("MapRoleSkillInfoUI",function(ui)
		self.__ui = ui

		self:__initUI()

		self:setCurrTabIndex(1)
	
		self:showTitleTabList()
	
		self:setButtonPrepareSkill()
	
		self.__ui:showUI()
	end)
end

function MapSkillInfoPresenter:__initUI()
	self.__ui:setTitleTabListViewItemsMargin(0)

    self.__ui:setTitleTabListViewScrollBarEnabled(false)
end

function MapSkillInfoPresenter:hidePresenter()
	self:hideSkillInfoPopUI()

	self:unListViewSchedule()
	
	PopupLayerController:hideLayer("MapRoleSkillInfoUI",function(ui)
		ui:hideUI()
	end)
end

function MapSkillInfoPresenter:showTitleTabList()
	self.__ui:removeTitleTabListViewAllItems()

	local skillListTab = self.__viewModel:getSkillListTab()

	for i,skillTab in ipairs(skillListTab) do
		local skillTabBar = RoleSkillInfoTabBarUI:create()

		self.__ui:insertPanelToTitleTabListView(skillTabBar)

		skillTabBar:setName(skillTab.name)

		skillTabBar:releaseFunc(
			function()
				Audio:playEffect("xiaoAnNiu")

				self:setCurrTabIndex(i)

				self.__skillListPos = nil

				self:lightTab()

				self:setSkillList()

				self:hideSkillInfoPopUI()
			end
		)
	end

	self:lightTab()

	self:setSkillList()
end

function MapSkillInfoPresenter:setSkillList()
	local skillList = self.__viewModel:getCurrSkillList()

	local skillType = self.__viewModel:getCurrTabSkillType()
	
	skillList = self.__viewModel:sortSkill(skillList,skillType)

	local skillListView = self.__ui:getSkillListView()

	skillListView:removeAllItems()
	
	if MapIsEmpty(skillList) then
		self:unListViewSchedule()
		return
	end

	local skillInfoBarUI = RoleSkillInfoListBarUI

	skillListView:setSwallowTouches(false)

    local roleItemNum = #skillList
    local listSize = skillListView:getContentSize()
    local itemSize = skillInfoBarUI:create():getContentSize()
    local itemsMargin = skillListView:getItemsMargin()
    local itemMaxCount = Helper:mathFloor(listSize.height/(itemSize.height + itemsMargin)) + 2
    local isSchedule = true

    if roleItemNum < itemMaxCount then
        itemMaxCount = roleItemNum
        isSchedule = false
    end

    skillListView:setItemHeight(itemSize.height)

    skillListView:setItemInitFunc(function(skillPanel,skillInfo)
        self:initSkillPanelInfo(skillPanel,skillInfo,function()
			Audio:playEffect("daAnNiu")

			self:hideSkillInfoPopUI()

			self:showSkillInfo(skillInfo)

			self:hideSkillListImageBack()

			skillPanel:setImageBack(true)
		end)
    end)

    skillListView:setItemCreateFunc(function()
        return skillInfoBarUI:create()
    end)

    skillListView:showListView(skillList,itemMaxCount)

    if isSchedule then
        if self.__skillListPos then
            if self.__skillListPos.y > skillListView:getInnerContainerPosition().y then
                skillListView:setInnerContainerPosition(self.__skillListPos)
            end
        else
            skillListView:jumpToTop()
        end

        local isTrue = skillListView:refreshReuseItems()
		while isTrue do
			isTrue = skillListView:refreshReuseItems()
		end

        self:unListViewSchedule()

        self.listViewSchedule = self.__mainPresenter:schedule(function()
            skillListView:refreshReuseItems()
            self.__skillListPos = skillListView:getLastInnerContainerPosition()
        end)
    end
end

function MapSkillInfoPresenter:initSkillPanelInfo(skillPanel,roleSkill,callback)
    local skillId = roleSkill.id
    local skill = self.__viewModel:getSkill(skillId)

	skillPanel:setName(skill:getName())
	skillPanel:setStageDsc(self.__viewModel:getSkillStageDsc(skillId))
	skillPanel.Text_dsc:setPosition(self:getSkillPanelTextPosX(),40)
	skillPanel:setExpDsc(self:getTextExpDsc(skillId))
	skillPanel:setImageBack(false)

	skillPanel:releaseFunc(function()
        callback()
    end)

    local prepareSkills = self.__role:getSkillPrepare()

    local state = false

    local skillType = self.__viewModel:getCurrTabSkillType()
    
    local prepareList = SkillConst.PrepareList
    
    for k,v in pairs(prepareSkills) do
        if prepareList[k] ~= nil then
            if (k == skillType or (k == "quanjiao2" and skillType == "quanjiao1")) and ((skill.type == SKILL_TYPE_BASE and prepareList[k] == skill.id) or v == skill.id) then
                state = true
        elseif skillType == "bingqi" and ((skill.type == SKILL_TYPE_BASE and prepareList[k] == skill.id) or v == skill.id) and (k ~= "quanjiao1" and k ~= "quanjiao2" and k ~= "zhaojia" and k ~= "neigong" and k ~= "qinggong") then
                state = true
            end
        end
    end

    skillPanel:setDian(state)
end

function MapSkillInfoPresenter:showSkillInfo(roleSkill)
	if roleSkill == nil then
		return
	end

	local skillId = roleSkill.id

	self.__viewModel:setSkillId(skillId)

	local mapSkillInfoPopPresenter = self:getSkillInfoPopPresenter()

	mapSkillInfoPopPresenter:setParentPresenter(self)

	self:setPopPresenter(mapSkillInfoPopPresenter)
	
	local popUI = mapSkillInfoPopPresenter:getUI()

	popUI:addTo(self.__ui)
	
	mapSkillInfoPopPresenter:showLayer()
end

function MapSkillInfoPresenter:setButtonPrepareSkill()
	self.__ui:setButtonPrepareVisible(true)

    self.__ui:setButtonPrepareSkill(function()
		self.__mainPresenter:setVisible(false)
		
		self:hidePresenter()
		
		local titleLayer = MainControllLayer:getLayer("TitleLayer")
		titleLayer:setSetUpButtonName("准备技能")
		titleLayer:setTitleJHBack()
		titleLayer:show()
		
		titleLayer:setSkillPrepSkillLayerSetupBtnVisible(true)
		titleLayer:setButton_setupFunc(function()
			MainControllLayer:pushLayer("ActiveSkillPrepareUI")

			local activeSkillPrepareUI = MainControllLayer:getLayer("ActiveSkillPrepareUI")
			local activeSkillPreparePresenter = require("app.presenters.ActiveSkillPrepare.ActiveSkillPreparePresenter"):create()
			local activeSkillPrepare = require("app.models.ActiveSkillPrepare.ActiveSkillPrepare"):create()
			activeSkillPrepare:setRole(self.__role)
			activeSkillPrepare:initialize()
			
			activeSkillPreparePresenter:setOutput(activeSkillPrepareUI)
			activeSkillPreparePresenter:setInput(activeSkillPrepare)

			activeSkillPrepareUI:setInput(activeSkillPreparePresenter)
			activeSkillPrepareUI:showLayer()
		end)
        
		local skillPrepareLayer = MainControllLayer:getLayer("SkillPrepareLayer")
		MainControllLayer:pushLayer("SkillPrepareLayer")
		skillPrepareLayer:setRole(self.__role)
		skillPrepareLayer:initPrepareSkills()

		User:getRole():setFlag("PVP活动状态", "忙碌")
	end)
end

function MapSkillInfoPresenter:getTextExpDsc(skillId)
	local skill = self.__viewModel:getSkill(skillId)
	local skillLv
	if skill:checkIsSpecialZhiShiSkill() then
		skillLv = self.__role:getSpecialZhiShiSkillLv(skillId)
	else
		skillLv = self.__role:getSkillLvWithRoleLvLimit(skillId)
	end

	return skillLv.."级"
end

function MapSkillInfoPresenter:getSkillPanelTextPosX()
	return 500
end

function MapSkillInfoPresenter:getSkillInfoPopPresenter()
	local SkillInfoPopPresenterFactory = require("app.models.skill.SkillInfoViewModel.SkillInfoPopPresenterFactory")

	return SkillInfoPopPresenterFactory:createMapSkillInfoPopPresenter(self)
end

return NewClass("MapSkillInfoPresenter", {BaseSkillInfoPresenter}, MapSkillInfoPresenter)
000000