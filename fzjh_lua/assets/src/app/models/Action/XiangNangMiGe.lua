local class = require("third.class.NewClass")

local GoodsHelper = require("app.models.Store.GoodsHelper")

local XiangNangMiGe = {}

-- 状态，0：可领取，1：解锁，2：已领取
local RewardState = {
    NotReward = 1,
    Reward = 0,
    AfterReward = 2,
}

local RewardLevelType = {
    ONE_REWARD_TYPE = 1,
    SELECT_REWARD_TYPE = 2
}

function XiangNangMiGe:create()
    return XiangNangMiGe:new()
end

function XiangNangMiGe:ctor()
    self._actionId = 0

    self._name = ""

    self._desc = ""

    self._rewardLevelList = {}

    self._rewardList = {}
end

function XiangNangMiGe:setRole(role)
    self._role = role
end

function XiangNangMiGe:setActionId(actionId)
    self._actionId = actionId
end

function XiangNangMiGe:init(callback)
    HttpManagerEx:getSachetAtticNewList(self._actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._name = data.name

            self._desc = data.detail_desc

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self._desc = desc

            self._currencyName = data.currency_name

            self._currencyNum = data.currency_number

            self._helpText = data.help_text

            self:__dealWithRewardLevelInfo(data.exchange_list)

            self:__dealWithRewardInfo(data.rewards)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function XiangNangMiGe:getActionName()
    return self._name
end

function XiangNangMiGe:getActionDesc()
    return self._desc
end

function XiangNangMiGe:getCurrencyName()
    return self._currencyName
end

function XiangNangMiGe:getCurrencyNum()
    return self._currencyNum
end

function XiangNangMiGe:getRewardLevelList()
    return self._rewardLevelList
end

function XiangNangMiGe:getRewardList()
    return self._rewardList
end

function XiangNangMiGe:getHelpText()
    return self._helpText
end

function XiangNangMiGe:doReward(rewardId, isEmail, callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local currencyVersion = self._role:getCurrencyVersion()
    HttpManagerEx:exchangeAwardToSachetNew(self._actionId, rewardId, isEmail, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

            GoodsHelper:fromNetworkGrantGoods(self._role,GrantGoodRequest:create({goodsList = data.rewards,dataVersion = data.dataVer,yashiExpiredTime = data.yashi_expired_time, currencyVersion = data.currencyVersion}))

            local rewardList = data.rewards

            if MapIsEmpty(rewardList) == false then
                for i,v in ipairs(rewardList) do
                    local goods = GoodsHelper:getGoodsResClass(v.id)

                    PopText("获得"..goods:getName().."X"..tostring(v.num))
                end
            end

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

function XiangNangMiGe:getRewardById(id)
    if self._rewardList then
        for k,reward in ipairs(self._rewardList) do
            if reward.id == id then
                return reward
            end
        end
    end
end

function XiangNangMiGe:checkStateIsReward(state)
    return state == RewardState.Reward
end

function XiangNangMiGe:checkStateIsUnlock(state)
    return state == RewardState.NotReward
end

function XiangNangMiGe:checkStateIsRewarded(state)
    return state == RewardState.AfterReward
end

function XiangNangMiGe:checkRewardLevelIsSelect(rewardLevelType)
    return rewardLevelType == RewardLevelType.SELECT_REWARD_TYPE
end

function XiangNangMiGe:checkCurrencyIsEnough(price)
    return self._currencyNum >= price
end

-- true 代表背包满
function XiangNangMiGe:checkBagIsEnough(rewards)
    return not GoodsHelper:checkRoleBagGoods(self._role, rewards)
end

function XiangNangMiGe:checkCanBuy(rewards)
    local isDuplicate, searchInfo = GoodsHelper:checkDuplicatePurchaseList(self._role, rewards)

    return not isDuplicate, searchInfo
end

function XiangNangMiGe:__dealWithRewardLevelInfo(rewardInfo)
    local info = {}

    if MapIsEmpty(rewardInfo) == false then
        for k,v in pairs(rewardInfo) do
            if MapIsEmpty(v) == false then
                local _info = {}
                _info.text = v.text
                _info.state = v.status
                _info.id = v.rewardLevel
                _info.rewardLevelType = v.type
                _info.rewardIds = v.rewardIds
                _info.exchangeId = v.exchangeId
                 
                table.insert(info,_info)
            end
        end
    end

    table.sort(info,function(a,b)
        if a.id < b.id then
            return true
        else
            return false
        end
    end)

    self._rewardLevelList = info
end

function XiangNangMiGe:__dealWithRewardInfo(rewardInfo)
    local info = {}

    if MapIsEmpty(rewardInfo) == false then
        for k,v in pairs(rewardInfo) do
            if MapIsEmpty(v) == false then
                local _info = {}
                _info.id = tonumber(k)
                _info.text = v.text
                _info.price = v.price
                _info.rewards = v.rewards

                table.insert(info,_info)
            end
        end
    end

    table.sort(info,function(a,b)
        if a.id < b.id then
            return true
        else
            return false
        end
    end)

    self._rewardList = info
end

return class("XiangNangMiGe", {}, XiangNangMiGe)
0000000000000