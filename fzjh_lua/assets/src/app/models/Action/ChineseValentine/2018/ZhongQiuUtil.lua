local ZhongQiuUtil = {}

local awardRoomList = { fb214_06 = true, fb214_11 = true }

local maxDayCount = 10

local maxCount = 70

local rewardList = {
    exp = {
        condtion = true,
        value = 2000,
    },
    pot = {
        condtion = true,
        value = 2000,
    },
    yueli = {
        condtion = function(self,isFamily)
            return not isFamily
        end,
        value = function(self,isWin)
            if isWin then
                return 30
            else
                return 15
            end
        end,
    },
    prestige = {
        condtion = function(self,isFamily)
            return isFamily
        end,
        value = function(self,isWin)
            if isWin then
                return 30
            else
                return 15
            end
        end,
    },
}

local print = function(...)
    if DEBUG_MODE == 1 then
        print(...)
    end
end
local function getRewardCondition(currRoomId,fightResult,dayCount,allCount)
    if ZHONGQIU_2018_IS_OPEN ~= true then
        return false
    end
    if DEBUG_MODE == 1 then
        return true
    end
    if GetTime() < Helper:getTimeStampWithStringDate("20210919", 0) or GetTime() > Helper:getTimeStampWithStringDate("20211003", 0) then
        print("不是活动时间")
        return false
    end

    if currRoomId == nil or fightResult == nil then
        return false
    end

    if awardRoomList[currRoomId] ~= true then
        print("不是活动房间")
        return false
    end

    if dayCount and dayCount >= maxDayCount then
        print("当日次数达到上限")
        return false
    end

    if allCount and allCount >= maxCount then
        print("总次数达到上限")
        return false
    end

    return true
end

local function getConditon(reward,cond_1)
    local canReward
    if type(reward.condtion) == "function" then
        canReward = reward:condtion(cond_1)
    else
        canReward = reward.condtion
    end
    return canReward
end

local function getValue(reward,cond_1)
    local value = 0
    if type(reward.value) == "function" then
        value = reward:value(cond_1)
    else
        value = reward.value
    end
    return value
end

local function getReward(role,cond_1,cond_2)
    for k,v in pairs(rewardList) do
        if k == "prestige" then
            local canReward = false
            canReward = getConditon(v,cond_1)

            if canReward then
                local value = 0
                value = getValue(v,cond_2)
                
                local FamilyPrestige=require("app.models.family.FamilyPrestige") 
                FamilyPrestige:addUserPrestige(value,"dengyuelou_PVP_reward",function (data)
                    local addPrestige = data.num
                    if addPrestige ~= nil and addPrestige ~= 0 then
                        PopText(role:getCHAttrName("prestige") .. " +" .. addPrestige)
                    end
                end)
            end
        else
            local canReward = false
            canReward = getConditon(v,cond_1)

            if canReward then
                local value = 0
                value = getValue(v,cond_2)
                role:addAttr(k,value)
                PopText(role:getCHAttrName(k) .. " +" .. value)
            end
        end
    end
end

--获得中秋比武奖励
-- fightResult 1,4 赢,2,5输 ,3平手，异常
function ZhongQiuUtil:getZhongQiuBiWuAward(currRoomId,fightResult)
    if DEBUG_MODE == 1 then
        print("fightResult = ",fightResult,"currRoomId = ",currRoomId)
    end

    local role = User:getRole()

    local dayCount = role:getDayFlag("ZhongQiuBiWu_reward_count")

    local allCount = role:getInheritFlag("2021_ZhongQiuBiWu_reward_allCount")

    local isTrue = getRewardCondition(currRoomId,fightResult,dayCount,allCount)

    if isTrue ~= true then
        return
    end

    local isFamily = false
    local isWin = false

    if role:hasFamily() then
        isFamily =true
    end

    if fightResult == 1 or fightResult == 4 then
        isWin = true
    elseif fightResult == 2 or fightResult == 5 then
        isWin = false
    else
        print("战斗结果异常")
        return
    end

    getReward(role,isFamily,isWin)
    --奖励次数
    role:setDayFlag("ZhongQiuBiWu_reward_count",dayCount + 1)

    role:setInheritFlag("2021_ZhongQiuBiWu_reward_allCount",allCount + 1)

end


return ZhongQiuUtil000000000000