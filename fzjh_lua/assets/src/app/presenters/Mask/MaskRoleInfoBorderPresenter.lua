local MaskRoleInfoBorderPresenter = class("MaskRoleInfoBorderPresenter", cc.Layer)

function MaskRoleInfoBorderPresenter:create()
    local p = MaskRoleInfoBorderPresenter.new()
    p:__init()
    return p
end

function MaskRoleInfoBorderPresenter:__init()
    self.__ui = require("app.views.ui.MaskUI.MaskRoleInfoBorderUI"):create()

    self.__ui:addTo(self)

    self.__ui:setPanelBack(
        function()
            self:hideLayer()
        end
    )
end

function MaskRoleInfoBorderPresenter:showLayer(infoFramePath)
    self.__ui:setTextTitle("个人信息框")

    self.__ui:setImageBack(infoFramePath)

    self.__ui:showUI()
end

function MaskRoleInfoBorderPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "MaskRoleInfoBorderPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(MaskRoleInfoBorderPresenter)
return MaskRoleInfoBorderPresenter
000000000000000