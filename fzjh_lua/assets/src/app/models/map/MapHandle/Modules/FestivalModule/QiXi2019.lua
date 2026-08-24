--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local QiXi2019 = class("QiXi2019", require("app.models.map.MapHandle.Modules.BaseModule"))
local QiXiFestival = require("app.models.Action.QiXiFestival")

--@RefType [src.app.models.map.MapInfo#MapInfo]
local MapInfo = require("app.models.map.MapInfo")

--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
QiXi2019.mapId = {}

--@desc 涉及房间 : 格式{["id"] = true} 默认为nil，无限制
QiXi2019.roomId = nil

--@desc 开启状态，默认开启
QiXi2019.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
QiXi2019.activityTime = 0


QiXi2019.doResult = {
	["放河灯"] = function(map, result, environment)
        local maxTimes= result.arg2 or 10

        if not result.arg3 then 
            print("点河灯: arg3 成功执行的条件结果集 为空")
            return
        end
        local role = User:getRole()
        if role:getItemCount("77lights1")<1 then 
        	PopText("你背包并没有七夕彩灯。")
        	return
        end
        HttpManagerEx:getActionTimes("RiverLamp",function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if data.num>=maxTimes then
                        RichPrint("main", "你今天已经放过"..tostring(maxTimes).."次七夕彩灯了。")
                        return
                    end
                    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                    local dialog = DialogALayer:getInstance()
                    dialog:hide()
                    dialog:show("你是否要在这放七夕彩灯？")
                    dialog:setButton1("确定", function()
                        dialog:hide()
                        HttpManagerEx:submitAction("RiverLamp",1,function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    role:addItemCount("77lights1", -1)
                                    RichPrint("main", "你将点燃的七夕彩灯放于水中，拨弄了几下水纹，好让它漂得更远。随后你缓缓闭上双目，在心中许了一个愿望。")
                                    map:doNoRoleResults(result.arg3,environment) 
                                else
                                    PopText(errmsg)
                                    print(errcode,errmsg)
                                end
                            else
                                PopText(errmsg)
                            end
                        end, IS_SHOW_WAITING)
                    end)
                    dialog:setButton2("取消", function()
                        RichPrint("main","你想了想决定去别的地方放七夕彩灯。")
                    end)
                    dialog:setWeChatVisible(false)
                else
                    PopText(errmsg)
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING)
    end,
    ["七夕交谈"] = function(map, result, environment)
        local npc = environment.currRole
        local talkText = ""
        if map:getFlag("是否创建七夕怪物") == 1 then
            local textList = { 
                "这《百家姓》极为常见，流传甚广，却不知这黑衣为何偏要劫取小生的手抄本？",
                "前些日子却是有一蒙面怪客拿了本残破不堪的书籍让小生代为誊抄，这两件事之间莫不是有什么关联？"
            }
            talkText = textList[math.random(1,#textList)] 
        else
            talkText = "今日，小生以《百家姓》为样苦练欧楷，不料尚未抄完，抄本竟被一黑衣客夺走。如今黑衣客逃往此地，不知少侠能否替小生取回抄本？" 
        end
        RichPrint("main", "YEL" .. npc.name .. "：" .. talkText)
    end,
    ["七夕送礼"] = function(map, result, environment)
        local player = User:getRole()
        local role = environment.currRole
        local currRoomId = environment.currRoomId
        local itemId = result.arg2 -- npc接受的礼物

        if map:getFlag("是否杀死七夕怪物") ~= 1 then --记录是否杀死七夕怪物
            RichPrint("main","YEL" .. role.name .. "：这个贼子仍然藏在此处，请少侠速速前往")
            return
        end

        local item = player:getItem(itemId)
        if item and player:getItemCount(itemId) > 0 then
            QiXiFestival:finishQiXiTask(map,role,currRoomId,itemId)
        else
            RichPrint("main","YEL" .. role.name .. "：少侠，那贼子夺去的书籍你可曾看到？想是遗落在了贼子的藏身之地。")
        end
    end,
    ["生成七夕怪物"] = function(map, result, environment)
        local player = User:getRole()
        local npcId = result.arg2

        if map:getFlag("是否创建七夕怪物") == 1 then --判断是否生成了怪物
            print("已经生成怪物")
            return
        end

        QiXiFestival:createQiXiTaskGuaiWu(npcId,map)   

        map:setFlag("是否创建七夕怪物",1)
    end,
    ["七夕怪物交谈"] = function(map, result, environment)
        local npc = environment.currRole
        local talkText = ""
        local textList = { 
            "哈哈哈，少侠当真只是替人追回书籍？只怕，你是觊觎这书中关于《摩耶经》的下落吧！",
            "江湖皆知，从关外流入一本《摩耶经》，里头暗藏神功，你也是武林中人不可能没听说过，又何必在这里惺惺作态？",
            "我劝你还是少管闲事，这本书可是关乎《摩耶经》中暗藏的关外神功，江湖各派对其势在必得，混入宝阁的也并非我一人。"
        }
        
        talkText = textList[math.random(1,#textList)] 
      
        RichPrint("main", "YEL" .. npc.name .. "：" .. talkText)
    end,
    ["七夕怪物追击"] = function(map, result, environment)
        local currRoomId = environment.currRoomId
        local currRole = environment.currRole
        local roleId = currRole.id
        local randomNum = map:getFlag("七夕怪物追击结果")
        if randomNum == 0 then
            randomNum = math.random(1,2)
            map:setFlag("七夕怪物追击结果",randomNum)
        end

        if randomNum == 1 then
            do
                local qi = User:getRoleAttr("qi")
                if qi <= 0 then
                    PopText("血量过低")
                    return
                end
                
                local attackerName = environment.currRole.name
                local anqiName = "暗器"
                local interval = 1.5
                local damagePercent = 0.1
                
                local finalCount = 0 --总次数
                local defeatedCount = 0 --失败次数

                local DialogDodgeLayer = require("app.views.layer.MapLayer.DialogDodgeLayer")
                
                local dodgeLayer = DialogDodgeLayer:createInRunningScene()
                if dodgeLayer:isAvail() == false then
                    print("dodgeLayer is now busy")
                    return
                end

                local function ResultCallFunc()
                    if dodgeLayer:isAvail() == false then
                        print("dodgeLayer is now busy")
                        return
                    end
                    dodgeLayer:reinit()
                    dodgeLayer:setAttackerName(attackerName)
                    dodgeLayer:setAnqiName(anqiName)
                    dodgeLayer:setRole(User:getRole())
                    dodgeLayer:setTime(interval)
                    dodgeLayer:setDamagePercent(damagePercent)
                    dodgeLayer:setResultCallback(function(isSucc)
                        print("躲避结果" .. tostring(isSucc))
                        finalCount = finalCount + 1
                        if isSucc ~= true then
                            defeatedCount = defeatedCount + 1
                        end
                        
                        if finalCount >= 8 then
                            print("总次数到了")
                            if defeatedCount >= 3 then
                                print("失败")
                                RichPrint("main","黑衣客狞笑一声，知道老子暗器的厉害了吧？")
                                return
                            end
                            print("成功")

                            RichPrint("main","看到你展示了鬼魅般的轻功身法，黑衣客心下大骇，仓惶逃窜，连百家姓掉到地上都没发觉。")
                            local itemId = "zhouhuodongbg"

                            map:dropItem(currRoomId, itemId,1)
                            map:removeRoomRole(currRoomId,roleId)
                            map:setFlag("是否杀死七夕怪物",1)
                            map.__MapLayer:delayRefreshMap()
                            return
                        end

                        if isSucc == true then
                            ResultCallFunc()
                        else
                            local qi = User:getRoleAttr("qi")
                            if qi <= 0 then
                                User:addRoleAttr("dead", 1)
                                User:setRoleAttr("deadReason", anqiName)
                                RichPrint("main","黑衣客狞笑一声，知道老子暗器的厉害了吧？")
                                return
                            end

                            if defeatedCount >= 3 then
                                print("失败次数到了")
                                RichPrint("main","黑衣客狞笑一声，知道老子暗器的厉害了吧？")
                                return
                            end

                            ResultCallFunc()
                        end
                    end)
                    dodgeLayer:show()
                end

                dodgeLayer:reinit()
                dodgeLayer:setRole(User:getRole())
                dodgeLayer:setAttackerName(attackerName)
                dodgeLayer:setAnqiName(anqiName)
                dodgeLayer:setTime(interval)
                dodgeLayer:setDamagePercent(damagePercent)

                dodgeLayer:setResultCallback(
                function(isSucc)
                    print("躲避结果" .. tostring(isSucc))
                    finalCount = finalCount + 1
                    if isSucc == true then
                        ResultCallFunc()
                    else
                        defeatedCount = defeatedCount + 1
                        local qi = User:getRoleAttr("qi")
                        if qi <= 0 then
                            User:addRoleAttr("dead", 1)
                            User:setRoleAttr("deadReason", anqiName)
                            RichPrint("main","黑衣客狞笑一声，知道老子暗器的厉害了吧？")
                            return
                        end
                        ResultCallFunc()
                    end
                end)
                dodgeLayer:show()
            end
        else
            local player = User:getRole()
            local role1 = player
            local role2 = currRole
            local roomId = currRoomId
            local btnType = result.arg3 -- 按钮控制 1只显示恢复 2只显示逃跑 3都显示

            FubenClient:setValue("isFighting", true)
            User:getRole():updateFightStatus("战斗中")

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
                        User:getRole():updateFightStatus("战斗结束")

                        do
                            local fightType = "切磋"
                            player:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(1, 1), fightType)
                            currRole:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(2, 1), fightType)
                        end

                        -- 战斗胜利条件结果
                        if winTeamId == 1 then
                            RichPrint("main", "你轻而易举地击败了黑衣客，他仓惶逃窜，连百家姓掉到地上都没发觉。")
                            local itemId = "zhouhuodongbg"

                            map:dropItem(currRoomId, itemId,1)
                            map:removeRoomRole(currRoomId,roleId)
                            map:setFlag("是否杀死七夕怪物",1)
                            map.__MapLayer:delayRefreshMap()
                        elseif winTeamId == 2 then
                            RichPrint("main", "黑衣客冷冷地看着你，对你的武功修为颇为不屑。")
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
                        User:getRole():updateFightStatus("战斗结束")
                        -- 隐藏按钮区域
                        fightLayer:callUIMemFunc("setButtonAreaVisble", false)
                        -- 显示战斗结束文本区域
                        fightLayer:callUIMemFunc("showFightEndTextArea")

                        -- 设置战斗结束文本区域的文本
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "逃跑")
                        local name = role1.realName or role1.name 
                        fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, name .. "大喝一声：“三十六计，走为上计")

                        fightLayer:callUIMemFunc(
                            "setFightEndTextAreaReleaseFunc",
                            function()
                                if map._mapLayer then
                                    map._mapLayer:resumeSelfAndChildren()
                                    map._mapLayer:setVisible(true)
                                end

                                MainControllLayer:resumeUpdate()

                                fightLayer:hide(
                                    function()
                                        fightLayer:destroyInstance()
                                        cleanTable(fightLayer)
                                    end
                                )
                            end
                        )
                        RichPrint("main", "黑衣客冷冷地看着你，对你的武功修为颇为不屑。")
                    end
                end,
                btnType,
                map._mapLayer._currRoom.fightBackground
            )
        end
    end,
}

function QiXi2019:entryMap(map, currTime)
    local mapId = User:getRole():getInheritFlag("七夕情书随机副本id")

    --todo:此处是否要加活动时间控制
    if map.id == mapId then
        QiXiFestival:createQiXiRole(map)
    end
end



return QiXi2019
00