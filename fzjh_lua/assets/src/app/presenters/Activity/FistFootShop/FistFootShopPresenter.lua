local FistFootShopPresenter = class("FistFootShopPresenter", cc.Layer)

local GoodsHelper = require("app.models.Store.GoodsHelper")

local FistFootShop = require("app.models.Action.FistFootShop")

function FistFootShopPresenter:create()
    local p = FistFootShopPresenter:new()
    p:init()
    return p
end

function FistFootShopPresenter:init()
    self.__ui = require("app.views.ui.ActionUI.FistFoot.FistFootShopUI"):create()

    self.__ui:addTo(self)

    self.__ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self.__interactor = FistFootShop:create()
end

function FistFootShopPresenter:showLayer()
    self.__role = User:getRole()

    self.__interactor:setRole(self.__role)

    self.__ui:setPaneltipIsVisible(false)

    self.__ui:setPaneltipFunc(function()
        self.__ui:setPaneltipIsVisible(false)
    end)

    self:__initData()    
end

function FistFootShopPresenter:setActionId(actionId)
    self.__interactor:setActionId(actionId)
end

function FistFootShopPresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function FistFootShopPresenter:__initData()
    self.__interactor:getFistFootShopInfo(
        function()
            self.__ui:setTextTitle(self.__interactor:getActionName())

            self.__ui:setTextDesc1(self.__interactor:getActionDesc())

            self:__initSpecialOfferUI()

            self:__initDayList()

            self:__setRuleFunc()

            self:__setButtonTip()

            self.__ui:showUI()
        end
    )
end

function FistFootShopPresenter:__initSpecialOfferUI()
    local discountRateStr = tostring(self.__interactor:getDiscountRate()).."%"

    self.__ui:setTextDesc3("当前特惠基数:"..discountRateStr) 

    local daySelectCost = self.__interactor:getDaySelectCost()

    local specialOfferState = self.__interactor:getSpecialOfferState()

    if specialOfferState == 0 then
        local specialOfferStartDate = self.__interactor:getSpecialOfferStartDate()

        local durationTime = math.max(specialOfferStartDate - GetTime(),0)

        local day = math.floor(durationTime/86400)
        
        local hour = math.floor(durationTime%86400/3600)
        
        local minute = math.floor(durationTime%3600/60)

        local timeStr = tostring(day).."天"..tostring(hour).."时"..tostring(minute).."分后开启特惠购买"

        self.__ui:setTextDesc2(timeStr)

        self.__ui:setTextDesc4("")

        if daySelectCost == 0 then
            self.__ui:setButton1("点击设置每日支付元宝数",function()
                self:__showSelectCostUI()
            end)
        else
            if self.__interactor:isBuyDailyItem() then
                self.__ui:setTextDesc4("已确认每日支付元宝数:"..daySelectCost)

                self.__ui:setButton1(nil)
            else
                self.__ui:setButton1("每日支付元宝数:"..daySelectCost,
                function()
                    self:__showSelectCostUI()
                end)
            end
        end
        
    elseif specialOfferState == 1 then
        self.__ui:setTextDesc2("特惠购买已开启")
        self.__ui:setTextDesc4("")
        self.__ui:setButton1("点击特惠购买",
            function()
                self:__showBuySpecialOffer()
            end
        )
    elseif specialOfferState == 2 then
        self.__ui:setButton1(nil)

        self.__ui:setTextDesc2("")

        local cost = self.__interactor:getSpecialOfferCost()

        local useDiscountRate = self.__interactor:getSpecialOfferUseDiscountRate()

        local gainList = self.__interactor:getSpecialOfferGainList()

        local text1 = "已使用"..useDiscountRate.."%特惠基数,支付"..cost.."元宝获得"
        
        local text2 = ""

        for i,v in ipairs(gainList) do
            local num = v.number

            local goodsId = v.goodsId

            local goods = GoodsHelper:getGoodsResClass(goodsId)

            local name = goods:getName()

            if i == 1 then
                text2 = name..":"..num
            else
                text2 = text2..";"..name..":"..num
            end
        end

        self.__ui:setTextDesc4(text1.."\n"..text2)
    end
