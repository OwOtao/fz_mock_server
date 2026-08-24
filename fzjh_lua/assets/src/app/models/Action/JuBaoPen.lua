local class = require("third.class.NewClass")

local JuBaoPen = {}

-- 状态，0：不可领取，1：可领取，2：已领取
local RewardState = {
    NotReward = 0,
    Reward = 1,
    AfterReward = 2,
}

-- 1 为单个奖励 2为多选
local RewardType = {
    ONE_REWARD_TYPE = 1,
    SELECT_REWARD_TYPE = 2
}

function JuBaoPen:create()
    return JuBaoPen:new()
end

function JuBaoPen:ctor()
    self._actionId = 0

    self._name = ""

    self._desc = ""

    self._rewardLevelList = {}

    self._rewardList = {}
end

function JuBaoPen:setRole(role)
    self._role = role
end

function JuBaoPen:setActionId(actionId)
    self._actionId = actionId
end

function JuBaoPen:init(callback)
    HttpManagerEx:getZhaoCaiJinBaoInfo(self._actionId,function(status, errcode, errmsg, data)
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

            self._currencyNum = data.shopping_money

            self:__dealWithRewardLevelInfo(data.list)

            self:__dealWithRewardInfo(data.rewards)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function JuBaoPen:getActionName()
    return self._name
end

function JuBaoPen:getActionDesc()
    return self._desc
end

function JuBaoPen:getCurrencyNum()
    return self._currencyNum
end

function JuBaoPen:getRewardLevelList()
    return self._rewardLevelList
end

function JuBaoPen:doReward(id, rewardId, isEmail, callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    local currencyVersion = self._role:getCurrencyVersion() 
    HttpManagerEx:getZhaoCaiJinBaoReward(self._actionId, id, rewardId, isEmail, dataVer, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local rewardList = data.reward
            if MapIsEmpty(rewardList) == false then
                for k,v in pairs(rewardList) do
                    if v.type == 1 or v.type == 2 then --物品
                        self._role:addItemCount(v.itemId,v.number)
                    elseif v.type == 3 then --属性
                        self._role:addAttr(v.itemId,v.number)
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

            if data.currencyVersion then
                self._role:setCurrencyVersion(data.currencyVersion)
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

function JuBaoPen:setAfterRewardCallback(func)
    self._afterRewardCallback = Helper:getDef(func,EMPTY_FUNC)
end

function JuBaoPen:getRewardById(id)
    id = tostring(id)
    if self._rewardList[id] then
        return self._rewardList[id]
    end
end

function JuBaoPen:checkStateIsReward(state)
    return state == RewardState.Reward
end

function JuBaoPen:checkStateIsRewarded(state)
    return state == RewardState.AfterReward
end

function JuBaoPen:checkRewardTypeIsSelect(rewardType)
    return rewardType == RewardType.SELECT_REWARD_TYPE
end

-- true 代表背包满
function JuBaoPen:checkBagIsEnough(rewards)
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

    if self._role:checkCanBuyTwoOrMoreThings(items,false) == true then
        return false
    else
        return true
    end
end

function JuBaoPen:__dealWithRewardLevelInfo(list)
    local info = {}

    if MapIsEmpty(list) == false then
        for k,v in pairs(list) do
            if MapIsEmpty(v) == false then
                local _info = {}
                _info.id = v.id
                _info.state = v.status
                _info.needMoney = v.needMoney
                _info.rewardType = v.idType
                _info.rewardIdList = v.rewards

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

function JuBaoPen:__dealWithRewardInfo(rewardInfo)
    local info = {}

    if MapIsEmpty(rewardInfo) == false then
        for rewardId,rewards in pairs(rewardInfo) do
            local _rewards = {}
            if MapIsEmpty(rewards) == false then
                for k, v in pairs(rewards) do
                    local _info = {}
                    _info.id = v.itemId
                    _info.number = v.number
                    _info.name = v.name
                    _info.type = v.type

                    table.insert(_rewards,_info)
                end
            end

            info[tostring(rewardId)] = _rewards
        end
    end

    self._rewardList = info
end

return class("JuBaoPen", {}, JuBaoPen)
000000000000000