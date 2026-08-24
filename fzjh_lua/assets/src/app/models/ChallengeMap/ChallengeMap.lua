local LogSystem = require("app.models.LogSystem.LogSystem")
local class = require("third.class.NewClass")
local BaseMap = require("app.models.map.BaseMap")
local AsyncFunction = require("third.async.AsyncFunction")
local AsyncFunctions = require("third.async.AsyncFunctions")
local AsyncConditionGroup = require("third.async.AsyncConditionGroup")
local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")
local ChallengeMapConstant = require("app.models.ChallengeMap.ChallengeMapConstant")

--@RefType [src.app.models.ChallengeMap.ConditionAndResultInput#ConditionAndResultInput]
local ConditionAndResultInput = require("app.models.ChallengeMap.ConditionAndResultInput")

local function mergeResult(resultMap, result)
    for k, v in pairs(result) do
        if resultMap[k] == nil then
            resultMap[k] = {}
        end
        table.insert(resultMap[k], v)
    end
end

local function mergeResultMap(resultMap, addResultMap)
    if not MapIsEmpty(addResultMap) then
        for k, v in pairs(addResultMap) do
            if resultMap[k] == nil then
                resultMap[k] = {}
            end

            table.appendArray(resultMap[k], v)
        end
    end
end

local printDepth = 0

local ChallengeMap = {}

function ChallengeMap:create(data)
    local p = ChallengeMap.new(data)
    BaseMap.ctor(p)

    p:init()
    return p
end

function ChallengeMap:ctor()
    -- 异步函数列表
    self.__asyncFunctionList = {}
    -- 输出
    self.__output = nil -- 输出
end

function ChallengeMap:setOutput(output)
    assert(output ~= nil, "ChallengeMap:setOutput() - output is nil")
    self.__output = output
end

function ChallengeMap:init()
end

--[[
    @desc: 获取对象, 包括角色和物品
    author:TangJian
    time:2021-12-09 18:02:08
    --@objectId: 对象id为角色id或者物品id
    @return: 对象或角色
]]
function ChallengeMap:getObject(objectId)
    local role = self.objects[objectId]

    if role == nil then
        LogSystem:log("找不到角色:", tostring(objectId))
        role = {name = "找不到角色", type = "role", baseId = "default"}
    end

    -- 记录是否初始化, 只需要初始化一次
    if role._inMapInited == nil or role._inMapInited == false then
        -- baseId 判断不能省去（飞贼任务）
        if role.type == "role" then
            -- NPC属性修改
            if role.baseId ~= nil then
                local npc = self.__objectDataMap[role.baseId]
                if npc == nil then
                    npc = Npc:getNpc("guxudaozhang")
                end

                role = table.cloneAndRemoveFunctions(role)
                role = inherit(role, npc)
                role = Role:create(role)

                role:addSubModuleTo("RoleModule", "app.models.role.module.challengeMap.RoleChallengeMapNpcModule")
                if PRINT_MODE == 1 then
                    print("玩家名 = " .. tostring(role.name) .. "; 玩家队伍 = " .. tostring(role.teamMark))
                end
            end

            Npc:initSalesItem(role)

            -- 刷新npcbuff效果
            role:updateRoleBuff()

            --npc的血量和内力回满
            role.qi = role:getCurrQiMax()
            role.neili = role:getFinalAttr("neiliMax")
        elseif role.type == "item" then
            local BaseItem = require("app.models.item.BaseItem")
            role = inherit({}, role, BaseItem:create())
        else
            error("role type error")
        end

        Npc:initRoleIsForbidden(role)
        role._inMapInited = true

        self.objects[objectId] = role
    end
    return self.objects[objectId]
end

--@desc: 添加对象
--@author:LvBin
--@time:2022-01-07 17:22:55
--@return
function ChallengeMap:createObject(object)
    local objectId = object.id
    if self.objects[objectId] then
        print("副本已经有该对象了 objectId = " .. objectId)
    else
        self.objects[objectId] = object
    end
end

--[[
    @desc: 获取房间数据
    author:TangJian
    time:2021-12-16 12:18:30
    --@roomId: 
    @return:
]]
function ChallengeMap:getRoom(roomId)
    return assert(self.room[roomId], "找不到房间: " .. tostring(roomId))
end

--[[
    @desc: 获得房间对象列表, 包括角色和物品
    author:TangJian
    time:2021-12-09 18:03:32
    --@roomId: 
    @return:
]]
function ChallengeMap:getRoomObjectList(roomId)
    return table.mergeArray(self:getRoomRoles(roomId), self:getRoomItems(roomId))
end

--@desc: 获得房间角色列表
--@author:LvBin
--@time:2021-12-21 17:08:47
--@return
function ChallengeMap:getRoomRoles(roomId)
    return self.room[roomId].roomRoles
end

--@desc: 获得房间物品列表
--@author:LvBin
--@time:2021-12-21 17:09:42
--@roomId:
--@roleId:
--@return
function ChallengeMap:getRoomItems(roomId)
    return self.room[roomId].roomItems
end

--@desc: 移除房间对象, 包括角色和物品
--@author:LvBin
--@time:2021-12-21 16:39:23
--@roomId:
--@fromRoleId:
--@toRoleId:
--@return
function ChallengeMap:removeRoomObject(roomId, roleId)
    local object = self:getObject(roleId)
    local roomRoles = self:getRoomRoles(roomId)

    if object.type == "item" then
        roomRoles = self:getRoomItems(roomId)
    end

    if MapIsEmpty(roomRoles) == false then
        for i = table.getn(roomRoles), 1, -1 do
            if roomRoles[i] == roleId then
                table.remove(roomRoles, i)
                break
            end
        end
    end
end

--@desc: 添加房间对象, 包括角色和物品
--@author:LvBin
--@time:2021-12-21 16:45:29
--@roomId:
--@fromRoleId:
--@toRoleId:
--@return
function ChallengeMap:addRoomObject(roomId, roleId)
    local object = self:getObject(roleId)
    local roomRoles = self:getRoomRoles(roomId)

    if object.type == "item" then
        roomRoles = self:getRoomItems(roomId)
    end

    if MapIsEmpty(roomRoles) == false then
        for index, _objectId in ipairs(roomRoles) do
            if _objectId == roleId then
                print("房间中已存在该" .. tostring(roleId) .. "，不需要再次添加")
                return
            end
        end
    end

    table.insert(roomRoles, roleId)
end

--换人
function ChallengeMap:swapRoomRole(roomId, fromRoleId, toRoleId)
    local role = self:getObject(fromRoleId)
    local roomRoles = self:getRoomRoles(roomId)

    if role.type == "item" then
        roomRoles = self:getRoomItems(roomId)
    end

    if MapIsEmpty(roomRoles) == false then
        for index, _roleId in ipairs(roomRoles) do
            if _roleId == fromRoleId then
                roomRoles[index] = toRoleId
                break
            end
        end
    end
end

function ChallengeMap:getCurrRoomObjectList()
    return table.map(
        self:getRoomObjectList(self:getCurrRoomId()),
        function(objectId)
            return self:getObject(objectId)
        end
    )
end

--[[
    @desc: 进入房间改为异步请求
    author:TangJian
    time:2021-12-15 20:08:36
    --@fromRoomId:
	--@toRoomId:
	--@callback: 
    @return:
]]
function ChallengeMap:enterRoom(fromRoomId, toRoomId, callback)
    self:__addAsyncFunction(
        AsyncFunction:create(
            function(thread)
                if fromRoomId ~= self:getCurrRoomId() then
                    LogSystem:log("挑战副本", "点击太快")
                    thread:finish(false)
                end
                printDepth = printDepth + 1

                LogSystem:log("挑战副本", string.rep("  ", printDepth), "从房间", fromRoomId, "进入房间", toRoomId, "开始")

                local canEnterRoom = true
                local fromRoomResultMap = {}
                do
                    local input = ConditionAndResultInput:create()
                    input:setRoomId(fromRoomId)

                    input:setEventType(ChallengeMapConstant.EventType.PlayerInRoom)
                    input:setEventArgs({fromRoomId, toRoomId})

                    local asyncFunction = self:createExecuteRoomAutoConditionAndResultAsyncFunc(input)
                    fromRoomResultMap = asyncFunction:await()

                    if not MapIsEmpty(fromRoomResultMap.stop) then
                        for i, v in ipairs(fromRoomResultMap.stop) do
                            if v then
                                canEnterRoom = false
                                break
                            end
                        end
                    end
                end

                do
                    local input = ConditionAndResultInput:create()
                    input:setRoomId(toRoomId)

                    input:setEventType(ChallengeMapConstant.EventType.PlayerInRoom)
                    input:setEventArgs({fromRoomId, toRoomId})

                    local asyncFunction = self:createExecuteRoomAutoConditionAndResultAsyncFunc(input)
                    local resultMap = asyncFunction:await()

                    if not MapIsEmpty(resultMap.stop) then
                        for i, v in ipairs(resultMap.stop) do
                            if v then
                                canEnterRoom = false
                                break
                            end
                        end
                    end
                end

                if canEnterRoom then
                    if not MapIsEmpty(fromRoomResultMap.objectFollow) then
                        for i, v in ipairs(fromRoomResultMap.objectFollow) do
                            self:addRoomObject(toRoomId, v.roleId)
                            self:removeRoomObject(fromRoomId, v.roleId)
                        end
                    end

                    self.__lastRoomId = fromRoomId
                    self:setCurrRoomId(toRoomId)

                    LogSystem:log("挑战副本", string.rep("  ", printDepth), "从房间", fromRoomId, "进入房间", toRoomId, "成功")
                else
                    LogSystem:log("挑战副本", string.rep("  ", printDepth), "从房间", fromRoomId, "进入房间", toRoomId, "失败")
                end

                printDepth = printDepth - 1
                thread:finish(canEnterRoom)
            end
        ):onFinish(callback)
    )
end

--@desc: 执行初始房间条件结果
--@author:LvBin
--@time:2022-02-22 16:49:23
--@return
function ChallengeMap:executeDefaultRoomAutoConditionAndResult()
    local input = ConditionAndResultInput:create()

    input:setRoomId(self:getDefaultRoomId())

    self:createExecuteRoomAutoConditionAndResultAsyncFunc(input):await()
end

--[[
    @desc: 玩家切磋战斗
    author:TangJian
    time:2021-12-16 12:18:10
    --@defenderId:
	--@callback: [src.app.models.ChallengeMap.MapFightFinishCallback.AChallengeFinishCallback#AChallengeFinishCallback]
    @return:
]]
function ChallengeMap:playerChallengeFight(defenderId, callback)
    local ChallengeMapBattleRunner = require("app.models.ChallengeMap.MapBattle.ChallengeMapBattleRunner")

    ChallengeMapBattleRunner:runBattle(self, defenderId, callback:getFightFinishCallback())
end

--@desc: 
--@author:LvBin
--@time:2026-04-08 15:40:09
--@defenderId:
	--@callback: 
--@return
function ChallengeMap:playerChallengeOldFight(...)
    local ChallengeMapOldFightBuilder = require("app.models.ChallengeMap.MapBattle.ChallengeMapOldFightBuilder")

	ChallengeMapOldFightBuilder:startFight(self,...)
end


--[[
    @desc: 执行对象某个事件需要触发的条件结果
    author:TangJian
    time:2021-12-09 18:03:44
    --@objectId: 对象id
	--@index: 按钮编号
    @return:
]]
function ChallengeMap:executeObjectEventConditionAndResultGroup(objectId, operationIndex, finishCallback)
    self:__addAsyncFunction(self:__createExecuteObjectOperationConditionAndResultGroupAsyncFunc(objectId, operationIndex, finishCallback))
end

function ChallengeMap:__createExecuteObjectOperationConditionAndResultGroupAsyncFunc(objectId, operationIndex, finishCallback)
    return AsyncFunction:create(
        function(thread)
            printDepth = printDepth + 1
            local object = self:getObject(objectId)
            local conditionAndResultGroup = object.operationList[operationIndex]

            LogSystem:log("挑战副本", string.rep("  ", printDepth), "对", objectId, "执行操作", conditionAndResultGroup.caozuoName, "开始")

            assert(conditionAndResultGroup ~= nil, "ChallengeMap:executeObjectEventConditionAndResultGroup() - conditionAndResultGroup is nil")

            assert(objectId ~= nil, "ChallengeMap:__createExecuteObjectOperationConditionAndResultGroupAsyncFunc() - objectId is nil")

            -- 创建输入对象
            local input = ConditionAndResultInput:create()
            input:setRoomId(self:getCurrRoomId())
            input:setRoleId(objectId)

            local result =
                self:__createExecuteConditionAndResultGroupAsyncFunc(
                input,
                conditionAndResultGroup.condition.relation,
                conditionAndResultGroup.condition.conditions,
                conditionAndResultGroup.result,
                finishCallback
            ):await()

            LogSystem:log("挑战副本", string.rep("  ", printDepth), "对", objectId, "执行操作", conditionAndResultGroup.caozuoName, "完成")

            printDepth = printDepth - 1
            thread:finish(result)
        end
    ):onFinish(finishCallback)
end

--[[
    @desc: 执行房间内的条件结果
    author:TangJian
    time:2021-12-28 15:38:26
    --@input:
	--@finishCallback: 
    @return:
]]
function ChallengeMap:createExecuteRoomAutoConditionAndResultAsyncFunc(input, finishCallback)
    return AsyncFunction:create(
        function(thread)
            local roomId = input:getRoomId()
            local room = self.room[roomId]

            assert(room ~= nil, "ChallengeMap:executeRoomAutoConditionAndResult() - room is nil, roomId is"..tostring(roomId))

            local resultMap = {}

            for i, conditionGroupAndResult in ipairs(room.autoConditionAndResultList) do
                local asyncFunction =
                    self:__createExecuteConditionAndResultGroupAsyncFunc(
                    input,
                    conditionGroupAndResult.autoCondition.relation,
                    conditionGroupAndResult.autoCondition.conditions,
                    conditionGroupAndResult.autoResult
                )
                local addResultMap = asyncFunction:await()
                if type(addResultMap) == "table" then
                    mergeResultMap(resultMap, addResultMap)
                end
            end

            local objectList = self:getRoomObjectList(roomId)
            for i, objectId in ipairs(objectList) do
                local object = self:getObject(objectId)
                input:setRoleId(objectId)
                for i, conditionGroupAndResult in ipairs(object.autoConditionAndResultList) do
                    local asyncFunction =
                        self:__createExecuteConditionAndResultGroupAsyncFunc(
                        input,
                        conditionGroupAndResult.autoCondition.relation,
                        conditionGroupAndResult.autoCondition.conditions,
                        conditionGroupAndResult.autoResult
                    )
                    local addResultMap = asyncFunction:await()
                    if type(addResultMap) == "table" then
                        mergeResultMap(resultMap, addResultMap)
                    end
                end
            end

            thread:finish(resultMap)
        end
    ):onFinish(finishCallback)
end

--[[
    @desc: 执行条件结果组
    author:TangJian
    time:2021-12-28 15:37:33
    --@input:
	--@relation:
	--@conditions:
	--@results:
	--@finishCallback: 
    @return:
]]
function ChallengeMap:__createExecuteConditionAndResultGroupAsyncFunc(input, relation, conditions, results, finishCallback)
    return AsyncFunction:create(
        function(thread)
            local conditionIsTrue = self:__createExecuteConditionGroupAsyncFunc(input, relation, conditions):await()

            local resultMap = {}

            -- 条件成立则执行结果
            if conditionIsTrue then
                resultMap = self:createExecuteResultGroupAsyncFunc(input, results):await()
            end
            thread:finish(resultMap)
        end
    ):onFinish(finishCallback)
end

--[[
    @desc: 执行条件组
    author:TangJian
    time:2021-12-28 15:38:06
    --@input:
	--@relation:
	--@conditions: 
    @return:
]]
function ChallengeMap:__createExecuteConditionGroupAsyncFunc(input, relation, conditions)
    return AsyncFunction:create(
        function(thread)
            printDepth = printDepth + 1
            -- 条件为空,直接成立
            if #conditions == 0 then
                LogSystem:log("挑战副本", string.rep("  ", printDepth), "条件组执行开始：条件为空直接成功")
                printDepth = printDepth - 1
                thread:finish(true)
                return
            end

            LogSystem:log("挑战副本", string.rep("  ", printDepth), "条件组执行开始：", relation)

            local functions = {}
            for i, condition in ipairs(conditions) do
                table.insert(
                    functions,
                    function(thread)
                        printDepth = printDepth + 1
                        local conditionInput = inherit({}, input)
                        conditionInput:setArgs(condition.args)
                        conditionInput:setMap(self)
                        local asyncFunction = AsyncFunction:create(self:getConditionById(condition.type), conditionInput)
                        local result = asyncFunction:await()

                        if result then
                            LogSystem:log("挑战副本", string.rep("  ", printDepth), "条件成功：", condition)
                        else
                            LogSystem:log("挑战副本", string.rep("  ", printDepth), "条件失败：", condition)
                        end

                        printDepth = printDepth - 1

                        -- 阻塞等待
                        thread:finish(result)
                    end
                )
            end

            local ret = AsyncConditionGroup:create(relation, functions):await()

            if ret then
                LogSystem:log("挑战副本", string.rep("  ", printDepth), "条件组执行成功")
            else
                LogSystem:log("挑战副本", string.rep("  ", printDepth), "条件组执行失败")
            end

            printDepth = printDepth - 1
            thread:finish(ret)
        end
    )
end

--[[
    @desc: 执行结果列表
    author:TangJian
    time:2021-12-28 15:36:36
    --@input: 
	--@results: 结果列表
    @return:
]]
function ChallengeMap:createExecuteResultGroupAsyncFunc(input, results)
    return AsyncFunction:create(
        function(thread)
            printDepth = printDepth + 1
            -- 没有结果直接完成
            if #results == 0 then
                -- LogSystem:log("挑战副本", string.rep("  ", printDepth), "结果组执行开始:没有填写结果")
                printDepth = printDepth - 1
                thread:finish()
            end

            LogSystem:log("挑战副本", string.rep("  ", printDepth), "结果组执行开始:")

            local resultMap = {}
            local functions = {}

            for i, result in ipairs(results) do
                table.insert(
                    functions,
                    function(thread)
                        local resultInput = inherit({}, input)
                        resultInput:setArgs(result.args)
                        resultInput:setMap(self)
                        local asyncFunction = AsyncFunction:create(self:getResultById(result.type), resultInput)

                        LogSystem:log("挑战副本", string.rep("  ", printDepth), "结果执行：", result)

                        local ret = asyncFunction:await()

                        if not MapIsEmpty(ret) then
                            if ret[result.type] == nil then
                                error("ChallengeMap结果返回值如果不为空，则必须以结果名为key " .. tostring(result.type))
                            end
                        end

                        -- 阻塞等待
                        thread:finish(ret)
                    end
                )
            end

            local asyncFunctions = AsyncFunctions:create(functions)
            local results = asyncFunctions:await()
            for i, result in ipairs(results) do
                if type(result) == "table" then
                    mergeResult(resultMap, result)
                end
            end

            LogSystem:log("挑战副本", string.rep("  ", printDepth), "结果组执行完毕:", resultMap)

            printDepth = printDepth - 1

            thread:finish(resultMap)
        end
    )
end

function ChallengeMap:getConditionById(conditionId)
    return ChallengeMapSystem:getInstance():getConditionById(conditionId)
end

function ChallengeMap:getResultById(resultId)
    return ChallengeMapSystem:getInstance():getResultById(resultId)
end

function ChallengeMap:canDoNext()
    return #self.__asyncFunctionList == 0
end

function ChallengeMap:__addAsyncFunction(asyncFunction)
    -- 阻止交互
    self.__output:interactDisable()
    table.insert(self.__asyncFunctionList, asyncFunction)
end

function ChallengeMap:__executeAsyncFunctions()
    if #self.__asyncFunctionList > 0 then
        local asyncFunction = self.__asyncFunctionList[1]
        local isFinished, result = asyncFunction:tryGetResult()
        if isFinished then
            table.remove(self.__asyncFunctionList, 1)
        end
    end

    return #self.__asyncFunctionList
end

function ChallengeMap:__playerDie()
    BaseMap.__playerDie(self)
end

-- 调度器每帧执行一次
function ChallengeMap:update(ft)
    -- 执行异步操作队列
    if self:__executeAsyncFunctions() == 0 then
        self.__output:interactEnable()
    end
end

function ChallengeMap:refreshMap()
    self.__output:refreshMap()
end

function ChallengeMap:quit()
    self.__output:quit()
end

function ChallengeMap:asyncIsFinishMapFunc()
    local input = ConditionAndResultInput:create()
    input:setMap(self)

    local conditionGroup = self.finishId
    local relation = conditionGroup.relation
    local conditions = conditionGroup.conditions

    return self:__createExecuteConditionGroupAsyncFunc(input, relation, conditions)
end

function ChallengeMap:canLeaveMap(callback)
    self:__addAsyncFunction(
        AsyncFunction:create(
            function(thread)
                if self:asyncIsFinishMapFunc():await() then
                    thread:finish(true)
                end

                thread:finish(false)
            end
        ):onFinish(callback)
    )
end

function ChallengeMap:leaveMapAsync()
    return AsyncFunction:create(
        function(thread)
            thread:finish(true)
        end
    )
end

function ChallengeMap:playerKillRole(roomId, roleId)
    local currRole = self:getObject(roleId)

    --@desc withCorpse为0时，不生成尸体，直接移除
    if currRole.withCorpse == 0 then
        self:removeRoomObject(roomId, roleId)
        self:refreshMap()
        return
    end

    local player = self:getPlayer()
    local rewardIds = currRole:getDropSchemeIdArray()
    if table.getn(rewardIds) > 0 then
        --@RefType [src.app.models.Record.Reward.ARewardRecord#ARewardRecord]
        local ARewardRecord = require("app.models.Record.Reward.ARewardRecord")

        local rewardGet =
            require("app.models.reward.OpenRewardGet"):create(
            player,
            rewardIds,
            ARewardRecord.RTYPE.KILL_NPC_DROP,
            "mapRewardArrayWithRewardSchemeArray",
            {
                mapid = self.id,
                npcid = currRole.id
            }
        )
        rewardGet:doGetReward(
            function(rewardArray)
                for i, reward in ipairs(rewardArray) do
                    if reward.type == "物品" then
                        currRole:addItemCount(reward.id, reward.value)
                    elseif reward.type == "属性" then
                        player:addAttr(reward.id, reward.value)
                        self:richPrintText(player, reward.id, reward.value) -- 属性变化文本显示
                        PopText("获得" .. player:getCHAttrName(reward.id) .. tostring(reward.value))
                    end
                end
            end
        )
    end

    local items = currRole:getItems()

    local corpseDsc
    corpseDsc = currRole:getHeCall() .. "生前是" .. currRole.name .. "。\n\n"
    corpseDsc = corpseDsc .. "然而，" .. currRole:getHeCall() .. "已经死了，只剩下一具尸体静静的躺在这里。\n"

    if MapIsEmpty(items) == false then
        corpseDsc = corpseDsc .. currRole:getHeCall() .. "的遗物有："
        for i, roleItem in ipairs(items) do
            local item = Item:getOneItemByKey(roleItem.itemId)
            roleItem.name = item.name
            corpseDsc = corpseDsc .. "\n" .. tostring(item.name) .. " X" .. tostring(roleItem.count)
        end
    end

    local corpse = {
        type = "item",
        subType = "尸体",
        _inMapInited = true,
        aliveId = currRole.id, -- 活着的时候的id
        aliveName = currRole.name, -- 活着的时候的名字
        aliveDsc = currRole.dsc, -- 描述
        id = "尸体" .. tostring(Helper:getOnlyId()),
        name = "尸体",
        dsc = corpseDsc,
        items = items, -- 尸体里面的物品
        sex = currRole.sex,
        operationList = {
            {
                caozuoName = "提取",
                buttonShow = 1,
                condition = {relation = "and", conditions = {}},
                result = {{type = "extract", args = {}}}
            }
        },
        autoConditionAndResultList = {}
    }
    corpse = Role:create(corpse)
    self:createObject(corpse) -- 创建尸体
    self:swapRoomRole(roomId, currRole.id, corpse.id) -- 替换掉活着的人
    self:refreshMap()
end

--@desc: 添加定时器
--@author:LvBin
--@time:2022-08-25 11:36:51
--@input:
--@time: 计时时间
--@name: 计时器名字
--@resultList: 需要执行的结果列表
--@return
function ChallengeMap:addTimer(input, time, name, resultList)
    local timerTime = time
    local timerName = name
    local resultStrs = resultList
    local timerFlag = false

    if self.timerMap == nil then
        self.timerMap = {}
    end

    local timer = {}

    if self.timerMap[timerName] == nil then
        self.timerMap[timerName] = timer
    else
        timer = self.timerMap[timerName]
        if timer.delayFuncHandle ~= nil then
            self._mapLayer:stopActionByTag(timer.delayFuncHandle)
            timer.delayFuncHandle = nil
        end
        timer.flag = false
    end

    timer.time = timerTime
    timer.name = timerName
    timer.flag = timerFlag
    timer.sTime = GetTime()
    timer.resultStrs = resultStrs
    timer.backTime = Helper:getDef(BACKGROUND_TIME, 0)

    local function TimerFunc()
        timer.flag = true

        self._mapLayer:stopActionByTag(self.timerMap[timerName].delayFuncHandle)
        self.timerMap[timerName].delayFuncHandle = nil

        if timer.resultStrs ~= nil then
            local retResults = {}
            for index, result in ipairs(timer.resultStrs) do
                table.insert(
                    retResults,
                    {
                        type = result[1],
                        args = result[2]
                    }
                )
            end

            self:createExecuteResultGroupAsyncFunc(input, retResults):await()
        end
    end

    self.timerMap[timerName].delayFuncHandle = self._mapLayer:delayFunc(timerTime, TimerFunc)
end

function ChallengeMap:hidePanelWait()
    self.__output:hidePanelWait()
end

return class("ChallengeMap", {BaseMap}, ChallengeMap)
000000