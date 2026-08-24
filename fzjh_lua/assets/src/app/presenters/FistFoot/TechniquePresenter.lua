local TechniquePresenter = class("TechniquePresenter", cc.Layer)

local FistFootResManager = require("app.models.FistFootSystem.FistFootResManager")

local FistFootConst = require("app.models.FistFootSystem.FistFootConst")

function TechniquePresenter:create()
    local p = TechniquePresenter:new()
    p:init()
    return p
end

function TechniquePresenter:init()
    self.__ui = require("app.views.ui.FistFootUI.TechniqueUI"):create()

    self.__ui:addTo(self)
end

function TechniquePresenter:showLayer()
    self.__index = 1

    self:initTechniqueList()

    self:setPanelButton()
    
    self:setButton1()
    
    self:setButton2()

    self:setPanelText()

    self.__ui:show()
end

function TechniquePresenter:initTechniqueList()
    self.__techniqueList = {}
    local techniqueLevelData = FistFootResManager:getTechniqueLevelData()
    for i = 1,10 do
        if self.__techniqueList[i] == nil then
            self.__techniqueList[i] = {}
        end
        for k,v in pairs(techniqueLevelData) do
            if v.splace == i and v.type == self.__type then
                local techniqueId = v.skillid
                local isOpen = false
                local lv = self.__role:getFistFootSystem():getTechniqueLv(techniqueId)
                if lv > 0 then
                    isOpen = true
                else
                    lv = 1
                end
                self.__techniqueList[i].id = techniqueId
                self.__techniqueList[i].isOpen = isOpen
                self.__techniqueList[i].lv = lv
                break
            end
        end
    end
end

function TechniquePresenter:refreshLayer()
    self:initTechniqueList()

    self:setPanelButton()

    self:setButton2()

    self:setPanelText()
end

function TechniquePresenter:setRole(role)
    self.__role = role
end

function TechniquePresenter:setType(type)
    self.__type = type
end

