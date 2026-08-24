local EditorMap = {}

--@desc: 初始化房间
--@author:Liang SongQiang
--@time:2018-12-01 11:04:06
local function initMapRoom(map)
    -- 初始化房间链接
    local function _initRoomLink(room)
        local link = {}
        local linkKeyWord = {"center", "left", "leftUp", "up", "rightUp", "right", "rightDown", "down", "leftDown"}
        for k, keyWord in pairs(linkKeyWord) do
            link[keyWord] = room[keyWord]
            room[keyWord] = nil
        end
        room.link = link
    end

    -- 初始化房间单位
    local function _initRoomUnit(room)
        local unitList = {}
        for i = 1, 999 do
            local unit = room["unit" .. tostring(i)]
            if unit then
                table.insert(unitList, unit)
                room["unit" .. tostring(i)] = nil
            else
                break
            end
        end

        room.roleList = unitList
    end

    -- 副本房间
    local MapRoom = {}
    map.roomCount = #map.roomList
    for i, v in ipairs(map.roomList) do
        local room = v

        -- 初始化房间
        _initRoomLink(room)
        _initRoomUnit(room)

        -- 清理无用的数据
        room.fullName = nil

        room.stepMusic = "jiaobu"

        MapRoom[room.id] = clone(room)
    end

    map.roomList = nil
    map.room = MapRoom
end

local function initMapUnit(map)
    --@RefType [src.app.models.npc.EditorNpc#EditorNpc]
    -- local Npc = require("app.models.npc.EditorNpc")

    map.roles = {}

    -- 副本单位阶段表
    local stageMap = {}

    for i, baseUnit in ipairs(map.unitList) do
        if baseUnit.id ~= nil then
            -- stageMap[baseUnit.id] = {}

            for i, stage in ipairs(baseUnit.behaviourStageList) do
                if stage.stageId ~= nil and stage.stageId ~= "" then
                    local unit = {
                        id = baseUnit.id,
                        name = baseUnit.name
                    }
                    -- unit.behaviourStageList = nil
                    unit.behaviourStageList = nil
                    Helper:tableCover(unit, stage)
                    unit._version = EDITOR_MAP_VERSION
                    -- 属性修正
                    Npc:initNpc(unit)

                    unit.id = unit.stageId

                    map.roles[unit.id] = unit

                    -- stageMap[baseUnit.id][stage.stageId] = unit
                else
                    print(baseUnit.id .. "阶段ID错误")
                end
            end

            -- if MapIsEmpty(unitInstanceList) ~= true then
            --     for i, unit in ipairs(unitInstanceList) do
            --         if unit.unitId and unit.stageId and stageMap[baseUnit.id][unit.stageId] then
            --             -- Helper:print_lua_table(stageMap[baseUnit.id][unit.stageId])
            --             map.roles[unit.unitId] = stageMap[baseUnit.id][unit.stageId]
            --             map.roles[unit.unitId].unitId = unit.unitId
            --             map.roles[unit.unitId].id = unit.unitId
            --         else
            --             -- Helper:print_lua_table(unitInstanceList)
            --             -- print("111111111111111111")
            --             if DEBUG_MODE == 1 then
            --                 assert(nil, "阶段列表没有找到NPC 基础ID:" .. baseUnit.id .. "，阶段ID：" .. unit.unitId .. "，stageId：" .. unit.stageId)
            --             end
            --         end
            --     end
            -- end
        else
            print("单位ID不存在 " .. i)
        end
    end

    -- map.stageMap = stageMap
    map.unitList = nil
end


local function initMapBranch(map)
    map.branchMap = {}

    if MapIsEmpty(map.branchTreeList) ~= true then
        for i, branchTree in ipairs(map.branchTreeList) do
            local tab = {}
            tab.id = branchTree.id
            tab.currNodeId = branchTree.currNodeId
            tab.nodeMap = {}

            local function initBranchNode(node,parentId)
                if node ~= nil then
                    tab.nodeMap[node.id] = node
                    node.parentId = parentId
                    for i, child in ipairs(node._childern) do
                        initBranchNode(child,node.id)
                    end

                    node.pos = nil
                    node._childern = nil
                end
            end

            initBranchNode(branchTree.treeRoot,nil)

            map.branchMap[branchTree.id] = tab
        end
    end
    map.branchTreeList = nil
end

function EditorMap:initMap(mapData)
    local map = Helper:tableCover(require("app.models.EMap.EMap"):create(), mapData)

    if MapIsEmpty(map.mapAppearance) == false then
        map.mapAppearanceIndex = map.mapAppearance[1].mapAppearanceIndex
        map.mapAppearance = map.mapAppearance[1].mapAppearance
        map.completeConditions = {}
    end

    -- print("=====================================")
    -- print("===== 初始化副本 " .. mapId .. " 房间 =====")
    initMapRoom(map)
    -- print("===== 初始化副本 " .. mapId .. " 单位 =====")
    initMapUnit(map)
    -- print("===== 初始化分支 " .. mapId .. " 分支 =====")
    initMapBranch(map)

    return map
end

return EditorMap
000000000000000