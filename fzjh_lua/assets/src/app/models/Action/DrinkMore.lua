local class = require("third.class.NewClass")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")
local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")
local DrinkMore = {}
local RewardType = {
    PersonalReward = 1,
    GroupReward = 2,
}
-- 状态，0：未解锁，1：可领取，2：已领取
local RewardState = {
    NotReward = 0,
    Reward = 1,
    AfterReward = 2,
}

local RewardSort = {
    [RewardState.Reward] = 1,
    [RewardState.NotReward] = 2,
    [RewardState.AfterReward] = 3,
}

function DrinkMore:create()
    return DrinkMore:new()
end

function DrinkMore:ctor()
    self.__name = "年兽"
    self.__desc = "打年兽了"
    self.__num = 10
    self.__gruopList = {}
    self.__personalList = {}
    self.__access = "年兽"
    self.__personalCount = 0
    self.__groupCount = 0
end

function DrinkMore:setRole(role)
    self.__role = role
end

function DrinkMore:getRole()
    return self.__role
end

function DrinkMore:getActionInfo(func)
    HttpManagerEx:getToastRewardList(function(status, errcode, errmsg, data)
		if status ==200 and errcode == 0 then
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

            self.__personalCount = data.personal_count

            self.__groupCount = data.collective_count

            self.__num = data.baiduo

            self.__driveAwaySpace = data.reserved_blank

            self.__drinkState = data.is_toast

            self.__giftRewardList = data.gifts_list

            self:__initShowRewardList(data.list)

            self:__initDriveAwayInfo(data.expel_reward)

            if func then 
                func()
            end
		else
			PopText(errmsg)
		end
	end,IS_SHOW_WAITING)
end

function DrinkMore:getActionName()
    return self.__name
end

function DrinkMore:getActionDesc()
    return self.__desc
end

function DrinkMore:getDrinkNum()
    return self.__num
end

function DrinkMore:getPersonalRewardList()
    return self.__personalList
end

function DrinkMore:getGroupRewardList()
    return self.__gruopList
end

function DrinkMore:getAccess()
    return self.__access
end

function DrinkMore:getDriveAwayInfo()
    return self.__driveAwayInfo
end

function DrinkMore:getDrinkState()
    return self.__drinkState
end

function DrinkMore:doDrink(num,func)
    if num > 0 then
        local space = self.__driveAwaySpace[tostring(num)] or 1

        if self.__role:checkCanBuyTwoOrMoreThings({["jian101"] = space},true) == false then
            return
        end

        local dataVer = self.__role:getServerActionSystem():getDataVersion()

        HttpManagerEx:toastQian(num, dataVer, function(status, errcode, errmsg, data)
            if status ==200 and errcode == 0 then
                self.__num = data.baiduo

                GoodsHelper:fromNetworkGrantGoods(self.__role,GrantGoodRequest:create({goodsList = data.rewards,dataVersion = data.dataVer}))

                ActionRewardsHelper:printGetRewardsText(data.rewards)

                if data.msg then
                    PopText(data.msg)
                end
                if func then
                    func()
                end
            else
                PopText(errmsg)
            end
        end,IS_SHOW_WAITING)
    end
end

local giftRewardsText = {}

function DrinkMore:getGiftRewardText(giftId)
    if not giftRewardsText[tostring(giftId)] then
        local rewards = self.__giftRewardList[tostring(giftId)]
        local text = ""
        for i = 1, #rewards, 1 do
            local goods = GoodsHelper:getGoodsResClass(rewards[i].id)
            text = text .. goods:getName().."X"..rewards[i].num
            if i < #rewards then
                text = text .. "、"
            end
        end

        giftRewardsText[tostring(giftId)] = text
    end
    
    return giftRewardsText[tostring(giftId)]
end

function DrinkMore:getGiftReward(giftId)
    return self.__giftRewardList[tostring(giftId)]
end

