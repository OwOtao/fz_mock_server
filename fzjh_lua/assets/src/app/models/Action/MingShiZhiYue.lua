local class = require("third.class.NewClass")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")
local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

local MingShiZhiYue = {}

function MingShiZhiYue:create()
    return MingShiZhiYue:new()
end

function MingShiZhiYue:ctor()
    self.__actionId = 0

    self.__name = ""

    self.__desc = ""

    self.__rewardList = {}
    --[[
        {
			"tag_name": "布衣之约",
            "unlock_type": 1,（1：免费解锁；3：月卡解锁；2：人民币解锁）
            "state": 1,（0：未解锁；1：已解锁）
			"lock_desc":"需成为江湖名士才能领取此页奖励。",
			"product_key":"com.mkjump.fzjha.product119",（人民币解锁时下发）
            "daily_reward": [
                    {
                            "rid": 1,
                            "reward": [
                                    {
                                        "id": "400038",
                                        "num": 60
                                    },,,,,,
                            ],
                            "state": 0
                    },,,,,,
                ]
        },
    ]]
end

function MingShiZhiYue:init(callback)
    HttpManagerEx:getLoginRewardList(self.__actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self.__name = data.act_name

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self.__desc = desc

            self.__rewardList = data.list

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function MingShiZhiYue:getActionName()
    return self.__name
end

function MingShiZhiYue:getActionDesc()
    return self.__desc
end

function MingShiZhiYue:setRole(role)
    self.__role = role
end

function MingShiZhiYue:setActionId(actionId)
    self.__actionId = actionId
end

function MingShiZhiYue:getRewardUnlockState(rewardType)
    for i, reward in ipairs(self.__rewardList) do
        if reward.unlock_type == rewardType then
            return reward.state == 1
        end
    end
end

function MingShiZhiYue:getRewardState(rewardType)
    for i, reward in ipairs(self.__rewardList) do
        if reward.unlock_type == rewardType then
            local rewardList = reward.daily_reward
            
            local isTrue = false

            for i, v in ipairs(rewardList) do
                if v.state == 1 then
                    isTrue = true
                    break
                end
            end

            return isTrue
        end
    end
end

function MingShiZhiYue:getRewardTitle(rewardType)
    for i, reward in ipairs(self.__rewardList) do
        if reward.unlock_type == rewardType then
            return reward.tag_name
        end
    end
end

function MingShiZhiYue:getRewardProductKey(rewardType)
    for i, reward in ipairs(self.__rewardList) do
        if reward.unlock_type == rewardType then
            return reward.product_key
        end
    end
end

function MingShiZhiYue:getRewardConditionText(rewardType)
    for i, reward in ipairs(self.__rewardList) do
        if reward.unlock_type == rewardType then
            return reward.lock_desc
        end
    end
end

function MingShiZhiYue:getRewardList(rewardType)
    for i, reward in ipairs(self.__rewardList) do
        if reward.unlock_type == rewardType then
            return reward.daily_reward
        end
    end
end

function MingShiZhiYue:getRewardText(goodsList)
    return ActionRewardsHelper:getRewardText(goodsList)
end

function MingShiZhiYue:checkBagCanGetReward(goodsList)
    local isTrue, msg = ActionRewardsHelper:checkBagCanGetRewards(goodsList, self.__role)
    return isTrue, msg
end

function MingShiZhiYue:doReward(rid, isEmail, callback)
    local dataVer = self.__role:getServerActionSystem():getDataVersion()
    local currencyVersion = self.__role:getCurrencyVersion()

    HttpManagerEx:getLoginReward(self.__actionId, rid, isEmail, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then

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

return class("MingShiZhiYue", {}, MingShiZhiYue)
000000000000