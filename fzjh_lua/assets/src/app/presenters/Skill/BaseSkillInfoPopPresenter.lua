local ISkillInfoPopPresenter = require("app.presenters.Skill.interface.ISkillInfoPopPresenter")

local abstract = require("third.class.abstract")

local BaseSkillInfoPopPresenter = {
    __backFunc = EMPTY_FUNC
}

function BaseSkillInfoPopPresenter:setUI(ui)
    self.__ui = ui
end

function BaseSkillInfoPopPresenter:getUI()
    return self.__ui
end

function BaseSkillInfoPopPresenter:setParentPresenter(parentPresenter)
    self.__parentPresenter = parentPresenter
end

function BaseSkillInfoPopPresenter:getParentPresenter()
    return self.__parentPresenter
end

function BaseSkillInfoPopPresenter:getParentModel()
    return self.__parentPresenter:getViewModel()
end

function BaseSkillInfoPopPresenter:setBackFunc(func)
    self.__backFunc = func
end

function BaseSkillInfoPopPresenter:updateSkin(skin_config)
    if self.__ui and self.__ui.updateSkin then
        self.__ui:updateSkin(skin_config)
    end
end

return abstract("BaseSkillInfoPopPresenter", {ISkillInfoPopPresenter}, BaseSkillInfoPopPresenter)
000000000000000