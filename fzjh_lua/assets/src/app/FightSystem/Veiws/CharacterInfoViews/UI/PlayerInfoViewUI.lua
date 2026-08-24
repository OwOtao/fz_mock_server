--[[
    author:Seven
    time:2023-10-19 15:45:10
    desc: 玩家角色信息UI类
]]
local BaseViewUI = require("app.FightSystem.Veiws.ViewCommon.BaseViewUI")

local IInfoPanelViewUI = require("app.FightSystem.Veiws.CharacterInfoViews.UI.IInfoPanelViewUI")

local NodeActionManager = require("app.extends.NodeAction.NodeActionManager")

local NodeActions = require("app.extends.NodeAction.Actions")

local ViewUIClickRegister = require("app.FightSystem.Veiws.ViewCommon.ViewUIClickRegister")

local FightCommons = require("app.FightSystem.FightCommons")

local NewClass = require("third.class.NewClass")
--@SuperType [src.app.FightSystem.Veiws.ViewCommon.BaseViewUI#BaseViewUI]
local PlayerInfoViewUI = {}

function PlayerInfoViewUI:onInit()
    self:setVisible(false)

    self.ActiveName:setVisible(false)

    self.__activePosX = self.ActiveName:getPositionX()

    self.__activeStartPosY = 123

    self.CostNeiLi:setVisible(false)

    --@RefType [NodeActionManager]
    self.__textNodeActionManager = NodeActionManager:create()

    --@desc 操作释放列表
    self.__operationNameNodes = {}

    self.AllBuffPanel:setVisible(false)

    --@RefType [src.app.FightSystem.Veiws.ViewCommon.ViewUIClickRegister#ViewUIClickRegister]
    self.__viewUIPressRegister = ViewUIClickRegister:createWithMoveChildren(self.__node)
end

function PlayerInfoViewUI:addChildNode(node)
    self.__node:addChild(node)
end

function PlayerInfoViewUI:onDestroy()
end

function PlayerInfoViewUI:onUpdate(ft)
    self.__textNodeActionManager:update(ft)
    self.__viewUIPressRegister:update(ft)
end

function PlayerInfoViewUI:setVisible(bool)
    self:getNode():setVisible(bool)
end

function PlayerInfoViewUI:addBuffIcon(iconUi, index)
    iconUi:setName("BuffIcon" .. index)
    self.BuffPanel:addChild(iconUi)
end

function PlayerInfoViewUI:addBuffBigIcon(iconUi, index)
    iconUi:setName("BigBuffIcon" .. index)
    self.AllBuffPanel:addChild(iconUi)
end

function PlayerInfoViewUI:setRoleQiProgress(value)
    self.QiBar:setPercent(value)
end

function PlayerInfoViewUI:setRoleQiMaxProgress(value)
    self.QiMaxBar:setPercent(value)
end

function PlayerInfoViewUI:setRoleQiAndQiMaxValue(qiValue, qiMaxValue)
    self.QiValue:setString(tostring(qiValue) .. "/" .. tostring(qiMaxValue))
end

function PlayerInfoViewUI:setRoleNeiLiProgress(value)
    self.NeiliBar:setPercent(value)
end

function PlayerInfoViewUI:setRoleNeiLiMaxProgress(value)
    self.NeiliMaxBar:setPercent(value)
end

function PlayerInfoViewUI:setRoleNeiLiAndNeiLiMaxValue(neiLiValue, neiLiMaxValue)
    self.NeiliValue:setString(tostring(neiLiValue) .. "/" .. tostring(neiLiMaxValue))
end

function PlayerInfoViewUI:setTiliMaxProgress(percent)
    self.TiliMaxBar:setPercent(percent)
end

function PlayerInfoViewUI:setTiliProgress(percent)
    self.TiliBar:setPercent(percent)
end

function PlayerInfoViewUI:setRoleName(name)
    self.Name:setString(name)
end

function PlayerInfoViewUI:showOperationName(name)
    while self.__textNodeActionManager:getActionCount() > 0 do
        self.__textNodeActionManager:update(0.1)
    end

    local textNode = self:__cloneActiveName()

    local nodeCount = #self.__operationNameNodes

    local posY = self.__activeStartPosY + (nodeCount * 49)

    self:getNode():addChild(textNode)

    textNode:setVisible(true)

    textNode:setString(name)

    textNode:setTextColor(cc.c4b(238, 238, 238, 255))

    textNode:setPosition(cc.p(self.__activePosX, posY))

    table.insert(self.__operationNameNodes, textNode)
end

function PlayerInfoViewUI:hideOperationName(hideAnimStyle)
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

function PlayerInfoViewUI:removeAllOperationName()
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

function PlayerInfoViewUI:__moveNextOperationName()
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

function PlayerInfoViewUI:getBigIconNode(index)
    local iconNode = self.BuffPanel:getChildByName("BuffIcon" .. index)
    return iconNode
end

function PlayerInfoViewUI:getIconNode(index)
    local iconNode = self.AllBuffPanel:getChildByName("BigBuffIcon" .. index)
    return iconNode
end

function PlayerInfoViewUI:showNeiliCost(value)
    if self.__costNeiliAction then
        self.__costNeiliAction:remove()
    end

    self.CostNeiLi:setOpacity(255)

    self.CostNeiLi:setVisible(true)

    self.CostNeiLi:setString(value .. "内力")

    self.CostNeiLi:setTextColor(cc.c4b(66, 139, 255, 255))

    self.__costNeiliAction =
        self.__mainView:runUINodeAction(
        self.CostNeiLi,
        NodeActions.Sequence:create(
            NodeActions.DelayTime:create(1),
            NodeActions.FadeOut:create(0.5),
            NodeActions.CallFunc:create(
                function()
                    self.CostNeiLi:setVisible(false)
                end
            )
        )
    )
end

function PlayerInfoViewUI:__cloneActiveName()
    local activeNameNode = self.ActiveName:clone()

    return activeNameNode
end

function PlayerInfoViewUI:registerClickFunc(beganFunc, releaseFunc, canceledFunc, pressingUpdateFunc)
    self.__viewUIPressRegister:registerClickFunc(beganFunc, releaseFunc, canceledFunc, pressingUpdateFunc)
end

function PlayerInfoViewUI:showAllBuffPanel()
    self.AllBuffPanel:setVisible(true)
end

function PlayerInfoViewUI:hideAllBuffPanel()
    self.AllBuffPanel:setVisible(false)
end

return NewClass("PlayerInfoViewUI", {BaseViewUI, IInfoPanelViewUI}, PlayerInfoViewUI)
000000000000