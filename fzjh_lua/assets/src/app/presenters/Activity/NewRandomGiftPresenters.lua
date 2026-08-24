local NewRandomGiftPresenters = class("NewRandomGiftPresenters", cc.Layer)

function NewRandomGiftPresenters:create()
    local p = NewRandomGiftPresenters:new()
    p:init()
    return p
end

function NewRandomGiftPresenters:init()
    self._actionUI = require("app.views.ui.ActionUI.NewRandomGiftUI"):create()

    self._actionUI:addTo(self)

    local NewRandomGift = require("app.models.Action.NewRandomGift")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self:__setRuleFunc()

    self._interactor = NewRandomGift:create()
end

function NewRandomGiftPresenters:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    
    self:__initData()

    self._interactor:setAfterBuyCallBack(function()
        self._interactor:init("N",function()

            self._actionUI:setText1("活动期间已购买道具："..self._interactor:getBuyTimes().."次")

            if self._interactor:checkIsMaxBuyTimes() then
                self._actionUI:setButton1TouchEnable(false)
                self._actionUI:setButton1Texture("Image/UI/TaskUI/anniuhui.png")
            end

            if self._interactor:getRefreshCost() > 0 then
                self._actionUI:setText2("本次花费"..self._interactor:getRefreshCost()..self._interactor:getRefreshCostCNName())
            else
                self._actionUI:setText2("本次刷新免费")
            end

            self:__showListView()
        end)
    end)

    self._interactor:setAfterRewardCallback(function()
        self._interactor:init("N",function()
            self:__showListView()
        end)
    end)
end

function NewRandomGiftPresenters:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function NewRandomGiftPresenters:__initData()
    self._interactor:init("N",
        function()
            self._actionUI:setTextTitle(self._interactor:getActionName())

            self._actionUI:setDesc(self._interactor:getActionDesc())

            self._actionUI:setText1("活动期间已购买道具："..self._interactor:getBuyTimes().."次")

            if self._interactor:getRefreshCost() > 0 then
                self._actionUI:setText2("本次花费"..self._interactor:getRefreshCost()..self._interactor:getRefreshCostCNName())
            else
                self._actionUI:setText2("本次刷新免费")
            end

            self:__showListView()

            self._actionUI:showInfoListView(self._interactor:getRewardPoolList())

            self._actionUI:setPanelInfoFunc(function()
                self._actionUI:setPanelInfoVisible(false)
            end)

            self._actionUI:setPanelInfoBtnFunc(function()
                self._actionUI:setPanelInfoVisible(true)
            end)

            if self._interactor:checkIsMaxBuyTimes() then
                self._actionUI:setButton1TouchEnable(false)
                self._actionUI:setButton1Texture("Image/UI/TaskUI/anniuhui.png")
            end

            self._actionUI:setButton1Name("刷新")

            self._actionUI:setButton1Func(function()
                if self._interactor:isCanRefresh() then
                    local refreshFunc = function()
                        self._interactor:init("Y",function()
                    
                            if self._interactor:getRefreshCost() > 0 then
                                self._actionUI:setText2("本次花费"..self._interactor:getRefreshCost()..self._interactor:getRefreshCostCNName())
                            else
                                self._actionUI:setText2("本次刷新免费")
                            end
    
                            if self._interactor:checkIsMaxBuyTimes() then
                                self._actionUI:setButton1TouchEnable(false)
                                self._actionUI:setButton1Texture("Image/UI/TaskUI/anniuhui.png")
                            end
                
                            self:__showListView()
                        end)
                    end
                    
                    if self._interactor:getRefreshCost() > 0 then
                        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                        local dialog = DialogALayer:getInstance()
                        dialog:show()
                        dialog:setRichText( "本次刷新需消耗"..self._interactor:getRefreshCost()..self._interactor:getRefreshCostCNName().."，是否继续？")
                        dialog:setButton1("确定", function()
                            refreshFunc()
                        end)
                        dialog:setButton2("取消", function()
                            dialog:hide()
                        end)
                        dialog:setWeChatVisible(false)
                    else
                        refreshFunc()
                    end
                end
            end)

            self._actionUI:showUI()
        end
    )
end

function NewRandomGiftPresenters:__showListView()
    local rewardList = self._interactor:getRewardList()
    for k,v in pairs(rewardList) do
        if v.func then
            local oldFunc = v.func
            v.func = function()
                if v.state == 0 then
                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                    local dialog = DialogALayer:getInstance()
                    dialog:show()
                    dialog:setRichText( "是否使用"..v.btnName..v.text1.."？")
                    dialog:setButton1("确定", function()
                        oldFunc()
                    end)
                    dialog:setButton2("取消", function()
                        dialog:hide()
                    end)
                    dialog:setWeChatVisible(false)
                else
                    oldFunc()
                end
            end
        end
    end
    self._actionUI:showListView(rewardList)
end

function NewRandomGiftPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "NewRandomGiftPresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function NewRandomGiftPresenters:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function NewRandomGiftPresenters:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function NewRandomGiftPresenters:__showRule()
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

Helper:classDefNodeGetInstance(NewRandomGiftPresenters)

return NewRandomGiftPresenters
0