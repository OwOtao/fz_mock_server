local DreamModel = {}

local DreamEquip = require("app.models.DreamWorldModel.DreamEquip")

local DreamConst = require("app.models.DreamWorldModel.DreamConst")

local ROOM_EVENT_TYPE = DreamConst.RoomEventType

local EVENT_TYPE_ATRR_NAME = DreamConst.RoomTypeName

--@desc 存放是否已经到过的房间
local hadBeenToRooms = {}

function DreamModel:clearInfo()
    hadBeenToRooms = {}
end

--@desc:
--@author:Seven_L
--@time:2020-07-02 15:39:34
--@map: [BaseMap]
--@roomId:
function DreamModel:enterRoom(map, roomId)
    local player = map:getPlayer()

    player.emotionMgr:enterRoom(map, roomId)

    local room = map:getRoomById(roomId)

    if hadBeenToRooms[roomId] == true then
        return
    end

    print("enter dream room , type :" .. room.roomType, EVENT_TYPE_ATRR_NAME[room.roomType])

    if math.random(1, 100) >= 50 then
        player.emotionMgr:getCurrEmotion():showTips()
    end

    if room.roomType == ROOM_EVENT_TYPE.EMPTY then
        self:triggerEvent(map, roomId, 1)
    end
end

--@desc: 随机事件触发
--@author:Seven_L
--@time:2020-07-02 16:42:26
--@map: [BaseMap]
--@roomId: 现在处于的房间
--@times: 第几次执行
function DreamModel:triggerEvent(map, roomId, times)
    local delaySec = {
        2,
        4,
        3
    }

    local room = map:getRoomById(roomId)

    room.scheduleTag =
        map:setSchedule(
        function()
            local player = map:getPlayer()
            if player.emotionMgr:triggerRandomEvent({map = map, roomId = roomId, role = player}) then
            else
                local nextSec = delaySec[times + 1]
                if nextSec ~= nil then
                    self:triggerEvent(map, roomId, times + 1)
                end
            end
        end,
        nil,
        delaySec[times],
        1
    )
end

function DreamModel:leaveRoom(map, roomId)
    self:unRoomSchedule(map, roomId)

    local player = map:getPlayer()

    player.emotionMgr:leaveRoom(map, roomId)

    if hadBeenToRooms[roomId] == nil then
        hadBeenToRooms[roomId] = true
    end

    --@desc 删除房间角色列表
    local drSystem = User:getRole():getDreamSystem()
    drSystem:deleteRoleList(map, roomId)
end

function DreamModel:unRoomSchedule(map, roomId)
    local room = map:getRoomById(roomId)

    if room.scheduleTag ~= nil then
        map:unSchedule(room.scheduleTag)
    end
end

function DreamModel:enterMap(map)
    local player = map:getPlayer()

    DreamEquip:changeNextStageWeapon(player)
    
    local currFloor = player.dreamWorld.cFloor
    if currFloor > 1 then
        --@desc 第一层不触发进入楼层的情况
        player.emotionMgr:enterNewFloor({map = map, roomId = map:getDefaultRoomId()})
    end

end

function DreamModel:exitMap(map)
    local roomId = map:getCurrRoomId()
    self:unRoomSchedule(map, roomId)
end

function DreamModel:qieCuoFightEnd(map,winTeamId)
    local player = map:getPlayer()
    player.emotionMgr:battleFinish({map = map, roomId = map:getCurrRoomId(),winTeamId = winTeamId})
end

function DreamModel:jueDouFightEnd(map,winTeamId)
    local player = map:getPlayer()
    player.emotionMgr:fightFinish({map = map, roomId = map:getCurrRoomId(),winTeamId = winTeamId})
end

function DreamModel:enterFightEvent(map)
    local player = map:getPlayer()
    player.emotionMgr:enterFightEvent()
end

return DreamModel
00000000