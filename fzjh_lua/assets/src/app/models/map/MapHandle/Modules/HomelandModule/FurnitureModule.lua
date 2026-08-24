--@desc 家具相关操作

--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local FurnitureModule = class("FurnitureModule", require("app.models.map.MapHandle.Modules.BaseModule"))

local Skill = require("app.models.skill.Skill")

--@RefType [src.app.models.HomelandModel.FurnitureModel.FurnitureModel#FurnitureModel]
local FurnitureModel = require("app.models.HomelandModel.FurnitureModel.FurnitureModel")

local RoleTaskControllor = require("app.views.layer.RoleLayer.RoleTaskControllor")

local PoisonUtil = require("app.models.Poison.PoisonUtil")

--@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")

--@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")

local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")

--@desc 条件结果的方法
FurnitureModule.doResult = {
    ["休息"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        local furnitrure = environment.currRole
        local bedId = furnitrure.jjId
        local bedValue = furnitrure.value
        --判断是否有香炉
        local xiangLus = HomelandRoomUtil:getCurrRoomFurnitureByType(map,25)
        local XiangLuModel = require("app.models.HomelandModel.XiangLuModel")
        local currXiangLu,currXiangLuId,currXiangId
        if MapIsEmpty(xiangLus) == false then
            currXiangLu = xiangLus[1]
            currXiangLuId = currXiangLu.jjId
            if XiangLuModel:checkFireXiangIsNormal(XiangLuModel:getFireXiangType(currXiangLu)) then
                currXiangId = currXiangLu.extra.xiangId
            end

            if #xiangLus >1 then --香炉设定一个房间只能摆一个
                print("香炉设定一个房间只能摆一个")
            end
        end
        XiangLuModel:bedRestFun(bedValue,currXiangLuId,currXiangId)
    end,
    ["家具收起"] = function(map, result, environment)
        local furnitrure = environment.currRole
        FurnitureModel:pickUp(furnitrure, map)
    end,
    ["发送邀请函"] = function(map, result, environment)
        -- map:getRole(environment.currRole.id)
        print("----------------------------------")
        if HomelandRoleUtil:currMapHaveGj(map) == false then
            PopText("这种迎来送往的事情，还是找个管家来办理吧！")
            return
        end
        ConfirmLayer:createCustomInRunningScene(
            "你要给谁发送邀请函?",
            "确定",
            function(conFirmLayer)
                local editBoxString = conFirmLayer:getEditBoxString()
                local YaoQingHanModel = require("app.models.HomelandModel.YaoQingHanModel")
                YaoQingHanModel:sendYaoQingHan(editBoxString)
            end,
            "取消",
            function()
            end
        )
    end,
    ["储物箱"] = function(map, result, environment)
        local currRoom = map:getRoomById(map:getCurrRoomId())
        PopupLayerController:showLayer(
            "ChuWuGuiLayer",
            function(layer)
                layer:showLayer(currRoom, map)
            end
        )
    end,
    ["副本调息"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()
        if (role:getLv() < 350 and role:getFlag("开启经脉系统") == 0) then
            RichPrint("main", "经脉系统未开启，无法使用。")
            return
        end

        local item = environment.currRole

        local itemId = item.jjId

        local itemAttr = Item:getOneItemByKey(itemId)

        local valueStr = itemAttr.value

        local values = string.split(valueStr, ";")

        role:setFlag("经脉加成", 1 + tonumber(values[1]) * 1.25)
        
        role:setFlag("真气加成", 1 + tonumber(values[1]))
        
        RoleTaskControllor:clickTiaoXiLayer(
            function()
                role:pranayama()

                do  --限时历练
                    local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience")
            
                    if LimitedTimeExperience:checkTaskIsOpen("tiaoxi") then
                        LimitedTimeExperience:setRole(role)
                        LimitedTimeExperience:finishTaskByTaskType("tiaoxi")
                    end
                end

                do --每日任务
                    local DailyTasksActivity = require("app.models.Action.DailyTasksActivity")
                    DailyTasksActivity:addDailyTaskPoint("tiaoxi")
                end

                local HomelandUtil = require("app.models.HomelandModel.HomelandUtil")

                if HomelandUtil:isRoomByTypeFromFlag("tsfangjian015") then
                    RichPrint("main","你走入调息室，松弛筋骨、坐了下来，静气凝神，呼吸变得悠长，开始进行调息……")
                else
                    self:print("HIC你静气凝神，呼吸变得悠长，开始进行调息……")
                end

                local text = HomelandDesc:getPranaymaDesc()
                local i = 1
                map:setSchedule(
                    function(tag)
                        if not role:isInCurrState(ROLE_CURR_STATE_TIAOXI) then
                            map:unSchedule(tag)
                            return
                        end
                        RichPrint("main", text[i])

                        i = i + 1

                        if i > #text then
                            i = 1
                        end
                    end,
                    2
                )
            end
        )
    end,
    ["副本香炉"] = function(map, result, environment)
        if (User:getRole():getLv() < 350 and User:getRole():getFlag("开启经脉系统") == 0) then 
            RichPrint("main", "经脉系统未开启，无法使用。")
        else
            PopupLayerController:showLayer(
                "MerdianAromaBurnerLayer",
                function(layer)
                    layer:showLayer()
                end
            )
         end
    end,
    ["查看悬兵洞"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()

        if map:getMapType() == MAP_TYPE.MYHOME then
            if role:getInheritFlag("可进入苏州水底") == 1 and role:getInheritFlag("开始神兵任务") >= 2 then
            else
                PopText("神兵系统未开启，无法使用该功能。")
                return
            end

            HttpManagerEx:getClientData({type = "xuanbingdong"},function(status, errcode, errmsg, data)
                -- print("------------------------------getClientData-----------------------------")
                -- Helper:print_lua_table(data)
                if status == 200 then
                    if errcode == 0 then
                        if MapIsEmpty(data) == false then
                            if data.flag == 1 then
                                print("查看自己的悬兵洞")
                                local HomeLandDesc = require("app.models.HomelandModel.HomelandDesc")
                                local text = HomeLandDesc:getCangJianShiDesc(ShenBingDesc:getCollectScore(role:getAttr("collectScore")))
                                MainControllLayer:pushLayer("XuanBingDong")
                                local XuanBingDong = MainControllLayer:getLayer("XuanBingDong")
                                XuanBingDong:setInRoom(true)
                                XuanBingDong:show()
                            else
                                PopText("网络连接异常，请重试。")
                            end
                        end
                    else
                        PopText(errmsg)
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            end, IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)

            return
        end

        local userId = map.userid

        local room = map:getRoomById(environment.currRoomId)

        local collectScore = 1

        if map.extra and map.extra.collectScore then
            collectScore = map.extra.collectScore
        end

        HttpManagerEx:getCkItemsListByUid(
            map.uid,
            "xuanbingdong",
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        MainControllLayer:pushLayer("UserEquipItemLayer")
                        local XuanBingDong = MainControllLayer:getLayer("UserEquipItemLayer")
                        XuanBingDong:showLayer(data.list, collectScore)
                    else
                        PopText(errmsg)
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            end,
            IS_SHOW_WAITING,
            HTTP_MANAGER_RETRY_TYPE_RETRY
        )
    end,
    ["查看藏衣阁"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()
        if map:getMapType() == MAP_TYPE.MYHOME then
            if role:getInheritFlag("可进入苏州水底") == 1 and role:getInheritFlag("开始神兵任务") >= 2 then
            else
                PopText("神兵系统未开启，无法使用该功能。")
                return
            end

            HttpManagerEx:getClientData({type = "cangyige"},function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        if MapIsEmpty(data) == false then
                            if data.flag == 1 then
                                local HomeLandDesc = require("app.models.HomelandModel.HomelandDesc")
                                local text = HomeLandDesc:getCangYiShiDesc(ShenBingDesc:getCollectScore(role:getAttr("collectScore")))
                                MainControllLayer:pushLayer("CangYiGe")
                                local CangYiGe = MainControllLayer:getLayer("CangYiGe")
                                CangYiGe:show(true, text)
                            else
                                PopText("网络连接异常，请重试。")
                            end
                        end
                    else
                        PopText(errmsg)
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            end, IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)
            return
        end

        if not map.mid or map.mid == "" then
            return
        end

        local userId = map.uid
        local roomId = map:getCurrRoomId()
        local room = map:getRoomById(roomId)
        local yiGui = nil
        local roleList = room.roleList
        for k, v in pairs(roleList) do
            local role = map:getRole(v)
            if role.iType == "衣柜" then
                yiGui = role
                break
            end
        end

        local collectScore = Helper:getDef(map.extra.collectScore, 1)
        if map.extra and map.extra.collectScore then
            collectScore = map.extra.collectScore
        end

        HttpManagerEx:getCkItemsListByUid(
            userId,
            "cangyige",
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        MainControllLayer:pushLayer("UserArmorItemLayer")
                        local CangYiGe = MainControllLayer:getLayer("UserArmorItemLayer")
                        CangYiGe:showLayer(data.list, collectScore)
                    else
                        PopText(errmsg)
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            end,
            IS_SHOW_WAITING,
            HTTP_MANAGER_RETRY_TYPE_RETRY
        )
    end,
    ["家具使用"] = function(map, result, environment)
        local furnitureId = environment.currRole.jjId

        local furnitrue = Item:getOneItemByKey(furnitureId)

        if not furnitrue then
            if DEBUG_MODE == 1 then
                assert(false, "没有该家具：" .. furnitureId)
            end
            return
        end

        RichPrint("main", furnitrue.usedsc)
    end,
    ["副本闭关"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()

        local skillId = Helper:getDef(role:getPrepareSkill("neigong"), "jibenneigong")

        local roleSkill = role:getSkill(skillId)

        if MapIsEmpty(roleSkill) then
            PopText("您还没学会任何内功。")
            return
        end

        local currRole = environment.currRole

        local BiGuanModel = require("app.models.BiGuan.BiGuanModel")
        --@RefType [src.app.models.BiGuan.BiGuanModel#BiGuanModel]
        local biGuan = BiGuanModel:create(skillId)
        local itemAttr = Item:getOneItemByKey(currRole.jjId)
        local valueStr = itemAttr.value
        local values = string.split(valueStr, ";")
        biGuan:setReduceCostFactor(Helper:getDef(tonumber(values[2]),0))
        biGuan:print()

        if biGuan:checkCanBiGuan() == false then
            return
        end

        PopupLayerController:showLayer("BiGuanLayer",function (layer)
            layer:showLayer(biGuan)
        end)
    end,
    ["吃饭"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()
        local furniture = environment.currRole

        local dinnerResult = FurnitureModel:dinner(function ()
            furniture.canUse1 = 1
            furniture.canUse2 = 0
            furniture.canUse3 = 0
        end)

        local text = HomelandDesc:getEatDesc(dinnerResult.rate)
        PopupLayerController:showLayer(
            "GlobalShadeLayer",
            function(layer)
                layer:showLayer()
                layer:setPopText("你正在干别的事情。")
            end
        )
        local TIME = 2
        for i = 1, #text do
            map.__MapLayer:delayFunc(
                0 + (i - 1) * TIME,
                function()
                    RichPrint("main", text[i])
                    if i == #text then
                        if dinnerResult.name ~= nil and dinnerResult.value ~= nil then
                            RichPrint("main", dinnerResult.name .. " ：" .. dinnerResult.value)
                        end
                        PopupLayerController:hideLayer(
                            "GlobalShadeLayer",
                            function(layer)
                                layer:hideLayer()
                            end
                        )
                    end
                end
            )
        end
    end,
    ["装盒"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()
        local currRole = environment.currRole
        local zcLv = 0
        local roleList = map:getRoomRoleList(map:getCurrRoomId())

        local npc
        for i, v in ipairs(roleList) do
            local roleData = map:getRole(v)
            if roleData.jobType == "chuzi001" then
                --@RefType [src.app.models.role.Role#Role]
                npc = roleData
                zcLv = HomelandRoleUtil:getFidelityLv(roleData.defaultZhongCheng)
                break
            end
        end

        
        local dinner = role:getHomelandAttr("dinner")
        
        if not dinner then
            assert(false, "没有dinner 数据，不应该有这条件结果调用，请检查。")
        end
        
        local traitCount = 0

        if npc ~= nil then
            --@desc 特性增加打包数量
            traitCount = traitCount + npc:getBuffAttr("dabaoNumAdd")
        end
        local count = dinner.times + traitCount

        dinner.times = count
        role:setHomelandAttr("dinner",dinner)

        --@desc 判断背包是否已满
        if not role:checkCanBuyTwoOrMoreThings({["jian111"] = count}) then
            return
        end

        local traitTimeFactor = 1 + Helper:getDef(npc:getBuffAttr("shiheTimeSub"),0)

        for i = 1, count do
            local id = "shihe_" .. Helper:getOnlyId()
            local time = GetTime() + (3600 * 2 * traitTimeFactor)

            role:addItemCount(id, 1, time)
        end

        dinner.status = 2

        PopText("获得道具食盒 X" .. count)
        currRole.canUse1 = 1
        currRole.canUse2 = 0
        currRole.canUse3 = 0
    end,
    ["查看藏书"] = function(map, result, environment)
        PopupLayerController:showLayer(
            "BookLiteraryLayer",
            function(layer)
                layer:showLayer(true)
            end
        )
    end,
    ["查看秘籍"] = function(map, result, environment)
        PopupLayerController:showLayer(
            "BookCaseLayer",
            function(layer)
                layer:showLayer(true)
            end
        )
    end,
    ["品书"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()

        if role:getTimeLimitFlag("品书") ~= 0 then
            local time = math.floor(role:getTimeLimitFlagTime("品书"))
            local hour = math.floor(time / 3600)
            local min = math.floor((time - hour * 3600) / 60)
            local sec = math.floor(time - hour * 3600 - min * 60)
            RichPrint(
                "main",
                "看书虽好，但也不宜多哦，还是休息一会吧，过" ..
                    tostring(hour) .. "小时" .. tostring(min) .. "分钟" .. tostring(sec) .. "秒后再来也不迟。"
            )
            return
        end

        local roleList = map:getRoles()
        local guanjialv = 0
        for i, v in pairs(roleList) do
            if i == "guanjia1001" then
                local guanjiaData = map:getRole("guanjia1001")
                guanjialv = HomelandRoleUtil:getFidelityLv(guanjiaData.defaultZhongCheng)
            end
        end

        local text = HomelandDesc:getReadBookByTeaDesc()
        local currLv = role:getSkillLv("dushushizi")
        local totalInt = role:getFinalAttr("currInt")
        local lastText = ""
        if currLv >= role:getSkillLvLimit("dushushizi") then
            local addPot = math.floor((totalInt / 2) ^ 2 + (guanjialv + 1) * 2000)
            role:addAttr("pot", addPot)
            lastText = "潜能 +" .. addPot
        else
            local addExp = 0
            local upLv = 0
            local MAX_ROLE_SKILL_EXP = role:conversionSkillExpAndLv("exp", role:getSkillLvLimit("dushushizi"))
            local nowExp = role:getSkillExp("dushushizi")

            addExp = currLv*2+100*(totalInt / 2 + guanjialv * 50)
            if addExp + nowExp > MAX_ROLE_SKILL_EXP then
                addExp = MAX_ROLE_SKILL_EXP - nowExp
            end

            local newLv = role:conversionSkillExpAndLv("lv", nowExp + addExp)
            role.skills["dushushizi"] = {id = "dushushizi", exp = nowExp + addExp}
            if newLv - currLv > 0 then
                upLv = newLv - currLv
            end

            lastText = "【读书识字】经验 +" .. addExp

            if upLv > 0 then
                lastText = lastText .. "\n" .. "【读书识字】等级 +" .. upLv
            end
        end

        role:setTimeLimitFlag("品书", 1, 3600 * 48)
        PopupLayerController:showLayer(
            "GlobalShadeLayer",
            function(layer)
                layer:showLayer()
                layer:setPopText("品书中。")
            end
        )

        local TIME = 2
        for i = 1, #text do
            map.__MapLayer:delayFunc(
                0 + (i - 1) * TIME,
                function()
                    RichPrint("main", text[i])
                    if i == #text then
                        RichPrint("main", lastText)
                        PopupLayerController:hideLayer(
                            "GlobalShadeLayer",
                            function(layer)
                                layer:hideLayer()
                            end
                        )
                    end
                end
            )
        end
    end,
    --玉露泉
    ["打水"] = function(map, result, environment)
        local role = User:getRole()
        if role:getDayFlag("打水") > 0 then
            PopText("天井之水来之不易，还是明日再来取吧。")
            return
        end

        if not role:checkCanBuyTwoOrMoreThings({["yulujingshui1"] = 1}) then
            return
        end

        RichPrint("main", "你推动竹竿，重物下坠，引水装置将泉水汲了上来。")
        -- RichPrint("main", "玉露泉之中取来的水。水质清澈透亮，十分甘甜，如琼浆玉露，不仅适合烹酒煮茶，也适合照料植物。")
        role:setDayFlag("打水", 1)
        role:addItemCount("yulujingshui1", 1)
        PopText("获得玉露井水 X1")
    end,
    ["观景"] = function(map, result, environment)
        local role = User:getRole()

        if role:getDayFlag("观景") > 0 then
            PopText("好景虽然怡人，但看多了也无甚趣味，您还是明日再来吧。")
            return
        end

        local jinMax = role:getJingMax()
        local jing = role:getAttr("jing")
        if jing >= jinMax then
            PopText("您精力充沛。")
            return
        end

        local roleList = map:getRoles()
        local guanjialv = 0
        for i, v in pairs(roleList) do
            if v.id == "guanjia1001" then
                local guanjiaData = map:getRole("guanjia1001")
                guanjialv = HomelandRoleUtil:getFidelityLv(guanjiaData.defaultZhongCheng)
                break
            end
        end

        local addJing = math.floor((guanjialv + 5) * (guanjialv + 5) + jinMax / 20)
        local text = HomelandDesc:getViewScene()
        local TIME = 2
        local num = math.random(1, 4)
        if jing + addJing > jinMax then
            addJing = jinMax - jing
        end
        role:addAttr("jing", addJing)
        role:setDayFlag("观景", 1)
        PopupLayerController:showLayer(
            "GlobalShadeLayer",
            function(layer)
                layer:showLayer()
                layer:setPopText("您正在观景中")
            end
        )

        for i = 1, #text do
            map.__MapLayer:delayFunc(
                0 + (i - 1) * TIME,
                function()
                    RichPrint("main", text[i])
                    if i == #text then
                        RichPrint("main", "恢复精力 +" .. math.floor(addJing))
                        PopupLayerController:hideLayer(
                            "GlobalShadeLayer",
                            function(layer)
                                layer:hideLayer()
                            end
                        )
                    end
                end
            )
        end
    end,
    ["播种"] = function(map, result, environment)
        local SeedLayer = require("app.views.layer.HomelandLayer.SeedLayer")
        SeedLayer:showLayer(environment.currRole,map)
    end,
    ["种植进度"] = function(map, result, environment)
        local role = User:getRole()
        local currLand = environment.currRole
        local SeedModel = require("app.models.HomelandModel.SeedModel")
        local str = SeedModel:getRePlantTimeStr(currLand)
        RichPrint("main",str)
    end,
    ["照料"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()
        local currLand = environment.currRole

        if role:getTimeLimitFlag("tend_" .. currLand.id) > 0 then
            local time = math.floor(role:getTimeLimitFlagTime("tend_" .. currLand.id))
            local hour = math.floor(time / 3600)
            local min = math.floor((time - hour * 3600) / 60)
            local sec = math.floor(time - hour * 3600 - min * 60)

            RichPrint(
                "main",
                "你刚才已经照料过它了，还有" .. tostring(hour) .. "小时" .. tostring(min) .. "分钟" .. tostring(sec) .. "可执行该操作。"
            )
            return
        end

        --@RefType [src.app.models.HomelandModel.SeedModel#SeedModel]
        local SeedModel = require("app.models.HomelandModel.SeedModel")

        local currRoom = map:getRoomById(environment.currRoomId)

        local npc
        for k, npcId in pairs(currRoom.roleList) do
            local temp = map:getRole(npcId)
            if temp.cType == "老农" then
                npc = temp
                break
            end
        end

        local item = role:getItem("yulujingshui1")
        if item then
            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            --@RefType [src.app.views.layer.DialogLayer.DialogALayer#DialogALayer]
            local dialog = DialogALayer:getInstance()

            local itemAttr = Item:getOneItemByKey(item.itemId)
            dialog:show("你确定要使用" .. itemAttr.name .. "进行照料吗？")

            dialog:setWeChatVisible(false)
            dialog:setButton1(
                "是",
                function()
                    SeedModel:tendLand(currLand, map, item, npc)
                    role:addItemCount(item.itemId,-1)
                    RichPrint("main", "你将取来的玉露井水撒了下去，泉水如露水般点点滴落绿叶之间，不一会便润湿了土壤。")
                end
            )
            dialog:setButton2(
                "否",
                function()
                    SeedModel:tendLand(currLand, map, nil, npc)
                    RichPrint("main", "你照料了该土地。")
                end
            )
            dialog:setButton3(
                "取消",
                function()
                end
            )
        else
            SeedModel:tendLand(currLand, map, item, npc)
        end
    end,
    ["铲除"] = function(map, result, environment)
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()

        dialog:show("你确定要铲除该土地种植的植物么？")

        dialog:setWeChatVisible(false)

        local currLand = environment.currRole

        dialog:setButton1(
            "确定",
            function()
                local SeedModel = require("app.models.HomelandModel.SeedModel")

                SeedModel:clearLandInfo(currLand,map)

                RichPrint("main","您铲除了该地种植的植物。")
            end
        )
        dialog:setButton2(
            "否",
            function()
            end
        )
    end,
    ["种植收取"] = function(map, result, environment)
        local currRoom = map:getRoomById(environment.currRoomId)
        local npc
        for k, npcId in pairs(currRoom.roleList) do
            local temp = map:getRole(npcId)
            if temp.cType == "老农" then
                npc = temp
                break
            end
        end
        local currLand = environment.currRole
        --@RefType [src.app.models.HomelandModel.SeedModel#SeedModel]
        local SeedModel = require("app.models.HomelandModel.SeedModel")
        SeedModel:harvest(currLand,npc,map)
    end,
    ["饰品箱"] = function(map, result, environment)
        PopupLayerController:showLayer(
            "DecorativeBoxLayer",
            function(layer)
                layer:showLayer()
            end
        )
    end,
    ["设宴"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()
        if role:getTimeLimitFlag("设宴CD") > 0 then
            local time = math.floor(role:getTimeLimitFlagTime("设宴CD"))
            local hour = math.floor(time / 3600)
            local min = math.floor((time - hour * 3600) / 60)
            local sec = math.floor(time - hour * 3600 - min * 60)

            RichPrint(
                "main",
                "上一场宴席不久前才结束，请在" .. tostring(hour) .. "小时" .. tostring(min) .. "分钟" .. tostring(sec) .. "后再开宴吧！"
            )
            return
        end

        PopupLayerController:showLayer("TaiQingTaiLayer",function (layer)
            layer:showLayer(map)
        end)

    end,
    ["完美闭关"] = function(map, result, environment)
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()

        if role:getTimeLimitFlag("晶台闭关") ~= 0 then
            local time = math.floor(role:getTimeLimitFlagTime("晶台闭关"))
            local hour = math.floor(time / 3600)
            local min = math.floor((time - hour * 3600) / 60)
            local sec = math.floor(time - hour * 3600 - min * 60)

            RichPrint(
                "main",
                "此处灵气已被你消耗殆尽，还有" ..
                    tostring(hour) .. "小时" .. tostring(min) .. "分钟" .. tostring(sec) .. "秒才能恢复，还是在那之后再来吧。"
            )
            return
        end

        local skillId = Helper:getDef(role:getPrepareSkill("neigong"), "jibenneigong")
        local roleSkill = role:getSkill(skillId)
        if MapIsEmpty(roleSkill) then
            PopText("您还没学会任何内功。")
            return
        end

        local BiGuanModel = require("app.models.BiGuan.BiGuanModel")
        --@RefType [src.app.models.BiGuan.BiGuanModel#BiGuanModel]
        local biGuan = BiGuanModel:create(skillId)
        biGuan:print()

        if biGuan:checkCanBiGuan() == false then
            return
        end
        local addSkillLv = biGuan:getAddSkillLv()
        local costPot = math.floor(biGuan:getCost())

        Helper:print_lua_table(roleSkill)

        print("================", addSkillLv)
        print("=-----------------------", costPot)

        local skill = Skill:getSkill(skillId)

        PopupLayerController:showLayer(
            "PopConfirmLayer",
            function(layer)
                local text = "你确定在晶台处闭关修炼你的" .. skill.name .. "吗？\n(此处乃灵气汇聚之地，闭关必定成功)"
                layer:showRefreshPannel()
                layer:setDesc1("消耗：" .. costPot .. "潜能")

                layer:setDsc(text)
                layer:setButtonNameAndCallFunc(
                    "确认",
                    function()

                        role:setTimeLimitFlag("晶台闭关", 1, 3600 * 72)

                        local addExp = role:getSkillNeedExp(skillId,addSkillLv)

                        print("-------------------------------add exp",addExp)
                        roleSkill.exp = roleSkill.exp + addExp
                        role:setAttr("pot", role:getAttr("pot") - costPot)
                        
                        local roleSkill_test = role:getSkill(skillId)
                        Helper:print_lua_table(roleSkill_test)
                        local text = {
                            "你默默运转内力，隐隐有些感觉。",
                            "你将内力运出丹田，过紫宫、入泥丸、透十二重楼，遍布奇筋八脉，然后收回丹田。",
                            "你将内力运经诸穴，抵四肢百骸，然后又回收丹田。",
                            "你在丹田中不断积蓄内力，只觉得浑身燥热。",
                            "你缓缓呼吸吐纳，将空气中水露皆收为己用。"
                        }
                        -- role:addSkillLv(skillId,addSkillLv)
                        local TIME = 2
                        local times = 30 / TIME
                        local index = 1
                        local actionCount = 0
                        PopupLayerController:showLayer(
                            "GlobalShadeLayer",
                            function(layer)
                                layer:showLayer()
                                layer:setPopText("您正在运功，请稍后。")
                            end
                        )
                        map:setSchedule(
                            function(tag)
                                RichPrint("main", text[index])
                                index = index + 1
                                actionCount = actionCount + 1
                                if index > #text then
                                    index = 1
                                end

                                if actionCount == times then
                                    PopupLayerController:hideLayer(
                                        "GlobalShadeLayer",
                                        function(layer)
                                            layer:hideLayer()
                                        end
                                    )
                                    RichPrint(
                                        "main",
                                        "你的 【" .. tostring(skill.name) .. "】 等级 +" .. tostring(addSkillLv)
                                    )
                                    map:unSchedule(tag)
                                end
                            end,
                            2
                        )
                    end
                )
                layer:setCanelButtonNameAndCallFunc("取消")
            end
        )
    end,
    ["敲门"] = function(map, result, environment)
        local currRoomId = map:getCurrRoomId()
        local currRoomAttr = map:getRoomById(currRoomId)

        local currDoorId = map.extra.doorId
        if currDoorId == nil then
            print("当前没有大门信息")
            return
        end

        local mapRoles = map:getRoles()
        local doorAttr = HomelandRoomUtil:getDoorAttr(currDoorId)
        if not mapRoles["guanjia1001"] then
            RichPrint("main", doorAttr.caozuotext)
            return
        end

        local haveYqh = false
        local role = User:getRole()
        local items = role:getItems()
        for i, item in ipairs(items) do
            local itemAttr = Item:getOneItemByKey(item.itemId)
            if itemAttr and itemAttr.type == "邀请函" and map.mid == itemAttr.mid then
                haveYqh = true
            end
        end

        if haveYqh == true or HomelandRoomUtil:canEnterTheDoor(currDoorId) then
            map:setFlag("doorIsOpen", 1)
            RichPrint("main", doorAttr.caozuotext1)
            local currRoomRoleList = map:getRoomRoleList(currRoomId)
            local gjCurrRoom
            for k, v in pairs(map:getRoomMap()) do
                local roleList = map:getRoomRoleList(k)
                if roleList then
                    for key, value in pairs(roleList) do
                        if value == "guanjia1001" then
                            gjCurrRoom = k
                        end
                    end
                end
            end
            if gjCurrRoom then
                map:removeRoomRole(gjCurrRoom, "guanjia1001")
                local MapInfo = require("app.models.map.MapInfo")
                MapInfo:addRoleToRoom(map, currRoomId, "guanjia1001")
                --隐藏敲门按钮
                environment.currRole.canUse3 = 0

                map.__MapLayer:refreshMap()
            end
            return
        end

        --@desc 交互失败文本
        RichPrint("main", doorAttr.caozuotext2)
    end,
    ["家园熔炉"] = function(map, result, environment)
        if User:getRole():getInheritFlag("可进入苏州水底") == 0 and DEBUG_MODE ~= 1 then
            PopText("神兵系统未开启，无法使用该功能。")
            return
        end

        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()

        local skillLv = User:getRole():getSkillLv("duanzaozhishu")

        if skillLv == 0 then
            RichPrint("main", "你未学习锻造之术，无法使用")
            return
        end

        PopupLayerController:showLayer(
            "ShenBingRongLianLayer",
            function(layer)
                -- layer:setInitValue(tonumber(result.arg2),tonumber(result.arg3))
                layer:showLayer(tonumber(result.arg2), tonumber(result.arg3))
            end
        )
    end,
    ["家园锻造"] = function(map, result, environment)
        if User:getRole():getInheritFlag("可进入苏州水底") == 0 and DEBUG_MODE ~= 1 then
            PopText("神兵系统未开启，无法使用该功能。")
            return
        end
        
        --@RefType [src.app.models.role.Role#Role]
        local role = User:getRole()

        local skillLv = User:getRole():getSkillLv("duanzaozhishu")

        if skillLv == 0 then
            RichPrint("main", "你未学习锻造之术，无法使用")
            return
        end

        local gjZcLv = 0
        local isHomeLandDZ = true
        if HomelandRoleUtil:currMapHaveGj(map) then
            local gj = map:getRole("guanjia1001")
            gjZcLv = HomelandRoleUtil:getFidelityLv(gj.defaultZhongCheng)
        end

        MainControllLayer:pushLayer("FurnaceLayer")
        local FurnaceLayer = MainControllLayer:getLayer("FurnaceLayer")
        FurnaceLayer:entryLayer(result.arg2,isHomeLandDZ,gjZcLv)
    end,
    ["改造对联"] = function(map, result, environment)
        PopupLayerController:showLayer(
            "DuiLianLayer",
            function(layer)
                layer:showLayer(map, environment.currRole)
            end
        )
    end,
    ["大门改造"] = function(map, result, environment)
        PopupLayerController:showLayer(
            "DamenRenovationLayer",
            function(layer)
                layer:showLayer(map, environment.currRole)
            end
        )
    end,

    ["修炼武功"] = function(map, result, environment)
        local itemRole = environment.currRole
        if not itemRole.durable then 
            itemRole.durable = 120
            print("-----------为什么没有耐久度")
        end
        PopupLayerController:showLayer("SkillXiuLianLayer",function(layer)
            layer:showLayer(itemRole)
        end)
    end,
    
    ["假人破损"] = function(map, result, environment)
        local itemRole = environment.currRole
        if itemRole.durable >0 then 
            return
        end
        itemRole.canUse1 = false
        itemRole.canUse10 = true
        itemRole.name = "损坏的假人"
        itemRole.dsc = "一个因刻苦修炼而损坏了的假人，已经毫无用处了。"
    end,

     ["假人销毁"] = function(map, result, environment)
        local furniture = environment.currRole
        if furniture.durable >=9999 then 
            PopText("此物太过贵重，不能销毁！")
            return
        end
        local currRoomId = map:getCurrRoomId()
        local player = User:getRole()
        local furnitureId = furniture.jjId
        local fq = player:getHomelandAttr("fq")
        local localVer = player:getAttr("sCk_ver")
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        dialog:show("RED销毁：将"..furniture.name.."销毁后，"..furniture.name.."将无法复原，请慎重考虑后再进行销毁操作。","是否要将"..furniture.name.."销毁？")
        dialog:setButton1("确定", function()
           HttpManagerEx:removeFurniture(
                fq.mid,
                furniture.fid,
                localVer["homeland"],
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            local local_ver = player:getAttr("sCk_ver")
                            local_ver["homeland"] = data.ver
                            player:setAttr("sCk_ver", local_ver)
                            map:addFurTypeCount(furniture.itype,-1)                        
                            map:removeRoomRole(currRoomId, furniture.id)
                            map.roles[furniture.id] = nil
                            map.__MapLayer:refreshMap()
                            PopText("你将"..furniture.name.."销毁了")
                            local Record = require("app.models.Record.Record")
                            local logData = {}
                            logData[furnitureId] = -1
                            local logOrigin = "假人销毁"
			                Record:addLog(Record.LOG_TYPE.ITEM,logData,logOrigin)
                            return true
                        else
                            print("errcode", errcode)
                            PopText("销毁失败")
                        end
                        return true
                    else
                        print("errcode", errcode)
                        PopText("销毁失败")
                        return true
                    end
                end,
                IS_SHOW_WAITING,
                HTTP_MANAGER_RETRY_TYPE_RETRY
            )
        end)
        dialog:setButton2("取消", function()
        end)
        dialog:setWeChatVisible(false)
    end,

    ["修改家具操作可用"] = function (map, result, environment)
        local item = environment.currRole

        local useName = result.arg2

        local canUse = result.arg3

        item[useName] = tonumber(canUse) or 0
    end,
    
    ["梦境香炉添香"] = function (map, result, environment)
        local xiangLu = environment.currRole
        PopupLayerController:showLayer("XiangLuLayer",function(layer)
            layer:showLayer(xiangLu)
        end)
    end,

    ["梦境香炉收起"] = function (map, result, environment)
        local furniture = environment.currRole
        local XiangLuModel = require("app.models.HomelandModel.XiangLuModel")
        if XiangLuModel:checkFireXiangIsNormal(XiangLuModel:getFireXiangType(furniture)) then
            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:hide()
            dialog:show("香炉收起需要熄灭炉中的香，是否熄灭炉中焚烧的香？")
            dialog:setButton1("确定", function()
               FurnitureModel:pickUp(furniture, map)
            end)
            dialog:setButton2("取消", function()
            end)
            dialog:setWeChatVisible(false)
        else
            FurnitureModel:pickUp(furniture, map)
        end
    end,

    ["副本疲倦值文本提示"] = function(map, result, environment)
        local role = map:getPlayer()
        local pijuan = role:getAttr("pijuan")
        local pijuanLevelDesc = {
            [1] = "你此时只觉精神饱满，浑身上下有着用不完的力气。",  --大于0，小于等于80
            [2] = "你打了个哈欠，眨了眨干涩的眼睛，不由感觉到了一丝疲倦。", --大于80，小于等于160
            [3] = "你长长地打了个哈欠，又伸了一个懒腰，只觉倦意如潮水般向你涌来。", --大于160，小于等于200
        }

        local pijuanLevel = 1
        if pijuan > 160 then
            pijuanLevel = 3
        elseif pijuan > 80 then 
            pijuanLevel = 2
        end

        RichPrint("main", pijuanLevelDesc[pijuanLevel])
    end,

    ["自创武学"] = function (map, result, environment)
        local selfCreatedSkillSystem = map:getPlayer():getSelfCreatedSkillSystem()
        
        if selfCreatedSkillSystem:isOpenSystem() == true then
            selfCreatedSkillSystem:downloadData(function()
                AchievementSystem:updateRecord(function()
                    MainControllLayer:pushLayer("SelfCreatedSkillMenuUI")
                    local layer = MainControllLayer:getLayer("SelfCreatedSkillMenuUI")
                    layer:showLayer(selfCreatedSkillSystem)
                    local titleLayer = MainControllLayer:getLayer("TitleLayer")
                    titleLayer:setMapLayerToSelfCreatedSkillMenuUIFunc(function()
                        if selfCreatedSkillSystem:checkIsCreating() == false then
                            environment.currRole.canUse1 = 1
                            environment.currRole.canUse2 = 0
                        else
                            environment.currRole.canUse1 = 0
                            environment.currRole.canUse2 = 1
                        end
                        map.__MapLayer:delayRefreshMap()
                    end)
                end)
            end)
        else
            PopText("神功系统未开启")
        end
    end,

    ["神功书案收起"] = function (map, result, environment)
        local role = map:getPlayer()
        local selfCreatedSkillSystem = role:getSelfCreatedSkillSystem()

        local furnitrure = environment.currRole

        local itemAttr = Item:getOneItemByKey(furnitrure.jjId)
        if FurnitureModel:checkFurIsInRightRoom(itemAttr,map,map:getCurrRoomId()) == false then
            FurnitureModel:pickUp(furnitrure, map)
            return
        end

        if selfCreatedSkillSystem:checkIsCreating() then
            PopText("招式创作未完成，该家具无法收起。")
            return
        end

        FurnitureModel:pickUp(furnitrure, map)
    end,

    ["查看自创招式"] = function (map, result, environment)
        local ZhaosLibraryPresenter = require("app.presenters.selfCreatedSkill.zhaosLibrary.ZhaosLibraryPresenter")
        PopupLayerController:showLayer(
            "ZhaosLibraryUI",
            function(layer)
                local selfCreatedSkillSystem = map:getPlayer():getSelfCreatedSkillSystem()
                layer:showLayer(selfCreatedSkillSystem,function()
                    if selfCreatedSkillSystem:checkIsCreating() == false then
                        environment.currRole.canUse1 = 1
                        environment.currRole.canUse2 = 0
                    else
                        environment.currRole.canUse1 = 0
                        environment.currRole.canUse2 = 1
                    end
                    map.__MapLayer:delayRefreshMap()
                end,ZhaosLibraryPresenter)
            end
        )
    end,

    ["查看自创武学"] = function (map, result, environment)
        local selfCreatedSkillSystem = map:getPlayer():getSelfCreatedSkillSystem()
        
        if selfCreatedSkillSystem:isOpenSystem() == true then
            PopupLayerController:showLayer("BookRackUI",function(layer)
                layer:showLayer()
            end)
        else
            PopText("神功系统未开启")
        end
    end,
}

--@desc:
--@author:Liang SongQiang
--@time:2018-04-27 15:40:53
function FurnitureModule:entryMap(map, currTime)
    if PRINT_MODE == 1 then
        print("EntryMap(): id: " .. map.id, "name: " .. map.name)
    end

    -- 检查是否需要上锁房间
    if map:getMapType() ~= MAP_TYPE.MYHOME then
        return
    end
    local SeedModel = require("app.models.HomelandModel.SeedModel")
    SeedModel:checkNeedLockRoom(map)
end

return FurnitureModule 0000000000000