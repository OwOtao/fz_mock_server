local DreamNpc = require("app.models.npc.DreamNpc")
local DreamMap = require("app.models.map.DreamMap")
local DreamUtil = require("app.models.DreamWorldModel.DreamUtil")
local newClass = require("third.class.NewClass")

local MAX_X = 10

local MAX_Y = 10

local DreamConst = require("app.models.DreamWorldModel.DreamConst")

local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")

local MapResHelper = require("app.models.map.MapResHelper")

--@desc 事件类型
local EVENT_TYPE = DreamConst.RoomEventType

local EVENT_TYPE_ATRR_NAME = DreamConst.RoomTypeName

local OPERTION_EVENT_NAME = DreamConst.OpertionEventName

local MAX_FLOOR = DreamConst.MAX_FLOOR

local log = function(obj)
    if PRINT_MODE == 1 then
        if type(obj) == "table" then
            Helper:print_lua_table(obj)
        else
            print(obj)
        end
    end
end

local DreamSystem = {}

function DreamSystem:create(role)
    local p = DreamSystem.new()
    p.__isNotSerializable = true
    p:init(role)
    return p
end

function DreamSystem:init(role)
    self:setRole(role)
    self:setResManager()
    role:setDreamSystem(self)
end

function DreamSystem:setResManager()
    self._resManager = require("app.models.DreamWorldModel.DreamResManager")
end

function DreamSystem:getResManager()
    return self._resManager
end

function DreamSystem:setRole(role)
    self.__role = role
end

function DreamSystem:getRole()
    return self.__role
end

--@desc: 根据事件ID获取事件
--@author:Seven_L
--@time:2019-12-19 17:39:45
--@event_id: 事件id
function DreamSystem:_getEevetByLv(eventType, eventLv, eventInfo)
    local events = eventInfo.selectList.event_list_by_lv[tostring(eventType)][tostring(eventLv)]

    return events
end

--@desc: 根据楼层创建门
function DreamSystem:createDoorByFloor(floor)
    local floorEvent = self._resManager:getDrEvents()["楼层事件"][tostring(math.min(MAX_FLOOR,floor))]
    local defaultEvent_drlx3 = floorEvent.drlx3
    local floorLv = assert(tonumber(string.split(defaultEvent_drlx3,";")[2]),"初始类房间没有填楼层难度")
    local exitEvents = self._resManager:getEventListByLv()[tostring(EVENT_TYPE.EXIT)][tostring(floorLv)]
    local floorId = Helper:RandomByWeight(exitEvents, "Eventweight", "npcid")
    return floorId
end

--@desc: Boss房与Exit房 二选一
--@author: Seven_L
--@time:2019-12-19 16:47:34
--@str: 策划填写字段，需解析
function DreamSystem:_initBossRoomOrExitRoom(floor_event, eventInfo)
    self:_initSpecialRoom(floor_event.drlx1, EVENT_TYPE.BOSS, eventInfo)

    --@desc 如果没有生成boss类型事件，则生成出口房间事件
    if MapIsEmpty(eventInfo.eventList.bossRoom) == true then
        local eventType = EVENT_TYPE.EXIT
        local exit_str = floor_event.drlx11
        local exit_arr = string.split(exit_str, ";")
        if exit_arr[2] == nil or exit_arr[2] == "" then
            self:_insertEventByType(eventInfo, eventType)
        else
            self:_insertEventByLvRange(exit_arr[2], eventType, eventInfo)
        end
    else
        local eventType = EVENT_TYPE.BOSSPRE

        local pre_arr = string.split(floor_event.drlx10, ";")

        if pre_arr[2] == nil or pre_arr[2] == "" then
            self:_insertEventByType(eventInfo, eventType)
        else
            self:_insertEventByLvRange(pre_arr[2], eventType, eventInfo)
        end
    end
end

--@desc: 根据事件类型随机插入
--@author:Seven_L
--@time:2020-04-01 10:57:24
--@eventInfo: 环境
--@eventType: 事件类型
function DreamSystem:_insertEventByType(eventInfo, eventType)
    local event = self:_selectEventByType(eventInfo, eventType)
    if event ~= nil then
        self:_insertEvent(event, eventInfo)
    end
end

--@desc: 根据lv范围抽取
--@author:Seven_L
--@time:2020-04-01 11:01:44
--@rangStr: lv范围字符串
--@eventType: 事件类型
--@eventInfo: 事件抽取过程中的环境变量
function DreamSystem:_insertEventByLvRange(rangStr, eventType, eventInfo)
    --@desc 直接根据lv拿事件
    local event_lv_range = string.split(rangStr, ",")

    local start_index = event_lv_range[1]

    local end_Index = event_lv_range[2]

    if end_Index == nil or end_Index == "" then
        end_Index = start_index
    end
    self:_selectEventByLvRange(eventInfo, eventType, start_index, end_Index)
end

--@desc: 根据事件类型抽取要生成事件
--@author:Seven_L
--@time:2019-12-20 11:20:38
--@str: 策划填写字段
--@eventType: 事件类型
--@eventInfo: 事件抽取过程中的环境变量
function DreamSystem:_initSpecialRoom(str, eventType, eventInfo)
    local strArr = string.split(str, ";")

    --@desc 概率
    local probability = strArr[1]

    --@desc 难度范围
    local range = strArr[2]

    if probability ~= "" and tonumber(probability) > 0 then
        local rand = math.random(0, 100)

        if rand <= tonumber(probability) then
            if range == nil or range == "" then
                self:_insertEventByType(eventInfo, eventType)
            else
                self:_insertEventByLvRange(range, eventType, eventInfo)
            end
        end
    end
end

--@desc: 抽取普通事件
--@author:Seven_L
--@time:2019-12-20 11:38:57
--@floor_event: 楼层事件
--@eventInfo: 事件抽取过程中的环境变量
function DreamSystem:_initNormalRoom(floor_event, eventInfo)
    local events_struct = {}

    --@desc 字段解析
    for i = 6, 8 do
        local str = floor_event["drlx" .. i]

        local arr = string.split(str, ";")
        --@desc 权重
        local weight = tonumber(arr[1])

        --@desc 解析抽取范围
        local lv_start_index = 0
        local lv_end_index = 0
        if arr[2] ~= "" and arr[2] ~= nil then
            local range_arr = string.split(arr[2], ",")
            lv_start_index = tonumber(range_arr[1])
            if range_arr[2] ~= nil and range_arr[2] ~= "" then
                lv_start_index = tonumber(range_arr[2])
            end
        end

        --@desc 上下限数量
        local minStr = floor_event["drlx" .. i .. "s"]
        local min_count = -1
        local max_count = -1
        if minStr ~= nil and minStr ~= 0 and minStr ~= "" then
            local min_max = string.split(minStr, ",")
            min_count = tonumber(min_max[1])
            if min_max[2] ~= nil and min_max[2] ~= "" then
                max_count = tonumber(min_max[2])
            end
        end

        local eventType = {
            [6] = EVENT_TYPE.TASKS,
            [7] = EVENT_TYPE.FIGHT,
            [8] = EVENT_TYPE.EMPTY
        }

        local event_struct = {
            event_type = eventType[i],
            weight = weight,
            lv_start_index = lv_start_index,
            lv_end_index = lv_end_index,
            min_count = min_count,
            max_count = max_count
        }
        table.insert(events_struct, event_struct)
    end

    --@desc 随机保底的事件
    for i, event in ipairs(events_struct) do
        if type(event.min_count) == "number" and event.min_count > 0 then
            for i = 1, event.min_count do
                --@desc 如果有指定范围
                if event.lv_start_index ~= 0 then
                    if event.lv_end_index == 0 or event.lv_end_index == "" then
                        self:_selectEventByLvRange(eventInfo, event.event_type, event.lv_start_index, event.lv_start_index)
                    else
                        self:_selectEventByLvRange(eventInfo, event.event_type, event.lv_start_index, event.lv_end_index)
                    end
                else
                    self:_insertEventByType(eventInfo, event.event_type)
                end
            end
        end
    end

    --@desc 抽取完保底后要将可能已经到达数量的类型移除
    for i = #events_struct, 1, -1 do
        local event = events_struct[i]
        local event_type_name = switch(event.event_type, EVENT_TYPE_ATRR_NAME)

        local max_count = event.max_count
        local now_count = #eventInfo.eventList[event_type_name]

        if max_count > 0 and now_count >= max_count then
            table.remove(events_struct, i)
        end
    end

    --@desc 如果有剩余 随机权重
    if eventInfo.remaining_event_count > 0 then
        for i = 1, eventInfo.remaining_event_count do
            local total_count = 0

            local index = Helper:RandomByWeight(events_struct, "weight")

            local event = events_struct[index]

            local max_count = event.max_count

            local event_type_name = switch(event.event_type, EVENT_TYPE_ATRR_NAME)
            local now_count = #eventInfo.eventList[event_type_name]

            if max_count > 0 and now_count < max_count then
                if event.lv_start_index ~= 0 then
                    if event.lv_end_index == 0 or event.lv_end_index == "" then
                        self:_selectEventByLvRange(eventInfo, event.event_type, event.lv_start_index, event.lv_start_index)
                    else
                        self:_selectEventByLvRange(eventInfo, event.event_type, event.lv_start_index, event.lv_end_index)
                    end
                else
                    self:_insertEventByType(eventInfo, event.event_type)
                end

                local count = #eventInfo.eventList[event_type_name]
                if count >= max_count then
                    table.remove(events_struct, index)
                end
            else
                if event.lv_start_index ~= 0 then
                    if event.lv_end_index == 0 or event.lv_end_index == "" then
                        self:_selectEventByLvRange(eventInfo, event.event_type, event.lv_start_index, event.lv_start_index)
                    else
                        self:_selectEventByLvRange(eventInfo, event.event_type, event.lv_start_index, event.lv_end_index)
                    end
                else
                    self:_insertEventByType(eventInfo, event.event_type)
                end
            end
        end
    end
