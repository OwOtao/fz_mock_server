local LoginMultipleRewardPresenter = class("LoginMultipleRewardPresenter", cc.Layer)
local GoodsHelper = require("app.models.Store.GoodsHelper")
local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")

function LoginMultipleRewardPresenter:create()
    local p = LoginMultipleRewardPresenter:new()
    p:init()
    return p
end

function LoginMultipleRewardPresenter:init()
    self._actionUI = require("app.views.ui.ActionUI.LoginMultipleRewardUI"):create()

    self._actionUI:addTo(self)

    local LoginMultipleReward = require("app.models.Action.LoginMultipleReward")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self:__setRuleFunc()

    self._interactor = LoginMultipleReward:create()
end

function LoginMultipleRewardPresenter:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    
    self:__initData()
end

function LoginMultipleRewardPresenter:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function LoginMultipleRewardPresenter:__initData()
    self._interactor:init(
        function()
            self._actionUI:setTextTitle(self._interactor:getActionName())

            self._actionUI:setDesc(self._interactor:getActionDesc())

            self:initCountText()

            self:initTipImage()

            self:initTipText()

            self:initTitle()

            self:initRewardButton()

            self:initRewardPool()
            
            self:initTodayRewardPool()
            
            self._actionUI:showUI()
        end
    )
end

function LoginMultipleRewardPresenter:initTipImage()
    local config = self._interactor:getPoolTextConfig()

    for k, v in pairs(config) do
        self._actionUI:setTipImageFunc(k, function()
            local dialog = DialogELayer:getInstance()
            self._actionUI:setLightTipImageVisible(k, true)
            dialog:show(v.text)
            dialog:setPanelBack(function()
                self._actionUI:setLightTipImageVisible(k, false)
            end)
        end)
    end

    self._actionUI:setTipImageFunc(5, function()
        local dialog = DialogELayer:getInstance()
        self._actionUI:setLightTipImageVisible(5, true)
        dialog:show("当前已累计登录："..self._interactor:getLoginDayCount().."天")
        dialog:setPanelBack(function()
            self._actionUI:setLightTipImageVisible(5, false)
        end)
    end)
end

function LoginMultipleRewardPresenter:initTitle()
    local config = self._interactor:getPoolTextConfig()

    for k, v in pairs(config) do
        self._actionUI:setText(k, v.name)
    end
end

function LoginMultipleRewardPresenter:initCountText()
    self._actionUI:setCountText(1, "已领取次数："..self._interactor:getTodayRewardReceivedCount().."/"..self._interactor:getTodayRewardTotalCount().."次")
    self._actionUI:setCountText(2, "当前可领次数："..self._interactor:getTodayRewardAvailableCount().."次")
    self._actionUI:setCountText(3, "当前累积次数："..self._interactor:getTodayRewardUnclaimableCount().."次")
end

function LoginMultipleRewardPresenter:initTipText()
    if self._interactor:getTodayRewardReceivedCount() == self._interactor:getTodayRewardTotalCount() then
        self._actionUI:setTipTextVisible(1, true)
        self._actionUI:setButtonVisible(1, false)
        self._actionUI:setTipText(1, "已获得全部奖励")
    elseif self._interactor:getTodayRewardAvailableCount() == 0 then
        self._actionUI:setTipTextVisible(1, true)
        self._actionUI:setButtonVisible(1, false)
        self._actionUI:setTipText(1, "暂无可领奖励")
    else
        self._actionUI:setTipTextVisible(1, false)
        self._actionUI:setButtonVisible(1, true)
    end

    if self._interactor:checkRewardPoolIsEmpty() then
        self._actionUI:setTipTextVisible(2, true)
        self._actionUI:setButtonVisible(2, false)
        self._actionUI:setTipText(2, "已获得全部奖池奖励")
    elseif self._interactor:getRewardAvailableCount() == 0 then
        self._actionUI:setTipTextVisible(2, true)
        self._actionUI:setButtonVisible(2, false)
        self._actionUI:setTipText(2, "奖池暂无可领奖励")
    else
        self._actionUI:setTipTextVisible(2, false)
        self._actionUI:setButtonVisible(2, true)
    end
end

function LoginMultipleRewardPresenter:initRewardButton()
    self._actionUI:setButtonFunc(1, function()
        self._interactor:getTotalAvailableClaimReward(1, function()
            self:initCountText()
            self:initTipText()
        end)
    end)

    self._actionUI:setButtonFunc(2, function()
        self._interactor:getTotalAvailableClaimReward(2, function()
            self:initRewardPool()
            self:initTipText()
        end)
    end)
end

function LoginMultipleRewardPresenter:initTodayRewardPool()
    local todayRewardPool = self._interactor:getTodayRewardPool()
    local uiList = {}

    for i, v in ipairs(todayRewardPool) do
        local goods = GoodsHelper:getGoodsResClass(v.id)

        table.insert(uiList, {
            icon = goods:getIcon(),
            text = "X"..v.num,
            func = function()
                self:__showGoodsInfoUI({{id = v.id}})
            end
        })
    end

    self._actionUI:initListView_1(uiList)
end

function LoginMultipleRewardPresenter:initRewardPool()
    local rewardPool = self._interactor:getRewardPool()
    local uiList = {}

    for day, dayReward in pairs(rewardPool) do
        local info = {text = day.."天", day = tonumber(day), sortIndex = 1, list = {}}

        for i, v in ipairs(dayReward) do
            local goods = GoodsHelper:getGoodsResClass(v.id)

            if v.state ~= 2 then
                info.sortIndex = 0
            end

            table.insert(info.list, {
                icon = goods:getIcon(),
                text = "X"..v.num,
                visible1 = v.state == 2,
                visible2 = v.state ~= 1,
                visible3 = v.state ~= 2,
                bgImg = v.state == 1 and "Image/UI/ActionUI/wupingkuang-2.png" or "Image/UI/ActionUI/wupingkuang-1.png",
                func = function()
                    if v.state == 1 then
                        self._interactor:getOneReward(v.poolId, v.day, function()
                            self:initRewardPool()
                            self:initTipText()
                        end)
                    else
                        self:__showGoodsInfoUI({{id = v.id}})
                    end
                end
            })
        end

        table.insert(uiList, info)
    end

    table.sort(uiList, function(a, b)
        if a.sortIndex == b.sortIndex then
            return a.day < b.day
        else
            return a.sortIndex < b.sortIndex
        end 
    end)

    self._actionUI:initListView_2(uiList)
end

function LoginMultipleRewardPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "LoginMultipleRewardPresenter",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function LoginMultipleRewardPresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function LoginMultipleRewardPresenter:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function LoginMultipleRewardPresenter:__showRule()
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

function LoginMultipleRewardPresenter:__showGoodsInfoUI(goodsList)
    PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
        layer:showLayer(goodsList)
    end)
end

Helper:classDefNodeGetInstance(LoginMultipleRewardPresenter)

return LoginMultipleRewardPresenter
000000000000