--[[
    author:Seven
    time:2023-06-25 14:03:23
    desc: 奖励打开处理策略
]]
local RewardGetStrategyFunc = {}

function RewardGetStrategyFunc.rewardArrayWithRewardScheme(rsids, env, exp, luck, kongfu)
    assert(table.getn(rsids) > 0, "RewardGetStrategyFunc.rewardArrayWithRewardScheme rsids must be not empty")

    local recordItemList = {}

    local finaleRewardArray = {}

    for i, rsid in ipairs(rsids) do
        local rewardArray, record = RewardManager:getRewardArrayWithRewardScheme(rsid, exp, luck, kongfu)

        if not MapIsEmpty(rewardArray) then
            table.insert(recordItemList, record)
            for i, reward in ipairs(rewardArray) do
                table.insert(finaleRewardArray, reward)
            end
        end
    end

    return finaleRewardArray, recordItemList
end

function RewardGetStrategyFunc.mapRewardArrayWithRewardSchemeArray(__ridArray, env, exp, luck, kongfu)
    assert(env.mapid, "RewardGetStrategyFunc.mapRewardArrayWithRewardSchemeArray env.mapid must be not nil")
    
    assert(table.getn(__ridArray) > 0, "RewardGetStrategyFunc.mapRewardArrayWithRewardSchemeArray __ridArray must be not empty")

    local rewardArray, rewardRecordList = RewardManager:getMapRewardArrayWithRewardSchemeArray(env.mapid, __ridArray, exp, luck, kongfu)

    return rewardArray, rewardRecordList
end

return RewardGetStrategyFunc
0000