--[[
	副本工厂类, 隔离副本细节, 对外提供统一的副本接口
]]
local assertIsInstance = require("third.assertIsInstance.assertIsInstance")
local IMap = require("app.models.map.interface.IMap")
local MapConstant = require("app.models.map.constant.MapConstant")
local BaseMap = require("app.models.map.BaseMap")
local DreamMap = require("app.models.map.DreamMap")
local EMapBuilder = require("app.models.map.builder.EMapBuilder")
local BaseMapBuilder = require("app.models.map.builder.BaseMapBuilder")

local function log(...)
    print("MapFactory:", ...)
end

local MapFactory = {}

function MapFactory:createMap(mapVersion, mapType, mapId)
    log("createMap", mapType)

    local map =
        switch(
        mapType,
        {
            [MapConstant.MapType.DREAM_MAP] = function()
                local builder = EMapBuilder:create(mapId)
                builder:build()
                return builder:getMap()
            end,
            [MapConstant.MapType.BASE_MAP] = function()
                local builder = BaseMapBuilder:create(mapId)
                builder:build()
                return builder:getMap()
            end,
            [MapConstant.MapType.CHALLENGE_MAP] = function()
                error()
            end,
            default = function()
                return require("app.models.map.BaseMap"):create()
            end
        }
    )

    return assertIsInstance(map, IMap)
end

function MapFactory:createChallengeMap(mapId)
    local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")
    return ChallengeMapSystem:getInstance():createMap(mapId)
end

return MapFactory
000000000