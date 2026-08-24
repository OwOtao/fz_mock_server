local DieJinChongZhiPresenters = class("DieJinChongZhiPresenters", cc.Layer)

function DieJinChongZhiPresenters:create()
    local p = DieJinChongZhiPresenters:new()
    p:init()
    return p
end

function DieJinChongZhiPresenters:init()
    self._actionUI = require("app.views.ui.ActionUI.DieJinChongZhiUI"):create()

    self._actionUI:addTo(self)

    local DieJinChongZhi = require("app.models.Action.DieJinChongZhi")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self._interactor = DieJinChongZhi:create()

    self:__setRuleFunc()
end

function DieJinChongZhiPresenters:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)

    self:__initData()

    self._interactor:setAfterRewardCallback(function()
        self._interactor:init(
        function()
            self._actionUI:showItemInfo(self._interactor:getTodayRewardInfo()[1])
            self._actionUI:showListView(self._interactor:getOherRewardInfo())
        end)
    end)
end

function DieJinChongZhiPresenters:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function DieJinChongZhiPresenters:__initData()
    self._interactor:init(
        function()
            self:__initUI()

            self._actionUI:showUI()
        end
    )
end

function DieJinChongZhiPresenters:__initUI()
    self._actionUI:setTextTitle(self._interactor:getActionName())

    self._actionUI:setDesc(self._interactor:getActionDesc())

    self._actionUI:setText1("累计达标充值天数："..self._interactor:getCurrDays().."天")

    self._actionUI:setText2("本日所需充值额度："..self._interactor:getCurrSpendNumber().."/"..self._interactor:getStandardNumber().."元")

    self._actionUI:showItemInfo(self._interactor:getTodayRewardInfo()[1])

    self._actionUI:showListView(self._interactor:getOherRewardInfo())

    self._actionUI:setButton1Func(function()
        MainControllLayer:pushLayer("StoreLayer")
        local StoreLayer=MainControllLayer:getLayer("StoreLayer")
        StoreLayer:showWithAction(function()
            PopupLayerController:showLayer("DieJinChongZhiPresenters",function(layer)
                layer:setActionId(self._interactor:getActionId())
                layer:showLayer()
            end)
        end)
        self:hideLayer()
    end)
end

function DieJinChongZhiPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "DieJinChongZhiPresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function DieJinChongZhiPresenters:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function DieJinChongZhiPresenters:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function DieJinChongZhiPresenters:__showRule()
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

Helper:classDefNodeGetInstance(DieJinChongZhiPresenters)

return DieJinChongZhiPresenters
0000