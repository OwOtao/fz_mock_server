local NewClass = require("third.class.NewClass")

local DreamMapSkillInfoPresenter = require("app.presenters.Skill.SkillInfo.DreamMapSkillInfoPresenter")

local FondDreamMapSkillInfoPresenter = {}

function FondDreamMapSkillInfoPresenter:create(mainPresenter,viewModel)
    local p = FondDreamMapSkillInfoPresenter:new()
    p:__init(mainPresenter,viewModel)
    return p
end

function FondDreamMapSkillInfoPresenter:getSkillInfoPopPresenter()
	local SkillInfoPopPresenterFactory = require("app.models.skill.SkillInfoViewModel.SkillInfoPopPresenterFactory")

	return SkillInfoPopPresenterFactory:createFondDreamMapSkillInfoPopPresenter(self)
end

return NewClass("FondDreamMapSkillInfoPresenter", {DreamMapSkillInfoPresenter}, FondDreamMapSkillInfoPresenter)
000000