--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local BaseResults = class("BaseResults", require("app.models.map.MapHandle.Modules.BaseModule"))

--@desc 条件结果的方法
BaseResults.doResult = {
    ["弹出文本"] = function(map, result, environment)
        local PopRichText = require("app.views.layer.PopLayer.PopText")
        local popRichText = PopRichText:pop(result.arg2)
    end,
    ["地图标记设置"] = function(map, result, environment)
        map:setFlag(result.arg2, tonumber(result.arg3))
    end,
    ["地图标记变化"] = function(map, result, environment)
        map:setFlag(result.arg2, map:getFlag(result.arg2) + result.arg3)
        print(map._flags[result.arg2])
    end,
    ["人物标记设置"] = function(map, result, environment)
        if PRINT_MODE == 1 then
            print("人物标记设置" .. result.arg2 .. " = " .. result.arg3)
        end
        environment.currRole:setFlag(result.arg2, result.arg3)
        if PRINT_MODE == 1 then
            print(result.arg2 .. " = " .. environment.currRole:getFlag(result.arg2))
        end
    end,
    ["玩家标记设置"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        player:setFlag(result.arg2, result.arg3)
        --缉拿任务判断完成
        if player:getFlag("缉拿任务") == 2 then
            PopText("缉拿成功")
            local Task = require("app.models.task.Task")
            local roleTsak = Task:getRoleTask("task20")
            roleTsak.state = TASK_STATE_TO_SUBMIT
            player:setFlag("缉拿任务", 0)
        end
    end,
    ["玩家时间标记设置"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        player:setDayFlag(result.arg2, result.arg3)
    end,
    ["玩家定时标记设置"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        player:setTimeLimitFlag(result.arg2, result.arg3, result.arg4)
    end,
    ["更新玩家定时标记"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        player:updateTimeLimitFlag(result.arg2, player:getTimeLimitFlag(result.arg2) + result.arg3)
    end,
    ["玩家标记设置当前时间"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        player:setFlag(result.arg2, GetTime())
    end,
    ["玩家时间标记变化"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        player:setDayFlag(result.arg2, player:getDayFlag(result.arg2) + result.arg3)
    end,
    ["玩家标记变化"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        player:setFlag(result.arg2, player:getFlag(result.arg2) + result.arg3)
    end,
    ["可传承玩家标记设置"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        player:setInheritFlag(result.arg2, result.arg3)
    end,
    ["可传承玩家标记变化"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        player:setInheritFlag(result.arg2, player:getInheritFlag(result.arg2) + result.arg3)
    end,
    ["人物标记变化"] = function(map, result, environment)
        local currRole = environment.currRole
        currRole:setFlag(result.arg2, currRole:getFlag(result.arg2) + result.arg3)
    end,
    ["玩家属性变化"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(), User:getRole())

        local numValue = tonumber(result.arg3)

        local AttrRecord = require("app.models.Record.UserAttrRecord.AttrRecord")

        local AttrDoChange = require("app.models.role.attr.AttrDoChange")

        if numValue ~= nil then
            local tips = {
                ["qi"] = "气血",
                ["qiPercent"] = "气血上限",
                ["neili"] = "内力",
                ["zhengqi"] = "正气",
                ["breathVal"] = "真气"
            }
            local attrName = result.arg2
            local addValue = tonumber(map:checkCanGetReward(result, player))
            local val = math.abs(addValue)
            if tips[attrName] ~= nil then
                if addValue > 0 then
                    PopText("GRN" .. tips[attrName] .. " +" .. tostring(val))
                else
                    PopText("RED" .. tips[attrName] .. " -" .. tostring(val))
                end
            end

            --@RefType [src.app.models.role.attr.AttrDoChange#AttrDoChange]
            local doAttrChange =
                AttrDoChange:create(
                player,
                AttrRecord.R_TYPE.MAP_RESULT,
                attrName,
                addValue,
                {
                    mapid = map.id,
                    npcid = environment.currRole.id,
                    func = "add",
                    rlt = result.arg1
                }
            )

            doAttrChange:doAttrGet(
                function(attrName, value)
                    player:addAttr(attrName, value)
                    if value ~= 0 then -- add by XiaoZhiWei 2017/03/13 15:08:14 为0的时候不需要有文本提示信息
                        map:richPrintText(player, result.arg2, addValue) -- 属性变化文本显示
                    end
                end
            )
        else
            local attrName = result.arg2
            local value = result.arg3
            --@RefType [src.app.models.role.attr.AttrDoChange#AttrDoChange]
            local doAttrChange =
                AttrDoChange:create(
                player,
                AttrRecord.R_TYPE.MAP_RESULT,
                attrName,
                value,
                {
                    mapid = map.id,
                    npcid = environment.currRole.id,
                    func = "set",
                    rlt = result.arg1
                }
            )

            doAttrChange:doAttrGet(
                function(attrName, value)
                    player:setAttr(attrName, value)
                    map:richPrintText(player, attrName, value) -- 属性变化文本显示
                end
            )
        end

    end,
    ["NPC属性变化"] = function(map, result, environment)
        if not result.arg2 then
            print("NPC属性变化........................arg2位空")
            return
        end
        local npc = map:getRole(result.arg2)
        local value = math.abs(result.arg4)
        npc:addAttr(result.arg3, value)
        print("测试数据:npc的" .. npc:getCHAttrName(result.arg3) .. "发生改变.......+", value)
    end,
    ["玩家扣血"] = function(map, result, environment)
        local deltaHp = result.arg2
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        --print( "## 玩家扣血 " .. tostring( deltaHp ) )
        player:addAttr("qi", -result.arg2)
        map:richPrintText(player, "qi", -result.arg2) -- 属性变化文本显示

        if deltaHp < 0 then
            --扣血正好相反
            PopText("RED气血" .. " +" .. tostring(-deltaHp))
        else
            PopText("GRN气血" .. " -" .. tostring(deltaHp))
        end

        if player:getAttr("qi") <= 0 then
            player:addAttr("dead", 1)
            map:richPrintText(player, "dead", 1) -- 属性变化文本显示
            player:setAttr("deadReason", result.arg3)
            map:richPrintText(player, "deadReason", result.arg3) -- 属性变化文本显示
            PopText("你被" .. result.arg3 .. "死了")
            --map.__MapLayer.ControllLayer:popLayer()
            map.__MapLayer.TotalMapBtn_IsInit = false
            map.__MapLayer:quit()
        end
    end,
    ["玩家扣血百分比"] = function(map, result, environment)
        local percentHp = result.arg2 -- 百分比
        local deadReason = result.arg3 --
        local percentType = result.arg4 -- 1 生命值上限扣血， 2 当前生命值百分比扣血
        local player = Helper:getDef(map:getPlayer(),User:getRole())

        if percentType == nil then
            percentType = 1
        end

        local num = 0
        if percentType == 1 then
            num = player:getCurrQiMax() * (percentHp / 100)
        elseif percentType == 2 then
            num = player:getAttr("qi") * (percentHp / 100)
        end
        player:addAttr("qi", -num)
        -- 属性变化文本显示
        map:richPrintText(player, "qi", -num)

        if num < 0 then
            --扣血正好相反
            PopText("RED气血" .. " +" .. tostring(math.floor(-num)))
        else
            PopText("GRN气血" .. " -" .. tostring(math.floor(num)))
        end

        if player:getAttr("qi") <= 0 and deadReason ~= nil then
            player:addAttr("dead", 1)
            map:richPrintText(player, "dead", 1) -- 属性变化文本显示
            player:setAttr("deadReason", deadReason)
            map:richPrintText(player, "deadReason", deadReason) -- 属性变化文本显示
            PopText("你被" .. deadReason .. "死了")
            --map.__MapLayer.ControllLayer:popLayer()
            map.__MapLayer.TotalMapBtn_IsInit = false
            map.__MapLayer:quit()
        end
    end,
    ["玩家物品变化"] = function(map, result, environment)
        local itemId = result.arg2
        local itemCount = tonumber(result.arg3)
        local printText = result.arg4
        local itemType = result.arg5 --物品类型，用来判断是否要进行特殊处理
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        if itemCount == 0 then
            return
        end
        --增加能否获取物品的判断 7/22
        if not map:addItemCount(itemId, itemCount) then
            map:dropItem(environment.currRoomId, itemId, itemCount)
            return
        end

        -- add by XiaoZhiWei 2017/08/31 20:38:33 加一层判断,如果背包内没有这个物品,则不需要做操作
        if itemCount < 0 then
            local item = player:getItem(itemId)
            if item == nil then
                return
            end
        end

        --处理每日24点消失的物品
        if itemType and itemType == "每日限时" then
            local item = Item:getOneItemByKey(itemId)
            item:setDayItemTimeend()
        end

        player:addItemCount(itemId, itemCount)

        Statistics:recordItemCount(itemId, itemCount) -- 统计

        if printText ~= nil then
            PopText(printText)
        elseif itemCount > 0 then
            PopText("你获得了 " .. Item:getOneItemByKey(itemId).name)
        else
            PopText("你损失了 " .. Item:getOneItemByKey(itemId).name)
        end
    end,
    ["玩家武功等级变化"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        local ret = player:addSkillLv(result.arg2, tonumber(result.arg3))
        if ret == true then
            local Skill = require("app.models.skill.Skill")
            local skill = Skill:getSkill(result.arg2)
            RichPrint(
                "main",
                "武功 【" .. tostring(skill.name) .. "】 等级 " .. Helper:numberToStringWithPlus(tonumber(result.arg3))
            )
            if POISONSYS then
                --@desc 判断是否解锁毒药配方)
                PoisonFormula:unlockPoisonFormulaBySkillLvUp(result.arg2)
            end
        end
    end,
    ["玩家武功经验变化"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(),User:getRole())
        local ret,addExp = player:addSkillExpBySkillId(result.arg2, tonumber(result.arg3))
        if ret == true then
            local Skill = require("app.models.skill.Skill")
            local skill = Skill:getSkill(result.arg2)
            RichPrint(
                "main",
                "武功 【" .. tostring(skill.name) .. "】 经验 " .. Helper:numberToStringWithPlus(tonumber(addExp))
            )
            if POISONSYS then
                --@desc 判断是否解锁毒药配方)
                PoisonFormula:unlockPoisonFormulaBySkillLvUp(result.arg2)
            end
        end
    end,
    ["删除自身"] = function(map, result, environment)
        local roomId = environment.currRoomId
        local currRole = environment.currRole
        map:removeRoomRole(roomId, currRole.id)
    end,
    ["换人"] = function(map, result, environment)
        local fromRoleId = result.arg2
        local toRoleId = result.arg3
        local roomId = result.arg4
        if roomId == nil then
            roomId = environment.currRoomId
        end
        map:swapRoomRole(roomId, fromRoleId, toRoleId)
    end,
    ["添加人物"] = function(map, result, environment)
        local roomId = environment.currRoomId
        local roleId = result.arg2
        map:addRoomRole(roomId, roleId)
    end,
    ["添加人物到随机房间"] = function(map, result, environment)
        local roleId = result.arg2
        local roomIdStrs = string.split(result.arg3, ":")
        local roomId = roomIdStrs[math.random(1, #roomIdStrs)]
        map:addRoomRole(roomId, roleId)
    end,
    -- add by XiaoZhiWei 2017/08/30 16:30:02 添加人物到周围房间
    ["添加人物到周围房间"] = function(map, result, environment)
        local roleId = result.arg2
        local step = Helper:getDef(result.arg3, 0)
        local roomList = map:getNearRoomsExceptmap(map:getCurrRoomId(), step)
        map:addRoomRole(roomList[math.random(1, #roomList)], roleId)
    end,
    ["删除人物"] = function(map, result, environment)
        local roomId = environment.currRoomId
        local roleId = result.arg2
        map:removeRoomRole(roomId, roleId)
    end,
    ["删除指定房间人物"] = function(map, result, environment)
        local roleId = result.arg2
        local roomId = result.arg3
        if roleId == nil or roomId == nil then
            return
        end
        map:removeRoomRole(roomId, roleId, false)
    end,
    ["删除尸体"] = function(map, result, environment)
        local roomId = environment.currRoomId
        local roleList = map:getRoomRoleList(roomId)
        for i = #roleList, 1, -1 do
            if roleList[i] ~= nil and string.find(roleList[i], "尸体") ~= nil then
                print("删除尸体 " .. roleList[i])
                map:removeRoomRole(roomId, roleList[i])
            end
        end
    end,
    ["传送玩家"] = function(map, result, environment)
        local roomId = result.arg2
        map.__MapLayer:teleportRoom(roomId)
    end,
    ["文本输出"] = function(map, result, environment)
        -- local ControllLayer = require("app.views.layer.ControllLayer")
        -- local controllLayer = ControllLayer:getInstance()
        local layer = MainControllLayer:getCurrLayer()
        local currRole = environment.currRole

        local text = result.arg2
        local npc_id_str = result.arg3

        local npc_id_list = {}
        if npc_id_str then
            npc_id_list = string.split(npc_id_str, ";")
        end

        if layer == "JiuChouMapLayer" then
            layer = MainControllLayer:getLayer("JiuChouMapLayer")
            layer:print("CYN" .. result.arg2)
        else
            if text ~= nil then
                if not MapIsEmpty(npc_id_list) then
                    for index, npcId in ipairs(npc_id_list) do
                        local npc = map:getRole(npcId)
                        text = string.gsub(text, "#" .. index .. "#", npc.name)
                    end
                end

                if currRole ~= nil then
                    text = string.gsub(text, "#mz", currRole.name)
                end

                --@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
                local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
                text = HomelandDesc:subChengHuText(text)

                local StringUtil = require("app.extends.StringUtil")
                text = StringUtil:replaceNpcName(text,map)

                local player = Helper:getDef(map:getPlayer(),User:getRole())
                text = StringUtil:replaceDynamicRoleText(text,player)

                RichPrint("main", "CYN" .. text)
            end
        end
    end,
    ["NPC随机文本输出"] = function(map, result, environment)
        local textList = string.split(result.arg2, "#suiji")
        local weightList = string.split(result.arg3, ";")
        local list = {}
        for k, v in pairs(weightList) do
            table.insert(list, k, tonumber(v))
        end
        RichPrint("main", textList[Helper:RandomByWeight(list)])
    end,
    ["地图角色满状态"] = function(map, result, environment)
        local roleId = result.arg2
        local settingRole = map:getRole(roleId)

        print("################################################# 地图角色满状态")

        settingRole:setFlag("是否死亡", nil) -- 满状态的时候 标记去除 add by XiaoZhiWei 2016-12-22

        settingRole:setAttr("qiPercent", 1)
        settingRole:setAttr("qi", settingRole:getCurrQiMax())
        settingRole:setAttr("neili", settingRole:getFinalAttr("neiliMax"))
    end,
    ["策略奖励"] = function(map, result, environment)
        local player = Helper:getDef(map:getPlayer(), User:getRole())
        local currRole = environment.currRole
        --@RefType [src.app.models.Record.Reward.ARewardRecord#ARewardRecord]
        local ARewardRecord = require("app.models.Record.Reward.ARewardRecord")

        local openRewardGet =
            require("app.models.reward.OpenRewardGet"):create(
            player,
            string.split(result.arg2),
            ARewardRecord.RTYPE.MAP_RESULT,
            "mapRewardArrayWithRewardSchemeArray",
            {
                mapid = map.id,
                npcid = currRole.id,
                rlt = "策略奖励"
            }
        )

        openRewardGet:doGetReward(
            function(rewardArray)
                for i, reward in ipairs(rewardArray) do
                    if reward.type == "物品" then
                        if PRINT_MODE == 1 then
                            local item = Item:getOneItemByKey(reward.id)
                            if item then
                                local name = Helper:getDef(Item:getOneItemByKey(reward.id).name, "")
                                local value = Helper:getDef(reward.value, 1)
                                if name then
                                    PopText("[测试才能看见]: 得到物品 [" .. name .. "] x " .. reward.value)
                                end
                            end
                        end
                        if map:addItemCount(reward.id, reward.value) == false then
                            map:dropItem(environment.currRoomId, reward.id, reward.value)
                        else
                            player:addItemCount(reward.id, reward.value)
                            PopText("获得 " .. Item:getOneItemByKey(reward.id).name .. " x " .. reward.value)
                            Statistics:recordItemCount(reward.id, reward.value) -- 用于统计
                        end
                    elseif reward.type == "属性" then
                        if type(player:getCHAttrName(reward.id)) == "string" then
                            PopText("获得" .. player:getCHAttrName(reward.id) .. tostring(reward.value))
                        end
                        player:addAttr(reward.id, reward.value)
                        map:richPrintText(player, reward.id, reward.value) -- 角色属性变化文本显示
                    end
                end
            end
        )
    end,
    ["随机传送玩家"] = function(map, result, environment)
        -- 传送玩家 --
        local roomsListStr = result.arg2

        roomsListStr = string.split(roomsListStr, ";")

        local randid = math.random(1, #roomsListStr)
        local randRoomId = roomsListStr[randid]

        if randRoomId == nil or randRoomId == "" then
            assert("传送到一个不存在的房间 roomsListStr = " .. tostring(roomsListStr))
            return
        end

        print("随机传送玩家 randRoomId=" .. randRoomId)
        environment.mapLayer:teleportRoom(randRoomId)
    end,
    ["随机传送玩家不重复"] = function(map, result, environment)
        -- 传送玩家 --
        local roomsListStr = result.arg2 --待传送的房间列表
        local lastRoomId = result.arg3 --最后一个房间

        print("随机传送玩家不重复 role=" .. environment.currRole.id .. " roomsListStr=" .. roomsListStr .. " ")
        if lastRoomId then
            print("lastRoomId=" .. lastRoomId)
        end

        if roomsListStr == nil or roomsListStr == "" then
            return
        end

        if map.gRandomRooms == nil then
            map.gRandomRooms = {}
        end

        --是否存在
        if map.gRandomRooms[result.id] == nil then
            --第一次运行，把房间解析出来放入列表
            local roomsListStr = string.split(roomsListStr, ";")

            print("随机传送玩家不重复 " .. #roomsListStr)

            map.gRandomRooms[result.id] = {}

            for i, room_str in ipairs(roomsListStr) do
                table.insert(map.gRandomRooms[result.id], room_str)
            end
        end

        print("随机传送玩家不重复 result.id=" .. result.id .. " count=" .. #map.gRandomRooms[result.id])

        if #map.gRandomRooms[result.id] > 0 then
            local randid = math.random(1, #map.gRandomRooms[result.id])
            local rand_roomid = map.gRandomRooms[result.id][randid]

            table.remove(map.gRandomRooms[result.id], randid)

            print("随机传送玩家不重复 随机到房间 " .. rand_roomid .. " 还有 " .. #map.gRandomRooms[result.id] .. " 个")

            environment.mapLayer:teleportRoom(rand_roomid)
        else
            print("随机传送玩家不重复 已经没了 lastRoom=" .. type(lastRoomId))

            if lastRoomId ~= nil and lastRoomId ~= "" then
                environment.mapLayer:teleportRoom(lastRoomId)
            end
        end
    end,
    ["重置随机房间记录"] = function(map, result, environment)
        -- 配合结果 "随机传送玩家不重复" 使用 情况不重复的记录达到刷新的效果 add by XiaoZhiWei 2016-12-21
        map.gRandomRooms = nil
        print("重置随机房间记录")
    end,
    ["弹出文本窗口"] = function(map, result, environment)
        local title = result.arg2
        local str = string.split(result.arg3, ";")
        local textSize = tonumber(result.arg4)

        PopupLayerController:showLayer(
            "TextPopLayer",
            function(layer)
                layer:showLayer(title, str, textSize)
            end
        )
    end,
    ["获得碎银"] = function(map, result, environment)
        local role = Helper:getDef(map:getPlayer(),User:getRole())
        local money = role:getMoneyFromExp()

        PopText("碎银 + " .. tostring(money))
        role:addAttr("money", money)
        map:richPrintText(role, "money", money)
    end,
    ["自定义背景音乐"] = function(map, result, environment)
        -- Audio:stopMusic()
        local bgm, vol, isLoop = result.arg2, Helper:getDef(result.arg3, 1), Helper:getDef(result.arg4, 0)
        Audio:setMusicVolume(vol)
        map._currMusicBGM = bgm
        if isLoop == 1 then
            map.__MapLayer._currEffectId = Audio:playMusic(bgm, true)
        else
            map.__MapLayer._currEffectId = Audio:playMusic(bgm, false)
        end
    end,
    ["自定义副本音乐"] = function(map, result, environment)
        -- Audio:stopMusic()
        local bgm, vol, isLoop = result.arg2, Helper:getDef(result.arg3, 1)
        Helper:getDef(result.arg4, 1)
        Audio:setMusicVolume(vol)
        map._currMusicBGM = bgm
        if isLoop == 1 then
            map.__MapLayer._currEffectId = Audio:playMusic(bgm, true)
        else
            map.__MapLayer._currEffectId = Audio:playMusic(bgm, false)
        end
        if map.defaultBGM == nil then
            map.defaultBGM = Helper:getDef(map.BGM, "")
        end
        map.BGM = bgm
    end,
    ["离开副本"] = function(map, result, environment)
        map.__MapLayer.TotalMapBtn_IsInit = false
        map.__MapLayer:quit()
    end,
    ["恢复默认副本音乐"] = function(map, result, environment)
        map.BGM = map.defaultBGM
        map._currMusicBGM = map.BGM
        if map.BGM == "" then
            Audio:stopMusic()
            return
        end
        map.__MapLayer._currEffectId = Audio:playMusic(map.BGM, true)
    end,
    ["暂停播放音乐"] = function(map, result, environment)
        Audio:stopMusic()
        map.__MapLayer:playMapMusic()
    end,
    ["批量替换房间背景音乐"] = function(map, result, environment)
        local roomIds = result.arg2
        local bgm, vol, isLoop = result.arg3, result.arg4, result.arg5
        if roomIds == nil then
            return
        end
        local roomList = string.split(roomIds, ";")
        if MapIsEmpty(roomList) == true then
            return
        end
        for k, roomId in pairs(roomList) do
            map:replaceRoomBGM(roomId, bgm, vol, isLoop)
        end
    end,
    ["播放默认背景音乐"] = function(map, result, environment)
        local roomIds = Helper:getDef(result.arg2, "")
        local roomList = string.split(roomIds, ";")
        if MapIsEmpty(roomList) == true then
            return
        end
        for i, roomId in ipairs(roomList) do
            map:replayLastRoomBgm(roomId)
        end
    end,
    ["播放上一个背景音乐"] = function(map, result, environment)
        local roomIds = Helper:getDef(result.arg2, "")
        local roomList = string.split(roomIds, ";")
        if MapIsEmpty(roomList) == true then
            return
        end
        for i, roomId in ipairs(roomList) do
            map:replayLastRoomBgm(roomId)
        end
    end,

	["获得称号"] = function(map, result, environment)
		--result.arg2  称号id
        local titleId = tostring(result.arg2)
        local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")
        local title = RoleTitleResManager:getBasicTitleClassById(titleId)
        local player = Helper:getDef(map:getPlayer(),User:getRole())

        if player:hasBasicTitle(titleId) == false then
            player:addBasicTitle(titleId)
            PopText("获得"..title:getColorName() .."称号")
        end
	end,
	["副本离开"] = function(map, result, environment)
		print("--------------------")
		PopupLayerController:showLayer("TongGuanPopLayer", function(layer)
			layer:maxZ()
			layer:show(Helper:getDef(map:getPlayer(),User:getRole()), map.__MapLayer:getDefaultRoom(), "离开")
			-- layer.Panel_selectMapDetailItemUI.Text_stateDsc:setString("进行中")
			layer:setTitle("离开副本")
			layer:setQuitFunc("离开" ,
				function()
					map.__MapLayer:quit()
				end)
			layer:setButton2("取消")
		end)
	end,
	["进入平安小镇"] = function(map, result, environment)
		--@RefType [src.app.models.map.PingAnTown#PingAnTown]
        local PingAnTown = require("app.models.map.PingAnTown")
        local mapId = "fb205"
        HttpManagerEx:getConfigFuben(
            mapId,
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        if data.status == 1 then
                            PingAnTown:entryTown(map.__MapLayer)
                        else
                            PopText("此章节暂未开放，敬请期待")
                        end
                    else
                        PopText(errmsg)
                    end
                end
            end,
            IS_SHOW_WAITING
        )
    end,
    ["随机人物投放"] = function(map, result, environment)
		local npcList = string.split(result.arg2, ";")
		
		local roomsList = string.split(result.arg3, ";")
		
		--打乱顺序表
		local function shuffle(t)
			if type(t) ~= "table" then
				return
			end
			local l = #t
			local tab = {}
			local index = 1
			while #t ~= 0 do
				local n = math.random(0, #t)
				if t[n] ~= nil then
					tab[index] = t[n]
					table.remove(t, n)
					index = index + 1
				end
			end
			return tab
		end
		
		local addNpcToRoom = function(npcStr)
			local npcArr = string.split(npcStr, ",")
			
			local index = math.random(1, #roomsList)
			print("随机房间的索引为 ：" .. index)
			
			local roomId = roomsList[index]
			
			npcArr = shuffle(npcArr)
			for i = 1, #npcArr do
				map:addRoomRole(roomId, npcArr[i], false)
			end
			table.remove(roomsList, index)
			
			print("添加了角色后的房间列表")
			-- Helper:print_lua_table(roomsList)
		end
		
		
		for i = 1, #npcList do
			addNpcToRoom(npcList[i])
		end
    end,
    ["增加货币"] = function(map, result, environment)
		local doType = Helper:getDef(result.arg2,"remove")
		local name = Helper:getDef(result.arg3,"gongxiandian")
		local count = Helper:getDef(result.arg4,0)
		local list = {
			["mingbi"] = "冥币",
			["gongxiandian"] = "贡献点",
			["yuanbao"] = "元宝",
			["zjjifen"] = "功绩",
            ["yinpiao"] = "银票",
            ["meiyu"] = "江湖美誉",
            ["zongheng"] = "雪矾",
		}

		local addType = result.arg5
        
		if name == "yinpiao" and addType == nil then
			addType = "openHomeland"
		end

		HttpManagerEx:updateCurrencyByType(doType,name,count,addType, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if name == "zjjifen" then
						if Helper:getDef(data.zjjifen, 0) == 0 then
							PopText("您今日所得功绩已达上限")
						else
							PopText(list[name].."+"..tostring(data.zjjifen))
						end
					else
						if list[name] ~= nil then
							PopText(list[name].."+"..tostring(count))
						end
					end
				else
					PopText(errmsg)
				end
			end
		end, IS_SHOW_WAITING)
    end,

	["增加周年庆积分"] = function(map, result, environment)
        local num = result.arg2
        local addType=result.arg3
        local tab = {
            shop_id = "zhounianqin_jf",
            number = num,
            type = addType
        }
        HttpManagerEx:addCurrency(tab,function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if data.number > 0 then
                        PopText("新春礼券+"..tostring(data.number))
                    end
                else
                    PopText(errmsg)
                end
            end
        end, IS_SHOW_WAITING)
    end,
    
	["修改房间可进"] = function(map, result, environment)
        local roomId = result.arg2
        local enterable = tonumber(result.arg3)

        if enterable == nil then
            assert(false,"arg3 填写错误")
        end

        local roomAttr = map:getRoomAttr(roomId)
        if roomAttr == nil then
            return
        end

        roomAttr.enterable = enterable
	end,
	["修改房间可离开"] = function(map, result, environment)
        local roomId = result.arg2
        local canLeave = tonumber(result.arg3)

        if canLeave == nil then
            assert(false,"arg3 填写错误")
        end

        local roomAttr = map:getRoomAttr(roomId)
        if roomAttr == nil then
            return
        end

        roomAttr.canLeave = canLeave
	end,
	["修改房间可见"] = function(map, result, environment)
        local roomId = result.arg2
        local visible = tonumber(result.arg3)

        if visible == nil then
            assert(false,"arg3 填写错误")
        end

        local roomAttr = map:getRoomAttr(roomId)
        if roomAttr == nil then
            return
        end

        roomAttr.visible = visible
    end,

    ["修改当前房间可离开属性"] = function(map, result, environment)
        local canLeave = tonumber(result.arg2)
        if canLeave == nil then
            assert(false,"arg2 填写错误")
        end
        local roomId = environment.currRoomId
        local roomAttr = map:getRoomAttr(roomId)
        if roomAttr == nil then
            return
        end
        roomAttr.canLeave = canLeave

    end,

     ["修改当前房间可进入属性"] = function(map, result, environment)
        local enterable = tonumber(result.arg2)
        if enterable == nil then
            assert(false,"arg2 填写错误")
        end
        local roomId = environment.currRoomId
        local roomAttr = map:getRoomAttr(roomId)
        if roomAttr == nil then
            return
        end
        roomAttr.enterable = enterable
    end,

     ["修改当前房间可见属性"] = function(map, result, environment)
        local visible = tonumber(result.arg2)
        if visible == nil then
            assert(false,"arg2 填写错误")
        end
        local roomId = environment.currRoomId
        local roomAttr = map:getRoomAttr(roomId)
        if roomAttr == nil then
            return
        end
        roomAttr.visible = visible
    end,


    ["副本故事"] = function(map, result, environment)
		local textList = string.split(result.arg2, ";")
		local timeList = string.split(result.arg3, ";")

		local npc_id_str = result.arg4

		local npc_id_list = {}
		if npc_id_str then
			npc_id_list = string.split(npc_id_str,";")
		end
		
		local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
		local CustomLayer = require("app.views.layer.PopLayer.PopLayer")
		CustomLayer:getInstance():show()
		CustomLayer:getInstance().Panel_back:setVisible(false)
		
		local delay = 0
		for i, v in ipairs(textList) do
			environment.mapLayer:delayFunc(delay, function()
				--@desc 字符串替换成NPC名字
				if not MapIsEmpty(npc_id_list) then
					for index,npcId in ipairs(npc_id_list) do
						local npc = map:getRole(npcId)
						v = string.gsub(v, "#"..index.."#", npc.name)
					end
				end
                v = HomelandDesc:subChengHuText(v)

                local StringUtil = require("app.extends.StringUtil")
                v = StringUtil:replaceNpcName(v,map)

				RichPrint("main", v)
			end)
			if timeList[i] then
				delay = timeList[i] + delay
			end
		end
		
		environment.mapLayer:delayFunc(delay, function()
			CustomLayer:getInstance():hide(function()
				CustomLayer:getInstance():removeFromParent(true)
			end)
		end)
    end,
	
	["添加副本追随者"] = function(map, result, environment)
		local npcIds = result.arg2
		if npcIds == nil then
		else
			local currNpcList = map:getFollowInfoByKey("npcList")
			local npcList = string.split(npcIds, ",")
			if MapIsEmpty(currNpcList) == true then
			else
				for i, v in ipairs(currNpcList) do
					table.insert(npcList, math.random(1, #npcList), v)
				end
			end
			map:updateFollowInfo("npcList", npcList)
			-- Helper:print_lua_table(npcList)
			map:refreshFollowRoles(environment.currRoomId)
		end
    end,
    ["移除副本追随者"] = function(map, result, environment)
		local npcIds = result.arg2
		local currNpcList = map:getFollowInfoByKey("npcList")
		local _currNpcList = clone(currNpcList)
		if npcIds ~= nil then
			local npcList = string.split(npcIds, ",")
			local list = {}
			if MapIsEmpty(currNpcList) == true then
			else
				for j, npcId in pairs(npcList) do
					for i, v in pairs(_currNpcList) do
						if npcId == v then
							table.remove(_currNpcList, i)
							break
						end
					end
				end
			end
			map:updateFollowInfo("npcList", _currNpcList)
			-- Helper:print_lua_table(_currNpcList)
			map:refreshFollowRoles(environment.currRoomId)
		end
    end,
    ["邀请函前往"] = function(map, result, environment)
        if JIAYUAN_SYSTEM_IS_OPEN == false then
            PopText("该功能暂时未开放")
            return
        end
    
        --@desc [src.app.models.role.Role#Role]
        local role = Helper:getDef(map:getPlayer(),User:getRole())
        local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")
        if HomelandUtil:sysIsOpen() == false then
            return
        end

        local role = Helper:getDef(map:getPlayer(),User:getRole())
        PopupLayerController:showLayer("CheFuLayer",function (layer)
            layer:show()
            layer:setRoles(role)
        end)
    end,
    ["副本无动画跳转"] = function(map, result, environment)
		local role = Helper:getDef(map:getPlayer(),User:getRole())
		local fbId = result.arg2 -- 副本ID
		local roomId = result.arg3 -- 房间ID
		local text = result.arg4 -- 输出文本
		
		
        local isRefresh = false
		
        --@desc 如果为1强制刷新，不然遵循5分钟刷新规则。
        if result.arg5 == 1 then
            isRefresh = true
        end
		
		--控制是否输出跳转后房间的进入文本,默认为输出
		local isShowText = true 
		if result.arg6 == 1 then
			isShowText = false
		end
		
        local maplayer = map.__MapLayer
        
        --@RefType [src.app.models.role.Role#Role]
        local role = Helper:getDef(map:getPlayer(),User:getRole())
        
        local toMap = role:getMapById(fbId)

        local function toNewMap(toMap)
            toMap:setCallBackAndConnect(
                function()
                    maplayer:setMap(toMap)

                    if toMap._isComingIn ~= true then
                        toMap:refreshBranchEvent()
                    end
                    
                    map._isComingIn = true

                    maplayer:replaceRoom(roomId,"center",isShowText)

                    toMap:setCurrRoomId(roomId)
                    
                    toMap:doRoomOperation("进入房间",roomId)

                    maplayer:delayRefreshMap()

                    if text then
                        RichPrint("main", text)
                    end
                end
            )
        end

        local function toOldMap(toMap)
            if isRefresh == true then
                toMap = role:initMapById(fbId)
            else
                local lastTime = role:getFlag(fbId)
                if lastTime == 0 and toMap._isComingIn == nil then
                    print("副本跳转 第一次进入副本 初始化 " .. toMap.id)
                    toMap = role:initMapById(fbId)
                elseif (lastTime ~= 0 and GetTime() - lastTime >= MAP_REFRESH_INTERVAL) or toMap._isComingIn == nil then
                    print("副本跳转 超过副本时间 或者游戏重新启动 初始化 " .. toMap.id)
                    toMap = role:initMapById(fbId)
                else
                    print("副本跳转 直接进入")
                end
            end

            if fbId == "fb220" then
                local RoleFactory = require("app.models.role.factory.RoleFactory")
				local cloneRole = RoleFactory:createSelfCreatedSkillTaskRole()
				toMap:setPlayer(cloneRole)
			end

            toMap:setCallBackAndConnect(
                function()
                    maplayer:setMap(toMap)
                    maplayer:replaceRoom(roomId,"center",isShowText)
                    toMap:setCurrRoomId(roomId)
                    maplayer:delayRefreshMap()
                    MessageCenter:notify("EnterMap",{map = toMap})
                    --@desc 跳转后执行房间的条件结果
                    local results =
                        toMap:doRoomConditionAndResult(
                        roomId,
                        {
                            operation = "进入房间",
                            roomId = roomId,
                            currRoomId = nil,
                            mapLayer = maplayer,
                            currRole = nil
                        }
                    )
                    if text then
                        RichPrint("main", text)
                    end
                end
            )
        end

        if Map:getMapVersionByMapId(toMap.id) == EDITOR_MAP_VERSION then
            toNewMap(toMap)
        else
            if fbId == "fb220" and role:getSelfCreatedSkillSystem():isOpenSystem() == true then
                local SelfCreatedSkillTaskModel = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillTask.SelfCreatedSkillTaskModel")
                --@desc 临时处理，需整理副本进入流程
                SelfCreatedSkillTaskModel:resetTask(
                    function(errcode, taskInfo)
                        if errcode == 0 or errcode == 2 then
                            toOldMap(toMap)
                        elseif errcode == 1 then
                            PopText("地宫古迹任务未接取，请先接取该任务。")
                        elseif errcode == 3 then
                            PopText("地宫任务本周已完成，请下周再来。")
                        end
                    end
                )
            else
                toOldMap(toMap)
            end
        end

    end,
    
    ["解锁点记录"] = function(map, result, environment)
        local recordId = result.arg2
        local record = AchievementSystem:getRecordById(recordId)
        AchievementSystem:add(record)
    end,

    ["副本完成"] = function(map, result, environment)
        if User:getRole():isMapCompleted(map.id) then
            return
        end
        
        User:getRole():setMapCompleted(map.id)
    end,
}

BaseResults.doResult["玩家状态标识设置"] = function(map, result, environment)
    assert(result.arg2 , "arg2 不能为空")
    assert(tonumber(result.arg3) , "arg3 不能为空")
    
    local player = Helper:getDef(map:getPlayer(),User:getRole())
    player:setRoleStatusTags(result.arg2, tonumber(result.arg3))
end

BaseResults.doResult["玩家传承状态标识设置"] = function(map, result, environment)
    assert(result.arg2 , "arg2 不能为空")
    assert(tonumber(result.arg3) , "arg3 不能为空")
    
    local player = Helper:getDef(map:getPlayer(),User:getRole())
    player:setInheritRoleStatusTags(result.arg2, tonumber(result.arg3))
end

BaseResults.doResult["玩家传承时间状态标识设置"] = function(map, result, environment)
    assert(result.arg2 , "arg2 不能为空")
    assert(tonumber(result.arg3) , "arg3 不能为空")
    
    local player = Helper:getDef(map:getPlayer(),User:getRole())
    player:setInheritTimeStatusTags(result.arg2, tonumber(result.arg3))
end

BaseResults.doResult["玩家时间状态标识设置"] = function(map, result, environment)
    assert(result.arg2 , "arg2 不能为空")
    assert(tonumber(result.arg3) , "arg3 不能为空")
    
    local player = Helper:getDef(map:getPlayer(),User:getRole())
    player:setTimeStatusTags(result.arg2, tonumber(result.arg3))
end

BaseResults.doResult["NPC状态标识设置"] = function(map, result, environment)
    assert(result.arg2 , "arg2 不能为空")
    assert(tonumber(result.arg3) , "arg3 不能为空")
    
    local npc = environment.currRole
    npc:setNpcStatusTags(result.arg2, tonumber(result.arg3))
end

BaseResults.doResult["副本状态标识设置"] = function(map, result, environment)
    assert(result.arg2 , "arg2 不能为空")
    assert(tonumber(result.arg3) , "arg3 不能为空")
    
    map:setMapStatusTags(result.arg2, tonumber(result.arg3))
end

return BaseResults
0000000000000