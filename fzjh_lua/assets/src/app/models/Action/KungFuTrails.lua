local class = require("third.class.NewClass")

local KungFuTrails = {}

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

function KungFuTrails:create()
    return KungFuTrails:new()
end

function KungFuTrails:ctor()
    self._actionId = 0

    self._name = "武门试炼"

    self._desc = "武门试炼武门试炼武门试炼武门试炼武门试炼武门试炼"

    self._list = {}

    self._taskType = {}
end

function KungFuTrails:setRole(role)
    self._role = role
end

function KungFuTrails:setActionId(actionId)
    self._actionId = actionId
end

function KungFuTrails:init(callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    HttpManagerEx:getWuMenTrialInfo(dataVer, function(status, errcode, errmsg, data)
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

            self:__dealWithInfo(data.list)

            if callback then
                callback()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function KungFuTrails:getActionName()
    return self._name
end

function KungFuTrails:getActionDesc()
    return self._desc
end

function KungFuTrails:getListByTypeId(id)
    local list = {}

    for i, v in ipairs(self._list) do
        if v.taskTypeId == id then
            table.insert(list, v)
        end
    end

    table.sort(list, function(a, b)
        if RewardSort[a.state] < RewardSort[b.state] then
            return true
        elseif RewardSort[a.state] == RewardSort[b.state] then
            local a_index = string.gsub(a.id,"task","")
            local b_index = string.gsub(b.id,"task","")
            return tonumber(a_index) < tonumber(b_index)
        else
            return false
        end
    end)

    return list
end

function KungFuTrails:getTaskFisrtTypeIdAndName()
    if self._taskType[1] then
        return self._taskType[1].id, self._taskType[1].name
    end
end

function KungFuTrails:getTaskSecondTypeIdAndName()
    if self._taskType[2] then
        return self._taskType[2].id, self._taskType[2].name
    end
end

function KungFuTrails:doReward(rewardId, callback)
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    HttpManagerEx:getWuMenTrialReward(rewardId, dataVer, function(status, errcode, errmsg, data)
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

function KungFuTrails:setAfterRewardCallback(func)
    self._afterRewardCallback = Helper:getDef(func,EMPTY_FUNC)
end


function KungFuTrails:checkStateIsReward(state)
    return state == RewardState.Reward
end

function KungFuTrails:checkStateIsUnlock(state)
    return state == RewardState.NotReward
end

function KungFuTrails:checkStateIsRewarded(state)
    return state == RewardState.AfterReward
end

-- true 代表背包满
function KungFuTrails:checkBagIsEnough(rewards)
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

    if self._role:checkCanBuyTwoOrMoreThings(items,false) == true then
        return false
    else
        return true
    end
end

function KungFuTrails:__dealWithInfo(list)
    self._list = {}
    self._taskType = {}

    local info = {}
    local taskType = {}

    if MapIsEmpty(list) == false then
        for k,v in pairs(list) do
            if MapIsEmpty(v) == false then
                local _info = {}

                _info.id = v.taskId
                _info.text1 = v.taskText
                _info.taskTypeId = v.taskTypeId
                _info.taskReward = v.taskReward
                _info.text2 = v.rewardText
                _info.state = v.taskState

                if not taskType[v.taskTypeId] then
                    taskType[v.taskTypeId] = {
                        id = v.taskTypeId,
                        name = v.taskTypeName
                    }
                end

                table.insert(info,_info)
            end
        end
    end

    self._list = info

    for k, v in pairs(taskType) do
        table.insert(self._taskType, v)
    end

    table.sort(self._taskType, function(a, b)
        return a.id < b.id
    end)
end

return class("KungFuTrails", {}, KungFuTrails)
00000000000