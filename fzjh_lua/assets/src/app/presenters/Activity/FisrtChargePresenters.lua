local FisrtChargePresenters = class("FisrtChargePresenters", cc.Layer)

function FisrtChargePresenters:create()
    local p = FisrtChargePresenters:new()
    p:init()
    return p
end

function FisrtChargePresenters:init()
    self._actionUI = require("app.views.ui.ActionUI.FisrtChargeUI"):create()

    self._actionUI:addTo(self)

    local FisrtCharge = require("app.models.Action.FisrtCharge")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self:__setRuleFunc()

    self._interactor = FisrtCharge:create()
end

function FisrtChargePresenters:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    
    self:__initData()

    self._interactor:setAfterRewardCallback(function()
        self._interactor:init(function()
            self._actionUI:showListView(self._interactor:getRewardList())
        end)
    end)
end

function FisrtChargePresenters:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function FisrtChargePresenters:__initData()
    self._interactor:init(
        function()
            self._actionUI:setTextTitle(self._interactor:getActionName())

            self._actionUI:setDesc(self._interactor:getActionDesc())

            self._actionUI:showListView(self._interactor:getRewardList())

            self._actionUI:showUI()

            if self._interactor:getChargeState() then
                self._actionUI:setButton_1Texture("Image/UI/TaskUI/anniuhui.png")
            end

            self._actionUI:setButton_1Func(function()
                local chargeState = self._interactor:getChargeState()
                if chargeState == false then
                    MainControllLayer:pushLayer("StoreLayer")
                    local StoreLayer=MainControllLayer:getLayer("StoreLayer")
                    StoreLayer:showWithAction(function()
                        PopupLayerController:showLayer("FisrtChargePresenters",function(layer)
                            layer:showLayer()
                        end)
                    end)
                    self:hideLayer()
                else
                    PopText("已满足充值条件，可领取奖励")
                end
            end)

        end
    )
end

function FisrtChargePresenters:hideLayer()
    PopupLayerController:hideLayer(
        "FisrtChargePresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function FisrtChargePresenters:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function FisrtChargePresenters:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function FisrtChargePresenters:__showRule()
	PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("活动规则")
        layer:showPanel_1(self.__ruleInfo)
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

Helper:classDefNodeGetInstance(FisrtChargePresenters)

return FisrtChargePresenters
000000000000000