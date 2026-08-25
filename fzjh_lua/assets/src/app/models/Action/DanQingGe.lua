local class = require("third.class.NewClass")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")
local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")
local CurrencyUtil = require("app.models.Currency.CurrencyUtil")

local DanQingGe = {}

-- 状态，0：未解锁，1：可领取，2：已领取
local RewardState = {
    NotReward = 0,
    Reward = 1,
    AfterReward = 2,
}

local RewardSort = {
    [RewardState.NotReward] = 1,
    [RewardState.Reward] = 1,
    [RewardState.AfterReward] = 2,
}

function DanQingGe:create()
    return DanQingGe:new()
end

function DanQingGe:ctor()
    self._actionId = 0

    self._name = ""

    self._desc = ""

    self._rewardList = {}

    self._currencyList = {}
end

function DanQingGe:setRole(role)
    self._role = role
end

function DanQingGe:setActionId(actionId)
    self._actionId = actionId
end

function DanQingGe:init(callback)
    local currencyVersion = self._role:getCurrencyVersion()
    HttpManagerEx:getDanQingPavilionInfo(self._actionId, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._name = data.act_name

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self._desc = desc

            self._currencyList = data.currencyList

            self:__dealWithList(data.list)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function DanQingGe:getActionName()
    return self._name
end

function DanQingGe:getActionDesc()
    return self._desc
end

function DanQingGe:getCurrencyNameByCurrencyId(currencyId)
    return CurrencyUtil:getCurrencyName(currencyId)
end

function DanQingGe:getCurrencyNumByCurrencyId(currencyId)
    for k, v in ipairs(self._currencyList) do
        if v.id == currencyId then
            return v.num
        end
    end
end

function DanQingGe:getList()
    return self._list
end

function DanQingGe:exchangeReward(id, rewardId, callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local currencyVersion = self._role:getCurrencyVersion()
    HttpManagerEx:exchangeDanQingPavilionItem(self._actionId, id, rewardId, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            if data.msg then
                PopText(data.msg)
            end

            if data.currencyVersion then
                self._role:setCurrencyVersion(data.currencyVersion)
            end

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function DanQingGe:doReward(rewardId, callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local currencyVersion = self._role:getCurrencyVersion()
    HttpManagerEx:getDanQingPavilionReward(self._actionId, rewardId, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            GoodsHelper:fromNetworkGrantGoods(self._role,GrantGoodRequest:create({goodsList = data.rewards, dataVersion = data.dataVer, currencyVersion = data.currencyVersion, yashiExpiredTime = data.yashi_expired_time}))

            ActionRewardsHelper:printGetRewardsText(data.rewards)

            if data.msg then
                PopText(data.msg)
            end

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function DanQingGe:getRewardById(id)
    if self._rewardList then
        return self._rewardList[id]
    end
end

function DanQingGe:checkRewardIsSelect(type)
    return type == 2
end

function DanQingGe:checkRewardIsRandom(type)
    return type == 3
end

function DanQingGe:checkIsDiscount(discount)
    return discount < 1
end

function DanQingGe:checkStateIsReward(state)
    return state == RewardState.Reward
end

function DanQingGe:checkStateIsUnlock(state)
    return state == RewardState.NotReward
end

function DanQingGe:checkStateIsRewarded(state)
    return state == RewardState.AfterReward
end

function DanQingGe:checkCanGetReward(rewards)
    local isDuplicate, searchInfo = GoodsHelper:checkDuplicatePurchaseList(self._role, rewards)

    return not isDuplicate, searchInfo
end

function DanQingGe:checkBagCanGetReward(rewards)
    local isTrue, msg = ActionRewardsHelper:checkBagCanGetRewards(rewards, self._role)
    return isTrue, msg
end

function DanQingGe:__dealWithList(rewardInfo)
    local info = {}

    if MapIsEmpty(rewardInfo) == false then
        for k,v in pairs(rewardInfo) do
            if MapIsEmpty(v) == false then
                local _info = {}
                _info.text = v.text
                _info.state = v.state
                _info.type = v.rewardType
                _info.id = v.id
                _info.price = v.price
                _info.currencyId = v.currencyId
                _info.discount = v.discount
                _info.buyTimes = v.buyTimes
                _info.totalTimes = v.totalTimes
                _info.reward = v.reward
                _info.rewardNumber = v.rewardNumber
                _info.reduplicate = v.reduplicate
                _info.rewardIdPoolList = {}
                
                for rewardId, rewards in pairs(v.showList) do
                    local showList = {}

                    for __k, __v in pairs(rewards) do
                        table.insert(showList, __v)
                    end

                    table.insert(_info.rewardIdPoolList, rewardId)
                    self._rewardList[tostring(rewardId)] = showList
                end

                table.insert(info,_info)
            end
        end
    end

    table.sort(info,function(a,b)
        if RewardSort[a.state] < RewardSort[b.state] then
            return true
        elseif RewardSort[a.state] == RewardSort[b.state] then
            return a.id < b.id
        else
            return false
        end
    end)

    self._list = info
end

return class("DanQingGe", {}, DanQingGe)
000000000