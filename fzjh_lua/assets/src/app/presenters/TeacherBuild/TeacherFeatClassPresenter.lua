local TeacherFeatClassPresenter = class("TeacherFeatClassPresenter", cc.Layer)

function TeacherFeatClassPresenter:create()
    local p = TeacherFeatClassPresenter:new()
    p:init()
    return p
end

function TeacherFeatClassPresenter:init()
    self.__ui = require("app.views.ui.TeacherBuildUI.TeacherFeatClassUI"):create()

    self.__ui:addTo(self)
end

function TeacherFeatClassPresenter:showLayer()
    self:setTextFeatPoint()

    self:setTextFeatClass()

    self:showListViewFeat()

    self.__ui:show()
end

function TeacherFeatClassPresenter:setRole(role)
    self.__role = role
end

function TeacherFeatClassPresenter:showListViewFeat()
    local featList = self.__role:getTeacherBuildSystem():getFeatClassList()

    local retList = {}
    
    for i,v in ipairs(featList) do
        table.insert(retList, {name = v.text,dsc = "所需名绩点数",point = v.featscount})
    end

    self.__ui:setListViewFeat(retList)
end

function TeacherFeatClassPresenter:setTextFeatPoint()
    self.__ui:setTextFeatPoint("当前名绩点数："..self.__role:getTeacherBuildSystem():getFeatScount())
end

function TeacherFeatClassPresenter:setTextFeatClass()
    self.__ui:setTextFeatClass("当前名衔"..self.__role:getTeacherBuildSystem():getFeatClassName())
end

Helper:classDefNodeGetInstance(TeacherFeatClassPresenter)
return TeacherFeatClassPresenter
0000000000000000