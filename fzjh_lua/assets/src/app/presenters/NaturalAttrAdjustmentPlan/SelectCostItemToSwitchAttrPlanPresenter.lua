--[[
    author:Seven
    time:2024-01-09 14:28:58
    desc: 下拉选择列表全屏弹窗
]]
local SelectOneItemOnListUI = require("app.views.ui.Dialog.SelectOneItemOnListUI")
local SelectCostItemToSwitchAttrPlanPresenter = class("SelectCostItemToSwitchAttrPlanPresenter", LayerEx)

function SelectCostItemToSwitchAttrPlanPresenter:create()
    return SelectCostItemToSwitchAttrPlanPresenter:new():__init()
end

function SelectCostItemToSwitchAttrPlanPresenter:__init()
    --@RefType [src.app.views.ui.Dialog.SelectOneItemOnListUI#SelectOneItemOnListUI]
    self.__ui = SelectOneItemOnListUI:create()

    self.__ui:getUINode():addTo(self)

    self:setVisible(false)

    self.__selecedIndex = 0

    self.__ui:setTitleName("需要消耗如下哪种材料切换对应属性")

    self.__ui:registerPanelBackClick(
        function()
            self:hideLayer()
        end
    )

    return self
end

--@desc:
--@author:Seven
--@time:2024-01-09 14:40:32
--@adjustmentPlan: [src.app.models.role.attr.NaturalAttributePlan.INaturalAttrAdjustmentPlan#INaturalAttrAdjustmentPlan]
function SelectCostItemToSwitchAttrPlanPresenter:showLayer(adjustmentPlan, role)
    self.__adjustmentPlan = adjustmentPlan
    self.__selecedIndex = 1

    self:__initItemList()

    self:__initSelectableList()

    self:__showSelectedItem()

    self:show()
end

function SelectCostItemToSwitchAttrPlanPresenter:registerBtnOneClickFunc(name, func)
    self.__ui:registerBtnOneClickFunc(
        name,
        function()
            func(self.__selecedIndex)
        end
    )
end

function SelectCostItemToSwitchAttrPlanPresenter:registerBtnTwoClickFunc(name, func)
    self.__ui:registerBtnTwoClickFunc(
        name,
        function()
            func(self.__selecedIndex)
        end
    )
end

function SelectCostItemToSwitchAttrPlanPresenter:__initItemList()
    self.__itemList = {}

    for i, v in ipairs(self.__adjustmentPlan:getSwitchPlanCostItemList()) do
        local item = Item:getOneItemByKey(v.id)

        local showText = Helper:getNoColorStr(item:getItemAttr("name")) .. " " .. tostring(v.count) .. tostring(item:getItemAttr("unit"))

        table.insert(
            self.__itemList,
            {
                id = v.id,
                count = v.count,
                showText = showText
            }
        )
    end
end

function SelectCostItemToSwitchAttrPlanPresenter:__initSelectableList()
    self.__ui:removeAllSelectableItems()
    for i, v in ipairs(self.__itemList) do
        local selectableUINode = self.__ui:getNewItemUINode()

        self.__ui:addSelectableItemToList(selectableUINode)

        selectableUINode.Txt_ItemName:setString(v.showText)

        if i == self.__selecedIndex then
            self.__ui:selectItem(i)
        end

        selectableUINode:releaseFunc(
            function()
                self.__selecedIndex = i

                self:__showSelectedItem()

                self.__ui:hideListView()
            end
        )
    end
end

function SelectCostItemToSwitchAttrPlanPresenter:__getItemInfoByIndex(index)
    return self.__itemList[index]
end

function SelectCostItemToSwitchAttrPlanPresenter:__showSelectedItem()
    self.__ui:setSelectedItemPanelName(self:__getItemInfoByIndex(self.__selecedIndex).showText)
    self.__ui:selectItem(self.__selecedIndex)
end

function SelectCostItemToSwitchAttrPlanPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "SelectCostItemToSwitchAttrPlanPresenter",
        function(layer)
            self:hide()
        end
    )
end

Helper:classDefNodeGetInstance(SelectCostItemToSwitchAttrPlanPresenter)
return SelectCostItemToSwitchAttrPlanPresenter
000000000000