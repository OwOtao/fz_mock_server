local TeacherBuildInfoPresenter = class("TeacherBuildInfoPresenter", cc.Layer)

local TeacherBuildConst = require("app.models.TeacherBuildSystem.TeacherBuildConst")

local TeacherBuildResManager = require("app.models.TeacherBuildSystem.TeacherBuildResManager")

function TeacherBuildInfoPresenter:create()
    local p = TeacherBuildInfoPresenter:new()
    p:init()
    return p
end

function TeacherBuildInfoPresenter:init()
    self.__ui = require("app.views.ui.TeacherBuildUI.TeacherBuildInfoUI"):create()

    self.__ui:addTo(self)
end

function TeacherBuildInfoPresenter:showLayer()
    self.__ui:show()
end

function TeacherBuildInfoPresenter:onEnable()
    self:refreshLayer()
end


function TeacherBuildInfoPresenter:refreshLayer()
    self:setBuildData()

    self:setTitleName()

    self:setTextLv()

    self:setExp()

    self:setTextDesc()

    self:setTextEffect1()

    self:setTextEffect2()

    self:setTextOpenLv()

    self:setTextOpenCon()

    self:setEffectButton()

    self:setButtonBuild()

    self:setButtonDonate()

    self:setButtonUpgrade()
end

function TeacherBuildInfoPresenter:setRole(role)
    self.__role = role
end

function TeacherBuildInfoPresenter:setBuildData()
    self.__selectIndex = self.__role:getTeacherBuildSystem():getSelectIndex()

    local buildList = self.__role:getTeacherBuildSystem():getBuildList()

    self.__buildData = buildList[self.__selectIndex]

    self.__build = self.__role:getTeacherBuildSystem():getBuildByExp(self.__buildData.buildTypeId,self.__buildData.buildTeacherExp)
end

function TeacherBuildInfoPresenter:setTitleName()
    local TitleLayer = MainControllLayer:getLayer("TitleLayer")
    TitleLayer:setTextTitle(self.__build:getName())
end

function TeacherBuildInfoPresenter:setTextLv()
    self.__ui:setTextLv("建筑等级: "..self.__build:getLv())
end

function TeacherBuildInfoPresenter:setExp()
    local exp = self.__buildData.buildTeacherExp
    
    local currMax = self.__role:getTeacherBuildSystem():getBuildUpgradeNeedExp(self.__buildData.buildTypeId,exp)

    self.__ui:setTextExp(exp.."/"..currMax)

    local percet = exp/currMax
    
    self.__ui:setPercent(percet*100)
end

function TeacherBuildInfoPresenter:setTextDesc()
	self.__ui:setTextDesc(self.__build:getDesc())
end

function TeacherBuildInfoPresenter:setTextEffect1()
    self.__ui:setTextSupTitle1("当前建筑等级用途")

	self.__ui:setTextEffectDsc1(self.__build:getEffectText())

    self.__ui:setTextSupTitleCon1("名位升级条件")

    self.__ui:setTextCondition1(self.__build:getConditiontext()[1] or "")

    self.__ui:setTextCondition2(self.__build:getConditiontext()[2] or "")
end

function TeacherBuildInfoPresenter:setTextEffect2()
    if self.__role:getTeacherBuildSystem():isMaxBuildLevel(self.__buildData.buildTypeId,self.__buildData.buildTeacherExp) then
        self.__ui:setTextSupTitle2("下一级用途")

        self.__ui:setTextEffectDsc2("已达到最大等级")

        self.__ui:setTextSupTitleCon2("名位升级条件")

        self.__ui:setTextCondition3(self.__build:getConditiontext()[1] or "")

        self.__ui:setTextCondition4(self.__build:getConditiontext()[2] or "")
    else
        local nextLv = self.__build:getLv() + 1

        local buildType = self.__build:getTypeId()

        local buildMap = TeacherBuildResManager:getBuildMap()

        local nextBuil

        for k,v in pairs(buildMap) do
            if v.buildingid == buildType and v.buildlv == nextLv then
                nextBuil = self.__role:getTeacherBuildSystem():getBuildById(v.buildid)
                break
            end
        end

        self.__ui:setTextSupTitle2("下一级用途")
    
        self.__ui:setTextEffectDsc2(nextBuil:getEffectText())

        self.__ui:setTextSupTitleCon2("名位升级条件")

        self.__ui:setTextCondition3(nextBuil:getConditiontext()[1] or "")

        self.__ui:setTextCondition4(nextBuil:getConditiontext()[2] or "")
    end
end

function TeacherBuildInfoPresenter:setTextOpenLv()
    self.__ui:setTextOpenLv("当前名位等级："..self.__buildData.buildLv)
end

function TeacherBuildInfoPresenter:setTextOpenCon()
    local currLv = self.__buildData.buildLv

    local buildType = self.__build:getTypeId()

    local buildMap = TeacherBuildResManager:getBuildMap()

    local effectDesc = ""

    for k,v in pairs(buildMap) do
        if v.buildingid == buildType and v.buildlv == currLv then
            effectDesc = self.__role:getTeacherBuildSystem():getBuildById(v.buildid):getOpenLvDesc()
            break
        end
    end

    self.__ui:setTextOpenCon(effectDesc)
end

