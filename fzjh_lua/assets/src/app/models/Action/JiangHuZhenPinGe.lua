local class = require("third.class.NewClass")

local JiangHuZhenPinGe = {}
local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")
local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

function JiangHuZhenPinGe:create()
    return JiangHuZhenPinGe:new()
end

function JiangHuZhenPinGe:ctor()
    self.__actionId = 0

    self.__name = ""

    self.__desc = ""

    self.__lotteryList = {}

    self.__buttonInfos = {}
end

function JiangHuZhenPinGe:setRole(role)
    self._role = role
end

function JiangHuZhenPinGe:init(callback)
    HttpManagerEx:getZhenPinGeLotteryList(self.__actionId,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    self.__name = data.act_name

                    local desc = ""

                    desc = desc .. data.detail_time .. "\n"

                    if MapIsEmpty(data.detail_desc) == false then
                        for i, v in ipairs(data.detail_desc) do
                            desc = desc .. v .. "\n"
                        end
                    end

                    self.__endTime = data.end_time

                    self.__desc = desc

                    self.__lotteryList = data.lottery_list

                    self.__exchangeCurrencyId = data.exchange_currency.id

                    self.__exchangeCurrencyName = data.exchange_currency.name

                    self.__exchangeCurrencyCount = data.exchange_currency.count

                    self.__currencyId = data.currency.id

                    self.__currencyName = data.currency.name

                    self.__currencyCount = data.currency.count

                    self.__buyGoodId = data.buy_good.id

                    self.__buyGoodItemId = data.buy_good.itemId

                    self.__buyGoodName = data.buy_good.name

                    self.__buttonInfos = data.button

                    self.__act_times = data.act_times

                    self.__exchageRewardList = self:__initExchangeList(data.exchange_list)

                    self.__rewardCurrTimes = data.lottery_times

                    self.__rewardTotalTimes = data.breakevenNum

                    callback()
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function JiangHuZhenPinGe:__initExchangeList(list)
    for i, v in ipairs(list) do
        local goods = GoodsHelper:getGoodsResClass(v.goodsId)
        v.icon = goods:getIcon()
        v.showView = goods:getViewType() ~= 0
    end
    
    table.sort(
        list,
        function(a, b)
            if a.id < b.id then
                return true
            end

            return false
        end
    )

    return list
end

function JiangHuZhenPinGe:setActionId(actionId)
    self.__actionId = actionId
end

function JiangHuZhenPinGe:getActionName()
    return self.__name
end

function JiangHuZhenPinGe:getActionDesc()
    return self.__desc
end

function JiangHuZhenPinGe:getActionEndTime()
    return self.__endTime
end

function JiangHuZhenPinGe:getExchageRewardList()
    return self.__exchageRewardList
end

function JiangHuZhenPinGe:getShowRewards()
    local list = {}

    if MapIsEmpty(self.__lotteryList) == false then
        for i, v in ipairs(self.__lotteryList) do
            if #list == 4 then
                break
            end

            local info = {
                id = v.id,
                num = v.num,
            }

            if v.showType == 1 then
                table.insert(list, info)
            end
        end
    end

    return list
end

function JiangHuZhenPinGe:getExchangeCurrencyId()
    return self.__exchangeCurrencyId
end

function JiangHuZhenPinGe:getExchangeCurrencyName()
    return self.__exchangeCurrencyName
end

function JiangHuZhenPinGe:getExchangeCurrencyCount()
    return self.__exchangeCurrencyCount
end

function JiangHuZhenPinGe:setExchangeCurrencyCount(value)
    self.__exchangeCurrencyCount = value
end

function JiangHuZhenPinGe:getCurrencyId()
    return self.__currencyId
end

function JiangHuZhenPinGe:getCurrecnyName()
    return self.__currencyName
end

function JiangHuZhenPinGe:getCurrencyCount()
    return self.__currencyCount
end

function JiangHuZhenPinGe:setCurrencyCount(value)
    self.__currencyCount = value

    if self:getCurrecnyName() == "yuanbao" then
        self._role:setAttr("yuanbao", self.__currencyCount)
    end
end

function JiangHuZhenPinGe:getBuyGoodId()
    return self.__buyGoodId
end

function JiangHuZhenPinGe:getBuyGoodItemId()
    return self.__buyGoodItemId
end

function JiangHuZhenPinGe:getButtonInfo()
    return self.__buttonInfos
end

function JiangHuZhenPinGe:getExchangeRewardInfo(index)
    return self.__exchageRewardList[index]
end

function JiangHuZhenPinGe:setCurrRewardTimes(rewardCurrTimes)
    self.__rewardCurrTimes = rewardCurrTimes
end

function JiangHuZhenPinGe:getCurrRewardTimes()
    return self.__rewardCurrTimes
end

function JiangHuZhenPinGe:getTotalRewardTimes()
    return self.__rewardTotalTimes
end

function JiangHuZhenPinGe:doLottery(index, callback)
    local btnInfo = self.__buttonInfos[index]

    if self:getCurrencyCount() < btnInfo.removeCurrency then
        --@desc 抽奖消耗的数量不足
        return callback(2)
    end

    local role_weight = self._role:getAttr("weight")

    if role_weight - #self._role:getItems() < btnInfo.times then
        PopText("您的背包不足" .. btnInfo.times .. "格，请先清理背包。")
        return
    end

    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local currencyVersion = self._role:getCurrencyVersion()

    HttpManagerEx:doZhenPinGeLottery(self.__actionId,
        btnInfo.times, dataVer, currencyVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if MapIsEmpty(data.prize) == false then
                        GoodsHelper:fromNetworkGrantGoods(self._role,GrantGoodRequest:create({goodsList = data.prize, dataVersion = data.dataVer, currencyVersion = data.currencyVersion}))

                        ActionRewardsHelper:printGetRewardsText(data.prize)
                    end

                    self:setExchangeCurrencyCount(data.exchange_currency)

                    self:setCurrencyCount(data.currency)

                    self:setCurrRewardTimes(data.lottery_times)

                    callback(1, data)
                elseif errcode == 3 then
                    callback(2)
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function JiangHuZhenPinGe:exchangeItem(reward, exchangeNum, successCallback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local currencyVersion = self._role:getCurrencyVersion()
    HttpManagerEx:exchangeZhenPinGeGoods(
        self.__actionId, reward.id, exchangeNum, dataVer, currencyVersion,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    local goodsList = {}

                    local rewardInfo = data.reward

                    table.insert(goodsList, rewardInfo)

                    GoodsHelper:fromNetworkGrantGoods(self._role,GrantGoodRequest:create({goodsList = goodsList, dataVersion = data.dataVer, currencyVersion = data.currencyVersion}))

                    if data.msg then
                        PopText(data.msg)
                    end

                    reward.exchangeCount = Helper:getRange(reward.exchangeCount - exchangeNum, 0)

                    self:setExchangeCurrencyCount(data.exchangeCurrencyCount)

                    if successCallback then
                        local goods = GoodsHelper:getGoodsResClass(rewardInfo.id)
                        local info = {
                            need = reward.need * exchangeNum,
                            thankText = reward.thankText,
                            name = goods:getName(),
                            number = rewardInfo.num
                        }
                        successCallback(info)
                    end
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function JiangHuZhenPinGe:checkCanBuy(rewards)
    return ActionRewardsHelper:checkRewardsCanBuy(rewards, self._role)
end

function JiangHuZhenPinGe:checkCanGetReward(rewards)
    return ActionRewardsHelper:checkBagCanGetRewards(rewards, self._role)
end

return class("JiangHuZhenPinGe", {}, JiangHuZhenPinGe)
0000000000