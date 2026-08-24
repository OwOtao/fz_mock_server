local ChallengeMapConstant = require("app.models.ChallengeMap.ChallengeMapConstant")
local ChallengeMapResource = require("app.models.ChallengeMap.ChallengeMapResource")
local ChallengeMapConditions = {}

local function getFlagValue(input, flagId)
    local map = input:getMap()
    local flagType = ChallengeMapResource:getInstance():getFlagDataById(flagId).tabType
    local flagValue =
        switch(
        flagType,
        {
            [ChallengeMapConstant.FlagType.Map] = function()
                return map:getFlag(flagId)
            end,
            [ChallengeMapConstant.FlagType.Role] = function()
                local roleId = input:getRoleId()
                local role = map:getObject(roleId)
                return role:getFlag(flagId)
            end,
            [ChallengeMapConstant.FlagType.Player] = function()
                local player = map:getPlayer()
                return player:getFlag(flagId)
            end,
            [ChallengeMapConstant.FlagType.PlayerInherit] = function()
                local player = map:getPlayer()
                return player:getInheritFlag(flagId)
            end,
            [ChallengeMapConstant.FlagType.TimeLimit] = function()
                local player = map:getPlayer()
                return player:getTimeLimitFlag(flagId)
            end,
            default = function()
                error("找不到flagType:" .. tostring(flagType))
            end
        }
    )

    return flagValue
end

-- 无条件成立的条件
function ChallengeMapConditions.kick(thread, input)
    thread:finish(true)
end

--@desc:
--@author:LvBin
--@time:2021-12-22 20:20:21
--@thread:
--@input:
--@return
function ChallengeMapConditions.inroom(thread, input)
    local eventType = input:getEventType()
    local fromRoomId = input:getEventArgs()[1]
    local toRoomId = input:getEventArgs()[2]

    if eventType == ChallengeMapConstant.EventType.PlayerInRoom then
        if (input:getArgs()[1] == "any" or input:getArgs()[1] == fromRoomId) and (input:getArgs()[2] == "any" or input:getArgs()[2] == toRoomId) then
            thread:finish(true)
        end
    end

    thread:finish(false)
end

--@desc: 玩家是否完成副本
--@author:LvBin
--@time:2021-12-22 11:44:51
--@thread:
--@input:
--@return
function ChallengeMapConditions.clearing(thread, input)
    local map = input:getMap()
    if map:asyncIsFinishMapFunc():await() then
        thread:finish(true)
    end

    thread:finish(false)
end

-- 挑战胜利条件判断
function ChallengeMapConditions.challengewin(thread, input)
    local eventType = input:getEventType()
    local eventRoleId = input:getEventArgs()[1]
    local conditionRoleId = input:getArgs()[1]

    if eventType == ChallengeMapConstant.EventType.ChallengeWin then
        if conditionRoleId == eventRoleId then
            thread:finish(true)
        end
    end

    thread:finish(false)
end

-- 挑战失败条件判断
function ChallengeMapConditions.challengelose(thread, input)
    local eventType = input:getEventType()
    local eventRoleId = input:getEventArgs()[1]
    local conditionRoleId = input:getArgs()[1]

    if eventType == ChallengeMapConstant.EventType.ChallengeLose then
        if conditionRoleId == eventRoleId then
            thread:finish(true)
        end
    end

    thread:finish(false)
end

--@desc: 切磋且战斗逃跑
--@author:LvBin
--@time:2021-12-21 15:01:24
--@thread:
--@input:
--@return
function ChallengeMapConditions.challengeout(thread, input)
    local eventType = input:getEventType()
    local eventRoleId = input:getEventArgs()[1]
    local conditionRoleId = input:getArgs()[1]

    if eventType == ChallengeMapConstant.EventType.ChallengeRunaway then
        if conditionRoleId == eventRoleId then
            thread:finish(true)
        end
    end

    thread:finish(false)
end

