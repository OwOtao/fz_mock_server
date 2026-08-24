local class = require("third.class.NewClass")

local MapNormalSkillInfoPopPresenter = require("app.presenters.Skill.NormalSkill.MapNormalSkillInfoPopPresenter")

local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")

local FondDreamMapNormalSkillInfoPopPresenter = {}

function FondDreamMapNormalSkillInfoPopPresenter:create()
    local p = FondDreamMapNormalSkillInfoPopPresenter:new()
    p:init()
    return p
end

function FondDreamMapNormalSkillInfoPopPresenter:__showNormalMapSkilInfo()
    PopupLayerController:showLayer("BasicSkillDetailPresenter",function (layer)
        layer:showLayer(self.__role,self.__skillId)
    end)
end

return class("FondDreamMapNormalSkillInfoPopPresenter", {MapNormalSkillInfoPopPresenter}, FondDreamMapNormalSkillInfoPopPresenter)
000000