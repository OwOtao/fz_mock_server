local class = require("third.class.NewClass")

local ChallengeMapResource = require("app.models.ChallengeMap.ChallengeMapResource")

local ChallengeMapBuilder = {}

function ChallengeMapBuilder:create(mapId)
    local p = ChallengeMapBuilder.new({__mapId = mapId})
    return p
end

function ChallengeMapBuilder:buildMap()
    local ChallengeMap = require("app.models.ChallengeMap.ChallengeMap")
    local mapData = ChallengeMapResource:getInstance():getMapInfoById(self.__mapId)
    mapData.__VERSION = CHALLENGE_MAP_VERSION

    self:__initMapRoom(mapData)
    self:__initMapObject(mapData)
    self:__initMapObjectData(mapData)

    self.__map = ChallengeMap:create(mapData)
end

function ChallengeMapBuilder:getMap()
    return self.__map
end

function ChallengeMapBuilder:__initMapObjectData(mapData)
    mapData.__objectDataMap = ChallengeMapResource:getInstance():getMapNpcsById(mapData.npcGridId)
end

function ChallengeMapBuilder:__initMapObject(mapData)
    local roles = ChallengeMapResource:getInstance():getMapRolesById(mapData.roleGridId)

    mapData.objects = {}

    for k, role in pairs(roles) do
        role.type = "role"
        mapData.objects[k] = role
    end

    local items = ChallengeMapResource:getInstance():getMapItemsById(mapData.itemGridId)

    for k, item in pairs(items) do
        item.type = "item"
        mapData.objects[k] = item
    end

    for _, object in pairs(mapData.objects) do
        object.operationList = table.getTableListByKeyList(object, {"caozuoName", "buttonShow", "condition", "result"})
        object.autoConditionAndResultList = table.getTableListByKeyList(object, {"autoCondition", "autoResult"})
    end
end

function ChallengeMapBuilder:__initMapRoom(map)
    local mapRoom = ChallengeMapResource:getInstance():getMapRoomsById(map.roomGridId)
    map.room = inherit({}, mapRoom)
    for k, room in pairs(map.room) do
        self:__initRoomLink(room)
        self:__initRoomConditionAndResult(room)
    end
end

function ChallengeMapBuilder:__initRoomLink(room)
    local link = {}
    local linkKeyWord = {"center", "left", "leftUp", "up", "rightUp", "right", "rightDown", "down", "leftDown"}
    for k, keyWord in pairs(linkKeyWord) do
        if type(room[keyWord]) == "string" and string.len(room[keyWord]) >= 1 then
            link[keyWord] = room[keyWord]
        end
    end
    room.link = link
end

function ChallengeMapBuilder:__initRoomConditionAndResult(room)
    local autoConditionAndResult = table.getTableListByKeyList(room, {"autoCondition", "autoResult"})
    room.autoConditionAndResultList = autoConditionAndResult
end

return class("ChallengeMapBuilder", {}, ChallengeMapBuilder)
00000