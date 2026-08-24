local TeacherBuildItemPresenter = class("TeacherBuildItemPresenter", cc.Layer)

function TeacherBuildItemPresenter:create()
    local p = TeacherBuildItemPresenter:new()
    p:init()
    return p
end

function TeacherBuildItemPresenter:init()
    self.__ui = require("app.views.ui.TeacherBuildUI.TeacherBuildItemUI"):create()

    self.__ui:addTo(self)
end

function TeacherBuildItemPresenter:setRole(role)
    self.__role = role
end

function TeacherBuildItemPresenter:showLayer()
    self:showPanelItem()

    self:setPanelBack()

    self.__ui:show()
end

function TeacherBuildItemPresenter:setItemData(itemData)
    self.__itemData = itemData
end

function TeacherBuildItemPresenter:showPanelItem()
    local retArray = {}

    if MapIsEmpty(self.__itemData) == false then
        for i,v in ipairs (self.__itemData) do
            local retTab = {
                name = self.__role:getTeacherBuildSystem():getBuildItemName(v.itemId),
                num = v.count.."/"..v.countLimit
            }

            table.insert(retArray,retTab)
        end

        self.__ui:setPanelItemList(retArray)

        self.__ui:setNotItemText(false)
    else
        self.__ui:setNotItemText(true)
    end

end

function TeacherBuildItemPresenter:setPanelBack()
    self.__ui:setPanelBack(
        function()
            self:hideLayer()
        end
    )
end

function TeacherBuildItemPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "TeacherBuildItemPresenter",
        function(layer)
            self.__ui:hide()
        end
    )
end

Helper:classDefNodeGetInstance(TeacherBuildItemPresenter)
return TeacherBuildItemPresenter
00000000000000