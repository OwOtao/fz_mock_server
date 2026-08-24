local MapMeetUtil = {}

--@desc 任务列表及相关数据
local taskList = require("script.mapMeet.ouyu4")["偶遇列表"]

--@desc 每个副本对应的区域分类
local locationList = require("script.mapMeet.ouyu4")["地点标注"]

--@desc 任务人物
local ouYuRole = require("script.mapMeet.ouyu1")["fball"]

--@desc 任务物品
local ouYuItem = require("script.mapMeet.ouyu3")["fball"]

--@desc 任务人物及数据的基础属性。
local ouYuRoleBase = require("script.mapMeet.ouyu5")["fball"]

--@RefType [src.app.models.map.MapInfo#MapInfo]
local MapInfo = require("app.models.map.MapInfo")

local mapRoleConditions
--@desc 加密
local function mapRoleConditionsEncrypt()
    mapRoleConditions = require("script.mapMeet.ouyu2")
    local mapConditionAndResults = mapRoleConditions["fball"]
    for k, v in pairs(mapConditionAndResults) do
        if string.find(k, "rlt_") then
            mapConditionAndResults[k] = createEncryptTable(v)
        end
    end

    mapRoleConditions["fball"] = mapConditionAndResults
end
mapRoleConditionsEncrypt()

--@desc 生成根据地点类型获取对应副本
local locationByArea = {}
local function initLocationTableByType()
    for fbId, area_tb in pairs(locationList) do
        for area_index, v in pairs(area_tb) do
            if area_index ~= "id" then
                if locationByArea[area_index] == nil then
                    locationByArea[area_index] = {}
                end
                table.insert(locationByArea[area_index], fbId)
            end
        end
    end
end
initLocationTableByType()

--@desc 在全副本中根据区域索引随机一个房间
function MapMeetUtil:getRandomRoomIdByAreaInAllMap(areaIndex)
    local roomId

    local mapListByArea = locationByArea[areaIndex]

    if mapListByArea == nil then
        assert(false, "OuYuModel:getRandomRoomIdByAreaInAllMap 区域索引传值出错：" .. areaIndex)
    end

    local fbId = mapListByArea[math.random(1, #mapListByArea)]

    local roomId = self:randomRoomIdByArea(areaIndex, fbId)

    return roomId
end

--@desc 根据传入的区域列表数组随机获得一个满足所有区域的副本
function MapMeetUtil:getMapIdByAreaArray(area_list)
    --@desc 满足条件的所有副本
    local map_id_list = {}

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    --@desc 不能超过人物进度
    for mapId, map_area in pairs(locationList) do
        if Map:getMapState(mapId) == MAP_STATE.COMPLETE and self:checkMapHasArea(mapId, area_list) then
            table.insert(map_id_list, mapId)
        end
    end

    if MapIsEmpty(map_id_list) then
        return nil
    end

    local mapId = map_id_list[math.random(1, #map_id_list)]

    return mapId
end

--@desc 随机获取一个任务ID
function MapMeetUtil:getTaskByWeight()
    local task = {}

    local taskIndex = Helper:RandomByWeight(taskList, "weight")

    task = taskList[taskIndex]

    print("OuYuModel:getTask() 获取随机偶遇任务ID：", taskIndex)

    return task
end

--@desc 根据任务ID获取任务数据
function MapMeetUtil:getTaskById(taskId)
    return assert(taskList[tostring(taskId)], "偶遇任务列表获取任务失败，ID：" .. taskId)
end

--@desc 获取任务的任务地点类型
function MapMeetUtil:getTaskLocMarkById(taskId)
    local task = self:getTaskById(taskId)

    return task.locMark
end

local _taskRoleOrItemIdCache = {}
--@desc 获取任务相关的NPC_ID和物品ID
function MapMeetUtil:getNpcOrItemIdByTask(taskId)
    if _taskRoleOrItemIdCache[tostring(taskId)] then
        return _taskRoleOrItemIdCache[tostring(taskId)]
    end

    local id_list = {}

    for npcId, npc in pairs(ouYuRole) do
        if tostring(npc.renwubiaoshi) == taskId then
            id_list[npcId] = true
        end
    end

    for itemId, item in pairs(ouYuItem) do
        if tostring(item.renwubiaoshi) == taskId then
            id_list[itemId] = true
        end
    end

    _taskRoleOrItemIdCache[tostring(taskId)] = id_list

    return id_list
end

--@desc 获取任务需要生成的NPC列表
function MapMeetUtil:getTaskNpcArray(taskId)
    local task = self:getTaskById(taskId)

    local npc_str = task.createRole

    local npc_list = string.split(npc_str, ";")

    return npc_list
end

--@desc 获取任务地点列表数组
function MapMeetUtil:getTaskAreaArray(taskId)
    local task = self:getTaskById(taskId)

    if task.location == nil then
        return
    end

    local loc_str = task.location

    local loc_list = string.split(loc_str, ";")

    return loc_list
end

--@desc 获取固定的任务地点列表
function MapMeetUtil:getTaskConstantLocArray(taskId)
    local task = self:getTaskById(taskId)

    if task.location1 == nil then
        assert(false, "偶遇任务：生成地点填写错误：" .. taskId)
        return
    end

    local loc_str = task.location1

    local loc_list = string.split(loc_str, ";")

    return loc_list
end

--@desc 初始化人物物品的条件结果
function MapMeetUtil:initConditions(npc)
    local mapConditionAndResults = mapRoleConditions["fball"]
    local conditionAndResults = {}
    for i = 1, 999 do
        local conditionAndResult = {}
        local conditions = npc["conditions" .. tostring(i)]
        local results = npc["results" .. tostring(i)]
        if conditions and results then
            local conditionList = string.split(conditions, ";")
            local resultList = string.split(results, ";")

            conditions = {}
            results = {}
            for k, contitionName in pairs(conditionList) do
                local condition = mapConditionAndResults["con_" .. contitionName]
                table.insert(conditions, condition)
            end
            for k, resultName in pairs(resultList) do
                local result = mapConditionAndResults["rlt_" .. resultName]

                if result then
                    table.insert(results, result)
                end
            end

            conditionAndResult["conditions"] = conditions
            conditionAndResult["results"] = results
            conditionAndResult["conditionRelation"] = npc["conditionRelation" .. tostring(i)]
        else
            break
        end
        table.insert(conditionAndResults, conditionAndResult)
    end
    npc.conditionAndResults = conditionAndResults
end

--@desc 获取副本某区域的房间列表
function MapMeetUtil:getAreaRoomListByMapId(mapId, areaIndex)
    local map_area_list = locationList[mapId]

    if map_area_list[areaIndex] == nil then
        assert(false, "该副本ID没有该区域，请检查代码：" .. mapId)
    end

    local area_str = map_area_list[areaIndex]

    local room_list = string.split(area_str, ";")

    return room_list
end

--@desc 根据区域索引随机一个房间
function MapMeetUtil:randomRoomIdByArea(areaIndex, mapId)
    local room_list = self:getAreaRoomListByMapId(mapId, areaIndex)

    local roomId = room_list[math.random(1, #room_list)]

    return roomId
end

--@desc 检查该副本是否有area_list中的所有区域
function MapMeetUtil:checkMapHasArea(mapId, area_list)
    local map_area = locationList[mapId]
    if map_area == nil then
        return false
    end

    local isHas = true
    for index, areaIndex in pairs(area_list) do
        if map_area[areaIndex] == nil then
            isHas = false
            break
        end
    end

    return isHas
end

--@desc 同副本任务NPC列表生成[需排除相同区域内已使用的房间]
function MapMeetUtil:initNpcListBySameMap(taskId, mapId)
    local task = self:getTaskById(taskId)

    local result_list = {}
    --@desc 获取NPC列表
    local npc_list = self:getTaskNpcArray(taskId)
    if task.location then
        local area_list = self:getTaskAreaArray(taskId)

        if #npc_list ~= #area_list then
            assert(false, "偶遇任务NPC 列表个数和地点数量不一致，检查资源，任务ID：" .. taskId)
        end

        if not mapId then
            mapId = self:getMapIdByAreaArray(area_list)
        end
        for index, areaIndex in ipairs(area_list) do
            local room_list = self:getAreaRoomListByMapId(mapId, areaIndex)

            local npcs = string.split(npc_list[index], ",")

            local roomIndex = math.random(1, #room_list)
            for i, npcId in ipairs(npcs) do
                result_list[npcId] = room_list[roomIndex]
            end
            table.remove(room_list, roomIndex)
        end
    elseif task.location1 then
        local room_list = self:getTaskConstantLocArray(taskId)

        if #npc_list ~= #room_list then
            assert(false, "偶遇任务NPC 列表个数和地点数量不一致，检查资源，任务ID：" .. taskId)
        end

        for k, roomId in pairs(room_list) do
            local npcs = string.split(npc_list[k], ",")

            for i, npcId in ipairs(npcs) do
                result_list[npcId] = roomId
            end
        end
    end

    return result_list
end

function MapMeetUtil:initNpcListByDiffMap(taskId, mapId)
    local task = self:getTaskById(taskId)

    local result_list = {}
    --@desc 获取NPC列表
    local npc_list = self:getTaskNpcArray(taskId)

    if task.location then
        local area_list = self:getTaskAreaArray(taskId)

        if #npc_list ~= #area_list then
            assert(false, "偶遇任务NPC 列表个数和地点数量不一致，检查资源，任务ID：" .. taskId)
        end

        if mapId then
            --@desc 不同副本任务第一个区域必须是当前副本捏。
            local room_list = self:getAreaRoomListByMapId(mapId, area_list[1])
            local npcs = string.split(npc_list[1], ",")
            local roomIndex = math.random(1, #room_list)
            local roomId = room_list[roomIndex]
            for i, npcId in ipairs(npcs) do
                result_list[npcId] = roomId
            end
            table.remove(room_list, roomIndex)
            table.remove(area_list, 1)
            table.remove(npc_list, 1)
        end

        for index, areaIndex in ipairs(area_list) do
            local npcs = string.split(npc_list[index], ",")
            local mapId = self:getMapIdByAreaArray({areaIndex})
            local room_list = self:getAreaRoomListByMapId(mapId,areaIndex)
            local roomIndex = math.random(1, #room_list)
            local roomId = room_list[roomIndex]
            for i, npcId in ipairs(npcs) do
                table.remove( room_list,roomIndex )
                result_list[npcId] = roomId
            end
        end
    elseif task.location1 then
        local room_list = self:getTaskConstantLocArray(taskId)

        for index, roomId in ipairs(room_list) do
            local npcs = string.split(npc_list[index], ",")
            for i, npcId in ipairs(npcs) do
                result_list[npcId] = roomId
            end
        end
    end

    return result_list
end

--@desc: 在关联副本创建所有任务关联的NCP和物品
--@author:Liang SongQiang
--@time:2018-07-05 23:33:11
--@map:[src.app.models.map.BaseMap#BaseMap]
--@taskId: 任务ID
function MapMeetUtil:createAllTaskNpcOrItem(taskId, map)
    local task = self:getTaskById(taskId)

    --@desc 初始化人物
    do
        local taskRoles = {}
        for npcId, npc in pairs(ouYuRole) do
            if tostring(npc.renwubiaoshi) == taskId or tostring(npc.renwubiaoshi) == "all" and map.roles[npcId] == nil then
                table.insert(taskRoles, npcId)
            end
        end


        --@desc 判断是否有身世任务NPC需要替换，如果没有全部从本地偶遇任务的人物列表中抽取数据
        if task.lifeRole ~= nil then
            local fromWebNpcs = string.split(task.lifeRole, ";")
            for i = #taskRoles, 1, -1 do
                for index, liftRoleId in ipairs(fromWebNpcs) do
                    if taskRoles[i] == liftRoleId then
                        table.remove(taskRoles, i)
                    end
                end
            end

            if not MapIsEmpty(fromWebNpcs) then
                --@RefType [src.app.models.role.Role#Role]
                local role = User:getRole()
                --@desc 当前身世任务ID
                local servant_id = role:getAttr("ssTask").serId
                self:initRoleFormWeb(map, fromWebNpcs, servant_id)
            end
        end

        for i, npcId in ipairs(taskRoles) do
            local npc = ouYuRole[npcId]
            self:initRoleInLocal(map, npc)
        end
    end

    --@desc 初始化物品
    do
        for npcId, item in pairs(ouYuItem) do
            if tostring(item.renwubiaoshi) == taskId or tostring(item.renwubiaoshi) == "all" and map.roles[npcId] == nil then
                item.type = "item"
                self:initConditions(item)
                MapInfo:addMapRole(map, item)
            end
        end
    end
end

function MapMeetUtil:initRoleInLocal(map, npc)
    npc.type = "role"

    if type(npc.words) == "string" then
        npc.words = string.split(npc.words, ";")
    end

    self:initConditions(npc)
    npc = table.mergeMap(ouYuRoleBase[npc.baseId], npc)
    -- Npc:initRoleWithRandomAttr(npc)
    -- Map:initNpcEquipsAndItems(npc)
    -- Map:initNpcActiveZhao(npc)
    Npc:initNpc(npc)
    npc = Helper:tableCover(Role:create(), npc)
    npc._inMapInited = true
    MapInfo:addMapRole(map, npc)
end

--@desc 从服务器拿数据覆盖本地人物进行生成（家园仆人） 会有延迟
function MapMeetUtil:initRoleFormWeb(map, npcIdList, npcWebId)
    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()
    local mid = role:getHouseId()

    if mid == nil then
        print("没有mid，检查存档。")
        return 
    end

    HttpManagerEx:getEmployRoleData(
        npcWebId,
        mid,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode  == 0 then
                    Helper:print_lua_table(data)
    
                    --@RefType [src.app.models.HomelandModel.HomelandRoleUtil#HomelandRoleUtil]
                    local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
    
                    for i,npcId in ipairs(npcIdList) do
                        local npc = ouYuRole[npcId]
                        --@TODO 2018-07-09 22:03:23 从服务器拿到数据后，基本数据从家园的人物基础表拿数据
                        npc = table.mergeMap(npc,data)
                        npc = table.mergeMap(npc, HomelandRoleUtil:getMobanRoleAttr(data.modal))
                        npc.type = "role"
                        npc.id = npcId
                        npc.jobType = npc.job
                        npc.cType = HomelandRoleUtil:getCHAJobTypeName(npc.jobType)
                        HomelandRoleUtil:initMapRoleNameByJobtypeAndZcLv(npc)
                        self:initConditions(npc)
                        if type(npc.words) == "string" then
                            npc.words = string.split(npc.words, ";")
                        end
        
                        -- Npc:initRoleWithRandomAttr(npc)
                        -- Map:initNpcEquipsAndItems(npc)
                        -- Map:initNpcActiveZhao(npc)
                        Npc:initNpc(npc)
                        npc = Helper:tableCover(Role:create(), npc)
                        npc._inMapInited = true
                        MapInfo:addMapRole(map, npc)
                    end
                else
                    -- PopText(errmsg)
                    print(errmsg,errcode)
                    local ShenShiTask = require("app.models.HomelandModel.MapMeetModel.ShenShiTask")
                    ShenShiTask:clearTask()
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
end

--@desc: 在副本中生成任务相关人物物品
--@author:Liang SongQiang
--@time:2018-07-05 14:01:02
--@map: [src.app.models.map.BaseMap#BaseMap]
function MapMeetUtil:createTaskInMap(map, taskId, mapList, npcList)
    if MapIsEmpty(mapList) or MapIsEmpty(npcList) then
        return
    end

    local task = self:getTaskById(taskId)

    --@RefType [src.app.models.role.Role#Role]
    local role = User:getRole()

    if task.mark then
        local flagMark = role:getFlag(task.mark)
        if flagMark == 0 then
            print("偶遇任务："..taskId.."已完成。")
            return
        end
    end

    local isRelationMap = false
    for k, taskFbId in pairs(mapList) do
        if taskFbId == map.id then
            isRelationMap = true
            break
        end
    end

    --@desc 在该副本创建任务关联所有NPC
    if isRelationMap then
        
        self:createAllTaskNpcOrItem(taskId, map)

        self:addConditionResultToMap(taskId,map)

        --@desc 把需要创建的人物创建到指定房间。
        for npcId, roomId in pairs(npcList) do
            local fbId = string.split(roomId, "_")[1]
            if fbId == map.id then
                map:addRoomRole(roomId, npcId, false)
            end
        end
        map.__MapLayer:delayRefreshMap()
    else
        print("不是任务涉及的副本，无需生成相关人物：" .. taskId)
    end
end

--@desc: 加入偶遇相关的
--@author:Liang SongQiang
--@time:2018-07-18 16:08:24
--@taskId: 任务ID
function MapMeetUtil:addConditionResultToMap(taskId,map)
    local addList = {}
    for k,v in pairs(mapRoleConditions["fball"]) do
        if tostring(v.renwubiaoshi) == tostring(taskId) or v.renwubiaoshi == "all" then
            Map:addMapRoleCondition(map.id,clone(v))
        end
    end
end


--@desc 删除副本中生成的NPC
--@map: [src.app.models.map.BaseMap#BaseMap]
function MapMeetUtil:clearMapNpc(npcList, map)
    local rooms = map:getRoomMap()

    for roomId, room in pairs(rooms) do
        if room.roleList then
            for i = #room.roleList, 1, -1 do
                local tNpcId = room.roleList[i]
                if npcList[tNpcId] == true then
                    print("删除房间人物：", tNpcId,roomId)
                    table.remove(room.roleList, i)
                end
            end
        end
    end

    for npcId, v in pairs(npcList) do
        if map.roles[npcId] then
            map.roles[npcId] = nil
        end
    end
end

return MapMeetUtil
00000000000