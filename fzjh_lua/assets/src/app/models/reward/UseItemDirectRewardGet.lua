--[[
    author:Seven
    time:2023-06-25 15:18:42
    desc: 对应物品表属性“rwIdxx”属性直接获取奖励
]]
local newClass = require("third.class.NewClass")

local Record = require("app.models.Record.Record")

local UseItemDirectRewardGet = {}

function UseItemDirectRewardGet:create(item, role)
    return UseItemDirectRewardGet.new():__init(item, role)
end

function UseItemDirectRewardGet:__init(item, role)
    self._item = item

    self._role = role

    self._record = {
        itemId = item.id,
        finalRewards = {}
    }
    return self
end

function UseItemDirectRewardGet:doGetReward(func)
    local exp = self._role:getAttr("exp")
    local luck = self._role:getFinalAttr("luck")
    local kongfu = self._role:getKongfu()
    local lv = self._role:getLv()

    self._record["rCondi"] = {
        exp = exp,
        luck = luck,
        kongfu = kongfu,
        lv = lv
    }

    local rewards = {}
    local rewardRecordList = {}
    if not MapIsEmpty(self._item.rewardID) and not MapIsEmpty(self._item.rewardPR) then
        local str = ""
        for k, v in pairs(self._item.rewardPR) do
            if k ~= 1 then
                str = str .. ";"
            end
            str = str .. v
        end
        -- 随机奖励
        local rwID = Helper:RandomIndexByPercentWithString(str)

        local rewardIds = string.split(self._item.rewardID[rwID], ",")

        for i, rid in ipairs(rewardIds) do
            local reward = RewardManager:getFinalRewardWithRewarId(rid, exp, luck, kongfu, lv)
            table.insert(rewards, reward)
            table.insert(
                rewardRecordList,
                {
                    rid = rid,
                    reward = reward
                }
            )
        end

        if table.getn(rewards) > 0 then
            func(rewards)

            self._record.finalRewards = rewardRecordList
        end
        self:__submitRecord()
    end
end

function UseItemDirectRewardGet:__submitRecord()
    if self._role ~= User:getRole() then
        --@desc 非玩家本身角色不记录
        return 
    end
    Record:addLogData(Record.RECORD_TYPE.USE_ITEM_REWARD, self._record)
end

return newClass("UseItemDirectRewardGet", {}, UseItemDirectRewardGet)
0000000000