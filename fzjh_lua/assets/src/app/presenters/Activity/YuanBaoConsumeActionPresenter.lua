local YuanBaoConsumeActionPresenter = class("YuanBaoConsumeActionPresenter", cc.Layer)

function YuanBaoConsumeActionPresenter:create()
    local p = YuanBaoConsumeActionPresenter:new()
    p:init()
    return p
end

function YuanBaoConsumeActionPresenter:init()
    self._actionUI = require("app.views.ui.ActionUI.YuanBaoConsumeActionUI"):create()

    self._actionUI:addTo(self)

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self:__setRuleFunc()

    local YuanBaoConsumeAction = require("app.models.Action.YuanBaoConsumeAction")

    self._interactor = YuanBaoConsumeAction:create()
end

function YuanBaoConsumeActionPresenter:showLayer()
    self._role = User:getRole()
    self._showRewardIndex = 1

    self._interactor:setRole(self._role)
    self._interactor:init(
        function()
            self:__initUI(function()
                self._actionUI:showUI()
                self._time = GetTime()
                self:__updateTime()
            end)
        end
    )
end

function YuanBaoConsumeActionPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "YuanBaoConsumeActionPresenter",
        function(layer)
            self._actionUI:hideUI()
            if self.handle then
                self:unschedule(self.handle)
                self.handle = nil
            end
        end
    )
end

function YuanBaoConsumeActionPresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function YuanBaoConsumeActionPresenter:__initUI(func)
    self._actionUI:setTextTitle(self._interactor:getActionName())

    self._actionUI:setDesc(self._interactor:getActionDesc())
    
    self:__initNowPanelInfo()

    self._actionUI:setRightBtnFunc(function()
        self:__initRightPanelInfo()
    end)

    self._actionUI:setLeftBtnFunc(function()
        self:__initLeftPanelInfo()
    end)

	self._actionUI:setButtonPayFunc(function()
		MainControllLayer:pushLayer("StoreLayer")
		local StoreLayer = MainControllLayer:getLayer("StoreLayer")
		StoreLayer:showWithAction(function()
			PopupLayerController:showLayer("YuanBaoConsumeActionPresenter",function(layer)
				layer:showLayer()
                layer:initRule(self.__ruleInfo)
			end)
		end)
		self:hideLayer()
	end)

    if func then
        func()
    end
end

function YuanBaoConsumeActionPresenter:__initNowPanelInfo()
    local panelInfo = self._interactor:getShowInfo()

    Helper:print_lua_table(panelInfo)

    if MapIsEmpty(panelInfo) == false then
        local info = panelInfo[self._showRewardIndex]
        self:__initPanelInfo(info)
        self._actionUI:initNowPanelInfo(info.rewards)
    end
end

function YuanBaoConsumeActionPresenter:__initLeftPanelInfo()
    if self._showRewardIndex == 1 then
        return
    end

    self._showRewardIndex = self._showRewardIndex - 1
    local panelInfo = self._interactor:getShowInfo()

    if MapIsEmpty(panelInfo) == false then
        local info = panelInfo[self._showRewardIndex]
        self:__initPanelInfo(info)

        self._actionUI:initNextPanelInfo(info.rewards)
        self._actionUI:switchNextByLeft()
    end
end

function YuanBaoConsumeActionPresenter:__initRightPanelInfo()
    local panelInfo = self._interactor:getShowInfo()

    if MapIsEmpty(panelInfo) == false then
        if self._showRewardIndex == #panelInfo then
            return
        end

        self._showRewardIndex = self._showRewardIndex + 1

        local info = panelInfo[self._showRewardIndex]
        self:__initPanelInfo(info)

        self._actionUI:initNextPanelInfo(info.rewards)
        self._actionUI:switchNextByRight()
    end
end

function YuanBaoConsumeActionPresenter:__initPanelInfo(info)
    if MapIsEmpty(info) == false then
        self._actionUI:setLoadingBarText(tostring(self._interactor:getSpendNum()).."/"..tostring(info.target))
        self._actionUI:setLoadingBarPercent(self._interactor:getSpendNum() / info.target * 100)
        self._actionUI:setTipsText("累计消耗"..tostring(info.target).."元宝即可获得以下奖励")
 
        if self._interactor:checkStateIsGetReward(info.state) then
            self._actionUI:setRewardBtnName("已领取")
            self._actionUI:setRewardBtnTouchEnable(false)
        else
            self._actionUI:setRewardBtnName("领取")
            self._actionUI:setRewardBtnTouchEnable(true)
        end

        self._actionUI:setRewardBtnFunc(function()
            if self._interactor:checkStateIsUnlock(info.state) then
                PopText("未消耗足够元宝")
                return
            end

            local isBagEnough = self._interactor:checkBagCanGetReward(info.rewards)
            local isEmail = isBagEnough == true and 0 or 1

            self._interactor:doReward(info.rid, isEmail, function()
                self._actionUI:setRewardBtnName("已领取")
                self._actionUI:setRewardBtnTouchEnable(false)
            end)
        end)
    end
end

function YuanBaoConsumeActionPresenter:__updateTime(time)
    if self.handle then
        self:unschedule(self.handle)
        self.handle = nil
    end

    self._actionUI:setTimeTextVisible(true)

    self.handle = self:schedule(function()
        local nowTime = GetTime()

        if Helper:diffWithDate(self._time,nowTime) ~= 0 then
            self._interactor:init(
                function()
                    self:__initUI(function()
                    end)
                end
            )
            self._time = GetTime()
        end
        local duration = Helper:getTodayRemainingTime(nowTime)

        local year, month, day, hour, minute, second = Helper:getExpiredTime(duration)

        self._actionUI:setTimeText("距离活动重置："..tostring(hour).."小时"..tostring(minute).."分"..tostring(second).."秒")
    end,0.5)
end

function YuanBaoConsumeActionPresenter:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function YuanBaoConsumeActionPresenter:__showRule()
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

Helper:classDefNodeGetInstance(YuanBaoConsumeActionPresenter)

return YuanBaoConsumeActionPresenter
000000000