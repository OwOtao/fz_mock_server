local ChallengeMapConstant = require("app.models.ChallengeMap.ChallengeMapConstant")
local ChallengeMapResource = require("app.models.ChallengeMap.ChallengeMapResource")
local ChallengeMapResults = {}

--[[
    @desc: 输出文本
    author:TangJian
    time:2021-12-14 15:11:45
    --@thread:
	--@input: [src.app.models.ChallengeMap.ConditionAndResultInput#ConditionAndResultInput]
	--@output: 
    @return:
]]
function ChallengeMapResults.doc(thread, input)
    local text = input:getArgs()[1]

    RichPrint("main", "YEL" .. text)

    thread:finish()
end

--@desc: 随机文本输出
--@author:LvBin
--@time:2021-12-21 19:28:38
--@thread:
--@input:
--@return
function ChallengeMapResults.redoc(thread, input)
    local textList = input:getArgs()
    local text = textList[math.random(1, #textList)]

    RichPrint("main", "YEL" .. text)

    thread:finish()
end

--@desc: 弹出文本
--@author:LvBin
--@time:2021-12-16 12:23:10
--@thread:
--@input: [src.app.models.ChallengeMap.ConditionAndResultInput#ConditionAndResultInput]
--@return
function ChallengeMapResults.tips(thread, input)
    local text = input:getArgs()[1]

    PopText(text)

    thread:finish()
end

-- 切磋
function ChallengeMapResults.challenge(thread, input)
    local roleId = input:getArgs()[1]
    local roomId = input:getRoomId()
    local map = input:getMap()
    local player = map:getPlayer()

    local fightFinish = false
    local eventType = nil

    --@RefType [src.app.models.ChallengeMap.MapFightFinishCallback.NormalChallengeFightFinishCallback#NormalChallengeFightFinishCallback]
    local finishCallback = require("app.models.ChallengeMap.MapFightFinishCallback.NormalChallengeFightFinishCallback"):create()

    finishCallback:setMapPlayee(player)

    finishCallback:setMap(map)

    finishCallback:setRoomId(roomId)

    finishCallback:setDefenderId(roleId)

    map:playerChallengeFight(roleId, finishCallback)

    while finishCallback:isFinish() == false do
        thread:yield()
    end

    local newInput = inherit({}, input)

    newInput:setEventType(finishCallback:getFightFinishEventTypt())

    newInput:setEventArgs({roleId})

    local asyncFunction = map:createExecuteRoomAutoConditionAndResultAsyncFunc(newInput)
    asyncFunction:await()

    thread:finish()
end

--@desc: 决斗
--@author:LvBin
--@time:2021-12-21 15:38:47
--@thread:
--@input:
--@return
function ChallengeMapResults.duel(thread, input)
    local roleId = input:getArgs()[1]
    local roomId = input:getRoomId()
    local map = input:getMap()
    local player = map:getPlayer()

    local fightFinish = false
    local eventType = nil

    --@RefType [src.app.models.ChallengeMap.MapFightFinishCallback.DuelChallengeFightCallback#DuelChallengeFightCallback]
    local finishCallback = require("app.models.ChallengeMap.MapFightFinishCallback.DuelChallengeFightCallback"):create()

    finishCallback:setMapPlayee(player)

    finishCallback:setMap(map)

    finishCallback:setRoomId(roomId)

    finishCallback:setDefenderId(roleId)

    map:playerChallengeFight(roleId, finishCallback)

    while finishCallback:isFinish() == false do
        thread:yield()
    end

    local newInput = inherit({}, input)

    newInput:setEventType(finishCallback:getFightFinishEventTypt())

    newInput:setEventArgs({roleId})

    local asyncFunction = map:createExecuteRoomAutoConditionAndResultAsyncFunc(newInput)

    asyncFunction:await()

    thread:finish()
end

function ChallengeMapResults.stop(thread, input)
    thread:finish({stop = true})
end

-- 换人
function ChallengeMapResults.change(thread, input)
    local fromRoleId = input:getArgs()[1]
    local toRoleId = input:getArgs()[2]
    local roomId = input:getRoomId()
    local map = input:getMap()

    map:swapRoomRole(roomId, fromRoleId, toRoleId)
    map:refreshMap()

    thread:finish()
end

--@desc: 对象移动到指定房间
--@author:LvBin
--@time:2021-12-21 16:34:45
--@thread:
--@input:
--@return
function ChallengeMapResults.objectMove(thread, input)
    local args = input:getArgs()
    local map = input:getMap()
    local currRoomId = input:getRoomId()
    local objectId = args[1]
    local roomId = args[2]

    map:addRoomObject(roomId, objectId)
    map:removeRoomObject(currRoomId, objectId)

    map:refreshMap()

    thread:finish()
end

--@desc: 对象移动到随机房间
--@author:LvBin
--@time:2022-08-24 18:15:30
--@thread:
--@input:
--@return
function ChallengeMapResults.objectrMove(thread, input)
    local args = input:getArgs()
    local map = input:getMap()
    local currRoomId = input:getRoomId()
    local objectId = args[1]
    local weightList = args[2]
    local roomIdList = args[3]

    local roomId = roomIdList[Helper:RandomByWeight(weightList)]

    map:addRoomObject(roomId, objectId)
    map:removeRoomObject(currRoomId, objectId)

    map:refreshMap()

    thread:finish()
end

--@desc: 添加房间对象
--@author:LvBin
--@time:2021-12-21 17:45:41
--@thread:
--@input:
--@return
function ChallengeMapResults.addobject(thread, input)
    local args = input:getArgs()
    local map = input:getMap()
    local roomId = input:getRoomId()
    local objectId = args[1]

    map:addRoomObject(roomId, objectId)

    map:refreshMap()

    thread:finish()
end

--@desc: 移除房间对象
--@author:LvBin
--@time:2021-12-21 17:24:58
--@thread:
--@input:
--@return
function ChallengeMapResults.outobject(thread, input)
    local args = input:getArgs()
    local map = input:getMap()
    local roomId = input:getRoomId()
    local objectId = args[1]

    map:removeRoomObject(roomId, objectId)

    map:refreshMap()

    thread:finish()
end

--@desc: 添加背包道具
--@author:LvBin
--@time:2021-12-21 19:32:15
--@thread:
--@input:
--@return
function ChallengeMapResults.itemin(thread, input)
    local args = input:getArgs()
    local map = input:getMap()
    local player = map:getPlayer()

    local itemId = args[1]
    local num = args[2]
    player:addItemCount(itemId, num)

    thread:finish()
end

--@desc: 扣除背包道具
--@author:LvBin
--@time:2022-01-19 16:06:41
--@thread:
--@input:
--@return
function ChallengeMapResults.itemout(thread, input)
    local args = input:getArgs()
    local map = input:getMap()
    local player = map:getPlayer()

    local itemId = args[1]
    local num = args[2]
    player:addItemCount(itemId, -num)

    thread:finish()
end

--@desc: 传送玩家到指定房间
--@author:LvBin
--@time:2021-12-21 19:37:56
--@thread:
--@input:
--@return
function ChallengeMapResults.transfer(thread, input)
    local toRoomId = input:getArgs()[1]
    local roomId = input:getRoomId()
    local map = input:getMap()
    local player = map:getPlayer()

    if toRoomId ~= roomId then
        map.__output:entryRoom(roomId, toRoomId, "center")
    end

    thread:finish()
end

--@desc: 完成挑战副本，进入结算
--@author:LvBin
--@time:2021-12-22 11:35:51
--@thread:
--@input:
--@return
function ChallengeMapResults.outgame(thread, input)
    local map = input:getMap()
    map.__output:popMapFinishChoiceLayer()
    thread:finish()
end

--@desc: 设置对象按钮显示状态
--@author:LvBin
--@time:2021-12-22 15:52:26
--@thread:
--@input:
--@return
function ChallengeMapResults.showButton(thread, input)
    local map = input:getMap()
    local roleId = input:getRoleId()
    local object = map:getObject(roleId)
    local args = input:getArgs()

    local buttonIndex = args[1]
    local buttonIsShwo = args[2]
    if object.operationList[buttonIndex] then
        object.operationList[buttonIndex].buttonShow = buttonIsShwo
    end

    thread:finish()
end

--@desc: 执行当前房间和房间内角色条件结果
--@author:LvBin
--@time:2021-12-27 22:35:09
--@thread:
--@input:
--@return
function ChallengeMapResults.refresh(thread, input)
    local map = input:getMap()

    local asyncFunction = map:createExecuteRoomAutoConditionAndResultAsyncFunc(input)
    asyncFunction:await()

    thread:finish()
end

--@desc: 设置标记值
--@author:LvBin
--@time:2021-12-29 11:42:08
--@thread:
--@input:
--@return
function ChallengeMapResults.gainTab(thread, input)
    local map = input:getMap()
    local flagList = input:getArgs()
    local flagId = flagList[1]
    local flagValue = flagList[2]
    local flagType = ChallengeMapResource:getInstance():getFlagDataById(flagId).tabType
    switch(
        flagType,
        {
            [ChallengeMapConstant.FlagType.Map] = function()
                map:setFlag(flagId, flagValue)
            end,
            [ChallengeMapConstant.FlagType.Role] = function()
                local roleId = input:getRoleId()
                local role = map:getObject(roleId)
                role:setFlag(flagId, flagValue)
            end,
            [ChallengeMapConstant.FlagType.Player] = function()
                local player = map:getPlayer()
                player:setFlag(flagId, flagValue)
            end,
            [ChallengeMapConstant.FlagType.PlayerInherit] = function()
                local player = map:getPlayer()
                player:setInheritFlag(flagId, flagValue)
            end,
            [ChallengeMapConstant.FlagType.TimeLimit] = function()
                local player = map:getPlayer()
                player:setTimeLimitFlag(flagId, flagValue)
            end
        }
    )
    thread:finish()
end

--@desc: 删除标记
--@author:LvBin
--@time:2021-12-29 11:43:04
--@thread:
--@input:
--@return
function ChallengeMapResults.deleteTab(thread, input)
    local map = input:getMap()
    local flagId = input:getArgs()[1]
    local flagType = ChallengeMapResource:getInstance():getFlagDataById(flagId).tabType
    switch(
        flagType,
        {
            [ChallengeMapConstant.FlagType.Map] = function()
                map:setFlag(flagId, nil)
            end,
            [ChallengeMapConstant.FlagType.Role] = function()
                local roleId = input:getRoleId()
                local role = map:getObject(roleId)
                role:setFlag(flagId, nil)
            end,
            [ChallengeMapConstant.FlagType.Player] = function()
                local player = map:getPlayer()
                player:setFlag(flagId, nil)
            end,
            [ChallengeMapConstant.FlagType.PlayerInherit] = function()
                local player = map:getPlayer()
                player:setInheritFlag(flagId, nil)
            end,
            [ChallengeMapConstant.FlagType.TimeLimit] = function()
                local player = map:getPlayer()
                player:setTimeLimitFlag(flagId, 0)
            end
        }
    )
    thread:finish()
end

--@desc: 添加标记值
--@author:LvBin
--@time:2023-02-16 17:01:02
--@thread:
--@input:
--@return
function ChallengeMapResults.addtab(thread, input)
    local map = input:getMap()
    local flagId = input:getArgs()[1]
    local addValue = input:getArgs()[2]
    local flagType = ChallengeMapResource:getInstance():getFlagDataById(flagId).tabType
    switch(
        flagType,
        {
            [ChallengeMapConstant.FlagType.Map] = function()
                map:setFlag(flagId, map:getFlag(flagId) + addValue)
            end,
            [ChallengeMapConstant.FlagType.Role] = function()
                local roleId = input:getRoleId()
                local role = map:getObject(roleId)
                role:setFlag(flagId, role:getFlag(flagId) + addValue)
            end,
            [ChallengeMapConstant.FlagType.Player] = function()
                local player = map:getPlayer()
                player:setFlag(flagId, player:getFlag(flagId) + addValue)
            end,
            [ChallengeMapConstant.FlagType.PlayerInherit] = function()
                local player = map:getPlayer()
                player:setInheritFlag(flagId, player:getInheritFlag(flagId) + addValue)
            end,
            [ChallengeMapConstant.FlagType.TimeLimit] = function()
                local player = map:getPlayer()
                player:setTimeLimitFlag(flagId, player:getTimeLimitFlag(flagId) + addValue)
            end
        }
    )
    thread:finish()
end

--@desc: 减少标记值
--@author:LvBin
--@time:2023-02-16 17:01:02
--@thread:
--@input:
--@return
function ChallengeMapResults.cuttab(thread, input)
    local map = input:getMap()
    local flagId = input:getArgs()[1]
    local addValue = input:getArgs()[2]
    local flagType = ChallengeMapResource:getInstance():getFlagDataById(flagId).tabType
    switch(
        flagType,
        {
            [ChallengeMapConstant.FlagType.Map] = function()
                map:setFlag(flagId, math.max(map:getFlag(flagId) - addValue, 0))
            end,
            [ChallengeMapConstant.FlagType.Role] = function()
                local roleId = input:getRoleId()
                local role = map:getObject(roleId)
                role:setFlag(flagId, math.max(role:getFlag(flagId) - addValue, 0))
            end,
            [ChallengeMapConstant.FlagType.Player] = function()
                local player = map:getPlayer()
                player:setFlag(flagId, math.max(player:getFlag(flagId) - addValue, 0))
            end,
            [ChallengeMapConstant.FlagType.PlayerInherit] = function()
                local player = map:getPlayer()
                player:setInheritFlag(flagId, math.max(player:getInheritFlag(flagId) - addValue, 0))
            end,
            [ChallengeMapConstant.FlagType.TimeLimit] = function()
                local player = map:getPlayer()
                player:setTimeLimitFlag(flagId, math.max(player:getTimeLimitFlag(flagId) - addValue, 0))
            end
        }
    )
    thread:finish()
end

--@desc: 按钮选项
--@author:LvBin
--@time:2021-12-29 11:45:15
--@thread:
--@input:
--@return
function ChallengeMapResults.choice(thread, input)
    local map = input:getMap()
    local args = input:getArgs()
    local desc = args[1]
    local retArray = {}
    for i = 2, #args do
        local buttonName = args[i][1]
        local results = args[i][2]
        local retResults = {}
        for index, result in ipairs(results) do
            table.insert(
                retResults,
                {
                    type = result[1],
                    args = result[2]
                }
            )
        end

        table.insert(
            retArray,
            {
                buttonName = buttonName,
                callback = function()
                    map:createExecuteResultGroupAsyncFunc(input, retResults):await()
                end
            }
        )
    end
    PopupLayerController:showLayer(
        "ChoiceResultPresenter",
        function(layer)
            layer:setTextDesc(desc)
            layer:setListView(retArray)
            layer:showLayer()
        end
    )

    thread:finish()
end

--@desc: 限时按钮选项
--@author:LvBin
--@time:2023-02-21 15:02:54
--@thread:
--@input:
--@return
function ChallengeMapResults.timechoice(thread, input)
    local map = input:getMap()
    local args = input:getArgs()
    local desc = args[1]
    local time = tonumber(args[2])

    local defaultResults = {}

    local defaultResultList = args[3]

    for index, result in ipairs(defaultResultList) do
        table.insert(
            defaultResults,
            {
                type = result[1],
                args = result[2]
            }
        )
    end

    local defaultCallBack = function()
        map:createExecuteResultGroupAsyncFunc(input, defaultResults):await()
    end

    local retButtonArray = {}

    for i = 4, #args do
        local buttonName = args[i][1]
        local results = args[i][2]
        local retResults = {}
        for index, result in ipairs(results) do
            table.insert(
                retResults,
                {
                    type = result[1],
                    args = result[2]
                }
            )
        end

        table.insert(
            retButtonArray,
            {
                buttonName = buttonName,
                callback = function()
                    map:createExecuteResultGroupAsyncFunc(input, retResults):await()
                end
            }
        )
    end

    PopupLayerController:showLayer(
        "TimeChoiceResultPresenter",
        function(layer)
            layer:setTime(time)
            layer:setDesc(desc)
            layer:setButtonList(retButtonArray)
            layer:setDefaultCallBack(defaultCallBack)
            layer:showLayer()
        end
    )

    thread:finish()
end

--@desc: 玩家恢复气血
--@author:LvBin
--@time:2021-12-29 18:25:10
--@thread:
--@input:
--@return
function ChallengeMapResults.hpup(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local hpValue = input:getArgs()[1]

    player:addAttr("qi", hpValue)

    thread:finish()
end

--@desc: 玩家减少气血
--@author:LvBin
--@time:2021-12-29 18:26:14
--@thread:
--@input:
--@return
function ChallengeMapResults.hpdown(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local currHp = player:getAttr("qi")
    local hpValue = input:getArgs()[1]
    if currHp <= hpValue then
        hpValue = currHp - 1
    end

    player:addAttr("qi", -hpValue)

    thread:finish()
end

--@desc: 玩家回复内力
--@author:LvBin
--@time:2021-12-29 18:26:58
--@thread:
--@input:
--@return
function ChallengeMapResults.manaup(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local neiliValue = input:getArgs()[1]

    player:addAttr("neili", neiliValue)

    thread:finish()
end

--@desc: 玩家回复内力
--@author:LvBin
--@time:2021-12-29 18:27:58
--@thread:
--@input:
--@return
function ChallengeMapResults.manadown(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local neiliValue = input:getArgs()[1]

    player:addAttr("neili", -neiliValue)

    thread:finish()
end

--@desc: 玩家回复气血(最大值百分比)
--@author:LvBin
--@time:2021-12-29 18:30:58
--@thread:
--@input:
--@return
function ChallengeMapResults.hpupPCT(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local currQiMax = player:getAttr("qiMax")
    local hpPercent = input:getArgs()[1] / 100

    player:addAttr("qi", currQiMax * hpPercent)

    thread:finish()
end

--@desc: 玩家减少气血(最大值百分比)
--@author:LvBin
--@time:2021-12-30 11:42:05
--@thread:
--@input:
--@return
function ChallengeMapResults.hpdownPCT(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local currHp = player:getAttr("qi")
    local currQiMax = player:getAttr("qiMax")
    local hpPercent = input:getArgs()[1] / 100
    local hpValue = currQiMax * hpPercent

    if currHp <= hpValue then
        hpValue = currHp - 1
    end

    player:addAttr("qi", -hpValue)

    thread:finish()
end

--@desc: 玩家恢复内力(最大值百分比)
--@author:LvBin
--@time:2021-12-30 11:46:04
--@thread:
--@input:
--@return
function ChallengeMapResults.manaupPCT(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local neiliMax = player:getAttr("neiliMax")
    local neiliPercent = input:getArgs()[1] / 100

    player:addAttr("neili", neiliMax * neiliPercent)

    thread:finish()
end

--@desc: 玩家减少内力(最大值百分比)
--@author:LvBin
--@time:2021-12-30 11:47:32
--@thread:
--@input:
--@return
function ChallengeMapResults.manadownPCT(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local neiliMax = player:getAttr("neiliMax")
    local neiliPercent = input:getArgs()[1] / 100

    player:addAttr("neili", -neiliMax * neiliPercent)

    thread:finish()
end

--@desc: 提取对方身上物品
--@author:LvBin
--@time:2022-01-07 18:03:48
--@return
function ChallengeMapResults.extract(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local roleId = input:getRoleId()
    local currRole = map:getObject(roleId)
    local extractFinish = false

    local MapBagLayer = require("app.views.layer.MapLayer.MapBagLayer")

    local mapBagLayer = MapBagLayer:getInstance()

    mapBagLayer:show()

    mapBagLayer:setRoles(
        player,
        currRole,
        function()
            local corpseDsc = ""
            local items = currRole:getItems()
            corpseDsc = currRole:getHeCall() .. "生前是" .. currRole.aliveName .. "。\n\n"
            corpseDsc = corpseDsc .. "然而，" .. currRole:getHeCall() .. "已经死了，只剩下一具尸体静静的躺在这里。\n"

            if MapIsEmpty(items) == false then
                corpseDsc = corpseDsc .. currRole:getHeCall() .. "的遗物有："
                local length = #items
                if length > 6 then
                    length = 6
                end
                for i = 1, length do
                    local roleItem = items[i]
                    local item = Item:getOneItemByKey(roleItem.itemId)
                    roleItem.name = item.name
                    corpseDsc = corpseDsc .. "\n" .. tostring(item.name) .. " X" .. tostring(roleItem.count)
                end
            end

            currRole.dsc = corpseDsc

            extractFinish = true
        end
    )

    while extractFinish == false do
        thread:yield()
    end

    thread:finish()
end

--@desc: 房间内对象跟随玩家移动
--@author:LvBin
--@time:2022-01-17 14:29:19
--@thread:
--@input:
--@return
function ChallengeMapResults.objectFollow(thread, input)
    local map = input:getMap()
    local eventType = input:getEventType()
    local fromRoomId = input:getEventArgs()[1]
    local toRoomId = input:getEventArgs()[2]
    local roleId = input:getRoleId()
    local roomId = input:getRoomId()

    if eventType == ChallengeMapConstant.EventType.PlayerInRoom and fromRoomId == roomId then
        thread:finish({objectFollow = {roleId = roleId}})
    end

    thread:finish()
end

--@desc: 随机结果
--@author:LvBin
--@time:2022-08-24 16:41:30
--@thread:
--@input:
--@return
function ChallengeMapResults.rdresults(thread, input)
    local map = input:getMap()
    local args = input:getArgs()
    local weightList = args[1]
    local resultsList = args[2]

    local results = resultsList[Helper:RandomByWeight(weightList)]

    local retResults = {}
    for index, result in ipairs(results) do
        table.insert(
            retResults,
            {
                type = result[1],
                args = result[2]
            }
        )
    end

    map:createExecuteResultGroupAsyncFunc(input, retResults):await()

    thread:finish()
end

--@desc: 根据条件不同，执行符合条件的结果集。
--@author:LvBin
--@time:2022-08-25 10:40:15
--@thread:
--@input:
--@return
function ChallengeMapResults.itresults(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local args = input:getArgs()
    local itemId = args[1]
    local count = args[2]
    local logic = args[3]
    local roleItemCount = player:getItemCount(itemId)
    local sucResults = args[4]
    local defResults = args[5]
    local results = defResults
    if Helper:compareTwoNumberWithCN(roleItemCount, count, logic) == true then
        results = sucResults
    end

    local retResults = {}
    for index, result in ipairs(results) do
        table.insert(
            retResults,
            {
                type = result[1],
                args = result[2]
            }
        )
    end

    map:createExecuteResultGroupAsyncFunc(input, retResults):await()

    thread:finish()
end

--@desc: 添加定时器
--@author:LvBin
--@time:2022-08-25 11:41:41
--@thread:
--@input:
--@return
function ChallengeMapResults.timer(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local args = input:getArgs()
    local timerTime = tonumber(args[1])
    local timerName = args[2]
    local resultList = args[3]

    map:addTimer(input, timerTime, timerName, resultList)

    thread:finish()
end

--@desc: 延时
--@author:LvBin
--@time:2023-02-17 18:14:23
--@thread:
--@input:
--@return
function ChallengeMapResults.delayer(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local args = input:getArgs()
    local timerTime = tonumber(args[1])
    local text = args[2]

    map:hidePanelWait()

    local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")

    local waitingLayer = WaitingLayer:createInRunningScene()

    waitingLayer:show()

    waitingLayer:hidePanelWait()

    waitingLayer:setClickBackgroundFunc(
        function()
            PopText(text)
        end
    )

    thread:wait(timerTime)

    waitingLayer:hideAndRemoveSelf()

    waitingLayer = nil

    thread:finish()
end

--@desc: 结局动画文本播放
--@author:LvBin
--@time:2024-01-03 18:18:57
--@thread:
--@input:
--@return
function ChallengeMapResults.endinganimation(thread, input)
    local map = input:getMap()
    local animId = input:getArgs()[1]

    local resultAnims = ChallengeMapResource:getInstance():getResultAnimById(animId)

    PopupLayerController:showLayer(
        "DepartFromFamilyTextAnimLayer",
        function(layer)
            layer:setAnimInfo(resultAnims)
            layer:showLayer()
        end
    )

    thread:finish()
end

function ChallengeMapResults.fishing(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local fishingId = input:getArgs()[1]

    local fishingData = ChallengeMapResource:getInstance():getFishingDataById(fishingId)

    local finish = false
    PopupLayerController:showLayer(
        "FishingPresenter",
        function(layer)
            layer:setFishingData(fishingData)
            layer:setRole(player)
            layer:setFinishCallbackFunc(
                function()
                    finish = true
                end
            )
            layer:showLayer()
        end
    )

    while finish == false do
        thread:yield()
    end

    thread:finish()
end

function ChallengeMapResults.answer(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local answerId = input:getArgs()[1]

    local answerData = ChallengeMapResource:getInstance():getAnswerDataById(answerId)

    local finish = false

    PopupLayerController:showLayer(
        "AnswerPresenter",
        function(layer)
            layer:setAnswerData(answerData)
            layer:setRole(player)
            layer:setFinishCallbackFunc(
                function()
                    finish = true
                end
            )
            layer:showLayer()
        end
    )

    while finish == false do
        thread:yield()
    end

    thread:finish()
end

--@desc: 设置副本角色状态标识
--@author:Seven
--@time:2025-02-26 17:54:39
function ChallengeMapResults.playerstatustags(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local tagId = input:getArgs()[1]
    local tagValue = input:getArgs()[2]

    assert(tagId, "ChallengeMapResults.rolestatustag tagId is nil")

    assert(tonumber(tagValue), "ChallengeMapResults.rolestatustag tagValue is nil")

    player:setRoleStatusTags(tagId, tagValue)

    thread:finish()
end

function ChallengeMapResults.playerinheritstatustags(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local tagId = input:getArgs()[1]
    local tagValue = input:getArgs()[2]

    assert(tagId, "ChallengeMapResults.rolestatustag tagId is nil")

    assert(tonumber(tagValue), "ChallengeMapResults.rolestatustag tagValue is nil")

    player:setInheritRoleStatusTags(tagId, tagValue)

    thread:finish()
end

function ChallengeMapResults.playerinherittimestatustags(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local tagId = input:getArgs()[1]
    local tagValue = input:getArgs()[2]

    assert(tagId, "ChallengeMapResults.rolestatustag tagId is nil")

    assert(tonumber(tagValue), "ChallengeMapResults.rolestatustag tagValue is nil")

    player:setInheritTimeStatusTags(tagId, tagValue)

    thread:finish()
end

function ChallengeMapResults.playertimestatustags(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local tagId = input:getArgs()[1]
    local tagValue = input:getArgs()[2]

    assert(tagId, "ChallengeMapResults.rolestatustag tagId is nil")

    assert(tonumber(tagValue), "ChallengeMapResults.rolestatustag tagValue is nil")

    player:setTimeStatusTags(tagId, tagValue)

    thread:finish()
end

function ChallengeMapResults.npcstatustags(thread, input)
    local map = input:getMap()
    local roleId = input:getRoleId()
    local npc = map:getObject(roleId)
    local tagId = input:getArgs()[1]
    local tagValue = input:getArgs()[2]

    assert(tagId, "ChallengeMapResults.rolestatustag tagId is nil")

    assert(tonumber(tagValue), "ChallengeMapResults.rolestatustag tagValue is nil")

    npc:setNpcStatusTags(tagId, tagValue)

    thread:finish()
end

function ChallengeMapResults.mapstatustags(thread, input)
    local map = input:getMap()
    local tagId = input:getArgs()[1]
    local tagValue = input:getArgs()[2]

    assert(tagId, "ChallengeMapResults.rolestatustag tagId is nil")

    assert(tonumber(tagValue), "ChallengeMapResults.rolestatustag tagValue is nil")

    map:setMapStatusTags(tagId, tagValue)

    thread:finish()
end

function ChallengeMapResults.puzzle(thread, input)
    local gameId = input:getArgs()[1]

    PopupLayerController:showLayer(
        "PuzzleGamePresenter",
        function(layer)
            layer:setMap(input:getMap())
            layer:setBaseResult(input)
            layer:setGameId(gameId)
            layer:showLayer()
        end
    )

    thread:finish()
end

function ChallengeMapResults.addplayerbuff(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()

    local add_buff_id = input:getArgs()[1]

    assert(add_buff_id, "ChallengeMapResults.addPlayerbuff add_buff_id is nil")

    local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")

    ChallengeMapSystem:getInstance():getBuffSystem():addBuff(add_buff_id, player)

    thread:finish()
end

function ChallengeMapResults.deleteplayerbuff(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()

    local delete_buff_id = input:getArgs()[1]

    assert(delete_buff_id, "ChallengeMapResults.deletePlayerbuff delete_buff_id is nil")

    local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")

    ChallengeMapSystem:getInstance():getBuffSystem():removeBuff(delete_buff_id, player)

    thread:finish()
end

function ChallengeMapResults.oldchallenge(thread, input)
	local map = input:getMap()

    local player = map:getPlayer()

	local roleId = input:getArgs()[1]

	local npc = map:getObject(roleId)

	local combatidData = npc.combatid

    local idType = combatidData[1]

	local battleGroupId = combatidData[2]

	local levelId = combatidData[3]

	local npcFightData = ChallengeMapResource:getInstance():getNpcOldFightData(battleGroupId,levelId,map:getPlayer():getAttr("lv"))
	
	Npc:initNpc(npcFightData)

	local npc = Helper:tableCover(Role:create(), npcFightData)

    npc:updateRoleBuff()

	local finishCallback = function(fightPlayer)
		local qi = math.max(fightPlayer:getAttr("qi"),1)

		local neili = fightPlayer:getAttr("neili")

		local currQiMax = fightPlayer:getRole():getCurrQiMax()

		local qiPercent = fightPlayer:getAttr("qiPercent")

		qiPercent = math.max(qiPercent,1/fightPlayer:getAttr("qiMax"))

		--@desc 切磋结束，玩家血量至少恢复到20%
		if qi < currQiMax * 0.2 then
			qi = math.ceil(currQiMax * 0.2)
		end

		player:setAttr("qi", qi)

		player:setAttr("neili", neili)

		player:setAttr("qiPercent", qiPercent)
	end

	local winCallback = function()
		local newInput = inherit({}, input)
	
		newInput:setEventType(ChallengeMapConstant.EventType.ChallengeWin)
	
		newInput:setEventArgs({roleId})
	
		local asyncFunction = map:createExecuteRoomAutoConditionAndResultAsyncFunc(newInput)
		asyncFunction:await()
	end

	local loseCallback = function()
		local newInput = inherit({}, input)
	
		newInput:setEventType(ChallengeMapConstant.EventType.ChallengeLose)
	
		newInput:setEventArgs({roleId})
	
		local asyncFunction = map:createExecuteRoomAutoConditionAndResultAsyncFunc(newInput)
		asyncFunction:await()
	end

	map:playerChallengeOldFight(player,npc,finishCallback,winCallback,loseCallback)

    thread:finish()
end

function ChallengeMapResults.oldduel(thread, input)
	local map = input:getMap()

    local player = map:getPlayer()

	local roleId = input:getArgs()[1]

	local npc = map:getObject(roleId)

	local combatidData = npc.combatid

    local idType = combatidData[1]

	local battleGroupId = combatidData[2]

	local levelId = combatidData[3]

	local npcFightData = ChallengeMapResource:getInstance():getNpcOldFightData(battleGroupId,levelId,map:getPlayer():getAttr("lv"))
	
	Npc:initNpc(npcFightData)

	local npc = Helper:tableCover(Role:create(), npcFightData)

    npc:updateRoleBuff()

	local finishCallback = function(fightPlayer)
		local qi = math.max(fightPlayer:getAttr("qi"),1)

		local neili = fightPlayer:getAttr("neili")

		local qiPercent = fightPlayer:getAttr("qiPercent")

		player:setAttr("qi", qi)

		player:setAttr("neili", neili)

		player:setAttr("qiPercent", qiPercent)
	end

	local winCallback = function()
		local newInput = inherit({}, input)
	
		newInput:setEventType(ChallengeMapConstant.EventType.DuelWin)
	
		newInput:setEventArgs({roleId})
	
		local asyncFunction = map:createExecuteRoomAutoConditionAndResultAsyncFunc(newInput)
		asyncFunction:await()

		map:playerKillRole(input:getRoomId(), roleId)
	end

	local loseCallback = function()
		local newInput = inherit({}, input)
	
		newInput:setEventType(ChallengeMapConstant.EventType.DuelLose)
	
		newInput:setEventArgs({roleId})
	
		local asyncFunction = map:createExecuteRoomAutoConditionAndResultAsyncFunc(newInput)
		asyncFunction:await()

		PopupLayerController:showLayer(
			"ChallengeMapLosePresenter",
			function(layer)
				layer:setButtonLeave(
					"离开",
					function()
						local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")

						ChallengeMapSystem:getInstance():leaveTheMap(
							map,
							2,
							function(result, msg)
								if result then
									map:quit()
									layer:hideLayer()
								else
									PopText(msg)
								end
							end
						)
					end
				)
				layer:showLayer()
			end
		)
	end

	map:playerChallengeOldFight(player,npc,finishCallback,winCallback,loseCallback)

    thread:finish()
end

--@desc: 根据标记值数值，执行符合条件的结果集。
--@author:LvBin
--@time:2026-04-21 20:27:48
--@thread:
	--@input: 
--@return
function ChallengeMapResults.labelresult(thread, input)
    local map = input:getMap()
    local player = map:getPlayer()
    local args = input:getArgs()
    local flagId = args[1]
    local flagValue = args[2]
    local logic = args[3]
	local flagType = ChallengeMapResource:getInstance():getFlagDataById(flagId).tabType
    local roleFlagValue =
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
    local sucResults = args[4]
    local defResults = args[5]
    local results = defResults
    if Helper:compareTwoNumberWithCN(roleFlagValue, flagValue, logic) == true then
        results = sucResults
    end

    local retResults = {}
    for index, result in ipairs(results) do
        table.insert(
            retResults,
            {
                type = result[1],
                args = result[2]
            }
        )
    end

    map:createExecuteResultGroupAsyncFunc(input, retResults):await()

    thread:finish()
end

return ChallengeMapResults
00000000000000