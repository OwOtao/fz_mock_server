-- 江湖怪客玩法
local JiangHuGuaiKeModule = class("JiangHuGuaiKeModule", require("app.models.map.MapHandle.Modules.BaseModule"))

local JiangHuGuaiKeModel = require("app.models.HomelandModel.JiangHuGuaiKeModel")
--@desc 条件结果的方法
JiangHuGuaiKeModule.doResult = {
    ["怪物交谈"] = function(map, result, environment)
        local currRole = environment.currRole
        local currRoleId = currRole.id
        local text = JiangHuGuaiKeModel:textMoren(currRoleId)
        RichPrint("main", currRole.name.."："..text)
    end,
    ["接受挑战"] = function(map, result, environment)
        local player = User:getRole()
        local role1 = clone(player)
        local role2 = clone(map:getRole(result.arg2))
        local roomId = environment.currRoomId
        local btnType = result.arg3 -- 按钮控制 1只显示恢复 2只显示逃跑 3都显示

        Audio:playEffect("jiaoHu")

        if not JiangHuGuaiKeModel:checkCanFight() then 
            return 
        end

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

                    User:getRole():addSeeSkillAfterFight(role2) --战斗结束后添加见闻武学技能

                    -- 战斗胜利条件结果
                    if winTeamId == 1 then
                        local textLose = JiangHuGuaiKeModel:textLose(role2.id)
                        RichPrint("main", role2.name.."："..textLose)
                        JiangHuGuaiKeModel:removeKilledGuaiKe(map,roomId,role2.id)
                        JiangHuGuaiKeModel:getWinRewards(0,"",map,role2.name,roomId,role2.groupID)
                        map.__MapLayer:delayRefreshMap()
                    elseif winTeamId == 2 then
                        local textWin = JiangHuGuaiKeModel:getTextWin(role2.id)
                        RichPrint("main", role2.name.."："..textWin)
                        map.__MapLayer:delayRefreshMap()
                    end

                    do --淬毒武器使用后需扣除淬毒效果次数
                        local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
                        local zhengqi = role:getRole():getAttr("zhengqi")
                        local player = User:getRole()
                        player:setAttr("zhengqi",zhengqi)
                        if POISONSYS then
                           local rolePoison = role._role:getAttr("poison")
                            player.poison = rolePoison
                        end
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

                    User:getRole():addSeeSkillAfterFight(role2) --战斗结束后添加见闻武学技能

                    do --淬毒武器使用后需扣除淬毒效果次数
                        local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
                        local zhengqi = role:getRole():getAttr("zhengqi")
                        local player = User:getRole()
                        player:setAttr("zhengqi",zhengqi)
                        if POISONSYS then
                            local rolePoison = role._role:getAttr("poison")
                            player.poison = rolePoison
                        end
                    end
                    
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
                                MainControllLayer:resumeUpdate()
                            end

                            fightLayer:hide(
                                function()
                                    fightLayer:destroyInstance()
                                    cleanTable(fightLayer)
                                end
                            )
                        end
                    )
                    local textEscape = JiangHuGuaiKeModel:getTextEscape(role2.id)
                    RichPrint("main", role2.name.."："..textEscape)
                end
            end,
            btnType,
            map._mapLayer._currRoom.fightBackground
        )
    end,
    ["门客代打"] = function(map, result, environment)
        local role = User:getRole()
        if role:getDayFlag("每日门客代打次数") >= 2 then
            PopText("今日门客代打次数已达上限")
            return
        end

        if not JiangHuGuaiKeModel:checkCanFight() then 
            return 
        end

        PopupLayerController:showLayer("MenKeDaiDaLayer", function(layer)
            local menkeArray = JiangHuGuaiKeModel:createCanFightMenkeArray(map)
            local isMenKeDaiDa = true
            if MapIsEmpty(menkeArray) then
                layer:setDesc("你没有可代为出战的门客！")
            else
                layer:setDesc("你想让哪位门客代你出战？")
            end
            layer:setTextTitle("门客代打")
            layer:setListView(menkeArray,function(id)
                PopupLayerController:hideLayer(
                    "MenKeDaiDaLayer",
                    function(layer)
                        layer:hide()
                    end
                )
                local npcId = id
                local role1 = clone(map:getRole(npcId))
                role1.isMenKe = true

                local role2 = clone(map:getRole(result.arg2))
                local roomId = environment.currRoomId
                local btnType = result.arg3 -- 按钮控制 1只显示恢复 2只显示逃跑 3都显示

                Audio:playEffect("jiaoHu")

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

                            -- 战斗胜利条件结果
                            if winTeamId == 1 then
                                local textLose = JiangHuGuaiKeModel:textLose(role2.id)
                                RichPrint("main", role2.name.."："..textLose)
                                JiangHuGuaiKeModel:removeKilledGuaiKe(map,roomId,role2.id)
                                JiangHuGuaiKeModel:getWinRewards(1,map:getRole(npcId),map,role2.name,roomId,role2.groupID)
                                User:getRole():setDayFlag("每日门客代打次数",User:getRole():getDayFlag("每日门客代打次数") + 1)
                                map.__MapLayer:delayRefreshMap()
                            elseif winTeamId == 2 then
                                local textWin = JiangHuGuaiKeModel:getTextWin(role2.id)
                                RichPrint("main", role2.name.."："..textWin)
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
                                        MainControllLayer:resumeUpdate()
                                    end

                                    fightLayer:hide(
                                        function()
                                            fightLayer:destroyInstance()
                                            cleanTable(fightLayer)
                                        end
                                    )
                                end
                            )
                            local textEscape = JiangHuGuaiKeModel:getTextEscape(role2.id)
                            RichPrint("main", role2.name.."："..textEscape)
                        end
                    end,
                    btnType,
                    map._mapLayer._currRoom.fightBackground
                )
            end)
            layer:showLayer()
        end)
    end
}

function JiangHuGuaiKeModule:entryMap(map, currTime)
    if JIANG_HU_GUAI_KE_ISOPEN ~= true then
        return
    end

    local role = User:getRole()
    local roleLv = role:getLv()
    if map:isUserMap() and roleLv >= 200 then
        JiangHuGuaiKeModel:createGuaiKe(map)
    end
end


return JiangHuGuaiKeModule0000000000000