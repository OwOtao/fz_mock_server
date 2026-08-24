local TechniqueUnlockPresenter = class("TechniqueUnlockPresenter", require("app.presenters.FistFoot.TechniqueImprovePresenter"))

function TechniqueUnlockPresenter:create()
    local p = TechniqueUnlockPresenter:new()
    p:init()
    return p
end

function TechniqueUnlockPresenter:init()
    --@RefType [TechniqueImproveUI]
    self.__ui = require("app.views.ui.FistFootUI.TechniqueImproveUI"):create()

    self.__ui:addTo(self)
end

function TechniqueUnlockPresenter:showLayer()

    self.__lv = 1
    --@RefType [src.app.models.FistFootSystem.FistFootTechniques.BasicFistFootTechnique#BasicFistFootTechnique]
    self.__basicTechnique = self.__role:getFistFootSystem():getBasicFistFootTechnique(self.__techniqueId,self.__lv)

    local text = "需要解锁"..self.__basicTechnique:getName().."，需要消耗"..self.__basicTechnique:getSkillcon().."点技巧感悟点数，是否提升？"
    
    self.__ui:setTextTitle1(text)

    self.__ui:setTextTitle2("升级条件：")

    self.__ui:setTextDesc1(self.__basicTechnique:getOpentext())

    self.__ui:setPanelText1("当前技巧感悟点数：",self.__role:getFistFootSystem():getFeelPoint())

    self:setButtonConfirm()

    self:setButtonCancel()

    self.__ui:show()
end

function TechniqueUnlockPresenter:setRole(role)
    self.__role = role
end

function TechniqueUnlockPresenter:setTechniqueId(techniqueId)
    self.__techniqueId = techniqueId
end

function TechniqueUnlockPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "TechniqueUnlockPresenter",
        function(layer)
            self.__ui:hide()
        end
    )
end

function TechniqueUnlockPresenter:setButtonConfirm(func)
    self.__ui:setButtonConfirm(function()
        self.__role:getFistFootSystem():upgradeTechnique(
            self.__type,
            self.__techniqueId,
            function(isOk,msg,data)
                if isOk then
                    if self.__callback then
                        self.__callback()
                        
                        PopText("技巧解锁成功")

                    end
                else
                    PopText(msg)
                end
                self:hideLayer()
            end
        )
    end)
end

function TechniqueUnlockPresenter:setButtonCancel(func)
    self.__ui:setButtonCancel(function()
        self:hideLayer()
    end)
end


Helper:classDefNodeGetInstance(TechniqueUnlockPresenter)
return TechniqueUnlockPresenter
0000