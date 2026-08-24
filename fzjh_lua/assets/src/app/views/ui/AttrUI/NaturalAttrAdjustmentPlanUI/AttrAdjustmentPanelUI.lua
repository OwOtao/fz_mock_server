--[[
    author:Seven
    time:2024-01-05 21:29:33
    desc: 属性调整UI容器UI
]]
local newClass = require("third.class.NewClass")

local ViewUIClickRegister = require("app.views.ui.CommonUITools.ViewUIClickRegister")

local AttrAdjustmentPanelUI = {}

function AttrAdjustmentPanelUI:create(uiNode)
    return AttrAdjustmentPanelUI.new():__init(uiNode)
end

function AttrAdjustmentPanelUI:__init(uiNode)
    self.__uiNode = uiNode

    Helper:convertUIParent(self.__uiNode)

    --@RefType [src.app.views.ui.CommonUITools.ViewUIClickRegister#ViewUIClickRegister]
    self.__btnAddClickRegister = ViewUIClickRegister:createWithReleaseFuncTotally(self.__uiNode.Btn_Add)
    --@RefType [src.app.views.ui.CommonUITools.ViewUIClickRegister#ViewUIClickRegister]
    self.__btnDecClickRegister = ViewUIClickRegister:createWithReleaseFuncTotally(self.__uiNode.Btn_Dec)

    return self
end

function AttrAdjustmentPanelUI:getUINode()
    return self.__uiNode
end

function AttrAdjustmentPanelUI:setAttrValue(value)
    self.__uiNode.Txt_Value:setString(tostring(value))
end

function AttrAdjustmentPanelUI:setAttrName(name)
    self.__uiNode.Txt_AttrName:setString(name)
end

function AttrAdjustmentPanelUI:setBtnAddEnable(bool)
    if bool == true then
        self.__uiNode.Btn_Add.Img_CanUse:setVisible(true)
        self.__uiNode.Btn_Add.Img_CanNotUse:setVisible(false)
    else
        self.__uiNode.Btn_Add.Img_CanUse:setVisible(false)
        self.__uiNode.Btn_Add.Img_CanNotUse:setVisible(true)
    end
end

function AttrAdjustmentPanelUI:setBtnDecEnable(bool)
    if bool == true then
        self.__uiNode.Btn_Dec.Img_CanUse:setVisible(true)
        self.__uiNode.Btn_Dec.Img_CanNotUse:setVisible(false)
    else
        self.__uiNode.Btn_Dec.Img_CanUse:setVisible(false)
        self.__uiNode.Btn_Dec.Img_CanNotUse:setVisible(true)
    end
end

function AttrAdjustmentPanelUI:registerBtnAddClickFunc(beganFunc, releaseFunc, canceledFunc, pressingUpdateFunc)
    --@desc 由于cocos点击可能不触发cancel事件，所以这里需要手动取消press状态
    if self.__btnAddClickRegister:isPress() then
        self.__btnAddClickRegister:cancelPress()
    end
    self.__btnAddClickRegister:registerClickFunc(beganFunc, releaseFunc, canceledFunc, pressingUpdateFunc)
end

function AttrAdjustmentPanelUI:registerBtnDecClickFunc(beganFunc, releaseFunc, canceledFunc, pressingUpdateFunc)
    if self.__btnDecClickRegister:isPress() then
        self.__btnDecClickRegister:cancelPress()
    end
    self.__btnDecClickRegister:registerClickFunc(beganFunc, releaseFunc, canceledFunc, pressingUpdateFunc)
end

function AttrAdjustmentPanelUI:updateUI(ft)
    self.__btnAddClickRegister:update(ft)
    self.__btnDecClickRegister:update(ft)
end

return newClass("AttrAdjustmentPanelUI", {}, AttrAdjustmentPanelUI)
00000000000000