end

function FistFootShopPresenter:__initDayList()
    local listData = self.__interactor:getShopDayList()

    self.__ui:removeAllItems()

    for i,v in ipairs(listData) do
        local dayId = v.id

        local panel = self.__ui:createPanelItem()

        self.__ui:addItemToList(panel)

        panel.Text_day:setString("第"..Helper:numberCast(tonumber(dayId)).."天")

        for tierId = 1,3 do
            local tierPanel = panel["Panel_"..tierId]

            local probability = v.probability[tierId]

            local numAdd = v.bonus[tierId]/100

            local isGet = self.__interactor:isGetTier(dayId,tierId)

            tierPanel.Text_1:setString(tostring(probability).."%概率" )

            tierPanel.Image_get:setVisible(isGet)

            for itemIndex = 1,2 do
                local rewardData = v.rewards[itemIndex]

                local rewardId = rewardData[1]

                local rewardQuota = rewardData[2]/100

                local name = self.__interactor:getItemName(rewardId)

                local icon = self.__interactor:getItemIcon(rewardId)
                
                local num = self.__interactor:ceilDayItemNum(rewardId,numAdd,rewardQuota)

                tierPanel["Text_item"..itemIndex]:setString(name.."*"..num)

                tierPanel["Image_"..itemIndex]:loadTexture(icon,0)
            end
        end

        panel.Image_4.Image_1:loadTexture(self.__interactor:getCostIcon(),0)

        local daySelectCost = self.__interactor:getDaySelectCost()

        if daySelectCost == 0 then
            panel.Image_4.Text_2:setString("请先设置每")

            panel.Image_4.Text_3:setString("日支付元宝")

            panel.Image_4:releaseFunc(function()
                PopText("请先设置每日支付元宝")
            end)
        else
            if self.__interactor:isBuyDailyItem() then
                local isBuyDay = self.__interactor:isBuyDay(dayId)
                
                if isBuyDay then
                    panel.Image_4.Text_2:setString("已支付")
    
                    panel.Image_4.Text_3:setString("")
    
                    panel.Image_4:releaseFunc(function()
                        PopText("已完成支付，不可重复支付")
                    end)
                else
                    panel.Image_4.Text_2:setString("点击支付")
    
                    panel.Image_4.Text_3:setString(daySelectCost.."元宝")
    
                    panel.Image_4:releaseFunc(function()
                        self:__showBuyDayNotFirst(dayId)
                    end)
                end
            else
                panel.Image_4.Text_2:setString("点击支付")
    
                panel.Image_4.Text_3:setString(daySelectCost.."元宝")

                panel.Image_4:releaseFunc(function()
                    self:__showBuyDayFirst(dayId)
                end)
            end
        end
    end
end

function FistFootShopPresenter:__showSelectCostUI()
    PopupLayerController:showLayer("FistFootShopDayPaySelectPresenter",function(layer)
        layer:setInteractor(self.__interactor)
        layer:setCallBack(function()
            self:__initSpecialOfferUI()

            self:__initDayList()
        end)
        layer:showLayer()
    end)
end

function FistFootShopPresenter:__showBuySpecialOffer()
    PopupLayerController:showLayer("FistFootShopBuySpecialOfferPresenter",function(layer)
        layer:setInteractor(self.__interactor)
        layer:setCallBack(function()
            self:__initSpecialOfferUI()

            self:__initDayList()
        end)
        layer:showLayer()
    end)
end

function FistFootShopPresenter:__showBuyDayFirst(dayId)
    PopupLayerController:showLayer("FistFootShopBuyDayConfirmPresenter",function(layer)
        local daySelectCost = self.__interactor:getDaySelectCost() 

        local specialOfferCostMaxLimit = daySelectCost * self.__interactor:getDayCostMultiple()

        layer:setDayId(dayId)

        layer:setInteractor(self.__interactor)
        
        layer:setText1("是否确认支付"..tostring(daySelectCost).."元宝")

        layer:setText2("特惠购买支付上限为"..tostring(specialOfferCostMaxLimit).."元宝")

        layer:setText3("")

        layer:setTextTip1("")

        layer:setTextTip2(self:__getTextSpecialOfferTip())

        layer:setTextTip3("注意:一经确认，本期活动不可修改")

        layer:setCallBack(function()
            self:__initSpecialOfferUI()

            self:__initDayList()
        end)
        
        layer:showLayer()
    end)
