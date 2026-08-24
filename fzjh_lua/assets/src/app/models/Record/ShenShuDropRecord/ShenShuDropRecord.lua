local newClass = require("third.class.NewClass")

--@RefType [Record]
local Record = require("app.models.Record.Record")

local ShenShuDropRecord = {}

function ShenShuDropRecord:create(dropType, shenShuId, mapId, roomId, npcId)
    return ShenShuDropRecord.new():__init(dropType, shenShuId, mapId, roomId, npcId)
end

function ShenShuDropRecord:__init(dropType, shenShuId, mapId, roomId, npcId)
    self._dropType = assert(dropType, "dropType is nil")
    self._shenShuId = assert(shenShuId, "shenShuId is nil")
    self._mapId = assert(mapId, "mapId is nil")
    self._roomId = assert(roomId, "roomId is nil")
    self._npcId = npcId

    return self
end


function ShenShuDropRecord:submitRecord()
    Record:addLogData(Record.RECORD_TYPE.SHENSHU_DROP, self:_serialize())
end

function ShenShuDropRecord:_serialize()
    local record = {
        dropType = self._dropType,
        shenShuId = self._shenShuId,
        mapId = self._mapId,
        roomId = self._roomId,
        npcId = self._npcId,
    }

    return record
end

return newClass("ShenShuDropRecord", {}, ShenShuDropRecord)
00000