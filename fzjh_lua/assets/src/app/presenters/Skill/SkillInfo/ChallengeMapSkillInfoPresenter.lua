local NewClass = require("third.class.NewClass")

local MapSkillInfoPresenter = require("app.presenters.Skill.SkillInfo.MapSkillInfoPresenter")

local ChallengeMapSkillInfoPresenter = {}

function ChallengeMapSkillInfoPresenter:create(mainPresenter,viewModel)
    local p = ChallengeMapSkillInfoPresenter:new()
    p:__init(mainPresenter,viewModel)
    return p
end

function ChallengeMapSkillInfoPresenter:__initUI()
    self.__ui:setTitleTabListViewItemsMargin(30)

    self.__ui:setTitleTabListViewScrollBarEnabled(false)
end

function ChallengeMapSkillInfoPresenter:setButtonPrepareSkill()
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

return NewClass("ChallengeMapSkillInfoPresenter", {MapSkillInfoPresenter}, ChallengeMapSkillInfoPresenter)
000000000