end

--@desc: 根据难度范围抽取事件列表
--@author:Seven_L
--@time:2019-12-19 20:11:12
--@eventInfo:随机过程的环境变量
--@upper:上限
--@lower: 下限
function DreamSystem:_selectEventByLvRange(eventInfo, eventType, startIndex, endIndex)
    local event_list = {}
    --@desc 根据lv范围随机，需得出范围内数量
    for i = tonumber(startIndex), tonumber(endIndex) do
        local events = self:_getEevetByLv(eventType, i, eventInfo)
        if MapIsEmpty(events) == false then
            for i, v in ipairs(events) do
                table.insert(event_list, v)
            end
        end
    end

    if MapIsEmpty(event_list) == false then
        local rand_index = Helper:RandomByWeight(event_list, "Eventweight")
        local e = event_list[rand_index]
        self:_insertEvent(e, eventInfo)
    else
        print(eventType .. "  lv : " .. startIndex .. "~" .. endIndex .. "没有符合要求的事件或事件列表已经被抽空。")
    end
end

--@desc: 根据事件类型纯随机
--@author:Seven_L
--@time:2019-12-20 10:33:21
--@eventInfo: 随机过程的环境变量
--@eventType:事件类型
function DreamSystem:_selectEventByType(eventInfo, eventType)
    local event_list = eventInfo.selectList.event_list_by_type[tostring(eventType)]

    if MapIsEmpty(event_list) == true then
        print("根据类型随机得出列表为空表：" .. eventType)
    else
        local index = math.random(1, #event_list)

        local event = event_list[index]

        return event
    end

    return nil
end

--@desc:插入筛选出的事件，并删除出筛选列表
--@author:Seven_L
--@time:2019-12-19 18:43:35
--@event: 筛选出的事件
--@eventInfo:
function DreamSystem:_insertEvent(event, eventInfo)
    local eventType = event.Eventtype

    local event_id = event.id

    local event_name = switch(eventType, EVENT_TYPE_ATRR_NAME)

    table.insert(eventInfo.eventList[event_name], event)

    if MapIsEmpty(eventInfo.selectList.event_list_by_lv[tostring(eventType)]) == false then
        for lv, events in pairs(eventInfo.selectList.event_list_by_lv[tostring(eventType)]) do
            if lv == tostring(event.lv) then
                for i = #events, 1, -1 do
                    local info = events[i]
                    if info.id == event.id then
                        table.remove(eventInfo.selectList.event_list_by_lv[tostring(eventType)][lv], i)
                        break
                    end
                end
            end
        end
    end

    eventInfo.remaining_event_count = eventInfo.remaining_event_count - 1

    if eventInfo.remaining_event_count < 0 then
        print("==============================================")
        print("剩余事件数已小于0，请检查是否出错。")
        print("此次生成事件应为：", eventInfo.event_total_count)
        Helper:print_lua_table(eventInfo.eventList)
        print("==============================================\n")
    end

    local type_list = eventInfo.selectList.event_list_by_type[tostring(eventType)]
    for i = #type_list, 1, -1 do
        local e = type_list[i]
        if e.id == event.id then
            table.remove(type_list, i)
            break
        end
    end
end

function DreamSystem:_getFloorEvents(floor)
    local drEvents = self._resManager:getDrEvents()
    local template_num = floor
    if template_num > MAX_FLOOR then
        template_num = MAX_FLOOR
    end
    return drEvents["楼层事件"][tostring(template_num)]
end

function DreamSystem:createMap(floor)
    local floor_event = self:_getFloorEvents(floor)
    local eventInfo = {
        event_total_count = 0,
        remaining_event_count = 0,
        selectList = {
            event_list_by_lv = clone(self._resManager:getEventListByLv()),
            event_list_by_type = clone(self._resManager:getEventListByType())
        },
        eventList = {
            bossRoom = {},
            shopRoom = {},
            defaultRoom = {},
            hideRoom = {},
            treasureRoom = {},
            taskRoom = {},
            fightRoom = {},
            emptyRoom = {},
            trapRoom = {},
            bossPreRoom = {},
            exitRoom = {}
        }
    }

    --@desc 事件数
    local eventsArr = string.split(floor_event.drEvents, ";")
    if eventsArr[2] ~= nil and eventsArr[2] ~= "" then
        eventInfo.event_total_count = math.random(tonumber(eventsArr[1]), tonumber(eventsArr[2]))
    else
        eventInfo.event_total_count = tonumber(eventsArr[1])
    end

    eventInfo.remaining_event_count = eventInfo.event_total_count

    --@desc boss房和出口房二选一
    self:_initBossRoomOrExitRoom(floor_event, eventInfo)

    --@desc 没有特殊规则，单独抽取的属性
    local prop_list = {
        -- 商品类;
        drlx2 = EVENT_TYPE.SHOP,
        -- 初始类;
        drlx3 = EVENT_TYPE.DEFAULT,
        -- 隐藏类;
        drlx4 = EVENT_TYPE.HIDE,
        -- 秘宝类;
        drlx5 = EVENT_TYPE.TREASURE
    }
    for prop_name, event_type in pairs(prop_list) do
        self:_initSpecialRoom(floor_event[prop_name], event_type, eventInfo)
    end

    --@desc 根据权重抽取
    self:_initNormalRoom(floor_event, eventInfo)

    local roomCount = 0
    local map_event_list = {}

    --@desc 唯一出口位置要求
    local pos_unique_list = {}

    --@desc boss类型事件处理
    local boss_event = {}

    local drEvents = self._resManager:getDrEvents()
    
    for k, v in pairs(eventInfo.eventList) do
        if k == EVENT_TYPE_ATRR_NAME[EVENT_TYPE.BOSS] or k == EVENT_TYPE_ATRR_NAME[EVENT_TYPE.BOSSPRE] then
            if boss_event[k] == nil then
                boss_event[k] = {}
            end
            for i, v1 in ipairs(v) do
                table.insert(boss_event[k], v1)
            end
        else
            for i, v1 in ipairs(v) do
                if drEvents["功能房id"]["drlx" .. v1.Eventtype]["roomKey"] == 1 then
                    table.insert(pos_unique_list, v1)
                else
                    roomCount = roomCount + 1
                    table.insert(map_event_list, v1)
                end
            end
        end
    end

    log(eventInfo)

    local map = {
        id = "drFloor_" .. floor,
        name = "梦境",
        mapType = self:_getMapType(),
        inText = floor_event.dreamtext,
        ouyuopen = 2,
        room = {},
        roles = {},
        dream = {}
    }

    local map_matrix = {}

    local room_ids = {}

    for i = 1, roomCount do
        local id = "room_" .. i
        table.insert(room_ids, id)
    end

    local center_pos = cc.p(math.ceil(MAX_X / 2), math.ceil(MAX_Y / 2))

    local env = {
        --@desc 选位置是否排除周边已占用格子
        exUsed = false,
        --@desc 记录位置信息
        matrix = {},
        --@desc 随机房间列表
        room_ids = room_ids,
        --@desc 现在计算的位置
        now_pos = nil,
        --@desc 前一个计算的位置
        pre_pos = nil,
        --@desc 确定放置位置的顺序
        placeQueue = {},
        --@desc 上次从placeQueue里面拿对象时的索引
        lastUseCount = nil,
        --@desc 房间事件填充列表(仅放置没有位置要求的事件，如有位置等特殊要求，需单独生成房间并抽取。)
        event_list = map_event_list,
        --@desc 存放事件类型生成的的NPC，下个事件房间生成时需排除相同npcid
        event_list_roomnpc = {},
        --@desc 有唯一出口要求的事件
        pos_event_list = pos_unique_list,
        --@desc boss事件处理
        boss_event = boss_event,
        --@desc 生成地图最大X轴坐标
        max_pos_x = 0,
        --@desc 生成地图最大Y轴坐标
        max_pos_y = 0,
        --@desc 生成地图最小X轴坐标
        min_pos_x = 0,
        --@desc 生成地图最小Y轴坐标
        min_pos_y = 0
    }

    env.now_pos = center_pos

    --@region 普通房间位置确定
    while #env.room_ids > 0 do
        if env.now_pos == center_pos and env.pre_pos == nil then
            -- --@desc 初始位置，直接赋值
            local randIndex = math.random(1, #env.room_ids)
            local roomId = env.room_ids[randIndex]
            local room = self:_createRoomByEventList(roomId, env)
            self:_addRoomToMap(map, room)
            self:_addRoomToMatrix(env.matrix, env.now_pos, roomId)
            table.remove(room_ids, randIndex)
            table.insert(env.placeQueue, env.now_pos)
            env.pre_pos = env.now_pos
        else
            local dirs = self:_getCanUseDirection(env.matrix, env.now_pos, env.exUsed)
            if MapIsEmpty(dirs) == false then
                local dir = dirs[math.random(1, #dirs)]

                local next_pos = cc.pAdd(env.now_pos, Helper:getDirectionVec2(dir))

                if env.matrix[next_pos.x .. "_" .. next_pos.y] == nil then
                    local randIndex = math.random(1, #env.room_ids)

                    local roomId = env.room_ids[randIndex]

                    local room = self:_createRoomByEventList(roomId, env)

                    local now_room_id = env.matrix[env.now_pos.x .. "_" .. env.now_pos.y]

                    local now_room = map.room[now_room_id]

                    self:_connectRoom(now_room, room, dir)

                    self:_addRoomToMap(map, room)

                    self:_addRoomToMatrix(env.matrix, next_pos, roomId)

                    table.remove(room_ids, randIndex)

                    table.insert(env.placeQueue, next_pos)

                    env.pre_pos = env.now_pos

                    env.now_pos = next_pos

                    env.exUsed = false
                else
                    --@desc 当随机位置已是被占用的情况。
                    local placed_room_id = env.matrix[next_pos.x .. "_" .. next_pos.y]

                    local placed_room = map.room[placed_room_id]

                    local now_room_id = env.matrix[env.now_pos.x .. "_" .. env.now_pos.y]

                    local now_room = map.room[now_room_id]

                    self:_connectRoom(now_room, placed_room, dir)

                    env.pre_pos = env.now_pos

                    env.now_pos = next_pos

                    env.exUsed = true
                end

                env.lastUseCount = nil
            else
                if env.lastUseCount == nil then
                    env.lastUseCount = #env.placeQueue
                end

                local count = env.lastUseCount

                local last_place_pos = env.placeQueue[count]

                env.pre_pos = env.now_pos

                env.now_pos = last_place_pos

                env.lastUseCount = env.lastUseCount - 1

                env.exUsed = true
            end
        end
    end
    --@endregion

    --@RefType [src.app.models.map.EditorMap#EditorMap]
    local map = DreamMap:create(map)

    if map.entryRoom1 == nil then
        map.entryRoom1 = "room_1"
    end

    --@region 生成位置唯一的房间
    local has_empty_link_rooms = {}
    for roomId, room in pairs(map.room) do
        local link = room.link
        for i, v in ipairs({"up", "right", "down", "left"}) do
            if link[v] == nil then
                table.insert(has_empty_link_rooms, room)
                break
            end
        end
    end

    if MapIsEmpty(env.pos_event_list) == false then
        for _, event in ipairs(env.pos_event_list) do
            local room_rand_index = math.random(1, #has_empty_link_rooms)

            local room = has_empty_link_rooms[room_rand_index]

            local empty_dirs = {}
            for _, v in ipairs({"up", "right", "down", "left"}) do
                if room.link[v] == nil then
                    table.insert(empty_dirs, v)
                end
            end

            local dir_rand_index = math.random(1, #empty_dirs)
            local dir = empty_dirs[dir_rand_index]

            roomCount = roomCount + 1
            local roomid = "room_" .. roomCount
            local next_room = self:_createRoomByEventList(roomid, {event_list = {event}, event_list_roomnpc = env.event_list_roomnpc})
            self:_connectRoom(room, next_room, dir)

            self:_addRoomToMap(map, next_room)

            local has_empty = false
            for _, v in ipairs({"up", "right", "down", "left"}) do
                if room.link[v] == nil then
                    has_empty = true
                    break
                end
            end

            if has_empty == false then
                table.remove(has_empty_link_rooms, room_rand_index)
            end
        end
    end
    --@endregion

    --@desc 生成Boss房间事件
    if MapIsEmpty(env.boss_event) == false then
        for i, event in ipairs(env.boss_event[EVENT_TYPE_ATRR_NAME[EVENT_TYPE.BOSSPRE]]) do
            local room_rand_index = math.random(1, #has_empty_link_rooms)

            local room = has_empty_link_rooms[room_rand_index]

            local empty_dirs = {}
            for _, v in ipairs({"up", "right", "down", "left"}) do
                if room.link[v] == nil then
                    table.insert(empty_dirs, v)
                end
            end

            local dir_rand_index = math.random(1, #empty_dirs)
            local dir = empty_dirs[dir_rand_index]

            roomCount = roomCount + 1
            local roomid = "room_" .. roomCount
            local next_room = self:_createRoomByEventList(roomid, {event_list = {event}, event_list_roomnpc = env.event_list_roomnpc})
            self:_connectRoom(room, next_room, dir)
            self:_addRoomToMap(map, next_room)

            --@region boss房间
            local boss_event = env.boss_event[EVENT_TYPE_ATRR_NAME[EVENT_TYPE.BOSS]][i]

            local empty_dirs = {}
            for _, v in ipairs({"up", "right", "down", "left"}) do
                if next_room.link[v] == nil then
                    table.insert(empty_dirs, v)
                end
            end

            local dir = empty_dirs[math.random(1, #empty_dirs)]
            roomCount = roomCount + 1
            local boss_room_id = "room_" .. roomCount
            local boss_room = self:_createRoomByEventList(boss_room_id, {event_list = {boss_event}, event_list_roomnpc = env.event_list_roomnpc})
            self:_connectRoom(next_room, boss_room, dir)
            self:_addRoomToMap(map, boss_room)
            --@endregion
        end
    end

    self:_addSpecialNpc(map, floor)

    return map
end

function DreamSystem:_getMapType()
    return MAP_TYPE.DREAMMAP
end

function DreamSystem:_addSpecialNpc(map, floor)
    local rooms = map.room

    if MapIsEmpty(rooms) == true then
        error("putInSpecialNpc ： 地图没有房间？？")
        return
    end

    local roomTypes = {}

    for rooomId, room in pairs(rooms) do
        local roomType = room.roomType

        if roomTypes["drlx" .. tostring(roomType)] == nil then
            roomTypes["drlx" .. tostring(roomType)] = {}
        end

        table.insert(roomTypes["drlx" .. tostring(roomType)], room.id)
    end

    local drSpecialNpc = self._resManager:getDrSpecialNpc()

    local specialNpcRule = drSpecialNpc.rule

    local unlockNpcRule = drSpecialNpc.unlock_rule

    local isUnlockRule = false

    local ruleFloorList = {}

    --从解锁规则池拿对应数据
    for k,v in pairs(unlockNpcRule) do
        if v.drfloor == floor then
            if v.Unlockid and AchievementSystem:checkUnlockPointIsUnlock(v.Unlockid) then
                isUnlockRule = true
                table.insert(ruleFloorList,v)
            end
        end
    end
    --无解锁特殊单位，从原规则池拿数据
    if isUnlockRule == false then
        for _, rule_info in pairs(specialNpcRule) do
            if rule_info.drfloor == floor then
                table.insert(ruleFloorList, rule_info)
            end
        end
    end

    if #ruleFloorList <= 0 then
        return
    end

    for i = 1, #ruleFloorList do
        local rule = ruleFloorList[i]

        if rule.probability > 0 and math.random(1, 100) <= rule.probability then
            local npcId = rule.npcid

            local roomTypeRandomList = string.split(rule.drlxid, ";")

            --@desc 查找当前房间是否有该类型房间
            for j = #roomTypeRandomList, 1, -1 do
                local randomRoomType = roomTypeRandomList[j]
                if roomTypes[randomRoomType] == nil or #roomTypes[randomRoomType] == 0 then
                    table.remove(roomTypeRandomList, j)
                end
            end

            if #roomTypeRandomList == 0 then
                print("------该npc无房间可加入    npcId  = ",npcId)
            else
                local randomIndex = math.random(1, #roomTypeRandomList)
    
                local randomType = roomTypeRandomList[randomIndex]
    
                local roomRandomIndex = math.random(1, #roomTypes[randomType])
    
                local roomId = roomTypes[randomType][roomRandomIndex]
    
                table.insert(rooms[roomId].roleList, npcId)
    
                table.remove(roomTypes[randomType], roomRandomIndex)
    
                print("========================== add special npc " .. npcId .. " ====================")
                print("room id :", roomId)
                print("-------------------------------------------")
                Helper:print_lua_table(rooms[roomId].roleList)
                print("========================== add special npc end ====================\n")
            end
        end
    end
end

--@desc: 连接两个房间
--@author:Liang SongQiang
--@time:2019-11-20 14:44:14
--@room1: 房间1
--@room2: 房间2
--@dir: 方向
function DreamSystem:_connectRoom(room1, room2, dir)
    room1.link[dir] = room2.id

    local nav_dir = Helper:getOppositeDirection(dir)

    room2.link[nav_dir] = room1.id
end

--@desc: 获取某一点可以随机的方向数组
--@author:Liang SongQiang
--@time:2019-11-19 15:29:19
--@matrix: 位置占用信息列表
--@start_pos: 计算的位置
--@exUsed: 是否排除已被占用的位置。
function DreamSystem:_getCanUseDirection(matrix, start_pos, exUsed)
    local array = {}

    for dir_index, dir_str in ipairs(DIRECTION_LINK_STR) do
        if dir_index ~= DIRECTION_LINK.CENTER then
            local point = Helper:getDirectionVec2(dir_str)
            local pos = cc.pAdd(start_pos, point)

            if (pos.x > 0 and pos.x <= MAX_X) and (pos.y > 0 and pos.y <= MAX_Y) then
                if exUsed ~= true then
                    table.insert(array, dir_str)
                elseif exUsed == true then
                    if matrix[pos.x .. "_" .. pos.y] == nil then
                        table.insert(array, dir_str)
                    end
                end
            end
        end
    end

    return array
end

--@desc: 位置确定后，放置房间位置
--@author:Liang SongQiang
--@time:2019-11-19 14:16:14
--@matrix: 位置-房间记录矩阵
--@pos: 位置对象
--@roomId: 房间ID
function DreamSystem:_addRoomToMatrix(matrix, pos, roomId)
    if matrix[pos.x .. "_" .. pos.y] ~= nil then
        print("此位置已被使用，请检查：" .. pos.x .. "," .. pos.y)
        return false
    end

    matrix[pos.x .. "_" .. pos.y] = roomId

    return true
end

--@desc: 把创建好的房间加入副本中
--@author:Liang SongQiang
--@time:2019-11-19 12:11:34
--@map: 副本对象
--@room: 需要加入副本的房间
function DreamSystem:_addRoomToMap(map, room)
    if map.room == nil then
        map.room = {}
    end

    map.room[room.id] = room

    if room.roomType == EVENT_TYPE.DEFAULT then
        map.entryRoom1 = room.id
    end

    return true
end

function DreamSystem:_createRoom(roomid, eventType)
    local event_room_info = self._resManager:getDrEvents()["功能房id"]["drlx" .. eventType]

    local randRooms = event_room_info.roomname

    local roomIds = string.split(randRooms, ";")

    local rand = math.random(1, #roomIds)

    local roomId = roomIds[rand]

    local fbId = string.split(roomId, "_")[1]

    local mapRooms = MapResHelper:getMapRoomRes(fbId)

    local roomInfo = mapRooms[roomId]

    if roomInfo == nil then
        error(false, "随机房间名字：随机房间ID不存在：" .. roomId)
    end

    return {
        id = roomid,
        name = roomInfo.name,
        dsc = roomInfo.dsc,
        link = {
            center = nil,
            left = nil,
            leftUp = nil,
            up = nil,
            rightUp = nil,
            right = nil,
            rightDown = nil,
            down = nil,
            leftDown = nil
        },
        roleList = {},
        canLeave = 1,
        enterable = 1,
        stepMusic = Helper:getDef(roomInfo.stepMusic, "jiaobu")
    }
end

--@desc: 在列表中随机抽取事件生成房间
--@author:Seven_L
--@time:2020-04-01 20:15:22
--@roomid: 房间id
--@roomInfo: 房间信息
--@event_list: 事件列表
function DreamSystem:_createRoomByEventList(roomid, env)
    local event_list = env.event_list

    local event_list_roomnpc = env.event_list_roomnpc
    local room
    if MapIsEmpty(event_list) == false then
        local rand = math.random(1, #event_list)

        local event = event_list[rand]

        room = self:_createRoom(roomid, event.Eventtype)
        room.roomType = event.Eventtype

        room.drEventId = event.id

        room.roleList = {}

        --@desc 事件NPC
        if event.npcid ~= nil and event.npcid ~= "" then
            local event_npcs = string.split(event.npcid, ";")
            for i, npcid in ipairs(event_npcs) do
                if npcid ~= nil and npcid ~= "" then
                    table.insert(room.roleList, npcid)
                end
            end
        end

        local event_room_info = self._resManager:getDrEvents()["功能房id"]["drlx" .. event.Eventtype]

        if MapIsEmpty(event_room_info) == false then
            room.stepMusic = Helper:getDef(event_room_info.stepMusic, "jiaobu")
            --@desc 上锁功能
            if event_room_info.roomKey == 1 then
                room.enterable = 0
                room.roomKey = 1
            end

            if event_room_info.roomnpc ~= 0 and event_room_info.roomnpc ~= "" then
                local npcs = string.split(event_room_info.roomnpc, ",")
                local list = {}
                for i = 1, #npcs do
                    if npcs[i] ~= nil and npcs[i] ~= "" then
                        table.insert(list, npcs[i])
                    end
                end

                for i = #list, 1, -1 do
                    local npcid = list[i]

                    if event_list_roomnpc[npcid] == true then
                        table.remove(npcs, i)
                    end
                end

                if #list > 1 then
                    local randIndex = math.random(1, #list)
                    table.insert(room.roleList, list[randIndex])
                    event_list_roomnpc[list[randIndex]] = true
                else
                    table.insert(room.roleList, list[1])
                    event_list_roomnpc[list[1]] = true
                end
            end
        else
            print("该类型 ： " .. event.Eventtype .. ' "功能房id"表中没有对应类型')
        end

        table.remove(event_list, rand)
    end

    return room
end

--@desc 创建NPC
function DreamSystem:createNpc(npcId, floorNum)
    print("创建梦境 NPC npcId = ", npcId, floorNum)
    local drUnit = self._resManager:getDrUnit()
    local drwx = self._resManager:getDrWx()
    local wxGroup = self._resManager:getWxGroup()
    local drdw = self._resManager:getDrdw()
    local drName = self._resManager:getDrName()

    local npc_info = Helper:tableCover({}, drUnit[npcId])

    if npc_info == nil then
        return nil
    end

    local wx_str = npc_info.WuXueMuBan

    local unit_str = npc_info.unitMuBan

    local floorBuffValue = math.max(floorNum - MAX_FLOOR, 0)

    local floorNum = floorNum > MAX_FLOOR and MAX_FLOOR or floorNum

    if wx_str ~= nil and wx_str ~= "" and wx_str ~= 0 then
        local wx_muban_list = string.split(wx_str, ";")

        local groupId = wx_muban_list[math.random(1, #wx_muban_list)]

        local randomList = {}

        local groupList = wxGroup[tonumber(groupId)]

        for i, v in ipairs(groupList) do
            if v.drfloor == floorNum then
                table.insert(randomList, v)
            end
        end

        local id = Helper:RandomByWeight(randomList, "weight", "id")

        if id == nil then
            error("npcId : " .. npcId .. "武学模板随机出空值，检查资源")
        end
        local info = drwx[tostring(id)]

        Helper:tableCover(npc_info, info)

        -- 等级;lv	加力;jiali	气血;qi	内力;neili  臂力;str	根骨;con	身法;dex	悟性;int
        -- 超过40层 以40层属性为基础 每层提高 5% 低于40层读表
        npc_info.lv = npc_info.lv ~= nil and Helper:mathFloor(npc_info.lv + npc_info.lv * 0.05 * floorBuffValue) or npc_info.lv
        npc_info.jiali = npc_info.jiali ~= nil and Helper:mathFloor(npc_info.jiali + npc_info.jiali * 0.05 * floorBuffValue) or npc_info.jiali
        npc_info.qi = npc_info.qi ~= nil and Helper:mathFloor(npc_info.qi + npc_info.qi * 0.05 * floorBuffValue) or npc_info.qi
        npc_info.neili = npc_info.neili ~= nil and Helper:mathFloor(npc_info.neili + npc_info.neili * 0.05 * floorBuffValue) or npc_info.neili
        npc_info.str = npc_info.str ~= nil and Helper:mathFloor(npc_info.str + npc_info.str * 0.05 * floorBuffValue) or npc_info.str
        npc_info.sav = npc_info.sav ~= nil and Helper:mathFloor(npc_info.sav + npc_info.sav * 0.05 * floorBuffValue) or npc_info.sav
        npc_info.con = npc_info.con ~= nil and Helper:mathFloor(npc_info.con + npc_info.con * 0.05 * floorBuffValue) or npc_info.con
        npc_info.dex = npc_info.dex ~= nil and Helper:mathFloor(npc_info.dex + npc_info.dex * 0.05 * floorBuffValue) or npc_info.dex

        local i = 1
        while true do
            if npc_info["skillLv" .. i] ~= nil then
                npc_info["skillLv" .. i] = Helper:mathFloor(npc_info["skillLv" .. i] + npc_info["skillLv" .. i] * 0.05 * floorBuffValue)
                i = i + 1
            else
                break
            end
        end
    end

    if unit_str ~= nil and unit_str ~= "" and unit_str ~= 0 then
        local unit_list = string.split(unit_str, ";")
        local unit_id
        if tonumber(unit_list[2]) ~= nil then
            unit_id = math.random(tonumber(unit_list[1]), tonumber(unit_list[2]))
        else
            unit_id = unit_list[1]
        end
        local unit_info = Helper:tableCover({}, drdw[tostring(unit_id)])
        if unit_info ~= nil then
            if unit_info.unitType == "role" then
                --@desc 性别随机
                local sex_list = string.split(tostring(unit_info.sex), ";")
                local sex = sex_list[math.random(1, #sex_list)]
                if tonumber(sex) == 1 then
                    unit_info.sex = "男"
                elseif tonumber(sex) == 2 then
                    unit_info.sex = "女"
                else
                    unit_info.sex = "野兽"
                end

                --@desc 年龄随机
                local age_range = string.split(tostring(unit_info.age), ";")
                local age = 1
                if age_range[2] == nil or age_range[2] == "" then
                    age = tonumber(age_range[1])
                else
                    age = math.random(tonumber(age_range[1]), tonumber(age_range[2]))
                end
                unit_info.age = age

                --@desc 容貌随机
                local looks_range = string.split(tostring(unit_info.looks), ";")
                local looks = 1
                if looks_range[2] == nil or looks_range[2] == "" then
                    looks = tonumber(looks_range[1])
                else
                    looks = math.random(tonumber(looks_range[1]), tonumber(looks_range[2]))
                end
                unit_info.looks = looks
            else
                unit_info.sex = "野兽"
            end

            --@region 随机姓名
            local name = ""
            if unit_info.xing ~= nil and unit_info.xing ~= 0 then
                local xingList = string.split(unit_info.xing, ";")
                if xingList[1] == "" or xingList[2] == "" or xingList[2] == nil or xingList[1] == "nil" then
                    error("drdw 表中 id  : " .. unit_id .. " 字段xing 填写格式错误：" .. unit_info.xing)
                end

                if tonumber(xingList[1]) > 0 and tonumber(xingList[2]) > 0 then
                    local surnameId = math.random(tonumber(xingList[1]), tonumber(xingList[2]))
                    local propertyName
                    if unit_info.sex == "男" then
                        propertyName = "bsurname"
                    elseif unit_info.sex == "女" then
                        propertyName = "gsurname"
                    else
                        if unit_info.unitType == "item" then
                            propertyName = "itemname"
                        else
                            propertyName = 0
                        end
                    end
                    if propertyName ~= 0 and drName[tostring(surnameId)][propertyName] ~= 0 then
                        name = drName[tostring(surnameId)][propertyName]
                    end
                end
            end

            if unit_info.ming ~= nil and unit_info.ming ~= 0 then
                local mingList = string.split(unit_info.ming, ";")
                if mingList[1] == "" or mingList[2] == "" or mingList[2] == nil or mingList[1] == "nil" then
                    error("drdw 表中 id  : " .. unit_id .. " 字段xing 填写格式错误：" .. unit_info.xing)
                end

                if tonumber(mingList[1]) > 0 and tonumber(mingList[2]) > 0 then
                    local nameId = math.random(tonumber(mingList[1]), tonumber(mingList[2]))
                    local propertyName
                    if unit_info.sex == "男" then
                        propertyName = "bname"
                    elseif unit_info.sex == "女" then
                        propertyName = "gname"
                    else
                        propertyName = 0
                    end

                    if propertyName ~= 0 then
                        if drName[tostring(nameId)][propertyName] ~= 0 then
                            name = name .. drName[tostring(nameId)][propertyName]
                        end
                    end
                end
            end

            if name ~= "" then
                unit_info.name = name
            end
            --@endregion

            Helper:tableCover(npc_info, unit_info)
        else
            print("没有该属性模板 ID：" .. tostring(unit_id))
        end
    end

    npc_info.id = npcId

    return DreamNpc:create(npc_info)
end

--@endregion

--@desc: 增加进入新创梦境接口
--@author:Seven
--@time:2020-12-11 16:26:55
function DreamSystem:enterNewMap(dream_role)
    self:enterMap(1,dream_role,function ()
        local dreamtfnodetext = self._resManager:getDrTftexts()
        local player = User:getRole()
        local dream_talent = player:getAttr("DreamTalent")

        for _,text_info in pairs(dreamtfnodetext) do
            local tf_id = text_info.tianfuid
            if dream_talent[tostring(tf_id)] == true then
                RichPrint("main",text_info.texts)
            end
        end

    end)
end

function DreamSystem:enterMap(floor_num, dreamRole,enter_layer_callback)
    enter_layer_callback = Helper:getDef(enter_layer_callback,EMPTY_FUNC)
    local map = self:createMap(floor_num)
    Map:setMapWithId(map.id, map)
    map:setPlayer(dreamRole) --设置梦境主角
    dreamRole.dreamWorld.cFloor = floor_num --记录梦境楼层

    local currLayerName = MainControllLayer:getCurrLayer()
    local layer = MainControllLayer:getLayer(currLayerName)

    RichPrint("main", Helper:getDef(map.inText, ""))

    --@desc 进入梦境,需要把装备的兵器和准备的兵器武学同步
    local DreamEquip = require("app.models.DreamWorldModel.DreamEquip")
    DreamEquip:equipWeapon(dreamRole,dreamRole:getEquipByName("weapon"))

    layer:delayFunc(
        2,
        function()
            map:setCallBackAndConnect(
                function()
                    local mapLayer = MainControllLayer:getLayer("MapLayer")

                    mapLayer:enterMap(map)

                    MainControllLayer:pushLayer("MapLayer")

                    MessageCenter:notify("EnterMap", {map = map})

                    map:getPlayer():dispatchEvent("EnterMap", {map = map})

                    enter_layer_callback()
                end
            )
        end
    )
end

--@desc: 进入下一层(先完成当前楼层，再进入下一层)
--@author:Seven_L
--@time:2020-04-11 14:37:25
--@map: 当前地图
--showStr 中间跳转动画显示文本
function DreamSystem:enterNextMap(map, showStr)
    local player = map:getPlayer()

    --@desc 当前楼层完成事件
    map:getPlayer():dispatchEvent("FloorCompleteEvent", {map = map})

    local next_floor = player.dreamWorld.cFloor + 1
    player.dreamWorld.cFloor = next_floor

    local handleEventRecord = function(events)
        if MapIsEmpty(events) == false then
            self:handlDreamOperationEvent(events)
        end
    end

    local currLayerName = MainControllLayer:getCurrLayer()
    local layer = MainControllLayer:getLayer(currLayerName)

    local entryMapLayer = MainControllLayer:getLayer("EntryMapLayer")
    entryMapLayer:maxZ()
    entryMapLayer:setCenterText(showStr)
    entryMapLayer:show()

    local enterNextMap = function(curr_map, next_map, role)
        -- @TODO 2020-11-20 12:01:32 临时处理进入下一层时 还能点击上一层人物按钮
        local roleList = curr_map:getRoomRoleList(curr_map:getCurrRoomId())

        for i = #roleList, 1, -1 do
            local tRoleId = roleList[i]
            curr_map:removeRoomRole(curr_map:getCurrRoomId(),tRoleId)
        end

        curr_map.__MapLayer:delayRefreshMap()
        
        
        --清醒值消耗完了，梦境楼层不再改变
        if role:getAttr("sober") > 0 then
            --@desc 可结算楼层
            role.dreamWorld.eFloor = next_floor
        end
        
        next_map:setPlayer(role)
        


        layer:delayFunc(
            2,
            function()
                -- MainControllLayer:getLayer("PrintLayer"):initRichText()

                curr_map:leaveMap()

                RichPrint("main", Helper:getDef(next_map.inText, ""))

                next_map:setCallBackAndConnect(
                    function()
                        local mapLayer = MainControllLayer:getLayer("MapLayer")

                        mapLayer:switchMap(next_map)

                        
                        MessageCenter:notify("EnterMap", {map = next_map})
                        
                        map:getPlayer():dispatchEvent("EnterMap", {map = map})

                        MainControllLayer:removeLayer("EntryMapLayer")
                        
                        self:showFloorSettleLayer(next_floor,next_map)
                    end
                )
            end
        )
    end

    local addPijuanFunc = function(addValue)
        if addValue == 0 or type(addValue) ~= "number" then
			return
		end
        local role = User:getRole()
        role:addAttr("pijuan",addValue)
        local text 
        if addValue > 0 then
            text = "随着梦境的深入，疲倦值增加"..tostring(addValue).."点"
        else
            text = "随着梦境的深入，疲倦值扣除"..tostring(math.abs(addValue)).."点"
        end
        PopText(text)
    end

    HttpManagerEx:dreamFloorComplete(
        player:getTrimData(),
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    handleEventRecord(data.eventsInfo)
                    local next_map = self:createMap(next_floor)
                    Map:setMapWithId(next_map.id, next_map)
                    enterNextMap(map, next_map, player)
                    addPijuanFunc(data.addPijuan)
                    return true
                elseif errcode == 2 then
                    --@desc 信息校对后流程
                    handleEventRecord(data.eventsInfo)
                    player:destory()
                    local role = self:createDreamRoleWithData(data.roleAttr)
                    local next_map = self:createMap(next_floor)
                    Map:setMapWithId(next_map.id, next_map)
                    enterNextMap(map, next_map, role)
                    addPijuanFunc(data.addPijuan)
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end


--@desc: 梦境副本结算
--@author:Seven
--@time:2020-09-01 11:54:20
--@map: 副本地图
--@callback: 结算callback
function DreamSystem:mapComplete(map, callback)
    local roleAttr = map:getPlayer():getTrimData()

    --@desc 奖励的角色
    local rewardRole = User:getRole()

    local uploadParams = {
        roleAttr = roleAttr,
        rewardParams = {lv = rewardRole:getLv(), menpaiId = map:getPlayer():getFamilyId(), qiMax = rewardRole:getFinalAttr("qiMax"), neiliMax = rewardRole:getFinalAttr("neiliMax")}
    }

    HttpManagerEx:dreamWorldComplete(
        uploadParams,
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if MapIsEmpty(data.eventsInfo) == false then
                        self:handlDreamOperationEvent(data.eventsInfo)
                    end

                    self:_handleCompleteReward(data.reward, map, map:getPlayer().dreamWorld.eFloor, callback)

                    local dreamsettlement = self._resManager:getDrPj()
                    
                    --@desc 完成梦境时，给玩家回复精力值
                    self:addJingDreamComplete()
                    
                    local pijuan = rewardRole:getAttr("pijuan")

                    local buffId,overText
                    for _,valueRange in pairs(dreamsettlement) do
                        local min = valueRange.min

                        local max = valueRange.max

                        if pijuan > min and pijuan <= max  then
                            buffId = valueRange.drbuffid
                            overText = valueRange.overtest
                        end
                    end

                    -- if buffId ~= nil and buffId ~= 0 then
                    --     rewardRole:addBuffV2(buffId)    
                    -- end
                    
                    self:_doRecordUnlock(map:getPlayer())

                    --@desc 输出文本
                    MainControllLayer:getLayer("PrintLayer"):initRichText()
                    if overText ~= nil then
                        RichPrint("main", overText)
                    end

                    -- if pijuan < 0 then
                    --     rewardRole:setAttr("pijuan",0)
                    -- end

                    self:printRoleInfo(map:getPlayer())
                    
                    return true
                elseif errcode == 1 then
                    print("--------------- 梦境角色信息重复上传！！！ -------------------")
                    return true
                elseif errcode == -2 then --@desc 作弊强制退出梦境副本
                    PopText(errmsg)
                    if callback then
                        callback()
                    end
                    return true
                else
                    PopText(errmsg)
                    return false
                end
            else
                PopText(errmsg)
                return false
            end
        end,
        IS_SHOW_WAITING,
        HTTP_MANAGER_RETRY_TYPE_RETRY
    )
end


function DreamSystem:printRoleInfo(role)
    local itemStr,skillStr,buffStr = "","",""
    if MapIsEmpty(role:getItems()) == false then
        for i,v in ipairs(role:getItems()) do
            itemStr = itemStr..v.itemId.."#"..v.count.."|"
        end
    end
    if MapIsEmpty(role:getSkillPrepare()) == false then
        for k,v in pairs(role:getSkillPrepare()) do
            skillStr = skillStr..v.."#"..role:getSkillLv(v).."|"
        end
    end
    local buffManager = role._buffManager
    if buffManager then
        if #buffManager.buffList > 0 then
            for i = 1, #buffManager.buffList do
                local buff = buffManager.buffList[i]
                buffStr = buffStr..buff.id.."#"..tostring(buff.state).."#"..buff.layers.."|"
            end
        end
    end
    print("角色梦境死亡记录:"..",楼层="..role.dreamWorld.eFloor.. ",等级="..role.lv..",碎银="..role.dreamPoints..",情绪id="..role.emotionMgr:getCurrEmotion().type..",先天臂力="..role.str..",先天根骨="..role.con..",先天身法="..role.dex..",后天臂力="..role.secStr..",后天根骨="..role.secCon..",后天身法="..role.secDex..",气血上限="..role:getFinalAttr("qiMax")..",内力上限="..role:getFinalAttr("neiliMax")..",攻击力="..role:getAtk()..",防御力="..role:getDef()..",加力值="..role:getAttr("jiaLi")..",伤害力="..role:getPowerDamage()..",防护力="..role:getFangHu()..",闪躲力="..role:getDodge()..",命中力="..role:getHitRate()..",招架力="..role:getParry()..",背包数据="..itemStr..",武学数据="..skillStr..",Buff数据="..buffStr)
end

--@desc: 处理楼层中发生的事件
--@author:Seven
--@time:2020-09-01 15:10:53
--@events: 服务器返回客户端需处理的事件
function DreamSystem:handlDreamOperationEvent(events)
    for i, event in ipairs(events) do
        if event.type == OPERTION_EVENT_NAME.Unlock_Talent then
            local talentId = event.id

            --记录到存档
            DreamTalentModel:addUserDreamTalent(talentId)
            
            local talent = DreamTalentModel:getTalentAttrById(talentId)
            if talent.drbuffid and talent.drbuffid ~= 0 and talent.talentType == 1 then
                User:getRole():addBuffV2(talent.drbuffid)
            end
        elseif event.type == OPERTION_EVENT_NAME.Upgrade_Talent then
            local talentId = event.id
            local nextId = DreamTalentModel:getUpgradeTalentId(event.id)
            local talent = DreamTalentModel:getTalentAttrById(talentId)
            local nextTalent = DreamTalentModel:getTalentAttrById(nextId)

            --记录到存档  删除升级前的天赋，新增升级后的天赋
            DreamTalentModel:deleteUserDreamTalent(talentId)
            DreamTalentModel:addUserDreamTalent(nextId)
            DreamTalentModel:changeUserPrepareTalent(talentId,nextId)
            if talent.drbuffid and talent.drbuffid ~= 0 and talent.talentType == 1 then
                User:getRole():removeBuffV2(talent.drbuffid)
            end
            if nextTalent.drbuffid and nextTalent.drbuffid ~= 0 and nextTalent.talentType == 1 then
                User:getRole():addBuffV2(nextTalent.drbuffid)
            end
        end
    end
end

--@desc: 梦境结算奖励
--@author:Seven
--@time:2020-09-01 15:37:46
--@rewards: 服务器返回奖励数据
--@map: 地图
--@floor: 结算楼层（用于显示）
--@callback: 奖励领取回调
function DreamSystem:_handleCompleteReward(rewards, map, floor, callback)
    PopupLayerController:showLayer(
        "DreamCompleteRewardLayer",
        function(rewardLayer)
            rewardLayer:showLayer(
                rewards,
                floor,
                function()
                    if callback then
                        callback()
                    end
                    --@desc 梦境结束销毁梦境主角
                    map:getPlayer():destory()
                end
            )
        end
    )
    RewardManager2:getReward(rewards, User:getRole(), map)
end

--@desc 梦境完成任务
function DreamSystem:finishTask(map, currRoomId)
    local room = map:getRoomMap()[currRoomId]
    local taskId = room.drEventId
    local eventType = room.roomType
    local events = self._resManager:getEventListByType()[tostring(eventType)]
    if MapIsEmpty(events) == false then
        local npcId = nil
        for k, v in pairs(events) do
            if v.id == taskId then
                npcId = v.rewardid
                break
            end
        end
        map:addRoomRole(currRoomId, npcId)
    else
        error(nil, "没有该类型事件 :" .. eventType)
    end
end

--@desc 离开房间删除房间单位
function DreamSystem:deleteRoleList(map, currRoomId)
    local room = map:getRoomMap()[currRoomId]
    local taskId = room.drEventId
    local eventType = room.roomType
    local events = self._resManager:getEventListByType()[tostring(eventType)]
    if MapIsEmpty(events) == false then
        local delete = 0
        for k, v in pairs(events) do
            if v.id == taskId then
                delete = v.delete
                break
            end
        end
        if delete == 1 then
            map.room[currRoomId].roleList = {}
            map.__MapLayer:delayRefreshMap()
        end
    else
        error(nil, "没有该类型事件 :" .. eventType)
    end
end

--@desc 梦境完成时增加玩家精力
function DreamSystem:addJingDreamComplete()
    local role = User:getRole()
    local dr_params = role:getAttr("dr_params")
    if MapIsEmpty(dr_params) then
        return
    end
    local enterDreamBedValue = dr_params.enterDreamBedValue
    local enterDreamPijuan = dr_params.enterDreamPijuan
    local jingMax = role:getJingMax()
    local currPijuan = role:getAttr("pijuan")
    if type(enterDreamBedValue) == "number" and type(enterDreamPijuan) == "number" then
        print("enterDreamBedValue = ",enterDreamBedValue,"enterDreamPijuan = ",enterDreamPijuan,"jingMax = ",jingMax,"currPijuan = ",currPijuan)
        local addJing = (enterDreamBedValue^2 + jingMax/100)*(enterDreamPijuan-currPijuan)/200
        addJing = math.max(math.floor(addJing),0)
        print("addJing = ",addJing)
        if addJing > 0 then     
            role:addAttr("jing", addJing)
            PopText("精力 + "..addJing)
        end
        
        role:setAttr("dr_params",{})
    end
end

--@desc 获取梦境经验奖励
function DreamSystem:getExpReward(floor)
    floor = Helper:getRange(floor,1,MAX_FLOOR)
    local dreamfloorexp = self._resManager:getDrFloorExp()
    local exp = 0

    for k,v in pairs(dreamfloorexp) do
        if v.drfloor == floor then
            exp = v.floorexp
            break
        end
    end

    return exp
end

--@desc 特殊标记对应解锁记录点
function DreamSystem:_doRecordUnlock(role)
    if not role then
        return
    end

    if role:getFlag("红衣男子结算") == 1 then
        local record = AchievementSystem:getRecordById(3002)
		AchievementSystem:add(record)
    end

    --完成一次梦境结算 记录点
    do
        local record = AchievementSystem:getRecordById(5011)
        AchievementSystem:add(record)
    end
end

--创建梦境人物
--@attrMobanId: 属性模板id
--@sectMobanId: 门派模板id
--@desc 无参数就是根据表内权重随机模板
function DreamSystem:createNewDreamRole(attrMobanId,sectMobanId)
    local data = self:_createRoleData(attrMobanId,sectMobanId)

    local role = self:_createDreamRole()

    local DreamRoleModel = require("app.models.DreamWorldModel.DreamRoleModel")
    self:_setRoleData(role,data)
    
    DreamUtil:initDreamRoleWeaponSkill(role)
    
    role.dreamWorld = {
        eFloor = 1,
        cFloor = 1
    }
    
    DreamRoleModel:addRoleMessage(role)

    -- 检查矫正属性
    self:_initAttr(role)
    
    -- 属性监控
    self:_initAttrMonitor(role)
    
    --@desc 初始化物品带来的buff
    role:initItemBuff()

    self:_initDreamTalentBuff(role)

    return role
end

function DreamSystem:createDreamRoleWithData(data)
    local role = self:_createDreamRole()
    local DreamRoleModel = require("app.models.DreamWorldModel.DreamRoleModel")
    self:_setRoleData(role,data)

    role.isDreamRole = true --是否是梦境人物
    if role.dreamWorld == nil then
        role.dreamWorld = {
            eFloor = 1,
            cFloor = 1
        }
    end
    
    DreamRoleModel:addRoleMessage(role)

    -- 属性监控
    self:_initAttrMonitor(role)

    return role
end

-- 检查矫正属性
function DreamSystem:_initAttr(role)
    role:initAttr()
end

-- 属性监控
function DreamSystem:_initAttrMonitor(role)
    role:initAttrMonitor()
end

function DreamSystem:_createDreamRole()
    local RoleFactory = require("app.models.role.factory.RoleFactory")
    return RoleFactory:createDreamRole()
end

function DreamSystem:_setRoleData(role,data)
    Helper:tableCover(role, data)
	self:_initDreamRole(role)

    role:updateRoleBuff()
    role:checkActiveZhaoIsDeblocking()
end

function DreamSystem:_initDreamRole(role)
    local RoleBuff = require("app.models.role.RoleBuff")
	role._roleBuff = RoleBuff:create()

    -- 自创武学系统
    local SelfCreatedSkillSystem = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillSystem")
    role._selfCreatedSkillSystem = SelfCreatedSkillSystem:create()
    
    -- 面具系统
	local MaskSystem = require("app.models.mask.MaskSystem")
	role._maskSystem = MaskSystem:create(role)

	local RoleItemSystem = require("app.models.role.item.RoleItemSystem")
	role._roleItemSystem = RoleItemSystem:create(role)

	--@desc 情绪系统接入
	local EmotionMgr = require("app.models.DreamWorldModel.EmotionStatus.EmotionMgr")
	role.emotionMgr = EmotionMgr:create(role)

	local BuffManager = require("app.models.Buff.BuffManager")
	role._buffManager = BuffManager:create()
	-- 监控buff状态变化
    role._buffManager:registerUpdateFunc(function()
        role:dispatchEvent("roleBuffUpdate")
    end)

    local SelfCreatedSkillPropSystem = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillPropSystem")
	role._selfCreatedSkillSystem:setPropSystem(SelfCreatedSkillPropSystem:create())
    role._selfCreatedSkillSystem:init(role)
    
    role._buffManager:init(role)
    
    role._selfCreatedSkillSystem:updataSelfCreatedSkillMap()
end

function DreamSystem:_initDreamTalentBuff(role)
    local DreamTalentTab = User:getRole():getAttr("DreamTalent")
    local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")
    if MapIsEmpty(DreamTalentTab) == false then
        for talentId ,v in pairs(DreamTalentTab) do
            local talent = DreamTalentModel:getTalentAttrById(talentId)
            if talent.drbuffid and talent.drbuffid ~= 0 and talent.talentType == 2 then
                print("------初始化天赋带来的buff--------",talent.drbuffid)
                role:addBuffV2(talent.drbuffid)
            end
        end
    end
end

--初始化梦境人物
--@attrMobanId: 属性模板id
--@sectMobanId: 门派模板id
function DreamSystem:_createRoleData(attrMobanId,sectMobanId)
    local roleAttrMoban = self:_getRoleAttrMoBan(attrMobanId)
    
    local roleWuGongMoban = self:_getRoleWuGongMoBan(sectMobanId)

    return self:_createDreamRoleData(roleAttrMoban,roleWuGongMoban)
end

function DreamSystem:_createDreamRoleData(roleAttrMoban,roleWuGongMoban)
    local dreamRoleData = table.mergeMap(roleAttrMoban, roleWuGongMoban)

    --性别
    local sexStrList = string.split(dreamRoleData.sex,";")
    local sexNum = math.random(tonumber(sexStrList[1]),tonumber(sexStrList[2]))
    local sex = sexNum == 1 and "男" or "女"
    dreamRoleData.sex = sex

    --容貌
    local looksStrList = string.split(dreamRoleData.looks,";")
    local looksNum = math.random(tonumber(looksStrList[1]),tonumber(looksStrList[2]))
    dreamRoleData.looks = looksNum

    --年龄
    local ageStrList = string.split(dreamRoleData.age,";")
    local ageNum = math.random(tonumber(ageStrList[1]),tonumber(ageStrList[2]))
    dreamRoleData.age = ageNum
    
    --姓名
    if tonumber(dreamRoleData.name) == 0 then
        dreamRoleData.name = self:_createName(dreamRoleData.sex)
    end

    --气血
    local qiStrList = string.split(dreamRoleData.qi,";")
    local qiNum = math.random(tonumber(qiStrList[1]),tonumber(qiStrList[2]))
    dreamRoleData.qi = math.modf(qiNum/100)*100

    --内力
    local neiliStrList = string.split(dreamRoleData.neili,";")
    local neiliNum = math.random(tonumber(neiliStrList[1]),tonumber(neiliStrList[2]))
    dreamRoleData.neili = math.modf(neiliNum/100)*100
    
    --加力
    local jialiStrList = string.split(dreamRoleData.jiali,";")
    local jialiNum = math.random(tonumber(jialiStrList[1]),tonumber(jialiStrList[2]))
    dreamRoleData.jiali = jialiNum

    --先天四维
    do
        --臂力
        local strs = string.split(dreamRoleData.str,";")
        local str = math.random(tonumber(strs[1]),tonumber(strs[2]))
        dreamRoleData.str = str

        --根骨
        local cons = string.split(dreamRoleData.con,";")
        local con = math.random(tonumber(cons[1]),tonumber(cons[2]))
        dreamRoleData.con = con

        --身法
        dreamRoleData.dex = 80 - str - con

        --悟性
        dreamRoleData.int = tonumber(dreamRoleData.int)
    end

    --门派
    local family = {
		level = dreamRoleData.level,
		name = dreamRoleData.family
	}	
	dreamRoleData.family = family

    --等级
    local lvStrList = string.split(dreamRoleData.lv,";")
    local lvNum = math.random(tonumber(lvStrList[1]),tonumber(lvStrList[2]))
    dreamRoleData.lv = lvNum

    -- 初始货币
    local drmoneyStrList = string.split(dreamRoleData.drmoney,";")
    local drmoneyNum = math.random(tonumber(drmoneyStrList[1]),tonumber(drmoneyStrList[2]))
    dreamRoleData.dreamPoints = drmoneyNum

    --初始背包大小
    local weightNum = 20
    if string.find(dreamRoleData.weight,";") then
        local weightStrList = string.split(dreamRoleData.weight,";")
        weightNum = math.random(tonumber(weightStrList[1]),tonumber(weightStrList[2]))
    else
        weightNum = tonumber(dreamRoleData.weight)
    end
    dreamRoleData.weight = weightNum

    --清醒值
    local sober = 0
    if string.find(dreamRoleData.drsober,";") then
        local soberList = string.split(dreamRoleData.drsober,";")
        sober = math.random(tonumber(soberList[1]),tonumber(soberList[2]))
    else
        sober = tonumber(dreamRoleData.drsober)
    end
    dreamRoleData.sober = sober

    if sober <= 0 then
        dreamRoleData.dreamStatus = 2 --梦醒状态
    else
        dreamRoleData.dreamStatus = 1 --正常状态
    end

    dreamRoleData.isDreamRole = true --是否是梦境人物（用于区分玩家角色）
    
    dreamRoleData.drtext = nil

    dreamRoleData.drmptext = nil

    Npc:initNpc(dreamRoleData)

    return dreamRoleData
end

--获取梦境人物属性模板
function DreamSystem:_getRoleAttrMoBan(id)
    local RoleAttrTab = self._resManager:getRoleAttrTab()
    if id then
        for k,v in pairs(RoleAttrTab) do
            if tostring(v.drwbid) == tostring(id) then
                return v
            end
        end
        error("不存在人物属性模板 id = "..id)
    else
        local extractList = {}
        local weight = {}
        for k,v in pairs(RoleAttrTab) do
            if v.zjweight then
                table.insert(extractList,v)
                table.insert(weight,v.zjweight)
            end
        end
        local random = Helper:RandomByWeight(weight)
        local roleMoban = extractList[random]
        return roleMoban
    end
end

--获取梦境人物武功模板
function DreamSystem:_getRoleWuGongMoBan(id)
    local RoleSkillTab = self._resManager:getRoleSkillTab()
    local RoleUnlockSkillTab = self._resManager:getRoleUnlockSkillTab()
    if id then
        for k,v in pairs(RoleSkillTab) do
            if tostring(v.drwxid) == tostring(id) then
                return v
            end
        end
        error("不存在人物武功模板 id = "..id)
    else
        local mobanList = {}
        local weight = {}

        --@familyId 玩家门派id,不抽取同门派武功模板
        local familyId = User:getRole():getFamilyId()
        
        -- 添加解锁门派模板
        for k,v in pairs(RoleUnlockSkillTab) do
            if v.Unlockid and AchievementSystem:checkUnlockPointIsUnlock(v.Unlockid) then
                if v.family ~= familyId and v.mpweight then
                    table.insert(mobanList,v)
                    table.insert(weight,v.mpweight)
                end
            end
        end
        
        local debug_data
        if DEBUG_MODE == 1 then
            debug_data = User:getRole():getDayFlag("DreamFamilyWeight")
        end

        for k,v in pairs(RoleSkillTab) do
            if v.family ~= familyId and v.mpweight then

                if DEBUG_MODE == 1 then
                    if type(debug_data) == "table" and debug_data[v.family] then
                        v.mpweight = debug_data[v.family]
                    end
                end

                table.insert(mobanList,v)
                table.insert(weight,v.mpweight)
            end
        end

        --师门信物
        if User:getRole():getTimeLimitFlagTime("family_token_id") > 0 then
            local familyMoBanId = User:getRole():getTimeLimitFlag("family_token_id")
            local moban
            for k,v in ipairs(mobanList) do
                if v.family == familyMoBanId then
                    moban = v
                    break
                end
            end

            if MapIsEmpty(moban) == false then
                User:getRole():setTimeLimitFlag("family_token_id",0,0)
                return moban
            end
            print("----------门派模板找不到对应信物门派 信物门派ID：",familyMoBanId)
		end

        local random = Helper:RandomByWeight(weight)
        return mobanList[random]
    end
end

--生成人物名字
function DreamSystem:_createName(sex)
    local RoleNameTab = self._resManager:getRoleNameTab()
    local nameList = {}
    for k,v in pairs(RoleNameTab) do
        table.insert( nameList, v)
    end

    local xStr,mStr = "",""

    if sex == "男" then
        xStr = nameList[math.random(1,#nameList)].boyx
        mStr = nameList[math.random(1,#nameList)].boym
    else
        xStr = nameList[math.random(1,#nameList)].girlx
        mStr = nameList[math.random(1,#nameList)].girlm
    end

    local name = xStr..mStr
    
    return name 
end

--获取梦境人物头像
function DreamSystem:getDreamRoleFaceImagPath(role)
    local RoleFaceImag = self._resManager:getRoleFaceImag()
    if role == nil  then
        return
    end
    local index = ""
    local imagPath = ""
    if role.sex == "男" then
        index = "drboy"
    else
        index = "drgirl"
    end

    for k,v in pairs(RoleFaceImag) do
        if v.drlooks == role.looks  then
            imagPath = v[index]
            break
        end
    end

    return imagPath
end

--增加技能主动招式熟练度
function DreamSystem:addDreamRoleSkillZhaoLv(fightRole,player)
    local role = fightRole:getRole()
    --战斗开始时的招式数组
	local fightStartZhaoIdArray = Helper:getDef(fightRole.fightStartPreparedActiveZhaoIdArray,{})

	--战斗完成时的招式数组
	local fightFinishZhaoIdArray = fightRole:getRole():getPreparedActiveZhaoIdArray()

	local zhaoList = Helper:arrayUnion(fightStartZhaoIdArray,fightFinishZhaoIdArray)

	if MapIsEmpty(zhaoList) == true then
        return
    end
    
    for i,zhaoId in pairs(zhaoList) do
        if zhaoId == "huifu" then
        else

            local baseZhaoId = Skill:getBaseZhaoId(zhaoId)
            local currLv = role:getSkillZhaoLv(baseZhaoId)
            
            if DEBUG_MODE == 1 then    
                print("zhaoId ",zhaoId) 
                print("currLv", currLv)
                print("fightRole:getActiveZhaoUseTimes(zhaoId)",fightRole:getActiveZhaoUseTimes(zhaoId))
                print("upodds", tonumber(self._resManager:getRoleSkillsZhao(zhaoId).lvprobability))
                print("getSkillZhaoPotEfficiency", role:getSkillZhaoPotEfficiency(baseZhaoId))
            end 

            local maxLv = role:getZhaoLvLimit(zhaoId)
            if currLv < 1 or currLv >= maxLv then
                return
            end

            if baseZhaoId ~= nil and fightRole:getActiveZhaoUseTimes(zhaoId) > 0 then
                local upodds = tonumber(self._resManager:getRoleSkillsZhao(zhaoId).lvprobability)
    
                if upodds < math.random(1,100) then
                    return
                end
            
                currLv = currLv + 1
                local exp = role:conversionZhaoExpAndLv("exp",currLv, role:getSkillZhaoPotEfficiency(baseZhaoId))
                
                local roleSkillZhao = {id = baseZhaoId, exp = exp}
                
                player:setSkillZhao(baseZhaoId, roleSkillZhao)
                PopText("奇招取胜，惊觉『"..Skill:getActiveZhao(zhaoId):getName().."』提升了一重。")
            end
        end
    end
end

--获得梦境武学评价
function DreamSystem:getDreamSkillDsc(skillId,role)
    if skillId == nil or role == nil then
        return ""
    end
    local skillAttr = self._resManager:getRoleSkillsTab(skillId)
    local currPinji = self:_getDreamSkillLevel(skillId,role)

    local dsc = skillAttr["lvtext"..currPinji]

    return dsc or "默认评价"
end

function DreamSystem:_getMaxPj()
    return 10
end

function DreamSystem:_getMinPj()
    return 1
end

--提升梦境武学品级
function DreamSystem:addDreamSkillLevel(skillId,role,addLevel)
    if skillId == nil or role == nil or addLevel == nil then
        return
    end

    local currPj = self:_getDreamSkillLevel(skillId,role)
    local finalPj = Helper:getRange(currPj + addLevel, self:_getMinPj(), self:_getMaxPj())
    local skillAttr = self._resManager:getRoleSkillsTab(skillId)

    local finalExp = skillAttr["lvexp"..tostring(finalPj)]
    if tonumber(finalExp) then 
        role:setSkill(skillId, {id = skillId, exp = tonumber(finalExp)})
    end
end

--获取梦境武学当前品级
function DreamSystem:_getDreamSkillLevel(skillId,role)
    if skillId == nil then
        return
    end
    local currPinji = 1 --当前品级
    local skillExp = role:getSkillExp(skillId)
    if skillExp == 0 then
        currPinji = 0
    end

    local skillAttr = self._resManager:getRoleSkillsTab(skillId)
    if MapIsEmpty(skillAttr) == false then
        local maxPj = self:_getMaxPj()
        for i = 1,maxPj do
            if skillExp >= skillAttr["lvexp"..i] then
                currPinji = i
            else
                break
            end
        end
    else
        error("主角技能表错误，技能表没有该id："..skillId)
    end
    
    return currPinji
end

function DreamSystem:getWebReward(context)
    RewardManager2:getWebReward(context)
end

function DreamSystem:getDreamEquipRes()
    return self._resManager:getDrEquipment()
end

function DreamSystem:showFloorSettleLayer(floor,map)
    if floor ~= 40 then
        return
    end
    PopupLayerController:showLayer("Dialog17Layer", function(layer)
        layer:setTextDesc("此般梦中殊途已然行至尽头，继续前行收获也是如出一辙，浮生若梦是去是留，还请决断。")
        layer:setButtonClose("继续挑战",function()
            layer:hideLayer()
        end)
        layer:setButtonConfirm("抽身离去",function()
            PopupLayerController:showLayer("LeaveDreamMapLayer", function(layer)
                layer:maxZ()
                layer:showLayer()
                layer:setBtn1Func("关闭",function ()
                    layer:hideLayer()
                end)
                layer:setBtn2Func("抽身离去",function()
                    self:mapComplete(map,function()
                        map.__MapLayer.TotalMapBtn_IsInit = false
                        map.__MapLayer:quit()
                        layer:hideLayer()
                    end)
                end)
                layer:setCurrfloorNum("("..floor.."层)")
            end)
            layer:hideLayer()
        end)
        layer:showLayer()
    end)
end

--@desc: 获取梦境角色门派介绍
--@author:LvBin
--@time:2025-02-10 17:24:31
--@role: 
--@return
function DreamSystem:getFamilyDesc(role)
    local dmenpaiinfo,menpaiText = self._resManager:getRoleSkillTab()[tostring(role.drwxid)]
	if MapIsEmpty(dmenpaiinfo) then
		local RoleUnlockSkillTab = self._resManager:getRoleUnlockSkillTab()
		for k,v in pairs(RoleUnlockSkillTab) do
			if v.family == role:getFamilyId() then
				menpaiText = v.drmptext
				break
			end
		end
	else
		menpaiText = self._resManager:getRoleSkillTab()[tostring(role.drwxid)].drmptext
	end

    return menpaiText
end

return newClass("DreamSystem", {}, DreamSystem)

0000000000000