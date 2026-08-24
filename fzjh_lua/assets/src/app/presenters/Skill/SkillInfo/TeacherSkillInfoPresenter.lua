local class = require("third.class.NewClass")

local BaseSkillInfoPresenter = require("app.presenters.Skill.SkillInfo.BaseSkillInfoPresenter")

local SkillInfoTabBarUI = require("app.views.ui.SkillUI.SkillInfoTabBarUI")

local SkillInfoListBarUI = require("app.views.ui.SkillUI.SkillInfoListBarUI")

local TeacherSkillInfoPresenter = {}

function TeacherSkillInfoPresenter:create(mainPresenter,viewModel)
    local p = TeacherSkillInfoPresenter:new()
    p:__init(mainPresenter,viewModel)
    return p
end

--@desc: 
--@author:LvBin
--@time:2024-11-18 17:15:40
--@mainPresenter: [SkillInfoLayer]
	--@viewModel: [src.app.models.skill.SkillInfoViewModel.TeacherSkillInfoViewModel#TeacherSkillInfoViewModel]
--@return
function TeacherSkillInfoPresenter:__init(mainPresenter,viewModel)
    self.__mainPresenter = mainPresenter

    self.__ui = mainPresenter:getUI()

    self.__viewModel = viewModel

	self.__viewModel:setPresenter(self)

	self.__role = viewModel:getRole()
end

function TeacherSkillInfoPresenter:showPresenter()
	self:setCurrTabIndex(1)

	self.__ui:setTitleTabListViewScrollBarEnabled(false)
	
	self:setTitleName()

	self:showTitleTabList()
	
	self:setButtonTab()

	self:setButtonLianGong()

	self:setButtonSkillBreak()

	self:setButtonPrepare()
end

function TeacherSkillInfoPresenter:update()
end

function TeacherSkillInfoPresenter:setTitleName()
	MainControllLayer:getLayer("TitleLayer"):setTextTitle("师父的技能")
end

function TeacherSkillInfoPresenter:showTitleTabList()
	self.__ui:removeTitleTabListViewAllItems()

	local skillListTab = self.__viewModel:getSkillListTab()

	for i,skillTab in ipairs(skillListTab) do
		local skillTabBar = SkillInfoTabBarUI:create()

		self.__ui:insertPanelToTitleTabListView(skillTabBar)

		skillTabBar:setName(skillTab.name)
	end

	self:lightTab()

	self:setSkillList()
end

function TeacherSkillInfoPresenter:setSkillList()
	local skillList = self.__viewModel:getCurrSkillList()

	local skillListView = self.__ui:getSkillListView()

	skillListView:removeAllItems()
	
	if MapIsEmpty(skillList) then
		self:unListViewSchedule()
		return
	end

	local skillInfoBarUI = SkillInfoListBarUI

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

function TeacherSkillInfoPresenter:initSkillPanelInfo(skillPanel,roleSkill,callback)
    local skill = Skill:getSkill(roleSkill.id)
	local skillLv
	if skill:checkIsSpecialZhiShiSkill() then
		skillLv = self.__role:getSpecialZhiShiSkillLv(roleSkill.id)
	else
		skillLv = self.__role:getSkillLvWithRoleLvLimit(roleSkill.id)
	end
	
	skillPanel:setExpDsc(skillLv.."级")

	skillPanel:setName(skill:getName())
	skillPanel:setStageDsc(skill:getStageDsc(self.__role))
	skillPanel:setImageBack(false)

	skillPanel:releaseFunc(function()
        callback()
    end)
end


function TeacherSkillInfoPresenter:showSkillInfo(roleSkill)
	if roleSkill == nil then
		return
	end

	local SkillInfoPopPresenterFactory = require("app.models.skill.SkillInfoViewModel.SkillInfoPopPresenterFactory")

	local skillId = roleSkill.id

	self.__viewModel:setSkillId(skillId)
	
	local skillInfoPopPresenter = SkillInfoPopPresenterFactory:createTeacherSkillInfoPopPresenter(self)

	skillInfoPopPresenter:setParentPresenter(self)

	skillInfoPopPresenter:updateSkin(self.__mainPresenter:getSkinConfig())

	self:setPopPresenter(skillInfoPopPresenter)
	
	local popUI = skillInfoPopPresenter:getUI()

	popUI:addTo(self.__mainPresenter)
	
	skillInfoPopPresenter:showLayer()
end

function TeacherSkillInfoPresenter:setButtonTab()
	local isVisible = true

	local buttonName = "我技\n的能"

	local callback = function()
		Audio:playEffect("daAnNiu")
		
		self:hideSkillInfoPopUI()
		
        self.__mainPresenter:showMySelfSkillInfoPresenter()
	end

	self.__ui:setButtonTab(isVisible,buttonName,callback)
end

function TeacherSkillInfoPresenter:setButtonLianGong()
	self.__ui:setButtonLianGong(false)
end

function TeacherSkillInfoPresenter:setButtonSkillBreak()
	self.__ui:setButtonSkillBreak(false)
end

function TeacherSkillInfoPresenter:setButtonPrepare()
	self.__ui:setButtonPrepare(false)
end

return class("TeacherSkillInfoPresenter", {BaseSkillInfoPresenter}, TeacherSkillInfoPresenter)
0000000000000000