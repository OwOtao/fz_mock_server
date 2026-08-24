--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local FightResult = class("FightResult", require("app.models.map.MapHandle.Modules.BaseModule"))

--@desc 条件结果的方法
FightResult.doResult = {
    ["主动击杀玩家"] = function(map, result, environment)
        local currRole = environment.currRole
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        if PRINT_MODE == 1 then
            print("environment.currRoomId = " .. tostring(environment.currRoomId))
        end

        -- 判断角色是否死亡  动作为杀死时不能主动攻击玩家
        if currRole:getFlag("是否死亡") == true or environment.operation == "杀死" then
            return
        end
        local currRoomId = map:getCurrRoomId()
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show(Helper:getDef(result.arg2, "HIR看起来" .. currRole:getName() .. "想与你决斗！"))
        dialog:setBack(false)
        dialog:setButton1(
            Helper:getDef(result.arg3, "迎战"),
            function()
                Audio:playEffect("jiaoHu")
                if player:getCurrMapId() ~= map.id then
                    PopText("已逃离对方的追捕，无法进行战斗。")
                    return
                end
                
                local role = currRole
                local currMap = map
                map.mapLayer = map.__MapLayer

                role:initNpcAttr() -- NPC状态初始化
                map:afterFightWithShaSi(
                    player,
                    role,
                    function(winTeamId)
                        -- 战斗胜利条件结果
                        if winTeamId == 1 then
                            PopText("你决斗战胜了" .. role:getName())
                             --因为地图延时刷新 加个遮罩防止尸体未出现可再次决斗
                            PopupLayerController:showLayer("GlobalShadeLayer",function (layer)
                                layer:setPopText("")
                                layer:showLayer()
                            end)
                            -- 玩家操作默认
                            role:setFlag("是否死亡", true)
                            currMap:dowithRoleOperation(
                                {
                                    operation = "杀死",
                                    result = "成功",
                                    player = player,
                                    currRole = role,
                                    currMap = currMap,
                                    currRoomId = currRoomId
                                }
                            )
                            currMap:doConditionAndResult(
                                role.conditionAndResults,
                                {
                                    conditionType = "杀死",
                                    result = "成功",
                                    currRole = role,
                                    currRoomId = currRoomId,
                                    mapLayer = map.mapLayer
                                }
                            )

                            currMap:doRoomConditionAndResult(currRoomId) -- 刷新房间条件结果
                            map.__MapLayer:delayRefreshMap()

                            map.__MapLayer:delayFunc(0.1,function()
                                PopupLayerController:hideLayer("GlobalShadeLayer",function (layer)
                                    layer:hideLayer()
                                end)
                            end)
                        elseif winTeamId == 2 then
                            PopText("你被" .. role:getName() .. "打败了")

                            if player:getFlag("佣兵模式") == "开启" then
                                currMap:doConditionAndResult(
                                    role.conditionAndResults,
                                    {
                                        conditionType = "杀死",
                                        result = "失败",
                                        currRole = role,
                                        currRoomId = currRoomId,
                                        mapLayer = map.mapLayer
                                    }
                                )
                                currMap:doRoomConditionAndResult(currRoomId)
                             -- 刷新房间条件结果
                            else
                                map.__MapLayer.TotalMapBtn_IsInit = false
                                map.__MapLayer:quit()
                            end
                        elseif winTeamId == 3 then
                            currMap:doConditionAndResult(
                                role.conditionAndResults,
                                {
                                    conditionType = "杀死",
                                    result = "逃跑",
                                    currRole = role,
                                    currRoomId = currRoomId,
                                    mapLayer = map.mapLayer
                                }
                            )

                            map.mapLayer:delayRefreshMap()
                            -- 刷新房间条件结果
                            map:doRoomConditionAndResult(currRoomId)
                        else
                        end
                    end
                )
            end
        )
    end,
    ["主动切磋玩家"] = function(map, result, environment)
        local currRole = environment.currRole
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        -----------------------------------------------------------------------------------------------------------
        -- @author GaoHanZheng
        -- @time 2018/01/03 18:20:38
        -- @desc 增加参数二,默认没有,type(result.arg1) == "function"
        local backFunc = result.arg2
        if PRINT_MODE == 1 then
            print("environment.currRoomId = " .. tostring(environment.currRoomId))
        end
        if environment.conditionType == "切磋" then -- add by XiaoZhiWei 2017/09/06 16:53:17 切磋的条件结果不进入切磋界面
            return
        end
        local currRoomId = map:getCurrRoomId()
        if map:checkRoleIsInRoom(currRoomId, currRole.id) == false then
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

                if player:getCurrMapId() ~= map.id then
                    PopText("已逃离对方的追捕，无法进行战斗。")
                    return
                end

                if TANGJIAN_TEST_ENABLE then
                    local role = currRole
                    local currMap = map
                    map.mapLayer = map.__MapLayer

                    role:initNpcAttr() -- NPC状态初始化
                    map:afterFightWithQieCuo(
                        player,
                        role,
                        function(winTeamId)
                            -- 战斗胜利条件结果
                            if winTeamId == 1 then
                                PopText("你切磋战胜了" .. role:getName())

                                -- 玩家操作默认
                                currMap:dowithRoleOperation(
                                    {
                                        operation = "切磋",
                                        result = "成功",
                                        player = player,
                                        currRole = role,
                                        currMap = currMap,
                                        currRoomId = currRoomId
                                    }
                                )
                                currMap:doConditionAndResult(
                                    role.conditionAndResults,
                                    {
                                        conditionType = "切磋",
                                        result = "成功",
                                        currRole = role,
                                        currRoomId = currRoomId,
                                        mapLayer = map.mapLayer
                                    }
                                )
                                if backFunc ~= nil then
                                    backFunc(winTeamId)
                                end
                                currMap:doRoomConditionAndResult(currRoomId) -- 刷新房间条件结果
                                map.__MapLayer:delayRefreshMap()
                            elseif winTeamId == 2 then
                                PopText("你被" .. role:getName() .. "打败了")
                                currMap:doConditionAndResult(
                                    role.conditionAndResults,
                                    {
                                        conditionType = "切磋",
                                        result = "失败",
                                        currRole = role,
                                        currRoomId = currRoomId,
                                        mapLayer = map.mapLayer
                                    }
                                )
                                if backFunc ~= nil then
                                    backFunc(winTeamId)
                                end
                                currMap:doRoomConditionAndResult(currRoomId)
                             -- 刷新房间条件结果
                            elseif winTeamId == 3 then
                                currMap:doConditionAndResult(
                                    role.conditionAndResults,
                                    {
                                        conditionType = "切磋",
                                        result = "逃跑",
                                        currRole = role,
                                        currRoomId = currRoomId,
                                        mapLayer = map.mapLayer
                                    }
                                )
                                if backFunc ~= nil then
                                    backFunc(winTeamId)
                                end
                                map.mapLayer:delayRefreshMap()
                                -- 刷新房间条件结果
                                map:doRoomConditionAndResult(currRoomId)
                            else
                            end
                        end
                    )
                else
                end
            end
        )
    end,
    ["攻击玩家"] = function(map, result, environment)
        local currRole = environment.currRole
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        local TANGJIAN_TEST_ENABLE = true
        local currRoomId = map:getCurrRoomId()
        if PRINT_MODE == 1 then
            print("environment.currRoomId = " .. tostring(currRoomId))
        end
        if map:checkRoleIsInRoom(currRoomId, currRole.id) == false then
            return
        end
        -- 判断角色是否死亡  动作为杀死时不能主动攻击玩家
        if currRole:getFlag("是否死亡") == true or environment.operation == "杀死" 
        -- 佣兵状态下 章作之战败后跳转房间不再显示 被御林军等npc主动攻击弹窗
        or (player:getFlag("章作之惩罚") == 1  and  player:getFlag("佣兵模式") == "关闭" and map.id == "fb37" )
        then
            return
        end

        
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        --dialog.show=true
        if not dialog._isShow then
            dialog:hide()
            dialog:show("HIR看起来" .. currRole:getName() .. "想与你决斗！")
            dialog:setBack(false)
            dialog._isShow = true
            dialog:setButton1(
            "迎战",
            function()
                Audio:playEffect("jiaoHu")
                
                if player:getCurrMapId() ~= map.id then
                    PopText("已逃离对方的追捕，无法进行战斗。")
                    dialog._isShow = false
                    return
                end

                if TANGJIAN_TEST_ENABLE then
                    local role = currRole
                    local currMap = map
                    map.mapLayer = map.__MapLayer
                    role:initNpcAttr() -- NPC状态初始化
                    map:afterFightWithShaSi(
                        player,
                        role,
                        function(winTeamId)
                            -- 战斗胜利条件结果
                            dialog._isShow = false
                            if winTeamId == 1 then

                                PopText("你决斗战胜了" .. role:getName())
                                --因为地图延时刷新 加个遮罩防止尸体未出现可再次决斗
                                PopupLayerController:showLayer("GlobalShadeLayer",function (layer)
                                    layer:setPopText("")
                                    layer:showLayer()
                                end)
                                -- 玩家操作默认
                                role:setFlag("是否死亡", true)
                                currMap:dowithRoleOperation(
                                    {
                                        operation = "杀死",
                                        result = "成功",
                                        player = player,
                                        currRole = role,
                                        currMap = currMap,
                                        currRoomId = currRoomId
                                    }
                                )
                                currMap:doConditionAndResult(
                                    role.conditionAndResults,
                                    {
                                        conditionType = "杀死",
                                        result = "成功",
                                        currRole = role,
                                        currRoomId = currRoomId,
                                        mapLayer = map.mapLayer
                                    }
                                )

                                currMap:doRoomConditionAndResult(currRoomId) -- 刷新房间条件结果
                                map.__MapLayer:delayRefreshMap()

                                map.__MapLayer:delayFunc(0.1,function()
                                    PopupLayerController:hideLayer("GlobalShadeLayer",function (layer)
                                        layer:hideLayer()
                                    end)
                                end)
                            elseif winTeamId == 2 then
                                PopText("你被" .. role:getName() .. "打败了")

                                if player:getFlag("佣兵模式") == "开启" then
                                    currMap:doConditionAndResult(
                                        role.conditionAndResults,
                                        {
                                            conditionType = "杀死",
                                            result = "失败",
                                            currRole = role,
                                            currRoomId = currRoomId,
                                            mapLayer = map.mapLayer
                                        }
                                    )
                                    currMap:doRoomConditionAndResult(currRoomId)
                                 -- 刷新房间条件结果
                                else
                                    map.__MapLayer.TotalMapBtn_IsInit = false
                                    map.__MapLayer:quit()
                                end
                            elseif winTeamId == 3 then -- add by XiaoZhiWei 2017/09/06 14:38:56 逃跑的情况
                                currMap:doConditionAndResult(
                                    role.conditionAndResults,
                                    {
                                        conditionType = "杀死",
                                        result = "逃跑",
                                        currRole = role,
                                        currRoomId = currRoomId,
                                        mapLayer = map.mapLayer
                                    }
                                )

                                map.mapLayer:delayRefreshMap()
                                -- 刷新房间条件结果
                                map:doRoomConditionAndResult(currRoomId)
                            else
                            end

                        end,
                        nil,
                        function ()
                            dialog._isShow = false
                        end
                    )
                else
                    local FightLayer = require("app.views.layer.WordFightLayer")
                    local fightLayer = FightLayer:getInstance()
                    fightLayer:show(true, "杀死")
                    fightLayer:startFight(
                        {player},
                        {currRole},
                        function(winTeamId)
                            if winTeamId == 1 then
                                map:dowithRoleOperation(
                                    {
                                        operation = "杀死",
                                        result = "成功",
                                        player = player,
                                        currRole = currRole,
                                        currMap = map,
                                        currRoomId = currRoomId
                                    }
                                )

                                currRole:setFlag("是否死亡", true)

                                map:doConditionAndResult(
                                    currRole.conditionAndResults,
                                    {
                                        conditionType = "杀死",
                                        result = "成功",
                                        currRole = currRole,
                                        player = player,
                                        currMap = map,
                                        currRoomId = currRoomId
                                    }
                                )

                                -- 刷新房间条件结果
                                map:doRoomConditionAndResult(currRoomId)
                                map.__MapLayer:delayRefreshMap()
                            elseif winTeamId == 2 then
                                map.__MapLayer.TotalMapBtn_IsInit = false
                                map.__MapLayer:quit()
                            -- map.__MapLayer.ControllLayer:popLayer()
                            end

                        end,
                        true
                    )
                end
            end
        )
        dialog:setButton2(
            "逃跑",
            function()
                if PRINT_MODE == 1 then
                    print(tostring(map.__last_Room))
                end
                dialog._isShow = false
                -- 刷新房间条件结果
                -- map:doRoomConditionAndResult(environment.currRoomId)
            end
        )
        end
        

        return "攻击玩家"
    end,
    ["主动切磋"] = function(map, result, environment)
        if map:getMapFightState() == true then
            return
        end

        local player = Helper:getDef(map:getPlayer(),User:getRole())
        local currRole = environment.currRole

        local currRoomId = map:getCurrRoomId()
        if map:checkRoleIsInRoom(currRoomId, currRole.id) == false then
            return
        end

        map:setMapFightState(true)

        local role = currRole
        local currMap = map
        map.mapLayer = map.__MapLayer

        currMap:doConditionAndResult(
            role.conditionAndResults,
            {
                operation = "切磋",
                currRole = role,
                currRoomId = currRoomId,
                mapLayer = map.mapLayer
            }
        )

        role:initNpcAttr() -- NPC状态初始化

        currMap:afterFightWithQieCuo(
            player,
            role,
            function(winTeamId)
                -- 战斗胜利条件结果
                if winTeamId == 1 then
                    -- PopText("你战胜了" .. role:getName())
                    currMap:doConditionAndResult(
                        role.conditionAndResults,
                        {
                            conditionType = "切磋",
                            result = "成功",
                            currRole = role,
                            currRoomId = currRoomId,
                            mapLayer = map.mapLayer
                        }
                    )

                    map.mapLayer:delayRefreshMap()
                    map:doRoomConditionAndResult(currRoomId)
                elseif winTeamId == 2 then
                    -- PopText("你被" .. role:getName() .. "打趴在地")
                    currMap:doConditionAndResult(
                        role.conditionAndResults,
                        {
                            conditionType = "切磋",
                            result = "失败",
                            currRole = role,
                            currRoomId = currRoomId,
                            mapLayer = map.mapLayer
                        }
                    )

                    map.mapLayer:delayRefreshMap()
                    -- 刷新房间条件结果
                    map:doRoomConditionAndResult(currRoomId)
                elseif winTeamId == 3 then
                    currMap:doConditionAndResult(
                        role.conditionAndResults,
                        {
                            conditionType = "切磋",
                            result = "逃跑",
                            currRole = role,
                            currRoomId = currRoomId,
                            mapLayer = map.mapLayer
                        }
                    )

                    map.mapLayer:delayRefreshMap()
                    -- 刷新房间条件结果
                    map:doRoomConditionAndResult(currRoomId)
                else
                    winTeamId = 0
                end

            end
        )
    end,
    ["自定义对战"] = function(map, result, environment)
        print("自定义对战: " .. result.arg2 .. " VS " .. result.arg3)
        local role1, role2
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        --参数为me 为玩家自己
        if result.arg2 == "ME" then
            role1 = clone(player)
        else
            role1 = clone(map:getRole(result.arg2))
        end

        role2 = clone(map:getRole(result.arg3))
        local resultStrs1 = result.arg4
        local resultStrs2 = result.arg5
        local btnType = result.arg6 -- 按钮控制 1只显示恢复 2只显示逃跑 3都显示
        if role1.name == "章作之" then
            role1._isZhang = true
            role1.activeZhaos = map:getYongBingRole():getAttr("activeZhaos")
            btnType = 4
        end

        Audio:playEffect("jiaoHu")

        FubenClient:setValue("isFighting", true)
        player:updateFightStatus("战斗中")

        local FightLayer = require("app.views.layer.FightLayer.FightLayer")
        FightLayer:startMapFight(
            {role1},
            {role2},
            function(fightLayer, eventType, ...)
                local fight = fightLayer:getFight()
                if eventType == FightLayer.EVENT_TYPE_FIGHT_READY then
                    -- 暂停地图场景渲染
                    map._mapLayer:pauseSelfAndChildren()
                    map._mapLayer:setVisible(false)
                    MainControllLayer:pauseUpdate()

                    -- 战斗开始的时候设置下玩家
                    local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
                    fight:setPlayer(role)

                    -- fight:start()
                    -- fightLayer:printRolePrologue(1, "切磋")
                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_START then
                    PopText("战斗开始!!!")
                    -- -- 战斗开始的时候设置下玩家
                    -- local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
                    -- fight:setPlayer(role)
                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_FINISH then
                    local winTeamId, teams = ...

                    FubenClient:setValue("isFighting", false)
                    player:updateFightStatus("战斗结束")

                    -- 战斗胜利条件结果
                    if winTeamId == 1 then
                        if resultStrs1 ~= nil then
                            map:doNoRoleResults(resultStrs1, environment)
                        end
                        map.__MapLayer:delayRefreshMap()
                    elseif winTeamId == 2 then
                        if resultStrs2 ~= nil then
                            map:doNoRoleResults(resultStrs2, environment)
                        end
                        map.__MapLayer:delayRefreshMap()
                    end

                    map._mapLayer:resumeSelfAndChildren()
                    map._mapLayer:setVisible(true)
                    MainControllLayer:resumeUpdate()

                    fightLayer:hide(
                        function()
                            fightLayer:destroyInstance()
                        end
                    )
                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_RUNAWAY then
                    FubenClient:setValue("isFighting", false)
                    player:updateFightStatus("战斗结束")
                    -- 隐藏按钮区域
                    fightLayer:callUIMemFunc("setButtonAreaVisble", false)
                    -- 显示战斗结束文本区域
                    fightLayer:callUIMemFunc("showFightEndTextArea")

                    -- 设置战斗结束文本区域的文本
                    fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "逃跑")
                    fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, role1.name .. "大喝一声：“三十六计，走为上计")

                    fightLayer:callUIMemFunc(
                        "setFightEndTextAreaReleaseFunc",
                        function()
                            -- player:calcActiveZhaoUseTimes(fight:getRoleByTeamIdAndInTeamId(1, 1)) -- 计算主动招式熟练度
                            if map._mapLayer then
                                map._mapLayer:resumeSelfAndChildren()
                                map._mapLayer:setVisible(true)
                            end

                            fightLayer:hide(
                                function()
                                    fightLayer:destroyInstance()
                                    cleanTable(fightLayer)
                                end
                            )
                        end
                    )
                end
            end,
            btnType,
            map._mapLayer._currRoom.fightBackground
        )
    end,
    ["传承战斗"] = function(map, result, environment)
        local role1, role2
        -- role1 = User:getRole():createInheritRole()

        local attr = {
            name = User:getRoleAttr("inherit").name,
            sex = User:getRoleAttr("inherit").sex,
            str = 20,
            int = 20,
            con = 20,
            dex = 20,
            skills = {
                jibenquanjiao = {id = "jibenquanjiao", exp = 1876},
                jibenzhaojia = {id = "jibenzhaojia", exp = 1876},
                jibenqinggong = {id = "jibenqinggong", exp = 1876},
                jibenneigong = {id = "jibenneigong", exp = 1876},
            }
        }

        role1 = Helper:tableCover(Role:create(),attr)
        
        role2 = clone(map:getRole(result.arg2))
        local resultsStrs = result.arg3

        if TANGJIAN_TEST_ENABLE then
            Audio:playEffect("jiaoHu")
            local FightLayer = require("app.views.layer.FightLayer.FightLayer")
            FightLayer:startInheritFight(
                {role1},
                {role2},
                function(fightLayer, eventType, ...)
                    local fight = fightLayer:getFight()
                    if eventType == FightLayer.EVENT_TYPE_FIGHT_READY then
                        -- 暂停地图场景渲染
                        map._mapLayer:pauseSelfAndChildren()
                        map._mapLayer:setVisible(false)
                        MainControllLayer:pauseUpdate()

                        -- 战斗开始的时候设置下玩家
                        local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
                        fight:setPlayer(role)
                        -- fight:start()
                    elseif eventType == FightLayer.EVENT_TYPE_FIGHT_START then
                        -- 暂停地图场景渲染
                        -- map._mapLayer:pauseSelfAndChildren()
                        -- map._mapLayer:setVisible(false)
                        PopText("战斗开始!!!")
                        -- -- 战斗开始的时候设置下玩家
                        -- local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
                        -- fight:setPlayer(role)
                    elseif eventType == FightLayer.EVENT_TYPE_FIGHT_FINISH then
                        local winTeamId, teams = ...

                        -- 战斗胜利条件结果
                        if winTeamId == 1 then
                            if resultsStrs ~= nil then
                                map:doNoRoleResults(resultsStrs, environment)
                            end
                            map.__MapLayer:delayRefreshMap()
                        else
                            map.__MapLayer.TotalMapBtn_IsInit = false
                            map.__MapLayer:quit()
                        end

                        local InheritMapRoleLayer = MainControllLayer:getLayer("InheritMapRoleLayer")
                        InheritMapRoleLayer:onPause()
                        InheritMapRoleLayer:setVisible(false)

                        map._mapLayer:resumeSelfAndChildren()
                        map._mapLayer:setVisible(true)
                        MainControllLayer:resumeUpdate()

                        fightLayer:hide(
                            function()
                                fightLayer:destroyInstance()
                            end
                        )
                    end
                end
            )
        else
            local WordFightLayer = require("app.views.layer.WordFightLayer")
            local fightLayer = WordFightLayer:getInstance()
            fightLayer:show(true, "切磋")
            fightLayer:startFight(
                {role1},
                {role2},
                function(winTeamId)
                    if winTeamId == 1 then
                        if resultsStrs ~= nil then
                            map:doNoRoleResults(resultsStrs, environment)
                        end
                        map.__MapLayer:delayRefreshMap()
                    elseif winTeamId == 2 then
                        map.__MapLayer:quit()
                    end
                end,
                true,
                false
            )
        end
    end,
}

return FightResult
000000000000