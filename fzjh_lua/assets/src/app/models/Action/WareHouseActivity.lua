local class = require("third.class.NewClass")

local wareHouseProgressAwards = require("script.activity.wareHouseProgressAwards")["Sheet1"]

local wareHouseRandomAwards = require("script.activity.wareHouseRandomAwards")["Sheet1"]

local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")

local GoodsHelper = require("app.models.Store.GoodsHelper")

local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

local WareHouseActivity = {}

function WareHouseActivity:create()
    return WareHouseActivity:new()
end

function WareHouseActivity:ctor()
    self.__name = "地仓府库"
    self.__desc = "活动文本"
    self.__access = "密钥获取文本"
end

function WareHouseActivity:setRole(role)
    self.__role = role
end

function WareHouseActivity:getRole()
    return self.__role
end

function WareHouseActivity:getActionInfo(func)
    local currencyVersion = self.__role:getCurrencyVersion()
    HttpManagerEx:getWareHouseActivityInfo(currencyVersion,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__name = data.act_name

                self.__desc = data.detail_desc

                local desc = ""

                if MapIsEmpty(data.detail_desc) == false then
                    for i, v in ipairs(data.detail_desc) do
                        desc = desc .. v .. "\n"
                    end
                end

                self.__desc = desc

                self.__access = data.help_desc

                self.__secret_num1 = data.secret_num1

                self.__secret_num2 = data.secret_num2

                self.__progress_award_states = data.progress_award_states

                self.__floorNum = data.random_award_list.floorNum

                self.__random_awards = data.random_award_list.random_awards

                if func then
                    func(true, data)
                end
            else
                if func then
                    func(false, errmsg)
                end
            end
        end,
        IS_SHOW_WAITING
    )
end

function WareHouseActivity:drawLucky(indexList, func)
    local currencyVersion = self.__role:getCurrencyVersion()
    HttpManagerEx:WareHouseDrawLucky(
        indexList,currencyVersion,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local cost = #indexList

                self.__secret_num1 = self.__secret_num1 - cost

                self.__secret_num2 = self.__secret_num2 + cost

                self.__progress_award_states = data.progress_award_states

                if data.currencyVersion then
                    self.__role:setCurrencyVersion(data.currencyVersion)
                end

                local awardIds = data.awardIds

                local rewards = {}

                if MapIsEmpty(awardIds) == false then
                    for i = 1, #awardIds, 1 do
                        local award = self:getRandomAwardRes(awardIds[i])
                        if award.notReward ~= true then
                            table.insert(rewards, {id = award:getId(), num = award.num})
                        end
                    end
                end
                
                local rewardType = 2

                local isEmail = self:checkCanGetReward(rewards) == false and 1 or 0

                self:getAward(
                    indexList,
                    rewardType,
                    awardIds,
                    isEmail,
                    function(result, awardIds, msg)
                        if func then
                            func(result, awardIds, msg)
                        end
                    end
                )
            else
                if func then
                    func(false, nil, errmsg)
                end
            end
        end,
        IS_SHOW_WAITING
    )
end

function WareHouseActivity:getAward(indexList,rewardType, awardIdList, isEmail, func)
    local dataVer = self:getRole():getServerActionSystem():getDataVersion()
    local currencyVersion = self:getRole():getCurrencyVersion()
    HttpManagerEx:getWareHouseAward(
        rewardType,
        awardIdList,
        isEmail,
        dataVer,
        currencyVersion,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local msg = ""

                if MapIsEmpty(data.awardIds) == false then
                    local rewards = {}
                    for i = 1, #data.awardIds, 1 do
                        local reward
                        if rewardType == 1 then
                            reward = self:getProgressAwardRes(data.awardIds[i])
                        else
                            reward = self:getRandomAwardRes(data.awardIds[i])
                        end

                        if reward.notReward ~= true then
                            table.insert(rewards, {id = reward:getId(), num = reward.num})
                        end
                    end

                    if MapIsEmpty(rewards) == false then
                        GoodsHelper:fromNetworkGrantGoods(self.__role,GrantGoodRequest:create({goodsList = rewards,dataVersion = data.dataVer, currencyVersion = data.currencyVersion}))

                        ActionRewardsHelper:printGetRewardsText(rewards)
                    else
                        msg = "少侠与大奖更进一步了"
                    end
                else
                    msg = "少侠与大奖更进一步了"
                end

                if data.msg then
                    msg = data.msg
                end

                for i = 1, #indexList, 1 do
                    if rewardType == 1 then
                        --状态改为已领取
                        self.__progress_award_states[indexList[i]] = 2
                    else
                        --状态改为已抽取
                        self.__random_awards[indexList[i]].state = 1
                        
                        self.__random_awards[indexList[i]].awardId = awardIdList[i]
                    end
                end

                if func then
                    func(true, awardIdList, msg)
                end
            else
                if func then
                    func(false, nil, errmsg)
                end
            end
        end,
        IS_SHOW_WAITING
    )
end

function WareHouseActivity:enterNextFloor(func)
    HttpManagerEx:enterWareHouseNextFloor(
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__floorNum = data.random_award_list.floorNum

                self.__random_awards = data.random_award_list.random_awards

                if func then
                    func(true, data)
                end
            else
                if func then
                    func(false, errmsg)
                end
            end
        end,
        IS_SHOW_WAITING
    )
end

function WareHouseActivity:getActionName()
    return self.__name
end

function WareHouseActivity:getActionDesc()
    return self.__desc
end

function WareHouseActivity:getAccess()
    return self.__access
end

function WareHouseActivity:getSecretNum1()
    return self.__secret_num1
end

function WareHouseActivity:getSecretNum2()
    return self.__secret_num2
end

function WareHouseActivity:getProgressAwardStates()
    return self.__progress_award_states
end

function WareHouseActivity:getFloorNum()
    return self.__floorNum
end

function WareHouseActivity:getRandomAwards()
    return self.__random_awards
end

function WareHouseActivity:getProgressAwardNum()
    local num = 0

    for k, v in pairs(wareHouseProgressAwards) do
        num = num + 1
    end

    return num
end

function WareHouseActivity:getProgressAwardRes(id)
    local res = wareHouseProgressAwards[tonumber(id)]
    local goodsInfo = res.gift
    if MapIsEmpty(goodsInfo) == false then
        local goodsId = goodsInfo[1]
        local goods = GoodsHelper:getGoodsResClass(goodsId)

        return inherit({condition = res.condition, num = goodsInfo[2]},goods)
    else
        return {condition = res.condition}
    end
end

function WareHouseActivity:getRandomAwardRes(id)
    local res = wareHouseRandomAwards[tonumber(id)]
    local goodsInfo = res.gift

    if MapIsEmpty(goodsInfo) == false then
        local goodsId = goodsInfo[1]
        local goods = GoodsHelper:getGoodsResClass(goodsId)
        return inherit({num = goodsInfo[2], gifttype = res.gifttype},goods)
    else
        return {notReward = true, gifttype = res.gifttype}
    end
end

function WareHouseActivity:checkCanGetReward(rewards)
    return ActionRewardsHelper:checkBagCanGetRewards(rewards, self.__role)
end

return class("WareHouseActivity", {}, WareHouseActivity)
0000000000000