local DanQingGePresenter = class("DanQingGePresenter", cc.Layer)
local MaskResManager = require("app.models.mask.MaskResManager")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")

local dis_img_path = {
    ["0.9"] = "Image/UI/StoreUI/jiuzhe.png",
    ["0.8"] = "Image/UI/StoreUI/bazhe.png",
    ["0.6"] = "Image/UI/StoreUI/liuzhe.png",
    ["0.5"] = "Image/UI/StoreUI/wuzhe.png",
    default = "Image/UI/StoreUI/jiuzhe.png"
}

function DanQingGePresenter:create()
    local p = DanQingGePresenter:new()
    p:init()
    return p
end

function DanQingGePresenter:init()
    self._actionUI = require("app.views.ui.ActionUI.DanQingGeUI"):create()

    self._actionUI:addTo(self)

    self._selectRewardUI = require("app.views.ui.ActionUI.RewardSelectUI"):create()

    self._selectRewardUI:addTo(self)

    self._selectRewardUI:hideUI()

    self._selectRewardUI:setButtonBack(
        function()
            self._selectRewardUI:hideUI()
        end
    )

    self:__setRuleFunc()

    local DanQingGe = require("app.models.Action.DanQingGe")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self._interactor = DanQingGe:create()
end

function DanQingGePresenter:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    
    self:__initData()
end

function DanQingGePresenter:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function DanQingGePresenter:__initData()
    self._interactor:init(
        function()
            self:__initUI()

            self._actionUI:showUI()
        end
    )
end

function DanQingGePresenter:__initUI()
    self._actionUI:setTextTitle(self._interactor:getActionName())

    self._actionUI:setDesc(self._interactor:getActionDesc())

    self._actionUI:setText1("")

    local listData = self._interactor:getList()

    local uiList = {}

    for __, itemInfo in pairs(listData) do
        local text1 = itemInfo.text
        local text2 = itemInfo.buyTimes.."/"..itemInfo.totalTimes
        local text3 = "原价："..itemInfo.price..self._interactor:getCurrencyNameByCurrencyId(itemInfo.currencyId)
        local btnName = "领取"
        local enable = true
        local visible1 = self._interactor:checkRewardIsRandom(itemInfo.type)
        local visible2 = self._interactor:checkIsDiscount(itemInfo.discount)
        local texture1 = "Image/UI/TaskUI/anniu.png"
        local texture2 = dis_img_path[tostring(itemInfo.discount)]
        
        if self._interactor:checkStateIsUnlock(itemInfo.state) then
            btnName = math.ceil(itemInfo.discount * itemInfo.price)..self._interactor:getCurrencyNameByCurrencyId(itemInfo.currencyId)

            if self._interactor:checkRewardIsSelect(itemInfo.type) then
                btnName = "进入"
            end
        end

        if self._interactor:checkStateIsRewarded(itemInfo.state) then
            btnName = "已售罄"
            enable = false
            texture1 = "Image/UI/TaskUI/anniuhui.png"
        end

        local func1 = function()
            if self._interactor:checkRewardIsRandom(itemInfo.type) then
                PopupLayerController:showLayer("GiftInfoPresenter",function(layer)
                    local dsc = "凭运气能开出以下其中"..tostring(itemInfo.rewardNumber).."种奖励"
                    if itemInfo.rewardNumber > 1 then
                        if itemInfo.reduplicate == 1 then
                            dsc = dsc.. "，奖励可重复获取：\n"
                        else
                            dsc = dsc.. "，奖励不可重复获取：\n"
                        end
                    else
                        dsc = dsc.. "：\n"
                    end

                    local goodsIdList = {}
                    local goodsAddTab = {} 

                    for i = 1, #itemInfo.rewardIdPoolList do
                        local goodsList = self._interactor:getRewardById(itemInfo.rewardIdPoolList[i])

                        local str = ActionRewardsHelper:getRewardText(goodsList)
                        if #goodsList > 1 then
                            dsc = dsc .. "礼包（" .. str .."）"
                        else
                            dsc = dsc .. str
                        end
                        
                        if i < #itemInfo.rewardIdPoolList then
                            dsc = dsc .. "、"
                        end

                        for i = 1, #goodsList do
                            if not goodsAddTab[goodsList[i].id] then
                                goodsAddTab[goodsList[i].id] = true
                                table.insert(goodsIdList, goodsList[i].id)
                            end
                        end
                    end

                    local giftData = {
                        name = itemInfo.text,
                        id = 1,
                        icon = "",
                        goodsIdList = goodsIdList,
                        dsc = dsc
                    }

                    local giftClass = require("app.presenters.GiftInfo.Gift"):create(giftData)

                    layer:setGift(giftClass)

                    layer:showUI()
                end)
            elseif self._interactor:checkRewardIsSelect(itemInfo.type) == false then
                local showList = {}

                for __, rewardId in ipairs(itemInfo.rewardIdPoolList) do
                    local goodsList = self._interactor:getRewardById(rewardId)

                    table.appendArray(showList, goodsList)
                end

                PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                    layer:showLayer(showList)
                end)
            end
        end 

        local func2 = function()
            if self._interactor:checkRewardIsSelect(itemInfo.type) and self._interactor:checkStateIsUnlock(itemInfo.state) then
                self._selectRewardUI:setText2("目前拥有"..self._interactor:getCurrencyNameByCurrencyId(itemInfo.currencyId).."数量："..self._interactor:getCurrencyNumByCurrencyId(itemInfo.currencyId))
                local rewardIds = itemInfo.rewardIdPoolList
                if MapIsEmpty(rewardIds) == false then
                    local rewards = {}
                    for i = 1, #rewardIds do
                        local uiList = {}
                        local goodsList = self._interactor:getRewardById(rewardIds[i])
  
                        local text = ActionRewardsHelper:getRewardText(goodsList)
                        local loadTexture = "Image/UI/TaskUI/anniu.png"
                        local btnName = "领取"

                        if self._interactor:checkStateIsUnlock(itemInfo.state) then
                            btnName = math.ceil(itemInfo.discount * itemInfo.price)..self._interactor:getCurrencyNameByCurrencyId(itemInfo.currencyId)
                        end

                        local func = function()
                            local reward = inherit({rewardId = rewardIds[i]},itemInfo)
                            self:__doReward(reward)
                            self._selectRewardUI:hideUI()
                        end

                        local func1 = function()
                            PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                                layer:showLayer(goodsList)
                            end)
                        end 

                        table.insert(rewards, {sortId = rewardIds[i], text = text, loadTexture = loadTexture, btnName = btnName, func = func, func1 = func1})
                    end

                    table.sort(rewards, function(a, b)
                        return tonumber(a.sortId) < tonumber(b.sortId)
                    end)
                    self._selectRewardUI:showListView(rewards)
                    self._selectRewardUI:showUI()
                end
            else
                self:__doReward(itemInfo)
            end 
        end

        table.insert(uiList, {text1 = text1, text2 = text2, text3 = text3, visible1 = visible1, visible2 = visible2, btnName = btnName, enable = enable, texture1 = texture1, texture2 = texture2, func1 = func1, func2 = func2})
    end

    self._actionUI:showListView(uiList)
