local ReputationStorePresenter = class("ReputationStorePresenter", cc.Layer)

function ReputationStorePresenter:create()
    local p = ReputationStorePresenter:new()
    p:init()
    return p
end

local InitEvent = {
    GetInfo = 0,    --初始化信息
    Refresh = 1     --元宝刷新
}

function ReputationStorePresenter:init()
    self._ui = require("app.views.ui.ActionUI.NewRandomGiftUI"):create()

    self._ui:addTo(self)

    local ReputationStore = require("app.models.Store.ReputationStore")

    self._ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self._ui:setPanelInfoVisible(false)
    self._ui:setPanelInfoBtnVisible(false)
    self._ui:setButtonRuleVisible(false)

    self._interactor = ReputationStore:create()
end

function ReputationStorePresenter:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    
    self:__initData()
end

function ReputationStorePresenter:setTitleName(name)
    self._ui:setTextTitle(name)
end

function ReputationStorePresenter:__initData()
    self._interactor:init(InitEvent.GetInfo,
        function()
            self._ui:setDesc(self._interactor:getActionDesc())

            self._ui:setText1("活动期间已购买道具："..self._interactor:getBuyTimes().."次")

            self._ui:setText1PosX(300)

            if self._interactor:getRefreshCost() > 0 then
                self._ui:setText2("本次花费"..self._interactor:getRefreshCost()..self._interactor:getRefreshCostCNName())
            else
                self._ui:setText2("本次刷新免费")
            end

            self:__showListView()

            self._ui:setPanelInfoFunc(function()
                self._ui:setPanelInfoVisible(false)
            end)

            self._ui:setPanelInfoBtnFunc(function()
                self._ui:setPanelInfoVisible(true)
            end)

            if self._interactor:checkIsMaxBuyTimes() then
                self._ui:setButton1TouchEnable(false)
                self._ui:setButton1Texture("Image/UI/TaskUI/anniuhui.png")
            else
                self._ui:setButton1TouchEnable(true)
                self._ui:setButton1Texture("Image/UI/TaskUI/anniu.png")
            end

            self._ui:setButton1Name("刷新")

            self._ui:setButton1Func(function()
                self:__refreshFunc()
            end)

            self._ui:showUI()
        end
    )
end

function ReputationStorePresenter:__showListView()
    self._ui:clearListView()

    local rewardList = self._interactor:getRewardList()
    for k,v in pairs(rewardList) do
        v.func = function()
            if v.state == 0 then
                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                local dialog = DialogALayer:getInstance()
                dialog:show()
                local text = "是否花费%s功绩购买%s个？完成购买后若背包已满，则会通过江湖游驿发放。"
                text = string.format(text,v.price,v.text1)
                dialog:setRichText(text)
                dialog:setButton1("确定", function()
                    self:__buyFunc(v)
                end)
                dialog:setButton2("取消", function()
                    dialog:hide()
                end)
                dialog:setWeChatVisible(false)
            elseif v.state == 1 then
                self:__getReward(v)
            elseif v.state == 2 then
                PopText("商品已经卖光，请下周再次购买")
            end
        end

        local panel = self._ui:cloneListViewPanelItem1()
        self._ui:initPanelItem1(panel, v)
        self._ui:addItemToListView(panel)
    end
end

function ReputationStorePresenter:__getReward(info)
    local is_email = 1
    if self._interactor:checkCanGetReward(info.rewards) then
        is_email = 0
    end

    self._interactor:doReward(info.id, is_email, function()
        self._interactor:init(InitEvent.GetInfo,function()
            self:__showListView()
        end)
    end)
end

function ReputationStorePresenter:__buyFunc(info)
    if self._interactor:checkIsMaxBuyTimes() then
        PopText("本周购买次数已用完，请下周再次购买")
        return
    end

    if info.stock <= 0 then
        PopText("商品已经卖光，请下周再次购买")
        return
    end

    self._interactor:buyGoods(info.id, function()
        self._interactor:init(InitEvent.GetInfo,function()
            self._ui:setText1("活动期间已购买道具："..self._interactor:getBuyTimes().."次")
    
            if self._interactor:checkIsMaxBuyTimes() then
                self._ui:setButton1TouchEnable(false)
                self._ui:setButton1Texture("Image/UI/TaskUI/anniuhui.png")
            end
    
            self:__showListView()
        end)
    end)
end

function ReputationStorePresenter:__refreshFunc()
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:show()
    local text = "刷新后商品库存不会改变，只会改变售卖种类。是否确认使用%s元宝刷新已在售卖的商品？"
    text = string.format(text, self._interactor:getRefreshCost())
    dialog:setRichText(text)
    dialog:setButton1("确定", function()
        self._interactor:init(InitEvent.Refresh,function()
            self:__showListView()
        end)
    end)
    dialog:setButton2("取消", function()
        dialog:hide()
    end)
    dialog:setWeChatVisible(false)
end

function ReputationStorePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "ReputationStorePresenter",
        function(layer)
            self._ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(ReputationStorePresenter)

return ReputationStorePresenter
0000