--[[
    author:Seven
    time:2024-01-09 14:12:49
    desc: 下拉选择列表全屏弹窗
]]
local newClass = require("third.class.NewClass")

local SelectOneItemOnListUI = {}

function SelectOneItemOnListUI:create()
    return SelectOneItemOnListUI.new():__init()
end

function SelectOneItemOnListUI:__init()
    self.__ui = require("Layer.Dialog.SelectOneItemOnListUI").create()["root"]

    Helper:convertUIParent(self.__ui) -- 获得所有子节点

    self.__ui.Pnl_Item:setVisible(false)

    self.__ui.Pnl_ListView:setVisible(false)

    self.__ui.Pnl_ListSelectedItem:releaseFunc(
        function()
            if self.__ui.Pnl_ListView:isVisible() then
                self:hideListView()
            else
                self:showListView()
            end
        end
    )

    return self
end

function SelectOneItemOnListUI:getUINode()
    return self.__ui
end

function SelectOneItemOnListUI:getNewItemUINode()
    local ui = self.__ui.Pnl_Item:clone()
    ui:setVisible(true)
    Helper:convertUIParent(ui)
    ui.Img_SelectedBg:setVisible(false)
    ui.Txt_ItemName:setTextColor(cc.c3b(189, 182, 182))
    return ui
end

function SelectOneItemOnListUI:setTitleName(name)
    self.__ui.Txt_Title:setString(name)
end

function SelectOneItemOnListUI:setSelectedItemPanelName(name)
    self.__ui.Pnl_ListSelectedItem.Txt_ItemName:setString(Helper:getDef(tostring(name), ""))
end

function SelectOneItemOnListUI:addSelectableItemToList(item)
    self.__ui.Pnl_ListView.ListView_Items:pushBackCustomItem(item)
end

function SelectOneItemOnListUI:removeAllSelectableItems()
    self.__ui.Pnl_ListView.ListView_Items:removeAllItems()
end

function SelectOneItemOnListUI:selectItem(index)
    for i, v in ipairs(self.__ui.Pnl_ListView.ListView_Items:getItems()) do
        if index == i then
            v.Img_SelectedBg:setVisible(true)
            v.Txt_ItemName:setTextColor(cc.c3b(255, 255, 255))
        else
            v.Img_SelectedBg:setVisible(false)
            v.Txt_ItemName:setTextColor(cc.c3b(189, 182, 182))
        end
    end
end

function SelectOneItemOnListUI:getAllSelectableItems()
    return self.__ui.Pnl_ListView.ListView_Items:getItems()
end

function SelectOneItemOnListUI:showListView()
    self.__ui.Pnl_ListView:setVisible(true)
end

function SelectOneItemOnListUI:hideListView()
    self.__ui.Pnl_ListView:setVisible(false)
end

function SelectOneItemOnListUI:registerBtnOneClickFunc(name, func)
    self.__ui.Btn_One.Txt_Name:setString(name)
    self.__ui.Btn_One:releaseFunc(
        function()
            Helper:getDef(func, EMPTY_FUNC)()
        end
    )
end

function SelectOneItemOnListUI:registerBtnTwoClickFunc(name, func)
    self.__ui.Btn_Two.Txt_Name:setString(name)
    self.__ui.Btn_Two:releaseFunc(
        function()
            Helper:getDef(func, EMPTY_FUNC)()
        end
    )
end

function SelectOneItemOnListUI:show()
    self.__ui:setVisible(true)
end

function SelectOneItemOnListUI:hide()
    self.__ui:setVisible(false)
end

function SelectOneItemOnListUI:registerPanelBackClick(func)
    self.__ui.Panel_back:releaseFunc(
        function()
            Helper:getDef(func, EMPTY_FUNC)()
        end
    )
end

return newClass("SelectOneItemOnListUI", {}, SelectOneItemOnListUI)
0000