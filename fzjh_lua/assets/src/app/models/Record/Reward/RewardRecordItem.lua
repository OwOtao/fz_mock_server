--[[
    author:Seven
    time:2023-06-20 16:22:41
    desc: 策略奖励记录表记录信息
]]
local newClass = require("third.class.NewClass")

local ISerializable = require("third.serializable.ISerializable")

local RewardRecordItem = {}

function RewardRecordItem:create(id)
    return RewardRecordItem.new():__init(id)
end

function RewardRecordItem:__init(id)
    assert(id and (string.len(id) > 0), "RewardRecordItem : id is nil or empty string")

    --@desc 来源id
    self._id = id

    --@desc 链式调用id
    self._chain = self._id

    --@desc 奖励
    self._rewardIds = {}

    return self
end

function RewardRecordItem:chainAppend(rid)
    self._chain = self._chain .. "|" .. rid
end

function RewardRecordItem:setRewardsRecord(rewards)
    assert(rewards, "不可为空")
    self._rewardIds = rewards
end

function RewardRecordItem:serialize()
    return {
        id = self._id,
        chain = self._chain,
        reward = self._rewardIds
    }
end

return newClass("RewardRecordItem", {ISerializable}, RewardRecordItem)
00000