function TeacherBuildInfoPresenter:setEffectButton()
    local effectList =  self.__build:getEffectList()
    
    local effect1 = effectList[1] 

    if effect1 and effect1:getSbutton() == TeacherBuildConst.BuildEffectButtonType.Have then
        self.__ui:setButtonEffect1(true,effect1:getButtontext(),function()
            self:executeEffect(effect1)
        end)
    else
        self.__ui:setButtonEffect1(false)
    end

    local effect2 = effectList[2] 

    if effect2 and effect2:getSbutton() == TeacherBuildConst.BuildEffectButtonType.Have then
        self.__ui:setButtonEffect2(true,effect2:getButtontext(),function()
            self:executeEffect(effect2)
        end)
    else
        self.__ui:setButtonEffect2(false)
    end

    local effect3 = effectList[3] 

    if effect3 and effect3:getSbutton() == TeacherBuildConst.BuildEffectButtonType.Have then
        self.__ui:setButtonEffect3(true,effect3:getButtontext(),function()
            self:executeEffect(effect3)
        end)
    else
        self.__ui:setButtonEffect3(false)
    end

end

function TeacherBuildInfoPresenter:setButtonBuild()
    if self.__buildData.state == TeacherBuildConst.BuildStateType.BuildIng then
        self.__ui:setButtonBuildTexture("Image/BaseUI/btn-grey-border.png")
        self.__ui:setButtonBuildScale9({x = 11, y = 10, width = 14, height = 11})
        self.__ui:setButtonBuildName("兴建中",{r = 0, g = 0, b = 0})
        self.__ui:setButtonBuild(function()
            PopText("目前正在兴建此建筑")
        end)
    else
        self.__ui:setButtonBuildTexture("Image/UI/ExamUI/siweikuang.png")
        self.__ui:setButtonBuildScale9{x = 270, y = 80, width = 359, height = 103}
        self.__ui:setButtonBuildName("兴建",{r = 255, g = 255, b = 255})
        self.__ui:setButtonBuild(function()
            self.__role:getTeacherBuildSystem():buildTeacherBuild(
                self.__buildData.buildTypeId,
                function(isOk,msg)
                    if isOk then
                        self.__buildData.state = TeacherBuildConst.BuildStateType.BuildIng

                        self:setButtonBuild()
                    else
                        PopText(msg)
                    end
                end
            )
        end)
    end
end

function TeacherBuildInfoPresenter:setButtonDonate()
    self.__ui:setButtonDonate("捐献",function()
        self.__role:getTeacherBuildSystem():getTeacherBuildDonateInfo(
            self.__buildData.buildTypeId,
            function(isOk,msg,data)
                if isOk then
                    MainControllLayer:pushLayer("TeacherBuildDonatePresenter")
                    local teacherBuildDonatePresenter = MainControllLayer:getLayer("TeacherBuildDonatePresenter")
                    teacherBuildDonatePresenter:setRole(self.__role)
                    teacherBuildDonatePresenter:initDonateData(self.__buildData.buildTypeId,data)
                    teacherBuildDonatePresenter:showLayer()
                else
                    PopText(msg)
                end
            end
        )
    end)
end

function TeacherBuildInfoPresenter:setButtonUpgrade()
    self.__ui:setButtonUpgrade("名位",function()
        if self.__buildData.buildLv >= self.__build:getLv()  then
            PopText("当前名位等级已是最高级")
            return 
        end

        PopupLayerController:showLayer(
                "TeacherBuildUpgradePresenter",
                function(layer)
                    layer:setRole(self.__role)
                    layer:setBuildData(self.__buildData)
                    layer:setCallback(
                        function()
                            self:refreshLayer()
                        end
                    )
                    layer:showLayer()
                end
            )
    end)
end

function TeacherBuildInfoPresenter:executeEffect(effect)
    if effect:getEffectType() == TeacherBuildConst.BuildEffectType.Transfer then
        local buildOpenLv = self.__buildData.buildLv
        if buildOpenLv < 1 then
            PopText("名位等级不足，不能使用")
            return
        end

       self:__departFamily()
    elseif effect:getEffectType() == TeacherBuildConst.BuildEffectType.ReputationStore then
        self:__store()
    elseif effect:getEffectType() == TeacherBuildConst.BuildEffectType.DonateShop then
        self:__donateShop()
    elseif effect:getEffectType() == TeacherBuildConst.BuildEffectType.Promote then
        self:__promote()
    elseif effect:getEffectType() == TeacherBuildConst.BuildEffectType.SupportShop then
        self:__supportShop()
    else
        error("未定义的建筑功能效果类型"..effect:getEffectType())
    end
end

function TeacherBuildInfoPresenter:__departFamily()
    local DepartFromFamilyPresenter = require("app.presenters.DepartFromFamily.DepartFromFamilyPresenter")
    local departFromFamilyPresenter = DepartFromFamilyPresenter:create()
    departFromFamilyPresenter:setRole(User:getRole())
    departFromFamilyPresenter:init()
    departFromFamilyPresenter:showLeaveUI()
end

function TeacherBuildInfoPresenter:__store()
    PopupLayerController:showLayer("ReputationStorePresenter",function(layer)
        layer:setTitleName(self.__build:getName())
        layer:showLayer()
    end)
end

function TeacherBuildInfoPresenter:__donateShop()
    PopupLayerController:showLayer("FamilyExchangeStorePresenter",function(layer)
        layer:setTitleName(self.__build:getName())
        layer:showLayer()
    end)
end

function TeacherBuildInfoPresenter:__promote()
    PopupLayerController:showLayer("TeacherBuildPromotePresenter",function(layer)
        layer:setTitleName(self.__build:getName())
        layer:showLayer()
    end)
end

function TeacherBuildInfoPresenter:__supportShop()
    PopupLayerController:showLayer("TeacherBuildResExchangeStorePresenter",function(layer)
        layer:setTitleName(self.__build:getName())
        layer:showLayer()
    end)
end

Helper:classDefNodeGetInstance(TeacherBuildInfoPresenter)
return TeacherBuildInfoPresenter
000