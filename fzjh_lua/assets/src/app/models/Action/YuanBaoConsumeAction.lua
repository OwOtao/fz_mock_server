local class = require("third.class.NewClass")

local YuanBaoConsumeAction = {}

function YuanBaoConsumeAction:create()
    return YuanBaoConsumeAction:new()
end

-- 状态，0：未解锁，1：可领取，2：已领取
local RewardState = {
    NotReward = 0,
    Reward = 1,
    AfterReward = 2,
}

function YuanBaoConsumeAction:ctor()
    self._actionId = 0

    self._name = "江湖夺宝"

    self._desc = "江湖夺宝江湖夺宝江湖夺宝江湖夺宝江湖夺宝"
end

function YuanBaoConsumeAction:setRole(role)
    self._role = role
end


function YuanBaoConsumeAction:init(callback)
    HttpManagerEx:getTime(function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 and data.time ~= nil then
            SetTime(tonumber(data.time))
            HttpManagerEx:getYuanbaoConsumptionInfo(function(status, errcode, errmsg, data)
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
        
                    self._spendNum = data.spend_number
                    
                    self:__dealWithRewardInfo(data.list)
        
                    if callback then
                        callback()
                    end
                else
                    PopText(errmsg)
                end
            end,IS_SHOW_WAITING)
        end
    end)
end

function YuanBaoConsumeAction:getActionName()
    return self._name
end

function YuanBaoConsumeAction:getSpendNum()
    return self._spendNum
end

function YuanBaoConsumeAction:getActionDesc()
    return self._desc
end


function YuanBaoConsumeAction:getShowInfo()
    return self._showInfo
end

function YuanBaoConsumeAction:doReward(rewardId, isEmail, callback)
    HttpManagerEx:getYuanbaoConsumptionReward(rewardId,isEmail,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local rewardList = data.rewards
            if MapIsEmpty(rewardList) == false then
                for k,v in pairs(rewardList) do
                    if v.type == 1 then --物品
                        self._role:addItemCount(v.id,v.number)
                    elseif v.type == 2 then --属性
                        self._role:addAttr(v.id,v.number)
                    end

                    PopText("获得"..v.name.."X"..tostring(v.number))
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

function YuanBaoConsumeAction:checkStateIsReward(state)
    return state == RewardState.Reward
end

function YuanBaoConsumeAction:checkStateIsUnlock(state)
    return state == RewardState.NotReward
end

function YuanBaoConsumeAction:checkStateIsGetReward(state)
    return state == RewardState.AfterReward
end

function YuanBaoConsumeAction:checkBagCanGetReward(rewards)
    local items = {}

    for k,v in pairs(rewards) do
        if v.type == 1 then
            if items[v.id] then
                items[v.id] = tonumber(v.number) + items[v.id]
            else
                items[v.id] = tonumber(v.number)
            end
        end
    end

    if self._role:checkCanBuyTwoOrMoreThings(items, false) == false then
        return false
    else
        return true
    end
end

function YuanBaoConsumeAction:__dealWithRewardInfo(info)
    self._showInfo = {}

    if MapIsEmpty(info) == false then
        for __,reward in pairs(info) do
            local _info = {}
            _info.rid = reward.rid
            _info.target = reward.target
            _info.state = reward.state
            _info.rewards = reward.rewards

            table.insert(self._showInfo, _info)
        end

        table.sort(self._showInfo,function(a, b)
            if a.target < b.target then
                return true
            else
                return false
            end
        end)
    end
end


return class("YuanBaoConsumeAction", {}, YuanBaoConsumeAction)
0000000000000