local TeacherBuildListPresenter = class("TeacherBuildListPresenter", cc.Layer)

local TeacherBuildConst = require("app.models.TeacherBuildSystem.TeacherBuildConst")

function TeacherBuildListPresenter:create()
    local p = TeacherBuildListPresenter:new()
    p:init()
    return p
end

function TeacherBuildListPresenter:init()
    --@RefType [TeacherBuildListUI]
    self.__ui = require("app.views.ui.TeacherBuildUI.TeacherBuildListUI"):create()

    self.__ui:addTo(self)
end

function TeacherBuildListPresenter:setRole(role)
    self.__role = role
end

function TeacherBuildListPresenter:showLayer()
    self:setButtonItems()

    self.__ui:show()
end

function TeacherBuildListPresenter:updateLayerSkinUI(skin_config)
    self.__ui:updateSkin(skin_config)
end

function TeacherBuildListPresenter:onEnable()
    self.__selectIndex = nil

    self.__buildList = self.__role:getTeacherBuildSystem():getBuildList()
   
    self:setListViewBuildList()

    self:setButtonInfo()
end

function TeacherBuildListPresenter:setListViewBuildList()
    local buildList = self.__buildList
    local retArray = {}
    table.sort(buildList, function(a,b)
        if a.state == b.state then
            return tonumber(a.buildTypeId) < tonumber(b.buildTypeId)
        else
            return a.state > b.state
        end
    end)


    for i,v in ipairs(buildList) do
        local build = self.__role:getTeacherBuildSystem():getBuildByExp(v.buildTypeId,v.buildTeacherExp)
        local retData = {}
        retData.name = build:getName()
        local currMax = self.__role:getTeacherBuildSystem():getBuildUpgradeNeedExp(v.buildTypeId,v.buildTeacherExp)
        retData.exp = "建筑进度  "..v.buildTeacherExp.."/"..currMax
        if v.state == TeacherBuildConst.BuildStateType.BuildIng then
            retData.isState = "建造中"
        else
            retData.isState = ""
        end

        retData.func = function()
            self.__selectIndex = i

            self.__role:getTeacherBuildSystem():setSelectIndex(i)

            self.__ui:setLightBuild(i)
        end
        
        table.insert(retArray,retData)
    end

    self.__ui:setListViewBuildList(retArray)
end

function TeacherBuildListPresenter:setButtonItems()
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

function TeacherBuildListPresenter:showPanelItem(itemData)
    PopupLayerController:showLayer(
        "TeacherBuildItemPresenter",
        function(layer)
            layer:setRole(self.__role)
            layer:setItemData(itemData)
            layer:showLayer()
        end
    )
end

function TeacherBuildListPresenter:setButtonInfo()
    self.__ui:setButtonInfo(
        function()
            if self.__selectIndex == nil then
                PopText("请先选择对应的师门建筑")
            else
                MainControllLayer:pushLayer("TeacherBuildInfoPresenter")
                local teacherBuildInfoPresenter = MainControllLayer:getLayer("TeacherBuildInfoPresenter")
                teacherBuildInfoPresenter:setRole(self.__role)
                teacherBuildInfoPresenter:showLayer()
            end
        end
    )
end


Helper:classDefNodeGetInstance(TeacherBuildListPresenter)
return TeacherBuildListPresenter
0