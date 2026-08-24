local TransmitRoomModel = {}

local SystemType = {
    Default = 1,
    ShenShu = 2,
    BaoZang = 3,
    LiLian = 4,
    VisitTask = 5
}

function TransmitRoomModel:getShenShuFilterRoomList()
    return self:__getFilterRoomListBySystem(SystemType.ShenShu)
end

function TransmitRoomModel:getBaoZangFilterRoomList()
    return self:__getFilterRoomListBySystem(SystemType.BaoZang)
end

function TransmitRoomModel:getDefaultFilterRoomList()
    return self:__getFilterRoomListBySystem(SystemType.Default)
end

function TransmitRoomModel:getLilianFilterRoomList()
    return self:__getFilterRoomListBySystem(SystemType.LiLian)
end

function TransmitRoomModel:getVisitTaskFilterRoomList()
    return self:__getFilterRoomListBySystem(SystemType.VisitTask)
end

function TransmitRoomModel:__getFilterRoomListBySystem(system)
    local roomList = {}
    local roomConfig = require("script.others.transmitRoom")["传送房间屏蔽表"]

    for __,config in pairs(roomConfig) do
        if config and config.systemId == system then
            local _roomList = config.roomList

            if _roomList == nil then
                return roomList
            end

            _roomList = string.split(_roomList,",")

            if MapIsEmpty(_roomList) == false then
                for __,roomId in pairs(_roomList) do
                    roomList[roomId] = true
                end
            end

            break
        end
    end

    return roomList
end




return TransmitRoomModel00000