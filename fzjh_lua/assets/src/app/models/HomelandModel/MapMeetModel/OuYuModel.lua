local OuYuModel = {}
--@RefType [src.app.models.HomelandModel.MapMeetModel.MapMeetUtil#MapMeetUtil]
local MapMeetUtil = require("app.models.HomelandModel.MapMeetModel.MapMeetUtil")

--@TODO 2018-07-04 16:22:25 偶遇任务保存的结构
--[[
    ouYuTask = {
        id = tostring(taskId),
        locMark = "",
        exTime = "",
        maps = {fb10,fb20}
        npcs = {
            npcId = mapRoomId,
            npcId2 = mapRoomId1,
            npcId3 = mapRoomId2,
        }
    }
]]
local _currMap

--@desc 检查副本偶遇是否可以开启
function OuYuModel:checkIsOpen()
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    if Map:getMapState("fb20") == MAP_STATE.COMPLETE then
        return true
    else
        return false
    end
end

--@desc: 检查是否超过了任务时间
--@author:Liang SongQiang
--@time:2018-07-04 17:52:56
function OuYuModel:isExTime(meetInfo)
    if meetInfo == nil then
        return false
    end

    local nowTime = GetTime()

    local task = MapMeetUtil:getTaskById(meetInfo.id)
    
    if not meetInfo.exTime then
        if DEBUG_MODE == 1 then
            assert(false, "偶遇任务的过期时间没有，检查代码。")
        end
        return true
    end
    
    if nowTime >= meetInfo.exTime then
        return true
    end

    return false
end

--@desc: 
--@author:Liang SongQiang
--@time:2018-07-11 11:34:26
--@map: [src.app.models.map.BaseMap#BaseMap]
function OuYuModel:acceptTask(map)
    if map:isUserMap() then
        return
    end

    --@desc 条件不满足的情况
    if not self:checkIsOpen() then
        return
    end

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local ouYuTask = role:getAttr("ouYuTask")

    if not ouYuTask or MapIsEmpty(ouYuTask) or self:isExTime(ouYuTask) then
        ouYuTask = self:createTask()
    end

    --@desc 如果没有生成npc列表，则根据条件判断生成列表
    if MapIsEmpty(ouYuTask.npc) or MapIsEmpty(ouYuTask.maps) then
        local result_npc_list, map_list = self:createTaskMapNpcData(ouYuTask.id, map)

        ouYuTask.npc = result_npc_list
        ouYuTask.maps = map_list

        role:setFlag(MapMeetUtil:getTaskById(ouYuTask.id).mark, 1)

        role:setAttr("ouYuTask", ouYuTask)
    end

    --@desc 在副本生成任务相关的人物物品
    MapMeetUtil:createTaskInMap(map, ouYuTask.id, ouYuTask.maps, ouYuTask.npc)

    print("--------------------------------------")
    Helper:print_lua_table(ouYuTask.npc)
    Helper:print_lua_table(ouYuTask.maps)
    print("--------------------------------------\n")
end

--@desc 检查任务在此副本是否满足条件生成NPC列表
function OuYuModel:checkCanCreateNpcList(taskId, map)
    local task = MapMeetUtil:getTaskById(taskId)

    local result = true

    if task.locMark == "同副本" then
        result = self:checkSameMapTaskConditon(map, taskId)
    elseif task.locMark == "不同副本" then
        result = self:checkDiffMapTaskConditon(map, taskId)
    end

    return result
end

--@desc 检查同副本任务地点在当前副本条件是否成立
function OuYuModel:checkSameMapTaskConditon(map, taskId)
    local task = MapMeetUtil:getTaskById(taskId)

    if task.location then
        local area_list = MapMeetUtil:getTaskAreaArray(taskId)
        return MapMeetUtil:checkMapHasArea(map.id, area_list)
    elseif task.location1 then
        local loc_list = MapMeetUtil:getTaskConstantLocArray(taskId)

        local fbId = string.split(loc_list[1], "_")[1]

        if fbId == map.id then
            return true
        end

        return false
    end

    assert(false, "偶遇任务地点填写错误，请检查资源。任务ID：" .. taskId)
end

--@desc  检查不同副本的偶遇任务在当前副本地点是否成立
function OuYuModel:checkDiffMapTaskConditon(map, taskId)
    local task = MapMeetUtil:getTaskById(taskId)

    if task.location then
        local area_list = MapMeetUtil:getTaskAreaArray(taskId)
        return MapMeetUtil:checkMapHasArea(map.id, {area_list[1]})
    elseif task.location1 then
        local loc_list = MapMeetUtil:getTaskConstantLocArray(taskId)

        local fbId = string.split(loc_list[1], "_")

        if fbId[1] == map.id then
            return true
        end

        return false
    end

    assert(false, "偶遇任务地点填写错误，请检查资源。任务ID：" .. taskId)
end

--@desc: 随机生成任务
--@author:Liang SongQiang
--@time:2018-07-04 16:00:08
--@map: [src.app.models.map.BaseMap#BaseMap]
function OuYuModel:createTask()
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local task = MapMeetUtil:getTaskByWeight()

    if task == nil or MapIsEmpty(task) then
        assert(false, "获取任务失败，请检查。")
        return
    end

    local roleTask = {
        id = tostring(task.id),
        locMark = task.locMark,
        exTime = GetTime() + 3600 * 8,
        maps = {},
        npc = {}
    }

    role:setAttr("ouYuTask", roleTask)
    return roleTask
end

--@desc 创建任务相关的NPC列表
function OuYuModel:createTaskMapNpcData(taskId, map)
    local task = MapMeetUtil:getTaskById(taskId)
    local result_npc_list, map_list = {}, {}
    if task.locMark == "同副本" then
        --@desc 判断当前副本是否满足生成该任务的条件
        if self:checkSameMapTaskConditon(map, task.id) == false then
            return
        end
        result_npc_list = MapMeetUtil:initNpcListBySameMap(taskId, map.id)
        table.insert(map_list, map.id)
    elseif task.locMark == "不同副本" then
        --@desc 判断当前副本是否满足生成该任务的条件
        if self:checkDiffMapTaskConditon(map, task.id) == false then
            return
        end
        result_npc_list = MapMeetUtil:initNpcListByDiffMap(taskId, map.id)
        --@desc 添加涉及副本
        do
            local tempFbIndex = {}
            for npcId, roomId in pairs(result_npc_list) do
                local fbId = string.split(roomId, "_")[1]
                tempFbIndex[fbId] = true
            end
            for k, v in pairs(tempFbIndex) do
                table.insert(map_list, k)
            end
        end
    end

    return result_npc_list, map_list
end

--@desc: 清除任务所有相关数据
--@author:Liang SongQiang
--@time:2018-07-04 16:00:43
function OuYuModel:clearTask()
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local ouYuTask = role:getAttr("ouYuTask")

    if not ouYuTask or MapIsEmpty(ouYuTask) then
        return
    end

    local map_list = ouYuTask.maps

    if MapIsEmpty(map_list) then
        return
    end

    local npc_item_list = MapMeetUtil:getNpcOrItemIdByTask(ouYuTask.id)

    --@desc 遍历关联副本
    for i, mapId in ipairs(map_list) do
        local map = role:getMapById(mapId)
        MapMeetUtil:clearMapNpc(npc_item_list, map)
    end

    role:setFlag(MapMeetUtil:getTaskById(ouYuTask.id).mark, nil)
    role:setAttr("ouYuTask", nil)

    if PRINT_MODE == 1 then
        Helper:print_lua_table(role:getAttr("ouYuTask"))
        print("清除任务成功")
    end

    local currLayer = MainControllLayer:getCurrLayer()
    if currLayer == "MapLayer" then
        --@RefType [src.app.views.layer.MapLayer.MapLayer#MapLayer]
        local layer = MainControllLayer:getLayer(currLayer)
        layer:delayRefreshMap()
    end

    --@TODO 测试阶段输出 2018-07-12 12:15:58
    RichPrint("main", "偶遇任务删除成功。")
end

function OuYuModel:checkTaskNeedClear()
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    local ouYuTask = role:getAttr("ouYuTask")

    if ouYuTask == nil or MapIsEmpty(ouYuTask) then
        return
    end

    if self:isExTime(ouYuTask) then
        local task = MapMeetUtil:getTaskById(ouYuTask.id)
        if role:getFlag(task.mark) >= 1 then
            role:setFlag(task.mark,nil)
            print("清除偶遇任务标记，ID：",task.id,task.mark)
            --@TODO 当偶遇任务过期时，并且已经任务标记大于1的情况需有文本输出 2018-07-12 12:11:08
            RichPrint("main","您的偶遇任务已过期。")
        end
        self:clearTask()
    end
end

return OuYuModel
00000000000000