local class = require("third.class.NewClass")
local IMapBuilder = require("app.models.map.builder.IMapBuilder")
local BaseMap = require("app.models.map.BaseMap")

local MapBuilder = {}

function MapBuilder:create(mapId)
    local p = MapBuilder.new()
    p.__mapId = mapId
    return p
end

function MapBuilder:build()
    local mapData = Map:getDefaultMapById(self.__mapId)

    local map = inherit({}, mapData, BaseMap:create())

    Map:__initMapCompleteAward(map)
    Map:__initMapCompleteCondition(map)
    Map:__initMapRoom(map)
    Map:__initMapRole(map)
    Map:__initMapNpc(self.__mapId)
    Map:__initRandomNpc(self.__mapId)

    map:init()
    self.__map = map
end

function MapBuilder:getMap()
    return self.__map
end

return class("MapBuilder", {IMapBuilder}, MapBuilder)
000000000000