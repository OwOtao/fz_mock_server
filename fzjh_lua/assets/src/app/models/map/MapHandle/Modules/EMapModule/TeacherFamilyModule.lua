--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local TeacherFamilyModule = class("TeacherFamilyModule", require("app.models.map.MapHandle.Modules.BaseModule"))

--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
TeacherFamilyModule.mapId = nil

--@desc 涉及房间 : 格式{["id"] = true} 默认为nil，无限制
TeacherFamilyModule.roomId = nil

--@desc 开启状态，默认开启
TeacherFamilyModule.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
TeacherFamilyModule.activityTime = 0

--@desc 子模块
TeacherFamilyModule.childModule = {}

--@desc 条件结果的方法
TeacherFamilyModule.doResult = {
    ["师门交谈"] = function(map, result, environment)
        local player = User:getRole()

        local teacher = environment.currRole

        teacher:obTalk(player)
    end,
    ["拜师"] = function(map, result, environment)
        local player = User:getRole()

        local teacher = environment.currRole
        player:obApprentice(teacher)
    end,
    ["师门请教"] = function(map, result, environment)
        local player = User:getRole()

        local teacher = environment.currRole
        teacher:obConsult(player)
    end,
    ["师门比武"] = function(map, result, environment)
        local player = User:getRole()

        local teacher = environment.currRole

        local operations = environment.currRole.operations

        if MapIsEmpty(operations) == true then
            operations = environment.currRoom.operations
        end

        local FamilyGroup = require("app.models.family.FamilyGroup")
        local dayFlag = player:getDayFlag(FamilyGroup.FLAGS_PREFIX.DAY_FIGHT_FLAG .. teacher.realTeacher)

        teacher:obCompete(
            player,
            function(fightLayer, fightEvent, ...)
                if fightEvent == fightLayer.EVENT_TYPE_FIGHT_FINISH then
                    local winTeamId, teams = ...

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

                    map.__MapLayer:delayRefreshMap()
                elseif fightEvent == fightLayer.EVENT_TYPE_FIGHT_RUNAWAY then
                    if MapIsEmpty(operations) == false then
                        map:doOperationByName("逃跑", operations, environment)
                    end
                    map.__MapLayer:delayRefreshMap()
                end
            end
        )
    end,
    ["舍友交谈"] = function(map, result, environment)
        --[[
            检查对方的期望物品
        ]]
        local role = environment.currRole

        local player = User:getRole()

        local FamilyGroup = require("app.models.family.FamilyGroup")

        local groupTemplate = FamilyGroup:getMemberTemplateByFamilyId(role.fgId)

        local bestItemId = FamilyGroup:getBestGiftItemId(role.userid, role.fgId)

        local giftFlag = FamilyGroup.FLAGS_PREFIX.GIFT_ITEMID_FLAG .. role.userid

        local sendGiftItemId = player:getDayFlag(giftFlag)

        local unGiftWords, bestGiftWords = FamilyGroup:getTalkWordsByBestItemId(bestItemId, role.fgId)

        local talk_word
        if sendGiftItemId == 0 then
            --@desc 今日还未送礼
            talk_word = unGiftWords[math.random(1, #unGiftWords)]
        elseif sendGiftItemId == bestItemId then
            --@desc 已送礼
            talk_word = bestGiftWords[math.random(1, #bestGiftWords)]
        elseif sendGiftItemId ~= bestItemId then
            local unHappyWords = groupTemplate["unhappyWords"]
            local list = string.split(unHappyWords, ";")
            talk_word = list[math.random(1, #list)]
        end

        RichPrint("main", "YEL" .. role.name .. "：" .. talk_word)
    end,
    ["舍友送礼"] = function(map, result, environment)
        --@desc 一天只能送一次
        local FamilyGroup = require("app.models.family.FamilyGroup")

        local player = User:getRole()

        local role = environment.currRole

        if player:getDayFlag(FamilyGroup.FLAGS_PREFIX.GIFT_ITEMID_FLAG .. role.userid) ~= 0 then
            PopText("您今日已对" .. role.name .. "送过一次礼物了。")
            return
        end

        local groupTemplate = FamilyGroup:getMemberTemplateByFamilyId(role.fgId)

        if MapIsEmpty(groupTemplate) then
            print("数据有误")
            return
        end

        --@desc 送礼列表
        local itemList = FamilyGroup:getGiftList(role.userid, role.fgId)

        local bestItemId = FamilyGroup:getBestGiftItemId(role.userid, role.fgId)

        -- if PRINT_MODE == 1 then
        print("-------------" .. role.name .. "--------------")
        print("今日是否送礼标记：" .. FamilyGroup.FLAGS_PREFIX.GIFT_ITEMID_FLAG .. role.userid)
        print("期望礼物标记" .. FamilyGroup.FLAGS_PREFIX.BEST_FLAG .. role.userid)
        print("期望礼物ID：" .. bestItemId)
        print("--------------------------------------------")
        -- end

        PopupLayerController:showLayer(
            "ItemSelectLayer2",
            function(layer)
                local list = {}
                for _, itemId in ipairs(itemList) do
                    local item = player:getOneItemByKey(itemId)
                    local count = player:getItemCount(item.id)

                    local temp = {
                        id = item.id,
                        name = item.name,
                        desc = "已拥有" .. count .. item.unit
                    }
                    table.insert(list, temp)
                end

                layer:setTitle("WHT送礼NOR")

                layer:setDesc("你打算送礼给你的同门" .. role.name .. "。你打算用何种物品以表同门之情呢？")

                layer:setList(list)

                layer:setBtnClickFunc(
                    function(itemId)
                        local item = player:getOneItemByKey(itemId)

                        local roleCount = player:getItemCount(itemId)

                        if roleCount < 1 then
                            PopText("你没有该物品")
                            return
                        end

                        --@desc 亲密度
                        local addIntimacy = 0

                        --@desc 声望
                        local addPrestige = 0

                        if itemId == bestItemId then
                            addPrestige = 20
                            addIntimacy = math.random(30, 70)
                        else
                            addPrestige = 5
                        end

                        local itemCount = 1

                        FamilyGroup:sendGift(
                            role.userid,
                            itemId,
                            itemCount,
                            addIntimacy,
                            addPrestige,
                            function(serverData)
                                player:addItemCount(itemId, -itemCount)

                                player:setDayFlag(FamilyGroup.FLAGS_PREFIX.GIFT_ITEMID_FLAG .. role.userid, itemId)

                                PopText("您送了一" .. item.unit .. item.name .. "给" .. role.name)

                                if serverData.addIntimacy ~= 0 then
                                    PopText(player:getCHAttrName("intimacy") .. " +" .. serverData.addIntimacy)
                                    FamilyGroup:updateLocalUserIntimacy(role, serverData.totalIntimacy)
                                end

                                if serverData.addPrestige ~= 0 then
                                    PopText(player:getCHAttrName("prestige") .. " +" .. serverData.addPrestige)
                                end

                                layer:hideLayer()
                            end,
                            function(errcode, errmsg)
                                if errcode == 2 then
                                    PopText("您今日已对" .. role.name .. "送过一次礼物了。")
                                else
                                    PopText(errmsg)
                                end
                            end
                        )
                    end
                )

                layer:showLayer()
            end
        )
    end,
    ["舍友收礼"] = function(map, result, environment)
        local role = environment.currRole

        local player = User:getRole()

        local FamilyGroup = require("app.models.family.FamilyGroup")

        FamilyGroup:getGift(
            role,
            function(data, haveGiftDesc)
                local gifts = data.gainGifts
                local giftList = {}
                for _, gift in ipairs(gifts) do
                    if giftList[gift.gift] == nil then
                        giftList[gift.gift] = gift.num
                    else
                        giftList[gift.gift] = giftList[gift.gift] + gift.num
                    end
                end

                for itemId, count in pairs(giftList) do
                    player:addItemCount(itemId, count)
                    local item = player:getOneItemByKey(itemId)
                    PopText("获得了" .. item.name .. " X" .. count)
                end

                RichPrint("main", "YEL" .. role.name .. "：" .. haveGiftDesc)
            end
        )
    end,
    ["舍友切磋"] = function(map, result, environment)
        --@RefType [src.app.models.family.FamilyGroup#FamilyGroup]
        local FamilyGroup = require("app.models.family.FamilyGroup")

        local player = User:getRole()

        local role = environment.currRole

        local dayFlag = player:getDayFlag(FamilyGroup.FLAGS_PREFIX.DAY_FIGHT_FLAG .. role.userid)

        if dayFlag ~= 0 then
            PopText("您与" .. role.name .. "今日已进行过一次切磋。")
            return
        end

        local operations = environment.currRole.operations

        if MapIsEmpty(operations) == true then
            operations = environment.currRoom.operations
        end

        local callback = function(fightLayer, fightEvent, ...)
            if fightEvent == fightLayer.EVENT_TYPE_FIGHT_FINISH then
                local winTeamId, teams = ...

                if winTeamId == 1 then
                    local ADD_PRESTIGE_VALUE = 10
                    if MapIsEmpty(operations) == false then
                        map:doOperationByName("切磋胜利", operations, environment)
                    end

                    local FamilyPrestige = require("app.models.family.FamilyPrestige")

                    FamilyPrestige:addUserPrestige(
                        ADD_PRESTIGE_VALUE,
                        "qcWin_" .. role.userid,
                        function(data)
                            local addPrestige = data.num

                            if addPrestige ~= nil and addPrestige ~= 0 then
                                PopText(player:getCHAttrName("prestige") .. " +" .. addPrestige)
                            end
                        end
                    )

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
                player:setDayFlag(FamilyGroup.FLAGS_PREFIX.DAY_FIGHT_FLAG .. role.userid, 1)
                map.__MapLayer:delayRefreshMap()
            elseif fightEvent == fightLayer.EVENT_TYPE_FIGHT_RUNAWAY then
                if MapIsEmpty(operations) == false then
                    map:doOperationByName("逃跑", operations, environment)
                end
                map.__MapLayer:delayRefreshMap()
                player:setDayFlag(FamilyGroup.FLAGS_PREFIX.DAY_FIGHT_FLAG .. role.userid, 1)
            end
        end

        --@desc 恢复满血状态
        role:setAttr("qiPercent", 1.0)
        role:setAttr("qi", role:getCurrQiMax())
        role:setAttr("neili", role:getFinalAttr("neiliMax"))

        --@desc 切磋胜利文本
        local wintext = Helper:getDef(role:getAttr("wintext"), "您比武赢了" .. role:getAttr("name") .. "。")

        --@desc 切磋失败文本
        local losetext = Helper:getDef(role:getAttr("losetext"), "您比武输给了" .. role:getAttr("name") .. "。")

        local FightLayer = require("app.views.layer.FightLayer.FightLayer")
        FightLayer:startMapFight(
            {player},
            {role},
            function(fightLayer, eventType, ...)
                local fight = fightLayer:getFight()
                if eventType == FightLayer.EVENT_TYPE_FIGHT_READY then
                    -- fightLayer:printRolePrologue(1, "切磋")
                    -- 暂停地图场景渲染
                    MainControllLayer:pauseUpdate()

                    -- 战斗开始的时候设置下玩家
                    local leftRole = fight:getRoleByTeamIdAndInTeamId(1, 1)
                    fight:setPlayer(leftRole)
                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_START then
                    PopText("战斗开始!!!")
                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_FINISH then
                    local winTeamId, teams = ...

                    -- 隐藏按钮区域
                    fightLayer:callUIMemFunc("setButtonAreaVisble", false)
                    -- 显示战斗结束文本区域
                    fightLayer:callUIMemFunc("showFightEndTextArea")

                    FubenClient:setValue("isFighting", false)
                    User:getRole():updateFightStatus("战斗结束")

                    User:getRole():addSeeSkillAfterFight(role) --战斗结束后添加见闻武学技能

                    -- 战斗胜利条件结果
                    if winTeamId == 1 then
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "胜利")
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你战胜了" .. role:getName() .. "。")
                        RichPrint("main", wintext)
                    elseif winTeamId == 2 then
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "失败")
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你被" .. role:getName() .. "击败了。")
                        RichPrint("main", losetext)
                    end

                    fightLayer:callUIMemFunc(
                        "setFightEndTextAreaReleaseFunc",
                        function()
                            MainControllLayer:resumeUpdate()

                            fightLayer:hide(
                                function()
                                    fightLayer:destroyInstance()
                                    cleanTable(fightLayer)
                                end
                            )
                        end
                    )

                    callback(fightLayer, eventType, ...)
                elseif eventType == FightLayer.EVENT_TYPE_FIGHT_RUNAWAY then
                    FubenClient:setValue("isFighting", false)
                    player:updateFightStatus("战斗结束")

                    User:getRole():addSeeSkillAfterFight(role) --战斗结束后添加见闻武学技能

                    -- 隐藏按钮区域
                    fightLayer:callUIMemFunc("setButtonAreaVisble", false)
                    -- 显示战斗结束文本区域
                    fightLayer:callUIMemFunc("showFightEndTextArea")

                    -- 设置战斗结束文本区域的文本
                    fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "逃跑")
                    fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, player.name .. "大喝一声：“三十六计，走为上计")

                    fightLayer:callUIMemFunc(
                        "setFightEndTextAreaReleaseFunc",
                        function()
                            fightLayer:hide(
                                function()
                                    fightLayer:destroyInstance()
                                    cleanTable(fightLayer)
                                end
                            )
                        end
                    )
                    RichPrint("main", "你逃跑了。")

                    callback(fightLayer, eventType, ...)
                end
            end
        )
    end,
    ["门派故事"] = function(map, result, environment)
        local menPaiStr = User:getRole():getFamilyName()
        environment.currRole:showTeacherAnimation(menPaiStr)
    end
}

local ignoreRoomList = {
    ["fb616_02"] = true,
    ["fb616_03"] = true,
    ["fb616_04"] = true,
    ["fb616_05"] = true,
    ["fb616_06"] = true,
    ["fb616_07"] = true,
    ["fb616_08"] = true,
    ["fb616_09"] = true,
    ["fb616_10"] = true,
    ["fb616_11"] = true,
    ["fb616_12"] = true,
    ["fb616_13"] = true
}

--@author:Liang SongQiang
--@time:2019-01-31 18:18:33
--@map: [src.app.models.EMap.EMap#EMap]
function TeacherFamilyModule:entryMap(map, currTime)
    --@RefType [src.app.models.family.FamilyGroup#FamilyGroup]
    local FamilyGroup = require("app.models.family.FamilyGroup")

    if map:getMapType() == MAP_TYPE.TEACHERMAP then
        local randomRoomList = {}
        local rooms = map:getRoomMap()
        for roomId, room in pairs(rooms) do
            if room.mapHide == 1 or ignoreRoomList[roomId] == true then
            else
                -- add by XiaoZhiWei 2018/05/18 20:58:38 全部都需要设置成已进入
                room.haveBeenTo = true
                table.insert(randomRoomList, roomId)
            end
        end

        local npcs = map:getRoles()

        for npdId, role in pairs(npcs) do
            if role.type == "role" then
                local teacherId = role.realTeacher

                if teacherId ~= nil then
                    local teacher = Npc:getNpc(teacherId)

                    Helper:tableCover(role, teacher)
                end
            end
        end

        FamilyGroup:getGroupMembers(
            function(data)
                --@desc 如果有缓存，先删除出房间
                if MapIsEmpty(map.familyGroups) == false then
                    for roleId, roomId in pairs(map.familyGroups) do
                        map:removeRoomRole(roomId, roleId)
                    end
                end

                if MapIsEmpty(data) then
                    return
                end

                FamilyGroup:getAllMembersIntimacy(
                    function(intimacyList)
                        --@desc 记录随机出现的房间
                        map.familyGroups = {}
                        for _, roleData in ipairs(data) do
                            if intimacyList[roleData.userid] ~= nil then
                                FamilyGroup:updateLocalUserIntimacy(roleData, intimacyList[roleData.userid])
                            end
                            local roomId = randomRoomList[math.random(1, #randomRoomList)]
                            local role = FamilyGroup:initMapMember(roleData)
                            map.familyGroups[role.id] = roomId
                            local MapInfo = require("app.models.map.MapInfo")
                            MapInfo:addMapRole(map, role)
                            MapInfo:addRoleToRoom(map, roomId, role.id)
                        end

                        print("=================== 舍友加入房间 ================")
                        Helper:print_lua_table(map.familyGroups)
                        print("================================================")
                    end
                )
            end
        )
    end
end

return TeacherFamilyModule
00000000000000