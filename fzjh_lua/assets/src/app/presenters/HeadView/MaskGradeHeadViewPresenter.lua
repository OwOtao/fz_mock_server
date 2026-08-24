local newClass = require("third.class.NewClass")

local IHeadViewPresenter = require("app.presenters.HeadView.IHeadViewPresenter")

local MaskGradeHeadViewPresenter = {}

function MaskGradeHeadViewPresenter:create(maskGrade, ui)
    local p = MaskGradeHeadViewPresenter.new()
    p:__init(maskGrade, ui)
    return p
end

function MaskGradeHeadViewPresenter:__init(maskGrade, ui)
    --@RefType [src.app.models.mask.MaskGrade#MaskGrade]
    self.__maskGrade = maskGrade

    --@RefType [HeadView]
    self.__ui = ui
end

function MaskGradeHeadViewPresenter:showTheHead()
    local animPath = self.__maskGrade:getAnimPath()

    self.__ui:setBorderImg(self.__maskGrade:getFramePath())

    self.__ui:setImageBackgroud(self.__maskGrade:getBackgroundPath())

    if animPath then
        self.__ui:setHeadAnimVisible(true)
        self.__ui:setHeadImageVisible(false)
        self.__ui:showTheHeadAnim(animPath)
    else
        self.__ui:setHeadAnimVisible(false)
        self.__ui:setHeadImageVisible(true)
        self.__ui:setHeadImage(self.__maskGrade:getResPath())
    end

    local effectName = self.__maskGrade:getEffectPath()

    if effectName then
        self.__ui:setHeadEffectVisible(true)
        self.__ui:playEffect(effectName)
    else
        self.__ui:setHeadEffectVisible(false)
    end
end

return newClass("MaskGradeHeadViewPresenter", {IHeadViewPresenter}, MaskGradeHeadViewPresenter)
0