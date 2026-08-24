local NewClass = require("third.class.NewClass")

local MapSkillInfoPresenter = require("app.presenters.Skill.SkillInfo.MapSkillInfoPresenter")

local DreamMapSkillInfoPresenter = {}

function DreamMapSkillInfoPresenter:create(mainPresenter,viewModel)
    local p = DreamMapSkillInfoPresenter:new()
    p:__init(mainPresenter,viewModel)
    return p
end

function DreamMapSkillInfoPresenter:__initUI()
    self.__ui:setTitleTabListViewItemsMargin(30)

    self.__ui:setTitleTabListViewScrollBarEnabled(false)
end

function DreamMapSkillInfoPresenter:getTextExpDsc(skillId)
	return ""
end

function DreamMapSkillInfoPresenter:getSkillPanelTextPosX()
	return 700
end

function DreamMapSkillInfoPresenter:getSkillInfoPopPresenter()
	local SkillInfoPopPresenterFactory = require("app.models.skill.SkillInfoViewModel.SkillInfoPopPresenterFactory")

	return SkillInfoPopPresenterFactory:createDreamMapSkillInfoPopPresenter(self)
end

function DreamMapSkillInfoPresenter:setButtonPrepareSkill()
	self.__ui:setButtonPrepareVisible(true)
	
    self.__ui:setButtonPrepareSkill(function()
		self.__mainPresenter:setVisible(false)
		
		self:hidePresenter()
		
		local titleLayer = MainControllLayer:getLayer("TitleLayer")
		titleLayer:setSetUpButtonName("准备技能")
		titleLayer:setTitleJHBack()
		titleLayer:show()
		
		titleLayer:setSkillPrepSkillLayerSetupBtnVisible(false)
        
		local skillPrepareLayer = MainControllLayer:getLayer("SkillPrepareLayer")
		MainControllLayer:pushLayer("SkillPrepareLayer")
		skillPrepareLayer:setRole(self.__role)
		skillPrepareLayer:initPrepareSkills()
	end)
end

return NewClass("DreamMapSkillInfoPresenter", {MapSkillInfoPresenter}, DreamMapSkillInfoPresenter)
000000000