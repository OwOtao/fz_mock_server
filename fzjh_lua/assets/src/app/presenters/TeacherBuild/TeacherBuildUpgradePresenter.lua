local TeacherBuildUpgradePresenter = class("TeacherBuildUpgradePresenter", cc.Layer)

local TeacherBuildResManager = require("app.models.TeacherBuildSystem.TeacherBuildResManager")

function TeacherBuildUpgradePresenter:create()
    local p = TeacherBuildUpgradePresenter:new()
    p:init()
    return p
end

function TeacherBuildUpgradePresenter:init()
    self.__ui = require("app.views.ui.TeacherBuildUI.TeacherBuildUpgradeUI"):create()

    self.__ui:addTo(self)
end

function TeacherBuildUpgradePresenter:showLayer()
    self:setTextDesc()

    self:setTextCondition()

    self:setTexteffectDesc1()

    self:setTexteffectDesc2()

    self:setButton1()

    self:setButton2()

    self.__ui:show()
end

function TeacherBuildUpgradePresenter:setCallback(callback)
    self.__callback = callback
end

function TeacherBuildUpgradePresenter:setRole(role)
    self.__role = role
end

function TeacherBuildUpgradePresenter:setBuildData(buildData)
    self.__buildData = buildData

    local currLv = self.__buildData.buildLv

    local nextLv = currLv + 1

    local buildType = self.__buildData.buildTypeId

    local buildMap = TeacherBuildResManager:getBuildMap()

    for k,v in pairs(buildMap) do
        if v.buildingid == buildType and v.buildlv == currLv then
            self.__build = self.__role:getTeacherBuildSystem():getBuildById(v.buildid)
        end

        if v.buildingid == buildType and v.buildlv == nextLv then
            self.__nextBuild = self.__role:getTeacherBuildSystem():getBuildById(v.buildid)
        end
    end
end

function TeacherBuildUpgradePresenter:setTextDesc()
    self.__ui:setTextDesc("当前名位等级为"..self.__build:getLv().."级，是否消耗"..self.__nextBuild:getCescalation().."点"..self.__role:getTeacherBuildSystem():getRenownName().."资源升级名位等级？")
end

function TeacherBuildUpgradePresenter:setTextCondition()
    local conditiontext = ""

    local conditiontextList = self.__nextBuild:getConditiontext()

    for i,text in ipairs(conditiontextList) do
        if i == 1 then
            conditiontext = text
        else
            conditiontext = conditiontext..","..text
        end
    end
    
    self.__ui:setTextCondition(conditiontext.."。")
end

function TeacherBuildUpgradePresenter:setTexteffectDesc1()
    self.__ui:setTexteffectDesc1(self.__build:getOpenLvDesc())
end

function TeacherBuildUpgradePresenter:setTexteffectDesc2()
    self.__ui:setTexteffectDesc2(self.__nextBuild:getOpenLvDesc())
end

function TeacherBuildUpgradePresenter:setButton1()
    self.__ui:setButton1("确定",function()
        self.__role:getTeacherBuildSystem():upgradeTeacherBuild(
            self.__buildData.buildTypeId,
            function(isOk,msg,data)
                if isOk then
                    if self.__callback then
                        self.__callback()
                    end
                    
                    PopText("升级成功")
                    
                    self:hideLayer()
                else
                    PopText(msg)
                end
            end
        )
    end)
end

function TeacherBuildUpgradePresenter:setButton2()
    self.__ui:setButton2("取消",function()
        self:hideLayer()
    end)
end

function TeacherBuildUpgradePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "TeacherBuildUpgradePresenter",
        function(layer)
            self.__ui:hide()
        end
    )
end

Helper:classDefNodeGetInstance(TeacherBuildUpgradePresenter)
return TeacherBuildUpgradePresenter
00000000000