local AnniversaryLoginRewardPresenter = class("AnniversaryLoginRewardPresenter", cc.Layer)

function AnniversaryLoginRewardPresenter:create()
    local p = AnniversaryLoginRewardPresenter:new()
    p:init()
    return p
end

function AnniversaryLoginRewardPresenter:init()
    self._actionUI = require("app.views.ui.ActionUI.AnniversaryLoginRewardUI"):create()

    self._actionUI:addTo(self)

    local AnniversaryLoginReward = require("app.models.Action.AnniversaryLoginReward")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )
    
    self:__setRuleFunc()

    self._actionUI:clearListView()

    self._interactor = AnniversaryLoginReward:create()

    self.handle = self:schedule(function(ft)
        self:update(ft)
    end,1)
end

function AnniversaryLoginRewardPresenter:setRole(role)
    self._interactor:setRole(role)
end

function AnniversaryLoginRewardPresenter:showLayer()
    self:__initData()
    self._interactor:setAfterRewardCallback(function()
        self._interactor:init(function()
            self:__initUI()
        end)
    end)
end

function AnniversaryLoginRewardPresenter:__initData()
    self._interactor:init(function()
        self.yuanbaoTime = self._interactor:getYuanBaoRewardTime()
        self:__initUI()
        self._actionUI:showUI()
    end)
end

function AnniversaryLoginRewardPresenter:__initUI()
    self._actionUI:setTextTitle(self._interactor:getActionName())
    self._actionUI:setDesc(self._interactor:getActionDesc())
    self._actionUI:setText1("最终可获得元宝："..self._interactor:getYuanBaoNum().."元宝")

    local islock = self._interactor:checkYuanBaoRewardIslock()

    if islock then
        self._actionUI:setRewardButtonTexture("Image/BaseUI/btn-grey.png")
    else
        self._actionUI:setRewardButtonTexture("Image/BaseUI/btn-orangeRed.png")
    end

    self._actionUI:setRewardButtonName("领取")

    self._actionUI:setButtonRewardFunc(function()
        if islock then
            local year = Helper:date("%Y",self.yuanbaoTime)
            local month = Helper:date("%m",self.yuanbaoTime)
            local day = Helper:date("%d",self.yuanbaoTime)
            local hour = Helper:date("%H",self.yuanbaoTime)
            PopText("元宝领取时间为"..year.."年"..month.."月"..day.."日"..hour.."时。")
            return
        end

        if self._interactor:checkCanGetYuanbaoReward() == true then
            self._interactor:doYuanBaoReward(function()
                self._actionUI:setText1("最终可获得元宝：0元宝")
            end)
        else
            PopText("当前无可领取元宝。")
        end
    end)

    local rewardList = self._interactor:getRewardList()
    self:__refreshListView(rewardList)
end

function AnniversaryLoginRewardPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "AnniversaryLoginRewardPresenter",
        function(layer)
            self.yuanbaoTime = nil
            self:unschedule(self.handle)
            self.handle = nil
            self._actionUI:hideUI()
        end
    )
end

function AnniversaryLoginRewardPresenter:update(ft)
    if self.yuanbaoTime then
        local time = GetTime()
        if time > self.yuanbaoTime then
            self.yuanbaoTime = nil
            self._interactor:init(function()
                self:__initUI()
            end)
        end
    end
end

function AnniversaryLoginRewardPresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function AnniversaryLoginRewardPresenter:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function AnniversaryLoginRewardPresenter:__showRule()
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

function AnniversaryLoginRewardPresenter:__refreshListView(list)
    for k,v in ipairs(list) do
        local panel = self._actionUI:getListViewItemByIndex(k - 1)
        if not panel then
            panel = self._actionUI:cloneListViewItem()
            self._actionUI:addItemToListView(panel)
        end
        self._actionUI:initListViewPanel(panel,v)
    end
end

Helper:classDefNodeGetInstance(AnniversaryLoginRewardPresenter)

return AnniversaryLoginRewardPresenter
0000000000000