local ItemIconDescInfoPresenter = class("ItemIconDescInfoPresenter", cc.Layer)

function ItemIconDescInfoPresenter:create()
    local p = ItemIconDescInfoPresenter:new()
    p:init()
    return p
end

function ItemIconDescInfoPresenter:init()
    self._ui = require("app.views.ui.ItemDescInfoUI.ItemIconShowUI"):create()

    self._ui:addTo(self)
end

function ItemIconDescInfoPresenter:setData(data)
    self._data = data
end

function ItemIconDescInfoPresenter:showLayer(list)
    self._ui:clearPage()
    self:initUI(list)
end

function ItemIconDescInfoPresenter:setTitle(title)
    self._ui:setTextName(title)
end

function ItemIconDescInfoPresenter:initUI(list)
    local role = User:getRole()
    local pageInfo = list
    
    local maxPage = #pageInfo

    if maxPage > 1 then
        self._ui:setButtonLeftVisible(true)
        self._ui:setButtonRightVisible(true)
    else
        self._ui:setButtonLeftVisible(false)
        self._ui:setButtonRightVisible(false)
    end
    
    for i, v in ipairs(pageInfo) do
        local panel = self._ui:clonePageNode()
        self._ui:initPageNode(panel, v)
        self._ui:addPage(panel)
    end

    self._ui:scrollToPage(0)
    self._pageIndex = 0

    self._ui:setButtonLeftFunc(function()
        if self._pageIndex  >= 1 then
            self._ui:scrollToPage(self._pageIndex - 1)
            self._pageIndex = self._pageIndex - 1
        end
    end)

    self._ui:setButtonRightFunc(function()
        if self._pageIndex < maxPage - 1 then
            self._ui:scrollToPage(self._pageIndex + 1)
            self._pageIndex = self._pageIndex + 1
        end
    end)

    self._ui:setButtonBackFunc(function()
        self:hideLayer()
    end)

    self._ui:show()
end

function ItemIconDescInfoPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ItemIconDescInfoPresenter",
        function(layer)
            self._ui:hide()
        end
    )
end

Helper:classDefNodeGetInstance(ItemIconDescInfoPresenter)

return ItemIconDescInfoPresenter
000000000000