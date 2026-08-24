
local NewClass = require("third.class.NewClass")

local MapSkillInfoPresenter = require("app.presenters.Skill.SkillInfo.MapSkillInfoPresenter")

local BiWuMapSkillInfoPresenter = {}

function BiWuMapSkillInfoPresenter:create(mainPresenter,viewModel)
    local p = BiWuMapSkillInfoPresenter:new()
    p:__init(mainPresenter,viewModel)
    return p
end

function BiWuMapSkillInfoPresenter:setButtonPrepareSkill()
	self.__ui:setButtonPrepareVisible(false)
end

return NewClass("BiWuMapSkillInfoPresenter", {MapSkillInfoPresenter}, BiWuMapSkillInfoPresenter)
00