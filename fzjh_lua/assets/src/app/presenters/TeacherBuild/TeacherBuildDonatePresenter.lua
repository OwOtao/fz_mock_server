local TeacherBuildDonatePresenter = class("TeacherBuildDonatePresenter", cc.Layer)

local TeacherBuildDonate = require("app.models.TeacherBuildSystem.Donate.TeacherBuildDonate")

function TeacherBuildDonatePresenter:create()
    local p = TeacherBuildDonatePresenter:new()
    p:init()
    return p
end

function TeacherBuildDonatePresenter:init()
    self.__ui = require("app.views.ui.TeacherBuildUI.TeacherBuildDonateUI"):create()

    self.__ui:addTo(self)
end

function TeacherBuildDonatePresenter:showLayer()
    self:setTextLv()

    self:setExp()

    self:setTextDonateNum()

    self:setListViewDonateList()

    self:setButtonItems()

    self.__ui:show()
end

function TeacherBuildDonatePresenter:refreshLayer()
    self:setTextLv()

    self:setExp()

    self:setTextDonateNum()

    self:setListViewDonateList()

    self:setButtonItems()
end

function TeacherBuildDonatePresenter:setRole(role)
    self.__role = role
end

function TeacherBuildDonatePresenter:initDonateData(buildTypeId,donateData)
    self.__buildTeacherExp = donateData.buildTeacherExp

    self.__donateNum = donateData.donateNum

    self.__donateMax = donateData.donateMax

    self.__donateList = donateData.donateList

    self.__build = self.__role:getTeacherBuildSystem():getBuildByExp(buildTypeId,self.__buildTeacherExp)
end

function TeacherBuildDonatePresenter:setTextLv()
    self.__ui:setTextLv("建筑等级: "..self.__build:getLv())
end

function TeacherBuildDonatePresenter:setExp()
    local exp = self.__buildTeacherExp
    
    local currMax = self.__role:getTeacherBuildSystem():getBuildUpgradeNeedExp(self.__build:getTypeId(),exp)

    self.__ui:setTextExp(exp.."/"..currMax)

    local percet = exp/currMax
    
    self.__ui:setPercent(percet*100)
end

function TeacherBuildDonatePresenter:setTextDonateNum()
    self.__ui:setTextDonateNum("本日捐献次数: "..self.__donateNum.."/"..self.__donateMax)
end

function TeacherBuildDonatePresenter:setListViewDonateList()
    local donateList = self.__donateList

    local retArray = {}

    for i,donateData in ipairs(donateList) do
        local retData = {}

        local donateId = donateData.donateId

        local state = donateData.state

        local donate = TeacherBuildDonate:create(donateId)

        retData.state = state

        retData.title = donate:getTitleText()

        retData.num = donate:getDonateText()

        retData.openText = donate:getOpenText()

        retData.func = function()
            self.__role:getTeacherBuildSystem():donateTeacherBuild(
                self.__build:getTypeId(),
                donate:getId(),
                state,
                function(errcode,msg,data)
                    if errcode == 0 then
                        self.__ui:hide()
                        if data.reward.upresources > 0 then
                            PopText("获得"..data.reward.upresources.."修筑度")
                        end

                        if data.reward.addRenown > 0 then
                            PopText("获得"..data.reward.addRenown..self.__role:getTeacherBuildSystem():getRenownName())
                        end

                        if data.reward.addDonate > 0 then
                            PopText("获得"..data.reward.addDonate..self.__role:getTeacherBuildSystem():getDonateName())
                        end

                        if data.msg then
                            PopText(data.msg)
                        end

                        MainControllLayer:popLayer()
                    elseif errcode == 2 or errcode == 3 then
                        PopText(msg)

                        self.__role:getTeacherBuildSystem():getTeacherBuildDonateInfo(
                            self.__build:getTypeId(),
                            function(isOk,msg,donateData)
                                if isOk then
                                    self:initDonateData(self.__build:getTypeId(),donateData)
                                    self:refreshLayer()
                                else
                                    PopText(msg)
                                end
                            end
                        )
                    elseif errcode == 4 then
                        PopText(msg)

                        MainControllLayer:popLayer()
                    else
                        PopText(msg)
                    end
                end
            )
        end
        
        table.insert(retArray,retData)
    end

    self.__ui:setListViewDonateList(retArray)
end

function TeacherBuildDonatePresenter:setButtonItems()
    self.__ui:setButtonItems(
        function()
            self.__role:getTeacherBuildSystem():getTeacherBuildItems(
                function(isOk,msg,data)
                    if isOk then
                        self:showPanelItem(data)
                    else
                        PopText(msg)
                    end
                end
            )
        end
    )
end

function TeacherBuildDonatePresenter:showPanelItem(itemData)
    PopupLayerController:showLayer(
        "TeacherBuildItemPresenter",
        function(layer)
            layer:setRole(self.__role)
            layer:setItemData(itemData)
            layer:showLayer()
        end
    )
end

Helper:classDefNodeGetInstance(TeacherBuildDonatePresenter)
return TeacherBuildDonatePresenter
00000000