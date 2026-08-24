local LaBaShiZhou_2021 = {}

function LaBaShiZhou_2021:getNpcList(npcList,num_1,num_2)
    local npcNum = math.random(num_1,num_2)
    local randomNpc = {}
    local npcRecord = {}
    local currNpcNum = 0

    while(currNpcNum < npcNum)
    do
        local npc_index = math.random(1,#npcList)
        if npcRecord[npcList[npc_index]] ~= true then
            table.insert(randomNpc,npcList[npc_index])
            npcRecord[npcList[npc_index]] = true
            currNpcNum = currNpcNum + 1
        end
    end
    return randomNpc
end

function LaBaShiZhou_2021:createLaBaShiZhouNpc(npcId)
    local role = Npc:createTaskNpc(npcId)
    role.labaId = npcId  --策划配置的npcid
    role.canKill = false
    role.caozuo1 = true
    role.caozuoName1 = "施粥"
    role.caozuo2 = true
    role.caozuoName2 = "驱赶"
    role.conditionAndResults =
    {
        {
            conditionRelation = "and",
            conditions =
            {
                {
                    arg1 = "玩家操作",
                    arg2 = "操作1",
                }
            },
            results =
            {
                {
                    arg1 = "施粥",
                },
            },
        },
        {
            conditionRelation = "and",
            conditions =
            {
                {
                    arg1 = "玩家操作",
                    arg2 = "操作2",
                }
            },
            results =
            {
                {
                    arg1 = "驱赶",
                },
            },
        },
    }

    return role
end

function LaBaShiZhou_2021:checkIsRefreshNpc()
    if self.currNpcNum <= 0 then
        return true
    end

    if GetTime() > self.singleStartTime + self.singleRefreshTime then
        return true
    end

    return false
end

function LaBaShiZhou_2021:checkIsEnd()
    return self.endTime < GetTime()
end

function LaBaShiZhou_2021:startGame()
    self.gameScore = 0
    self.shizhouNpcList = {}
end

function LaBaShiZhou_2021:setEndTime(endTime)
    self.endTime = endTime
end

function LaBaShiZhou_2021:setSingleRefreshTime(refreshTime)
    self.singleRefreshTime = refreshTime
end

function LaBaShiZhou_2021:setSingleNpcList(npcList)
    self.singleNpcList = npcList
end

function LaBaShiZhou_2021:startSingleGame(npcNum)
    self.currNpcNum = npcNum
    self.singleStartTime = GetTime()
end

function LaBaShiZhou_2021:checkIsRepeat(labaId)
    if not self.shizhouNpcList then
        self.shizhouNpcList = {}
    end

    for k,v in ipairs(self.shizhouNpcList) do
        if labaId == v then
            return true
        end
    end

    return false
end

function LaBaShiZhou_2021:shizhou(labaId,func)
    local isRepeat = self:checkIsRepeat(labaId)
    if isRepeat == false then
        self.gameScore = self.gameScore + 1
    else
        self.gameScore = math.max(self.gameScore - 1,0)
    end

    print("---------self.gameScore:",self.gameScore)

    self.currNpcNum = self.currNpcNum - 1

    table.insert(self.shizhouNpcList,labaId)

    if func then
        func(isRepeat)
    end

    Helper:print_lua_table(self.shizhouNpcList)
end

function LaBaShiZhou_2021:qugan(labaId,func)
    local isRepeat = self:checkIsRepeat(labaId)
    if isRepeat == false then
        self.gameScore = math.max(self.gameScore - 1,0)
    else
        self.gameScore = self.gameScore + 1
    end

    print("---------self.gameScore:",self.gameScore)

    self.currNpcNum = self.currNpcNum - 1

    if func then
        func(isRepeat)
    end

    Helper:print_lua_table(self.shizhouNpcList)
end

function LaBaShiZhou_2021:removeNpc(npcId)
    for k,v in ipairs(self.singleNpcList) do
        if npcId == v then
            v = nil
            break
        end
    end
end

function LaBaShiZhou_2021:getSingleNpcList()
    return self.singleNpcList
end

function LaBaShiZhou_2021:getRewardId()
    local rewardId
    if self.gameScore < 11 then
        rewardId = "21labashizhoujiangli1"
    elseif self.gameScore < 25 then
        rewardId = "21labashizhoujiangli2"
    elseif self.gameScore < 36 then
        rewardId = "21labashizhoujiangli3"
    else
        rewardId = "21labashizhoujiangli4"
    end
    return rewardId
end

return LaBaShiZhou_20210000000000000