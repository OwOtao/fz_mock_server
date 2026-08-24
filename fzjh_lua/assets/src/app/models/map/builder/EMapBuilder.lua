local class = require("third.class.NewClass")
local IMapBuilder = require("app.models.map.builder.IMapBuilder")

local MapBuilder = {}

function MapBuilder:create(map)
    local p = MapBuilder.new()
    p.__map = __map
    return p
end

function MapBuilder:build()
    --@TODO 2018-12-04 22:26:25 编辑器副本创建流程
    local mapData = inherit({}, Map:getDefaultMapById(self.mapId))

    --@RefType [src.app.models.map.EditorMap#EditorMap]
    local EditorMap = require("app.models.map.EditorMap")
    local map = EditorMap:initMap(mapData)
    map:init()
    self.__map = map
end

function MapBuilder:getMap()
    return self.__map
end

return class("MapBuilder", {IMapBuilder}, MapBuilder)
00000000