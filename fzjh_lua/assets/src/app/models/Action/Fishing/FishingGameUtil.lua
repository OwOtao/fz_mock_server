local FishingGameUtil = {}

local FishingTable = require("script.others.fishing.lua")["fish"]
local FishingAward = require("script.others.fishing.lua")["fishaward"]
local kiteReward = require("script.others.fishing.lua")["kitereward"]


function FishingGameUtil:getRandomFishId()
    local weightList = {
        [1] = self:getFishAttr("101").fishprobability,
        [2] = self:getFishAttr("102").fishprobability,
        [3] = self:getFishAttr("103").fishprobability,
        [4] = self:getFishAttr("104").fishprobability,
        [5] = self:getFishAttr("105").fishprobability
    }

    local random = Helper:RandomByWeight(weightList)
    local resultTab = {
		[1] = "101",
		[2] = "102",
		[3] = "103",
		[4] = "104",
		[5] = "105",
	}
    local fishId = resultTab[random]
    --43次保底锦鲤
    if User:getRole():getInheritFlag("weekslcd_gameTimes") >=42 then 
        fishId = "101"
        User:getRole():setInheritFlag("weekslcd_gameTimes",0)
    end
    return fishId
end

function FishingGameUtil:getFishAttr(fishId)
    return assert(FishingTable[fishId],"fishId = "..fishId)
end

function FishingGameUtil:getAwardList()
    local list = {}
    for k,v in pairs(FishingAward) do
        if v and tonumber(v.id) <500 then 
            table.insert( list,v)
        end
    end
    table.sort(list, function(a, b)
        return a.id < b.id
    end)

    return list
end

function FishingGameUtil:cheakFishIsEnough(fishId,num)
    local role = User:getRole()
    local fishTab = role:getInheritFlag("周活钓鱼玩法结果")
    if fishTab == 0 or nil then
        return false
    end

    if not MapIsEmpty(fishTab) then
        if fishTab[fishId] and fishTab[fishId] >= num then
            return true
        end
    end

    return false
end

--鱼类兑换
function FishingGameUtil:fishExchange(fishId,num)
    local role = User:getRole()
    local fishTab = role:getInheritFlag("周活钓鱼玩法结果")
    if fishTab == 0 or nil then
        return
    end

    if not MapIsEmpty(fishTab) then
        if fishTab[fishId] and fishTab[fishId] >= num then
            fishTab[fishId] = fishTab[fishId] - num
        else
            print("检查为什么鱼不足之前没有判断出来")
        end
    end

    role:setInheritFlag("周活钓鱼玩法结果",fishTab)

    --记录兑换的鱼
    local logTab = {}
    local fishName = self:getFishAttr(fishId).fishname
    logTab[fishName] = -num
    local Record = require("app.models.Record.Record")
    Record:addLog(1,logTab,"fishing")
end

--卖鱼列表
function FishingGameUtil:getShopFishList()
    local fishMarketList={}
    for k,v in pairs(FishingTable) do 
        table.insert(fishMarketList,v)
    end
    table.sort(fishMarketList,function(a, b)
        a.fishPrice = a.fishPrice or 0
        b.fishPrice = b.fishPrice or 0
        if a.fishPrice == b.fishPrice then 
            return a.id<b.id
        else
            return a.fishPrice > b.fishPrice
        end
    end)
    return fishMarketList
end

--获取赠鱼列表
function FishingGameUtil:getFishGiftToNpcList()
    local currTask={}
    if User:getRole():getDayFlag("赠鱼任务id")== 0 then
        currTask=self:getCurrTaskOfFishGift()
        if MapIsEmpty(currTask) then 
            print("获取赠鱼任务 出错")
            return currTask
        end
        User:getRole():setDayFlag("赠鱼任务id",currTask.id)
    else
        currTask=self:getCurrTaskOfFishGift(User:getRole():getDayFlag("赠鱼任务id"))
    end
    
    if MapIsEmpty(currTask) then 
        print("获取赠鱼任务 出错")
        return 
    end
    local taskFishList=currTask.fishNeed  --101, 1;105, 1
    taskFishList=string.split(taskFishList, ";")
    local FishGiftToNpcList={}
    for k,v in ipairs(taskFishList) do 
        if v then 
            local currFishInfo={}
            currFishInfo=string.split(v, ",")
            if #currFishInfo<2 then 
                print("策划配置有问题")
            end
            currFishInfo["id"]=currFishInfo[1] or 101
            currFishInfo["num"]=tonumber(currFishInfo[2]) or 1
            table.insert(FishGiftToNpcList,currFishInfo)
        end
    end
    return FishGiftToNpcList
end

--获取赠鱼任务
function FishingGameUtil:getCurrTaskOfFishGift(fishTaskId)

    local currTaskList={}
    local taskWeightList={}
    for k,v in pairs(FishingAward) do
        if MapIsEmpty(v)==false and tonumber(v.id) >500 then
            currTaskList[v.id]=v
            taskWeightList[v.id]=v.fishPr
        end
    end
    if fishTaskId and fishTaskId ~="" and fishTaskId ~=0 then 
        return currTaskList[fishTaskId]
    end
    local randomTaskId = Helper:RandomByWeight(taskWeightList)
    print("当前 赠鱼任务 randomTaskId:",randomTaskId)
    return currTaskList[randomTaskId]
end

--风筝兑换奖励
function FishingGameUtil:getKiteRewardList()
    local kiteRewardList={}

    if MapIsEmpty(kiteReward) then 
        return kiteRewardList
    end
    
    for k,v in pairs(kiteReward) do 
        table.insert(kiteRewardList,v)
    end
    -- table.sort(kiteRewardList,function(a, b)
    --     a.fishPrice = a.fishPrice or 0
    --     b.fishPrice = b.fishPrice or 0
    --     if a.fishPrice == b.fishPrice then 
    --         return a.id<b.id
    --     else
    --         return a.fishPrice > b.fishPrice
    --     end
    -- end)
    return kiteRewardList
end

return FishingGameUtil0000000000000000