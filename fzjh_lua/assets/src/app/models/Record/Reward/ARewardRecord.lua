--[[
    author:Seven
    time:2023-06-20 17:20:22
    desc:
]]
local newClass = require("third.class.NewClass")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local ISerializable = require("third.serializable.ISerializable")

local RewardRecordItem = require("app.models.Record.Reward.RewardRecordItem")

local ARewardRecord = {
    __recordItems = {},
    __rewards = {}
}

ARewardRecord.RTYPE = {
    MAP_RESULT = 0,
    KILL_NPC_DROP = 1,
    USE_ITEM = 2,
    VISITTASK = 3,
    TREASURE_BOX = 4,
}

function ARewardRecord:setType(r_type)
    self.__type = r_type
end

function ARewardRecord:addRewardRecordItem(item)
    xpcall(
        isImplement,
        function(err)
            print(err)
            error("addRewardRecordItem item is must implement RewardRecordItem")
        end,
        item,
        RewardRecordItem
    )

    table.insert(self.__recordItems, item)
end

function ARewardRecord:addFinnalReward(reward)
    table.insert(self.__rewards, reward)
end

function ARewardRecord:serialize()
    local t = {
        stype = self.__type
    }

    local items = {}
    for k, v in pairs(self.__recordItems) do
        table.insert(items, v:serialize())
    end

    t.recordItems = items

    t.rewards = self.__rewards

    local env = self:_envSerialize()

    for k, v in pairs(env) do
        if t[k] ~= nil then
            error("env serialize key is exist : " .. k)
        end
        t[k] = v
    end

    return t
end

function ARewardRecord:_envSerialize()
    error("ARewardRecord:_envSerialize must be override")
end

return newClass(
    "ARewardRecord",
    {
        ISerializable,
        {
            _envSerialize = function(self)
            end
        }
    },
    ARewardRecord
)
0000000000000