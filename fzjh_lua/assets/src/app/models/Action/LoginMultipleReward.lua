local class = require("third.class.NewClass")

local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")
local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

local rewardState = {
    NOT_PAY = 0,--未充值
    NOT_REWARD = 1, --可领取
    AWARDED = 2, --已领取
}

local LoginMultipleReward = {}

function LoginMultipleReward:create()
    return LoginMultipleReward:new()
end

function LoginMultipleReward:ctor()
    self._actionId = "LoginMultipleReward"

    self._name = "登录奖励"

    self._desc = "2021年5月15日0点-2021年5月31日23点59分，活动期间每天可购买超值礼包，每种礼包将会有不同的购买次数，购买后请及时领取，购买次数将于每天0点刷新。"
    --每日奖励总共可领取次数
    self._todayRewardTotalCount = 0
    --每日奖励已领取次数
    self._todayRewardReceivedCount = 0
    --每日奖励可领取次数
    self._todayRewardAvailableCount = 0
    --每日奖励不可领取次数
    self._todayRewardUnclaimableCount = 0
    --奖池可领取数量
    self._availableCount = 0
    --奖池已领取数量
    self._receivedCount = 0
    --奖池最大奖励数量
    self._maxRewradCount = 0

    self._poolTextConfig = {}
end

function LoginMultipleReward:setRole(role)
    self._role = role
end

function LoginMultipleReward:setActionId(actionId)
    self._actionId = actionId
end

