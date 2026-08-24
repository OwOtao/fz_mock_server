local RoleObserveModel = {}

function RoleObserveModel:createMapRoleFuncList(role)
    local player = User:getRole()
    local functionList = {}

    local currMap = player:getCurrMap()

    if Map:getMapVersionByMapId(currMap.id) == EDITOR_MAP_VERSION then
        if MapIsEmpty(role.operations) == false then
            for i, operation in ipairs(role.operations) do
                if operation.operationButton ~= nil and operation.isVisible ~= 0 then
                    local funcData = {
                        btnName = operation.operationButton,
                        btnFunc = function()
                            currMap:doOperation(
                                operation,
                                {
                                    currRole = role,
                                    currRoomId = currMap:getCurrRoomId(),
                                    mapLayer = currMap.__MapLayer
                                }
                            )
                            currMap.__MapLayer:delayRefreshMap()
                        end
                    }

                    table.insert(functionList, funcData)
                end
            end
        end
    else
        functionList = self:createOldMapNpcFunc(role, currMap)
    end

    if role.type == "role" then
        self:addMyTeacherFunc(role, functionList)
    
        self:addSalesFunc(role, functionList)

        self:addFestivalFunc(role, functionList)
    end

    return functionList
end

--@role: [src.app.models.role.Role#Role]
--@currMap: [src.app.models.map.BaseMap#BaseMap]
function RoleObserveModel:createOldMapNpcFunc(role, currMap)
    local Task = require("app.models.task.Task")

    local player = User:getRole()

    local functionList = {}
    if role.type == "role" then
        if role.canTalk == 1 or role.canTalk == true then
            local funcData = {
                btnName = "交谈",
                btnFunc = function()
                    currMap:doConditionAndResult(
                        role.conditionAndResults,
                        {
                            operation = "交谈",
                            currRole = role,
                            currRoomId = currMap:getCurrRoomId(),
                            mapLayer = currMap.__MapLayer
                        }
                    )
                    currMap.__MapLayer:delayRefreshMap()
                    -- 刷新房间条件结果
                    currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                    -- currMap.__MapLayer:replaceRoom(currMap:getCurrRoomId(), "center")
                    -- print("role.words = "..role.words)
                    if role.words and type(role.words) == "table" and #role.words ~= 0 then
                        local words = role.words[math.random(1, #role.words)]
                        if words == "$庙会文本" then
                            local portrait = Item:getOneItemByKey(player:getPortraitId())
                            print(portrait)
                            local miaohuitext = require("script.others.miaohuitext").Sheet1
                            if
                                portrait ~= nil and miaohuitext[portrait.id] ~= nil and
                                    type(miaohuitext[portrait.id].text1) == "string"
                             then
                                local strList = string.split(miaohuitext[portrait.id].text1, ";")
                                local index = math.random(1, #strList)
                                words = strList[index]
                                print("当前输出的庙会文本是 ： ", words)
                            else
                                words = "嗯？你是？"
                            end
                        end

                        local s1 = string.find(words, "$npcX$ ")
                        local s2 = string.find(words, "$npcM$ ")
                        if s1 ~= nil or s2 ~= nil then
                            -- 活动：鬼差任务文本输出使用
                            local des_name = role.des_name
                            local len = string.len(des_name)
                            local xing = ""
                            if len == 9 or len == 6 then
                                xing = string.sub(des_name, 1, 3)
                            elseif len == 12 then
                                xing = string.sub(des_name, 1, 6)
                            end
                            words = string.gsub(words, "$npcX$ ", xing)
                            words = string.gsub(words, "$npcM$ ", des_name)
                        end
                        local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
                        words = HomelandDesc:subChengHuText(words)
                        words = HomelandDesc:subNameText(words, role.name)

                        local StringUtil = require("app.extends.StringUtil")
                        words = StringUtil:replaceNpcName(words,currMap)
                        
                        RichPrint("main", "YEL" .. role.name .. "：" .. words)
                        -- if TEACHER_TASK_IS_OPEN == true then
                        --     local TeacherTask = require("app.models.task.teacherTask.teacherTask")
                        --     local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
                        --     if receiveTask and type(receiveTask) ~= "number" and receiveTask.taskType == 1 then
                        --         if receiveTask.npcBaseId == role.baseId then
                        --             TeacherTask:setTeacherTaskAttr("isComplete", "Y")
                        --             currMap:removeRoomRole(receiveTask.roomId, receiveTask.npcId)
                        --             receiveTask.roomId = {}
                        --             TeacherTask:setTeacherTaskAttr("receiveTask", receiveTask)
                        --             currMap.__MapLayer:delayRefreshMap()
                        --         -- local TeacherTaskLayer =  currMap.__MapLayer.ControllLayer:getLayer("TeacherTaskLayer")
                        --         -- TeacherTaskLayer:initLayer()
                        --         end
                        --     end
                        -- end
                    end

                    Task:refreshTasks(role, "talk")
                end
            }
            table.insert(functionList, funcData)
        end

        -- 送礼 --
        if PRINT_MODE == 1 then
            print("role.canPresent = " .. tostring(role.canPresent))
        end
        if role.canPresent == 1 or role.canPresent == true then
            local funcData = {
                btnName = "送礼",
                btnFunc = function()
                    local presentId, present = role.receivePresent -- npc接受的礼物
                    print("此NPC接受的物品Id:", role.receivePresent)
                    -- assert(presentId, "presentId 不能为空")

                    --  已被装备的物品 并且背包只有一把 无法被送礼
                    if player:checkItemIsEquipbyItemId(presentId) and player:getItemCount(presentId) < 2 then
                        PopText("已装备物品无法送礼")
                        return
                    end

                    if presentId then
                        present = player:getItem(presentId)
                        if present and player:getItemCount(presentId) > 0 then
                            -- if TEACHER_TASK_IS_OPEN == true then
                            --     local TeacherTask = require("app.models.task.teacherTask.teacherTask")
                            --     local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
                            --     if receiveTask and type(receiveTask) ~= "number" and receiveTask.taskType == 2 then
                            --         if receiveTask.npcBaseId == role.baseId then
                            --             TeacherTask:setTeacherTaskAttr("isComplete", "Y")
                            --             currMap:removeRoomRole(receiveTask.roomId, receiveTask.npcId)
                            --             receiveTask.roomId = {}
                            --             TeacherTask:setTeacherTaskAttr("receiveTask", receiveTask)
                            --             currMap.__MapLayer:delayRefreshMap()
                            --         -- local TeacherTaskLayer =  currMap.__MapLayer.ControllLayer:getLayer("TeacherTaskLayer")
                            --         -- TeacherTaskLayer:initLayer()
                            --         end
                            --     end
                            -- end
                            local itemAttr = Item:getOneItemByKey(presentId)
                            --打印出送出去的礼物
                            if itemAttr then
                                RichPrint("main", "你送给" .. role.name .. "一" .. itemAttr.unit .. itemAttr.name)
                            end
                            player:addItemCount(presentId, -1,nil,nil,"送礼")
                            --统计下送出去物品
                            currMap:addItemCount(presentId,-1)
                            --送礼后 如果装备物品有多个并且该装备物品 背包排序在前，会先移除装备那把
                            if player:checkItemIsEquipbyItemId(presentId) then
                                PopText("你取下了身上的" .. itemAttr.name .. "并送给" .. role.name)
                                player:setEquipByName("weapon", nil)
                            end

                            -- 玩家有该物品,可以送礼
                            currMap:doConditionAndResult(
                                role.conditionAndResults,
                                {
                                    conditionType = "赠送",
                                    result = "成功",
                                    currRole = role,
                                    currRoomId = currMap:getCurrRoomId(),
                                    mapLayer = currMap.__MapLayer
                                }
                            )
                        else
                            -- 玩家没有该物品,不能送礼
                            currMap:doConditionAndResult(
                                role.conditionAndResults,
                                {
                                    conditionType = "赠送",
                                    result = "失败",
                                    currRole = role,
                                    currRoomId = currMap:getCurrRoomId(),
                                    mapLayer = currMap.__MapLayer
                                }
                            )
                            RichPrint("main", "CYN我不接受你的物品")
                        end
                        currMap.__MapLayer:delayRefreshMap()
                        -- 刷新房间条件结果
                        currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                        Task:refreshTasks(role, "present")
                    else
                        RichPrint("main", "CYN我不接受你的物品")
                    end
                end
            }

            table.insert(functionList, funcData)
        end

        -- 请教 --
        if role.canConsult == 1 or role.canConsult == true then
            local funcData = {
                btnName = "请教",
                btnFunc = function()
                    currMap:doConditionAndResult(
                        role.conditionAndResults,
                        {
                            operation = "请教",
                            currRole = role,
                            currRoomId = currMap:getCurrRoomId(),
                            mapLayer = currMap.__MapLayer
                        }
                    )
                    currMap.__MapLayer:delayRefreshMap()
                    -- 刷新房间条件结果
                    currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                    --  currMap.__MapLayer:replaceRoom( currMap:getCurrRoomId(), "center")
                    Task:refreshTasks(role, "consult")
                end
            }

            table.insert(functionList, funcData)
        end

        -- 拜师 --
        if role.canApprentice == 1 or role.canApprentice == true then
            local funcData = {
                btnName = "拜师",
                btnFunc = function()
                    local teacher = assert(Npc:getNpc(role:getAttr("realTeacher")))

                    -- 已经加入门派 不显示拜师确认界面
                    if player:hasFamily() then
                        player:obApprentice(teacher)

                        -- RichPrint("main", "你决定拜["..role.name.."] 为师。")
                        if PRINT_MODE == 1 then
                            print(currMap)
                        end
                        currMap:doConditionAndResult(
                            role.conditionAndResults,
                            {
                                operation = "拜师",
                                currRole = role,
                                currRoomId = currMap:getCurrRoomId(),
                                mapLayer = currMap.__MapLayer
                            }
                        )
                        -- self:setMapRole(role)
                        currMap.__MapLayer:delayRefreshMap()
                        -- 刷新房间条件结果
                        currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                        --  currMap.__MapLayer:replaceRoom( currMap:getCurrRoomId(), "center")
                        Task:refreshTasks(role, "apprentice")
                    else
                        -- 确认拜师
                        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                        local dialog = DialogALayer:getInstance()

                        dialog:hide()
                        dialog:show(
                            "你确定要加入【" .. teacher:getFamilyName() .. "】吗?\n拜入【" .. teacher:getFamilyName() .. "】将无法拜入其他门派。",
                            "师父: " .. role.name
                        )
                        dialog:setButton1(
                            "决定了",
                            function()
                                player:obApprentice(teacher)

                                local currMap = player:getCurrMap()
                                -- RichPrint("main", "你决定拜["..role.name.."] 为师。")
                                if PRINT_MODE == 1 then
                                    print(currMap)
                                end
                                currMap:doConditionAndResult(
                                    role.conditionAndResults,
                                    {
                                        operation = "拜师",
                                        currRole = role,
                                        currRoomId = currMap:getCurrRoomId(),
                                        mapLayer = currMap.__MapLayer
                                    }
                                )
                                -- self:setMapRole(role)
                                currMap.__MapLayer:delayRefreshMap()
                                -- 刷新房间条件结果
                                currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                                --  currMap.__MapLayer:replaceRoom( currMap:getCurrRoomId(), "center")
                                Task:refreshTasks(role, "apprentice")
                            end
                        )

                        dialog:setButton2(
                            "再想想",
                            function()
                                dialog:hide()
                            end
                        )
                        dialog:setWeChatVisible(false)
                    end
                end
            }

            table.insert(functionList, funcData)
        end

        -- 切磋 --
        if role.canCompete == 1 or role.canCompete == true then
            local funcData = {
                btnName = "切磋",
                btnFunc = function()
                    if role.isFromWeb == true then
                        if player:getFlag("PVP活动状态") == "忙碌" then
                            PopText("正在忙碌中")
                            return
                        end
                        if Map:checkRoomCanQieCuo(currMap:getCurrRoomId()) == true then
                            player:updateFightStatus("主动邀战等待中")
                            FubenClient:qieCuo(role.userid)
                        else
                            PopText("此乃文教之地，不可动武！")
                        end
                        return
                    else
                        if PRINT_MODE == 1 then
                            print("开始切磋 切磋胜利 = " .. role:getFlag("切磋胜利"))
                        end
                        currMap:doConditionAndResult(
                            role.conditionAndResults,
                            {
                                operation = "切磋",
                                currRole = role,
                                currRoomId = currMap:getCurrRoomId(),
                                mapLayer = currMap.__MapLayer
                            }
                        )

                        -- self:setMapRole(role)
                        currMap.__MapLayer:delayRefreshMap()
                        -- currMap.__MapLayer:replaceRoom(currMap:getCurrRoomId(), "center")
                        -- 判断测试是否可用, 如果可以用, 就调用新的战斗 add by TangJian 2016/11/02 17:16:44
                        if TANGJIAN_TEST_ENABLE then
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
                                                currRoomId = currMap:getCurrRoomId(),
                                                mapLayer = currMap.__MapLayer
                                            }
                                        )

                                        -- self:setMapRole(role)
                                        currMap.__MapLayer:delayRefreshMap()
                                        -- 刷新房间条件结果
                                        currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                                        -- if TEACHER_TASK_IS_OPEN == true then
                                        --     local TeacherTask = require("app.models.task.teacherTask.teacherTask")
                                        --     local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
                                        --     if
                                        --         receiveTask and type(receiveTask) ~= "number" and
                                        --             receiveTask.taskType == 3
                                        --      then
                                        --         if receiveTask.npcBaseId == role.baseId then
                                        --             TeacherTask:setTeacherTaskAttr("isComplete", "Y")
                                        --             currMap:removeRoomRole(receiveTask.roomId, receiveTask.npcId)
                                        --             receiveTask.roomId = {}
                                        --             TeacherTask:setTeacherTaskAttr("receiveTask", receiveTask)
                                        --             currMap.__MapLayer:delayRefreshMap()
                                        --         -- local TeacherTaskLayer =  currMap.__MapLayer.ControllLayer:getLayer("TeacherTaskLayer")
                                        --         -- TeacherTaskLayer:initLayer()
                                        --         end
                                        --     elseif
                                        --         receiveTask and type(receiveTask) ~= "number" and
                                        --             receiveTask.taskType == 4
                                        --      then
                                        --         TeacherTask:dealCompeteWinResult(currMap.__MapLayer, role, true)
                                        --     end
                                        -- end
                                        Task:refreshTasks(role, "compete")
                                    elseif winTeamId == 2 then
                                        -- PopText("你被" .. role:getName() .. "打趴在地")
                                        currMap:doConditionAndResult(
                                            role.conditionAndResults,
                                            {
                                                conditionType = "切磋",
                                                result = "失败",
                                                currRole = role,
                                                currRoomId = currMap:getCurrRoomId(),
                                                mapLayer = currMap.__MapLayer
                                            }
                                        )

                                        -- self:setMapRole(role)
                                        currMap.__MapLayer:delayRefreshMap()
                                        -- 刷新房间条件结果
                                        currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                                        -- if TEACHER_TASK_IS_OPEN == true then
                                        --     local TeacherTask = require("app.models.task.teacherTask.teacherTask")
                                        --     TeacherTask:dealCompeteWinResult(currMap.__MapLayer, role, false)
                                        -- end
                                    elseif winTeamId == 3 then
                                        currMap:doConditionAndResult(
                                            role.conditionAndResults,
                                            {
                                                conditionType = "切磋",
                                                result = "逃跑",
                                                currRole = role,
                                                currRoomId = currMap:getCurrRoomId(),
                                                mapLayer = currMap.__MapLayer
                                            }
                                        )
                                        -- 刷新房间条件结果
                                        currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                                        -- 刷新房间条件结果
                                        -- if TEACHER_TASK_IS_OPEN == true then
                                        --     local TeacherTask = require("app.models.task.teacherTask.teacherTask")
                                        --     TeacherTask:dealCompeteWinResult(currMap.__MapLayer, role, false)
                                        -- end
                                    else
                                        -- if TEACHER_TASK_IS_OPEN == true then
                                        --     local TeacherTask = require("app.models.task.teacherTask.teacherTask")
                                        --     TeacherTask:dealCompeteWinResult(currMap.__MapLayer, role, false)
                                        -- end
                                    end
                                end
                            )
                        end
                    end
                end
            }

            table.insert(functionList, funcData)
        end

        -- 杀死 --  商人类型的NPC 不能杀死
        if (role.canKill == 1 or role.canKill == true) and role.canSale ~= 1 and role.canSale ~= true then
            local funcData = {
                btnName = "决斗",
                btnFunc = function()
                    if role.isFromWeb == true then
                        FubenClient:jueDou(role.id, Helper:getOnlyId())
                        return
                    else
                        currMap:doConditionAndResult(
                            role.conditionAndResults,
                            {
                                operation = "杀死",
                                currRole = role,
                                currRoomId = currMap:getCurrRoomId(),
                                mapLayer = currMap.__MapLayer
                            }
                        )

                        -- 对房间内同队伍人员产生仇恨标记
                        player:setMapRoomState(currMap.id, currMap:getCurrRoomId(), role.teamMark)

                        -- self:setMapRole(role)
                        currMap.__MapLayer:delayRefreshMap()
                        -- currMap.__MapLayer:replaceRoom(currMap:getCurrRoomId(), "center")
                        currMap:removeTaskFromDelayTasks(role.id)
                        if TANGJIAN_TEST_ENABLE then
                            role:initNpcAttr() -- NPC状态初始化
                            currMap:afterFightWithShaSi(
                                player,
                                role,
                                function(winTeamId)
                                    -- 战斗胜利条件结果
                                    if winTeamId == 1 then
                                        -- PopText("你杀死了" .. role:getName())
                                        -- 玩家操作默认
                                        role:setFlag("是否死亡", true)
                                        --因为地图延时刷新 加个遮罩防止出现快速点击问题
                                        PopupLayerController:showLayer("GlobalShadeLayer",function (layer)
                                            layer:setPopText("")
                                            layer:showLayer()
                                        end)
                                        currMap:dowithRoleOperation(
                                            {
                                                operation = "杀死",
                                                result = "成功",
                                                player = player,
                                                currRole = role,
                                                currMap = currMap,
                                                currRoomId = currMap:getCurrRoomId()
                                            }
                                        )
                                        currMap:doConditionAndResult(
                                            role.conditionAndResults,
                                            {
                                                conditionType = "杀死",
                                                result = "成功",
                                                currRole = role,
                                                currRoomId = currMap:getCurrRoomId(),
                                                mapLayer = currMap.__MapLayer
                                            }
                                        )

                                        -- self:setMapRole(role)
                                        currMap.__MapLayer:delayRefreshMap()
                                        currMap.__MapLayer:delayFunc(0.1,function()
                                            PopupLayerController:hideLayer("GlobalShadeLayer",function (layer)
                                                layer:hideLayer()
                                            end)
                                        end)
                                        currMap:removeTaskFromDelayTasks(role.id)
                                        --卡顿优化
                                        currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                                        -- 刷新房间条件结果
                                        Task:refreshTasks(role, "kill")
                                        -- if TEACHER_TASK_IS_OPEN == true then
                                        --     local TeacherTask = require("app.models.task.teacherTask.teacherTask")
                                        --     local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
                                        --     if
                                        --         receiveTask and type(receiveTask) ~= "number" and
                                        --             receiveTask.taskType == 3
                                        --      then
                                        --         if receiveTask.npcBaseId == role.baseId then
                                        --             TeacherTask:setTeacherTaskAttr("isComplete", "Y")
                                        --             currMap:removeRoomRole(receiveTask.roomId, receiveTask.npcId)
                                        --             receiveTask.roomId = {}
                                        --             TeacherTask:setTeacherTaskAttr("receiveTask", receiveTask)
                                        --             currMap.__MapLayer:delayRefreshMap()
                                        --         -- local TeacherTaskLayer =  currMap.__MapLayer.ControllLayer:getLayer("TeacherTaskLayer")
                                        --         -- TeacherTaskLayer:initLayer()
                                        --         end
                                        --     elseif
                                        --         receiveTask and type(receiveTask) ~= "number" and
                                        --             receiveTask.taskType == 4
                                        --      then
                                        --         TeacherTask:dealDuelConditionAndResult(true, role, currMap)
                                        --     end
                                        -- end
                                        local ghosts = require("app.models.Activities.ghosts")
                                        ghosts:killGhost(currMap.id, currMap:getCurrRoomId(), role)
                                    elseif winTeamId == 2 then
                                        PopText("你被" .. role:getName() .. "打败了")
                                        -- add by XiaoZhiWei 2017/05/18 15:29:32 佣兵模式下,战斗失败不退出副本
                                        if User:getRole():getFlag("佣兵模式") == "开启" then
                                            -- 刷新房间条件结果
                                            currMap:doConditionAndResult(
                                                role.conditionAndResults,
                                                {
                                                    conditionType = "杀死",
                                                    result = "失败",
                                                    currRole = role,
                                                    currRoomId = currMap:getCurrRoomId(),
                                                    mapLayer = currMap.__MapLayer
                                                }
                                            )
                                            currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                                        else
                                            currMap.__MapLayer.TotalMapBtn_IsInit = false
                                            currMap.__MapLayer:quit()
                                        end
                                    elseif winTeamId == 3 then
                                        -- 刷新房间条件结果
                                        currMap:doConditionAndResult(
                                            role.conditionAndResults,
                                            {
                                                conditionType = "杀死",
                                                result = "逃跑",
                                                currRole = role,
                                                currRoomId = currMap:getCurrRoomId(),
                                                mapLayer = currMap.__MapLayer
                                            }
                                        )
                                        -- 刷新房间条件结果
                                        currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                                    else
                                    end
                                end
                            )
                        else
                        end
                    end
                end
            }
            table.insert(functionList, funcData)
        end

        -- 交易
        if role.canSale == 1 or role.canSale == true then
            local funcData = {
                btnName = "交易",
                btnFunc = function()
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
                                    -- 刷新房间条件结果
                                    currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                                    currMap:removeRoomRole(currMap:getCurrRoomId(), role.id)
                                    currMap.__MapLayer:refreshRole()
                                    RichPrint("main", "你才一个转身，回头便发现黑市商人已不知所踪了。")
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
                            -- 冥币商人
                            -- Chapman:getDeadCurrencyList(role, self, callBackFunc)

                            --冥币商人 改成新的npc商人
                            Chapman:getNpcChapman(role)
                        elseif Chapman:checkIsChapman(role.baseId) then
                            -- 醉梦生商人
                            Chapman:getChapmanList(role)
                        else
                            local MapBagLayer = require("app.views.layer.MapLayer.MapBagLayer")
                            local layer = MapBagLayer:getInstance()
                            layer:show()
                            layer:setRoles(
                                User:getRole(),
                                role,
                                function()
                                    -- 刷新房间条件结果
                                    if User:getRole():getCurrMapId() ~= "fb202" then
                                        currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                                    end
                                end
                            )
                        end
                    end
                end
            }

            table.insert(functionList, funcData)
        end

        -- 玩家自定义操作按钮
        if role.caozuo == 1 or role.caozuo == true then
            -- local functionButton = self:createFunctionButton()
            -- self.ListView_bottom:pushBackCustomItem(functionButton)
            -- table.insert(buttonList, functionButton)

            local btmName = "操作"
            if role.caozuoName ~= nil and string.len(role.caozuoName) > 0 then
                btmName = tostring(role.caozuoName)
            end

            local funcData = {
                btnName = btmName,
                btnFunc = function()
                    -- if role.caozuoName ~= "莲花落" and role.caozuoName ~= "唱莲花落" then
                    --     self:hideLayer(true)
                    -- end
                    currMap:doConditionAndResult(
                        role.conditionAndResults,
                        {
                            operation = "操作",
                            currRole = role,
                            currRoomId = currMap:getCurrRoomId(),
                            mapLayer = currMap.__MapLayer
                        }
                    )
                    -- self:setMapRole(role)
                    currMap.__MapLayer:delayRefreshMap()
                    -- 刷新房间条件结果
                    currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                end
            }
            table.insert(functionList, funcData)
        end

        -----------------------------------------------------------------------------------------------------------
        -- @author XiaoZhiWei
        -- @time 2016/12/19 18:03:53
        -- @desc 拓展5个自定义按钮
        for i = 1, 10 do
            -- 玩家自定义操作按钮
            if role["caozuo" .. tostring(i)] == 1 or role["caozuo" .. tostring(i)] == true then
                -- self.ListView_bottom:pushBackCustomItem(functionButton)
                local btmName = "操作"

                if role["caozuoName" .. tostring(i)] ~= nil and string.len(role["caozuoName" .. tostring(i)]) > 0 then
                    btmName = tostring(role["caozuoName" .. tostring(i)])
                end

                local funcData = {
                    btnName = btmName,
                    btnFunc = function()
                        currMap:doConditionAndResult(
                            role.conditionAndResults,
                            {
                                operation = "操作" .. tostring(i),
                                currRole = role,
                                currRoomId = currMap:getCurrRoomId(),
                                mapLayer = currMap.__MapLayer
                            }
                        )

                        currMap.__MapLayer:delayRefreshMap()
                        -- 刷新房间条件结果
                        currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                        Task:refreshTasks(role)
                    end
                }
                table.insert(functionList, funcData)
            end
        end

        -- add by XiaoZhiWei 2017/07/07 15:11:18 是测试服务器 并且是调试模式
        if Game:isTesting() == true and DEBUG_MODE == 1 and role.name == "武馆老管家" then
            local funcData = {
                btnName = "交易",
                btnFunc = function()
                    local TYPE_MAP_SELLER = 2
                    HttpManagerEx:getDevoteList(
                        TYPE_MAP_SELLER,
                        "youxia",
                        function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    if MapIsEmpty(data) == false then
                                        local SalesLayer = require("app.views.layer.SalesLayer.SalesLayer")
                                        local layer = SalesLayer:getInstance()
                                        layer:show()
                                        role.zhaoShuXiang = data.list
                                        layer:setRoles(User:getRole(), role)
                                        layer:setSellerType(TYPE_MAP_SELLER)
                                        layer:setTextDesc(data.yuanbao)
                                        layer:setSallerMenPai("youxia")
                                    end
                                end
                                return true
                            end
                        end,
                        IS_SHOW_WAITING,
                        HTTP_MANAGER_RETRY_TYPE_RETRY
                    )
                end
            }
        end
    elseif role.type == "item" then
        local operationList = {
            {
                name = "打开",
                flag = "canOpen"
            },
            {
                name = "拾取",
                flag = "canPickUp"
            },
            {
                name = "使用",
                flag = "canUse"
            },
            {
                name = "放入",
                flag = "canPushIn"
            },
            {
                name = "提取",
                flag = "canExtract"
            }
        }

        for i, operation in ipairs(operationList) do
            local operationName = operation.name
            if operation.flag == "canUse" and type(role.useName) == "string" then
                operationName = role.useName
            end
            local operationFlag = operation.flag
            assert(
                operationName and operationFlag,
                "operationName = " .. tostring(operationName) .. ", " .. "operationFlag = " .. tostring(operationFlag)
            )
            if role[operationFlag] == true or role[operationFlag] == 1 then
                local funcData = {
                    btnName = operationName,
                    btnFunc = function()
                        if operationName == "放入" then
                            local presentId, present = role.receivePresent -- 可以放入的物品
                            if presentId then
                                -- currMap.__MapLayer:replaceRoom(currMap.__MapLayer._currRoom.id, "center")
                                present = player:getItem(presentId)
                                if present then
                                    -- 玩家有该物品,可以送礼
                                    currMap:doConditionAndResult(
                                        role.conditionAndResults,
                                        {
                                            conditionType = "放入",
                                            result = "成功",
                                            currRole = role,
                                            currRoomId = currMap:getCurrRoomId(),
                                            mapLayer = currMap.__MapLayer
                                        }
                                    )
                                    player:addItemCount(presentId, -1)
                                else
                                    -- 玩家没有该物品,不能送礼
                                    currMap:doConditionAndResult(
                                        role.conditionAndResults,
                                        {
                                            conditionType = "放入",
                                            result = "失败",
                                            currRole = role,
                                            currRoomId = currMap:getCurrRoomId(),
                                            mapLayer = currMap.__MapLayer
                                        }
                                    )
                                    RichPrint("main", "你身上没有东西可以放进去。")
                                end

                                -- self:setMapRole(role)
                                currMap.__MapLayer:delayRefreshMap()
                                -- 刷新房间条件结果
                                currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                            else
                                RichPrint("main", "你身上没有东西可以放进去。")
                            end
                            return
                        end

                        -- add by XiaoZhiWei 2018/06/01 11:58:29 检查角色是否在当前房间,否则不执行条件结果
                        if currMap:checkRoleIsInRoom(currMap:getCurrRoomId(), role.id) == false then
                            return
                        end

                        -- 玩家操作默认
                        currMap:dowithRoleOperation(
                            {
                                operation = operation.name,
                                player = player,
                                currRole = role,
                                currMap = currMap,
                                currRoomId = currMap:getCurrRoomId(),
                                func = function()
                                    currMap.__MapLayer:delayRefreshMap()
                                end
                            }
                        )

                        -- 执行条件和结果
                        currMap:doConditionAndResult(
                            role.conditionAndResults,
                            {
                                operation = operation.name,
                                currRole = role,
                                currRoomId = currMap:getCurrRoomId(),
                                mapLayer = currMap.__MapLayer
                            }
                        )
                        Task:refreshTasks(role, "canOpen")
                        -- self:setMapRole(role)
                        currMap.__MapLayer:delayRefreshMap()
                        -- 刷新房间条件结果
                        currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                        -- currMap.__MapLayer:replaceRoom(currMap.__MapLayer._currRoom.id, "center")
                    end
                }
                table.insert(functionList, funcData)
            end
        end

        -----------------------------------------------------------------------------------------------------------
        -- @author XiaoZhiWei
        -- @time 2016/12/19 18:17:20
        -- @desc 拓展 5个自定义使用按钮
        for i = 1, 10 do
            if role["canUse" .. tostring(i)] == true or role["canUse" .. tostring(i)] == 1 then
                local operationName = "使用"
                if type(role["useName" .. tostring(i)]) == "string" then
                    operationName = role["useName" .. tostring(i)]
                end

                local funcData = {
                    btnName = operationName,
                    btnFunc = function()
                        -- add by XiaoZhiWei 2018/06/01 11:58:29 检查角色是否在当前房间,否则不执行条件结果
                        if currMap:checkRoleIsInRoom(currMap:getCurrRoomId(), role.id) == false then
                            return
                        end

                        -- 玩家操作默认
                        currMap:dowithRoleOperation(
                            {
                                operation = "使用" .. tostring(i),
                                player = player,
                                currRole = role,
                                currMap = currMap,
                                currRoomId = currMap:getCurrRoomId(),
                                func = function()
                                    currMap.__MapLayer:delayRefreshMap()
                                end
                            }
                        )

                        -- 执行条件和结果
                        currMap:doConditionAndResult(
                            role.conditionAndResults,
                            {
                                operation = "使用" .. tostring(i),
                                currRole = role,
                                currRoomId = currMap:getCurrRoomId(),
                                mapLayer = currMap.__MapLayer
                            }
                        )

                        -- self:setMapRole(role)
                        currMap.__MapLayer:delayRefreshMap()
                        -- 刷新房间条件结果
                        currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                        Task:refreshTasks(role)
                    end
                }

                table.insert(functionList, funcData)
            end
        end
    end

    --@desc 程药发NPC的结构处理
    if role.buttons then
        for k,button in pairs(role.buttons) do
            local funcData = {
                btnName = button.name,
                btnFunc = button.func
            }
            table.insert( functionList,funcData )
        end
    end

    return functionList
end

function RoleObserveModel:getRoleDesc(role)
    local player = User:getRole()
    local desc = ""
    if role.type == "role" then
        if role.isFromWeb == true then 
            desc = self:getWebRoleDesc(role)
        else
            desc = role:getDsc(player)
        end
       
    elseif role.type == "item" then
        desc = role.dsc
    end

    return desc
end

function RoleObserveModel:getWebRoleDesc(role)
    local player = User:getRole()
    local desc = ""
    local cl = "WHT"
    local sex = "他"
    if role.sex == "女" then
        sex = "她"
    elseif role.sex == "野兽" then
        return (role.dsc == nil and "" or tostring(role.dsc))
    end

    if role:checkRoleIsPolymorph() then  --易容改貌
        if role.polymorph.sex == "女" then
            sex = "她"
        else
            sex = "他"
        end
    end
    if MapIsEmpty(role) == false then
        local relation = player:getRelation(role)
        if relation and role:getAttr("onlyId") ~= User:getRoleAttr("onlyId") then
            desc = cl..role.name.."是你的"..relation.."。\n"
        end
    end
    local dsc = ""
    if role.dsc then
        dsc = role.dsc
    end
    local title = ""
    if role.title then 
        title = "江湖人称"..role.title.."。"
    end
    local jiaLiDsc = "HIG很微妙"
    if role.jiaLiDsc then 
        jiaLiDsc = role.jiaLiDsc
    end
    --姓名
    desc = desc..cl..sex.."就是"..tostring(role.name).."。"..title..tostring(dsc).."\n"
    --年龄
    desc = desc..cl..sex.."看起来约"..role:getAgeDsc()
    --面貌
    desc = desc.."，"..sex..cl.."生得"..role:getFaceDsc()..cl.."。\n"
    --武功
    desc = desc..cl..sex.."的武功看来"..role:getKongfuDesc(role.kongfu)..cl.."，出手似乎"..jiaLiDsc..cl.."。\n"
    --气血
    desc = desc..cl..sex.."看起来"..role:getQiDsc().."。\n"
    --传承者信息
    desc = desc..role.inheritRoleDsc

    return desc
end

function RoleObserveModel:getTeacherNpcFuncList(role)
    local functions = role:getAttr("functions")

    local funcList = {}

    if MapIsEmpty(functions) == false then
        for i, v in ipairs(functions) do
            local funcData = {
                btnName = v.name,
                btnFunc = function()
                    v.func(role)
                end
            }

            table.insert(funcList, funcData)
        end
    end

    if role.type == "role" then
        self:addMyTeacherFunc(role, funcList)
    
        self:addSalesFunc(role, funcList)

        self:addFestivalFunc(role, funcList)
    end

    return funcList
end

function RoleObserveModel:addMyTeacherFunc(role, funcList)
    --@desc 请安按钮
    if role:getAttr("id") ~= User:getRole():getAttr("teacherId") then
        return
    end
    
    local qingjiaoBtn = {
        btnName = "请教",
        btnFunc = function()
            return role:obConsult(User:getRole())
        end
    }
    table.insert(funcList, qingjiaoBtn)


    local qinAn = {
        btnName = "请安",
        btnFunc = function()
            if role:getTimeLimitFlag("请安点击时间") == 0 then
                HttpManagerEx:addDevotePoint(
                    1,
                    0,
                    function(status, errcode, errmsg, data)
                        if status == 200 then
                            if errcode == 0 then
                                RichPrint("main", "你恭恭敬敬地向[" .. tostring(role.name) .. "]磕头请安，叫道：师傅在上，徒儿给您请安了！")
                                RichPrint("main", "[" .. tostring(role.name) .. "]对你微微点头并示意你起身。")
                                RichPrint("main", data.msg)
                            else
                                PopText("你今天已经请过安了！")
                            end

                            local currLayer = MainControllLayer:getCurrLayer()
                            if currLayer == "TeacherLayer" then
                                local teacherLayer = MainControllLayer:getLayer(currLayer)
                                teacherLayer:refreshGongXian()
                            end

                            do --每日任务
                                local DailyTasksActivity = require("app.models.Action.DailyTasksActivity")
                                DailyTasksActivity:addDailyTaskPoint("qingan")
                            end
                            
                        end
                    end,
                    IS_SHOW_WAITING
                )
                role:setTimeLimitFlag("请安点击时间", 1, 3)
            else
                PopText("请不要频繁点击！")
            end
        end
    }
    table.insert(funcList, qinAn)

    local groupRankingBtn = {
        btnName = "进境排行",
        btnFunc = function()
            --@RefType [src.app.models.family.FamilyGroup#FamilyGroup]
            local FamilyGroup = require("app.models.family.FamilyGroup")

            FamilyGroup:getGroupMembers(
                function(group_data)
                    FamilyGroup:getGroupRank(
                        function(rank)
                            -- Helper:print_lua_table(rank)

                            local rank_ui_data = {}

                            for rank_index, rank_data in ipairs(rank) do
                                local user_id = rank_data.userid
                                local rank_value = {
                                    name = nil,
                                    kongfu = 0,
                                    prestige = 0
                                }
                                if tostring(user_id) == tostring(User:getUserId()) then
                                    local player = User:getRole()
                                    rank_value.name = player:getAttr("name")
                                else
                                    for i, role_data in ipairs(group_data) do
                                        if tostring(user_id) == tostring(role_data.userid) then
                                            rank_value.name = role_data.name
                                            break
                                        end
                                    end
                                end

                                if MapIsEmpty(rank_value) == false then
                                    Helper:tableCover(rank_value, rank_data)
                                    table.insert(rank_ui_data, rank_value)
                                end
                            end
                            MainControllLayer:pushLayer("FamilyGroupRankLayer")
                            local layer = MainControllLayer:getLayer("FamilyGroupRankLayer")
                            layer:showLayer(rank_ui_data)

                        end
                    )
                end
            )
        end
    }
    table.insert(funcList, groupRankingBtn)
    
    local player = User:getRole()
    if player:getFlag("平复真气") == 1 then
        local pingfuBtn = {
            btnName = "平复真气",
            btnFunc = function ()
                PopupLayerController:showLayer(
                    "MeridianCalmDownLayer",
                    function(layer)
                        layer:showLayer(2)
                    end
                )
            end
        }
        
        table.insert(funcList, pingfuBtn)
    end

end


function RoleObserveModel:addSalesFunc(role, funcList)
    local salesList = Teacher:getTeacherSalers()
    if salesList[role:getAttr("id")] ~= true then
        return
    end

    local salesBtn = {
        btnName = "交易",
        btnFunc = function()
            local TYPE_TEACHER = 1
            HttpManagerEx:getDevoteList(
                TYPE_TEACHER,
                role:getFamilyId(),
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            if MapIsEmpty(data) == false then
                                local SalesLayer = require("app.views.layer.SalesLayer.SalesLayer")
                                local layer = SalesLayer:getInstance()
                                layer:show()
                                role.zhaoShuXiang = data.list
                                layer:setRoles(
                                    User:getRole(),
                                    role,
                                    function()
                                        local currLayerName = MainControllLayer:getCurrLayer()
                                        if currLayerName == "TeacherLayer" then
                                            local teacherLayer = MainControllLayer:getLayer(currLayerName)
                                            teacherLayer:refreshGongXian()
                                        end
                                    end
                                )
                                layer:setSellerType(TYPE_TEACHER)
                                layer:setTextDesc(data.yuanbao)
                                layer:setSallerMenPai(role:getFamilyId())
                            end
                        end
                        return true
                    end
                end,
                IS_SHOW_WAITING,
                HTTP_MANAGER_RETRY_TYPE_RETRY
            )
        end
    }
    table.insert(funcList, salesBtn)
end

function RoleObserveModel:addFestivalFunc(role, funcList)  
end

return RoleObserveModel
00000000