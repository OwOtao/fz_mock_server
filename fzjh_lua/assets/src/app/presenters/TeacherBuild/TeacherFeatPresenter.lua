local TeacherFeatPresenter = class("TeacherFeatPresenter", cc.Layer)

function TeacherFeatPresenter:create()
    local p = TeacherFeatPresenter:new()
    p:init()
    return p
end

function TeacherFeatPresenter:init()
    self.__ui = require("app.views.ui.TeacherBuildUI.TeacherFeatUI"):create()

    self.__ui:addTo(self)
end

function TeacherFeatPresenter:updateLayerSkinUI(skin_config)
    self.__ui:updateSkin(skin_config)
end

function TeacherFeatPresenter:showLayer()
    self.__index = 1

    self:initFeatList()

    self:setTextFeatPoint()

    self:setTextFeatClass()

    self:showListViewFeat()

    self:setPanelLabel1()

    self:setPanelLabel2()

    local titleLayer = MainControllLayer:getLayer("TitleLayer")
    titleLayer:setSetUpButtonName("名衔")
    titleLayer:setButton_setupFunc(function()
        MainControllLayer:pushLayer("TeacherFeatClassPresenter")
        local teacherFeatClassPresenter = MainControllLayer:getLayer("TeacherFeatClassPresenter")
        teacherFeatClassPresenter:setRole(self.__role)
        teacherFeatClassPresenter:showLayer()
    end)
    
    self.__ui:show()
end

function TeacherFeatPresenter:setRole(role)
    self.__role = role
end

function TeacherFeatPresenter:initFeatList()
    local featList = self.__role:getTeacherBuildSystem():getFeatList()

    local list1 = {}

    local list2 = {}

    for i, v in ipairs(featList) do
        local id = v.id

        local feat = self.__role:getTeacherBuildSystem():getFeat(id)

        if feat:getLabel() == 1 then
            table.insert(list1, v)
        elseif feat:getLabel() == 2 then
            table.insert(list2, v)
        end
    end

    self.__featList1 = list1

    self.__featList2 = list2
end

function TeacherFeatPresenter:showListViewFeat()
    local featList = {}

    if self.__index == 1 then
        featList = self.__featList1
    elseif self.__index == 2 then
        featList = self.__featList2
    end

    table.sort(featList, function(a,b)
        if a.state == 1 and b.state ~= 1 then
            return true
        elseif a.state ~= 1 and b.state == 1 then
            return false
        elseif a.state == b.state then
            return tonumber(a.id) < tonumber(b.id)
        else
            return a.state < b.state
        end
    end)

    local retList = {}
    
    for i, v in ipairs(featList) do
        local id = v.id

        local feat = self.__role:getTeacherBuildSystem():getFeat(id)
        
        local name = feat:getTitle()

        local dsc = feat:getText()

        local awardTexts = feat:getAwardTexts()

        local state = v.state

        local stateText = ""

        local butVisible = false

        local pdVisible = false

        local func = EMPTY_FUNC

        if state == 0 then
        elseif state == 1 then
            butVisible = true

            func = function()
                self.__role:getTeacherBuildSystem():getTeacherFeatReward(id,function(isResult,msg)
                    if isResult then
                        self:setTextFeatPoint()
    
                        self:setTextFeatClass()

                        v.state =2

                        self.__ui:refreshItem(i,{stateText = "已完成",butVisible = false,pdVisible = false})

                        for i,text in ipairs(awardTexts) do
                            PopText("获得"..text)
                        end
                    else
                        PopText(msg)
                    end
                end)
            end
        elseif state == 2 then
            stateText = "已完成"

            pdVisible = true
        end

        table.insert(
            retList,
            {
                id = id,

                name = name,

                dsc = dsc,

                awardText1 = awardTexts[1] or "",

                awardText2 = awardTexts[2] or "",

                state = state,

                stateText = stateText,
                
                butVisible = butVisible,

                pdVisible = pdVisible,

                func = func
            }
        )
    end


    self.__ui:setListViewFeat(retList)
end

function TeacherFeatPresenter:setTextFeatPoint()
    self.__ui:setTextFeatPoint("当前名绩点数："..self.__role:getTeacherBuildSystem():getFeatScount())
end

function TeacherFeatPresenter:setTextFeatClass()
    self.__ui:setTextFeatClass(self.__role:getTeacherBuildSystem():getFeatClassName())
end

function TeacherFeatPresenter:setPanelLabel1()
    local name = "日积月累"

    local color = {r = 255, g = 255, b = 255}

    if self.__index ~= 1 then
        color = {r = 142, g = 142, b = 142}
    end

    self.__ui:setPanelLabel1Color(color)

    self.__ui:setPanelLabel1(
        name,
        function()
            self.__index = 1

            self.__ui:setPanelLabel1Color({r = 255, g = 255, b = 255})

            self:setPanelLabel2()

            self:showListViewFeat()
        end
    )
end

function TeacherFeatPresenter:setPanelLabel2()
    local name = "千里之任"

    local color = {r = 255, g = 255, b = 255}

    if self.__index ~= 2 then
        color = {r = 142, g = 142, b = 142}
    end

    self.__ui:setPanelLabel2Color(color)

    self.__ui:setPanelLabel2(
        name,
        function()
            self.__index = 2

            self.__ui:setPanelLabel2Color({r = 255, g = 255, b = 255})

            self:setPanelLabel1()
            
            self:showListViewFeat()
        end
    )
end

Helper:classDefNodeGetInstance(TeacherFeatPresenter)
return TeacherFeatPresenter
000000