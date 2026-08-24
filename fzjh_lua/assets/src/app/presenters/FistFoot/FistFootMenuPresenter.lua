local FistFootMenuPresenter = class("FistFootMenuPresenter", cc.Layer)

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

function FistFootMenuPresenter:create()
    local p = FistFootMenuPresenter:new()
    p:init()
    return p
end

function FistFootMenuPresenter:init()
    self.__ui = require("app.views.ui.FistFootUI.FistFootMenuUI"):create()

    self.__ui:addTo(self)
end

function FistFootMenuPresenter:showLayer()
    self.__type = 10010

    self.__ui:setLightButton("Panel_10010")

    self.__isShow = true --展示过界面

    self.__isFirstShow = true --第一次展示过界面

    self:setBranchButton()

    self:setButtonGuaJi()

    self:setButtonTechnique()

    self:setButtonReset()
    
    self:setPanelText()

    self.__ui:show()
end

function FistFootMenuPresenter:onEnable()
    if self.__isShow == true and self.__isFirstShow == false then
        self:setPanelText()
    end
end

function FistFootMenuPresenter:onDisable()
    self.__isFirstShow = false
end

function FistFootMenuPresenter:setRole(role)
    self.__role = role
end

function FistFootMenuPresenter:setBranchButton()
    local list = {
        {
            widgetName = "Panel_10010",
            type = 10010,
        },
        {
            widgetName = "Panel_10020",
            type = 10020
        },
        {
            widgetName = "Panel_10030",
            type = 10030,
        },
        {
            widgetName = "Panel_10040",
            type = 10040,
        },
        {
            widgetName = "Panel_10050",
            type = 10050,
        },
    }
    for i ,v in ipairs(list) do
        self.__ui:setPanelButton(v.widgetName,
            function() 
                if self.__type ~= v.type then
                    self.__type = v.type
    
                    self:setPanelText()
                    self.__ui:setLightButton(v.widgetName)
                end
            end
        )
    end
end

function FistFootMenuPresenter:setButtonGuaJi()
    self.__ui:setButtonGuaJi("修行",
        function()
            if self.__role:getFistFootSystem():isGuaJi() then
                MainControllLayer:pushLayer("FistFootGuaJiPresenter")
                local fistFootGuaJiPresenter = MainControllLayer:getLayer("FistFootGuaJiPresenter")
                fistFootGuaJiPresenter:setRole(self.__role)
                fistFootGuaJiPresenter:showLayer()
            else
                self.__role:getFistFootSystem():getFistTasks(
                    function(isOk,msg,data)
                        if isOk then
                            MainControllLayer:pushLayer("FistFootTaskPresenter")
                            local fistFootTaskPresenter = MainControllLayer:getLayer("FistFootTaskPresenter")
                            fistFootTaskPresenter:setRole(self.__role)
                            fistFootTaskPresenter:setType(self.__type)
                            fistFootTaskPresenter:setTasks(data.list)
                            fistFootTaskPresenter:showLayer()
                        else
                            PopText(msg)
                        end
                    end
                )
            end
        end
    )
end

function FistFootMenuPresenter:setButtonTechnique()
    self.__ui:setButtonTechnique("技巧",
        function()
            MainControllLayer:pushLayer("TechniquePresenter")
            local techniquePresenter = MainControllLayer:getLayer("TechniquePresenter")
            techniquePresenter:setRole(self.__role)
            techniquePresenter:setType(self.__type)
            techniquePresenter:showLayer()
        end
    )
end

function FistFootMenuPresenter:setButtonReset()
    self.__ui:setButtonReset("易法",
        function()
            self.__role:getFistFootSystem():getTalentPageInfo(
                function(isOk,msg,data)
                    if isOk then
                        MainControllLayer:pushLayer("TalentPagePresenter")
                        local talentPagePresenter = MainControllLayer:getLayer("TalentPagePresenter")
                        talentPagePresenter:setRole(self.__role)
                        talentPagePresenter:setResetCount(data.resetCount)
                        talentPagePresenter:setPageIndex(data.currPageIndex)
                        talentPagePresenter:setTalentPageList(data.list)
                        talentPagePresenter:showLayer()
                    else
                        PopText(msg)
                    end
                end
            )
        end
    )
end

function FistFootMenuPresenter:setPanelText()
    local textMap = {}

    textMap.name = SkillClassifyManager:getClassifyInfo(tostring(self.__type)).thirdTypeName
    textMap.title1 = "【阅历】"
    textMap.title2 = "【锻境等级】"
    textMap.title3 = "【武练】"
    textMap.title4 = "【谙技】"
    textMap.title5 = "【技巧数量】"
    textMap.title6 = "【投入感悟点数】"

    local exp = self.__role:getFistFootSystem():getBranchExp(self.__type)
    local lv = self.__role:getFistFootSystem():getBranchLv(self.__type)
    local maxLv = self.__role:getFistFootSystem():getBranchMaxLv(self.__type)

    local value1 = ""
    if lv >= maxLv then
        value1 = "已达到最大等级"
    else
        local nextInfo = self.__role:getFistFootSystem():getBranchMap(self.__type,lv + 1)
        value1 = exp.."/"..nextInfo.exp
    end

    local techniques = self.__role:getFistFootSystem():getTechniquesByTypeFromClassMap(self.__type)
    local techniqueNum = #techniques
    local fJqdamage = 0

    for i, t in ipairs(techniques) do
        --@RefType [src.app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique#PlayerFistFootTechnique]
        local technique = t
        fJqdamage = fJqdamage + technique:getJqdamage()
    end

    textMap.value1 = value1
    textMap.value2 = lv
    textMap.value3 = self.__role:getFistFootSystem():getBranchDamage(self.__type)
    textMap.value4 = fJqdamage
    textMap.value5 = techniqueNum
    textMap.value6 = self.__role:getFistFootSystem():getBranchCostTechnique(self.__type)

    self.__ui:setPanelText(textMap)
end

Helper:classDefNodeGetInstance(FistFootMenuPresenter)
return FistFootMenuPresenter
00000