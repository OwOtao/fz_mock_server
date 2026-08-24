local class = require("third.class.NewClass")
local ActiveEffect = require("app.FightSystem.FightBuff.ActiveEffect")
local BuffSystemUtil = require("app.FightSystem.FightBuff.BuffSystemUtil")
local LogSystem = require("app.models.LogSystem.LogSystem")

local TransferBuffEffect = {}

function TransferBuffEffect:create(effect, buffNeeded)
    local p = TransferBuffEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function TransferBuffEffect:refresh()
    self:__init(self.__effect, self.__buffNeeded)
end

function TransferBuffEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    self.__transferBuffType = self.__effect:getEffectTypeParam()[1]
    self.__transferBuffTimes = tonumber(self.__effect:getEffectTypeParam()[2]) or 1
    self.__transferParams = self.__effect:getArgsParam()

    assert(table.contains({"BuffAll", "BuffClass", "BuffId"}, self.__transferBuffType), "TransferBuffEffect:__init() error, addActiveZhaoCDType is invalid" .. tostring(self.__addActiveZhaoCDType))
end

function TransferBuffEffect:getTransferType()
    return self.__transferBuffType
end

function TransferBuffEffect:getTransferParams()
    return self.__transferParams
end

function TransferBuffEffect:needTransferBuff(buffId, buffClass)
    if self.__transferBuffTimes and self.__transferBuffTimes > 0 then
        if self.__transferBuffType == "BuffAll" then
            return true
        elseif self.__transferBuffType == "BuffClass" then
            return table.contains(self.__transferParams, tostring(buffClass))
        elseif self.__transferBuffType == "BuffId" then
            return table.contains(self.__transferParams, tostring(buffId))
        else
            error("TransferBuffEffect:needTransferBuff() error, transferBuffType is invalid" .. tostring(self.__transferBuffType))
        end
    end
    return false
end

function TransferBuffEffect:getTransferBuffTimes()
    return self.__transferBuffTimes
end

function TransferBuffEffect:transferBuff()
    self.__transferBuffTimes = self.__transferBuffTimes - 1
end

-- LogSystem:attach("增益日志", TransferBuffEffect)

return class("TransferBuffEffect", {ActiveEffect}, TransferBuffEffect)
000000000