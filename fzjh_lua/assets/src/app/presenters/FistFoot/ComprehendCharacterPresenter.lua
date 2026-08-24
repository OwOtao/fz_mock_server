--[[
    特性领悟、替换
]]

local ComprehendCharacterPresenter = class("ComprehendCharacterPresenter", cc.Layer)

function ComprehendCharacterPresenter:create()
    local p = ComprehendCharacterPresenter:new()
    p:init()
    return p
end

function ComprehendCharacterPresenter:init()
    self.__ui = require("app.views.ui.FistFootUI.ComprehendCharacterUI"):create()

    self.__ui:addTo(self)
end

function ComprehendCharacterPresenter:showLayer()
    --@RefType [src.app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique#PlayerFistFootTechnique]
    local tech = self.__role:getFistFootSystem():getTechniqueByBranchTypeFromClassMap(self.__type,self.__techniqueId)
    --@RefType [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
    self.__effect = tech:getEffects()[1]
    --@RefType [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
    self.__unUseEffect = tech:getUnusedEffects()[1]

    
    
    self:initUI()
    
    self:setText1()
    
    self:setText2()
    
    self:setCharacterInfoButton()
    
    self.__ui:show()
end

function ComprehendCharacterPresenter:refreshLayer()
    --@RefType [src.app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique#PlayerFistFootTechnique]
    local tech = self.__role:getFistFootSystem():getTechniqueByBranchTypeFromClassMap(self.__type,self.__techniqueId)
    --@RefType [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
    self.__effect = tech:getEffects()[1]
    --@RefType [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
    self.__unUseEffect = tech:getUnusedEffects()[1]
    
    self:initUI()

    self:setText2()
end

function ComprehendCharacterPresenter:setRole(role)
    self.__role = role
end

function ComprehendCharacterPresenter:setType(type)
    self.__type = type
end

function ComprehendCharacterPresenter:setTechniqueId(techniqueId)
    self.__techniqueId = techniqueId
end

function ComprehendCharacterPresenter:setCharacterLv(lv)
    self.__lv = lv
end

function ComprehendCharacterPresenter:setOpicount(opicount)
    self.__opicount = opicount
end

function ComprehendCharacterPresenter:setCallback(callback)
    self.__callback = callback
end

function ComprehendCharacterPresenter:initUI()
    if self.__effect then

        local retData = {}
        
        retData.name = self.__effect:getName()
        
        retData.level = self.__effect:getLevel()
        
        retData.desc = self.__effect:getText()

        self.__ui:setPanel1(true,retData)

        self.__ui:setNotCharacterVisible(false)
    else
        self.__ui:setPanel1(false)

        self.__ui:setNotCharacterVisible(true)
    end

    if self.__unUseEffect then

        local retData = {}
        
        retData.name = self.__unUseEffect:getName()
        
        retData.level = self.__unUseEffect:getLevel()
        
        retData.desc = self.__unUseEffect:getText()

        self.__ui:setPanel2(true,retData)

        self.__ui:setButton1("确认更换",function()
            self.__role:getFistFootSystem():replaceCharacter(
                self.__type,
                self.__techniqueId,
                function(isOk,msg,data)
                    if isOk then
                        self:refreshLayer()

                        if self.__callback then
                            self.__callback()
                        end
                        
                        PopText("更换成功")
                    else
                        PopText(msg)
                    end
                end
            )
        end)

        self.__ui:setButton2(nil,EMPTY_FUNC)

        self.__ui:setButton3("再次领悟",function()
            self.__role:getFistFootSystem():extractCharacter(
                self.__type,
                self.__techniqueId,
                false,
                function(isOk,msg,data)
                    if isOk then
                        self:refreshLayer()

                        if self.__callback then
                            self.__callback()
                        end

                        PopText("领悟成功")
                    else
                        PopText(msg)
                    end
                end
            )
        end)
        
    else
        self.__ui:setPanel2(false)

        self.__ui:setButton1(nil,EMPTY_FUNC)

        local isFirst = true

        if self.__effect then
            isFirst = false
        end

        self.__ui:setButton2("领悟特性",function()
            self.__role:getFistFootSystem():extractCharacter(
                self.__type,
                self.__techniqueId,
                isFirst,
                function(isOk,msg,data)
                    if isOk then
                        self:refreshLayer()

                        if self.__callback then
                            self.__callback()
                        end

                        PopText("领悟成功")
                    else
                        PopText(msg)
                    end
                end
            )
        end)

        self.__ui:setButton3(nil,EMPTY_FUNC)
    end
end

function ComprehendCharacterPresenter:setText1()
    local attrName = User:getRole():getCHAttrName("characterPoint")
    local text = "所需"..attrName.."："..self.__opicount
    self.__ui:setText1(text)
end

function ComprehendCharacterPresenter:setText2()
    local attrName = User:getRole():getCHAttrName("characterPoint")
    local text = "当前"..attrName.."："..self.__role:getFistFootSystem():getCharacterPoint()
    self.__ui:setText2(text)
end

function ComprehendCharacterPresenter:setCharacterInfoButton()
    --@RefType [src.app.models.FistFootSystem.FistFootTechniques.BasicFistFootTechnique#BasicFistFootTechnique]
    local basicTechnique = self.__role:getFistFootSystem():getBasicFistFootTechnique(self.__techniqueId,self.__lv)
    local poolId = basicTechnique:getPapool()

    local titleLayer = MainControllLayer:getLayer("TitleLayer")
    titleLayer:setCustomButton("特性详细",function()
        self.__role:getFistFootSystem():getCharacterPoolInfo(
            poolId,
            function(isOk,msg,data)
                if isOk then
                    MainControllLayer:pushLayer("CharacterInfoPresenter")
                    local characterInfoPresenter = MainControllLayer:getLayer("CharacterInfoPresenter")
                    characterInfoPresenter:setRole(self.__role)
                    characterInfoPresenter:setCharacterList(data.characterList)
                    characterInfoPresenter:setCharacterLv(self.__lv)
                    characterInfoPresenter:showLayer()
                else
                    PopText(msg)
                end
            end
        )
    end)
end


Helper:classDefNodeGetInstance(ComprehendCharacterPresenter)
return ComprehendCharacterPresenter
0000000000