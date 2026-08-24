--[[
    author:Seven
    time:2024-01-12 15:09:04
    desc: 先天属性方案调整日志
]]
local newClass = require("third.class.NewClass")

--@RefType [Record]
local Record = require("app.models.Record.Record")

local NaturalAttrjustmentPlanRecord = {}

NaturalAttrjustmentPlanRecord.R_TYPE = {
    SWITCH = 1,
    ADJUSTMENT = 2
}

function NaturalAttrjustmentPlanRecord:create(stype, originid, replaceid, usetimes, resettm, env)
    return NaturalAttrjustmentPlanRecord.new():__init(stype, originid, replaceid, usetimes, resettm, env)
end

function NaturalAttrjustmentPlanRecord:__init(stype, oldPlanData, newPlanData, costInfo)
    self._stype = assert(stype, "stype is nil")
    self._oldPlanData = assert(oldPlanData, "oldPlanData is nil")
    self._newPlanData = assert(newPlanData, "newPlanData is nil")
    self._costInfo = costInfo
    return self
end

function NaturalAttrjustmentPlanRecord:addEnv(key, value)
    self._env[key] = value
end

function NaturalAttrjustmentPlanRecord:submitRecord()
    Record:addLogData(Record.RECORD_TYPE.NATURAL_ATTR_ADJUSTMENT, self:_serialize())
end

function NaturalAttrjustmentPlanRecord:_serialize()
    local record = {
        stype = self._stype,
        before = self._oldPlanData,
        after = self._newPlanData,
        cost = self._costInfo
    }

    return record
end

return newClass("NaturalAttrjustmentPlanRecord", {}, NaturalAttrjustmentPlanRecord)
00000