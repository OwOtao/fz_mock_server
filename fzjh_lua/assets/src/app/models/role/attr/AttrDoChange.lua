--[[
    author:Seven
    time:2023-06-28 11:38:26
    desc:
]]
local newClass = require("third.class.NewClass")

local AttrRecord = require("app.models.Record.UserAttrRecord.AttrRecord")

local AttrDoChange = {}

local donotRecordAttr = {
    ["qi"] = true,
    ["neili"] = true,
    ["qiPercent"] = true,
    ["qiMax"] = true,
    ["neiliMax"] = true,
    ["neiLiLimit"] = true
}

function AttrDoChange:create(role, stype, attrName, value, env)
    return AttrDoChange.new():__init(role, stype, attrName, value, env)
end

function AttrDoChange:__init(role, stype, attrName, value, env)
    self._type = stype
    self._role = role
    self._attrName = attrName
    self._value = value

    --@RefType [src.app.models.Record.UserAttrRecord.AttrRecord#AttrRecord]
    self.__record = AttrRecord:create(stype, attrName, value, env)

    return self
end

function AttrDoChange:doAttrGet(func)
    self._oldValue = self._role:getAttr(self._attrName)

    func(self._attrName, self._value)

    self._newValue = self._role:getAttr(self._attrName)

    if donotRecordAttr[self._attrName] then
        return 
    end

    self.__record:addEnv("newvalue", self._newValue)
    self.__record:addEnv("oldvalue", self._oldValue)
    self:_submitRecord()
end

function AttrDoChange:_submitRecord()
    if self._role ~= User:getRole() then
        return
    end

    self.__record:submitRecord()
end

return newClass("AttrDoChange", {}, AttrDoChange)
000