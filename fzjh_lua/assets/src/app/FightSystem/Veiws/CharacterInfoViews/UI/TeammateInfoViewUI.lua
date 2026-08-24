--[[
    author:Seven
    time:2023-10-19 15:59:40
    desc:
]]
local BaseViewUI = require("app.FightSystem.Veiws.ViewCommon.BaseViewUI")

local NodeActionManager = require("app.extends.NodeAction.NodeActionManager")

local IInfoPanelViewUI = require("app.FightSystem.Veiws.CharacterInfoViews.UI.IInfoPanelViewUI")

local NodeActions = require("app.extends.NodeAction.Actions")

local ViewUIClickRegister = require("app.FightSystem.Veiws.ViewCommon.ViewUIClickRegister")

local FightCommons = require("app.FightSystem.FightCommons")

local NewClass = require("third.class.NewClass")
--@SuperType [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
local TeammateInfoViewUI = {}

function TeammateInfoViewUI:onInit()
    self:setVisible(false)
    self.ActiveName:setVisible(false)

    --@RefType [NodeActionManager]
    self.__textNodeActionManager = NodeActionManager:create()

    self.__activePosX = self.ActiveName:getPositionX()

    self.__activeStartPosY = 72

    self.__operationNameNodes = {}

    self.AllBuffPanel:setVisible(false)

    --@RefType [src.app.FightSystem.Veiws.ViewCommon.ViewUIClickRegister#ViewUIClickRegister]
    self.__viewUIPressRegister = ViewUIClickRegister:createWithMoveChildren(self.__node)
end

function TeammateInfoViewUI:onDestroy()
end

function TeammateInfoViewUI:onUpdate(ft)
    self.__textNodeActionManager:update(ft)
    self.__viewUIPressRegister:update(ft)
end

function TeammateInfoViewUI:setVisible(bool)
    self:getNode():setVisible(bool)
end

function TeammateInfoViewUI:addBuffIcon(iconUi, index)
    iconUi:setName("BuffIcon" .. index)
    self.BuffPanel:addChild(iconUi)
end

function TeammateInfoViewUI:addBuffBigIcon(iconUi, index)
    iconUi:setName("BigBuffIcon" .. index)
    self.AllBuffPanel:addChild(iconUi)
end

function TeammateInfoViewUI:setRoleQiProgress(value)
    self.QiBar:setPercent(value)
end

function TeammateInfoViewUI:setRoleQiMaxProgress(value)
    self.QiMaxBar:setPercent(value)
end

function TeammateInfoViewUI:setTiliMaxProgress(percent)
    self.TiliMaxBar:setPercent(percent)
end

function TeammateInfoViewUI:setTiliProgress(percent)
    self.TiliBar:setPercent(percent)
end

function TeammateInfoViewUI:setRoleName(name)
    self.Name:setString(name)
end

function TeammateInfoViewUI:showOperationName(name)
    while self.__textNodeActionManager:getActionCount() > 0 do
        self.__textNodeActionManager:update(0.1)
    end

    local textNode = self:__cloneActiveName()

    local nodeCount = #self.__operationNameNodes

    local posY = self.__activeStartPosY + (nodeCount * 45)

    self:getNode():addChild(textNode)

    textNode:setVisible(true)

    textNode:setString(name)

    textNode:setTextColor(cc.c4b(238, 238, 238, 255))

    textNode:setPosition(cc.p(self.__activePosX, posY))

    table.insert(self.__operationNameNodes, textNode)
end

function TeammateInfoViewUI:hideOperationName(hideAnimStyle)
    hideAnimStyle = hideAnimStyle or FightCommons.HIDE_ACTIVE_SKILL_NAME_ANIM_STYLE.FONT_GREEN

    --@desc 先执行完未结束的action
    while self.__textNodeActionManager:getActionCount() > 0 do
        self.__textNodeActionManager:update(0.1)
    end

    if #self.__operationNameNodes <= 0 then
        return
    end

    local textNode = self.__operationNameNodes[1]

    textNode:setOpacity(255)

    if hideAnimStyle == FightCommons.HIDE_ACTIVE_SKILL_NAME_ANIM_STYLE.FONT_GREEN then
        textNode:setTextColor(cc.c4b(0, 215, 69, 255))
    elseif hideAnimStyle == FightCommons.HIDE_ACTIVE_SKILL_NAME_ANIM_STYLE.FONT_YELLOW then
        textNode:setTextColor(cc.c4b(206, 190, 0, 255))
    end
    textNode:setTextColor(cc.c4b(254, 0, 48, 255))
    local action =
        NodeActions.Sequence:create(
        NodeActions.Spawn:create(NodeActions.Sequence:create(NodeActions.ScaleTo:create(0.1, 1.2, 1.2), NodeActions.ScaleTo:create(0.1, 1, 1)), NodeActions.DelayTime:create(0.3)),
        NodeActions.FadeOut:create(0.2),
        NodeActions.CallFunc:create(
            function()
                textNode:setVisible(false)
                textNode:removeFromParent()
                table.remove(self.__operationNameNodes, 1)
                self:__moveNextOperationName()
            end
        )
    )

    self.__textNodeActionManager:runAction(textNode, action)
end

function TeammateInfoViewUI:removeAllOperationName()
    while self.__textNodeActionManager:getActionCount() > 0 do
        self.__textNodeActionManager:update(9999)
    end

    if table.getn(self.__operationNameNodes) > 0 then
        for i = table.getn(self.__operationNameNodes), 1, -1 do
            local node = self.__operationNameNodes[i]
            node:removeFromParent()
            table.remove(self.__operationNameNodes, i)
        end
    end
end

function TeammateInfoViewUI:setRoleQiAndQiMaxValue(qiValue, qiMaxValue)
end

function TeammateInfoViewUI:setRoleNeiLiProgress(value)
end

function TeammateInfoViewUI:setRoleNeiLiMaxProgress(value)
end

function TeammateInfoViewUI:setRoleNeiLiAndNeiLiMaxValue(neiLiValue, neiLiMaxValue)
end

function TeammateInfoViewUI:showNeiliCost(value)
end

function TeammateInfoViewUI:__cloneActiveName()
    local activeNameNode = self.ActiveName:clone()

    return activeNameNode
end

function TeammateInfoViewUI:__moveNextOperationName()
    if #self.__operationNameNodes <= 0 then
        return
    end

    for i = 1, #self.__operationNameNodes do
        local textNode = self.__operationNameNodes[i]

        local posY = self.__activeStartPosY + (i - 1) * 49

        local action = NodeActions.MoveTo:create(0.1, self.__activePosX, posY)

        self.__textNodeActionManager:runAction(textNode, action)
    end
end

function TeammateInfoViewUI:registerClickFunc(beganFunc, releaseFunc, canceledFunc, pressingUpdateFunc)
    self.__viewUIPressRegister:registerClickFunc(beganFunc, releaseFunc, canceledFunc, pressingUpdateFunc)
end

function TeammateInfoViewUI:showAllBuffPanel()
    self.AllBuffPanel:setVisible(true)
end

function TeammateInfoViewUI:hideAllBuffPanel()
    self.AllBuffPanel:setVisible(false)
end

function TeammateInfoViewUI:getBigIconNode(index)
    local iconNode = self.BuffPanel:getChildByName("BuffIcon" .. index)
    return iconNode
end

function TeammateInfoViewUI:getIconNode(index)
    local iconNode = self.AllBuffPanel:getChildByName("BigBuffIcon" .. index)
    return iconNode
end

return NewClass("TeammateInfoViewUI", {BaseViewUI, IInfoPanelViewUI}, TeammateInfoViewUI)
00