local MakeMaskSecretGiftPresenter = class("MakeMaskSecretGiftPresenter", cc.Layer)

local GoodsHelper = require("app.models.Store.GoodsHelper")

local MaskConst = require("app.models.mask.MaskConst")

function MakeMaskSecretGiftPresenter:create()
    local p = MakeMaskSecretGiftPresenter:new()
    p:init()
    return p
end

function MakeMaskSecretGiftPresenter:init()
    self.__ui = require("app.views.ui.ActionUI.MakeMaskSecretGiftUI"):create()

    self.__ui:addTo(self)

    self.__ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self:__setRuleFunc()
end

function MakeMaskSecretGiftPresenter:showLayer()
    self.__role = User:getRole()

    self.__maskSystem = self.__role:getMaskSystem()

    self.__maskSystem:getPayMakeMaskGiftInfo(function(isResult,msg)
        if isResult then
            self:__setTextTitle()
            
            self:__setTextDesc()

            self:__showList()

            self.__ui:showUI()
        else
            PopText(msg)
        end
    end)
end

function MakeMaskSecretGiftPresenter:__setTextTitle()
    self.__ui:setTextTitle(self.__maskSystem:getMakeMaskActivityName())
end

function MakeMaskSecretGiftPresenter:__setTextDesc()
    self.__ui:setTextDesc(self.__maskSystem:getMakeMaskActivityDesc())
end

function MakeMaskSecretGiftPresenter:__showList()
    local giftList = self.__maskSystem:getMakeMaskActivityGiftList()
    
    self.__ui:removeListViewAllItems()

    for i,giftData in ipairs(giftList) do
        local giftItem = self.__ui:createListViewItem()

        self.__ui:addItemToListView(giftItem)

        local giftId = giftData.id
        
        local state = giftData.state

        local nextReceiveTime = giftData.nextReceiveTime

        local syntheticMask = self.__maskSystem:getSpecialSyntheticMask(giftId)

        local goodsId = syntheticMask:getGoodsId()

        local goods = GoodsHelper:getGoodsResClass(goodsId)
        
        local beginTime = syntheticMask:getBegintime()

        local finishTime = syntheticMask:getFinishtime()

        local rewards = syntheticMask:getRewards()
        
        local durationTime = syntheticMask:getRewardsdays()

        local rewardLimit = syntheticMask:getRewardLimit()

        local rewardText = ""

        for i,reward in ipairs(rewards) do
            local rewardId = reward[1]

            local rewardNum= reward[2]

            local rewardName = GoodsHelper:getGoodsResClass(rewardId):getName()

            local oneRewardText = rewardName.."*"..rewardNum

            if rewardText == "" then
                rewardText = oneRewardText
            else
                rewardText = rewardText.."、"..oneRewardText
            end
        end
        
        local text1 = "赠礼发放时间:"
        
        local text2 = self:__getTimeTextStr(beginTime).."0时~"..self:__getTimeTextStr(finishTime).."0时"

        local text3 = "发放时间内,可领取"..rewardText..",每次领取,"..durationTime.."天以后可再次领取,最多可领取"..rewardLimit.."次"

        local text4 = ""

        local buttonEnabled = false

        local buttonName = ""

        local buttonFunc = EMPTY_FUNC

        if state == MaskConst.MakeMaskGiftState.UnOpenTime then
            buttonEnabled = false

            buttonName = "未到领取时间"
        elseif state == MaskConst.MakeMaskGiftState.UnMake then
            buttonEnabled = false

            buttonName = "面具未制作"
        elseif state == MaskConst.MakeMaskGiftState.Received then
            buttonEnabled = false

            buttonName = "未到领取时间"

            if nextReceiveTime then
                local dateTime = os.date("*t",nextReceiveTime)

                text4 = "下一次可领取时间："..dateTime.year.."年"..dateTime.month.."月"..dateTime.day.."日"..dateTime.hour.."时"
            end
        elseif state == MaskConst.MakeMaskGiftState.CanReceive then
            buttonEnabled = true

            buttonName = "点击领取"

            buttonFunc = function()
                self:receivePayMaskGift(giftId)
            end
        elseif state == MaskConst.MakeMaskGiftState.AllReceive then
            buttonEnabled = false

            buttonName = "已全部领取"
        end

        giftItem.Text_1:setString(goods:getName())

        giftItem.Text_2:setString(text1.."\n"..text2.."\n"..text3.."\n"..text4)

        giftItem.Button_1:setEnabled(buttonEnabled)

        giftItem.Button_1.Text_buttonName:setString(buttonName)

        giftItem.Button_1:releaseFunc(function()
            buttonFunc()
        end)

        giftItem:releaseFunc(function()
            PopupLayerController:showLayer(
                "MaskInfoPresenter",
                function(layer)
                    layer:showLayer(goods:getItemId())
                end
            )
        end)
    end
end

function MakeMaskSecretGiftPresenter:__getTimeTextStr(timeStr)
    local year = string.sub(timeStr, 1, 4)

    local month = string.sub(timeStr, 5, 6)
    
    local day = string.sub(timeStr, 7, 8)
	
    return string.format("%d年%d月%d日", year, month, day)
end

function MakeMaskSecretGiftPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "MakeMaskSecretGiftPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

function MakeMaskSecretGiftPresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function MakeMaskSecretGiftPresenter:__setRuleFunc()
	self.__ui:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function MakeMaskSecretGiftPresenter:__showRule()
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

function MakeMaskSecretGiftPresenter:receivePayMaskGift(id)
    self.__maskSystem:receivePayMaskGift(id,function(isRsult,params)
        if isRsult == true then
            self:__showList()

            local goodsList = params.goodsList

            if MapIsEmpty(goodsList) == false then
                for i,v in ipairs(goodsList) do
                    PopText("获得"..GoodsHelper:getGoodsResClass(v.id):getName().."X"..tostring(v.num))
                end
            end
        end

        if params.msg then
            PopText(params.msg)
        end
    end)
end

Helper:classDefNodeGetInstance(MakeMaskSecretGiftPresenter)

return MakeMaskSecretGiftPresenter
0000