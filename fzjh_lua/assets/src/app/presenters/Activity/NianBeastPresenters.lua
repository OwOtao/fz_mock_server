
local GoodsHelper = require("app.models.Store.GoodsHelper")

local NianBeastPresenters = class("NianBeastPresenters", cc.Layer)

function NianBeastPresenters:create()
    local p = NianBeastPresenters:new()
    p:init()
    return p
end

function NianBeastPresenters:init()
    self.__actionUI = require("app.views.ui.ActionUI.NianBeastUI"):create()

    self.__actionUI:addTo(self)

    self.__selectRewardUI = require("app.views.ui.ActionUI.RewardSelectUI"):create()

    self.__selectRewardUI:addTo(self)

    self.__selectRewardUI:hideUI()

    self:__setRuleFunc()

    local NianBeast = require("app.models.Action.NianBeast")

    self.__actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self.__selectRewardUI:setButtonBack(
        function()
            self.__selectRewardUI:hideUI()
        end
    )

    self.__interactor = NianBeast:create()
end

function NianBeastPresenters:showLayer()
    self.__interactor:setRole(User:getRole())
    
    self.__interactor:getActionInfo(function()
        self:__initUI()
        self.__actionUI:showUI()
    end)
end

function NianBeastPresenters:__initUI()
    self.__showType = 1
    self.__actionUI:setTextTitle(self.__interactor:getActionName())
    self.__actionUI:setTextDesc(self.__interactor:getActionDesc())
    self.__actionUI:setText1Str("剩余鞭炮："..tostring(self.__interactor:getNianBeastNum()))
    self.__actionUI:setTitleText(1, "个人进度")
    self.__actionUI:setTitleText(2, "全体进度")
    self.__actionUI:setButtonText(1, "获取鞭炮")
    self.__actionUI:setButtonText(2, "驱赶")
    self.__actionUI:setTitleFunc(1, function()
        self.__showType = 1
        self:showPersonalRewardList()
    end)

    self.__actionUI:setTitleFunc(2, function()
        self.__showType = 2
        self:showGroupRewardList()
    end)

    self.__actionUI:setButtonFunc(1, function()
        self:showAccess()
    end)

    self.__actionUI:setButtonFunc(2, function()
        self:doDriveAway()
    end)

    self:showPersonalRewardList()
end

function NianBeastPresenters:showAccess()
    PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("鞭炮获取")
        layer:showPanel_1(self.__interactor:getAccess())
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

function NianBeastPresenters:showPersonalRewardList()
    self.__actionUI:showListView(self:__getRewardUIList(self.__interactor:getPersonalRewardList()))
    self.__actionUI:setTitleBackGroundColorOpacity(1, 255)
    self.__actionUI:setTitleBackGroundColorOpacity(2, 0)
    self.__actionUI:setTitleVisible(1, true)
    self.__actionUI:setTitleVisible(2, false)
    self.__actionUI:setTitleEnable(1, false)
    self.__actionUI:setTitleEnable(2, true)
end

function NianBeastPresenters:showGroupRewardList()
    self.__actionUI:showListView(self:__getRewardUIList(self.__interactor:getGroupRewardList()))
    self.__actionUI:setTitleBackGroundColorOpacity(2, 255)
    self.__actionUI:setTitleBackGroundColorOpacity(1, 0)
    self.__actionUI:setTitleVisible(2, true)
    self.__actionUI:setTitleVisible(1, false)
    self.__actionUI:setTitleEnable(2, false)
    self.__actionUI:setTitleEnable(1, true)
end

function NianBeastPresenters:doDriveAway()
    self.__actionUI:setPanelDriveAwayVisible(true)
    self.__actionUI:setPanelDriveAwayText3(self.__interactor:getDriveAwayInfo())
    self.__actionUI:setPanelDriveAwayText4("（剩余鞭炮："..self.__interactor:getNianBeastNum().."个）")

    self.__actionUI:setPanelDriveAwayFunc(function()
        self.__interactor:getActionInfo(function()
            self.__actionUI:setPanelDriveAwayVisible(false)

            if self.__showType == 1 then
                self:showPersonalRewardList()
            elseif self.__showType == 2 then
                self:showGroupRewardList()
            end
        end)
    end)

    self.__actionUI:setPanelDriveAwayButtonText(1, "使用1次鞭炮")
    self.__actionUI:setPanelDriveAwayButtonFunc(1, function()
        if self.__interactor:getNianBeastNum() > 0 then
            self.__interactor:doDriveAway(1,function()
                self.__actionUI:setPanelDriveAwayText4("（剩余鞭炮："..self.__interactor:getNianBeastNum().."个）")
                self.__actionUI:setText1Str("剩余鞭炮："..tostring(self.__interactor:getNianBeastNum()))
            end)
        else
            PopText("鞭炮数量不足，可点击【获取鞭炮】按钮查看鞭炮获取方式")
        end
    end)

    self.__actionUI:setPanelDriveAwayButtonText(2, "使用10次鞭炮")
    self.__actionUI:setPanelDriveAwayButtonFunc(2, function()
        if self.__interactor:getNianBeastNum() > 0 then
            self.__interactor:doDriveAway(10,function()
                self.__actionUI:setPanelDriveAwayText4("（剩余鞭炮："..self.__interactor:getNianBeastNum().."个）")
                self.__actionUI:setText1Str("剩余鞭炮："..tostring(self.__interactor:getNianBeastNum()))
            end)
        else
            PopText("鞭炮数量不足，可点击【获取鞭炮】按钮查看鞭炮获取方式")
        end
    end)

    self.__actionUI:setPanelDriveAwayButtonText(3, "使用50次鞭炮")
    self.__actionUI:setPanelDriveAwayButtonFunc(3, function()
        if self.__interactor:getNianBeastNum() > 0 then
            self.__interactor:doDriveAway(50,function()
                self.__actionUI:setPanelDriveAwayText4("（剩余鞭炮："..self.__interactor:getNianBeastNum().."个）")
                self.__actionUI:setText1Str("剩余鞭炮："..tostring(self.__interactor:getNianBeastNum()))
            end)
        else
            PopText("鞭炮数量不足，可点击【获取鞭炮】按钮查看鞭炮获取方式")
        end
    end)