end

function FistFootShopPresenter:__showBuyDayNotFirst(dayId)
    PopupLayerController:showLayer("FistFootShopBuyDayConfirmPresenter",function(layer)
        local daySelectCost = self.__interactor:getDaySelectCost() 

        local buyNum = self.__interactor:buyDailyNum()

        local nextDiscountRate = self.__interactor:getDiscountByDayId(buyNum + 1)

        layer:setDayId(dayId)

        layer:setInteractor(self.__interactor)
        
        layer:setText1("是否确认支付"..tostring(daySelectCost).."元宝")

        layer:setText2("当前已累计支付"..buyNum.."天,获得特惠基数:"..tostring(self.__interactor:getDiscountRate()).."%")

        layer:setText3("完成本次支付,可获得特惠基数:"..nextDiscountRate.."%")

        local rewardText1 = "可获得:"..self:getTextSpecialOfferReward(1,nextDiscountRate)

        local rewardText2 = self:getTextSpecialOfferReward(2,nextDiscountRate)

        local tipText = "提示：以当前的每日支付元宝数，完成本次支付获得"..nextDiscountRate.."%特惠基数，通过特惠购买，最高可获得"..rewardText1..";"..rewardText2

        layer:setTextTip1(tipText)

        layer:setTextTip2("")

        layer:setTextTip3("")

        layer:setCallBack(function()
            self:__initSpecialOfferUI()

            self:__initDayList()
        end)
        
        layer:showLayer()
    end)
end

function FistFootShopPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "FistFootShopPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

function FistFootShopPresenter:__setButtonTip()
	self.__ui:setButtonTip(function()
        local daySelectCost = self.__interactor:getDaySelectCost()

        if daySelectCost == 0 then
            PopText("请先设置每日支付元宝")
            return
        end

        self.__ui:setPaneltipTextDesc(self:__getTextSpecialOfferTip())

        self.__ui:setPaneltipIsVisible(true)
    end)
end


function FistFootShopPresenter:__setRuleFunc()
	self.__ui:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function FistFootShopPresenter:__showRule()
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

function FistFootShopPresenter:getTextSpecialOfferReward(itemIndex,discountRate)
    local daySelectCost = self.__interactor:getDaySelectCost() 

    local specialOfferCostMaxLimit = daySelectCost * self.__interactor:getDayCostMultiple()
    
    local rewards = self.__interactor:getSpecialOfferRewards()

    local rewardId = rewards[itemIndex][1]

    local rewardQuota = rewards[itemIndex][2]/100

    local name = self.__interactor:getItemName(rewardId)

    discountRate = discountRate/100

    local num = self.__interactor:ceilSpecialOfferItemNum(rewardId,discountRate,specialOfferCostMaxLimit,rewardQuota)

    return name.."*"..num
end

function FistFootShopPresenter:__getTextSpecialOfferTip()
    local daySelectCost = self.__interactor:getDaySelectCost() 

    local specialOfferCostMaxLimit = daySelectCost * self.__interactor:getDayCostMultiple()

    local text = "提示:\n当前特惠购买可支付上限为"..specialOfferCostMaxLimit.."元宝，则在不同的特惠基数下，支付该数值元宝，可获得的道具数如下:"

    for i = 1,7 do
        local discount = self.__interactor:getDiscountByDayId(i)

        local rewardText1 = self:getTextSpecialOfferReward(1,discount)

        local rewardText2 = self:getTextSpecialOfferReward(2,discount)

        text = text.."\n"..i..".特惠基数:"..discount.."%,"..rewardText1..","..rewardText2
    end

    return text
end


Helper:classDefNodeGetInstance(FistFootShopPresenter)

return FistFootShopPresenter
000000000