function DrinkMore:__initShowRewardList(list)
    self.__personalList = {}
    self.__gruopList = {}

    if MapIsEmpty(list) == false then
        for k,v in pairs(list) do
            local rewardInfo = {}
            rewardInfo.rid = v.rid
            rewardInfo.state = v.state

            if v.state == RewardState.AfterReward then
                rewardInfo.enable = false
                rewardInfo.btnName = "已领取"
                rewardInfo.loadTexture = "Image/UI/TaskUI/anniuhui.png"
            elseif v.state == RewardState.NotReward then
                rewardInfo.enable = false
                rewardInfo.btnName = "领取"
                rewardInfo.loadTexture = "Image/UI/TaskUI/anniuhui.png"
            elseif v.state == RewardState.Reward then
                rewardInfo.enable = true
                rewardInfo.btnName = "领取"
                rewardInfo.loadTexture = "Image/UI/TaskUI/anniu.png"
            end

            rewardInfo.giftIdList = v.gift_ids

            if #v.gift_ids > 1 then
                rewardInfo.text2 = "内含多种组合奖励，请点击右方按钮进入多选奖励界面，选择所需奖励"
                rewardInfo.isSelect = true
            else
                rewardInfo.text2 = self:getGiftRewardText(v.gift_ids[1])
                rewardInfo.isSelect = false
            end

            if rewardInfo.isSelect then
                if v.state == RewardState.AfterReward then
                    rewardInfo.btnName = "已领取"
                else
                    rewardInfo.btnName = "进入"
                    rewardInfo.enable = true
                end
            end

            if v.exchange_id then
                rewardInfo.text2 = self:getGiftRewardText(v.exchange_id)
                rewardInfo.exchangeId = v.exchange_id
            end

            if v.rtype == RewardType.PersonalReward then
                rewardInfo.text1 = "共饮次数"..tostring(self.__personalCount).."/"..tostring(v.award_limit)
                table.insert(self.__personalList,rewardInfo)
            elseif v.rtype == RewardType.GroupReward then
                rewardInfo.text1 = "共饮次数"..tostring(self.__groupCount).."/"..tostring(v.award_limit)
                table.insert(self.__gruopList,rewardInfo)
            end
        end

        table.sort(self.__personalList,function(a,b)
            if RewardSort[a.state] < RewardSort[b.state] then
                return true
            elseif RewardSort[a.state] == RewardSort[b.state] then
                return a.rid < b.rid
            else
                return false
            end
        end)

        table.sort(self.__gruopList,function(a,b)
            if RewardSort[a.state] < RewardSort[b.state] then
                return true
            elseif RewardSort[a.state] == RewardSort[b.state] then
                return a.rid < b.rid
            else
                return false
            end
        end)
    end
end

function DrinkMore:checkCanGetReward(rewards)
    local isDuplicate, searchInfo = GoodsHelper:checkDuplicatePurchaseList(self.__role, rewards)

    return not isDuplicate, searchInfo
end

function DrinkMore:checkBagCanGetReward(rewards)
    local isTrue, msg = ActionRewardsHelper:checkBagCanGetRewards(rewards, self.__role)
    return isTrue, msg
end

function DrinkMore:doReward(rewardId, giftId, callback)
    local dataVer = self.__role:getServerActionSystem():getDataVersion()
    local newDataVer = self.__role:getCurrencyVersion()
    HttpManagerEx:getToastReward(rewardId, giftId, dataVer, newDataVer, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local rewardList = data.rewards

            local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

            GoodsHelper:fromNetworkGrantGoods(self.__role,GrantGoodRequest:create({goodsList = rewardList, dataVersion = data.dataVer}))

            ActionRewardsHelper:printGetRewardsText(rewardList)

            if data.newDataVer then
                self.__role:setCurrencyVersion(data.newDataVer)
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

function DrinkMore:__initDriveAwayInfo(list)
    if not self.__driveAwayInfo then
        if MapIsEmpty(list) == false then
            local text = ""
            for i = 1, #list, 1 do
                local goods = GoodsHelper:getGoodsResClass(list[i].id)
                text = text .. goods:getName().."X"..list[i].num
                if i < #list then
                    text = text .. "、"
                end
            end
            self.__driveAwayInfo = text
        end
    end
end

return class("DrinkMore", {}, DrinkMore)
0000000000000