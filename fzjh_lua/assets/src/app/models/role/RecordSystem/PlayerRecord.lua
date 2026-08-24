local PlayerRecord = {}

function PlayerRecord:__getJingMaxRecord(role)
    local currValue, part = role:getJingMax()

    return {
        value = currValue,
        part = part
    }
end

function PlayerRecord:getRecord(role)
    local jingMaxRecord = self:__getJingMaxRecord(role)

    return {
        jingMaxRecord = jingMaxRecord
    }
end

return PlayerRecord
0000000000000