--@SuperType [src.app.models.map.MapHandle.Modules.BaseModule#BaseModule]
local VisitTask = class("VisitTask", require("app.models.map.MapHandle.Modules.BaseModule"))

--@RefType [src.app.models.map.MapInfo#MapInfo]
local MapInfo = require("app.models.map.MapInfo")

--@desc 涉及副本ID ：格式{["id"] = true} 默认为nil，无限制
VisitTask.mapId = nil

--@desc 涉及房间 : 格式{["id"] = true} 默认为nil，无限制
VisitTask.roomId = nil

--@desc 开启状态，默认开启
VisitTask.status = 1

--@desc 活动时间 : 格式：20171001，默认值0 表示无时间限制
VisitTask.activityTime = 0

--@RefType [src.app.models.map.BaseMap#BaseMap]


VisitTask.doResult = {
    ["拜访交谈"] = function(map, result, environment)
        local visitTaskInfo=require("app.models.task.visitTask.VisitTask")
        local npcRole=environment.currRole

        --@RefType [src.app.models.role.Role#Role]
        local player = User:getRole()

        local visitTaskId = player:getAttr("visitTaskId")

        local task = visitTaskInfo:getTaskById(visitTaskId)

        local flag = task.flag

        if flag == nil then
            return
        end
        if player:getTimeLimitFlag(flag) == 0 then
            RichPrint("main",npcRole.name .. "：如若少侠有要事在身，在下先行告退，他日再登门拜访。")
            visitTaskInfo:removeVisitNPC()
        else
            if npcRole.onlyTalk==1 then 
                if npcRole.talkTimes>=1 then
                    local text = visitTaskInfo:changeText(Helper:getDef(task.okText,""),npcRole.name)
                    RichPrint("main", text)
                    visitTaskInfo:getReward(task,npcRole.name)
                else
                    npcRole.talkTimes=npcRole.talkTimes+1
                    RichPrint("main", task.word)
                end
            elseif player:getFlag("visitTaskTalk") == 1 and (task.operation == 1 or task.operation == 3 or task.operation == 4 or task.operation == 5) then 
                PopupLayerController:showLayer("VisitTaskLayer",function (layer)
                    layer:showLayer(task,npcRole)
                end)
                -- if visitTaskInfo.visitTask.type=="消费型" or visitTaskInfo.visitTask.type=="免费型" then 
                --     visitTaskInfo.isComplete=true
                -- end
                if task.operation==3 then 
                    npcRole.caozuo2=1
                    npcRole.receivePresent = task.conditions
                end
            elseif User:getRole():getTimeLimitFlag(flag) == 2 then 
                visitTaskInfo:getReward(task,npcRole.name)
            else
                RichPrint("main", task.word)
            end
        end
    end,

    ["拜访切磋"] = function(map, result, environment)
        local visitTaskInfo=require("app.models.task.visitTask.VisitTask")
        local currMap = map
        local role=environment.currRole

        local player = User:getRole()
        local taskId = player:getAttr("visitTaskId")

        local task = visitTaskInfo:getTaskById(taskId)

        local flag = task.flag

        if flag == nil then
            return
        end

        if player:getTimeLimitFlag(flag)==0 then
            RichPrint("main",role.name .. "：如若少侠有要事在身，在下先行告退，他日再登门拜访。")
            visitTaskInfo:removeVisitNPC()
            return
        end

        if TANGJIAN_TEST_ENABLE then
            role:initNpcAttr() -- NPC状态初始化
            currMap:afterFightWithQieCuo(player, role, function(winTeamId)
                -- 战斗胜利条件结果
                if winTeamId == 1 then

                    visitTaskInfo:getReward(task,role.name)
                    map.__MapLayer:delayRefreshMap()
                    -- 刷新房间条件结果
                    currMap:doRoomConditionAndResult(map:getCurrRoomId())
                elseif winTeamId == 2 then
                    visitTaskInfo:removeVisitNPC()
                    map.__MapLayer:delayRefreshMap()
                    -- 刷新房间条件结果
                elseif winTeamId == 3 then
                else
                end
            end)
        else
        end
    end,

    ["拜访送礼"] = function(map, result, environment)
        local visitTaskInfo=require("app.models.task.visitTask.VisitTask")
        
        local player=User:getRole()

        local visitTaskId = player:getAttr("visitTaskId")

        local task = visitTaskInfo:getTaskById(visitTaskId)

        local flag = task.flag

        if flag == nil then
            return
        end

        if player:getTimeLimitFlag(flag)==0 then
            RichPrint("main",environment.currRole.name .. "：如若少侠有要事在身，在下先行告退，他日再登门拜访。")
            visitTaskInfo:removeVisitNPC()
            return
        end

        local Item = require("app.models.item.Item")

        local role=environment.currRole

        local presentId = role.receivePresent -- npc接受的礼物

        print("此NPC接受的物品Id:",role.receivePresent)
        -- assert(presentId, "presentId 不能为空")
        
        if presentId == nil then
            RichPrint("main", "CYN我不接受你的物品")
            return
        end

        --  已被装备的物品 并且背包只有一把 无法被送礼  
        if player:checkItemIsEquipbyItemId(presentId) and player:getItemCount(presentId) < 2 then
            PopText("已装备物品无法送礼")
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
                PopText("你取下了身上的"..itemAttr.name.."并送给"..role.name)
                player:setEquipByName( "weapon" , nil )
            end

            --获取奖励
            visitTaskInfo:getReward(task,role.name)
        else
            RichPrint("main", "CYN我不接受你的物品")
        end

        map.__MapLayer:delayRefreshMap()
    end,
                 
}

function VisitTask:entryMap(map)
    if map:getMapType() ~= MAP_TYPE.MYHOME then 
        return 
    end
    self:createVisitNpc(map)
end

function VisitTask:createVisitNpc(map)
    local visitTask=require("app.models.task.visitTask.VisitTask")
    
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    
    local taskId = role:getAttr("visitTaskId")

    
    if taskId ~= nil then
        local task = visitTask:getTaskById(taskId)
        if MapIsEmpty(task) then
            return
        end
        
        if role:getTimeLimitFlag(task.flag) > 0 then
            local npcId = role:getAttr("vtNpcId")
            local npcRole=visitTask:createVisitNPC(task,npcId)
            MapInfo:addMapRole(map, npcRole)
            MapInfo:addRoleToRoom(map, map.entryRoom, npcRole.id)
        end
        
    end

end

return VisitTask
0000000000000000