--@desc: 决斗胜利条件判断
--@author:LvBin
--@time:2021-12-21 15:13:24
--@thread:
--@input:
--@return
function ChallengeMapConditions.duelwin(thread, input)
    local eventType = input:getEventType()
    local eventRoleId = input:getEventArgs()[1]
    local conditionRoleId = input:getArgs()[1]

    if eventType == ChallengeMapConstant.EventType.DuelWin then
        if conditionRoleId == eventRoleId then
            thread:finish(true)
        end
    end

    thread:finish(false)
end

--@desc: 决定逃跑
--@author:LvBin
--@time:2021-12-21 15:47:14
--@thread:
--@input:
--@return
function ChallengeMapConditions.duelout(thread, input)
    local eventType = input:getEventType()
    local eventRoleId = input:getEventArgs()[1]
    local conditionRoleId = input:getArgs()[1]

    if eventType == ChallengeMapConstant.EventType.DuelRunaway then
        if conditionRoleId == eventRoleId then
            thread:finish(true)
        end
    end

    thread:finish(false)
end

--@desc: 指定物品大于
--@author:LvBin
--@time:2021-12-16 15:43:41
--@thread:
--@input:
--@return
function ChallengeMapConditions.itemgreater(thread, input)
    local itemList = input:getArgs()
    local map = input:getMap()
    local player = map:getPlayer()

    local itemId = itemList[1]
    local itemCount = itemList[2]
    if player:getItemCount(itemId) > itemCount then
        thread:finish(true)
    else
        thread:finish(false)
    end
end

--@desc: 指定物品等于
--@author:LvBin
--@time:2021-12-16 15:44:18
--@thread:
--@input:
--@return
function ChallengeMapConditions.itemequal(thread, input)
    local itemList = input:getArgs()
    local map = input:getMap()
    local player = map:getPlayer()
    local itemId = itemList[1]
    local itemCount = itemList[2]
    if player:getItemCount(itemId) == itemCount then
        thread:finish(true)
    else
        thread:finish(false)
    end
end

--@desc: 指定物品小于
--@author:LvBin
--@time:2021-12-16 15:44:49
--@thread:
--@input:
--@return
function ChallengeMapConditions.itemless(thread, input)
    local itemList = input:getArgs()
    local map = input:getMap()
    local player = map:getPlayer()
    local itemId = itemList[1]
    local itemCount = itemList[2]
    if player:getItemCount(itemId) < itemCount then
        thread:finish(true)
    else
        thread:finish(false)
    end
end

