local class = require("third.class.NewClass")

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
end

function DanQingGe:setRole(role)
    self._role = role
end

function DanQingGe:setActionId(actionId)
    self._actionId = actionId
end

function DanQingGe:init(callback)
    HttpManagerEx:getDanQingPavilionInfo(self._actionId, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            self._name = data.act_name

            local desc = ""

            if MapIsEmpty(data.detail_desc) == false then
                for i, v in ipairs(data.detail_desc) do
                    desc = desc .. v .. "\n"
                end
            end

            self._desc = desc

            self._currencyName = data.currency_name

            self._currencyNum = data.currency_number

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

function DanQingGe:getCurrencyName()
    return self._currencyName
end

function DanQingGe:getCurrencyNum()
    return self._currencyNum
end

function DanQingGe:getList()
    return self._list
end

function DanQingGe:exchangeReward(id, rewardId, callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    HttpManagerEx:exchangeDanQingPavilionItem(self._actionId, id, rewardId, dataVer, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
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

function DanQingGe:doReward(rewardId, callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    HttpManagerEx:getDanQingPavilionReward(self._actionId, rewardId, dataVer, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local rewardList = data.rewards
            if MapIsEmpty(rewardList) == false then
                for k,v in pairs(rewardList) do
                    if v.type == 1 or v.type == 2 then --物品
                        self._role:addItemCount(v.id,v.number)
                    elseif v.type == 3 then --属性
                        self._role:addAttr(v.id,v.number)
                    end

                    PopText("获得"..v.name.."X"..tostring(v.number))
                end
            end

            if data and data.yashi_expired_time then  --江湖雅士体验卡额外处理
                self._role:updateYaShiStatus(data.yashi_expired_time)
            end

            if data.dataVer then
                self._role:getServerActionSystem():setDataVersion(data.dataVer)
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

function DanQingGe:getRewardById(id)
    if self._rewardList then
        return self._rewardList[id]
    end
end

function DanQingGe:checkRewardIsSelect(type)
    return type == 2
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

function DanQingGe:checkCurrencyIsEnough(price)
    return self._currencyNum >= price
end

-- true 代表背包满
function DanQingGe:checkBagIsEnough(rewards)
    local items = {}

    for k,v in pairs(rewards) do
        if v.type == 1 or v.type == 2 then
            if items[v.id] then
                items[v.id] = tonumber(v.number) + items[v.id]
            else
                items[v.id] = tonumber(v.number)
            end
        end
    end

    if self._role:checkCanBuyTwoOrMoreThings(items, false) == true then
        return false
    else
        return true
    end
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
                _info.buyTimes = v.buyTimes
                _info.totalTimes = v.totalTimes
                _info.reward = v.reward
                _info.rewardIdList = {}
                
                for rewardId, rewards in pairs(v.showList) do
                    local showList = {}

                    for __k, __v in pairs(rewards) do
                        table.insert(showList, __v)
                    end

                    table.insert(_info.rewardIdList, rewardId)
                    self._rewardList[rewardId] = showList
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
0000