local class = require("third.class.NewClass")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local LimitedTimeExperiencePresenters = {}

function LimitedTimeExperiencePresenters:create(iNianBeastView,iNianBeastModel)
    local p = LimitedTimeExperiencePresenters:new()
    p:init(iNianBeastView,iNianBeastModel)
    return p
end

function LimitedTimeExperiencePresenters:init(iNianBeastView,iNianBeastModel)
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

function LimitedTimeExperiencePresenters:setRole(role)
    self.__input:setRole(role)
end

function LimitedTimeExperiencePresenters:setActionId(actionId)
    self.__input:setActionId(actionId)
end

function LimitedTimeExperiencePresenters:showLayer()
    self.__input:getActionInfo(function()
        self.__output:showLayer(function()
            self.__output:showUI()
            self:__initUI()
        end)
    end)

    self.__startTime = GetTime()

    self:__setRuleFunc()

    self:__update()
end

function LimitedTimeExperiencePresenters:__initUI()
    self.__output:setTextDesc(self.__input:getActionDesc())
    self.__output:setTextTitle(self.__input:getActionName())
    self.__output:setTextStr(1,"当前历练分："..tostring(self.__input:getScore()).."分")
    self.__output:setTextStr(2,tostring(self.__input:getRefreshCost()).."元宝刷新任务")
    self.__output:setTextStr(3,"今日已完成任务："..tostring(self.__input:getFinishTaskCount()).."/"..tostring(self.__input:getTotalTaskCount()).."次")
    self.__output:setHongDianVisible(self.__input:getRewardState())
    self.__output:setButton_1Name("刷新")

    self:__showTaskList()
    self.__showList = 1

    self.__output:setTitle_1Func(function()
        self:__showTaskList()
        self.__showList = 1
    end)

    self.__output:setTitle_2Func(function()
        self:__showRewardList()
        self.__showList = 2
    end)

    self.__output:setButton_1Func(function()
        self:__refreshFunc()
    end)

    self.__output:setButtonBack(function()
        self.__output:hideLayer(function()
            self.__output:hideUI()
        end)
    end)
end

function LimitedTimeExperiencePresenters:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function LimitedTimeExperiencePresenters:__showTaskList()
    self.__output:showPanelItem_1List(self.__input:getTaskInfo())
    self.__output:setTitle_1BackGroundColorOpacity(255)
    self.__output:setTitle_2BackGroundColorOpacity(0)
    self.__output:setTitle_1Visible(true)
    self.__output:setTitle_2Visible(false)
    self.__output:setTitle_1Enable(false)
    self.__output:setTitle_2Enable(true)
    self.__output:setTextVisible(3,true)
    self.__output:setTextVisible(4,true)
end

function LimitedTimeExperiencePresenters:__showRewardList()
    local list = self.__input:getRewardList()
    local uiList = {}
    for i, v in ipairs(list) do
        local info = {}

        info.text1 = v.grade.."积分"

        local isShowSelectReward = false

        local rewardIds = v.rewardIds

        if v.state == 2 then
            info.loadTexture = "Image/UI/TaskUI/anniuhui.png"
            info.btnName = "已领取"
            info.text2 = self.__input:getRewardText(v.exchangeId)
        else
            info.loadTexture = "Image/UI/TaskUI/anniu.png"
            info.btnName = "领取"

            if #rewardIds > 1 then
                isShowSelectReward = true
                info.text2 = "内含多种组合奖励，请点击右方按钮进入多选奖励界面，选择所需奖励"
                info.btnName = "进入"
            else
                info.text2 = self.__input:getRewardText(rewardIds[1])
            end
        end

        info.func = function()
            if v.state == 2 then
                PopText("此奖励已领取")
                return
            end

            if isShowSelectReward == false then
                self:__doReward(v.rid, rewardIds[1], function()
                    self.__input:getActionInfo(function()
                        self:__showRewardList()
                        self.__output:setHongDianVisible(self.__input:getRewardState())
                    end)
                end)
            else
                self:__showSelectUI(v.rid, rewardIds, v.state)
            end
        end

        info.func1 = function()
            local giftId = v.exchangeId

            if giftId then
                PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                    layer:showLayer(self.__input:getReward(giftId))
                end)
            else
                if isShowSelectReward == false then
                    PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                        layer:showLayer(self.__input:getReward(rewardIds[1]))
                    end)        
                end
            end
        end

        table.insert(uiList, info)
    end

    self.__output:showPanelItemList(uiList)
    self.__output:setTitle_1BackGroundColorOpacity(0)
    self.__output:setTitle_2BackGroundColorOpacity(255)
    self.__output:setTitle_2Visible(true)
    self.__output:setTitle_1Visible(false)
    self.__output:setTitle_2Enable(false)
    self.__output:setTitle_1Enable(true)
    self.__output:setTextVisible(3,false)
    self.__output:setTextVisible(4,false)
