--[[
    author:Seven
    time:2023-06-20 17:56:17
    desc: 基础策略奖励记录
]]
local newClass = require("third.class.NewClass")

local ARewardRecord = require("app.models.Record.Reward.ARewardRecord")

--@SuperType [src.app.models.Record.Reward.ARewardRecord#ARewardRecord]
local BaseRewardRecord = {}

function BaseRewardRecord:create(stype)
    return BaseRewardRecord.new():__init(stype)
end

function BaseRewardRecord:__init(stype)
    self._env = {}
    self:setType(stype)
    return self
end

function BaseRewardRecord:setEnv(key, value)
    if self._env[key] then
        error("BaseRewardRecord env key is exist : " .. key)
    end

    self._env[key] = value
end

function BaseRewardRecord:setCondition(value)
    return self:setEnv("rCondi",value)
end

function BaseRewardRecord:_envSerialize()
    return self._env
end

return newClass("BaseRewardRecord", {ARewardRecord}, BaseRewardRecord)
00000000