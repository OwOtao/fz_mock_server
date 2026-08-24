local activityData = require("script.others.Keepsakes")["token"]
local TokenExchangeActivityUtils = {}

   -- {
    --     rewardName = "YEL奖励1NOR",
    --     rewardInfo = {
    --         ["items1"] = 2,
    --         ["items1"] = 2,
    --     },
    --     needItemNum = 10,
    --     needItemId = "xinwu",
    --     rewardStage = 1,
    --     rewardIndex = 1,
    --     maxIndexInStage = false
    -- }

function TokenExchangeActivityUtils:getAllExchangeInfos()
    local stageExchangeInfos = {}

    for k,v in pairs(activityData) do
        local info = {}
        info.rewardInfo = self:getOneExchangeRewards(v)
        info.rewardName = v.rewardname
        info.needItemNum = v.num
        info.needItemId = v.item
        info.rewardIndex = v.id
        info.rewardStage = v.stage
        info.maxIndexInStage = v.id == self:getOneStageExchangeMaxIndex(v.stage)
        info.minIndexInStage = v.id == self:getOneStageExchangeMinIndex(v.stage)
        info.rewardText = v.rewardtext
        table.insert(stageExchangeInfos,info)
    end

    return stageExchangeInfos
end

function TokenExchangeActivityUtils:getStageExchangeInfos(stage)
    assert(stage,"TokenExchangeActivityUtils:getstageExchangeInfos "..tostring(stage))
    local stageExchangeInfos = {}

    for k,v in pairs(activityData) do
        if stage == v.stage then
            local info = {}
            info.rewardInfo = self:getOneExchangeRewards(v)
            info.rewardName = v.rewardname
            info.needItemNum = v.num
            info.needItemId = v.item
            info.rewardIndex = v.id
            info.rewardStage = v.stage
            info.maxIndexInStage = v.id == self:getOneStageExchangeMaxIndex(v.stage)
            info.minIndexInStage = v.id == self:getOneStageExchangeMinIndex(v.stage)
            info.rewardText = v.rewardtext
            table.insert(stageExchangeInfos,info)
        end
    end

    return stageExchangeInfos
end

function TokenExchangeActivityUtils:getOneStageExchangeMaxIndex(stage)
    assert(stage,"TokenExchangeActivityUtils:getOneExchangeInfo "..tostring(stage))
    local maxIndex
    for k,v in pairs(activityData) do
        if stage == v.stage then
            if not maxIndex then
                maxIndex = v.id
            else
                maxIndex = math.max(maxIndex,v.id)
            end
        end
    end
    return maxIndex
end

function TokenExchangeActivityUtils:getOneStageExchangeMinIndex(stage)
    assert(stage,"TokenExchangeActivityUtils:getOneExchangeInfo "..tostring(stage))
    local minIndex
    for k,v in pairs(activityData) do
        if stage == v.stage then
            if not minIndex then
                minIndex = v.id
            else
                minIndex = math.min(minIndex,v.id)
            end
        end
    end
    return minIndex
end

function TokenExchangeActivityUtils:getOneExchangeRewards(exchangeInfo)
    local rewardItems = {}
    if MapIsEmpty(exchangeInfo) == false then
        --目前设定单个奖励最多有10个
        
        for i = 1,10 do
            if exchangeInfo["reward"..tostring(i)] then
                local reward_str = string.split(exchangeInfo["reward"..tostring(i)],",")
                local itemAttr = Item:getOneItemByKey(reward_str[1])
                if itemAttr then
                    rewardItems[reward_str[1]] = tonumber(reward_str[2])
                end
            end 
        end
    end
    return rewardItems
end

function TokenExchangeActivityUtils:getConfig(stage)
    if not stage then
        return self:getAllExchangeInfos()
    end
    if stage > self:getMaxStage() then
        stage = self:getMaxStage()
    end
    return self:getStageExchangeInfos(stage)
end


function TokenExchangeActivityUtils:sortTable(stageExchangeInfos)
    table.sort(stageExchangeInfos,function(a,b)
        if a.isReward and not b.isReward then
            return false
        elseif not a.isReward and b.isReward then
            return true
        else
            if a.rewardIndex < b.rewardIndex then
                return true
            else
                return false
            end
        end
    end)
end

function TokenExchangeActivityUtils:getMaxStage()
    local maxStage = 1
    for k,v in pairs(activityData) do
        maxStage = math.max(maxStage,v.stage)
    end

    return maxStage
end

return TokenExchangeActivityUtils000000