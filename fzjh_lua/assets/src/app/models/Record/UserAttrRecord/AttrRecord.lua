--[[
    author:Seven
    time:2023-06-25 18:07:09
    desc: 角色属性变化记录
]]
local newClass = require("third.class.NewClass")

local Record = require("app.models.Record.Record")

local AttrRecord = {}

AttrRecord.R_TYPE = {
    MAP_RESULT = 1
}

function AttrRecord:create(stype, attrName, value, env)
    return AttrRecord.new():__init(stype, attrName, value, env)
end

function AttrRecord:__init(stype, attrName, value, env)
    self._type = stype
    self._attrName = attrName
    self._value = value
    self._env = Helper:getDef(env, {})
    return self
end

function AttrRecord:addEnv(key, value)
    self._env[key] = value
end

function AttrRecord:submitRecord()
    Record:addLogData(Record.RECORD_TYPE.ATTR_CHANGE, self:_serialize())
end

function AttrRecord:_serialize()
    local record = {
        stype = self._type,
        attrName = self._attrName,
        value = self._value
    }

    if not MapIsEmpty(self._env) then
        for k, v in pairs(self._env) do
            record[k] = v
        end
    end

    return record
end

return newClass("AttrRecord", {}, AttrRecord)
0000000000