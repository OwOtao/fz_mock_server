local class = require("third.class.NewClass")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local DrinkMorePresenters = {}

function DrinkMorePresenters:create(iNianBeastView,iNianBeastModel)
    local p = DrinkMorePresenters:new()
    p:init(iNianBeastView,iNianBeastModel)
    return p
end

function DrinkMorePresenters:init(iNianBeastView,iNianBeastModel)
    self.__input = iNianBeastModel
    self.__output = iNianBeastView

    self._selectRewardUI = require("app.views.ui.ActionUI.RewardSelectUI"):create()

    self._selectRewardUI:addTo(self.__output)

    self._selectRewardUI:hideUI()

    self._selectRewardUI:setButtonBack(
        function()
            self._selectRewardUI:hideUI()
        end
    )
end

function DrinkMorePresenters:setRole(role)
    self.__input:setRole(role)
end

function DrinkMorePresenters:showLayer()
    self:__setRuleFunc()

    self.__input:getActionInfo(function()
        self.__output:showLayer(function()
            self.__output:showUI()
            self:__initUI()
        end)
    end)
end

function DrinkMorePresenters:__initUI()
    self.__showType = 1
    self:showPersonalRewardList()

    self.__output:setTextTitle(self.__input:getActionName())
    self.__output:setTextDesc(self.__input:getActionDesc())
    self.__output:setText1Str("剩余佳酿："..tostring(self.__input:getDrinkNum()))

    self.__output:setTitle_1Name("个人进度")

    self.__output:setTitle_2Name("全体进度")
    
    self.__output:setButton_1Name("获取佳酿")

    self.__output:setButton_2Name("共饮")

    self.__output:setTitle_1Func(function()
        self:showPersonalRewardList()
        self.__showType = 1
    end)

    self.__output:setTitle_2Func(function()
        self:showGroupRewardList()
        self.__showType = 2
    end)

    self.__output:setButton_1Func(function()
        self:showAccess()
    end)

    self.__output:setButton_2Func(function()
        self:doDrink()
    end)

    self.__output:setButtonBack(function()
        self.__output:hideLayer(function()
            self.__output:hideUI()
        end)
    end)

    self.__output:setPanelDriveAwayText1("请选择共饮的方式")
    self.__output:setPanelDriveAwayText2("饮用一坛佳酿后可以随机获得以下一个奖励")
end

function DrinkMorePresenters:showAccess()
    PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("佳酿获取")
        layer:showPanel_1(self.__input:getAccess())
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

function DrinkMorePresenters:showPersonalRewardList()
    local list = self.__input:getPersonalRewardList()
    for i, v in ipairs(list) do
        v.func1 = function()
            if v.isSelect == true then
                self:__showSelectUI(v.rid, v.giftIdList, v.state)
            else
                self:__getReward(v.rid, v.giftIdList[1], self.__input:getGiftReward(v.giftIdList[1]))
            end
        end

        v.func2 = function()
            local giftId = v.giftIdList[1]

            if v.isSelect == true then
                if v.exchangeId then
                    giftId = v.exchangeId
                else
                    return
                end
            end

            local goodsList = {}
            local rewards = self.__input:getGiftReward(giftId)
            for i, reward in ipairs(rewards) do
                table.insert(goodsList, {id = reward.id})
            end

            self:__showGoodsInfoUI(goodsList)
        end
    end
    self.__output:showListView(list)
    self.__output:setTitle_1BackGroundColorOpacity(255)
    self.__output:setTitle_2BackGroundColorOpacity(0)
    self.__output:setTitle_1Visible(true)
    self.__output:setTitle_2Visible(false)
    self.__output:setTitle_1Enable(false)
    self.__output:setTitle_2Enable(true)
end

function DrinkMorePresenters:showGroupRewardList()
    local list = self.__input:getGroupRewardList()
    for i, v in ipairs(list) do
        v.func1 = function()
            if v.isSelect == true then
                self:__showSelectUI(v.rid, v.giftIdList, v.state)
            else
                self:__getReward(v.rid, v.giftIdList[1], self.__input:getGiftReward(v.giftIdList[1]))
            end
        end
        
        v.func2 = function()
            local giftId = v.giftIdList[1]

            if v.isSelect == true then
                if v.exchangeId then
                    giftId = v.exchangeId
                else
                    return
                end
            end

            local goodsList = {}
            local rewards = self.__input:getGiftReward(giftId)
            for i, reward in ipairs(rewards) do
                table.insert(goodsList, {id = reward.id})
            end

            self:__showGoodsInfoUI(goodsList)
        end
    end

    self.__output:showListView(list)
    self.__output:setTitle_1BackGroundColorOpacity(0)
    self.__output:setTitle_2BackGroundColorOpacity(255)
    self.__output:setTitle_2Visible(true)
    self.__output:setTitle_1Visible(false)
    self.__output:setTitle_2Enable(false)
    self.__output:setTitle_1Enable(true)
end