function TechniquePresenter:setPanelButton()
    for i = 1, 10 do
        local techniqueId = self.__techniqueList[i].id
        local lv = self.__techniqueList[i].lv
        local isOpen = self.__techniqueList[i].isOpen
        local retData = {}
        
        if isOpen == true then
            --@RefType [src.app.models.FistFootSystem.FistFootTechniques.BasicFistFootTechnique#BasicFistFootTechnique]
            local basicTechnique = self.__role:getFistFootSystem():getBasicFistFootTechnique(techniqueId,lv)
            if basicTechnique:isEffect() == FistFootConst.TechniqueType.Normal then
                retData.image1 = "Image/UI/FistFootUI/kuang4.png"
                retData.image2 = "Image/UI/FistFootUI/technic1.png"
            elseif basicTechnique:isEffect() == FistFootConst.TechniqueType.Special then
                retData.image1 = "Image/UI/FistFootUI/kuang5.png"
                retData.image2 = "Image/UI/FistFootUI/technic3.png"
            else
                error("TechniquePresenter:setPanelButton 技巧类型异常 ：".. basicTechnique:isEffect())
            end
            
        else
            retData.image1 = "Image/UI/FistFootUI/kuang1.png"
            retData.image2 = "Image/UI/FistFootUI/technic2.png"
        end
        
        retData.callback = function() 
            if self.__index ~= i then
                self.__index = i

                self.__ui:setLightButton(i)

                self:setPanelText()

                self:setButton2()
            end
        end

        self.__ui:setPanelButton(i,retData)
    end

    self.__ui:setLightButton(self.__index)
end

function TechniquePresenter:setButton1()
    self.__ui:setButton1("技巧修炼",
        function()
            local techniqueId = self.__techniqueList[self.__index].id
            local lv = self.__techniqueList[self.__index].lv
            local isOpen = self.__techniqueList[self.__index].isOpen

            local branchLv = self.__role:getFistFootSystem():getBranchLv(self.__type)

            if lv >= branchLv then
                PopText("提升技巧失败，该技巧不得大于该拳脚等级")
                return
            end

            local techniqueMaxLv = self.__role:getFistFootSystem():getTechniqueMaxLv(techniqueId)
            if lv >= techniqueMaxLv then
                PopText("该技巧已经达到最大等级，无法提升")
                return
            end

            if isOpen then
                PopupLayerController:showLayer("TechniqueImprovePresenter", function(layer)
                    layer:setRole(self.__role)
                    layer:setTechniqueId(techniqueId)
                    layer:setTechniqueLv(lv)
                    layer:setType(self.__type)
                    layer:setCallback(function()
                        self:refreshLayer()
                    end)
                    layer:showLayer()
                end)
            else
                PopupLayerController:showLayer("TechniqueUnlockPresenter", function(layer)
                    layer:setRole(self.__role)
                    layer:setTechniqueId(techniqueId)
                    layer:setTechniqueLv(lv)
                    layer:setType(self.__type)
                    layer:setCallback(function()
                        self:refreshLayer()
                    end)
                    layer:showLayer()
                end)
            end


        end
    )
end

function TechniquePresenter:setButton2()
    local isGray = false
    local techniqueId = self.__techniqueList[self.__index].id
    local lv = self.__techniqueList[self.__index].lv
    local isOpen = self.__techniqueList[self.__index].isOpen

    local basicTechnique = self.__role:getFistFootSystem():getBasicFistFootTechnique(techniqueId,lv)
    if basicTechnique:isEffect() ~= FistFootConst.TechniqueType.Special then
        isGray = true
    end

    if isOpen ~= true then
        isGray = true
    end

    self.__ui:setButton2(
        isGray,
        "领悟特性",
        function()
            if basicTechnique:isEffect() ~= FistFootConst.TechniqueType.Special then
                PopText("此技巧无法领悟特性")
                return
            end

            if isOpen ~= true then
                PopText("该技巧尚未升级，不能领悟特性")
                return
            end

            local opicount = basicTechnique:getResource()

            MainControllLayer:pushLayer("ComprehendCharacterPresenter")
            local comprehendCharacterPresenter = MainControllLayer:getLayer("ComprehendCharacterPresenter")
            comprehendCharacterPresenter:setRole(self.__role)
            comprehendCharacterPresenter:setType(self.__type)
            comprehendCharacterPresenter:setTechniqueId(techniqueId)
            comprehendCharacterPresenter:setOpicount(opicount)
            comprehendCharacterPresenter:setCharacterLv(lv)
            comprehendCharacterPresenter:setCallback(function()
                self:setPanelText()
            end)
            comprehendCharacterPresenter:showLayer()
        end
    )
end

function TechniquePresenter:setPanelText()
    local techniqueId = self.__techniqueList[self.__index].id
    local lv = self.__techniqueList[self.__index].lv
    local isOpen = self.__techniqueList[self.__index].isOpen

    local basicTechnique = self.__role:getFistFootSystem():getBasicFistFootTechnique(techniqueId,lv)

    local textMap = {}
    textMap[1] = basicTechnique:getName()
    textMap[2] = "剩余感悟点数："..self.__role:getFistFootSystem():getFeelPoint()
    textMap[3] = "【境界等级】："..lv
    textMap[4] = "谙技："..basicTechnique:getJqdamage()
    textMap[5] = "特性效果"
    if basicTechnique:isEffect() == FistFootConst.TechniqueType.Normal then
        textMap[6] = "无法领悟"
    else
        if isOpen then
            local tech = self.__role:getFistFootSystem():getTechniqueByBranchTypeFromClassMap(self.__type,techniqueId)
            --@RefType [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
            local effect = tech:getEffects()[1]
            if effect then
                textMap[6] = effect:getText()
            else
                textMap[6] = "暂未领悟"
            end
        else
            textMap[6] = "暂未领悟"
        end
    end

    self.__ui:setPanelText(textMap)
end

Helper:classDefNodeGetInstance(TechniquePresenter)
return TechniquePresenter
0000