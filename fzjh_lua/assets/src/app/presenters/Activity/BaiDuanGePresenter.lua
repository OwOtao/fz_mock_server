local BaiDuanGePresenter = class("BaiDuanGePresenter", cc.Layer)

function BaiDuanGePresenter:create()
    local p = BaiDuanGePresenter:new()
    p:init()
    return p
end

function BaiDuanGePresenter:init()
    self._actionUI = require("app.views.ui.ActionUI.MingShiZhiYueUI"):create()

    self._actionUI:addTo(self)

    local BaiDuanGe = require("app.models.Action.BaiDuanGe")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )
    
    self:__setRuleFunc()

    self._interactor = BaiDuanGe:create()
end

function BaiDuanGePresenter:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)

    self._showType = 1
    
    self:__initData() 
end

function BaiDuanGePresenter:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function BaiDuanGePresenter:__initData()
    self._interactor:init(
        function()
            self._actionUI:setTextTitle(self._interactor:getActionName())

            self._actionUI:setDesc(self._interactor:getActionDesc())

            self:initConditionText()

            self:initTextColor()

            self:initTitleText()

            self:initHongDian()

            self:initListView()

            self:initTextFunc()

            self:initButtonFunc()

            self._actionUI:showUI()
        end
    )
end

function BaiDuanGePresenter:initHongDian()
    if self._showType == 1 then
        local isTrue = self._interactor:getRewardState(2)
        self._actionUI:setHongDianVisible(isTrue)
        self._actionUI:setHongDianPosition(cc.p(865, 1518))
    elseif self._showType == 2 then
        local isTrue = self._interactor:getRewardState(1)
        self._actionUI:setHongDianVisible(isTrue)
        self._actionUI:setHongDianPosition(cc.p(508, 1518))
    end
end

function BaiDuanGePresenter:initTitleText()
    local text = self._interactor:getRewardTitle(1)
    self._actionUI:setTextStr(1, text)

    local text = self._interactor:getRewardTitle(2)
    self._actionUI:setTextStr(2, text)

    if self._interactor:getRewardCount() == 1 then
        self._actionUI:setTextPositionX(1, 540)
        self._actionUI:setTextVisible(2, false)
    end
end

function BaiDuanGePresenter:initConditionText()
    local text = self._interactor:getRewardConditionText(self._showType)
    self._actionUI:setTextStr(3, text)
end

function BaiDuanGePresenter:initTextColor()
    if self._showType == 1 then
        local isTrue = self._interactor:getRewardUnlockState(1)
        if isTrue then
            self._actionUI:setTextColor(1, cc.c3b(207,196,57))
        else
            self._actionUI:setTextColor(1, cc.c3b(255,255,255))
        end
        
        self._actionUI:setTextColor(2, cc.c3b(255,255,255))
    elseif self._showType == 2 then
        local isTrue = self._interactor:getRewardUnlockState(2)
        if isTrue then
            self._actionUI:setTextColor(2, cc.c3b(207,196,57))
        else
            self._actionUI:setTextColor(2, cc.c3b(255,255,255))
        end
        
        self._actionUI:setTextColor(1, cc.c3b(255,255,255))
    end
end

function BaiDuanGePresenter:initTextFunc()
    self._actionUI:setTextFunc(1, function()
        if self._showType == 1 then
            return
        end

        self._showType = 1

        local isTrue = self._interactor:getRewardUnlockState(self._showType)
        if isTrue == false then
            local msg = self._interactor:getRewardConditionText(self._showType)
            if msg then
                PopText(msg)
            end
        end

        self:initConditionText()
        self:initTextColor()
        self:initHongDian()
        self:initListView()
        self:initButtonFunc()
    end)

    self._actionUI:setTextFunc(2, function()
        if self._showType == 2 then
            return
        end

        self._showType = 2

        local isTrue = self._interactor:getRewardUnlockState(self._showType)
        if isTrue == false then
            local msg = self._interactor:getRewardConditionText(self._showType)
            if msg then
                PopText(msg)
            end
        end

        self:initConditionText()
        self:initTextColor()
        self:initHongDian()
        self:initListView()
        self:initButtonFunc()
    end)
end

function BaiDuanGePresenter:initButtonFunc()
    local productKey = self._interactor:getRewardProductKey(self._showType)
    if productKey then
        local isTrue = self._interactor:getRewardUnlockState(self._showType) 
        if isTrue then
            self._actionUI:setButtonVisible(false)
        else
            self._actionUI:setButtonVisible(true)
        end
        
        self._actionUI:setButtonFunc(function()
            self._interactor:toPay(productKey, function()
                self._interactor:init(function()
                    self:initHongDian()
                    self:initListView()
                    self:initButtonFunc()
                end)
            end)
        end)
    else
        self._actionUI:setButtonVisible(false)
    end
end

function BaiDuanGePresenter:initListView()
    local list = self._interactor:getRewardList(self._showType)
    local uiList = {}

    for i, reward in ipairs(list) do
        local text1 = "登录"..tostring(i).."天"
        local text2 = self._interactor:getRewardText(reward.reward)
        local isEnabled = false
        local btnVisible = reward.state ~= 2
        local imgVisible = reward.state == 2
        local btnName = "领取"
        local loadTexture = "Image/UI/TeacherUI/anniu_ddfs.png"
        if reward.state == 1 then
            isEnabled = true
            loadTexture = "Image/UI/MapUI/anniu05.png"
        end

        local func = function()
            if reward.state == 0 then
                return
            elseif reward.state == 2 then
                return
            end

            local isTrue = self._interactor:checkBagCanGetReward(reward.reward)

            local isEmail = 1

            if isTrue then
                isEmail = 0
            end

            self._interactor:doReward(reward.rid, isEmail, function()
                self._interactor:init(function()
                    self:initHongDian()
                    self:initListView()
                end)
            end)
        end

        local func1 = function()
            PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                layer:showLayer(reward.reward)
            end)
        end
        
        table.insert(uiList, {text1 = text1, text2 = text2, isEnabled = isEnabled, btnVisible = btnVisible, imgVisible = imgVisible, btnName = btnName, loadTexture = loadTexture, func = func, func1 = func1})
    end

    self._actionUI:showListView(uiList)
end

function BaiDuanGePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "BaiDuanGePresenter",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function BaiDuanGePresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function BaiDuanGePresenter:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function BaiDuanGePresenter:__showRule()
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

Helper:classDefNodeGetInstance(BaiDuanGePresenter)

return BaiDuanGePresenter
0000000000000