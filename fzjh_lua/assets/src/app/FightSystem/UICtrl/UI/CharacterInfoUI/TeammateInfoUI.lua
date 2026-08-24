local BaseUI = require("app.FightSystem.UICtrl.UI.BaseUI")

local ICharacterInfoUI = require("app.FightSystem.UICtrl.UI.CharacterInfoUI.ICharacterInfoUI")

local NodeActionManager = require("app.extends.NodeAction.NodeActionManager")

local NodeActions = require("app.extends.NodeAction.Actions")

local TaskFlow = require("app.extends.TaskFlow")

local NewClass = require("third.class.NewClass")
--@SuperType [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
local TeammateInfoUI = {}

function TeammateInfoUI:onInit()
    self.ActiveName:setVisible(false)

    --@RefType [NodeActionManager]
    self.__textNodeActionManager = NodeActionManager:create()

    self.__activePosX = self.ActiveName:getPositionX()

    self.__activeStartPosY = 72

    self.__operationNameNodes = {}

    self.AllBuffPanel:setVisible(false)
end

function TeammateInfoUI:onDestroy()
end

function TeammateInfoUI:onUpdate(ft)
    self.__textNodeActionManager:update(ft)
end

function TeammateInfoUI:setVisible(bool)
    self:getNode():setVisible(bool)
end

function TeammateInfoUI:addBuffIcon(iconUi, index)
    iconUi:setName("BuffIcon" .. index)
    self.BuffPanel:addChild(iconUi)
end

function TeammateInfoUI:addBuffBigIcon(iconUi, index)
    iconUi:setName("BigBuffIcon" .. index)
    self.AllBuffPanel:addChild(iconUi)
end

function TeammateInfoUI:setRoleQiProgress(value)
    self.QiBar:setPercent(value)
end

function TeammateInfoUI:setRoleQiMaxProgress(value)
    self.QiMaxBar:setPercent(value)
end

function TeammateInfoUI:setTiliMaxProgress(percent)
    self.TiliMaxBar:setPercent(percent)
end

function TeammateInfoUI:setTiliProgress(percent)
    self.TiliBar:setPercent(percent)
end

function TeammateInfoUI:setRoleName(name)
    self.Name:setString(name)
end

function TeammateInfoUI:showOperationName(name)
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

function TeammateInfoUI:hideOperationName()
    --@desc 先执行完未结束的action
    while self.__textNodeActionManager:getActionCount() > 0 do
        self.__textNodeActionManager:update(0.1)
    end

    if #self.__operationNameNodes <= 0 then
        return
    end

    local textNode = self.__operationNameNodes[1]

    textNode:setOpacity(255)

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

function TeammateInfoUI:removeAllOperationName()
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

function TeammateInfoUI:updateBuffIcon(buffInfos)
    local FightCommons = require("app.FightSystem.FightCommons")
    for i = 1, FightCommons.BUFFICON_MAXCOUNT do
        local iconNode = self.BuffPanel:getChildByName("BuffIcon" .. i)
        if buffInfos and buffInfos[i] then
            local buffInfo = buffInfos[i]
            iconNode.Img:loadTexture(buffInfo.imagePath, 0)
            iconNode:setVisible(true)
            if buffInfo.count > 1 then
                iconNode.TextLayer:setString(buffInfo.count)
                iconNode.TextLayer:setVisible(true)
            else
                iconNode.TextLayer:setVisible(false)
            end
        else
            iconNode:setVisible(false)
        end
    end

    for i = 1, FightCommons.ALL_BUFFICON_MAXCOUNT do
        local iconNode = self.AllBuffPanel:getChildByName("BigBuffIcon" .. i)
        if buffInfos and buffInfos[i] then
            local buffInfo = buffInfos[i]
            iconNode.Img:loadTexture(buffInfo.imagePath, 0)
            iconNode:setVisible(true)
            if buffInfo.count > 1 then
                iconNode.TextLayer:setString(buffInfo.count)
                iconNode.TextLayer:setVisible(true)
            else
                iconNode.TextLayer:setVisible(false)
            end
        else
            iconNode:setVisible(false)
        end
    end
end

function TeammateInfoUI:setRoleQiAndQiMaxValue(qiValue, qiMaxValue)
end

function TeammateInfoUI:setRoleNeiLiProgress(value)
end

function TeammateInfoUI:setRoleNeiLiMaxProgress(value)
end

function TeammateInfoUI:setRoleNeiLiAndNeiLiMaxValue(neiLiValue, neiLiMaxValue)
end

function TeammateInfoUI:showNeiliCost(value)
end

function TeammateInfoUI:__cloneActiveName()
    local activeNameNode = self.ActiveName:clone()

    return activeNameNode
end

function TeammateInfoUI:__moveNextOperationName()
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

function TeammateInfoUI:registerClickFunc(beganFunc, endedFunc, cancelFunc)
    self.__node:moveChildrenWithButton(
        function()
            beganFunc()
        end,
        function()
            endedFunc()
        end,
        function()
            cancelFunc()
        end
    )
end

function TeammateInfoUI:showAllBuffPanel()
    self.AllBuffPanel:setVisible(true)
end

function TeammateInfoUI:hideAllBuffPanel()
    self.AllBuffPanel:setVisible(false)
end

return NewClass("TeammateInfoUI", {BaseUI, ICharacterInfoUI}, TeammateInfoUI)
00000