--[[
    author:Seven
    time:2023-06-21 21:05:48
    desc: 直接打开奖励策略奖励获取，（针对奖励策略表使用）
]]
local newClass = require("third.class.NewClass")
--@RefType [src.app.models.Record.Reward.ARewardRecord#ARewardRecord]
local ARewardRecord = require("app.models.Record.Reward.ARewardRecord")

local BaseRewardRecord = require("app.models.Record.Reward.BaseRewardRecord")

local RewardGetStrategyFunc = require("app.models.reward.RewardGetStrategyFunc")

local Record = require("app.models.Record.Record")

local OpenRewardGet = {}

function OpenRewardGet:create(role, ridArray, recordType, strategy, env)
    return OpenRewardGet.new():__init(role, ridArray, recordType, env, strategy)
end

function OpenRewardGet:__init(role, ridArray, recordType, env, strategy)
    self._role = role

    local recordType = assert(recordType, "recordType must be not nil")

    --@RefType [src.app.models.Record.Reward.BaseRewardRecord#BaseRewardRecord]
    self.__record = BaseRewardRecord:create(recordType)

    self.__env = env

    if not MapIsEmpty(env) then
        for k, v in pairs(env) do
            self.__record:setEnv(k, v)
        end
    end

    assert(table.getn(ridArray) > 0, "ridArray must be not empty")

    assert(RewardGetStrategyFunc[strategy], "startegy must be not nil or startegy must be in RewardGetStrategyFunc : " .. strategy)

    self.__ridArray = ridArray

    self.__strategy = strategy

    return self
end

function OpenRewardGet:doGetReward(doFunc)
    local exp = self._role:getAttr("exp")
    local luck = self._role:getFinalAttr("luck")
    local kongfu = self._role:getKongfu()

    self._rewardCondition = {
        exp = exp,
        luck = luck,
        kongfu = kongfu
    }

    self.__record:setCondition(self._rewardCondition)

    local rewardArray, rewardRecordList = RewardGetStrategyFunc[self.__strategy](self.__ridArray, self.__env, exp, luck, kongfu)

    if not MapIsEmpty(rewardArray) then
        doFunc(rewardArray)

        for i, v in ipairs(rewardRecordList) do
            self.__record:addRewardRecordItem(v)
        end

        for i, reward in ipairs(rewardArray) do
            self.__record:addFinnalReward(reward)
        end
    end

    self:__submitRecord()
end

function OpenRewardGet:__submitRecord()
    if self._role ~= User:getRole() then
        --@desc 非玩家本身角色不记录
        return
    end
    Record:addLogData(Record.RECORD_TYPE.STRA_REWARD, self.__record:serialize())
end

return newClass("OpenRewardGet", {}, OpenRewardGet)
00000