end

function LimitedTimeExperiencePresenters:__showSelectUI(rid, giftIdList, state)
    self._selectRewardUI:showUI()
    self._selectRewardUI:setText2("")

    local showList = {}

    for i, giftId in pairs(giftIdList) do
        local item = {}

        if state == 2 then
            item.loadTexture = "Image/UI/TaskUI/anniuhui.png"
            item.btnName = "已领取"
        else
            item.loadTexture = "Image/UI/TaskUI/anniu.png"
            item.btnName = "领取"
        end
        
        item.text = self.__input:getRewardText(giftId)
        
        item.func = function()
            if state == 0 then
                PopText("历练分不足，不可领取")
                return
            end

            if state == 2 then
                PopText("此奖励已领取")
                return
            end

            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:show( "是否确认领取"..item.text.."？")
            dialog:setButton1("确定", function()
                self:__doReward(rid, giftId, function() 
                    self._selectRewardUI:hideUI()
                    self.__input:getActionInfo(function()
                        self:__showRewardList()
                        self.__output:setHongDianVisible(self.__input:getRewardState())
                    end)
                end)
            end)
            dialog:setButton2("取消", function()
                dialog:hide()
            end)
            dialog:setWeChatVisible(false)
        end

        item.func1 = function()
            PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                layer:showLayer(self.__input:getReward(giftId))
            end)
        end

        table.insert(showList, item)
    end

    self._selectRewardUI:showListView(showList)
end

function LimitedTimeExperiencePresenters:__doReward(rid, giftId, func)
    local isTrue, searchInfo = self.__input:checkCanGetReward(self.__input:getReward(giftId))

    if isTrue == false then
        GoodsHelper:handleDuplicatePurchaseSearchInfo(
            searchInfo,
            {
                flowType = GoodsHelper.DUPLICATE_PURCHASE_FLOW_TYPE.BLOCK
            }
        )

        return
    end

    local isTrue, msg = self.__input:checkBagCanGetReward(self.__input:getReward(giftId)) 
    local isEmail = 0
    if isTrue == false then
        isEmail = 1
    end

    self.__input:doReward(rid, giftId, isEmail, function()
        if func then
            func()
        end
    end)
end

function LimitedTimeExperiencePresenters:__refreshFunc()
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show("是否花费100元宝刷新任务")
    dialog:setBack(false)
    dialog:setWeChatVisible(false)
    dialog:setButton2("取消", EMPTY_FUNC)
    dialog:setButton1(
        "确定",
        function()
            self.__input:refresh(function()
                if self.__showList == 1 then
                    self:__showTaskList()
                else
                    self:__showRewardList()
                end

                self.__output:setTextStr(1,"当前历练分："..tostring(self.__input:getScore()).."分")
                self.__output:setTextStr(3,"今日已完成任务："..tostring(self.__input:getFinishTaskCount()).."/"..tostring(self.__input:getTotalTaskCount()).."次")

                PopText("元宝-"..tostring(self.__input:getRefreshCost()).."，刷新任务成功。")
            end)
        end
    )
end

function LimitedTimeExperiencePresenters:__setRuleFunc()
	self.__output:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function LimitedTimeExperiencePresenters:__showRule()
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

function LimitedTimeExperiencePresenters:__update()
    self.__output:schedule(function()
        if Helper:diffWithDate(self.__startTime,GetTime()) > 0 then
			self.__startTime = GetTime()
            self.__input:getActionInfo(function()
                self:__initUI()
            end)
		end
    end,0.5)
end

return class("LimitedTimeExperiencePresenters", {}, LimitedTimeExperiencePresenters)

000000000000