end

function DanQingGePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "DanQingGePresenter",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function DanQingGePresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function DanQingGePresenter:__doReward(itemInfo)
    if self._interactor:checkStateIsReward(itemInfo.state) then
        local rewards = itemInfo.reward

        if self._interactor:checkBagCanGetReward(rewards) == false then
            PopText("背包空间不足，无法领取奖励。")
            return
        end

        self._interactor:doReward(itemInfo.id,function()
            self._interactor:init(
                function()
                    self:__initUI()
                end
            )
        end)

        return
    end

    local currencyName = self._interactor:getCurrencyNameByCurrencyId(itemInfo.currencyId)
    local currencyNum = self._interactor:getCurrencyNumByCurrencyId(itemInfo.currencyId)
    local price = math.ceil(itemInfo.price * itemInfo.discount)

    if self._interactor:checkStateIsUnlock(itemInfo.state) and 
    currencyNum < price then
        PopText(currencyName.."数量不足，兑换失败")
        return
    end

    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    local text = "是否消耗"..price..currencyName.."兑换"..itemInfo.text.."?NOR\n\n".."RED当前拥有的"..currencyName.."数量："..currencyNum
    dialog:show(text)
    dialog:setRichText(text)
    dialog:setButton1("确定", function()
        local rewardList = {}

        if self._interactor:checkRewardIsRandom(itemInfo.type) then
            for i, rewardId in ipairs(itemInfo.rewardIdPoolList) do
                local goodsList = self._interactor:getRewardById(rewardId)

                table.appendArray(rewardList, goodsList)
            end
        elseif self._interactor:checkRewardIsSelect(itemInfo.type) then
            local goodsList = self._interactor:getRewardById(itemInfo.rewardId)

            table.appendArray(rewardList, goodsList)
        else
            local goodsList = self._interactor:getRewardById(itemInfo.rewardIdPoolList[1])

            table.appendArray(rewardList, goodsList)
        end
        
        local isTrue, searchInfo = self._interactor:checkCanGetReward(rewardList)

        local function exchangeReward()
            self._interactor:exchangeReward(itemInfo.id, itemInfo.rewardId, function()
                self._interactor:init(
                    function()
                        self:__initUI()
                    end
                )
            end)
        end
       
        if isTrue == false then
            GoodsHelper:handleDuplicatePurchaseSearchInfo(
            searchInfo,
            {
                flowType = GoodsHelper.DUPLICATE_PURCHASE_FLOW_TYPE.CONTINUE,
                onConfirm = function()
                    exchangeReward()
                end
            }
        )
        else
            exchangeReward()
        end
    end)

    dialog:setButton2("取消", function()
        dialog:hide()
    end)

    dialog:setWeChatVisible(false)
end


function DanQingGePresenter:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function DanQingGePresenter:__showRule()
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

Helper:classDefNodeGetInstance(DanQingGePresenter)

return DanQingGePresenter
000000000000000