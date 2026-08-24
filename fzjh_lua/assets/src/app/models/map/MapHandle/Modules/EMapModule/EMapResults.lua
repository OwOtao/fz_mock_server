--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local EMapResults = class("EMapResults", require("app.models.map.MapHandle.Modules.BaseModule"))

--@desc 子模块
EMapResults.childModule = {}

--@desc 条件结果的方法
EMapResults.doResult = {
    ["交谈"] = function(map, result, environment)
        local currRole = environment.currRole
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        local strList = currRole.words

        local str = ""
        if MapIsEmpty(strList) == false then
            str = strList[math.random(1, #strList)]
        end


        local StringUtil = require("app.extends.StringUtil")
        str = StringUtil:replaceNpcName(str,map)
        
        RichPrint("main", "YEL" .. currRole.name .. "：" .. str)
    end,
    ["对话"] = function(map, result, environment)
        local currRole = environment.currRole
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        local strs = result.arg2

        local strList = string.split(strs, ";")

        local str = ""
        if MapIsEmpty(strList) == false then
            str = strList[math.random(1, #strList)]
        end


        local StringUtil = require("app.extends.StringUtil")
        str = StringUtil:replaceNpcName(str,map)
        
        RichPrint("main", "YEL" .. currRole.name .. "：" .. str)
    end,
    ["操作集"] = function(map, result, environment)
        local operationStr = result.arg2
        if operationStr == nil then
            return
        end

        local operationList = string.split(operationStr, ";")

        local operations = {}
        if environment.currRole ~= nil then
            operations = environment.currRole.operations
        end

        if MapIsEmpty(operations) == true then
            local currRoom = map:getRoomAttr(environment.currRoomId)
            operations = currRoom.operations
        end

        if MapIsEmpty(operations) == true then
            return
        end

        for i, operationId in ipairs(operationList) do
            map:doOperationById(operationId, operations, environment)
        end
    end,
    ["执行操作ID"] = function(map, result, environment)
        local operationId = result.arg2

        if operationId == nil then
            return
        end

        local operations
        if environment.currRole ~= nil then
            operations = environment.currRole.operations
        end

        if MapIsEmpty(operations) == true then
            local currRoom = map:getRoomAttr(environment.currRoomId)
            operations = currRoom.operations
        end

        if MapIsEmpty(operations) == true then
            return
        end

        map:doOperationById(operationId, operations, environment)
    end,
    ["执行操作名字"] = function(map, result, environment)
        local operationName = result.arg2

        if operationName == nil then
            return
        end

        local operations
        if environment.currRole ~= nil then
            operations = environment.currRole.operations
        end

        if MapIsEmpty(operations) == true then
            local currRoom = map:getRoomAttr(environment.currRoomId)
            operations = currRoom.operations
        end

        if MapIsEmpty(operations) == true then
            return
        end

        map:doOperationByName(operationName, operations, environment)
    end,
    ["交易"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        local role = environment.currRole

        if role.isNewStore then
            local StoreHelper = require("app.models.Store.StoreHelper")
            if StoreHelper:checkStoreIsInTime(role.id) then
                PopupLayerController:showLayer("StorePresenter",function(layer)
                    layer:setRole(User:getRole())
                    layer:setStore(role)
                    layer:setStoreLeftBag(role.bagType, User:getRole())
                    layer:showLayer()
                    layer:setBackCallBackFunc(function()
                    end)
                end)
            else
                StoreHelper:PopEndText(role.id)
            end
        else
            local Chapman = require("app.models.Chapman.Chapman")

            -- 黑市商人
            if string.find(role.id, "chapman") ~= nil then
                PopupLayerController:showLayer("BlackStorePresenter",function(layer)
                    layer:setRole(User:getRole())
                    layer:showLayer()
                    layer:setBackCallBackFunc(function()
                    end)
                end)
            elseif Chapman:checkIsCkChapman(role) then
                Chapman:getCkChapmanStoreList(role)
            elseif string.find(role.id, "fb200r21_1") ~= nil then
                -- 制作组商人
                TransCheck:checkAllUrlTrans()
                local ZhiZuoZu = require("app.models.ZhiZuoZu.ZhiZuoZu")
                ZhiZuoZu:openZhiZuoZuChapman(role)
            elseif Chapman:checkIsDeadCurrency(role.baseId) or Chapman:checkIsChapmanForNew(role.baseId) then
                --冥币商人 改成新的npc商人
                Chapman:getNpcChapman(role)
            elseif Chapman:checkIsChapman(role.baseId) then
                -- 醉梦生商人
                Chapman:getChapmanList(role)
            elseif Chapman:checkIsPrestigeChapman(role) then 
            -- 声望商人
                Chapman:getPrestigeChapmanStoreList(role)
            else
                local MapBagLayer = require("app.views.layer.MapLayer.MapBagLayer")
                local layer = MapBagLayer:getInstance()
                layer:show()
                layer:setRoles(
                    player,
                    role,
                    function()
                        -- 刷新房间条件结果
                        -- if User:getRole():getCurrMapId() ~= "fb202" then
                        --     map:doRoomConditionAndResult(map:getCurrRoomId())
                        -- end
                    end
                )
            end
        end
        
    end,
    ["送礼"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())

        local role = environment.currRole

        local presentId = role.receivePresent -- npc接受的礼物
        print("此NPC接受的物品Id:", role.receivePresent)
        -- assert(presentId, "presentId 不能为空")

        --  已被装备的物品 并且背包只有一把 无法被送礼
        if player:checkItemIsEquipbyItemId(presentId) and player:getItemCount(presentId) < 2 then
            PopText("已装备物品无法送礼")
            return
        end

        if presentId then
            RichPrint("main", "CYN我不接受你的物品")
            return
        end

        local present = player:getItem(presentId)
        if present and player:getItemCount(presentId) > 0 then
            local itemAttr = Item:getOneItemByKey(presentId)
            --打印出送出去的礼物
            if itemAttr then
                RichPrint("main", "你送给" .. role.name .. "一" .. itemAttr.unit .. itemAttr.name)
            end

            player:addItemCount(presentId, -1)

            --送礼后 如果装备物品有多个并且该装备物品 背包排序在前，会先移除装备那把
            if player:checkItemIsEquipbyItemId(presentId) then
                PopText("你取下了身上的" .. itemAttr.name .. "并送给" .. role.name)
                player:setEquipByName("weapon", nil)
            end

            map:doOperationByName("赠送成功", role.operations, environment)
        else
            map:doOperationByName("赠送失败", role.operations, environment)
            RichPrint("main", "CYN我不接受你的物品")
        end

        map.__MapLayer:delayRefreshMap()
    end,
    ["打开物品"] = function(map, result, environment)
        --@TODO 打开物品 2019-01-03 14:09:10
    end,
    ["拾取物品"] = function(map, result, environment)
        local item = environment.currRole

        local itemId = item.baseId

        local count = tonumber(result.arg2)
        if count == nil then
            count = 1
        end

        local role = Helper:getDef(map:getPlayer(),User:getRole())
        if role:checkCanBuyThings(itemId, count, "bag") == false then
            return
        end

        role:addItemCount(itemId, count)

        map:removeRoomRole(environment.currRoomId, item.id)

        environment.mapLayer:delayRefreshMap()

        PopText("获得了 " .. role:getOneItemByKey(itemId).name .. " X" .. count)
    end,
    ["节点奖励"] = function(map, result, environment)
        --@desc 节点ID
        local nodeId = environment.nodeId
        --@desc 分支ID
        local branchId = environment.branchId
        --@desc 操作ID
        local operationId = environment.operationId

        if nodeId == nil or branchId == nil then
            print("节点ID或者分支ID为空，不可获得奖励。")
            return
        end

        local role = Helper:getDef(map:getPlayer(),User:getRole())

        --@desc 奖励类型
        local reward_type = result.arg2

        --@desc 奖励ID，策略奖励ID，但在同一operationId下必须唯一
        local reward_id = result.arg3

        --@desc 存档保存的索引
        local reward_index_id = map.id .. "_" .. branchId .. "_" .. nodeId .. "_" .. operationId .. "_" .. reward_id
        local nodeRewards = role:getAttr("nodeRewards")
        if nodeRewards[reward_index_id] then
            if PRINT_MODE == 1 then
                print("该节点奖励索引："..reward_index_id)
            end
            return
        end

        local rewardArray =
            RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(
            reward_id,
            role:getAttr("exp"),
            role:getFinalAttr("luck"),
            role:getKongfu()
        )

        if PRINT_MODE == 1 then
            print("该节点奖励详情：")
            Helper:print_lua_table(rewardArray)
        end

        for i, reward in ipairs(rewardArray) do
            if reward.type == "物品" then
                local itemId = reward.id
                local count = tonumber(reward.value)
                PopText("获得了 " .. role:getOneItemByKey(itemId).name .. " X" .. count)
                if role:checkCanBuyThings(itemId, count, "bag") == false then
                    --@TODO 2019-01-02 16:46:18 不能加入背包的物品
                    --@desc 检查背包情况，如果已满，丢地上
                    local roomId = environment.currRoomId
                    map:dropItem(roomId, itemId, count)
                else
                    role:addItemCount(itemId, count)
                end
            elseif reward.type == "属性" then
                local attr_name = reward.id
                local value = tonumber(reward.value)

                role:addAttr(attr_name, value)

                PopText("获得" .. role:getCHAttrName(attr_name) .. " + " .. tostring(value))
            else
                print("reward type is error ", reward.type)
            end
        end

        nodeRewards[reward_index_id] = reward_type
    end,
    ["设置节点标记"] = function(map, result, environment)
        local role = Helper:getDef(map:getPlayer(),User:getRole())
        local flagName = result.arg2
        local flagValue = tonumber(result.arg3)

        if flagName == nil then
            assert(false, "节点标记名字（arg2)不可为空")
        end

        if type(flagValue) ~= "number" then
            assert(false, "节点标记值（arg3) 只能是数字。")
        end

        role:setNodeFlag(map.id, flagName, flagValue)
    end,
    ["提取"] = function(map, result, environment)
        local User = require("app.models.user.User")

        local player = Helper:getDef(map:getPlayer(),User:getRole())

        local currRole = environment.currRole

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
                if currRole.killedBySkillName then
                    corpseDsc = corpseDsc .. "从尸体上的累累伤痕来看，分明是精通“" .. currRole.killedBySkillName .. "”绝技的江湖高手所为。\n\n"
                end

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
            end
        )
    end,
    ["修改房间操作可用"] = function(map, result, environment)
        -- 被修改的操作
        local roomId = result.arg2
        local operationId = result.arg3
        local isEnabled = tonumber(result.arg4)

        if roomId == nil then
            roomId = map:getCurrRoomId()
        end

        local room = map:getRoomAttr(roomId)

        if room == nil then
            return
        end

        local operations = room.operations

        if MapIsEmpty(operations) == true then
            return
        end

        for i, operation in ipairs(operations) do
            if operation.id == operationId then
                operation.isEnable = isEnabled
                break
            end
        end
    end,
    ["修改NPC操作属性可用"] = function(map, result, environment)
        -- 被修改的操作
        local npcId = result.arg2
        local operationId = result.arg3
        local isEnabled = tonumber(result.arg4)

        if npcId == nil then
            return
        end

        local npc = map:getRole(npcId)

        if npc == nil then
            return
        end

        local operations = npc.operations

        if MapIsEmpty(operations) then
            return
        end

        for i, operation in ipairs(operations) do
            if operation.id == operationId then
                operation.isEnable = isEnabled
                break
            end
        end
    end,
    ["修改NPC操作可见"] = function(map, result, environment)
        -- 被修改的操作
        local npcId = result.arg2
        local operationId = result.arg3
        local isVisible = tonumber(result.arg4)

        if npcId == nil then
            return
        end

        local npc = map:getRole(npcId)

        if npc == nil then
            return
        end

        local operations = npc.operations

        if MapIsEmpty(operations) then
            return
        end

        for i, operation in ipairs(operations) do
            if operation.id == operationId then
                operation.isVisible = isVisible
                break
            end
        end
    end,
    ["决斗"] = function(map, result, environment)
        local role = environment.currRole
        local player = Helper:getDef(map:getPlayer(),User:getRole())

        local currRoomId = environment.currRoomId
        
        --npc代打
        local currRoom = map:getRoomAttr(currRoomId)
        local npcId = currRoom.npcFight
        if npcId then
            player = map:getRole(npcId)

            --@desc 代打npc满状态
            player:setAttr("qiPercent", 1)
            player:setAttr("qi", player:getCurrQiMax())
            player:setAttr("neili", player:getFinalAttr("neiliMax"))
        end
        
        -- self.mapLayer:replaceRoom(self.mapLayer._currRoom.id, "center")
        -- map:removeTaskFromDelayTasks(role.id)

        -- role:initNpcAttr() -- NPC状态初始化

        --@desc 恢复满血状态
        role:setAttr("qiPercent", 1.0)
        role:setAttr("qi", role:getCurrQiMax())
        role:setAttr("neili", role:getFinalAttr("neiliMax"))

        map:afterFightWithShaSi(
            player,
            role,
            function(winTeamId)
                local operations = environment.currRole.operations

                if MapIsEmpty(operations) == true then
                    operations = environment.currRoom.operations
                    if MapIsEmpty(operations) == true then
                        return
                    end
                end

                -- 战斗胜利条件结果
                if winTeamId == 1 then
                    -- 玩家操作默认
                    role:setFlag("是否死亡", true)
                    map.__MapLayer:delayRefreshMap()

                    map:playerKillRole(currRoomId, role)

                    map:doOperationByName("决斗胜利", operations, environment)
                elseif winTeamId == 2 then
                    map:doOperationByName("决斗失败", operations, environment)
                    PopText("你被" .. role:getName() .. "打败了")

                    if map:getMapType() ~= MAP_TYPE.DREAMMAP and map:getMapType() ~= MAP_TYPE.FONDDREAMMAP then
                        map.__MapLayer.TotalMapBtn_IsInit = false
                        map.__MapLayer:quit()
                    end
                elseif winTeamId == 3 then
                    map:doOperationByName("逃跑", operations, environment)
                end

                --清除代打npc
                if currRoom.npcFight then
                    local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")
                    DreamTalentModel:clearNpcFight(map)

                    local text = switch(winTeamId,{
                        [1] = "少侠，那宵小武功低微，我已将之击退了！",
                        [2] = "在下虽已竭尽全力，但仍是敌不过这宵小。少侠多多保重，在下先走一步！",
                        [3] = "我不知道阁下所谓何意，既然如此，你便自己应对吧！",
                        default = ""
                    })
                    RichPrint("main",text)
                end
            end
        )
    end,
    ["切磋"] = function(map, result, environment)
        local role = environment.currRole
        local currRoomId = environment.currRoomId

        local player = Helper:getDef(map:getPlayer(),User:getRole())

        --npc代打
        local currRoom = map:getRoomAttr(currRoomId)
        local npcId = currRoom.npcFight
        if npcId then
            player = map:getRole(npcId)

            --@desc 代打npc满状态
            player:setAttr("qiPercent", 1)
            player:setAttr("qi", player:getCurrQiMax())
            player:setAttr("neili", player:getFinalAttr("neiliMax"))
        end 

        --@desc 恢复满血状态
        role:setAttr("qiPercent", 1.0)
        role:setAttr("qi", role:getCurrQiMax())
        role:setAttr("neili", role:getFinalAttr("neiliMax"))

        map:afterFightWithQieCuo(
            player,
            role,
            function(winTeamId)
                local operations = environment.currRole.operations

                if MapIsEmpty(operations) == true then
                    operations = environment.currRoom.operations
                end

                -- 战斗胜利条件结果
                if winTeamId == 1 then
                    -- 刷新房间条件结果
                    -- PopText("你战胜了" .. role:getName())

                    if MapIsEmpty(operations) == false then
                        map:doOperationByName("切磋胜利", operations, environment)
                    end

                    map.__MapLayer:delayRefreshMap()
                elseif winTeamId == 2 then
                    if MapIsEmpty(operations) == false then
                        map:doOperationByName("切磋失败", operations, environment)
                    end
                    -- PopText("你被" .. role:getName() .. "打趴在地")

                    map.__MapLayer:delayRefreshMap()
                elseif winTeamId == 3 then
                    if MapIsEmpty(operations) == false then
                        map:doOperationByName("逃跑", operations, environment)
                    end
                    map.__MapLayer:delayRefreshMap()
                end

                --清除代打npc
                if currRoom.npcFight then
                    local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")
                    DreamTalentModel:clearNpcFight(map)

                    local text = switch(winTeamId,{
                        [1] = "少侠，那宵小武功低微，我已将之击退了！",
                        [2] = "在下虽已竭尽全力，但仍是敌不过这宵小。少侠多多保重，在下先走一步！",
                        [3] = "我不知道阁下所谓何意，既然如此，你便自己应对吧！",
                        default = ""
                    })
                    RichPrint("main",text)
                end
            end
        )
    end,
    ["主动击杀玩家"] = function(map, result, environment)
        local currRole = environment.currRole
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        local currRoomId = environment.currRoomId
        if PRINT_MODE == 1 then
            print("environment.currRoomId = " .. tostring(environment.currRoomId))
        end

        -- 判断角色是否死亡  动作为杀死时不能主动攻击玩家
        if currRole:getFlag("是否死亡") == true or environment.operation == "杀死" then
            return
        end

        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show(Helper:getDef(result.arg2, "HIR看起来" .. currRole:getName() .. "想与你决斗！"))
        dialog:setBack(false)
        dialog:setButton1(
            Helper:getDef(result.arg3, "迎战"),
            function()
                Audio:playEffect("jiaoHu")

                --@desc 恢复满血状态
                currRole:setAttr("qiPercent", 1.0)
                currRole:setAttr("qi", currRole:getCurrQiMax())
                currRole:setAttr("neili", currRole:getFinalAttr("neiliMax"))

                local operations = environment.currRole.operations

                if MapIsEmpty(operations) == true then
                    operations = environment.currRoom.operations
                end

                local operations = environment.currRole.operations

                if MapIsEmpty(operations) == true then
                    operations = environment.currRoom.operations
                end

                map:afterFightWithShaSi(
                    player,
                    currRole,
                    function(winTeamId)
                        -- 战斗胜利条件结果
                        if winTeamId == 1 then
                            -- map:removeTaskFromDelayTasks(role.id)--卡顿优化
                            -- 玩家操作默认
                            currRole:setFlag("是否死亡", true)
                            map.__MapLayer:delayRefreshMap()

                            map:playerKillRole(currRoomId, currRole)

                            map:doOperationByName("决斗胜利", operations, environment)
                        elseif winTeamId == 2 then
                            map:doOperationByName("决斗失败", operations, environment)
                            PopText("你被" .. player:getName() .. "打败了")
                            map.__MapLayer.TotalMapBtn_IsInit = false
                            map.__MapLayer:quit()
                        elseif winTeamId == 3 then
                            map:doOperationByName("逃跑", operations, environment)
                        end
                    end
                )
            end
        )
    end,
    ["主动切磋玩家"] = function(map, result, environment)
        local currRole = environment.currRole
        local player = Helper:getDef(map:getPlayer(),User:getRole())

        if map:checkRoleIsInRoom(map:getCurrRoomId(), currRole.id) == false then
            return
        end
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show(Helper:getDef(result.arg2, "HIR看起来" .. currRole:getName() .. "想与你切磋！"))
        dialog:setBack(false)
        dialog:setButton1(
            Helper:getDef(result.arg3, "迎战"),
            function()
                Audio:playEffect("jiaoHu")

                --@desc 恢复满血状态
                currRole:setAttr("qiPercent", 1.0)
                currRole:setAttr("qi", currRole:getCurrQiMax())
                currRole:setAttr("neili", currRole:getFinalAttr("neiliMax"))

                local operations = environment.currRole.operations

                if MapIsEmpty(operations) == true then
                    operations = environment.currRoom.operations
                end

                map:afterFightWithQieCuo(
                    player,
                    currRole,
                    function(winTeamId)
                        -- 战斗胜利条件结果
                        if winTeamId == 1 then
                            if MapIsEmpty(operations) == false then
                                map:doOperationByName("切磋胜利", operations, environment)
                            end

                            map.__MapLayer:delayRefreshMap()
                        elseif winTeamId == 2 then
                            if MapIsEmpty(operations) == false then
                                map:doOperationByName("切磋失败", operations, environment)
                            end

                            map.__MapLayer:delayRefreshMap()
                        elseif winTeamId == 3 then
                            if MapIsEmpty(operations) == false then
                                map:doOperationByName("逃跑", operations, environment)
                            end
                            map.__MapLayer:delayRefreshMap()
                        end
                    end
                )
            end
        )
    end,
    ["弹出按钮选择框"] = function(map, result, environment)
        local text = result.arg2
        local btnList = string.split(Helper:getDef(result.arg3, ""), ",")
        local list = string.split(Helper:getDef(result.arg4, ""), ",")
        local funcList = {}
        local operations = environment.currRole.operations
        for i = 1, 6 do
            funcList[i] = function()
                if list[i] ~= nil then
                    map:doOperationById(list[i], operations, environment)
                end
            end
        end

        PopupLayerController:showLayer(
            "ChooseButtonLayer",
            function(layer)
                layer:initLayer(
                    text,
                    btnList[1],
                    funcList[1],
                    btnList[2],
                    funcList[2],
                    btnList[3],
                    funcList[3],
                    btnList[4],
                    funcList[4],
                    btnList[5],
                    funcList[5],
                    btnList[6],
                    funcList[6]
                )
            end
        )
    end,
    ["弹出选项框"] = function(map, result, environment)
        local title = result.arg2 --标题
        local btn1Text = result.arg3 --按钮1文字
        local btn2Text = result.arg4 --按钮2文字
        local resultsStrs1 = result.arg5
        local resultsStrs2 = result.arg6
        local tips = result.arg7

        local currRole = environment.currRole
        local operations = nil
        if currRole ~= nil then
            operations = currRole.operations
        end

        if MapIsEmpty(operations) then
            operations = environment.currRoom.operations
        end

        if operations == nil then
            return
        end

        title = string.gsub(title, "#mz", environment.currRole.name)
        --@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
        local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
        title = HomelandDesc:subChengHuText(title)

        local StringUtil = require("app.extends.StringUtil")
        title = StringUtil:replaceNpcName(title,map)

        print(btn1Text .. btn2Text .. resultsStrs1 .. resultsStrs2)
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show(title,tips)
        dialog:setRichText(title)
        dialog:setWeChatVisible(false)
        dialog:setButton1(
            btn1Text,
            function()
                map:doOperationById(resultsStrs1, operations, environment)
            end
        )

        dialog:setButton2(
            btn2Text,
            function()
                dialog:hide()
                map:doOperationById(resultsStrs2, operations, environment)
            end
        )
    end,
    ["弹出选项框2"] = function(map, result, environment)
        --@TODO 2020-01-08 12:06:53 暂时支持3个选项，如需再次增加选项需重新设计界面
        local title = result.arg2 --标题
        local tips = result.arg3 -- 提示语
        local btn_list = string.split(Helper:getDef(result.arg4, ""), ";")
        local operation_list = string.split(Helper:getDef(result.arg5, ""), ";")

        local currRole = environment.currRole
        local operations = nil
        if currRole ~= nil then
            operations = currRole.operations
        end

        if MapIsEmpty(operations) then
            operations = environment.currRoom.operations
        end

        if operations == nil then
            return
        end

        title = string.gsub(title, "#mz", environment.currRole.name)
        --@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
        local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
        title = HomelandDesc:subChengHuText(title)

        local StringUtil = require("app.extends.StringUtil")
        title = StringUtil:replaceNpcName(title,map)
        
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show(title,tips)
        dialog:setRichText(title)
        dialog:setWeChatVisible(false)

        for i=1,3 do
            local btnStr = btn_list[i]
            local operationStr  = operation_list[i]

            if btnStr ~= nil and operationStr ~= nil then
                dialog["setButton"..i](dialog,btnStr,function ()
                    map:doOperationById(operationStr, operations, environment)
                end)
            end
        end
    end,
    ["多条文本输出"] = function(map, result, environment)
        local textStr = assert(result.arg2, "多条文本输出,参数二没有")
        local timeStr = assert(result.arg3, "多条文本输出,参数三没有")
        local tipStr = assert(result.arg4, "多条文本输出,参数四没有")
        local resultStr = assert(result.arg5, "多条文本输出,参数五没有")
        local textList = string.split(textStr, ";")
        local timeList = string.split(timeStr, ";")
        assert(#textList == #timeList, "文本个数与时间间隔个数不一致")
        local time = 0
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        --不能退出，移动以及不接受PVP邀请
        local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
        local mapLayer = MainControllLayer:getLayer("MapLayer")

        local operations = environment.currRole.operations

        local env = environment

        mapRoleLayer:statusButtonFunc(
            false,
            function()
                PopText(tipStr)
            end
        )
        mapRoleLayer:exitButtonFunc(
            false,
            function()
                PopText(tipStr)
            end
        )
        mapLayer:setUnmoveRoom(
            true,
            function()
                PopText(tipStr)
            end
        )
        map:setCanLeave(false)
        player:setFlag("PVP活动状态", "忙碌")
        for k, t in pairs(timeList) do
            time = time + tonumber(t)
            mapLayer:delayFunc(
                time,
                function()
                    if textList[k] then
                        RichPrint("main", textList[k])
                    end
                    if k == #timeList then
                        player:setFlag("PVP活动状态", "空闲中")
                        mapLayer:setUnmoveRoom(false)
                        mapRoleLayer:statusButtonFunc(true)
                        mapRoleLayer:exitButtonFunc(true)
                        map:setCanLeave(true)

                        local operation_list = string.split(resultStr, ";")
                        for i, operationId in ipairs(operation_list) do
                            map:doOperationById(operationId, operations, env)
                        end
                    end
                end
            )
        end
    end,
    ["删除指定房间人物"] = function(map, result, environment)
        local roleId = result.arg2
        local roomId = result.arg3
        if roleId == nil or roomId == nil then
            return
        end
        map:removeRoomRole(roomId, roleId, false)
    end,
    ["开启计时器"] = function(map, result, environment)
        local operations
        if environment.currRole ~= nil then
            operations = environment.currRole.operations
        end

        if MapIsEmpty(operations) == true then
            operations = environment.currRoom.operations
            if MapIsEmpty(operations) == true then
                return
            end
        end

        --arg2 时间
        --arg3 计时器名字
        local timerTime = tonumber(result.arg2)
        local timerName = result.arg3
        local operationId = result.arg4
        local timerFlag = false --计时器是否完成

        if map.timerMap == nil then
            map.timerMap = {}
        end

        local timer = {}
        if map.timerMap[timerName] == nil then
            map.timerMap[timerName] = timer
            print("创建计时器: " .. tostring(timerName))
        else
            timer = map.timerMap[timerName]
            print("计时器已存在" .. timerName .. "重置时间")
            if timer.delayFuncHandle ~= nil then
                environment.mapLayer:stopActionByTag(map.timerMap[timerName].delayFuncHandle)
                map.timerMap[timerName].delayFuncHandle = nil
            end
            map.timerMap[timerName].flag = false
        end

        timer.time = timerTime
        timer.name = timerName
        timer.flag = timerFlag
        timer.sTime = GetTime()
        timer.operationId = operationId
        timer.backTime = Helper:getDef(BACKGROUND_TIME, 0)

        print("开启计时器:" .. tostring(timerName) .. ":" .. tostring(timerTime))

        local function TimerOver()
            timer.flag = true

            environment.mapLayer:stopActionByTag(map.timerMap[timerName].delayFuncHandle)
            map.timerMap[timerName].delayFuncHandle = nil
            print("计时器已完成" .. tostring(timerName))

            if timer.operationId ~= nil then
                map:doOperationById(timer.operationId, operations, environment)
            end
        end

        map.timerMap[timerName].delayFuncHandle = environment.mapLayer:delayFunc(timerTime, TimerOver)
    end,
    ["停止计时器"] = function(map, result, environment)
        local timerName = result.arg2

        print("停止计时器:" .. tostring(timerName))
        if map.timerMap == nil or map.timerMap[timerName] == nil then
            print("停止计时器:" .. tostring(timerName) .. "失败")
            return
        end

        if map.timerMap[timerName].delayFuncHandle ~= nil then
            print("停止计时器:" .. tostring(timerName) .. "成功")
            environment.mapLayer:stopActionByTag(map.timerMap[timerName].delayFuncHandle)
            map.timerMap[timerName].delayFuncHandle = nil
            map.timerMap[timerName].flag = true
        end
    end,
    ["随机结果"] = function(map, result, environment)
        --arg2 = 结果;结果;结果;结果
        --arg3 = 权重1;权重2;权重3;权重4
        local result_strs = result.arg2
        local weight_strs = result.arg3

        local operations
        if environment.currRole ~= nil then
            operations = environment.currRole.operations
        end

        if MapIsEmpty(operations) == true then
            local currRoom = map:getRoomAttr(environment.currRoomId)
            operations = currRoom.operations
        end

        print("随机结果 " .. tostring(result_strs) .. "  " .. tostring(weight_strs))

        if result_strs == nil or result_strs == "" then
            return
        end

        --解开results
        result_strs = string.split(result_strs, ";")

        --判断weight是否为空，为空则默认为1
        local weights = {}
        if weight_strs == nil or weight_strs == "" then
            for i, result_str in ipairs(result_strs) do
                table.insert(weights, 1)
            end
        else
            weight_strs = string.split(weight_strs, ";")
            for i, weight_str in ipairs(weight_strs) do
                if weight_str ~= nil and weight_str ~= "" then
                    table.insert(weights, tonumber(weight_str))
                end
            end
        end

        --计算总重
        local totalweight = 0
        for i, v in ipairs(weights) do
            weights[i] = math.ceil(weights[i] * 1000) --通通乘以1000,避免表里设计了小数点
            totalweight = totalweight + weights[i]
        end

        local rand_num = math.random(0, totalweight)
        print("随机结果 " .. rand_num .. "/" .. totalweight)
        local currweight = 0
        for i = 1, #weights, 1 do
            if rand_num >= currweight and rand_num < currweight + weights[i] then
                print(" -------- currweight=" .. currweight .. "  weights[i]=" .. weights[i])
                --命中
                local result_str = result_strs[i]

                print("随机结果：" .. result_str)
                return map:doOperationById(result_str, operations, environment)
            end
            currweight = currweight + weights[i]
        end

        print("ERROR: 随机结果居然没有随机到")
    end,
    ["听书"] = function(map, result, environment)
        if type(result.arg2) ~= "string" or result.arg2 == "" or type(result.arg3) ~= "string" or result.arg3 == "" then
            print("result.arg2:", result.arg2)
            print("result.arg3:", result.arg3)
            print("策划配置有问题")
            return
        end
        local doFunc
        local currRole = environment.currRole
        local operations = nil
        if currRole ~= nil then
            operations = currRole.operations
        end

        if MapIsEmpty(operations) then
            operations = environment.currRoom.operations
        end

        if operations ~= nil and result.arg4 then
            doFunc=function()
                map:doOperationById(result.arg4, operations, environment)
            end 
        else
            doFunc=EMPTY_FUNC
        end
       
        local textList = string.split(result.arg2, ";")
        local timeList = string.split(result.arg3, ";")
        local Anniversary = require("app.models.Anniversary.Anniversary")
        Anniversary:newStoryteller(textList, timeList, doFunc)
    end,

    ["通关副本"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        map:setCompleted()
        player:setMapCompleted(map.id)
        
        local context = result.arg2 or ""

        PopupLayerController:showLayer("TongGuanPopLayer2",function (layer)
            layer:setLeftFunc("继续探索",function ()
                layer:hideLayer()
                map.__MapLayer:delayRefreshMap()
                map.__MapLayer:replaceRoom(map:getCurrRoomId(), "center",false)
            end)
            layer:setRightFunc("离开副本",function ()
                layer:hideLayer()
                map.__MapLayer:quit()
            end)
            layer:showLayer(map.title .. " " ..map.name,context)
        end)
    end,
    
    ["兵囚渡河"] = function(map, result, environment)
        if not result.arg2 or not result.arg3 then
            print("策划配置有问题") 
        end
        local currRole = environment.currRole
        local operations = nil
        if currRole ~= nil then
            operations = currRole.operations
        end

        if MapIsEmpty(operations) then
            operations = environment.currRoom.operations
        end

        if operations == nil then
            return
        end
        local successFunc = function()
            map:doOperationById(result.arg2, operations, environment)
        end 
        local failFunc=function()
            map:doOperationById(result.arg3, operations, environment)
        end
        PopupLayerController:showLayer("CrossingRiverLayer",function(layer)
            layer:showLayer(successFunc,failFunc)
        end)
    end,
    ["视频播放"] = function (map, result, environment)
        local currRole = environment.currRole
        local operations = nil
        if currRole ~= nil then
            operations = currRole.operations
        end

        if MapIsEmpty(operations) then
            operations = environment.currRoom.operations
        end

        local currRoomId = map:getCurrRoomId()

        local currRoom = map:getRoomAttr(currRoomId)
        
        local callback = function ()
            if operations == nil then
                return
            end
            Audio:stopMusic()
            map.__MapLayer:playRoomMusic(currRoom)
            map:doOperationById(result.arg4, operations, environment)
        end

        --@desc windows上无法打开webView
        if device.platform == "ios" or device.platform == "android" then
            local fileName = result.arg2
            local closeTime = result.arg3
            PopupLayerController:showLayer("VideoPlayLayer",function (layer)
                map.__MapLayer:stopMusic()
                local voice = DataBase:getDataWithString("voice")
                if voice ~="N" then
                    local musicFileName = "html/"..fileName..".mp3"
                
                    cc.SimpleAudioEngine:getInstance():playMusic(musicFileName, false)
                end

                -- Audio:playMusic(fileName,false)
                layer:showLayer(fileName,closeTime,callback)
            end)
        else
            print("PC平台无法播放，直接执行后续操作。")
            callback()
        end
    end,
    ["新躲避暗器"] = function(map, result, environment)
        --arg2 = 发射文本内容1
        --arg3 = 向上文本;向下文本;向左文本;向右文本
        --arg4 = 持续时间
        --arg5 = 伤害百分比
        --arg6 = 成功结果
        --arg7 = 失败结果
        --arg8 = 成功方向：上下左右

        local player = Helper:getDef(map:getPlayer(),User:getRole())
        local qi = player:getAttr("qi")
        if qi <= 0 then
            if MainControllLayer:getCurrLayer() == "MapLayer" then
                MainControllLayer:getLayer("MapLayer"):quit()
            end
            return
        end
        local rolePVPState = player:getFlag("PVP活动状态")
        if rolePVPState == "空闲中" then 
            player:setFlag("PVP活动状态","忙碌")
        end
        local fireTextList = {tostring(result.arg2)}
        local buttonNameList = string.split(tostring(result.arg3), ";")
        local interval = tonumber(result.arg4)
        local damagePercent = tonumber(result.arg5)
        local succResult = result.arg6
        local failedResult = result.arg7
        local correctDirection = result.arg8
        
        PopupLayerController:showLayer("NewDialogDodgeLayer", function(layer)
            if layer:isAvail() == false then
                print("dodgeLayer is now busy")
                return
            end
            
            layer:reinit()

            -- 躲避文本
            layer:setDodgeTexts(
            {
                ["up"] = { "你身形陡然纵起，凌空一跃。" , "你身体向上笔直纵身，跃起数丈。" } , 
                ["down"] = { "你足跟一支，全身后仰。" , "你飘然向下一闪，身体贴向地面。" } , 
                ["left"] = { "你身体晃动，向左一偏。" , "你身随意转，向左一闪。" } ,
                ["right"] = { "你向右，侧身一摆。" , "你足不点地，向右窜开。" } ,
                ["still"] = { "你停留在原地，什么也没做！" , "你尚未回过神来！" }
            })
            
            -- 躲避成功文本
            layer:setSuccTexts(
            {
                "十分轻松地躲过了暗器！",
                "犹如鬼魅一般，十分利索地躲过了暗器！",
                "暗器擦着你的身体而过，你并没受到伤害！",
                "电光火石之间躲过了暗器的攻击",
                "暗器已然落空！"
            })
            
            -- 受伤文本
            layer:setHurtTexts(
            {
                "你虽然反应极快，但还是擦伤了你，你受到了$z点伤害",
                "机关来势甚猛，你躲闪不及，受到了$z点伤害",
                "你一个躲避不及，还是被所击中，受到了$z点伤害",
                "你身法虽快，却未快过这，你受到了$z点伤害",
                "打中了你造成了$z点伤害，你痛苦不堪"
            })
            
            layer:setFireTexts(fireTextList)
            layer:setToFireTexts({"下身", "头部", "右侧", "左侧"})
            layer:setToDodgeTexts({"上跳", "下蹲", "左闪", "右闪"})
            layer:setBtnName(buttonNameList)
            layer:setTime(interval)
            layer:setDamagePercent(damagePercent)
            layer:setCorrectDirection(correctDirection)
            layer:setResultCallback(function(isSucc)
                
                if rolePVPState == "空闲中" then 
                    player:setFlag("PVP活动状态","空闲中")
                end

                local currRole = environment.currRole
                local operations = nil
                if currRole ~= nil then
                    operations = currRole.operations
                end

                if MapIsEmpty(operations) then
                    operations = environment.currRoom.operations
                end

                if operations == nil then
                    return
                end

                if isSucc == true then
                    map:doOperationById(succResult, operations, environment)
                else
                    map:doOperationById(failedResult, operations, environment)
                end
            end)
            
            layer:show()
        end)
    end,
    
    ["下毒玩法"] = function(map, result, environment)
		local succResult = result.arg2 --下毒成功调用结果集
		local failedResult = result.arg3 --下毒失败调用结果集
		local timeoutResult = result.arg4 --下毒超时调用结果集
        local animDuration = result.arg5 --动画时间
		PopupLayerController:showLayer("PoisonPlayLayer", function(layer)
			layer:showLayer(map,environment,succResult,failedResult,timeoutResult,animDuration)
		end)
    end,

    ["PVPFight"] = function(map, result, environment)
        local role = environment.currRole
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        if player:getFlag("PVP活动状态") == "忙碌" then
            PopText("正在忙碌中")
            return 
        end
        if Map:checkRoomCanQieCuo(map:getCurrRoomId()) == true then
            player:updateFightStatus("主动邀战等待中")
            FubenClient:qieCuo(role.userid)
        else
            PopText("此乃文教之地，不可动武！")
        end
    end,

    ["声望排行"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        local prestigeChapmanFamily=environment.currRole.menpai
        if not environment.currRole.lastVisitTime then
            environment.currRole.lastVisitTime=0
        end
        print("environment.currRole.lastVisitTime：",environment.currRole.lastVisitTime)
        local isUpLoad=false
        if GetTime()-environment.currRole.lastVisitTime>300 then 
            isUpLoad=true
            environment.currRole.lastVisitTime=GetTime()
        end
        print("role.menpai:",environment.currRole.menpai,"player.menpai:",player:getFamilyId())
        local playerFamily= player:getFamilyId()
        if prestigeChapmanFamily==playerFamily or DEBUG_MODE==1 then
            HttpManagerEx:updateUserPrestige(
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode== 0 then
                        PopupLayerController:showLayer("FamilyPrestigeRanking",function(layer)
                            layer:showLayer(isUpLoad)
                        end)
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        else
            PopText("不是本门弟子，不能随意查看")
        end
        
    end,
    ["故事动画播放"] = function(map, result, environment)
        local imageTab=string.split(result.arg2, ";") 
        local timeTab= string.split(result.arg3, ";")
        local image1=imageTab[1]
        local image2=imageTab[2]
        local duration1=tonumber(timeTab[1])
        local duration2=tonumber(timeTab[2])
        local musicName
        if result.arg5 then 
            musicName=result.arg5
        end


        local currRole = environment.currRole
        local operations = nil


        PopupLayerController:showLayer("ShowActionLayer", function(layer)

            layer:setEndFunc(function ()   
                if result.arg4 == nil then
                    return
                end

                if currRole ~= nil then
                    operations = currRole.operations
                end
        
                if MapIsEmpty(operations) then
                    operations = environment.currRoom.operations
                end
        
                if operations == nil then
                    return
                end
                
                map:doOperationById(result.arg4, operations, environment)
            end)

            layer:showLayer(duration1,duration2,image1,image2,musicName,function ()
            end)
        end)
    end,
    ["指定方向投放单位"] = function (map, result, environment)
        local currRoomId = map:getCurrRoomId()

        local room = map:getRoomAttr(currRoomId)

        local unitId = result.arg2

        local dir = result.arg3

        local link_room = room.link

        local roomId = link_room[DIRECTION_LINK_STR[dir]]

        local currRole = environment.currRole

        local operations = nil
        if currRole ~= nil then
            operations = currRole.operations
        end

        if MapIsEmpty(operations) then
            operations = environment.currRoom.operations
        end

        if roomId ~= nil and roomId ~= "" then
            map:addRoomRole(roomId, unitId, false)

            --@desc 移动成功执行
            if MapIsEmpty(operations) == false and result.arg4 ~= nil then
                map:doOperationById(result.arg4, operations, environment)
            end
        else
            --@desc 移动失败执行
            if MapIsEmpty(operations) == false and result.arg5 ~= nil then
                map:doOperationById(result.arg5, operations, environment)
            end
        end

    end,
    ["碧云心法转换成手心劫"] = function(map, result, environment)
        local succResult = result.arg2
		local failedResult = result.arg3
        local role = User:getRole()
        local skillExp = role:getSkillExp("biyunxinfa")
        local canye1 = role:getZhaoShuXiang("biluohuangquancanye")
        local canye2 = role:getZhaoShuXiang("yunqilongxiangcanye")

        local function doOperationById(result)
            local currRole = environment.currRole
            local operations = nil
            if currRole ~= nil then
                operations = currRole.operations
            end
    
            if MapIsEmpty(operations) then
                operations = environment.currRoom.operations
            end
    
            if operations == nil then
                return
            end
    
            map:doOperationById(result, operations, environment)
        end

        if skillExp <= 0 then
            PopText("你未学习碧云心法，无需进修。")
            doOperationById(failedResult)
            return
        end

        
        local maxExp = role:conversionSkillExpAndLv("exp", role:getLv())
        local addExp = Helper:getRange(math.min(skillExp,  maxExp - role:getSkillExp("shouxinjie")), 0)
        
        role:addSkillExp("shouxinjie", addExp)
        role:addSkillZhaoExp("xinzhongci",role:getSkillZhaoExp("biluohuangquan"))
        role:addSkillZhaoExp("zhijiansha",role:getSkillZhaoExp("yunqilongxiang"))
        if canye1 ~= nil and canye1.count >= 0 then
            role:addItemCount("xinzhongcicanye",canye1.count)
            PopText("获得"..role:getOneItemByKey("xinzhongcicanye").name.."X"..tostring(canye1.count))
        end

        if canye2 ~= nil and canye2.count >= 0 then
            role:addItemCount("zhijianshacanye",canye2.count)
            PopText("获得"..role:getOneItemByKey("zhijianshacanye").name.."X"..tostring(canye2.count))
        end

        doOperationById(succResult)
    end,

    ["心法武学转化"] = function(map, result, environment)
        local needSkillId = result.arg2
        local targetSkillId = result.arg3
        local succResult = result.arg4
		local failedResult = result.arg5

        local role = User:getRole()

        local skillExp = role:getSkillExp(needSkillId)

        local function doOperationById(result)
            local currRole = environment.currRole
            local operations = nil
            if currRole ~= nil then
                operations = currRole.operations
            end
    
            if MapIsEmpty(operations) then
                operations = environment.currRoom.operations
            end
    
            if operations == nil then
                return
            end
    
            map:doOperationById(result, operations, environment)
        end

        if skillExp <= 0 then
            doOperationById(failedResult)
            return
        end

        local targetSkillExp = role:getSkillExp(targetSkillId)
        if skillExp > targetSkillExp then
            local skill = {id = targetSkillId, exp = skillExp}
            role:setSkill(targetSkillId, skill)
        end
        
        role:removeSkill(needSkillId)

        doOperationById(succResult)
    end,
}


return EMapResults
0000