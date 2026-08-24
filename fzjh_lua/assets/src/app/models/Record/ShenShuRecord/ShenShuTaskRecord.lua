local newClass = require("third.class.NewClass")

--@RefType [Record]
local Record = require("app.models.Record.Record")

local ShenShuTaskRecord = {}

function ShenShuTaskRecord:create(shenShuTask)
    return ShenShuTaskRecord.new():__init(shenShuTask)
end

function ShenShuTaskRecord:__init(shenShuTask)
    self.allCount = shenShuTask.allCount
    self.count = shenShuTask.count
    self.lingShiUseTime = shenShuTask.task.startTime

    return self
end


function ShenShuTaskRecord:submitRecord()
    Record:addLogData(Record.RECORD_TYPE.SHENSHU_TASK, self:_serialize())
end

function ShenShuTaskRecord:_serialize()
    local record = {
        allCount = self.allCount,
        count = self.count,
        lingShiUseTime = self.lingShiUseTime,
    }

    return record
end

return newClass("ShenShuTaskRecord", {}, ShenShuTaskRecord)
0000000