function LoginMultipleReward:init(callback)
    local userAttr = {}
    userAttr.lv = self._role:getLv()
    HttpManagerEx:getNewLoginRewardInfo(self._actionId, userAttr, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._name = data.act_name

            self._desc = data.detail_desc

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self._desc = desc

            self._loginDayCount = data.loginDayCount

            self:__initTodayRewardPool(data.cyclic_pools)

            self:__initRewardPool(data.cumulative_pools)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function LoginMultipleReward:getActionName()
    return self._name
end

function LoginMultipleReward:getActionDesc()
    return self._desc
end

function LoginMultipleReward:getTodayRewardTotalCount()
    return self._todayRewardTotalCount
end

function LoginMultipleReward:getTodayRewardReceivedCount() 
    return self._todayRewardReceivedCount
end

function LoginMultipleReward:getTodayRewardAvailableCount()
    return self._todayRewardAvailableCount
end

function LoginMultipleReward:getTodayRewardUnclaimableCount()
    return self._todayRewardUnclaimableCount
end

function LoginMultipleReward:getRewardAvailableCount()
    return self._availableCount
end

function LoginMultipleReward:checkRewardPoolIsEmpty()
    return self._receivedCount == self._maxRewradCount
end

function LoginMultipleReward:getTodayRewardPool()
    return self._todayRewardPool
end

function LoginMultipleReward:getRewardPool()
    return self._rewardPool
end

function LoginMultipleReward:getPoolTextConfig()
    return self._poolTextConfig
end

function LoginMultipleReward:getLoginDayCount()
    return self._loginDayCount
end

function LoginMultipleReward:getOneReward(poolId, day, func)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local currencyVersion = self._role:getCurrencyVersion()
    local isEmail = 1

    if self._rewardPool[tostring(day)] then
        for k, v in pairs(self._rewardPool[tostring(day)]) do
            if tonumber(v.poolId) == tonumber(poolId) then
                if self:checkCanGetReward({v}) then
                    isEmail = 0
                    break
                end
            end
        end
    end

    HttpManagerEx:claimSingleNewLoginReward(self._actionId, poolId, day, isEmail, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            GoodsHelper:fromNetworkGrantGoods(self._role,GrantGoodRequest:create({goodsList = data.reward, dataVersion = data.dataVer, currencyVersion = data.currencyVersion}))

            ActionRewardsHelper:printGetRewardsText(data.reward)

            if data.msg then
                PopText(data.msg)
            end

            if self._rewardPool[tostring(day)] then
                self._availableCount = self._availableCount - 1
                self._receivedCount = self._receivedCount + 1
                for k, v in pairs(self._rewardPool[tostring(day)]) do
                    if tonumber(v.poolId) == tonumber(poolId) then
                        v.state = 2
                        if func then
                            func()
                        end
                        break
                    end
                end
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function LoginMultipleReward:getTotalAvailableClaimReward(poolType, func)
    local isEmail = 1
    if poolType == 1 then
        if self:checkCanGetReward(self._todayRewardPool) then
            isEmail = 0
        end
    elseif poolType == 2 then
        local rewardList = {}

        for i, rewards in pairs(self._rewardPool) do
            for __, reward in pairs(rewards) do
                if reward.state == 1  then
                    table.insert(rewardList, reward)
                end
            end
        end

        if MapIsEmpty(rewardList) then
            return
        end

        if self:checkCanGetReward(rewardList) then
            isEmail = 0
        end
    end

    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local currencyVersion = self._role:getCurrencyVersion()

    HttpManagerEx:claimAllNewLoginReward(self._actionId, poolType, isEmail, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            GoodsHelper:fromNetworkGrantGoods(self._role,GrantGoodRequest:create({goodsList = data.reward, dataVersion = data.dataVer, currencyVersion = data.currencyVersion}))

            ActionRewardsHelper:printGetRewardsText(data.reward)

            if data.msg then
                PopText(data.msg)
            end

            if poolType == 2 then
                for __, reward in pairs(self._rewardPool) do
                    for k, v in pairs(reward) do
                        if v.state == 1 then
                            self._availableCount = self._availableCount - 1
                            self._receivedCount = self._receivedCount + 1
                            v.state = 2
                        end
                    end
                end
            elseif poolType == 1 then
                self._todayRewardReceivedCount = data.receivedCount
                self._todayRewardAvailableCount = data.availableCount
            end
            
            if func then
                func()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function LoginMultipleReward:checkCanGetReward(rewards)
    return ActionRewardsHelper:checkBagCanGetRewards(rewards, self._role)
end

function LoginMultipleReward:__initTodayRewardPool(rewardPool)
    self._todayRewardReceivedCount = rewardPool.receivedCount
            
    self._todayRewardAvailableCount = rewardPool.availableCount

    self._todayRewardTotalCount = rewardPool.totalCount

    self._todayRewardUnclaimableCount = rewardPool.accumulateCount

    self._poolTextConfig[tostring(rewardPool.poolId)] = {
        text = rewardPool.text,
        name = rewardPool.name
    }

    self._todayRewardPool = {}

    for i,v in ipairs(rewardPool.rewards) do
        table.insert(self._todayRewardPool, {
            id = v.goodsId,
            num = v.num
        })
    end
end

function LoginMultipleReward:__initRewardPool(rewardPool)
    self._rewardPool = {}
    self._availableCount = 0
    self._receivedCount = 0
    self._maxRewradCount = 0

    for i, pool in ipairs(rewardPool) do
        for __, reward in ipairs(pool.rewards) do
            if not self._rewardPool[tostring(reward.day)] then
                self._rewardPool[tostring(reward.day)] = {}
            end

            table.insert(self._rewardPool[tostring(reward.day)], {
                id = reward.goodsId,
                num= reward.num,
                day = reward.day,
                state = reward.state,
                poolId = pool.poolId
            })

            --奖励状态 0 未解锁 1 可领取 2已领取
            if reward.state == 2 then
                self._receivedCount = self._receivedCount + 1
            end

            if reward.state == 1 then
                self._availableCount = self._availableCount + 1
            end

            self._maxRewradCount = self._maxRewradCount + 1
        end

        if not self._poolTextConfig[tostring(pool.poolId)] then
            self._poolTextConfig[tostring(pool.poolId)] = {}
        end

        if not self._poolTextConfig[tostring(pool.poolId)].text then
            self._poolTextConfig[tostring(pool.poolId)].text = pool.text
        end

        if not self._poolTextConfig[tostring(pool.poolId)].name then
            self._poolTextConfig[tostring(pool.poolId)].name = pool.name
        end
    end
end

return class("LoginMultipleReward", {}, LoginMultipleReward)
000