function DrinkMorePresenters:doDrink()
    if self.__input:getDrinkState() == false then
        PopText("醉仙酒饱喝足，已先行离开，少侠快去领取剩余奖励吧。")
        return
    end
    
    self.__output:setPanelDriveAwayVisible(true)
    self.__output:setPanelDriveAwayText3(self.__input:getDriveAwayInfo())
    self.__output:setPanelDriveAwayText4("（剩余佳酿："..self.__input:getDrinkNum().."个）")

    self.__output:setPanelDriveAwayFunc(function()
        self.__input:getActionInfo(function()
            self.__output:setPanelDriveAwayVisible(false)

            if self.__showType == 1 then
                self:showPersonalRewardList()
            elseif self.__showType == 2 then
                self:showGroupRewardList()
            end
        end)
    end)

    self.__output:setPanelDriveAwayButton1Name("饮用1坛佳酿")
    self.__output:setPanelDriveAwayButton1Func(function()
        if self.__input:getDrinkNum() > 0 then
            self.__input:doDrink(1,function()
                self.__output:setPanelDriveAwayText4("（剩余佳酿："..self.__input:getDrinkNum().."个）")
                self.__output:setText1Str("剩余佳酿："..tostring(self.__input:getDrinkNum()))
            end)
        else
            PopText("佳酿数量不足，可点击【获取佳酿】按钮查看佳酿获取方式")
        end
    end)

    self.__output:setPanelDriveAwayButton2Name("饮用10坛佳酿")
    self.__output:setPanelDriveAwayButton2Func(function()
        if self.__input:getDrinkNum() > 0 then
            self.__input:doDrink(10,function()
                self.__output:setPanelDriveAwayText4("（剩余佳酿："..self.__input:getDrinkNum().."个）")
                self.__output:setText1Str("剩余佳酿："..tostring(self.__input:getDrinkNum()))
            end)
        else
            PopText("佳酿数量不足，可点击【获取佳酿】按钮查看佳酿获取方式")
        end
    end)

    self.__output:setPanelDriveAwayButton3Name("饮用50坛佳酿")
    self.__output:setPanelDriveAwayButton3Func(function()
        if self.__input:getDrinkNum() > 0 then
            self.__input:doDrink(50,function()
                self.__output:setPanelDriveAwayText4("（剩余佳酿："..self.__input:getDrinkNum().."个）")
                self.__output:setText1Str("剩余佳酿："..tostring(self.__input:getDrinkNum()))
            end)
        else
            PopText("佳酿数量不足，可点击【获取佳酿】按钮查看佳酿获取方式")
        end
    end)
end

function DrinkMorePresenters:__getReward(rid, giftId, rewards, func)
    local isTrue, searchInfo = self.__input:checkCanGetReward(rewards)

    if isTrue == false then
        GoodsHelper:handleDuplicatePurchaseSearchInfo(
            searchInfo,
            {
                flowType = GoodsHelper.DUPLICATE_PURCHASE_FLOW_TYPE.BLOCK
            }
        )

        return
    end

    local isBagEnough, msg = self.__input:checkBagCanGetReward(rewards)

    if isBagEnough == false then
        PopText(msg)
        return
    end

    self.__input:doReward(rid, giftId, function()
        self.__input:getActionInfo(function()
            self.__output:setText1Str("剩余佳酿："..tostring(self.__input:getDrinkNum()))
            if self.__showType == 1 then
                self:showPersonalRewardList()
            elseif self.__showType == 2 then
                self:showGroupRewardList()
            end

            if func then
                func()
            end
        end)
    end)
end

function DrinkMorePresenters:__showSelectUI(rid, giftIdList, state)
    self._selectRewardUI:showUI()
    self._selectRewardUI:setText2("")

    local showList = {}

    for i, giftId in pairs(giftIdList) do
        local rewards = self.__input:getGiftReward(giftId)

        local item = {}
        if state == 1 then
            item.loadTexture = "Image/UI/TaskUI/anniu.png"
        else
            item.loadTexture = "Image/UI/TaskUI/anniuhui.png"
        end
        
        item.btnName = "领取"
        item.text = self.__input:getGiftRewardText(giftId)
        item.func = function()
            if state ~= 1 then
                return
            end

            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:show( "是否确认领取"..item.text.."？")
            dialog:setButton1("确定", function()
                self:__getReward(rid, giftId, rewards, function()
                    self._selectRewardUI:hideUI()
                end)
            end)
            dialog:setButton2("取消", function()
                dialog:hide()
            end)
            dialog:setWeChatVisible(false)
        end

        item.func1 = function()
            local goodsList = {}
            for i, reward in ipairs(rewards) do
                table.insert(goodsList, {id = reward.id})
            end

            self:__showGoodsInfoUI(goodsList)
        end
        table.insert(showList, item)
    end

    self._selectRewardUI:showListView(showList)
end

function DrinkMorePresenters:__showGoodsInfoUI(goodsList)
    PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
        layer:showLayer(goodsList)
    end)
end

function DrinkMorePresenters:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function DrinkMorePresenters:__setRuleFunc()
	self.__output:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function DrinkMorePresenters:__showRule()
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


return class("DrinkMorePresenters", {}, DrinkMorePresenters)

00000000