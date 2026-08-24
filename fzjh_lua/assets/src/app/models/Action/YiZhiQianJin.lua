local class = require("third.class.NewClass")

local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")

local YiZhiQianJin = {}

-- 状态，0：未解锁，1：可领取，2：已领取
local RewardState = {
    NotReward = 0,
    Reward = 1,
    AfterReward = 2,
}

function YiZhiQianJin:create()
    return YiZhiQianJin:new()
end

function YiZhiQianJin:ctor()
    self.__name = "一掷千金"

    self.__desc = "2021年5月15日0点-2021年5月31日23点59分，活动期间每天可购买超值礼包，每种礼包将会有不同的购买次数，购买后请及时领取，购买次数将于每天0点刷新。"

    self.__list = {}

    self.__yuanBao = 0
end

function YiZhiQianJin:setRole(role)
    self.__role = role
end

function YiZhiQianJin:init(callback)
    HttpManagerEx:getYuanBaoCostGiftList(function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self.__name = data.act_name

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self.__desc = desc

            self.__yuanBao = data.spend_yuanbao

            self.__list = data.list

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function YiZhiQianJin:getActionName()
    return self.__name
end

function YiZhiQianJin:getActionDesc()
    return self.__desc
end

function YiZhiQianJin:getSpendNum()
    return self.__yuanBao
end

function YiZhiQianJin:getList()
    return self.__list
end

function YiZhiQianJin:getGoodsInfo(goodsId)
    return GoodsHelper:getGoodsResClass(goodsId)
end

function YiZhiQianJin:checkStateIsReward(state)
    return state == RewardState.Reward
end

function YiZhiQianJin:checkStateIsUnlock(state)
    return state == RewardState.NotReward
end

function YiZhiQianJin:checkStateIsGetReward(state)
    return state == RewardState.AfterReward
end

function YiZhiQianJin:doReward(rewardId, isEmail, callback)
    local dataVer = self.__role:getServerActionSystem():getDataVersion()
    local currencyVersion = self.__role:getCurrencyVersion()

    HttpManagerEx:receiveYuanBaoPlanGift(rewardId, isEmail, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

            GoodsHelper:fromNetworkGrantGoods(self.__role,GrantGoodRequest:create({goodsList = data.reward, dataVersion = data.dataVer, currencyVersion = data.currencyVersion}))

            ActionRewardsHelper:printGetRewardsText(data.reward)

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

function YiZhiQianJin:checkCanGetReward(rewards)
    return ActionRewardsHelper:checkBagCanGetRewards(rewards, self.__role)
end

return class("YiZhiQianJin", {}, YiZhiQianJin)
0000000000000000