end

function NianBeastPresenters:__getRewardUIList(dataList)
    local uiList = {}

    local count = self.__interactor:getPersonalCount()

    if self.__showType == 2 then
        count = self.__interactor:getGroupCount()
    end

    for i, v in ipairs(dataList) do
        local btnName = "领取"
        local enable = true
        local loadTexture = "Image/UI/TaskUI/anniu.png"
        local text1 = "驱赶年兽次数"..tostring(count).."/"..tostring(v.award_limit)
        local text2 = ""
        local textColor = cc.c3b(208, 208, 208)
        local textVisible = true
        local textEnabled = true

        if v.state == 2 then
            btnName = "已领取"
            loadTexture = "Image/UI/TaskUI/anniuhui.png"
        elseif v.state == 0 then
            loadTexture = "Image/UI/TaskUI/anniuhui.png"
        end

        local goodsList = {}
        local giftIdList = v.gift_ids

        if v.state == 2 then
            goodsList = self.__interactor:getGoodsListByGiftId(v.exchange_id)
            text2 = self.__interactor:getGoodsText(goodsList)        
        else
            if #giftIdList > 1 then
                text2 = "内含多种奖励，请点击右方按钮进入多选奖励界面，选择所需奖励进行领取"
                btnName = "进入"
                textVisible = false
                textColor = cc.c3b(255, 0, 0)
                textEnabled = false
            else
                goodsList = self.__interactor:getGoodsListByGiftId(giftIdList[1])
                text2 = self.__interactor:getGoodsText(goodsList) 
            end
        end

        local func = function()
            if v.state == 2 then
                PopText("此奖励已领取")
                return
            elseif v.state == 0 then
                if #giftIdList == 1 then
                    PopText("未达到对应的驱赶次数")
                    return
                end
            end

            if #giftIdList > 1 then
                self.__selectRewardUI:setText2(text1)
                local selectRewardUIList = {}
                for i = 1, #giftIdList do
                    local goodsList = self.__interactor:getGoodsListByGiftId(giftIdList[i])
                    local text = self.__interactor:getGoodsText(goodsList)
                    local btnName = "领取"
                    local loadTexture = "Image/UI/MapUI/anniu05.png"
                    if v.state == 0 then
                        loadTexture = "Image/UI/MapUI/anniu04.png"
                    end

                    local func = function()
                        if v.state == 0 then
                            PopText("未达到对应的驱赶次数")
                            return
                        end

                        self:__doReward(v.rid, giftIdList[i], function()
                            self.__selectRewardUI:hideUI()
                            if self.__showType == 1 then
                                self:showPersonalRewardList()
                            else
                                self:showGroupRewardList()
                            end

                            self.__actionUI:setText1Str("剩余鞭炮："..tostring(self.__interactor:getNianBeastNum()))
                        end)
                    end

                    local func1 = function()
                        self:__showGoodsInfoUI(goodsList)
                    end

                    table.insert(selectRewardUIList, {btnName = btnName, loadTexture = loadTexture, func = func, func1 = func1, text = text})
                end
                self.__selectRewardUI:showListView(selectRewardUIList)
                self.__selectRewardUI:showUI()
            else
                self:__doReward(v.rid, giftIdList[1], function()
                    self.__interactor:getActionInfo(function()
                        if self.__showType == 1 then
                            self:showPersonalRewardList()
                        else
                            self:showGroupRewardList()
                        end

                        self.__actionUI:setText1Str("剩余鞭炮："..tostring(self.__interactor:getNianBeastNum()))
                    end)
                end)
            end
        end

        local func1 = function()
            self:__showGoodsInfoUI(goodsList)
        end
        
        table.insert(uiList, {text1 = text1, text2 = text2, func = func, func1 = func1, btnName = btnName, textVisible = textVisible, textColor = textColor, textEnabled = textEnabled, enable = enable, loadTexture = loadTexture})
    end

    return uiList
end

function NianBeastPresenters:__doReward(rid, giftId, func)
    local goodsList = self.__interactor:getGoodsListByGiftId(giftId)
    local isTrue, searchInfo = self.__interactor:checkCanGetReward(goodsList)
    if isTrue == false then
        GoodsHelper:handleDuplicatePurchaseSearchInfo(
            searchInfo,
            {
                flowType = GoodsHelper.DUPLICATE_PURCHASE_FLOW_TYPE.BLOCK
            }
        )

        return
    end

    local isTrue, msg = self.__interactor:checkBagCanGetReward(goodsList)
    if isTrue == false then
        PopText(msg)
        return
    end

    self.__interactor:doReward(rid, giftId, function()
        self.__interactor:getActionInfo(function()
            if func then
                func()
            end
        end)
    end)
end

function NianBeastPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "NianBeastPresenters",
        function(layer)
            self.__actionUI:hideUI()
        end
    )
end

function NianBeastPresenters:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function NianBeastPresenters:__setRuleFunc()
	self.__actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function NianBeastPresenters:__showRule()
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

function NianBeastPresenters:__showGoodsInfoUI(goodsList)
    PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
        layer:showLayer(goodsList)
    end)
end

Helper:classDefNodeGetInstance(NianBeastPresenters)

return NianBeastPresenters

00000000000