--@desc: 玩家门派属于此门派
--@author:LvBin
--@time:2021-12-21 15:09:21
--@thread:
--@input:
--@return
function ChallengeMapConditions.menpai(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local roleFamilyId = player:getFamilyId()

    local familyId = input:getArgs()[1]
    if roleFamilyId == familyId then
        thread:finish(true)
    else
        thread:finish(false)
    end
end

--@desc: 玩家门派不属于此门派
--@author:LvBin
--@time:2021-12-16 15:45:20
--@thread:
--@input:
--@return
function ChallengeMapConditions.menpain(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local roleFamilyId = player:getFamilyId()

    local familyId = input:getArgs()[1]
    if roleFamilyId ~= familyId then
        thread:finish(true)
    else
        thread:finish(false)
    end
end

--@desc: 指定标记不等于
--@author:LvBin
--@time:2021-12-22 16:26:43
--@thread:
--@input:
--@return
function ChallengeMapConditions.unEqualTab(thread, input)
    local flagList = input:getArgs()

    if getFlagValue(input, flagList[1]) ~= flagList[2] then
        thread:finish(true)
    end

    thread:finish(false)
end

--@desc: 指定标记等于
--@author:LvBin
--@time:2021-12-16 16:46:32
--@thread:
--@input:
--@return
function ChallengeMapConditions.equalTab(thread, input)
    local flagList = input:getArgs()

    if getFlagValue(input, flagList[1]) == flagList[2] then
        thread:finish(true)
    end

    thread:finish(false)
end

--@desc: 指定标记大于
--@author:LvBin
--@time:2023-02-16 16:53:35
--@thread:
--@input:
--@return
function ChallengeMapConditions.tabgr(thread, input)
    local flagList = input:getArgs()

    if getFlagValue(input, flagList[1]) > flagList[2] then
        thread:finish(true)
    end

    thread:finish(false)
end

--@desc: 指定标记小于
--@author:LvBin
--@time:2023-02-16 16:53:35
--@thread:
--@input:
--@return
function ChallengeMapConditions.tablt(thread, input)
    local flagList = input:getArgs()

    if getFlagValue(input, flagList[1]) < flagList[2] then
        thread:finish(true)
    end

    thread:finish(false)
end

--@desc: 条件组
--@author:LvBin
--@time:2021-12-27 16:49:58
--@thread:
--@input:
--@return
function ChallengeMapConditions.conditionGroup(thread, input)
    local map = input:getMap()
    local args = input:getArgs()[1]
    local relation = args[1]
    local conditions = {}

    for i = 2, #args do
        local conditionType = args[i][1]
        local conditionArgs = {}
        for index = 2, #args[i] do
            table.insert(conditionArgs, args[i][index])
        end
        local condition = {
            type = conditionType,
            args = conditionArgs
        }
        table.insert(conditions, condition)
    end

    local ok = map:__createExecuteConditionGroupAsyncFunc(input, relation, conditions):await()

    thread:finish(ok)
end

--@desc: 背包当前格数大于等于多少
--@author:LvBin
--@time:2022-08-24 17:58:16
--@thread:
--@input:
--@return
function ChallengeMapConditions.baggr(thread, input)
    local count = input:getArgs()[1]
    local map = input:getMap()
    local player = map:getPlayer()
    local itemsCount = #player:getItems()
    local roleWeight = player:getAttr("weight")

    if roleWeight - itemsCount >= count then
        thread:finish(true)
    else
        thread:finish(false)
    end
end

--@desc: 背包当前格数小于多少
--@author:LvBin
--@time:2022-08-24 18:13:39
--@thread:
--@input:
--@return
function ChallengeMapConditions.baglt(thread, input)
    local count = input:getArgs()[1]
    local map = input:getMap()
    local player = map:getPlayer()
    local itemsCount = #player:getItems()
    local roleWeight = player:getAttr("weight")

    if roleWeight - itemsCount < count then
        thread:finish(true)
    else
        thread:finish(false)
    end
end

--@desc: 性别判断
--@author:LvBin
--@time:2024-01-03 15:10:52
--@thread:
--@input:
--@return
function ChallengeMapConditions.sex(thread, input)
    local sex = input:getArgs()[1]
    local map = input:getMap()
    local player = map:getPlayer()
    local roleSex = player:getAttr("sex")

    if sex == roleSex then
        thread:finish(true)
    else
        thread:finish(false)
    end
end

--@desc: 角色等级大于
--@author:LvBin
--@time:2024-08-27 17:16:38
--@thread:
--@input:
--@return
function ChallengeMapConditions.lvgreater(thread, input)
    local lv = input:getArgs()[1]
    local map = input:getMap()
    local player = map:getPlayer()

    local roleLv = player:getAttr("lv")

    thread:finish(roleLv > lv)
end

--@desc: 角色等级等于
--@author:LvBin
--@time:2024-08-27 17:16:38
--@thread:
--@input:
--@return
function ChallengeMapConditions.lvequal(thread, input)
    local lv = input:getArgs()[1]
    local map = input:getMap()
    local player = map:getPlayer()

    local roleLv = player:getAttr("lv")

    thread:finish(roleLv == lv)
end

--@desc: 角色等级小于
--@author:LvBin
--@time:2024-08-27 17:16:38
--@thread:
--@input:
--@return
function ChallengeMapConditions.lvless(thread, input)
    local lv = input:getArgs()[1]
    local map = input:getMap()
    local player = map:getPlayer()

    local roleLv = player:getAttr("lv")

    thread:finish(roleLv < lv)
end

local _roleStatusTagCondition = function(_role,funcName ,symbol,tagId, tagValue)
    local func = _role[funcName]
    local player_value = func(_role, tagId)
    local ret =
        switch(
        symbol,
        {
            ["="] = function()
                if player_value == tonumber(tagValue) then
                    return true
                end
            end,
            [">"] = function()
                if player_value > tonumber(tagValue) then
                    return true
                end
            end,
            ["<="] = function()
                if player_value <= tonumber(tagValue) then
                    return true
                end
            end,
            ["<"] = function()
                if player_value < tonumber(tagValue) then
                    return true
                end
            end,
            [">="] = function()
                if player_value >= tonumber(tagValue) then
                    return true
                end
            end,
            ["!="] = function()
                if player_value ~= tonumber(tagValue) then
                    return true
                end
            end,
            default = function()
                error("玩家状态标识判断 参数错误 ， 不支持的符号 " .. tostring(symbol))
            end
        }
    )
    if ret == nil then
        ret = false
    end
    return ret
end

local _playerstatustagcondido = function (thread,input , funcName)
    local tagId = input:getArgs()[1]
    local value = tonumber(input:getArgs()[2])
    local symbol = input:getArgs()[3]
    assert(tagId, "playertimestatustagscondi arg[1] tagId is nil")
    assert(value, "playertimestatustagscondi arg[2] value is nil")
    assert(symbol, "playertimestatustagscondi arg[3] symbol is nil")

    local map = input:getMap()
    local player = map:getPlayer()
    local ret = _roleStatusTagCondition(player, funcName, symbol, tagId, value)

    if ret then
        thread:finish(true)
    else
        thread:finish(false)
    end
end

local _npcstatustagcondido = function (thread,input , funcName)
    local tagId = input:getArgs()[1]
    local value = tonumber(input:getArgs()[2])
    local symbol = input:getArgs()[3]
    assert(tagId, "npcstatustagscondi arg[1] tagId is nil")
    assert(value, "npcstatustagscondi arg[2] value is nil")
    assert(symbol, "npcstatustagscondi arg[3] symbol is nil")

    local map = input:getMap()
    local roleId = input:getRoleId()
    local role = map:getObject(roleId)
    local ret = _roleStatusTagCondition(role, funcName, symbol, tagId, value)

    if ret then
        thread:finish(true)
    else
        thread:finish(false)
    end
end

function ChallengeMapConditions.playerstatustagscondi(thread,input)
    return _playerstatustagcondido(thread,input,"getRoleStatusTags")
end

function ChallengeMapConditions.playerinheritstatustagscondi(thread, input)
    return _playerstatustagcondido(thread,input,"getInheritRoleStatusTags")
end

function ChallengeMapConditions.npcstatustagscondi(thread, input)
    return _npcstatustagcondido(thread,input,"getNpcStatusTags")
end

function ChallengeMapConditions.playertimestatustagscondi(thread,input)
    _playerstatustagcondido(thread,input, "getTimeStatusTags")
end

function ChallengeMapConditions.playerinherittimestatustagscondi(thread,input)
    _playerstatustagcondido(thread,input, "getInheritTimeStatusTags")
end

function ChallengeMapConditions.mapstatustagscondi(thread, input)
    local tagId = input:getArgs()[1]
    local value = tonumber(input:getArgs()[2])
    local symbol = input:getArgs()[3]
    assert(tagId, "npcstatustagscondi arg[1] tagId is nil")
    assert(value, "npcstatustagscondi arg[2] value is nil")
    assert(symbol, "npcstatustagscondi arg[3] symbol is nil")

    local map = input:getMap()
    local ret = _roleStatusTagCondition(map, "getMapStatusTags", symbol, tagId, value)

    if ret then
        thread:finish(true)
    else
        thread:finish(false)
    end
end

return ChallengeMapConditions
00000