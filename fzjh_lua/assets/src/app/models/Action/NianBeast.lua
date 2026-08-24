local class = require("third.class.NewClass")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")
local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

local NianBeast = {}

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

function NianBeast:create()
    return NianBeast:new()
end

function NianBeast:ctor()
    self.__name = "年兽"
    self.__desc = "打年兽了"
    self.__gruopList = {}
    self.__personalList = {}
    self.__goodsList = {}
    self.__rule = "年兽"
    self.__access = "年兽"
    self.__personalCount = 0
    self.__groupCount = 0
    self.__num = 0
end

function NianBeast:setRole(role)
    self.__role = role
end

function NianBeast:setAfterRewardFunc(func)
    self.__afterRewardFunc = func
end

function NianBeast:getRole()
    return self.__role
end

function NianBeast:getActionInfo(func)
    HttpManagerEx:getExpelRewardList(function(status, errcode, errmsg, data)
		if status ==200 and errcode == 0 then
            self.__name = data.act_name

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

            self.__num = data.bianpao

            self.__driveAwaySpace = data.reserved_blank

            self.__goodsList = data.gifts_list

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

function NianBeast:getActionName()
    return self.__name
end

function NianBeast:getActionDesc()
    return self.__desc
end

function NianBeast:getNianBeastNum()
    return self.__num
end

function NianBeast:getPersonalCount()
    return self.__personalCount
end

function NianBeast:getGroupCount()
    return self.__groupCount
end

function NianBeast:getPersonalRewardList()
    return self.__personalList
end

function NianBeast:getGroupRewardList()
    return self.__gruopList
end

function NianBeast:getGoodsListByGiftId(giftId)
    return self.__goodsList[tostring(giftId)]
end

function NianBeast:getAccess()
    return self.__access
end

function NianBeast:getDriveAwayInfo()
    return self.__driveAwayInfo
end

function NianBeast:checkCanGetReward(rewards)
    local isTrue, searchInfo = ActionRewardsHelper:checkRewardsCanBuy(rewards, self.__role)

    return isTrue, searchInfo.msg
end

function NianBeast:checkBagCanGetReward(rewards)
    local isTrue, msg = ActionRewardsHelper:checkBagCanGetRewards(rewards, self.__role)
    return isTrue, msg
end

function NianBeast:getGoodsText(goodsList)
    return ActionRewardsHelper:getRewardText(goodsList)
end

function NianBeast:doDriveAway(num,func)
    if num > 0 then
        local space = self.__driveAwaySpace[tostring(num)] or 1

        if self.__role:checkCanBuyTwoOrMoreThings({["jian101"] = space},true) == false then
            return
        end

        local dataVer = self.__role:getServerActionSystem():getDataVersion()

        local currencyVersion = self.__role:getCurrencyVersion()

        HttpManagerEx:expelNian(num, dataVer, currencyVersion, function(status, errcode, errmsg, data)
            if status ==200 and errcode == 0 then
                self.__num = data.bianpao

                GoodsHelper:fromNetworkGrantGoods(self.__role,GrantGoodRequest:create({goodsList = data.rewards, dataVersion = data.dataVer, currencyVersion = data.currencyVersion}))

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

function NianBeast:doReward(rid, giftId, callback)
    HttpManagerEx:getExpelReward(
        rid, giftId,
        self.__role:getServerActionSystem():getDataVersion(),
        self.__role:getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                GoodsHelper:fromNetworkGrantGoods(self.__role,GrantGoodRequest:create({goodsList = data.rewards, dataVersion = data.dataVer, currencyVersion = data.currencyVersion}))

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
        end,
        IS_SHOW_WAITING
    )
end

function NianBeast:__initShowRewardList(list)
    self.__personalList = {}
    self.__gruopList = {}

    if MapIsEmpty(list) == false then
        for k,v in pairs(list) do
            if v.rtype == 1 then
                table.insert(self.__personalList, v)
            else
                table.insert(self.__gruopList, v)
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

function NianBeast:__initDriveAwayInfo(list)
    self.__driveAwayInfo = ActionRewardsHelper:getRewardText(list)
end

return class("NianBeast", {}, NianBeast)
00000000000000