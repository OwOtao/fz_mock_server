local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local BuffSystemUtil = require("app.FightSystem.FightBuff.BuffSystemUtil")

local RemoveBuffEffect = {}

function RemoveBuffEffect:create(effect, buffNeeded)
    local p = RemoveBuffEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function RemoveBuffEffect:ctor()
end

function RemoveBuffEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function RemoveBuffEffect:__init(effect, buffNeeded)
    self.__isFinished = false
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    self.__removeBuffType = self.__effect:getEffectTypeParam()[1]
    self.__removeBuffParams = self.__effect:getArgsParam()
    self.__removeBuffLevelCount = self.__effect:getArgsParam()[2] or -1
    assert(table.contains({"BuffAll", "BuffClass", "BuffID" , "BuffNum"}, self.__removeBuffType), "RemoveBuffEffect:__init() error, removeBuffType is invalid" .. tostring(self.__removeBuffType))
end

function RemoveBuffEffect:getEffectType()
    return self.__effect:getEffectType()
end

function RemoveBuffEffect:needRemoveBuff(buffClass, buffId)
    if self.__isFinished then
        return false
    end

    BuffSystemUtil:log("RemoveBuffEffect:needRemoveBuff:", buffClass, buffId)
    if self.__removeBuffType == "BuffAll" then
        return true
    elseif self.__removeBuffType == "BuffClass" then
        return table.indexof(self.__removeBuffParams, tostring(buffClass)) ~= false
    elseif self.__removeBuffType == "BuffID" then
        return table.indexof(self.__removeBuffParams, tostring(buffId)) ~= false
    else
        error("RemoveBuffEffect:needRemoveBuff() error, removeBuffType is invalid " .. tostring(self.__removeBuffType))
    end
end

function RemoveBuffEffect:getLevelCount()
    return self.__removeBuffLevelCount
end

function RemoveBuffEffect:finish()
    self.__isFinished = true
end

return class("RemoveBuffEffect", {ActiveEffect}, RemoveBuffEffect)
0000000000000000