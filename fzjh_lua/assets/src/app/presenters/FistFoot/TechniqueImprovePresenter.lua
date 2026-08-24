local TechniqueImprovePresenter = class("TechniqueImprovePresenter", cc.Layer)

function TechniqueImprovePresenter:create()
    local p = TechniqueImprovePresenter:new()
    p:init()
    return p
end

function TechniqueImprovePresenter:init()
    --@RefType [TechniqueImproveUI]
    self.__ui = require("app.views.ui.FistFootUI.TechniqueImproveUI"):create()

    self.__ui:addTo(self)
end

function TechniqueImprovePresenter:showLayer()
    --@RefType [src.app.models.FistFootSystem.FistFootTechniques.BasicFistFootTechnique#BasicFistFootTechnique]
    self.__basicTechnique = self.__role:getFistFootSystem():getBasicFistFootTechnique(self.__techniqueId,self.__lv)
    
    self.__ui:setTextTitle2("升级条件：")
    if self.__role:getFistFootSystem():getTechniqueMaxLv(self.__techniqueId) > self.__lv then
        --@RefType [src.app.models.FistFootSystem.FistFootTechniques.BasicFistFootTechnique#BasicFistFootTechnique]
        self.__nextBasicTechnique = self.__role:getFistFootSystem():getBasicFistFootTechnique(self.__techniqueId,self.__lv + 1)

        local text = "需要升级"..self.__basicTechnique:getName().."到".. tostring(self.__nextBasicTechnique:getSkilllv()) .."级，需要消耗"..self.__nextBasicTechnique:getSkillcon().."点技巧感悟点数，是否提升？"
    
        self.__ui:setTextTitle1(text)
    
        self.__ui:setTextDesc1(self.__nextBasicTechnique:getOpentext())
    else
        self.__ui:setTextTitle1("当前已是最大等级")

        self.__ui:setTextDesc1("")
    end

    self.__ui:setPanelText1("当前技巧感悟点数：",self.__role:getFistFootSystem():getFeelPoint())

    self:setButtonConfirm()

    self:setButtonCancel()

    self.__ui:show()
end

function TechniqueImprovePresenter:setRole(role)
    self.__role = role
end

function TechniqueImprovePresenter:setTechniqueId(techniqueId)
    self.__techniqueId = techniqueId
end

function TechniqueImprovePresenter:setTechniqueLv(lv)
    self.__lv = lv
end

function TechniqueImprovePresenter:setType(type)
    self.__type = type
end

function TechniqueImprovePresenter:setCallback(callback)
    self.__callback = callback
end

function TechniqueImprovePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "TechniqueImprovePresenter",
        function(layer)
            self.__ui:hide()
        end
    )
end


function TechniqueImprovePresenter:setButtonConfirm(func)
    self.__ui:setButtonConfirm(function()
        self.__role:getFistFootSystem():upgradeTechnique(
            self.__type,
            self.__techniqueId,
            function(isOk,msg,data)
                if isOk then
                    if self.__callback then
                        self.__callback()
                        
                        PopText("技巧提升成功")
                    end
                else
                    PopText(msg)
                end
                self:hideLayer()
            end
        )
    end)
end

function TechniqueImprovePresenter:setButtonCancel(func)
    self.__ui:setButtonCancel(function()
        self:hideLayer()
    end)
end


Helper:classDefNodeGetInstance(TechniqueImprovePresenter)
return TechniqueImprovePresenter
000000