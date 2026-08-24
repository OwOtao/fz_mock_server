--[[
    author:Seven
    time:2024-01-05 17:00:34
    desc: 先天属性方案调整视图
]]
local newClass = require("third.class.NewClass")

local NaturalAttrAdjustmentPlanUI = {}

function NaturalAttrAdjustmentPlanUI:create()
    return NaturalAttrAdjustmentPlanUI:new():__init()
end

function NaturalAttrAdjustmentPlanUI:__init()
    self.__ui = require("Layer/AttrUI/NaturalAttrAdjustmentPlanUI").create()["root"]
    Helper:convertUIParent(self.__ui) -- 获得所有子节点
    self.__ui.Btn_Select:setVisible(false)
    self.__ui.Panel_Attr:setVisible(false)
    self.__ui.Panel_Container.ListView_Attr:setTouchEnabled(false)
    self.__ui.Panel_Container.ListView_SelectBtn:setTouchEnabled(false)
    return self
end

function NaturalAttrAdjustmentPlanUI:getUINode()
    return self.__ui
end

function NaturalAttrAdjustmentPlanUI:show()
    self.__ui:setVisible(true)
end

function NaturalAttrAdjustmentPlanUI:hide()
    self.__ui:setVisible(false)
end

function NaturalAttrAdjustmentPlanUI:getSelectBtnUINode()
    local ui = self.__ui.Btn_Select:clone()
    ui:setVisible(true)
    Helper:convertUIByParent(ui)
    return ui
end

function NaturalAttrAdjustmentPlanUI:getPanelAttrUINode()
    local ui = self.__ui.Panel_Attr:clone()
    ui:setVisible(true)
    Helper:convertUIByParent(ui)
    return ui
end

function NaturalAttrAdjustmentPlanUI:addBtnSelectNodeToSelectList(btnNode)
    self.__ui.Panel_Container.ListView_SelectBtn:pushBackCustomItem(btnNode)
end

function NaturalAttrAdjustmentPlanUI:removeAllBtnSelectNodeFromSelectList()
    self.__ui.Panel_Container.ListView_SelectBtn:removeAllItems()
end

function NaturalAttrAdjustmentPlanUI:setSelectBtnNodeName(index, name)
    local btnNode = self.__ui.Panel_Container.ListView_SelectBtn:getItem(index - 1)
    btnNode.Btn_Text:setString(name)
    btnNode.Txt_Bg:setSize({width = btnNode.Btn_Text:getSize().width + 50, height = btnNode.Txt_Bg:getSize().height})
end

function NaturalAttrAdjustmentPlanUI:setSelectBtnNodeStatus(index, bool)
    local btnNode = self.__ui.Panel_Container.ListView_SelectBtn:getItem(index - 1)
    btnNode.Txt_Bg:setVisible(bool)
end

function NaturalAttrAdjustmentPlanUI:addPanelAttrNodeToAttrList(panelNode)
    self.__ui.Panel_Container.ListView_Attr:pushBackCustomItem(panelNode)
end

function NaturalAttrAdjustmentPlanUI:registerLeftBtnFunc(name, func)
    self.__ui.Panel_Container.Btn_Left.Txt_BtnName:setString(name)
    self.__ui.Panel_Container.Btn_Left:releaseFunc(
        function()
            Helper:getDef(func, EMPTY_FUNC)()
        end
    )
end

function NaturalAttrAdjustmentPlanUI:registerRightBtnFunc(name, func)
    self.__ui.Panel_Container.Btn_Right.Txt_BtnName:setString(name)
    self.__ui.Panel_Container.Btn_Right:releaseFunc(
        function()
            Helper:getDef(func, EMPTY_FUNC)()
        end
    )
end

function NaturalAttrAdjustmentPlanUI:registerPanelBackClickFunc(func)
    self.__ui.Panel_back:releaseFunc(
        function()
            Helper:getDef(func, EMPTY_FUNC)()
        end
    )
end

function NaturalAttrAdjustmentPlanUI:setTextAssignablePoints(str)
    self.__ui.Panel_Container.Txt_AssignablePoints:setString(str)
end

return newClass("NaturalAttrAdjustmentPlanUI", {}, NaturalAttrAdjustmentPlanUI)
000000000000