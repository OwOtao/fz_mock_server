--[[
    author:Seven
    time:2023-07-05 12:11:52
    desc: 化元日志
]]
local newClass = require("third.class.NewClass")

--@RefType [Record]
local Record = require("app.models.Record.Record")

local HuaYuanRecord = {}

HuaYuanRecord.R_TYPE = {
    BREATHVAL_USE = 1,
    ITEM_USE = 2
}

function HuaYuanRecord:create(stype, originid, replaceid, usetimes, resettm, env)
    return HuaYuanRecord.new():__init(stype, originid, replaceid, usetimes, resettm, env)
end

function HuaYuanRecord:__init(stype, originid, replaceid, usetimes, resettm, env)
    self._stype = assert(stype, "stype is nil")
    self._originid = assert(originid, "originid is nil")
    self._replaceid = assert(replaceid, "replaceid is nil")
    self._usetimes = usetimes
    self._resettm = resettm
    self._env = Helper:getDef(env, {})
    return self
end

function HuaYuanRecord:addEnv(key, value)
    self._env[key] = value
end

function HuaYuanRecord:submitRecord()
    Record:addLogData(Record.RECORD_TYPE.M_HUAYUAN, self:_serialize())
end

function HuaYuanRecord:_serialize()
    local record = {
        stype = self._stype,
        meridianbef = self._originid,
        meridianaft = self._replaceid,
        usetimes = self._usetimes,
        resettm = self._resettm
    }

    if not MapIsEmpty(self._env) then
        for k, v in pairs(self._env) do
            record[k] = v
        end
    end

    return record
end

return newClass("HuaYuanRecord", {}, HuaYuanRecord)
00