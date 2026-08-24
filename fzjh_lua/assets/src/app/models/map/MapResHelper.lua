local MapResHelper = {}

function MapResHelper:getMapVolumeRes()
    return require("script.newmap.map.world")
end

function MapResHelper:getDefaultMapInfoRes()
    return require("script.map.map")["map"]
end

function MapResHelper:getEditorMapInfoRes()
    return require("script.newmap.map.mapInfo")
end

function MapResHelper:getChallengeMapInfoRes()
    return requireWithEncrypt("script.challengeMap.mapInfo")["map"]
end

function MapResHelper:getMapRoleRes(mapId)
    return requireWithEncrypt("script.map.mapRole." .. mapId)
end

function MapResHelper:getMapItemRes(mapId)
    return requireWithEncrypt("script.map.mapItem." .. mapId)
end

function MapResHelper:getMapNpcBaseRes(mapId)
    return require("script.map.mapRoleBase."..mapId)
end

function MapResHelper:getMapRoomRes(mapId)
    return require("script.map.mapRoom."..mapId) 
end

function MapResHelper:getMapConditionAndResultRes(mapId)
    return requireWithEncrypt("script.map.mapConditionAndResult."..mapId) 
end

function MapResHelper:getEditorMapRes(mapId)
    return requireWithEncrypt("script.newmap.map.maps." .. mapId)
end

function MapResHelper:getMapRandomNpcRes()
    return require("script.others.randomNpc")
end

function MapResHelper:getMapOtherNpcRes()
    return require("script.others.allmappeople").Sheet1
end

function MapResHelper:getMapOuYuListRes()
    return requireWithEncrypt("script.mapMeet.ouyu5")["fball"]
end

return MapResHelper 00000